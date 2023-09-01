unit Ths.Database.Table.SetOdemeBaslangicDonemi;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetOdemeBaslangicDonemi = class(TTable)
  private
    FOdemeBaslangicDonemi: TFieldDB;
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

    Property OdemeBaslangicDonemi: TFieldDB read FOdemeBaslangicDonemi write FOdemeBaslangicDonemi;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetOdemeBaslangicDonemi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_odeme_baslangic_donemi';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FOdemeBaslangicDonemi := TFieldDB.Create('odeme_baslangic_donemi', ftWideString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, '');
  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
end;

procedure TSetOdemeBaslangicDonemi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FOdemeBaslangicDonemi.QryName,
      FAciklama.QryName,
      FIsAktif.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetOdemeBaslangicDonemi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FOdemeBaslangicDonemi.QryName,
      FAciklama.QryName,
      FIsAktif.QryName
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

procedure TSetOdemeBaslangicDonemi.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FOdemeBaslangicDonemi.FieldName,
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

procedure TSetOdemeBaslangicDonemi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FOdemeBaslangicDonemi.FieldName,
      FAciklama.FieldName,
      FIsAktif.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetOdemeBaslangicDonemi.Clone: TTable;
begin
  Result := TSetOdemeBaslangicDonemi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



