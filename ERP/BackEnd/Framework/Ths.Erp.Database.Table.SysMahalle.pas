unit Ths.Erp.Database.Table.SysMahalle;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysSemt,
  Ths.Erp.Database.Table.SysIlce,
  Ths.Erp.Database.Table.SysSehir;

type
  TSysMahalle = class(TTable)
  private
    FMahalleAdi: TFieldDB;
    FPostaKodu: TFieldDB;
    FSemtId: TFieldDB;
    FSemtAdi: TFieldDB;
    FIlceId: TFieldDB;
    FIlceAdi: TFieldDB;
    FSehirId: TFieldDB;
    FSehirAdi: TFieldDB;

    FSysSemt: TSysSemt;
    FSysIlce: TSysIlce;
    FSysSehir: TSysSehir;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property MahalleAdi: TFieldDB read FMahalleAdi write FMahalleAdi;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property SemtId: TFieldDB read FSemtId write FSemtId;
    Property SemtAdi: TFieldDB read FSemtAdi write FSemtAdi;
    Property IlceId: TFieldDB read FIlceId write FIlceId;
    Property IlceAdi: TFieldDB read FIlceAdi write FIlceAdi;
    Property SehirId: TFieldDB read FSehirId write FSehirId;
    Property SehirAdi: TFieldDB read FSehirAdi write FSehirAdi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysMahalle.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_mahalle';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysSemt := TSysSemt.Create(ADatabase);
  FSysIlce := TSysIlce.Create(ADatabase);
  FSysSehir := TSysSehir.Create(ADatabase);

  FMahalleAdi := TFieldDB.Create('mahalle_adi', ftWideString, '', Self, 'Mahalle Adý');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftWideString, '', Self, 'Posta Kodu');
  FSemtId := TFieldDB.Create('semt_id', ftInteger, 0, Self, 'Semt Id');
  FSemtAdi := TFieldDB.Create(FSysSemt.SemtAdi.FieldName, FSysSemt.SemtAdi.DataType, '', Self, 'Semt Adý');
  FIlceId := TFieldDB.Create(FSysSemt.IlceId.FieldName, FSysSemt.IlceId.DataType, 0, Self, 'Ýlçe Id');
  FIlceAdi := TFieldDB.Create(FSysIlce.IlceAdi.FieldName, FSysIlce.IlceAdi.DataType, '', Self, 'Ýlçe Adý');
  FSehirId := TFieldDB.Create(FSysIlce.SehirId.FieldName, FSysIlce.SehirId.DataType, '', Self, 'Þehir Id');
  FSehirAdi := TFieldDB.Create(FSysSehir.SehirAdi.FieldName, FSysSehir.SehirAdi.DataType, '', Self, 'Þehir Adý');
end;

destructor TSysMahalle.Destroy;
begin
  FreeAndNil(FSysSemt);
  FreeAndNil(FSysIlce);
  FreeAndNil(FSysSehir);
  inherited;
end;

procedure TSysMahalle.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FMahalleAdi.QryName,
        FPostaKodu.QryName,
        FSemtId.QryName,
        addField(FSysSemt.TableName, FSysSemt.SemtAdi.FieldName, FSemtAdi.FieldName),
        addField(FSysIlce.TableName, FSysIlce.Id.FieldName, FIlceId.FieldName),
        addField(FSysIlce.TableName, FSysIlce.IlceAdi.FieldName, FIlceAdi.FieldName),
        addField(FSysSehir.TableName, FSysSehir.Id.FieldName, FSehirId.FieldName),
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehirAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysSemt.TableName, FSysSemt.Id.FieldName, TableName, FSemtId.FieldName),
        addJoin(jtLeft, FSysIlce.TableName, FSysIlce.Id.FieldName, FSysSemt.TableName, FSysSemt.IlceId.FieldName),
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, FSysIlce.TableName, FSysIlce.SehirId.FieldName),
        ' WHERE 1=1 ' + AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysMahalle.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
      AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT; ';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Self.Id.QryName,
        FMahalleAdi.QryName,
        FPostaKodu.QryName,
        FSemtId.QryName,
        addField(FSysSemt.TableName, FSysSemt.SemtAdi.FieldName, FSemtAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysSemt.TableName, FSysSemt.Id.FieldName, TableName, FSemtId.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSysMahalle.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FMahalleAdi.FieldName,
        FPostaKodu.FieldName,
        FSemtId.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysMahalle.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FMahalleAdi.FieldName,
        FPostaKodu.FieldName,
        FSemtId.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysMahalle.Clone: TTable;
begin
  Result := TSysMahalle.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
