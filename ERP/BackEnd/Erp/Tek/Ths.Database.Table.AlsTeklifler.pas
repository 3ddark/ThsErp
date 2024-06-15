unit Ths.Database.Table.AlsTeklifler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Math,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.TableDetailed,
  Ths.Database.Table.PrsPersoneller,
  Ths.Database.Table.StkKartlar,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.SetEInvFaturaTipleri,
  Ths.Database.Table.SetSatTeklifDurum;

type
  TAlsTeklif = class;

  TAlsTeklifDetay = class(TTable)
  private
    FHeaderID: TFieldDB;
    FTeklifDetayID: TFieldDB;
    FIrsaliyeDetayID: TFieldDB;
    FFaturaDetayID: TFieldDB;
    FStokKodu: TFieldDB;
    FStokAciklama: TFieldDB;
    FKullaniciAciklama: TFieldDB;
    FReferans: TFieldDB;
    FMiktar: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FIskontoOrani: TFieldDB;
    FKdvOrani: TFieldDB;
    FFiyat: TFieldDB;
    FNetFiyat: TFieldDB;
    FTutar: TFieldDB;
    FIskontoTutar: TFieldDB;
    FNetTutar: TFieldDB;
    FKdvTutar: TFieldDB;
    FToplamTutar: TFieldDB;
    FIsAnaUrun: TFieldDB;
    FReferansAnaUrunID: TFieldDB;
    FGtipNo: TFieldDB;
  published
    FStkStokKarti: TStkKart;
    constructor Create(ADatabase: TDatabase; ATeklif: TAlsTeklif = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Teklif: TAlsTeklif;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    //function ToSiparisDetay: TSatSiparisDetay;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property SiparisDetayID: TFieldDB read FTeklifDetayID write FTeklifDetayID;
    Property IrsaliyeDetayID: TFieldDB read FIrsaliyeDetayID write FIrsaliyeDetayID;
    Property FaturaDetayID: TFieldDB read FFaturaDetayID write FFaturaDetayID;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property StokAciklama: TFieldDB read FStokAciklama write FStokAciklama;
    Property KullaniciAciklama: TFieldDB read FKullaniciAciklama write FKullaniciAciklama;
    Property Referans: TFieldDB read FReferans write FReferans;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property IskontoOrani: TFieldDB read FIskontoOrani write FIskontoOrani;
    Property KdvOrani: TFieldDB read FKdvOrani write FKdvOrani;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
    Property NetFiyat: TFieldDB read FNetFiyat write FNetFiyat;
    Property Tutar: TFieldDB read FTutar write FTutar;
    Property IskontoTutar: TFieldDB read FIskontoTutar write FIskontoTutar;
    Property NetTutar: TFieldDB read FNetTutar write FNetTutar;
    Property KdvTutar: TFieldDB read FKdvTutar write FKdvTutar;
    Property ToplamTutar: TFieldDB read FToplamTutar write FToplamTutar;
    Property IsAnaUrun: TFieldDB read FIsAnaUrun write FIsAnaUrun;
    Property ReferansAnaUrunID: TFieldDB read FReferansAnaUrunID write FReferansAnaUrunID;
    Property GtipNo: TFieldDB read FGtipNo write FGtipNo;
  end;

  TAlsTeklif = class(TTableDetailed)
  private
    FSiparisID: TFieldDB;
    FIrsaliyeID: TFieldDB;
    FFaturaID: TFieldDB;
    FIsSiparislesti: TFieldDB;
    FTutar: TFieldDB;
    FIskontoTutar: TFieldDB;
    FAraToplam: TFieldDB;
    FKDVOran1: TFieldDB;
    FKDVTutar1: TFieldDB;
    FKDVOran2: TFieldDB;
    FKDVTutar2: TFieldDB;
    FKDVOran3: TFieldDB;
    FKDVTutar3: TFieldDB;
    FKDVOran4: TFieldDB;
    FKDVTutar4: TFieldDB;
    FKDVOran5: TFieldDB;
    FKDVTutar5: TFieldDB;
    FGenelToplam: TFieldDB;
    FIslemTipiID: TFieldDB;
    FIslemTipi: TFieldDB;
    FTeklifNo: TFieldDB;
    FTeklifTarihi: TFieldDB;
    FGecerlilikTarihi: TFieldDB;
    FMusteriKodu: TFieldDB;
    FMusteriAdi: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB;
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
    FIlce: TFieldDB;
    FMahalle: TFieldDB;
    FSemt: TFieldDB;
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FPostaKodu: TFieldDB;
    FMusteriTemsilcisi: TFieldDB;
    FMuhattapAd: TFieldDB;
    FMuhattapTelefon: TFieldDB;
    FReferans: TFieldDB;
    FParaBirimi: TFieldDB;
    FDovizKuruUsd: TFieldDB;
    FDovizKuruEur: TFieldDB;
    FAciklama: TFieldDB;
    FTevkifatKodu: TFieldDB;
    FTevkifatAciklama: TFieldDB;
    FTevkifatPay: TFieldDB;
    FTevkifatPayda: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
  published
    FFaturaTipi: TSetEinvFaturaTipi;
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;
    FTemsilci: TPrsPersonel;
    FSetTeklifDurum: TSetSatTeklifDurum;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    //function ToSiparis: TSatSiparis;

    function GetAddress: string;
    function ValidateDetay(ATable: TTable): Boolean; override;

    procedure PubRefreshHeader;

    Property SiparisID: TFieldDB read FSiparisID write FSiparisID;
    Property IrsaliyeID: TFieldDB read FIrsaliyeID write FIrsaliyeID;
    Property FaturaID: TFieldDB read FFaturaID write FFaturaID;
    Property IsSiparislesti: TFieldDB read FIsSiparislesti write FIsSiparislesti;
    Property Tutar: TFieldDB read FTutar write FTutar;
    Property IskontoTutar: TFieldDB read FIskontoTutar write FIskontoTutar;
    Property AraToplam: TFieldDB read FAraToplam write FAraToplam;
    Property KDVOran1: TFieldDB read FKDVOran1 write FKDVOran1;
    Property KDVTutar1: TFieldDB read FKDVTutar1 write FKDVTutar1;
    Property KDVOran2: TFieldDB read FKDVOran2 write FKDVOran2;
    Property KDVTutar2: TFieldDB read FKDVTutar2 write FKDVTutar2;
    Property KDVOran3: TFieldDB read FKDVOran3 write FKDVOran3;
    Property KDVTutar3: TFieldDB read FKDVTutar3 write FKDVTutar3;
    Property KDVOran4: TFieldDB read FKDVOran4 write FKDVOran4;
    Property KDVTutar4: TFieldDB read FKDVTutar4 write FKDVTutar4;
    Property KDVOran5: TFieldDB read FKDVOran5 write FKDVOran5;
    Property KDVTutar5: TFieldDB read FKDVTutar5 write FKDVTutar5;
    Property GenelToplam: TFieldDB read FGenelToplam write FGenelToplam;
    Property IslemTipiID: TFieldDB read FIslemTipiID write FIslemTipiID;
    Property IslemTipi: TFieldDB read FIslemTipi write FIslemTipi;
    Property TeklifNo: TFieldDB read FTeklifNo write FTeklifNo;
    Property TeklifTarihi: TFieldDB read FTeklifTarihi write FTeklifTarihi;
    Property GecerlilikTarihi: TFieldDB read FGecerlilikTarihi write FGecerlilikTarihi;
    Property MusteriKodu: TFieldDB read FMusteriKodu write FMusteriKodu;
    Property MusteriAdi: TFieldDB read FMusteriAdi write FMusteriAdi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property Ilce: TFieldDB read FIlce write FIlce;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Semt: TFieldDB read FSemt write FSemt;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property MusteriTemsilcisi: TFieldDB read FMusteriTemsilcisi write FMusteriTemsilcisi;
    Property MuhattapAd: TFieldDB read FMuhattapAd write FMuhattapAd;
    Property MuhattapTelefon: TFieldDB read FMuhattapTelefon write FMuhattapTelefon;
    Property Referans: TFieldDB read FReferans write FReferans;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property DovizKuruUsd: TFieldDB read FDovizKuruUsd write FDovizKuruUsd;
    Property DovizKuruEur: TFieldDB read FDovizKuruEur write FDovizKuruEur;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property TevkifatKodu: TFieldDB read FTevkifatKodu write FTevkifatKodu;
    Property TevkifatAciklama: TFieldDB read FTevkifatAciklama write FTevkifatAciklama;
    Property TevkifatPay: TFieldDB read FTevkifatPay write FTevkifatPay;
    Property TevkifatPayda: TFieldDB read FTevkifatPayda write FTevkifatPayda;
  end;

implementation

uses Ths.Constants;

constructor TAlsTeklifDetay.Create(ADatabase: TDatabase; ATeklif: TAlsTeklif);
begin
  TableName := 'als_teklif_detaylari';
  TableSourceCode := MODULE_SAT_TEK_KAYIT;
  inherited Create(ADatabase);

  FStkStokKarti := TStkKart.Create(ADatabase);

  if ATeklif <> nil then
    Teklif := ATeklif;

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FTeklifDetayID := TFieldDB.Create('siparis_detay_id', ftInteger, 0, Self, '');
  FIrsaliyeDetayID := TFieldDB.Create('irsaliye_detay_id', ftInteger, 0, Self, '');
  FFaturaDetayID := TFieldDB.Create('fatura_detay_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FStokAciklama := TFieldDB.Create('stok_aciklama', ftWideString, '', Self, '');
  FKullaniciAciklama := TFieldDB.Create('kullanici_aciklama', ftWideString, '', Self, '');
  FReferans := TFieldDB.Create('referans', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftBCD, 0, Self, '');
  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftWideString, '', Self, '');
  FIskontoOrani := TFieldDB.Create('iskonto_orani', ftBCD, 0, Self, '');
  FKdvOrani := TFieldDB.Create('kdv_orani', ftInteger, 0, Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
  FNetFiyat := TFieldDB.Create('net_fiyat', ftBCD, 0, Self, '');
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, '');
  FIskontoTutar := TFieldDB.Create('iskonto_tutar', ftBCD, 0, Self, '');
  FNetTutar := TFieldDB.Create('net_tutar', ftBCD, 0, Self, '');
  FKdvTutar := TFieldDB.Create('kdv_tutar', ftBCD, 0, Self, '');
  FToplamTutar := TFieldDB.Create('toplam_tutar', ftBCD, 0, Self, '');
  FIsAnaUrun := TFieldDB.Create('is_ana_urun', ftBoolean, 0, Self, '');
  FReferansAnaUrunID := TFieldDB.Create('referans_ana_urun_id', ftInteger, 0, Self, '');
  FGtipNo := TFieldDB.Create('gtip_no', ftWideString, '', Self, '');

  PrepareTableRequiredValues;
end;

destructor TAlsTeklifDetay.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  inherited;
end;

procedure TAlsTeklifDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Self.Id.QryName,
      FHeaderID.QryName,
      FTeklifDetayID.QryName,
      FIrsaliyeDetayID.QryName,
      FFaturaDetayID.QryName,
      FStokKodu.QryName,
      FStokAciklama.QryName,
      FKullaniciAciklama.QryName,
      FReferans.QryName,
      FMiktar.QryName,
      FOlcuBirimi.QryName,
      FIskontoOrani.QryName,
      FKdvOrani.QryName,
      FFiyat.QryName,
      FNetFiyat.QryName,
      FTutar.QryName,
      FIskontoTutar.QryName,
      FNetTutar.QryName,
      FKdvTutar.QryName,
      FToplamTutar.QryName,
      FIsAnaUrun.QryName,
      FReferansAnaUrunID.QryName,
      FGtipNo.QryName
    ], [
      addJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TAlsTeklifDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FHeaderID.QryName,
      FTeklifDetayID.QryName,
      FIrsaliyeDetayID.QryName,
      FFaturaDetayID.QryName,
      FStokKodu.QryName,
      FStokAciklama.QryName,
      FKullaniciAciklama.QryName,
      FReferans.QryName,
      FMiktar.QryName,
      FOlcuBirimi.QryName,
      FIskontoOrani.QryName,
      FKdvOrani.QryName,
      FFiyat.QryName,
      FNetFiyat.QryName,
      FTutar.QryName,
      FIskontoTutar.QryName,
      FNetTutar.QryName,
      FKdvTutar.QryName,
      FToplamTutar.QryName,
      FIsAnaUrun.QryName,
      FReferansAnaUrunID.QryName,
      FGtipNo.QryName
    ], [
      addJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
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

{
function TAlsTeklifDetay.ToSiparisDetay: TSatSiparisDetay;
var
  LStok: TStkKart;
begin
  Result := TSatSiparisDetay.Create(Database);
  LStok := TStkKart.Create(Database);
  try
    LStok.SelectToList(' AND ' + LStok.StokKodu.QryName + '=' + QuotedStr(FStokKodu.Value), False, False);

    Result.HeaderID.Value := 0;
    Result.TeklifDetayID.Value := Self.Id.Value;
    Result.IrsaliyeDetayID.Value := FIrsaliyeDetayID.Value;
    Result.FaturaDetayID.Value := FFaturaDetayID.Value;
    Result.StokKodu.Value := FStokKodu.Value;
    Result.StokAciklama.Value := FStokAciklama.Value;
    Result.KullaniciAciklama.Value := FKullaniciAciklama.Value;
    Result.Referans.Value := FReferans.Value;
    Result.Miktar.Value := FMiktar.Value;
    Result.OlcuBirimi.Value := FOlcuBirimi.Value;
    Result.IskontoOrani.Value := FIskontoOrani.Value;
    Result.KdvOrani.Value := FKdvOrani.Value;
    Result.Fiyat.Value := FFiyat.Value;
    Result.NetFiyat.Value := FNetFiyat.Value;
    Result.Tutar.Value := FTutar.Value;
    Result.IskontoTutar.Value := FIskontoTutar.Value;
    Result.NetTutar.Value := FNetTutar.Value;
    Result.KdvTutar.Value := FKdvTutar.Value;
    Result.ToplamTutar.Value := FToplamTutar.Value;
    Result.IsAnaUrun.Value := FIsAnaUrun.Value;
    Result.ReferansAnaUrunID.Value := FReferansAnaUrunID.Value;
    Result.GtipNo.Value := FGtipNo.Value;

    if LStok.List.Count = 1 then
    begin
      //stok kartý ve sipariþ detay mm
      Result.En.Value := LStok.En.Value;
      Result.Boy.Value := LStok.Boy.Value;
      Result.Yukseklik.Value := LStok.Yukseklik.Value;
      //stok kartý ve sipariþ detay kg birimi
      Result.NetAgirlik.Value := LStok.Agirlik.Value;
      Result.BrutAgirlik.Value := Result.NetAgirlik.Value;
    end;
  finally
    LStok.Free;
  end;
end;
}
procedure TAlsTeklifDetay.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FTeklifDetayID.FieldName,
      FIrsaliyeDetayID.FieldName,
      FFaturaDetayID.FieldName,
      FStokKodu.FieldName,
      FStokAciklama.FieldName,
      FKullaniciAciklama.FieldName,
      FReferans.FieldName,
      FMiktar.FieldName,
      FOlcuBirimi.FieldName,
      FIskontoOrani.FieldName,
      FKdvOrani.FieldName,
      FFiyat.FieldName,
      FNetFiyat.FieldName,
      FTutar.FieldName,
      FIskontoTutar.FieldName,
      FNetTutar.FieldName,
      FKdvTutar.FieldName,
      FToplamTutar.FieldName,
      FIsAnaUrun.FieldName,
      FReferansAnaUrunID.FieldName,
      FGtipNo.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TAlsTeklifDetay.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderID.FieldName,
      FTeklifDetayID.FieldName,
      FIrsaliyeDetayID.FieldName,
      FFaturaDetayID.FieldName,
      FStokKodu.FieldName,
      FStokAciklama.FieldName,
      FKullaniciAciklama.FieldName,
      FReferans.FieldName,
      FMiktar.FieldName,
      FOlcuBirimi.FieldName,
      FIskontoOrani.FieldName,
      FKdvOrani.FieldName,
      FFiyat.FieldName,
      FNetFiyat.FieldName,
      FTutar.FieldName,
      FIskontoTutar.FieldName,
      FNetTutar.FieldName,
      FKdvTutar.FieldName,
      FToplamTutar.FieldName,
      FIsAnaUrun.FieldName,
      FReferansAnaUrunID.FieldName,
      FGtipNo.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TAlsTeklifDetay.Clone: TTable;
begin
  Result := TAlsTeklifDetay.Create(Database, Self.Teklif);
  CloneClassContent(Self, Result);
end;

constructor TAlsTeklif.Create(ADatabase: TDatabase);
begin
  TableName := 'als_teklifler';
  TableSourceCode := MODULE_SAT_TEK_KAYIT;
  inherited Create(ADatabase);

  FSysUlke := TSysUlke.Create(Database);
  FSysSehir := TSysSehir.Create(Database);
  FTemsilci := TPrsPersonel.Create(Database);
  FFaturaTipi := TSetEinvFaturaTipi.Create(Database);
  FSetTeklifDurum := TSetSatTeklifDurum.Create(Database);

  FSiparisID := TFieldDB.Create('siparis_id', ftInteger, 0, Self, 'Sipariþ ID');
  FIrsaliyeID := TFieldDB.Create('irsaliye_id', ftInteger, 0, Self, 'Ýrsaliye ID');
  FFaturaID := TFieldDB.Create('fatura_id', ftInteger, 0, Self, 'Fatura ID');
  FIsSiparislesti := TFieldDB.Create('is_siparislesti', ftBoolean, False, Self, 'Sipariþleþti');
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, 'Tutar');
  FIskontoTutar := TFieldDB.Create('iskonto_tutar', ftBCD, 0, Self, 'Ýsk.Tutar');
  FAraToplam := TFieldDB.Create('ara_toplam', ftBCD, 0, Self, 'Ara Toplam');
  FKDVOran1 := TFieldDB.Create('kdv_oran1', ftInteger, 0, Self, 'KDV Oran1');
  FKDVTutar1 := TFieldDB.Create('kdv_tutar1', ftBCD, 0, Self, 'KDV Tutar1');
  FKDVOran2 := TFieldDB.Create('kdv_oran2', ftInteger, 0, Self, 'KDV Oran2');
  FKDVTutar2 := TFieldDB.Create('kdv_tutar2', ftBCD, 0, Self, 'KDV Tutar2');
  FKDVOran3 := TFieldDB.Create('kdv_oran3', ftInteger, 0, Self, 'KDV Oran3');
  FKDVTutar3 := TFieldDB.Create('kdv_tutar3', ftBCD, 0, Self, 'KDV Tutar3');
  FKDVOran4 := TFieldDB.Create('kdv_oran4', ftInteger, 0, Self, 'KDV Oran4');
  FKDVTutar4 := TFieldDB.Create('kdv_tutar4', ftBCD, 0, Self, 'KDV Tutar4');
  FKDVOran5 := TFieldDB.Create('kdv_oran5', ftInteger, 0, Self, 'KDV Oran5');
  FKDVTutar5 := TFieldDB.Create('kdv_tutar5', ftBCD, 0, Self, 'KDV Tutar5');
  FGenelToplam := TFieldDB.Create('genel_toplam', ftBCD, 0, Self, 'Genel Toplam');
  FIslemTipiID := TFieldDB.Create('islem_tipi_id', ftInteger, 0, Self, 'Ýþlem Tipi ID');
  FIslemTipi := TFieldDB.Create(FFaturaTipi.FaturaTipi.FieldName, FFaturaTipi.FaturaTipi.DataType, '', Self, 'Ýþlem Tipi');
  FTeklifNo := TFieldDB.Create('teklif_no', ftWideString, '', Self, 'Teklif No');
  FTeklifTarihi := TFieldDB.Create('teklif_tarihi', ftDateTime, 0, Self, 'Teklif Tarihi');
  FGecerlilikTarihi := TFieldDB.Create('gecerlilik_tarihi', ftDateTime, 0, Self, 'Geçerlilik Tarihi');
  FMusteriKodu := TFieldDB.Create('musteri_kodu', ftWideString, '', Self, 'Müþteri Kodu');
  FMusteriAdi := TFieldDB.Create('musteri_adi', ftWideString, '', Self, 'Müþteri Adý');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftWideString, '', Self, 'Vergi Dairesi');
  FVergiNo := TFieldDB.Create('vergi_no', ftWideString, '', Self, 'Vergi No');
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self, 'Ülke ID');
  FUlke := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self, 'Ülke Adý');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'Þehir ID');
  FSehir := TFieldDB.Create(FSysSehir.Sehir.FieldName, FSysSehir.Sehir.DataType, '', Self, 'Þehir');
  FIlce := TFieldDB.Create('ilce', ftWideString, '', Self, 'Ýlçe');
  FMahalle := TFieldDB.Create('mahalle', ftWideString, '', Self, 'Mahalle');
  FSemt := TFieldDB.Create('semt', ftWideString, '', Self, 'Semt');
  FCadde := TFieldDB.Create('cadde', ftWideString, '', Self, 'Cadde');
  FSokak := TFieldDB.Create('sokak', ftWideString, '', Self, 'Sokak');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftWideString, '', Self, 'Posta Kodu');
  FBinaAdi := TFieldDB.Create('bina_adi', ftWideString, '', Self, 'Bina Adý');
  FKapiNo := TFieldDB.Create('kapi_no', ftWideString, '', Self, 'Kapý No');
  FMusteriTemsilcisi := TFieldDB.Create('musteri_temsilcisi', ftString, '', Self, 'Müþteri Temsilcisi');
  FMuhattapAd := TFieldDB.Create('muhattap_ad', ftWideString, '', Self, 'Muhattap Ad');
  FMuhattapTelefon := TFieldDB.Create('muhattap_telefon', ftWideString, '', Self, 'Muhattap Telefon');
  FReferans := TFieldDB.Create('referans', ftWideString, '', Self, 'Referans');
  FParaBirimi := TFieldDB.Create('para_birimi', ftWideString, '', Self, 'Para');
  FDovizKuruUsd := TFieldDB.Create('doviz_kuru_usd', ftBCD, 0, Self, 'Döviz Kuru Usd');
  FDovizKuruEur := TFieldDB.Create('doviz_kuru_eur', ftBCD, 0, Self, 'Döviz Kuru Eur');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, 'Açýklama');
  FTevkifatKodu := TFieldDB.Create('tevkifat_kodu', ftWideString, '', Self, 'Tevkifat Kodu');
  FTevkifatAciklama := TFieldDB.Create('tevkifat_aciklama', ftWideString, '', Self, 'Tevkifat Açýklama');
  FTevkifatPay := TFieldDB.Create('tevkifat_pay', ftSmallint, 0, Self, 'Tevkifat Pay');
  FTevkifatPayda := TFieldDB.Create('tevkifat_payda', ftSmallint, 0, Self, 'Tevkifat Payda');

  PrepareTableRequiredValues;
