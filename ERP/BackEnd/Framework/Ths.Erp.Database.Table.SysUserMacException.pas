unit Ths.Erp.Database.Table.SysUserMacException;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKullanici;

type
  TSysUserMacException = class(TTable)
  private
    FUserNameID: TFieldDB;
    FUserName: TFieldDB;
    FIpAddress: TFieldDB;

    FSysUser: TSysKullanici;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    destructor Destroy; override;

    Property UserNameID: TFieldDB read FUserNameID write FUserNameID;
    Property UserName: TFieldDB read FUserName write FUserName;
    Property IpAddress: TFieldDB read FIpAddress write FIpAddress;
  end;

implementation

constructor TSysUserMacException.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_user_mac_exception';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FUserNameID := TFieldDB.Create('user_name_id', ftInteger, 0, Self);
  FUserName := TFieldDB.Create('user_name', ftString, '', Self);
  FIpAddress := TFieldDB.Create('ip_address', ftString, '', Self);

  FSysUser := TSysKullanici.Create(Database);
end;

destructor TSysUserMacException.Destroy;
begin
  FSysUser.Free;
  inherited;
end;

procedure TSysUserMacException.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FUserNameID.FieldName,
        addLangField(FUserName.FieldName),
        TableName + '.' + FIpAddress.FieldName
      ], [
        addLeftJoin(FUserName.FieldName, TableName + '.' + FUserNameID.FieldName, FSysUser.TableName) +
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FUserNameID, 'Kullanýcý Adý Id', QueryOfDS);
      setFieldTitle(FUserName, 'Kullanýcý Adý', QueryOfDS);
      setFieldTitle(FIpAddress, 'IP Adresi', QueryOfDS);
    end;
  end;
end;

procedure TSysUserMacException.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FUserNameID.FieldName,
        addLangField(FUserName.FieldName),
        TableName + '.' + FIpAddress.FieldName
      ], [
        addLeftJoin(FUserName.FieldName, TableName + '.' + FUserNameID.FieldName, FSysUser.TableName),
        'WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FUserNameID, QueryOfList);
        setFieldValue(FUserName, QueryOfList);
        setFieldValue(FIpAddress, QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSysUserMacException.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FUserNameID.FieldName,
        FIpAddress.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysUserMacException.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FUserNameID.FieldName,
        FIpAddress.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysUserMacException.Clone: TTable;
begin
  Result := TSysUserMacException.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
