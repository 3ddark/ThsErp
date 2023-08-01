unit Ths.Database.Table.SetEinvIstisnaKodu;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetEInvFaturaTipi;

type
  TSetEinvIstisnaKodu = class(TTable)
  private
    FIstisnaKodu: TFieldDB;
    FAciklama: TFieldDB;
    FIsTamIstisna: TFieldDB;
    FFaturaTipiID: TFieldDB;
    FFaturaTipi: TFieldDB;
  published
    FSetEInvFaturaTipi: TSetEinvFaturaTipi;

    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IstisnaKodu: TFieldDB read FIstisnaKodu write FIstisnaKodu;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsTamIstisna: TFieldDB read FIsTamIstisna write FIsTamIstisna;
    Property FaturaTipiID: TFieldDB read FFaturaTipiID write FFaturaTipiID;
    Property FaturaTipi: TFieldDB read FFaturaTipi write FFaturaTipi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEinvIstisnaKodu.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_istisna_kodu';
  TableSourceCode := MODULE_MHS_AYAR;
  inherited Create(ADatabase);

  FSetEInvFaturaTipi := TSetEinvFaturaTipi.Create(Database);

  FIstisnaKodu := TFieldDB.Create('istisna_kodu', ftWideString, '', Self, 'Ýstisna Kodu');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, 'Açýklama');
  FIsTamIstisna := TFieldDB.Create('is_tam_istisna', ftBoolean, False, Self, 'Tam Ýstisna');
  FFaturaTipiID := TFieldDB.Create('fatura_tipi_id', ftInteger, 0, Self, 'Fatura Tipi ID');
  FFaturaTipi := TFieldDB.Create(FSetEInvFaturaTipi.FaturaTipi.FieldName, FSetEInvFaturaTipi.FaturaTipi.DataType, '', Self, 'Fatura Tipi');
end;

destructor TSetEinvIstisnaKodu.Destroy;
begin
  FreeAndNil(FSetEInvFaturaTipi);
  inherited;
end;

procedure TSetEinvIstisnaKodu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIstisnaKodu.QryName,
      FAciklama.QryName,
      FIsTamIstisna.QryName,
      FFaturaTipiID.QryName,
      addField(FSetEInvFaturaTipi.TableName, FSetEInvFaturaTipi.FaturaTipi.FieldName, FFaturaTipi.FieldName)
    ], [
      addJoin(jtLeft, FSetEInvFaturaTipi.TableName, FSetEInvFaturaTipi.Id.FieldName, TableName, FFaturaTipiID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSetEinvIstisnaKodu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIstisnaKodu.QryName,
      FAciklama.QryName,
      FIsTamIstisna.QryName,
      FFaturaTipiID.QryName,
      addField(FSetEInvFaturaTipi.TableName, FSetEInvFaturaTipi.FaturaTipi.FieldName, FFaturaTipi.FieldName)
    ], [
      addJoin(jtLeft, FSetEInvFaturaTipi.TableName, FSetEInvFaturaTipi.Id.FieldName, TableName, FFaturaTipiID.FieldName),
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

procedure TSetEinvIstisnaKodu.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FIstisnaKodu.FieldName,
      FAciklama.FieldName,
      FIsTamIstisna.FieldName,
      FFaturaTipiID.FieldName
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

procedure TSetEinvIstisnaKodu.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FIstisnaKodu.FieldName,
      FAciklama.FieldName,
      FIsTamIstisna.FieldName,
      FFaturaTipiID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetEinvIstisnaKodu.Clone: TTable;
begin
  Result := TSetEinvIstisnaKodu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



