unit Ths.Database.Table.SysParaBirimleri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSysParaBirimi = class(TTable)
  private
    FPara: TFieldDB;
    FSembol: TFieldDB;
    FAciklama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Para: TFieldDB read FPara write FPara;
    property Sembol: TFieldDB read FSembol write FSembol;
    property Aciklama: TFieldDB read FAciklama write FAciklama;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysParaBirimi.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_para_birimleri';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FPara := TFieldDB.Create('para', ftString, '', Self, 'Para');
  FSembol := TFieldDB.Create('sembol', ftString, '', Self, 'Sembol');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
end;

procedure TSysParaBirimi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FPara.QryName,
      FSembol.QryName,
      FAciklama.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysParaBirimi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.QryName,
      FPara.QryName,
      FSembol.QryName,
      FAciklama.QryName
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

procedure TSysParaBirimi.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FPara.FieldName,
      FSembol.FieldName,
      FAciklama.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysParaBirimi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FPara.FieldName,
      FSembol.FieldName,
      FAciklama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysParaBirimi.Clone: TTable;
begin
  Result := TSysParaBirimi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
