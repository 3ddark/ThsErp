unit Ths.Database.Table.SetTekTeklifTipi;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetTekTeklifTipi = class(TTable)
  private
    FTeklifTipi: TFieldDB;
    FAciklama: TFieldDB;
    FIsAktif: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TeklifTipi: TFieldDB read FTeklifTipi write FTeklifTipi;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetTekTeklifTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_tek_teklif_tipi';
  TableSourceCode := MODULE_TSIF_AYAR;
  inherited Create(ADatabase);

  FTeklifTipi := TFieldDB.Create('teklif_tipi', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, False, Self, '');
end;

procedure TSetTekTeklifTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FTeklifTipi.QryName,
      FAciklama.QryName,
      FIsAktif.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetTekTeklifTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FTeklifTipi.QryName,
      FAciklama.QryName,
      FIsAktif.QryName
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

procedure TSetTekTeklifTipi.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    Close;
    SQL.Clear;
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FTeklifTipi.FieldName,
      FAciklama.FieldName,
      FIsAktif.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetTekTeklifTipi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FTeklifTipi.FieldName,
      FAciklama.FieldName,
      FIsAktif.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetTekTeklifTipi.Clone: TTable;
begin
  Result := TSetTekTeklifTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.


