unit Ths.Database.Table.UrtReceteler;

interface

{$I Ths.inc}

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  System.Generics.Collections,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.TableDetailed,
  Ths.Database.Table.StkKartlar,
  Ths.Database.Table.SysOlcuBirimleri,
  Ths.Database.Table.UrtIscilikler;

type
  TUrtRecete = class;

  TReceteTotals = record
    MaliyetHam: Double;
    MaliyetIsc: Double;
    MaliyetYan: Double;
    HammaddeCount: SmallInt;
    IscilikCount: SmallInt;
    YanUrunCount: SmallInt;
  end;

  TUrtReceteHammadde = class(TTable)
  private
    FHeaderID: TFieldDB;
    FReceteID: TFieldDB;
    FStokKodu: TFieldDB;
    FMiktar: TFieldDB;
    FFireOrani: TFieldDB;
    //not a database field
    FReceteKodu: TFieldDB;
    FStokAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FStkStokKarti: TStkKart;
    FSysOlcuBirimi: TSysOlcuBirimi;
    FUrtRecete: TUrtRecete;

    constructor Create(ADatabase: TDatabase; ARecete: TUrtRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TUrtRecete;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property ReceteID: TFieldDB read FReceteID write FReceteID;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property FireOrani: TFieldDB read FFireOrani write FFireOrani;
    //not a database field
    Property ReceteKodu: TFieldDB read FReceteKodu write FReceteKodu;
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TUrtReceteIscilik = class(TTable)
  private
    FHeaderID: TFieldDB;
    FIscilikKodu: TFieldDB;
    FMiktar: TFieldDB;
    //not a database field
    FGiderAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FUrtIscilik: TUrtIscilik;
    FSysOlcuBirimi: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ARecete: TUrtRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TUrtRecete;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property IscilikKodu: TFieldDB read FIscilikKodu write FIscilikKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    //not a database field
    Property GiderAdi: TFieldDB read FGiderAdi write FGiderAdi;
    Property Birim: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TUrtReceteYanUrun = class(TTable)
  private
    FHeaderID: TFieldDB;
    FUrunKodu: TFieldDB;
    FMiktar: TFieldDB;
    //not a database field
    FStokAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FStkStokKarti: TStkKart;
    FSysOlcuBirimi: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ARecete: TUrtRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TUrtRecete;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property UrunKodu: TFieldDB read FUrunKodu write FUrunKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    //not a database field
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TUrtRecete = class(TTableDetailed)
  private
    FUrunKodu: TFieldDB;
    FUrunAdi: TFieldDB;
    FOrnekMiktari: TFieldDB;
    FAciklama: TFieldDB;
    FMaliyet: TFieldDB;
    FHammaddeMaliyet: TFieldDB;
    FIscilikMaliyet: TFieldDB;
    FYanUrunMaliyet: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
    function ValidateDetay(ATable: TTable): Boolean; override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    ReceteMaliyet: TReceteTotals;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property UrunKodu: TFieldDB read FUrunKodu write FUrunKodu;
    Property UrunAdi: TFieldDB read FUrunAdi write FUrunAdi;
    Property OrnekMiktari: TFieldDB read FOrnekMiktari write FOrnekMiktari;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    property Maliyet: TFieldDB read FMaliyet write FMaliyet;
    property HammaddeMaliyet: TFieldDB read FHammaddeMaliyet write FHammaddeMaliyet;
    property IscilikMaliyet: TFieldDB read FIscilikMaliyet write FIscilikMaliyet;
    property YanUrunMaliyet: TFieldDB read FYanUrunMaliyet write FYanUrunMaliyet;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TUrtReceteHammadde.Create(ADatabase: TDatabase; ARecete: TUrtRecete);
begin
  TableName := 'urt_recete_hammaddeler';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FStkStokKarti := TStkKart.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);
  FUrtRecete := TUrtRecete.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FReceteID := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FReceteKodu := TFieldDB.Create(FUrtRecete.FUrunKodu.FieldName, FUrtRecete.UrunKodu.DataType, '', Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.Birim.FieldName, FSysOlcuBirimi.Birim.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TUrtReceteHammadde.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FSysOlcuBirimi);
  FreeAndNil(FUrtRecete);
  inherited;
end;

