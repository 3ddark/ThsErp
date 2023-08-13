unit Ths.Database.Table.SysUlkeler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Constants;

type
  TSysUlke = class(TTable)
  private
    FUlkeKodu: TFieldDB;
    FUlkeAdi: TFieldDB;
    FISOYear: TFieldDB;
    FISOCCTLD: TFieldDB;
    FIsEuMember: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property UlkeKodu: TFieldDB read FUlkeKodu write FUlkeKodu;
    Property UlkeAdi: TFieldDB read FUlkeAdi write FUlkeAdi;
    Property ISOYear: TFieldDB read FISOYear write FISOYear;
    Property ISOCCTLD: TFieldDB read FISOCCTLD write FISOCCTLD;
    Property IsEUMember: TFieldDB read FIsEuMember write FIsEuMember;
  end;

implementation

uses
  Ths.Globals;

constructor TSysUlke.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ulkeler';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FUlkeKodu := TFieldDB.Create('ulke_kodu', ftString, '', Self, 'Ülke Kodu');
  FUlkeAdi := TFieldDB.Create('ulke_adi', ftString, '', Self, 'Ülke Adi');
  FISOYear := TFieldDB.Create('iso_year', ftInteger, 0, Self, 'ISO Year');
  FISOCCTLD := TFieldDB.Create('iso_cctld', ftString, '', Self, 'ISO CCTLD');
  FIsEuMember := TFieldDB.Create('is_eu_member', ftBoolean, False, Self, 'EU Member?');
end;

procedure TSysUlke.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FUlkeKodu.QryName,
      FUlkeAdi.QryName,
      FISOYear.QryName,
      FISOCCTLD.QryName,
      FIsEuMember.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysUlke.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FUlkeKodu.QryName,
      FUlkeAdi.QryName,
      FISOYear.QryName,
      FISOCCTLD.QryName,
      FIsEuMember.QryName
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

procedure TSysUlke.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FUlkeKodu.FieldName,
      FUlkeAdi.FieldName,
      FISOYear.FieldName,
      FISOCCTLD.FieldName,
      FIsEuMember.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysUlke.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FUlkeKodu.FieldName,
      FUlkeAdi.FieldName,
      FISOYear.FieldName,
      FISOCCTLD.FieldName,
      FIsEuMember.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSysUlke.Clone: TTable;
begin
  Result := TSysUlke.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
