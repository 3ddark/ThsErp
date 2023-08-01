unit Ths.Database.Table.UrtReceteler;

interface

{$I Ths.inc}

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Data.DB,
  ZDataset,
  System.Generics.Collections,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.TableDetailed,
  Ths.Database.Table.StkStokKarti,
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
    //veri tabaný alaný deðil join
    FReceteKodu: TFieldDB;
    FStokAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FStkStokKarti: TStkStokKarti;
    FSysOlcuBirimi: TSysOlcuBirimi;
    FUrtRecete: TUrtRecete;

    constructor Create(ADatabase: TDatabase; ARecete: TUrtRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TUrtRecete;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property ReceteID: TFieldDB read FReceteID write FReceteID;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property FireOrani: TFieldDB read FFireOrani write FFireOrani;
    //veri tabaný alaný deðil join
    Property ReceteKodu: TFieldDB read FReceteKodu write FReceteKodu;
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TUrtReceteIscilik = class(TTable)
  private
    FHeaderID: TFieldDB;
    FGiderKodu: TFieldDB;
    FMiktar: TFieldDB;
    //veri tabaný alaný deðil join
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

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property GiderKodu: TFieldDB read FGiderKodu write FGiderKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    //veri tabaný alaný deðil join
    Property GiderAdi: TFieldDB read FGiderAdi write FGiderAdi;
    Property Birim: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TUrtReceteYanUrun = class(TTable)
  private
    FHeaderID: TFieldDB;
    FStokKodu: TFieldDB;
    FMiktar: TFieldDB;
    FFireOrani: TFieldDB;
    //veri tabaný alaný deðil join
    FStokAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FStkStokKarti: TStkStokKarti;
    FSysOlcuBirimi: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ARecete: TUrtRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TUrtRecete;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property FireOrani: TFieldDB read FFireOrani write FFireOrani;
    //veri tabaný alaný deðil join
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TUrtRecete = class(TTableDetailed)
  private
    FReceteKodu: TFieldDB;
    FReceteAdi: TFieldDB;
    FOrnekUretimMiktari: TFieldDB;
    FAciklama: TFieldDB;
    FMaliyet: TFieldDB;
    FHammaddeMaliyet: TFieldDB;
    FIscilikMaliyet: TFieldDB;
    FYanUrunMaliyet: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
    function ValidateDetay(ATable: TTable): Boolean; override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    ReceteMaliyet: TReceteTotals;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property ReceteKodu: TFieldDB read FReceteKodu write FReceteKodu;
    Property ReceteAdi: TFieldDB read FReceteAdi write FReceteAdi;
    Property OrnekUretimMiktari: TFieldDB read FOrnekUretimMiktari write FOrnekUretimMiktari;
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

  FStkStokKarti := TStkStokKarti.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);
  FUrtRecete := TUrtRecete.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FReceteID := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FReceteKodu := TFieldDB.Create(FUrtRecete.FReceteKodu.FieldName, FUrtRecete.ReceteKodu.DataType, '', Self, '');
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

procedure TUrtReceteHammadde.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FReceteID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Open;
  end;
end;

procedure TUrtReceteHammadde.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FReceteID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName,
      addField(FUrtRecete.TableName, FUrtRecete.FReceteKodu.FieldName, FReceteKodu.FieldName),
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

procedure TUrtReceteHammadde.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    Close;
    SQL.Clear;
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FReceteID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
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

procedure TUrtReceteHammadde.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FReceteID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TUrtReceteHammadde.Clone: TTable;
begin
  Result := TUrtReceteHammadde.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TUrtReceteIscilik.Create(ADatabase: TDatabase; ARecete: TUrtRecete);
begin
  TableName := 'rct_recete_iscilik';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FUrtIscilik := TUrtIscilik.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FGiderKodu := TFieldDB.Create('gider_kodu', ftWideString, '', Self, '');
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

procedure TUrtReceteIscilik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FGiderKodu.QryName,
      addField(FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, FGiderAdi.FieldName),
      FMiktar.QryName,
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FUrtIscilik.TableName, FUrtIscilik.Fiyat.FieldName, FFiyat.FieldName)
    ], [
      addJoin(jtLeft, FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, TableName, FGiderKodu.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FUrtIscilik.TableName, FUrtIscilik.BirimID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TUrtReceteIscilik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FGiderKodu.QryName,
      addField(FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, FGiderAdi.FieldName),
      FMiktar.QryName,
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FUrtIscilik.TableName, FUrtIscilik.Fiyat.FieldName, FFiyat.FieldName)
    ], [
      addJoin(jtLeft, FUrtIscilik.TableName, FUrtIscilik.GiderKodu.FieldName, TableName, FGiderKodu.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FUrtIscilik.TableName, FUrtIscilik.BirimID.FieldName),
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

procedure TUrtReceteIscilik.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FGiderKodu.FieldName,
      FMiktar.FieldName
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

procedure TUrtReceteIscilik.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FGiderKodu.FieldName,
      FMiktar.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TUrtReceteIscilik.Clone: TTable;
begin
  Result := TUrtReceteIscilik.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TUrtReceteYanUrun.Create(ADatabase: TDatabase; ARecete: TUrtRecete);
begin
  TableName := 'rct_recete_yan_urun';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FStkStokKarti := TStkStokKarti.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
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

procedure TUrtReceteYanUrun.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Open;
  end;
end;

procedure TUrtReceteYanUrun.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName,
      addField(FStkStokKarti.TableName, FStkStokKarti.StokAdi.FieldName, FStokAdi.FieldName),
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FStkStokKarti.TableName, FStkStokKarti.AlisFiyat.FieldName, FFiyat.FieldName)
    ], [
      addJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FStkStokKarti.TableName, FStkStokKarti.OlcuBirimiID.FieldName),
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtReceteYanUrun.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
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