function TUrtReceteHammadde.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FReceteID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtReceteHammadde.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FReceteID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName,
      addField(FUrtRecete.TableName, FUrtRecete.FUrunKodu.FieldName, FReceteKodu.FieldName),
      addField(FStkStokKarti.TableName, FStkStokKarti.StokAdi.FieldName, FStokAdi.FieldName),
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FStkStokKarti.TableName, FStkStokKarti.AlisFiyat.FieldName, FFiyat.FieldName)
    ], [
      AddJoin(jtLeft, FUrtRecete.TableName, FUrtRecete.Id.FieldName, TableName, ReceteID.FieldName),
      AddJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
      AddJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FStkStokKarti.TableName, FStkStokKarti.OlcuBirimiID.FieldName),
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtReceteHammadde.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FReceteID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtReceteHammadde.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FReceteID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtReceteHammadde.Clone: TTable;
begin
  Result := TUrtReceteHammadde.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TUrtReceteIscilik.Create(ADatabase: TDatabase; ARecete: TUrtRecete);
begin
  TableName := 'urt_recete_iscilikler';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FUrtIscilik := TUrtIscilik.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FIscilikKodu := TFieldDB.Create('iscilik_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FGiderAdi := TFieldDB.Create(FUrtIscilik.GiderKodu.FieldName, FUrtIscilik.GiderKodu.DataType, '', Self, 'Gider Kodu');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.Birim.FieldName, FSysOlcuBirimi.Birim.DataType, '', Self, 'Birim');
  FFiyat := TFieldDB.Create(FUrtIscilik.Fiyat.FieldName, FUrtIscilik.Fiyat.DataType, 0, Self, 'Fiyat');
end;

destructor TUrtReceteIscilik.Destroy;
begin
  FreeAndNil(FUrtIscilik);
  FreeAndNil(FSysOlcuBirimi);
  inherited;
end;

function TUrtReceteIscilik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FIscilikKodu.QryName,
      addField(FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, FGiderAdi.FieldName),
      FMiktar.QryName,
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FUrtIscilik.TableName, FUrtIscilik.Fiyat.FieldName, FFiyat.FieldName)
    ], [
      addJoin(jtLeft, FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, TableName, FIscilikKodu.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FUrtIscilik.TableName, FUrtIscilik.BirimID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtReceteIscilik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FIscilikKodu.QryName,
      addField(FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, FGiderAdi.FieldName),
      FMiktar.QryName,
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FUrtIscilik.TableName, FUrtIscilik.Fiyat.FieldName, FFiyat.FieldName)
    ], [
      addJoin(jtLeft, FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, TableName, FIscilikKodu.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FUrtIscilik.TableName, FUrtIscilik.BirimID.FieldName),
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

procedure TUrtReceteIscilik.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FIscilikKodu.FieldName,
      FMiktar.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtReceteIscilik.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FIscilikKodu.FieldName,
      FMiktar.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtReceteIscilik.Clone: TTable;
begin
  Result := TUrtReceteIscilik.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TUrtReceteYanUrun.Create(ADatabase: TDatabase; ARecete: TUrtRecete);
begin
  TableName := 'urt_recete_yan_urunler';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FStkStokKarti := TStkKart.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FUrunKodu := TFieldDB.Create('urun_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.Birim.FieldName, FSysOlcuBirimi.Birim.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TUrtReceteYanUrun.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FSysOlcuBirimi);
  inherited;
end;

function TUrtReceteYanUrun.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FUrunKodu.QryName,
      FMiktar.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtReceteYanUrun.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FUrunKodu.QryName,
      FMiktar.QryName,
      addField(FStkStokKarti.TableName, FStkStokKarti.StokAdi.FieldName, FStokAdi.FieldName),
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FStkStokKarti.TableName, FStkStokKarti.AlisFiyat.FieldName, FFiyat.FieldName)
    ], [
      addJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FUrunKodu.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FStkStokKarti.TableName, FStkStokKarti.OlcuBirimiID.FieldName),
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtReceteYanUrun.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FUrunKodu.FieldName,
      FMiktar.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtReceteYanUrun.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FUrunKodu.FieldName,
      FMiktar.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtReceteYanUrun.Clone: TTable;
begin
  Result := TUrtReceteYanUrun.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TUrtRecete.Create(ADatabase: TDatabase);
