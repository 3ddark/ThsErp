unit Ths.Erp.Database.Table.SysSemt;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysIlce,
  Ths.Erp.Database.Table.SysSehir;

type
  TSysSemt = class(TTable)
  private
    FSemtAdi: TFieldDB;
    FIlceId: TFieldDB;
    FIlceAdi: TFieldDB;
    FSehirId: TFieldDB;
    FSehirAdi: TFieldDB;

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

constructor TSysSemt.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_semt';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysIlce := TSysIlce.Create(ADatabase);
  FSysSehir := TSysSehir.Create(ADatabase);

  FSemtAdi := TFieldDB.Create('semt_adi', ftWideString, '', Self, 'Semt Adý');
  FIlceId := TFieldDB.Create('ilce_id', ftInteger, 0, Self, 'Ýlçe Id');
  FIlceAdi := TFieldDB.Create(FSysIlce.IlceAdi.FieldName, FSysIlce.IlceAdi.DataType, '', Self, 'Ýlçe Adý');
  FSehirId := TFieldDB.Create(FSysIlce.SehirId.FieldName, FSysIlce.SehirId.DataType, '', Self, 'Þehir Id');
  FSehirAdi := TFieldDB.Create(FSysSehir.SehirAdi.FieldName, FSysSehir.SehirAdi.DataType, '', Self, 'Þehir Adý');
end;

destructor TSysSemt.Destroy;
begin
  FreeAndNil(FSysIlce);
  FreeAndNil(FSysSehir);
  inherited;
end;

procedure TSysSemt.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FSemtAdi.QryName,
        FIlceId.QryName,
        addField(FSysIlce.TableName, FSysIlce.IlceAdi.FieldName, FIlceAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysIlce.TableName, FSysIlce.Id.FieldName, TableName, FIlceId.FieldName),
        ' WHERE 1=1 ' + AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysSemt.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
        FSemtAdi.QryName,
        addField(FSysIlce.TableName, FSysIlce.IlceAdi.FieldName, FIlceAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysIlce.TableName, FSysIlce.Id.FieldName, TableName, FIlceId.FieldName),
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

procedure TSysSemt.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FSemtAdi.FieldName,
        FIlceId.FieldName
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

procedure TSysSemt.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FSemtAdi.FieldName,
        FIlceId.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysSemt.Clone: TTable;
begin
  Result := TSysSemt.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
