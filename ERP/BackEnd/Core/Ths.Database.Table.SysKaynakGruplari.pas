unit Ths.Database.Table.SysKaynakGruplari;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSysKaynakGrubu = class(TTable)
  private
    FGrup: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Grup: TFieldDB read FGrup write FGrup;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysKaynakGrubu.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_kaynak_gruplari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FGrup := TFieldDB.Create('grup', ftString, '', Self, 'Grup');
end;

procedure TSysKaynakGrubu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      addLangField(FGrup.FieldName, '', True)
    ], [
      addLeftJoin(FGrup.FieldName, FGrup.FieldName, TableName, True),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysKaynakGrubu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.FieldName,
      addLangField(FGrup.FieldName, '', True)
    ], [
      addLeftJoin(FGrup.FieldName, FGrup.FieldName, TableName, True),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
end;

procedure TSysKaynakGrubu.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FGrup.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;

    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Id.FieldName).AsInteger
    else  AID := 0;
  finally
    Free;
  end;
end;

procedure TSysKaynakGrubu.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FGrup.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysKaynakGrubu.Clone():TTable;
begin
  Result := TSysKaynakGrubu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
