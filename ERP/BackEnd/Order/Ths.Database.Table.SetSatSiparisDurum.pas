unit Ths.Database.Table.SetSatSiparisDurum;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSatSiparisDurum = (Beklemede=1, Hazir, Gitti);
  TSetSatSiparisDurum = class(TTable)
  private
    FSiparisDurum: TFieldDB;
    FAciklama: TFieldDB;
    FIsAktif: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property SiparisDurum: TFieldDB read FSiparisDurum write FSiparisDurum;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetSatSiparisDurum.Create(ADatabase: TDatabase);
begin
  TableName := 'set_sat_siparis_durum';
  TableSourceCode := MODULE_TSIF_AYAR;
  inherited Create(ADatabase);

  FSiparisDurum := TFieldDB.Create('siparis_durum', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
end;

procedure TSetSatSiparisDurum.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FSiparisDurum.QryName,
      FAciklama.QryName,
      FIsAktif.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetSatSiparisDurum.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FSiparisDurum.QryName,
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

procedure TSetSatSiparisDurum.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FSiparisDurum.FieldName,
      FAciklama.FieldName,
      FIsAktif.FieldName
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

procedure TSetSatSiparisDurum.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FSiparisDurum.FieldName,
      FAciklama.FieldName,
      FIsAktif.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetSatSiparisDurum.Clone: TTable;
begin
  Result := TSetSatSiparisDurum.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