begin
  TableName := 'urt_receteler';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  ReceteMaliyet.HammaddeCount := 0;
  ReceteMaliyet.IscilikCount := 0;
  ReceteMaliyet.YanUrunCount := 0;

  FUrunKodu := TFieldDB.Create('urun_kodu', ftWideString, '', Self);
  FUrunAdi := TFieldDB.Create('urun_adi', ftWideString, '', Self);
  FOrnekMiktari := TFieldDB.Create('ornek_miktari', ftFloat, 0, Self);
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self);
  FMaliyet := TFieldDB.Create('maliyet', ftBCD, 0, Self);
  FHammaddeMaliyet := TFieldDB.Create('hammadde_maliyet', ftBCD, 0, Self);
  FIscilikMaliyet := TFieldDB.Create('iscilik_maliyet', ftBCD, 0, Self);
  FYanUrunMaliyet := TFieldDB.Create('yan_urun_maliyet', ftBCD, 0, Self);
end;

function TUrtRecete.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FUrunKodu.QryName,
      FUrunAdi.QryName,
      FOrnekMiktari.QryName,
      FAciklama.QryName,
      'spget_rct_toplam(cast('           + Id.QryName + ' as bigint)) ' + FMaliyet.FieldName,
      'spget_rct_hammadde_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FHammaddeMaliyet.FieldName,
      'spget_rct_iscilik_maliyet(cast('  + Id.QryName + ' as bigint)) ' + FIscilikMaliyet.FieldName,
      'spget_rct_yan_urun_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FYanUrunMaliyet.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtRecete.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Self.Id.QryName,
      FUrunKodu.QryName,
      FUrunAdi.QryName,
      FOrnekMiktari.QryName,
      FAciklama.QryName,
      'spget_rct_toplam(cast('           + Id.QryName + ' as bigint)) ' + FMaliyet.FieldName,
      'spget_rct_hammadde_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FHammaddeMaliyet.FieldName,
      'spget_rct_iscilik_maliyet(cast('  + Id.QryName + ' as bigint)) ' + FIscilikMaliyet.FieldName,
      'spget_rct_yan_urun_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FYanUrunMaliyet.FieldName
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

procedure TUrtRecete.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FUrunKodu.FieldName,
      FUrunAdi.FieldName,
      FOrnekMiktari.FieldName,
      FAciklama.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtRecete.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FUrunKodu.FieldName,
      FUrunAdi.FieldName,
      FOrnekMiktari.FieldName,
      FAciklama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TUrtRecete.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if (TObject(ListDetay[n1]).ClassType = TUrtReceteHammadde) and (ATable.ClassType = TUrtReceteHammadde) then
    begin
      TUrtReceteHammadde(ATable).Recete := Self;
      if TUrtReceteHammadde(ListDetay[n1]).FStokKodu.AsString = TUrtReceteHammadde(ATable).FStokKodu.AsString then
      begin
        TUrtReceteHammadde(ListDetay[n1]).FMiktar.Value := TUrtReceteHammadde(ListDetay[n1]).FMiktar.AsFloat + TUrtReceteHammadde(ATable).Miktar.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TUrtReceteIscilik) and (ATable.ClassType = TUrtReceteIscilik) then
    begin
      TUrtReceteIscilik(ATable).Recete := Self;
      if TUrtReceteIscilik(ListDetay[n1]).FIscilikKodu.AsString = TUrtReceteIscilik(ATable).FIscilikKodu.AsString then
      begin
        TUrtReceteIscilik(ListDetay[n1]).FMiktar.Value := TUrtReceteIscilik(ListDetay[n1]).FMiktar.AsFloat + TUrtReceteIscilik(ATable).FMiktar.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TUrtReceteYanUrun) and (ATable.ClassType = TUrtReceteYanUrun) then
    begin
      TUrtReceteYanUrun(ATable).Recete := Self;
      if TUrtReceteYanUrun(ListDetay[n1]).FUrunKodu.AsString = TUrtReceteYanUrun(ATable).FUrunKodu.AsString then
      begin
        TUrtReceteYanUrun(ListDetay[n1]).FMiktar.Value := TUrtReceteYanUrun(ListDetay[n1]).FMiktar.AsFloat + TUrtReceteYanUrun(ATable).FMiktar.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end;
  end;

  if not LExistsSameCode then
    ListDetay.Add(ATable);

  if ALastItem then RefreshHeader;
end;

procedure TUrtRecete.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TUrtRecete.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TUrtRecete.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable.Clone);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

procedure TUrtRecete.RefreshHeader;
var
  n1: Integer;
