unit Ths.Database.Table.SysAylar;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table;

type
  TSysAy = class(TTable)
  private
    FAyAdi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property AyAdi: TFieldDB read FAyAdi write FAyAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysAy.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_aylar';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FAyAdi := TFieldDB.Create('ay_adi', ftWideString, '', Self, 'Ay Adý');
end;

procedure TSysAy.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FAyAdi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysAy.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FAyAdi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TSysAy.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FAyAdi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysAy.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FAyAdi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysAy.Clone: TTable;
begin
  Result := TSysAy.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
