unit Ths.Database.Table.SysGridFiltrelerSiralamalar;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, Ths.Database,
  Ths.Database.Table;

type
  TSysGridFiltreSiralama = class(TTable)
  private
    FTabloAdi: TFieldDB;
    FIcerik: TFieldDB;
    FIsSiralama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property Icerik: TFieldDB read FIcerik write FIcerik;
    Property IsSiralama: TFieldDB read FIsSiralama write FIsSiralama;
  end;

implementation

uses Ths.Globals, Ths.Constants;

constructor TSysGridFiltreSiralama.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_filtreler_siralamalar';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self);
  FIcerik := TFieldDB.Create('icerik', ftString, '', Self);
  FIsSiralama := TFieldDB.Create('is_siralama', ftBoolean, False, Self);
end;

function TSysGridFiltreSiralama.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FTabloAdi.QryName,
      FIcerik.QryName,
      FIsSiralama.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysGridFiltreSiralama.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FTabloAdi.QryName,
      FIcerik.QryName,
      FIsSiralama.QryName
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
    Close;
  finally
    Free;
  end;
end;

procedure TSysGridFiltreSiralama.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FTabloAdi.FieldName,
      FIcerik.FieldName,
      FIsSiralama.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysGridFiltreSiralama.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FTabloAdi.FieldName,
      FIcerik.FieldName,
      FIsSiralama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSysGridFiltreSiralama.Clone: TTable;
begin
  Result := TSysGridFiltreSiralama.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
