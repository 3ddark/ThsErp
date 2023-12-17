unit Ths.Database.Table.SetEinvTeslimSekli;

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
  TSetEinvTeslimSekli = class(TTable)
  private
    FIsAktif: TFieldDB;
    FTeslimSekli: TFieldDB;
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
    Property TeslimSekli: TFieldDB read FTeslimSekli write FTeslimSekli;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsEFatura: TFieldDB read FIsEFatura write FIsEFatura;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEinvTeslimSekli.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_teslim_sekli';
  TableSourceCode := MODULE_MHS_AYAR;
  inherited Create(ADatabase);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, '');
  FTeslimSekli := TFieldDB.Create('teslim_sekli', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsEFatura := TFieldDB.Create('is_efatura', ftBoolean, False, Self, '');
end;

procedure TSetEinvTeslimSekli.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIsAktif.QryName,
      FTeslimSekli.QryName,
      FAciklama.QryName,
      FIsEfatura.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetEinvTeslimSekli.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FIsAktif.QryName,
      FTeslimSekli.QryName,
      FAciklama.QryName,
      FIsEfatura.QryName
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

procedure TSetEinvTeslimSekli.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FIsAktif.FieldName,
      FTeslimSekli.FieldName,
      FAciklama.FieldName,
      FIsEFatura.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetEinvTeslimSekli.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FIsAktif.FieldName,
      FTeslimSekli.FieldName,
      FAciklama.FieldName,
      FIsEFatura.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetEinvTeslimSekli.Clone: TTable;
begin
  Result := TSetEinvTeslimSekli.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



