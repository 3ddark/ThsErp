unit Ths.Database.Table.SysOndalikHaneler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSysOndalikHane = class(TTable)
  private
    FMiktar: TFieldDB;
    FFiyat: TFieldDB;
    FTutar: TFieldDB;
    FStokMiktar: TFieldDB;
    FDovizKuru: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Miktar: TFieldDB read FMiktar write FMiktar;
    property Fiyat: TFieldDB read FFiyat write FFiyat;
    property Tutar: TFieldDB read FTutar write FTutar;
    property StokMiktar: TFieldDB read FStokMiktar write FStokMiktar;
    property DovizKuru: TFieldDB read FDovizKuru write FDovizKuru;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysOndalikHane.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ondalik_haneler';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FMiktar := TFieldDB.Create('miktar', ftInteger, 2, Self, 'Miktar');
  FFiyat := TFieldDB.Create('fiyat', ftInteger, 2, Self, 'Fiyat');
  FTutar := TFieldDB.Create('tutar', ftInteger, 2, Self, 'Tutar');
  FStokMiktar := TFieldDB.Create('stok_miktar', ftInteger, 2, Self, 'Stok Miktar');
  FDovizKuru := TFieldDB.Create('doviz_kuru', ftInteger, 4, Self, 'Döviz Kuru');
end;

procedure TSysOndalikHane.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FMiktar.QryName,
      FFiyat.QryName,
      FTutar.QryName,
      FStokMiktar.QryName,
      FDovizKuru.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysOndalikHane.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FMiktar.QryName,
      FFiyat.QryName,
      FTutar.QryName,
      FStokMiktar.QryName,
      FDovizKuru.QryName
    ], [
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
  finally
    Free;
  end;
end;

procedure TSysOndalikHane.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FMiktar.FieldName,
      FFiyat.FieldName,
      FTutar.FieldName,
      FStokMiktar.FieldName,
      FDovizKuru.FieldName
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

procedure TSysOndalikHane.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Self.Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FMiktar.FieldName,
      FFiyat.FieldName,
      FTutar.FieldName,
      FStokMiktar.FieldName,
      FDovizKuru.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysOndalikHane.Clone: TTable;
begin
  Result := TSysOndalikHane.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
