unit Ths.Database.Table.SetEinvOdemeSekli;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetEinvOdemeSekli = class(TTable)
  private
    FIsAktif: TFieldDB;
    FOdemeSekli: TFieldDB;
    FKod: TFieldDB;
    FAciklama: TFieldDB;
    FIsEFatura: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    Property OdemeSekli: TFieldDB read FOdemeSekli write FOdemeSekli;
    Property Kod: TFieldDB read FKod write FKod;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsEFatura: TFieldDB read FIsEFatura write FIsEFatura;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEinvOdemeSekli.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_odeme_sekli';
  TableSourceCode := MODULE_MHS_AYAR;
  inherited Create(ADatabase);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
  FOdemeSekli := TFieldDB.Create('odeme_sekli', ftWideString, '', Self, '');
  FKod := TFieldDB.Create('kod', ftWideString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, '');
  FIsEFatura := TFieldDB.Create('is_efatura', ftBoolean, False, Self, '');
end;

procedure TSetEinvOdemeSekli.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIsAktif.QryName,
      FOdemeSekli.QryName,
      FKod.QryName,
      FAciklama.QryName,
      FIsEfatura.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetEinvOdemeSekli.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FIsAktif.QryName,
      FOdemeSekli.QryName,
      FKod.QryName,
      FAciklama.QryName,
      FIsEfatura.QryName
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

procedure TSetEinvOdemeSekli.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FIsAktif.FieldName,
      FOdemeSekli.FieldName,
      FKod.FieldName,
      FAciklama.FieldName,
      FIsEFatura.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetEinvOdemeSekli.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FIsAktif.FieldName,
      FOdemeSekli.FieldName,
      FKod.FieldName,
      FAciklama.FieldName,
      FIsEFatura.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetEinvOdemeSekli.Clone: TTable;
begin
  Result := TSetEinvOdemeSekli.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