procedure TUrtReceteYanUrun.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TUrtReceteYanUrun.Clone: TTable;
begin
  Result := TUrtReceteYanUrun.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TUrtRecete.Create(ADatabase: TDatabase);
begin
  TableName := 'rct_recete';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  ReceteMaliyet.HammaddeCount := 0;
  ReceteMaliyet.IscilikCount := 0;
  ReceteMaliyet.YanUrunCount := 0;

  FReceteKodu := TFieldDB.Create('recete_kodu', ftWideString, '', Self, 'Reçete Kodu');
  FReceteAdi := TFieldDB.Create('recete_adi', ftWideString, '', Self, 'Reçete Adý');
  FOrnekUretimMiktari := TFieldDB.Create('ornek_uretim_miktari', ftFloat, 0, Self, 'Örnek Üretim Miktarý');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, 'Açýklama');
  FMaliyet := TFieldDB.Create('maliyet', ftBCD, 0, Self, 'Maliyet');
  FHammaddeMaliyet := TFieldDB.Create('hammadde_maliyet', ftBCD, 0, Self, 'Hammadde Maliyet');
  FIscilikMaliyet := TFieldDB.Create('iscilik_maliyet', ftBCD, 0, Self, 'Ýþçilik Maliyet');
  FYanUrunMaliyet := TFieldDB.Create('yan_urun_maliyet', ftBCD, 0, Self, 'Yan Ürün Maliyet');
end;

procedure TUrtRecete.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    SQL.Clear;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FReceteKodu.QryName,
      FReceteAdi.QryName,
      FOrnekUretimMiktari.QryName,
      FAciklama.QryName,
      'spget_rct_toplam('           + Id.QryName + '::::bigint) ' + FMaliyet.FieldName,
      'spget_rct_hammadde_maliyet(' + Id.QryName + '::::bigint) ' + FHammaddeMaliyet.FieldName,
      'spget_rct_iscilik_maliyet('  + Id.QryName + '::::bigint) ' + FIscilikMaliyet.FieldName,
      'spget_rct_yan_urun_maliyet(' + Id.QryName + '::::bigint) ' + FYanUrunMaliyet.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TUrtRecete.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Self.Id.QryName,
      FReceteKodu.QryName,
      FReceteAdi.QryName,
      FOrnekUretimMiktari.QryName,
      FAciklama.QryName,
      'spget_rct_toplam('           + Self.Id.QryName + '::::bigint) ' + FMaliyet.FieldName,
      'spget_rct_hammadde_maliyet(' + Self.Id.QryName + '::::bigint) ' + FHammaddeMaliyet.FieldName,
      'spget_rct_iscilik_maliyet('  + Self.Id.QryName + '::::bigint) ' + FIscilikMaliyet.FieldName,
      'spget_rct_yan_urun_maliyet(' + Self.Id.QryName + '::::bigint) ' + FYanUrunMaliyet.FieldName
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

procedure TUrtRecete.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FReceteKodu.FieldName,
      FReceteAdi.FieldName,
      FOrnekUretimMiktari.FieldName,
      FAciklama.FieldName
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

procedure TUrtRecete.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FReceteKodu.FieldName,
      FReceteAdi.FieldName,
      FOrnekUretimMiktari.FieldName,
      FAciklama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
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
      if TUrtReceteIscilik(ListDetay[n1]).FGiderKodu.AsString = TUrtReceteIscilik(ATable).FGiderKodu.AsString then
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
      if TUrtReceteYanUrun(ListDetay[n1]).FStokKodu.AsString = TUrtReceteYanUrun(ATable).FStokKodu.AsString then
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

procedure TUrtRecete.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  n1, vID: Integer;
begin
  Self.Insert(vID, APermissionControl);
  Self.Id.Value := vID;
  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtReceteHammadde then
    begin
      TUrtReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtReceteHammadde(ListDetay[n1]).Insert(vID, True);
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteIscilik then
    begin
      TUrtReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtReceteIscilik(ListDetay[n1]).Insert(vID, True);
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtReceteYanUrun then
    begin
      TUrtReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtReceteYanUrun(ListDetay[n1]).Insert(vID, True);
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
  n1, LID: Integer;
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
      TTable(ListDetay[n1]).Insert(LID, False);
      TTable(ListDetay[n1]).Id.Value := LID;
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
