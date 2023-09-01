unit Ths.Database.Table.SetEinvPaketTipi;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetEinvPaketTipi = class(TTable)
  private
    FIsAktif: TFieldDB;
    FKod: TFieldDB;
    FPaketTipi: TFieldDB;
    FAciklama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    Property Kod: TFieldDB read FKod write FKod;
    Property PaketTipi: TFieldDB read FPaketTipi write FPaketTipi;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEinvPaketTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_paket_tipi';
  TableSourceCode := MODULE_MHS_AYAR;
  inherited Create(ADatabase);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
  FKod := TFieldDB.Create('kod', ftString, '', Self, '');
  FPaketTipi := TFieldDB.Create('paket_tipi', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
end;

procedure TSetEinvPaketTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIsAktif.QryName,
      FKod.QryName,
      FPaketTipi.QryName,
      FAciklama.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetEinvPaketTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FKod.QryName,
        FPaketTipi.QryName,
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

procedure TSetEinvPaketTipi.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FIsAktif.FieldName,
      FKod.FieldName,
      FPaketTipi.FieldName,
      FAciklama.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetEinvPaketTipi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FIsAktif.FieldName,
      FKod.FieldName,
      FPaketTipi.FieldName,
      FAciklama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetEinvPaketTipi.Clone: TTable;
begin
  Result := TSetEinvPaketTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



