unit Ths.Database.Table.SatSiparis;

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
  System.Generics.Collections,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.TableDetailed,
  Ths.Database.Table.SysOndalikHaneler,
  Ths.Database.Table.PrsPersoneller,
  Ths.Database.Table.StkKartlar,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.SetEInvFaturaTipleri,
  Ths.Database.Table.SeTSatSiparisDurum,
  Ths.Database.Table.SetEinvTeslimSekli,
  Ths.Database.Table.SetEinvOdemeSekli,
  Ths.Database.Table.SetEinvPaketTipi,
  Ths.Database.Table.SetEinvTasimaUcreti;

type
  TSatSiparis = class;

  TSatSiparisDetay = class(TTable)
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
    FEn: TFieldDB;
    FBoy: TFieldDB;
    FYukseklik: TFieldDB;
    FNetAgirlik: TFieldDB;
    FBrutAgirlik: TFieldDB;
    FHacim: TFieldDB;
    FKab: TFieldDB;
  published
    FStokResim: TFieldDB;

    FStkStokKarti: TStkKart;
    constructor Create(ADatabase: TDatabase; ASiparis: TSatSiparis = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Siparis: TSatSiparis;
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property TeklifDetayID: TFieldDB read FTeklifDetayID write FTeklifDetayID;
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
    Property En: TFieldDB read FEn write FEn;
    Property Boy: TFieldDB read FBoy write FBoy;
    Property Yukseklik: TFieldDB read FYukseklik write FYukseklik;
    Property Hacim: TFieldDB read FHacim write FHacim;
    Property NetAgirlik: TFieldDB read FNetAgirlik write FNetAgirlik;
    Property BrutAgirlik: TFieldDB read FBrutAgirlik write FBrutAgirlik;
    Property Kab: TFieldDB read FKab write FKab;
    Property StokResim: TFieldDB read FStokResim write FStokResim;
  end;

  TSatSiparis = class(TTableDetailed)
  private
    FTeklifID: TFieldDB;
    FIrsaliyeID: TFieldDB;
    FFaturaID: TFieldDB;
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
    FIslemTipi: TFieldDB; //veri tabaný alaný deðil not a database field
    FSiparisNo: TFieldDB;
    FSiparisTarihi: TFieldDB;
    FTeslimTarihi: TFieldDB;
    FMusteriKodu: TFieldDB;
    FMusteriAdi: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB; //veri tabaný alaný deðil not a database field
    FSehirID: TFieldDB;
    FSehir: TFieldDB; //veri tabaný alaný deðil not a database field
    FIlce: TFieldDB;
    FMahalle: TFieldDB;
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FPostaKodu: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FMusteriTemsilcisiID: TFieldDB;
    FMusteriTemsilcisi: TFieldDB; //veri tabaný alaný deðil not a database field
    FMuhattapAd: TFieldDB;
    FReferans: TFieldDB;
    FParaBirimi: TFieldDB;
    FDovizKuruUsd: TFieldDB;
    FDovizKuruEur: TFieldDB;
    FAciklama: TFieldDB;
    FProformaNo: TFieldDB;
    FSiparisDurumID: TFieldDB;
    FSiparisDurum: TFieldDB; //veri tabaný alaný deðil not a database field
    FTeslimSekliID: TFieldDB;
    FTeslimSekli: TFieldDB; //veri tabaný alaný deðil not a database field
    FOdemeSekliID: TFieldDB;
    FOdemeSekli: TFieldDB;  //veri tabaný alaný deðil not a database field
    FPaketTipiID: TFieldDB;
    FPaketTipi: TFieldDB;  //veri tabaný alaný deðil not a database field
    FTasimaUcretiID: TFieldDB;
    FTasimaUcreti: TFieldDB;  //veri tabaný alaný deðil not a database field
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
  published
    FFaturaTipi: TSetEinvFaturaTipi;
    FSysCountry: TSysUlke;
    FSysCity: TSysSehir;
    FTemsilci: TPrsPersonel;
    FSetSiparisDurum: TSeTSatSiparisDurum;
    FSetTeslimSekli: TSetEinvTeslimSekli;
    FSetOdemeSekli: TSetEinvOdemeSekli;
    FSetPaketTipi: TSetEinvPaketTipi;
    FSetNakliyeUcreti: TSetEinvTasimaUcreti;

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

    function getNewSiparisNo: string;
    function GetAddress: string;
    function ValidateDetay(ATable: TTable): Boolean; override;

    procedure PubRefreshHeader;

    Property TeklifID: TFieldDB read FTeklifID write FTeklifID;
    Property IrsaliyeID: TFieldDB read FIrsaliyeID write FIrsaliyeID;
    Property FaturaID: TFieldDB read FFaturaID write FFaturaID;
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
    Property IslemTipi: TFieldDB read FIslemTipi write FIslemTipi;  //veri tabaný alaný deðil not a database field
    Property SiparisNo: TFieldDB read FSiparisNo write FSiparisNo;
    Property SiparisTarihi: TFieldDB read FSiparisTarihi write FSiparisTarihi;
    Property TeslimTarihi: TFieldDB read FTeslimTarihi write FTeslimTarihi;
    Property MusteriKodu: TFieldDB read FMusteriKodu write FMusteriKodu;
    Property MusteriAdi: TFieldDB read FMusteriAdi write FMusteriAdi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;  //veri tabaný alaný deðil not a database field
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;  //veri tabaný alaný deðil not a database field
    Property Ilce: TFieldDB read FIlce write FIlce;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property MusteriTemsilcisiID: TFieldDB read FMusteriTemsilcisiID write FMusteriTemsilcisiID;
    Property MusteriTemsilcisi: TFieldDB read FMusteriTemsilcisi write FMusteriTemsilcisi;  //veri tabaný alaný deðil not a database field
    Property MuhattapAd: TFieldDB read FMuhattapAd write FMuhattapAd;
    Property Referans: TFieldDB read FReferans write FReferans;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property DovizKuruUsd: TFieldDB read FDovizKuruUsd write FDovizKuruUsd;
    Property DovizKuruEur: TFieldDB read FDovizKuruEur write FDovizKuruEur;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property ProformaNo: TFieldDB read FProformaNo write FProformaNo;
    Property SiparisDurumID: TFieldDB read FSiparisDurumID write FSiparisDurumID;
    Property SiparisDurum: TFieldDB read FSiparisDurum write FSiparisDurum;  //veri tabaný alaný deðil not a database field
    Property TeslimSekliID: TFieldDB read FTeslimSekliID write FTeslimSekliID;
    Property TeslimSekli: TFieldDB read FTeslimSekli write FTeslimSekli;  //veri tabaný alaný deðil not a database field
    Property OdemeSekliID: TFieldDB read FOdemeSekliID write FOdemeSekliID;
    Property OdemeSekli: TFieldDB read FOdemeSekli write FOdemeSekli; //veri tabaný alaný deðil not a database field
    Property PaketTipiID: TFieldDB read FPaketTipiID write FPaketTipiID;
    Property PaketTipi: TFieldDB read FPaketTipi write FPaketTipi;  //veri tabaný alaný deðil not a database field
    Property NakliyeUcretiID: TFieldDB read FTasimaUcretiID write FTasimaUcretiID;
    Property NakliyeUcreti: TFieldDB read FTasimaUcreti write FTasimaUcreti;  //veri tabaný alaný deðil not a database field
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SatTeklif;

constructor TSatSiparisDetay.Create(ADatabase: TDatabase; ASiparis: TSatSiparis);
begin
  TableName := 'sat_siparis_detay';
  TableSourceCode := MODULE_SAT_SIP_KAYIT;
  inherited Create(ADatabase);

  FStkStokKarti := TStkKart.Create(ADatabase);

  if ASiparis <> nil then
    Siparis := ASiparis;

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FTeklifDetayID := TFieldDB.Create('teklif_detay_id', ftInteger, 0, Self, '');
  FIrsaliyeDetayID := TFieldDB.Create('irsaliye_detay_id', ftInteger, 0, Self, '');
  FFaturaDetayID := TFieldDB.Create('fatura_detay_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, '');
  FStokAciklama := TFieldDB.Create('stok_aciklama', ftString, '', Self, '');
  FKullaniciAciklama := TFieldDB.Create('kullanici_aciklama', ftString, '', Self, '');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftString, '', Self, '');
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
  FGtipNo := TFieldDB.Create('gtip_no', ftString, '', Self, '');
  FEn := TFieldDB.Create('en', ftBCD, 0, Self, '');
  FBoy := TFieldDB.Create('boy', ftBCD, 0, Self, '');
  FYukseklik := TFieldDB.Create('yukseklik', ftBCD, 0, Self, '');
  FHacim := TFieldDB.Create('hacim', ftBCD, 0, Self, '');
  FNetAgirlik := TFieldDB.Create('net_agirlik', ftBCD, 0, Self, '');
  FBrutAgirlik := TFieldDB.Create('brut_agirlik', ftBCD, 0, Self, '');
  FKab := TFieldDB.Create('kab', ftInteger, 0, Self, '');

  PrepareTableRequiredValues;
end;

destructor TSatSiparisDetay.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  inherited;
end;

procedure TSatSiparisDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
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
      FGtipNo.QryName,
      FEn.QryName,
      FBoy.QryName,
      FYukseklik.QryName,
      FHacim.QryName,
      FNetAgirlik.QryName,
      FBrutAgirlik.QryName,
      FKab.QryName
    ], [
      addJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSatSiparisDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FGtipNo.QryName,
      FEn.QryName,
      FBoy.QryName,
      FYukseklik.QryName,
      FHacim.QryName,
      FNetAgirlik.QryName,
      FBrutAgirlik.QryName,
      FKab.QryName
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

procedure TSatSiparisDetay.DoInsert(APermissionControl: Boolean);
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
      FGtipNo.FieldName,
      FEn.FieldName,
      FBoy.FieldName,
      FYukseklik.FieldName,
      FHacim.FieldName,
      FNetAgirlik.FieldName,
      FBrutAgirlik.FieldName,
      FKab.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end
end;

procedure TSatSiparisDetay.DoUpdate(APermissionControl: Boolean);
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
      FGtipNo.FieldName,
      FEn.FieldName,
      FBoy.FieldName,
      FYukseklik.FieldName,
      FHacim.FieldName,
      FNetAgirlik.FieldName,
      FBrutAgirlik.FieldName,
      FKab.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSatSiparisDetay.Clone: TTable;
begin
  Result := TSatSiparisDetay.Create(Database, Self.Siparis);
  CloneClassContent(Self, Result);
end;

constructor TSatSiparis.Create(ADatabase: TDatabase);
begin
  TableName := 'sat_siparis';
  TableSourceCode := MODULE_SAT_SIP_KAYIT;
  inherited Create(ADatabase);

  FSysCountry := TSysUlke.Create(Database);
  FSysCity := TSysSehir.Create(Database);
  FTemsilci := TPrsPersonel.Create(Database);
  FFaturaTipi := TSetEinvFaturaTipi.Create(Database);
  FSetSiparisDurum := TSetSatSiparisDurum.Create(Database);
  FSetTeslimSekli := TSetEinvTeslimSekli.Create(Database);
  FSetOdemeSekli := TSetEinvOdemeSekli.Create(Database);
  FSetPaketTipi := TSetEinvPaketTipi.Create(Database);
  FSetNakliyeUcreti := TSetEinvTasimaUcreti.Create(Database);

  FTeklifID := TFieldDB.Create('teklif_id', ftInteger, 0, Self, 'Teklif ID');
  FIrsaliyeID := TFieldDB.Create('irsaliye_id', ftInteger, 0, Self, 'Ýrsaliye ID');
  FFaturaID := TFieldDB.Create('fatura_id', ftInteger, 0, Self, 'Fatura ID');
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, 'Tutar');
  FIskontoTutar := TFieldDB.Create('iskonto_tutar', ftBCD, 0, Self, 'Ýskonto Tutar');
  FAraToplam := TFieldDB.Create('ara_toplam', ftBCD, 0, Self, 'Ara Toplam');
  FKDVOran1 := TFieldDB.Create('kdv_oran1', ftInteger, 0, Self, 'KDV Oran 1');
  FKDVTutar1 := TFieldDB.Create('kdv_tutar1', ftBCD, 0, Self, 'KDV Tutar 1');
  FKDVOran2 := TFieldDB.Create('kdv_oran2', ftInteger, 0, Self, 'KDV Oran 2');
  FKDVTutar2 := TFieldDB.Create('kdv_tutar2', ftBCD, 0, Self, 'KDV Tutar 2');
  FKDVOran3 := TFieldDB.Create('kdv_oran3', ftInteger, 0, Self, 'KDV Oran 3');
  FKDVTutar3 := TFieldDB.Create('kdv_tutar3', ftBCD, 0, Self, 'KDV Tutar 3');
  FKDVOran4 := TFieldDB.Create('kdv_oran4', ftInteger, 0, Self, 'KDV Oran 4');
  FKDVTutar4 := TFieldDB.Create('kdv_tutar4', ftBCD, 0, Self, 'KDV Tutar 4');
  FKDVOran5 := TFieldDB.Create('kdv_oran5', ftInteger, 0, Self, 'KDV Oran 5');
  FKDVTutar5 := TFieldDB.Create('kdv_tutar5', ftBCD, 0, Self, 'KDV Tutar 5');
  FGenelToplam := TFieldDB.Create('genel_toplam', ftBCD, 0, Self, 'Genel Toplam');
  FIslemTipiID := TFieldDB.Create('islem_tipi_id', ftInteger, 0, Self, 'Ýþlem Tipi ID');
  FIslemTipi := TFieldDB.Create(FFaturaTipi.FaturaTipi.FieldName, FFaturaTipi.FaturaTipi.DataType, '', Self, 'Ýþlem Tipi');
  FSiparisNo := TFieldDB.Create('siparis_no', ftString, '', Self, 'Sipariþ No');
  FSiparisTarihi := TFieldDB.Create('siparis_tarihi', ftDateTime, 0, Self, 'Sipariþ Tarihi');
  FTeslimTarihi := TFieldDB.Create('teslim_tarihi', ftDateTime, 0, Self, 'Teslim Tarihi');
  FMusteriKodu := TFieldDB.Create('musteri_kodu', ftString, '', Self, 'Müþteri Kodu');
  FMusteriAdi := TFieldDB.Create('musteri_adi', ftString, '', Self, 'Müþteri Adý');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, 'Vergi Dairesi');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, 'Vergi No');
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self, 'Ülke ID');
  FUlke := TFieldDB.Create(FSysCountry.UlkeAdi.FieldName, FSysCountry.UlkeAdi.DataType, '', Self, 'Ülke');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'Þehir ID');
  FSehir := TFieldDB.Create(FSysCity.Sehir.FieldName, FSysCity.Sehir.DataType, '', Self, 'Þehir');
  FIlce := TFieldDB.Create('ilce', ftString, '', Self, 'Ýlçe');
  FMahalle := TFieldDB.Create('mahalle', ftString, '', Self, 'Mahalle');
  FCadde := TFieldDB.Create('cadde', ftString, '', Self, 'Cadde');
  FSokak := TFieldDB.Create('sokak', ftString, '', Self, 'Sokak');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftString, '', Self, 'Posta Kodu');
  FBinaAdi := TFieldDB.Create('bina_adi', ftString, '', Self, 'Bina Adý');
  FKapiNo := TFieldDB.Create('kapi_no', ftString, '', Self, 'Kapý No');
  FMusteriTemsilcisiID := TFieldDB.Create('musteri_temsilcisi_id', ftInteger, 0, Self, 'Müþteri Temsilci ID');
  FMusteriTemsilcisi := TFieldDB.Create(FTemsilci.AdSoyad.FieldName, FTemsilci.AdSoyad.DataType, FTemsilci.AdSoyad.Value, Self, FTemsilci.AdSoyad.Title);
  FMuhattapAd := TFieldDB.Create('muhattap_ad', ftString, '', Self, 'Muhattap Ad');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, 'Referans');
  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, 'Para Birimi');
  FDovizKuruUsd := TFieldDB.Create('doviz_kuru_usd', ftBCD, 0, Self, 'Döviz Kuru Usd');
  FDovizKuruEur := TFieldDB.Create('doviz_kuru_eur', ftBCD, 0, Self, 'Döviz Kuru Eur');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
  FProformaNo := TFieldDB.Create('proforma_no', ftInteger, 0, Self, 'Proforma No');
  FSiparisDurumID := TFieldDB.Create('siparis_durum_id', ftInteger, 0, Self, 'Sipariþ Durum ID');
  FSiparisDurum := TFieldDB.Create(FSetSiparisDurum.SiparisDurum.FieldName, FSetSiparisDurum.SiparisDurum.DataType, '', Self, 'Sipariþ Durum');
  FTeslimSekliID := TFieldDB.Create('teslim_sekli_id', ftInteger, 0, Self, 'Teslim Þekli ID');
  FTeslimSekli := TFieldDB.Create(FSetTeslimSekli.TeslimSekli.FieldName, FSetTeslimSekli.TeslimSekli.DataType, '', Self, 'Teslim Þekli');
  FOdemeSekliID := TFieldDB.Create('odeme_sekli_id', ftInteger, 0, Self, 'Ödeme Þekli ID');
  FOdemeSekli := TFieldDB.Create(FSetOdemeSekli.OdemeSekli.FieldName, FSetOdemeSekli.OdemeSekli.DataType, '', Self, 'Ödeme Þekli');
  FPaketTipiID := TFieldDB.Create('paket_tipi_id', ftInteger, 0, Self, 'Paket Tipi ID');
  FPaketTipi := TFieldDB.Create(FSetPaketTipi.PaketTipi.FieldName, FSetPaketTipi.PaketTipi.DataType, '', Self, 'Paket Tipi');
  FTasimaUcretiID := TFieldDB.Create('tasima_ucreti_id', ftInteger, 0, Self, 'Nakliye Ücreti ID');
  FTasimaUcreti := TFieldDB.Create(FSetNakliyeUcreti.TasimaUcreti.FieldName, FSetNakliyeUcreti.TasimaUcreti.DataType, '', Self, 'Nakliye Ücreti');

  PrepareTableRequiredValues;
