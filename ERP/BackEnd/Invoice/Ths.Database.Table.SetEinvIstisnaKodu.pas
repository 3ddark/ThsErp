unit Ths.Database.Table.SetEinvIstisnaKodu;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetEInvFaturaTipleri;

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
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
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

  FIstisnaKodu := TFieldDB.Create('istisna_kodu', ftWideString, '', Self, 'İstisna Kodu');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, 'Açıklama');
  FIsTamIstisna := TFieldDB.Create('is_tam_istisna', ftBoolean, False, Self, 'Tam İstisna');
  FFaturaTipiID := TFieldDB.Create('fatura_tipi_id', ftInteger, 0, Self, 'Fatura Tipi ID');
  FFaturaTipi := TFieldDB.Create(FSetEInvFaturaTipi.FaturaTipi.FieldName, FSetEInvFaturaTipi.FaturaTipi.DataType, '', Self, 'Fatura Tipi');
end;

destructor TSetEinvIstisnaKodu.Destroy;
begin
  FreeAndNil(FSetEInvFaturaTipi);
  inherited;
end;

function TSetEinvIstisnaKodu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
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
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSetEinvIstisnaKodu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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

procedure TSetEinvIstisnaKodu.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FIstisnaKodu.FieldName,
      FAciklama.FieldName,
      FIsTamIstisna.FieldName,
      FFaturaTipiID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetEinvIstisnaKodu.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FIstisnaKodu.FieldName,
      FAciklama.FieldName,
      FIsTamIstisna.FieldName,
      FFaturaTipiID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetEinvIstisnaKodu.Clone: TTable;
begin
  Result := TSetEinvIstisnaKodu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



