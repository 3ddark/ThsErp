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
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
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

  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Tablo Ad�');
  FIcerik := TFieldDB.Create('icerik', ftString, '', Self, '��erik');
  FIsSiralama := TFieldDB.Create('is_siralama', ftBoolean, False, Self, 'S�ralama?');
end;

procedure TSysGridFiltreSiralama.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FTabloAdi.QryName,
      FIcerik.QryName,
      FIsSiralama.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
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
    Database.GetSQLSelectCmd(LQry, TableName, [
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
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FTabloAdi.FieldName,
      FIcerik.FieldName,
      FIsSiralama.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysGridFiltreSiralama.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FTabloAdi.FieldName,
      FIcerik.FieldName,
      FIsSiralama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysGridFiltreSiralama.Clone: TTable;
begin
  Result := TSysGridFiltreSiralama.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
