unit Ths.Erp.Database.Table.RctIscilikGideri;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysOlcuBirimi,
  Ths.Erp.Database.Table.SetRctIscilikGiderTipi;

type
  TRctIscilikGideri = class(TTable)
  private
    FGiderKodu: TFieldDB;
    FGiderAdi: TFieldDB;
    FFiyat: TFieldDB;
    FOlcuBirimiID: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FGiderTipiID: TFieldDB;
    FGiderTipi: TFieldDB;
  published
    FBirim: TSysOlcuBirimi;
    FSetGiderTipi: TSetRctIscilikGiderTipi;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property GiderKodu: TFieldDB read FGiderKodu write FGiderKodu;
    Property GiderAdi: TFieldDB read FGiderAdi write FGiderAdi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
    Property OlcuBirimiID: TFieldDB read FOlcuBirimiID write FOlcuBirimiID;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property GiderTipiID: TFieldDB read FGiderTipiID write FGiderTipiID;
    Property GiderTipi: TFieldDB read FGiderTipi write FGiderTipi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TRctIscilikGideri.Create(ADatabase: TDatabase);
begin
  TableName := 'rct_iscilik_gideri';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FSetGiderTipi := TSetRctIscilikGiderTipi.Create(ADatabase);
  FBirim := TSysOlcuBirimi.Create(ADatabase);

  FGiderKodu := TFieldDB.Create('gider_kodu', ftWideString, '', Self, '');
  FGiderAdi := TFieldDB.Create('gider_adi', ftWideString, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
  FOlcuBirimiID := TFieldDB.Create('olcu_birimi_id', ftInteger, 0, Self, '');
  FOlcuBirimi := TFieldDB.Create(FBirim.OlcuBirimi.FieldName, FBirim.OlcuBirimi.DataType, '', Self, '');
  FGiderTipiID := TFieldDB.Create('gider_tipi_id', ftInteger, 0, Self, '');
  FGiderTipi := TFieldDB.Create(FSetGiderTipi.GiderTipi.FieldName, FSetGiderTipi.GiderTipi.DataType, '', Self, '');
end;

destructor TRctIscilikGideri.Destroy;
begin
  FreeAndNil(FBirim);
  FreeAndNil(FSetGiderTipi);
  inherited;
end;

procedure TRctIscilikGideri.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FGiderKodu.QryName,
        FGiderAdi.QryName,
        FFiyat.QryName,
        FOlcuBirimiID.QryName,
        addField(FBirim.TableName, FBirim.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        FGiderTipiID.QryName,
        addField(FSetGiderTipi.TableName, FSetGiderTipi.GiderTipi.FieldName, FGiderTipi.FieldName)
      ], [
        addJoin(jtLeft, FBirim.TableName, FBirim.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
        addJoin(jtLeft, FSetGiderTipi.TableName, FSetGiderTipi.Id.FieldName, TableName, FGiderTipiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
    end;
  end;
end;

procedure TRctIscilikGideri.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FGiderKodu.QryName,
        FGiderAdi.QryName,
        FFiyat.QryName,
        FOlcuBirimiID.QryName,
        addField(FBirim.TableName, FBirim.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        FGiderTipiID.QryName,
        addField(FSetGiderTipi.TableName, FSetGiderTipi.GiderTipi.FieldName, FGiderTipi.FieldName)
      ], [
        addJoin(jtLeft, FBirim.TableName, FBirim.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
        addJoin(jtLeft, FSetGiderTipi.TableName, FSetGiderTipi.Id.FieldName, TableName, FGiderTipiID.FieldName),
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

procedure TRctIscilikGideri.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FGiderKodu.FieldName,
        FGiderAdi.FieldName,
        FFiyat.FieldName,
        FOlcuBirimiID.FieldName,
        FGiderTipiID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TRctIscilikGideri.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FGiderKodu.FieldName,
        FGiderAdi.FieldName,
        FFiyat.FieldName,
        FOlcuBirimiID.FieldName,
        FGiderTipiID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TRctIscilikGideri.Clone: TTable;
begin
  Result := TRctIscilikGideri.Create(Database);
  CloneClassContent(Self, Result);
end;

end.