end;

destructor TSatSiparis.Destroy;
begin
  FSysCountry.Free;
  FSysCity.Free;
  FTemsilci.Free;
  FFaturaTipi.Free;
  FSetSiparisDurum.Free;
  FSetTeslimSekli.Free;
  FSetOdemeSekli.Free;
  FSetPaketTipi.Free;
  FSetNakliyeUcreti.Free;

  inherited;
end;

function TSatSiparis.GetAddress: string;
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

procedure TSatSiparis.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FTeklifID.QryName,
      FIrsaliyeID.QryName,
      FFaturaID.QryName,
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
      FSiparisNo.QryName,
      FSiparisTarihi.QryName,
      FTeslimTarihi.QryName,
      FMusteriKodu.QryName,
      FMusteriAdi.QryName,
      FVergiDairesi.QryName,
      FUlkeID.QryName,
      addField(FSysCountry.TableName, FSysCountry.UlkeAdi.FieldName, FUlke.FieldName),
      FSehirID.QryName,
      addField(FSysCity.TableName, FSysCity.Sehir.FieldName, FSehir.FieldName),
      FIlce.QryName,
      FMahalle.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FPostaKodu.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FVergiNo.QryName,
      FMusteriTemsilcisiID.QryName,
      addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
      FMuhattapAd.QryName,
      FReferans.QryName,
      FParaBirimi.QryName,
      FDovizKuruUsd.QryName,
      FDovizKuruEur.QryName,
      FAciklama.QryName,
      FProformaNo.QryName,
      FSiparisDurumID.QryName,
      addField(FSetSiparisDurum.TableName, FSetSiparisDurum.SiparisDurum.FieldName, FSiparisDurum.FieldName),
      FTeslimSekliID.QryName,
      addField(FSetTeslimSekli.TableName, FSetTeslimSekli.Aciklama.FieldName, FTeslimSekli.FieldName),
      FOdemeSekliID.QryName,
      addField(FSetOdemeSekli.TableName, FSetOdemeSekli.OdemeSekli.FieldName, FOdemeSekli.FieldName),
      FPaketTipiID.QryName,
      addField(FSetPaketTipi.TableName, FSetPaketTipi.PaketTipi.FieldName, FPaketTipi.FieldName),
      FTasimaUcretiID.QryName,
      addField(FSetNakliyeUcreti.TableName, FSetNakliyeUcreti.TasimaUcreti.FieldName, FTasimaUcreti.FieldName)
    ], [
      addJoin(jtLeft, FFaturaTipi.TableName, FFaturaTipi.Id.FieldName, TableName, FIslemTipiID.FieldName),
      addJoin(jtLeft, FSysCountry.TableName, FSysCountry.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysCity.TableName, FSysCity.Id.FieldName, TableName, FSehirID.FieldName),
      addJoin(jtLeft, FTemsilci.TableName, FTemsilci.Id.FieldName, TableName, FMusteriTemsilcisiID.FieldName),
      addJoin(jtLeft, FSetSiparisDurum.TableName, FSetSiparisDurum.Id.FieldName, TableName, FSiparisDurumID.FieldName),
      addJoin(jtLeft, FSetTeslimSekli.TableName, FSetTeslimSekli.Id.FieldName, TableName, FTeslimSekliID.FieldName),
      addJoin(jtLeft, FSetOdemeSekli.TableName, FSetOdemeSekli.Id.FieldName, TableName, FOdemeSekliID.FieldName),
      addJoin(jtLeft, FSetPaketTipi.TableName, FSetPaketTipi.Id.FieldName, TableName, FPaketTipiID.FieldName),
      addJoin(jtLeft, FSetNakliyeUcreti.TableName, FSetNakliyeUcreti.Id.FieldName, TableName, FTasimaUcretiID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TSatSiparis.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FTeklifID.QryName,
      FIrsaliyeID.QryName,
      FFaturaID.QryName,
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
      FSiparisNo.QryName,
      FSiparisTarihi.QryName,
      FTeslimTarihi.QryName,
      FMusteriKodu.QryName,
      FMusteriAdi.QryName,
      FVergiDairesi.QryName,
      FUlkeID.QryName,
      addField(FSysCountry.TableName, FSysCountry.UlkeAdi.FieldName, FUlke.FieldName),
      FSehirID.QryName,
      addField(FSysCity.TableName, FSysCity.Sehir.FieldName, FSehir.FieldName),
      FIlce.QryName,
      FMahalle.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FPostaKodu.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FVergiNo.QryName,
      FMusteriTemsilcisiID.QryName,
      addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
      FMuhattapAd.QryName,
      FReferans.QryName,
      FParaBirimi.QryName,
      FDovizKuruUsd.QryName,
      FDovizKuruEur.QryName,
      FAciklama.QryName,
      FProformaNo.QryName,
      FSiparisDurumID.QryName,
      addField(FSetSiparisDurum.TableName, FSetSiparisDurum.SiparisDurum.FieldName, FSiparisDurum.FieldName),
      FTeslimSekliID.QryName,
      addField(FSetTeslimSekli.TableName, FSetTeslimSekli.Aciklama.FieldName, FTeslimSekli.FieldName),
      FOdemeSekliID.QryName,
      addField(FSetOdemeSekli.TableName, FSetOdemeSekli.OdemeSekli.FieldName, FOdemeSekli.FieldName),
      FPaketTipiID.QryName,
      addField(FSetPaketTipi.TableName, FSetPaketTipi.PaketTipi.FieldName, FPaketTipi.FieldName),
      FTasimaUcretiID.QryName,
      addField(FSetNakliyeUcreti.TableName, FSetNakliyeUcreti.TasimaUcreti.FieldName, FTasimaUcreti.FieldName)
    ], [
      addJoin(jtLeft, FFaturaTipi.TableName, FFaturaTipi.Id.FieldName, TableName, FIslemTipiID.FieldName),
      addJoin(jtLeft, FSysCountry.TableName, FSysCountry.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysCity.TableName, FSysCity.Id.FieldName, TableName, FSehirID.FieldName),
      addJoin(jtLeft, FTemsilci.TableName, FTemsilci.Id.FieldName, TableName, FMusteriTemsilcisiID.FieldName),
      addJoin(jtLeft, FSetSiparisDurum.TableName, FSetSiparisDurum.Id.FieldName, TableName, FSiparisDurumID.FieldName),
      addJoin(jtLeft, FSetTeslimSekli.TableName, FSetTeslimSekli.Id.FieldName, TableName, FTeslimSekliID.FieldName),
      addJoin(jtLeft, FSetOdemeSekli.TableName, FSetOdemeSekli.Id.FieldName, TableName, FOdemeSekliID.FieldName),
      addJoin(jtLeft, FSetPaketTipi.TableName, FSetPaketTipi.Id.FieldName, TableName, FPaketTipiID.FieldName),
      addJoin(jtLeft, FSetNakliyeUcreti.TableName, FSetNakliyeUcreti.Id.FieldName, TableName, FTasimaUcretiID.FieldName),
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
  end
end;

procedure TSatSiparis.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FTeklifID.FieldName,
      FIrsaliyeID.FieldName,
      FFaturaID.FieldName,
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
      FSiparisNo.FieldName,
      FSiparisTarihi.FieldName,
      FTeslimTarihi.FieldName,
      FMusteriKodu.FieldName,
      FMusteriAdi.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FUlkeID.FieldName,
      FSehirID.FieldName,
      FIlce.FieldName,
      FMahalle.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FPostaKodu.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FMusteriTemsilcisiID.FieldName,
      FMuhattapAd.FieldName,
      FReferans.FieldName,
      FParaBirimi.FieldName,
      FDovizKuruUsd.FieldName,
      FDovizKuruEur.FieldName,
      FAciklama.FieldName,
      FProformaNo.FieldName,
      FSiparisDurumID.FieldName,
      FTeslimSekliID.FieldName,
      FOdemeSekliID.FieldName,
      FPaketTipiID.FieldName,
      FTasimaUcretiID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end
end;

procedure TSatSiparis.PubRefreshHeader;
begin
  RefreshHeader;
end;

procedure TSatSiparis.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FTeklifID.FieldName,
      FIrsaliyeID.FieldName,
      FFaturaID.FieldName,
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
      FSiparisNo.FieldName,
      FSiparisTarihi.FieldName,
      FTeslimTarihi.FieldName,
      FMusteriKodu.FieldName,
      FMusteriAdi.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FUlkeID.FieldName,
      FSehirID.FieldName,
      FIlce.FieldName,
      FMahalle.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FPostaKodu.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FMusteriTemsilcisiID.FieldName,
      FMuhattapAd.FieldName,
      FReferans.FieldName,
      FParaBirimi.FieldName,
      FDovizKuruUsd.FieldName,
      FDovizKuruEur.FieldName,
      FAciklama.FieldName,
      FProformaNo.FieldName,
      FSiparisDurumID.FieldName,
      FTeslimSekliID.FieldName,
      FOdemeSekliID.FieldName,
      FPaketTipiID.FieldName,
      FTasimaUcretiID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSatSiparis.Clone: TTable;
begin
  Result := TSatSiparis.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

function TSatSiparis.getNewSiparisNo: string;
begin
  with GDataBase.NewQuery() do
  try
    SQL.Clear;
    SQL.Text := 'SELECT max(' + FSiparisNo.FieldName + '::::integer) as ' + FSiparisNo.FieldName + ' FROM ' + Self.TableName;
    Open;

    if (FieldByName(FSiparisNo.FieldName).IsNull) or (FieldByName(FSiparisNo.FieldName).AsString = '') then
      Result := '1' //1
    else
      Result := (FieldByName(FSiparisNo.FieldName).AsInteger+1).ToString;
  finally
    Free;
  end;
end;

procedure TSatSiparis.RefreshHeader;
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
    if (FKDVOran1.Value = 0) and (FKDVOran1.Value <> TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran1.Value := TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran2.Value = 0) and (FKDVOran2.Value <> TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran2.Value := TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran3.Value = 0) and (FKDVOran3.Value <> TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran3.Value := TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran4.Value = 0) and (FKDVOran4.Value <> TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran4.Value := TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran5.Value = 0) and (FKDVOran5.Value <> TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran5.Value := TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value
  end;

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    if FKDVOran1.Value = TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar1.Value := FKDVTutar1.Value + TSatSiparisDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran2.Value = TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar2.Value := FKDVTutar2.Value + TSatSiparisDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran3.Value = TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar3.Value := FKDVTutar3.Value + TSatSiparisDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran4.Value = TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar4.Value := FKDVTutar4.Value + TSatSiparisDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran5.Value = TSatSiparisDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar5.Value := FKDVTutar5.Value + TSatSiparisDetay(ListDetay[n1]).KdvTutar.Value;

    FTutar.Value         := FTutar.Value        + TSatSiparisDetay(ListDetay[n1]).Tutar.Value;
    FIskontoTutar.Value  := FIskontoTutar.Value + TSatSiparisDetay(ListDetay[n1]).IskontoTutar.Value;
    FAraToplam.Value     := FTutar.Value - FIskontoTutar.Value;
    FGenelToplam.Value   := FGenelToplam.Value  + TSatSiparisDetay(ListDetay[n1]).ToplamTutar.Value;
  end;
end;

procedure TSatSiparis.BusinessDelete(APermissionControl: Boolean);
var
  LTek: TSatTeklif;
begin
  LTek := TSatTeklif.Create(Database);
  try
    LTek.SelectToList(' AND ' + LTek.Id.QryName + '=' + VarToStr(FTeklifID.Value), False, False);

    Self.Delete;

    if LTek.List.Count = 1 then
    begin
      LTek.SiparisID.Value := 0;
      LTek.IsSiparislesti.Value := False;
      LTek.Update;
    end;
  finally
    FreeAndNil(LTek);
  end;
end;

procedure TSatSiparis.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
  LTek: TSatTeklif;
begin
  Self.Insert(True);
  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TSatSiparisDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
    TSatSiparisDetay(Self.ListDetay[n1]).Insert(True);
  end;

  LTek := TSatTeklif.Create(Database);
  try
    LTek.SelectToList(' AND ' + LTek.Id.QryName + '=' + VarToStr(FTeklifID.Value), False, False);
    if LTek.List.Count = 1 then
    begin
      LTek.SiparisID.Value := Self.Id.Value;
      LTek.IsSiparislesti.Value := True;
      LTek.Update();
    end;
  finally
    LTek.Free;
  end;
end;

procedure TSatSiparis.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  n1, n2: Integer;
  LDetay: TSatSiparisDetay;
  ASiparis: TSatSiparis;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);

  for n1 := 0 to List.Count-1 do
  begin
    ASiparis := TSatSiparis(List[n1]);

    LDetay := TSatSiparisDetay.Create(Database, ASiparis);
    try
      LDetay.SelectToList(' AND ' + LDetay.HeaderID.QryName + '=' + ASiparis.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LDetay.List.Count-1 do
        ASiparis.AddDetay(TSatSiparisDetay(LDetay.List[n2]).Clone, n2 = LDetay.List.Count-1);
    finally
      LDetay.Free;
    end;
  end;
end;

procedure TSatSiparis.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TSatSiparisDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    if TSatSiparisDetay(Self.ListDetay[n1]).Id.Value > 0 then
    begin
      TSatSiparisDetay(Self.ListDetay[n1]).Update(False);
    end
    else
    begin
      TSatSiparisDetay(Self.ListDetay[n1]).Insert(False);
    end;
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count-1 do
    if TSatSiparisDetay(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TSatSiparisDetay(Self.ListSilinenDetay[n1]).Delete(False);
end;

procedure TSatSiparis.AddDetay(ATable: TTable; ALastItem: Boolean = False);
begin
  TSatSiparisDetay(ATable).Siparis := Self;
  Self.ListDetay.Add(ATable);
  if ALastItem then RefreshHeader;
end;

procedure TSatSiparis.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TSatSiparis.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
  if CompareValue(TSatSiparisDetay(ATable).Miktar.Value, 0, EPSILON) = EqualsValue then
    raise Exception.Create('Sýfýr miktar ile kayýt yapýlamaz!');
end;

procedure TSatSiparis.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

end.