begin
  ReceteMaliyet.MaliyetHam := 0;
  ReceteMaliyet.MaliyetIsc := 0;
  ReceteMaliyet.MaliyetYan := 0;
  ReceteMaliyet.HammaddeCount := 0;
  ReceteMaliyet.IscilikCount := 0;
  ReceteMaliyet.YanUrunCount := 0;

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtReceteHammadde then
    begin
      ReceteMaliyet.HammaddeCount := ReceteMaliyet.HammaddeCount + 1;
      ReceteMaliyet.MaliyetHam := ReceteMaliyet.MaliyetHam + TUrtReceteHammadde(ListDetay[n1]).Fiyat.AsFloat * TUrtReceteHammadde(ListDetay[n1]).Miktar.AsFloat
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteIscilik then
    begin
      ReceteMaliyet.IscilikCount := ReceteMaliyet.IscilikCount + 1;
      ReceteMaliyet.MaliyetIsc := ReceteMaliyet.MaliyetIsc + TUrtReceteIscilik(ListDetay[n1]).Fiyat.AsFloat * TUrtReceteIscilik(ListDetay[n1]).Miktar.AsFloat
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteYanUrun then
    begin
      ReceteMaliyet.YanUrunCount := ReceteMaliyet.YanUrunCount + 1;
      ReceteMaliyet.MaliyetYan := ReceteMaliyet.MaliyetYan - TUrtReceteYanUrun(ListDetay[n1]).Fiyat.AsFloat * TUrtReceteYanUrun(ListDetay[n1]).Miktar.AsFloat
    end;
  end;
end;

procedure TUrtRecete.BusinessDelete(APermissionControl: Boolean);
begin
  inherited;
  //
end;

procedure TUrtRecete.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(APermissionControl);
  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtReceteHammadde then
    begin
      TUrtReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtReceteHammadde(ListDetay[n1]).Insert(True);
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteIscilik then
    begin
      TUrtReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtReceteIscilik(ListDetay[n1]).Insert(True);
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteYanUrun then
    begin
      TUrtReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtReceteYanUrun(ListDetay[n1]).Insert(True);
    end;
  end;
end;

procedure TUrtRecete.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  ARecete: TUrtRecete;
  LHam: TUrtReceteHammadde;
  LIsc: TUrtReceteIscilik;
  LYan: TUrtReceteYanUrun;
  n2: Integer;
  n1: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    ARecete := TUrtRecete(List[n1]);

    LHam := TUrtReceteHammadde.Create(Database, ARecete);
    LIsc := TUrtReceteIscilik.Create(Database, ARecete);
    LYan := TUrtReceteYanUrun.Create(Database, ARecete);
    try
      LHam.SelectToList(' AND ' + LHam.HeaderID.QryName + '=' + ARecete.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LHam.List.Count - 1 do
        ARecete.AddDetay(TUrtReceteHammadde(TUrtReceteHammadde(LHam.List[n2]).Clone));

      LIsc.SelectToList(' AND ' + LIsc.HeaderID.QryName + '=' + ARecete.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LIsc.List.Count - 1 do
        ARecete.AddDetay(TUrtReceteIscilik(TUrtReceteIscilik(LIsc.List[n2]).Clone));

      LYan.SelectToList(' AND ' + LYan.HeaderID.QryName + '=' + ARecete.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LYan.List.Count - 1 do
        ARecete.AddDetay(TUrtReceteYanUrun(TUrtReceteYanUrun(LYan.List[n2]).Clone));

      RefreshHeader;
    finally
      FreeAndNil(LHam);
      FreeAndNil(LIsc);
      FreeAndNil(LYan);
    end;
  end;
end;

procedure TUrtRecete.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Update(APermissionControl);

  for n1 := 0 to ListSilinenDetay.Count - 1 do
    if TTable(ListSilinenDetay[n1]).Id.AsInteger > 0 then
      TTable(ListSilinenDetay[n1]).Delete(False);

  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtReceteHammadde then
      TUrtReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteIscilik then
      TUrtReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteYanUrun then
      TUrtReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;

    if TTable(ListDetay[n1]).Id.Value > 0 then
      TTable(ListDetay[n1]).Update(False)
    else
    begin
      TTable(ListDetay[n1]).Insert(False);
    end;
  end;
end;

function TUrtRecete.Clone: TTable;
begin
  Result := TUrtRecete.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
  TUrtRecete(Result).RefreshHeader;
end;

end.
