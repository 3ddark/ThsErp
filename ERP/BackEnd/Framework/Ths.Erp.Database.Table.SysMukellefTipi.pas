unit Ths.Erp.Database.Table.SysMukellefTipi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Constants,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysMukellefTipi = class(TTable)
  private
    FMukellefTipi: TFieldDB;
    FIsVarsayilan: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property MukellefTipi: TFieldDB read FMukellefTipi write FMukellefTipi;
    Property IsVarsayilan: TFieldDB read FIsVarsayilan write FIsVarsayilan;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton;

constructor TSysMukellefTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_mukellef_tipi';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FMukellefTipi := TFieldDB.Create('mukellef_tipi', ftString, '', Self, 'Mükellef Tipi');
  FIsVarsayilan := TFieldDB.Create('is_varsayilan', ftBoolean, False, Self, 'Varsayýlan?');
end;

procedure TSysMukellefTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FMukellefTipi.FieldName,
        TableName + '.' + FIsVarsayilan.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FMukellefTipi, 'Mükellef Tipi', QueryOfDS);
      setFieldTitle(FIsVarsayilan, 'Varsayýlan?', QueryOfDS);
    end;
  end;
end;

procedure TSysMukellefTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FMukellefTipi.FieldName,
        TableName + '.' + FIsVarsayilan.FieldName
      ], [
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

procedure TSysMukellefTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FMukellefTipi.FieldName,
        FIsVarsayilan.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysMukellefTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FMukellefTipi.FieldName, FIsVarsayilan.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysMukellefTipi.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LMukellef: TSysMukellefTipi;
  n1: Integer;
begin
  if Self.IsVarsayilan.Value then
  begin
    LMukellef := TSysMukellefTipi.Create(Database);
    try
      LMukellef.SelectToList('', False, False);
      for n1 := 0 to LMukellef.List.Count-1 do
      begin
        TSysMukellefTipi(LMukellef.List[n1]).IsVarsayilan.Value := False;
        TSysMukellefTipi(LMukellef.List[n1]).Update(False);
      end;
    finally
      FreeAndNil(LMukellef);
    end;
  end;
  Self.Insert(AID, APermissionControl);
end;

procedure TSysMukellefTipi.BusinessUpdate(APermissionControl: Boolean);
var
  LMukellef: TSysMukellefTipi;
  n1: Integer;
begin
  if Self.IsVarsayilan.Value then
  begin
    LMukellef := TSysMukellefTipi.Create(Database);
    try
      LMukellef.SelectToList('', False, False);
      for n1 := 0 to LMukellef.List.Count-1 do
      begin
        TSysMukellefTipi(LMukellef.List[n1]).IsVarsayilan.Value := False;
        TSysMukellefTipi(LMukellef.List[n1]).Update(False);
      end;
    finally
      FreeAndNil(LMukellef);
    end;
  end;
  Self.Update(APermissionControl);
end;

function TSysMukellefTipi.Clone: TTable;
begin
  Result := TSysMukellefTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