end;

destructor TAlsTeklif.Destroy;
begin
  FSysUlke.Free;
  FSysSehir.Free;
  FTemsilci.Free;
  FFaturaTipi.Free;
  FSetTeklifDurum.Free;

  inherited;
end;

procedure TAlsTeklif.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Self.Id.QryName,
      FSiparisID.QryName,
      FIrsaliyeID.QryName,
      FFaturaID.QryName,
      FIsSiparislesti.QryName,
      FTutar.QryName,
      FIskontoTutar.QryName,
      FAraToplam.QryName,
      FKDVOran1.QryName,
      FKDVTutar1.QryName,
      FKDVOran2.QryName,
      FKDVTutar2.QryName,
      FKDVOran3.QryName,
      FKDVTutar3.QryName,
      FKDVOran4.QryName,
      FKDVTutar4.QryName,
      FKDVOran5.QryName,
      FKDVTutar5.QryName,
      FGenelToplam.QryName,
      FIslemTipiID.QryName,
      addField(FFaturaTipi.TableName, FFaturaTipi.FaturaTipi.FieldName, FIslemTipi.FieldName),
      FTeklifNo.QryName,
      FTeklifTarihi.QryName,
      FGecerlilikTarihi.QryName,
      FMusteriKodu.QryName,
      FMusteriAdi.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FUlkeID.QryName,
      addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlke.FieldName),
      FSehirID.QryName,
      addField(FSysSehir.TableName, FSysSehir.Sehir.FieldName, FSehir.FieldName),
      FIlce.QryName,
      FMahalle.QryName,
      FSemt.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FPostaKodu.QryName,
      FMusteriTemsilcisi.QryName,
      FMuhattapAd.QryName,
      FMuhattapTelefon.QryName,
      FReferans.QryName,
      FParaBirimi.QryName,
      FDovizKuruUsd.QryName,
      FDovizKuruEur.QryName,
      FAciklama.QryName,
      FTevkifatKodu.QryName,
      FTevkifatAciklama.QryName,
      FTevkifatPay.QryName,
      FTevkifatPayda.QryName
    ], [
      addJoin(jtLeft, FFaturaTipi.TableName, FFaturaTipi.Id.FieldName, TableName, FIslemTipiID.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TAlsTeklif.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FSiparisID.QryName,
      FIrsaliyeID.QryName,
      FFaturaID.QryName,
      FIsSiparislesti.QryName,
      FTutar.QryName,
      FIskontoTutar.QryName,
      FAraToplam.QryName,
      FKDVOran1.QryName,
      FKDVTutar1.QryName,
      FKDVOran2.QryName,
      FKDVTutar2.QryName,
      FKDVOran3.QryName,
      FKDVTutar3.QryName,
      FKDVOran4.QryName,
      FKDVTutar4.QryName,
      FKDVOran5.QryName,
      FKDVTutar5.QryName,
      FGenelToplam.QryName,
      FIslemTipiID.QryName,
      addField(FFaturaTipi.TableName, FFaturaTipi.FaturaTipi.FieldName, FIslemTipi.FieldName),
      FTeklifNo.QryName,
      FTeklifTarihi.QryName,
      FGecerlilikTarihi.QryName,
      FMusteriKodu.QryName,
      FMusteriAdi.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FUlkeID.QryName,
      addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlke.FieldName),
      FSehirID.QryName,
      addField(FSysSehir.TableName, FSysSehir.Sehir.FieldName, FSehir.FieldName),
      FIlce.QryName,
      FMahalle.QryName,
      FSemt.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FPostaKodu.QryName,
      FMusteriTemsilcisi.QryName,
      FMuhattapAd.QryName,
      FMuhattapTelefon.QryName,
      FReferans.QryName,
      FParaBirimi.QryName,
      FDovizKuruUsd.QryName,
      FDovizKuruEur.QryName,
      FAciklama.QryName,
      FTevkifatKodu.QryName,
      FTevkifatAciklama.QryName,
      FTevkifatPay.QryName,
      FTevkifatPayda.QryName
    ], [
      addJoin(jtLeft, FFaturaTipi.TableName, FFaturaTipi.Id.FieldName, TableName, FIslemTipiID.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
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

procedure TAlsTeklif.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FSiparisID.FieldName,
      FIrsaliyeID.FieldName,
      FFaturaID.FieldName,
      FIsSiparislesti.FieldName,
      FTutar.FieldName,
      FIskontoTutar.FieldName,
      FAraToplam.FieldName,
      FKDVOran1.FieldName,
      FKDVTutar1.FieldName,
      FKDVOran2.FieldName,
      FKDVTutar2.FieldName,
      FKDVOran3.FieldName,
      FKDVTutar3.FieldName,
      FKDVOran4.FieldName,
      FKDVTutar4.FieldName,
      FKDVOran5.FieldName,
      FKDVTutar5.FieldName,
      FGenelToplam.FieldName,
      FIslemTipiID.FieldName,
      FTeklifNo.FieldName,
      FTeklifTarihi.FieldName,
      FGecerlilikTarihi.FieldName,
      FMusteriKodu.FieldName,
      FMusteriAdi.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FUlkeID.FieldName,
      FSehirID.FieldName,
      FIlce.FieldName,
      FMahalle.FieldName,
      FSemt.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FPostaKodu.FieldName,
      FMusteriTemsilcisi.FieldName,
      FMuhattapAd.FieldName,
      FMuhattapTelefon.FieldName,
      FReferans.FieldName,
      FParaBirimi.FieldName,
      FDovizKuruUsd.FieldName,
      FDovizKuruEur.FieldName,
      FAciklama.FieldName,
      FTevkifatKodu.FieldName,
      FTevkifatAciklama.FieldName,
      FTevkifatPay.FieldName,
      FTevkifatPayda.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TAlsTeklif.PubRefreshHeader;
begin
  RefreshHeader;
end;

procedure TAlsTeklif.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FSiparisID.FieldName,
      FIrsaliyeID.FieldName,
      FFaturaID.FieldName,
      FIsSiparislesti.FieldName,
      FTutar.FieldName,
      FIskontoTutar.FieldName,
      FAraToplam.FieldName,
      FKDVOran1.FieldName,
      FKDVTutar1.FieldName,
      FKDVOran2.FieldName,
      FKDVTutar2.FieldName,
      FKDVOran3.FieldName,
      FKDVTutar3.FieldName,
      FKDVOran4.FieldName,
      FKDVTutar4.FieldName,
      FKDVOran5.FieldName,
      FKDVTutar5.FieldName,
      FGenelToplam.FieldName,
      FIslemTipiID.FieldName,
      FTeklifNo.FieldName,
      FTeklifTarihi.FieldName,
      FGecerlilikTarihi.FieldName,
      FMusteriKodu.FieldName,
      FMusteriAdi.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FUlkeID.FieldName,
      FSehirID.FieldName,
      FIlce.FieldName,
      FMahalle.FieldName,
      FSemt.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FPostaKodu.FieldName,
      FMusteriTemsilcisi.FieldName,
      FMuhattapAd.FieldName,
      FMuhattapTelefon.FieldName,
      FReferans.FieldName,
      FParaBirimi.FieldName,
      FDovizKuruUsd.FieldName,
      FDovizKuruEur.FieldName,
      FAciklama.FieldName,
      FTevkifatKodu.FieldName,
      FTevkifatAciklama.FieldName,
      FTevkifatPay.FieldName,
      FTevkifatPayda.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TAlsTeklif.Clone: TTable;
begin
  Result := TAlsTeklif.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

{
function TAlsTeklif.ToSiparis: TSatSiparis;
var
  ASip: TSatSiparis;
  LSipDetay: TSatSiparisDetay;
  LSiparisDurum: TSetSatSiparisDurum;
  LTekDetay: TAlsTeklifDetay;
  n1: Integer;
begin
  LSiparisDurum := TSetSatSiparisDurum.Create(Database);
  LTekDetay := TAlsTeklifDetay.Create(Database, Self);
  try
    LSiparisDurum.SelectToList(' AND ' + LSiparisDurum.Id.QryName + '=' + Ord(TSatSiparisDurum.Beklemede).ToString, False, False);

    ASip := TSatSiparis.Create(Database);
    ASip.TeklifID.Value := Self.Id.Value;
    ASip.Tutar.Value := Self.Tutar.Value;
    ASip.IskontoTutar.Value := Self.IskontoTutar.Value;
    ASip.AraToplam.Value := Self.AraToplam.Value;
    ASip.KDVOran1.Value := Self.KDVOran1.Value;
    ASip.KDVTutar1.Value := Self.KDVTutar1.Value;
    ASip.KDVOran2.Value := Self.KDVOran2.Value;
    ASip.KDVTutar2.Value := Self.KDVTutar2.Value;
    ASip.KDVOran3.Value := Self.KDVOran3.Value;
    ASip.KDVTutar3.Value := Self.KDVTutar3.Value;
    ASip.KDVOran4.Value := Self.KDVOran4.Value;
    ASip.KDVTutar4.Value := Self.KDVTutar4.Value;
    ASip.KDVOran5.Value := Self.KDVOran5.Value;
    ASip.KDVTutar5.Value := Self.KDVTutar5.Value;
    ASip.GenelToplam.Value := Self.GenelToplam.Value;
    ASip.IslemTipiID.Value := Self.IslemTipiID.Value;
    ASip.IslemTipi.Value := Self.IslemTipi.Value;
    ASip.TeslimTarihi.Value := 0;
    ASip.MusteriKodu.Value := Self.MusteriKodu.Value;
    ASip.MusteriAdi.Value := Self.MusteriAdi.Value;
    ASip.VergiDairesi.Value := Self.VergiDairesi.Value;
    ASip.VergiNo.Value := Self.VergiNo.Value;
    ASip.UlkeID.Value := Self.UlkeID.Value;
    ASip.Ulke.Value := Self.Ulke.Value;
    ASip.SehirID.Value := Self.SehirID.Value;
    ASip.Sehir.Value := Self.Sehir.Value;
    ASip.Ilce.Value := Self.Ilce.Value;
    ASip.Mahalle.Value := Self.Mahalle.Value;
    ASip.Cadde.Value := Self.Cadde.Value;
    ASip.Sokak.Value := Self.Sokak.Value;
    ASip.PostaKodu.Value := Self.PostaKodu.Value;
    ASip.BinaAdi.Value := Self.BinaAdi.Value;
    ASip.KapiNo.Value := Self.KapiNo.Value;
    ASip.MusteriTemsilcisiID.Value := GSysKullanici.PersonelID.Value;
    ASip.MusteriTemsilcisi.Value := GSysKullanici.AdSoyad.Value;
    ASip.MuhattapAd.Value := Self.MuhattapAd.Value;
    ASip.Referans.Value := Self.Referans.Value;
    ASip.ParaBirimi.Value := Self.ParaBirimi.Value;
    ASip.DovizKuruUsd.Value := Self.DovizKuruUsd.Value;
    ASip.DovizKuruEur.Value := Self.DovizKuruEur.Value;
    ASip.Aciklama.Value := Self.Aciklama.Value;
    ASip.ProformaNo.Value := Self.ProformaNo.Value;
    ASip.SiparisDurumID.Value := LSiparisDurum.Id.Value;
    ASip.SiparisDurum.Value := LSiparisDurum.SiparisDurum.Value;
    ASip.TeslimSekliID.Value := Self.TeslimSekliID.Value;
    ASip.TeslimSekli.Value := Self.TeslimSekli.Value;
    ASip.OdemeSekliID.Value := Self.OdemeSekliID.Value;
    ASip.OdemeSekli.Value := Self.OdemeSekli.Value;
    ASip.PaketTipiID.Value := Self.PaketTipiID.Value;
    ASip.PaketTipi.Value := Self.PaketTipi.Value;
    ASip.NakliyeUcretiID.Value := Self.TasimaUcretiID.Value;
    ASip.NakliyeUcreti.Value := Self.TasimaUcreti.Value;


    LTekDetay.SelectToList(' AND ' + LTekDetay.HeaderID.QryName + '=' + VarToStr(Self.Id.Value), False, False);
    for n1 := 0 to LTekDetay.List.Count-1 do
    begin
      LSipDetay := TAlsTeklifDetay(LTekDetay.List[n1]).ToSiparisDetay;
      LSipDetay.HeaderID.Value := ASip.Id.Value;

      ASip.AddDetay(LSipDetay);
    end;

    Result := ASip;
  finally
    LSiparisDurum.Free;
    LTekDetay.Free;
  end;
end;
}
function TAlsTeklif.GetAddress: string;
begin
  Result := '';
  if FMahalle.AsString <> '' then
    Result := Result + FMahalle.AsString + ' MAH. ';

  if FCadde.AsString <> '' then
    Result := Result + FCadde.AsString + ' CD. ';

  if FSokak.AsString <> '' then
    Result := Result + FSokak.AsString + ' SK. ';

  if FKapiNo.AsString <> '' then
    Result := Result + ' NO: ' + FKapiNo.AsString;
end;

procedure TAlsTeklif.RefreshHeader;
var
  n1: Integer;
begin
  Self.Tutar.Value              := 0;
  Self.IskontoTutar.Value       := 0;
  Self.AraToplam.Value          := 0;
  Self.KDVOran1.Value           := 0;
  Self.KDVTutar1.Value          := 0;
  Self.KDVOran2.Value           := 0;
  Self.KDVTutar2.Value          := 0;
  Self.KDVOran3.Value           := 0;
  Self.KDVTutar3.Value          := 0;
  Self.KDVOran4.Value           := 0;
  Self.KDVTutar4.Value          := 0;
  Self.KDVOran5.Value           := 0;
  Self.KDVTutar5.Value          := 0;
  Self.GenelToplam.Value        := 0;

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    if (FKDVOran1.Value = 0) and (FKDVOran1.Value <> TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran1.Value := TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran2.Value = 0) and (FKDVOran2.Value <> TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran2.Value := TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran3.Value = 0) and (FKDVOran3.Value <> TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran3.Value := TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran4.Value = 0) and (FKDVOran4.Value <> TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran4.Value := TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran5.Value = 0) and (FKDVOran5.Value <> TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran5.Value := TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value
  end;

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    if FKDVOran1.Value = TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar1.Value := FKDVTutar1.Value + TAlsTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran2.Value = TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar2.Value := FKDVTutar2.Value + TAlsTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran3.Value = TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar3.Value := FKDVTutar3.Value + TAlsTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran4.Value = TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar4.Value := FKDVTutar4.Value + TAlsTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran5.Value = TAlsTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar5.Value := FKDVTutar5.Value + TAlsTeklifDetay(ListDetay[n1]).KdvTutar.Value;

    FTutar.Value         := FTutar.Value        + TAlsTeklifDetay(ListDetay[n1]).Tutar.Value;
    FIskontoTutar.Value  := FIskontoTutar.Value + TAlsTeklifDetay(ListDetay[n1]).IskontoTutar.Value;
    FAraToplam.Value     := FTutar.Value - FIskontoTutar.Value;
    FGenelToplam.Value   := FGenelToplam.Value  + TAlsTeklifDetay(ListDetay[n1]).ToplamTutar.Value;
  end;
end;

procedure TAlsTeklif.BusinessDelete(APermissionControl: Boolean);
begin
  inherited;
  //
end;

procedure TAlsTeklif.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(True);
  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TAlsTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    TAlsTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
    TAlsTeklifDetay(Self.ListDetay[n1]).Insert(True);
  end;
end;

procedure TAlsTeklif.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  n1, n2: Integer;
  LDetay: TAlsTeklifDetay;
  ATeklif: TAlsTeklif;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);

  for n1 := 0 to List.Count-1 do
  begin
    ATeklif := TAlsTeklif(List[n1]);

    LDetay := TAlsTeklifDetay.Create(Database, ATeklif);
    try
      LDetay.SelectToList(' AND ' + LDetay.HeaderID.QryName + '=' + ATeklif.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LDetay.List.Count-1 do
        ATeklif.AddDetay(TAlsTeklifDetay(LDetay.List[n2]).Clone, n2 = LDetay.List.Count-1);
    finally
      LDetay.Free;
    end;
  end;
end;

procedure TAlsTeklif.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TAlsTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    if TAlsTeklifDetay(Self.ListDetay[n1]).Id.Value > 0 then
    begin
      TAlsTeklifDetay(Self.ListDetay[n1]).Update(False);
    end
    else
    begin
      TAlsTeklifDetay(Self.ListDetay[n1]).Insert(False);
    end;
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count-1 do
    if TAlsTeklifDetay(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TAlsTeklifDetay(Self.ListSilinenDetay[n1]).Delete(False);
end;

procedure TAlsTeklif.AddDetay(ATable: TTable; ALastItem: Boolean = False);
begin
  TAlsTeklifDetay(ATable).Teklif := Self;
  Self.ListDetay.Add(TAlsTeklifDetay(ATable));
  if ALastItem then RefreshHeader;
end;

procedure TAlsTeklif.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TAlsTeklif.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
  if CompareValue(TAlsTeklifDetay(ATable).Miktar.Value, 0, EPSILON) = EqualsValue then
    raise Exception.Create('Sýfýr miktar ile kayýt yapýlamaz!');
end;

procedure TAlsTeklif.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

end.



