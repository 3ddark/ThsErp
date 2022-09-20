unit Ths.Erp.Database.Table.PrsSrcBilgisi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetPrsSrcTipi,
  Ths.Erp.Database.Table.PrsPersonel;

type
  TPrsSrcBilgisi = class(TTable)
  private
    FSrcTipiID: TFieldDB;
    FSrcTipi: TFieldDB;
    FPersonelID: TFieldDB;
    FPersonel: TFieldDB;

    FSetSrcTipi: TSetPrsSrcTipi;
    FPers: TPrsPersonel;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property SrcTipiID: TFieldDB read FSrcTipiID write FSrcTipiID;
    Property SrcTipi: TFieldDB read FSrcTipi write FSrcTipi;
    Property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    Property Personel: TFieldDB read FPersonel write FPersonel;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TPrsSrcBilgisi.Create(ADatabase: TDatabase);
begin
  TableName := 'prs_src_bilgisi';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FSetSrcTipi := TSetPrsSrcTipi.Create(Database);
  FPers := TPrsPersonel.Create(Database);

  FSrcTipiID := TFieldDB.Create('src_tipi_id', ftInteger, 0, Self, 'SRC Tipi ID');
  FSrcTipi := TFieldDB.Create(FSetSrcTipi.SrcTipi.FieldName, FSetSrcTipi.SrcTipi.DataType, '', Self, 'SRC Tipi');
  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel Kartý ID');
  FPersonel := TFieldDB.Create(FPers.AdSoyad.FieldName, FPers.AdSoyad.DataType, '', Self, 'Personel Adý');
end;

destructor TPrsSrcBilgisi.Destroy;
begin
  FreeAndNil(FSetSrcTipi);
  FreeAndNil(FPers);
  inherited;
end;

procedure TPrsSrcBilgisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FSrcTipiID.QryName,
        addField(FSetSrcTipi.TableName, FSetSrcTipi.SrcTipi.FieldName, FSrcTipi.FieldName),
        FPersonelID.QryName,
        addField(FPers.TableName, FPers.AdSoyad.FieldName, FPersonel.FieldName)
      ], [
        addJoin(jtLeft, FSetSrcTipi.TableName, FSetSrcTipi.Id.FieldName, TableName, FSrcTipiID.FieldName),
        addJoin(jtLeft, FPers.TableName, FPers.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TPrsSrcBilgisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Id.QryName,
        FSrcTipiID.QryName,
        addField(FSetSrcTipi.TableName, FSetSrcTipi.SrcTipi.FieldName, FSrcTipi.FieldName),
        FPersonelID.QryName,
        addField(FPers.TableName, FPers.AdSoyad.FieldName, FPersonel.FieldName)
      ], [
        addJoin(jtLeft, FSetSrcTipi.TableName, FSetSrcTipi.Id.FieldName, TableName, FSrcTipiID.FieldName),
        addJoin(jtLeft, FPers.TableName, FPers.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TPrsSrcBilgisi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FSrcTipiID.FieldName,
        FPersonelID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then AID := Fields.FieldByName(Id.FieldName).AsInteger
      else AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TPrsSrcBilgisi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FSrcTipiID.FieldName,
        FPersonelID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TPrsSrcBilgisi.Clone: TTable;
begin
  Result := TPrsSrcBilgisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
