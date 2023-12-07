unit Ths.Database.Table.StkStokHareketi;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.StkAmbarlar;

type
  TStkStokHareketi = class(TTable)
  private
    FStokKodu: TFieldDB;
    FMiktar: TFieldDB;
    FTutar: TFieldDB;
    FTutarDoviz: TFieldDB;
    FParaBirimi: TFieldDB;
    FIsGiris: TFieldDB;
    FTarih: TFieldDB;
    FAmbarID: TFieldDB;
    FAmbar: TFieldDB;
    FIsDonemBasi: TFieldDB;
  protected
    FStkStokAmbar: TStkAmbar;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property Tutar: TFieldDB read FTutar write FTutar;
    Property TutarDoviz: TFieldDB read FTutarDoviz write FTutarDoviz;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property IsGiris: TFieldDB read FIsGiris write FIsGiris;
    Property Tarih: TFieldDB read FTarih write FTarih;
    Property AmbarID: TFieldDB read FAmbarID write FAmbarID;
    Property Ambar: TFieldDB read FAmbar write FAmbar;
    Property IsDonemBasi: TFieldDB read FIsDonemBasi write FIsDonemBasi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkStokHareketi.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_hareketler';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkStokAmbar := TStkAmbar.Create(ADatabase);

  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, 'Stok Kodu');
  FMiktar := TFieldDB.Create('miktar', ftBCD, 0, Self, 'Miktar');
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, 'Tutar');
  FTutarDoviz := TFieldDB.Create('tutar_doviz', ftBCD, 0, Self, 'Döviz Tutar');
  FParaBirimi := TFieldDB.Create('para_birimi', ftWideString, '', Self, 'Para Birimi');
  FIsGiris := TFieldDB.Create('is_giris', ftBoolean, True, Self, 'Giriþ?');
  FTarih := TFieldDB.Create('tarih', ftDate, 0, Self, 'Tarih');
  FAmbarID := TFieldDB.Create('ambar_id', ftInteger, 0, Self, 'Ambar ID');
  FAmbar := TFieldDB.Create(FStkStokAmbar.AmbarAdi.FieldName, FStkStokAmbar.AmbarAdi.DataType, '', Self, 'Ambar');
  FIsDonemBasi := TFieldDB.Create('is_donem_basi', ftBoolean, False, Self, 'Dönem Baþý?');
end;

destructor TStkStokHareketi.Destroy;
begin
  FStkStokAmbar.Free;
  inherited;
end;

procedure TStkStokHareketi.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FTutar.QryName,
      FTutarDoviz.QryName,
      FParaBirimi.QryName,
      FIsGiris.QryName,
      FTarih.QryName,
      FAmbarID.QryName,
      addField(FStkStokAmbar.TableName, FStkStokAmbar.AmbarAdi.FieldName, FAmbarID.FieldName),
      FIsDonemBasi.QryName
    ], [
      addJoin(jtLeft, FStkStokAmbar.TableName, FStkStokAmbar.Id.FieldName, TableName, FAmbarID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TStkStokHareketi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FStokKodu.QryName,
      FMiktar.QryName,
      FTutar.QryName,
      FTutarDoviz.QryName,
      FParaBirimi.QryName,
      FIsGiris.QryName,
      FTarih.QryName,
      FAmbarID.QryName,
      addField(FStkStokAmbar.TableName, FStkStokAmbar.AmbarAdi.FieldName, FAmbarID.FieldName),
      FIsDonemBasi.QryName
    ], [
      addJoin(jtLeft, FStkStokAmbar.TableName, FStkStokAmbar.Id.FieldName, TableName, FAmbarID.FieldName),
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

procedure TStkStokHareketi.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FTutar.FieldName,
      FTutarDoviz.FieldName,
      FParaBirimi.FieldName,
      FIsGiris.FieldName,
      FTarih.FieldName,
      FAmbarID.FieldName,
      FIsDonemBasi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TStkStokHareketi.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FTutar.FieldName,
      FTutarDoviz.FieldName,
      FParaBirimi.FieldName,
      FIsGiris.FieldName,
      FTarih.FieldName,
      FAmbarID.FieldName,
      FIsDonemBasi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TStkStokHareketi.Clone():TTable;
begin
  Result := TStkStokHareketi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
