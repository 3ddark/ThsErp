unit Ths.Database.Table.SetEinvTasimaUcreti;

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
  TSetEinvTasimaUcreti = class(TTable)
  private
    FIsAktif: TFieldDB;
    FTasimaUcreti: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    Property TasimaUcreti: TFieldDB read FTasimaUcreti write FTasimaUcreti;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEinvTasimaUcreti.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_tasima_ucreti';
  TableSourceCode := MODULE_MHS_AYAR;
  inherited Create(ADatabase);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
  FTasimaUcreti := TFieldDB.Create('tasima_ucreti', ftString, '', Self, '');
end;

procedure TSetEinvTasimaUcreti.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIsAktif.QryName,
      FTasimaUcreti.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetEinvTasimaUcreti.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FIsAktif.QryName,
      FTasimaUcreti.QryName
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

procedure TSetEinvTasimaUcreti.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FIsAktif.FieldName,
      FTasimaUcreti.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetEinvTasimaUcreti.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FIsAktif.FieldName,
      FTasimaUcreti.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetEinvTasimaUcreti.Clone: TTable;
begin
  Result := TSetEinvTasimaUcreti.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



