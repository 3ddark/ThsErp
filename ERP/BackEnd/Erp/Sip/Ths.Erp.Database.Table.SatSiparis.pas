unit Ths.Erp.Database.Table.SatSiparis;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Math,
  Data.DB,
  System.Generics.Collections,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.TableDetailed,
  Ths.Erp.Database.Table.SysOndalikHane,
  Ths.Erp.Database.Table.PrsPersonel,
  Ths.Erp.Database.Table.StkStokKarti,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SetEInvFaturaTipi,
  Ths.Erp.Database.Table.SeTSatSiparisDurum,
  Ths.Erp.Database.Table.SetEinvTeslimSekli,
  Ths.Erp.Database.Table.SetEinvOdemeSekli,
  Ths.Erp.Database.Table.SetEinvPaketTipi,
  Ths.Erp.Database.Table.SetEinvTasimaUcreti;

const
  SS_MAL_KODU            = 1;
  SS_MAL_ADI             = 2;
  SS_MIKTAR              = 3;
  SS_BIRIM               = 4;
  SS_KDV_ORANI           = 5;
  SS_FIYAT               = 6;
  SS_ISKONTO_ORANI       = 7;
  SS_NET_FIYAT           = 8;
  SS_TUTAR               = 9;
  SS_NET_TUTAR           = 10;
  SS_REFERANS            = 11;

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

    FStok: TStkStokKarti;
    constructor Create(ADatabase: TDatabase; ASiparis: TSatSiparis = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Siparis: TSatSiparis;
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

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
    FDovizKuru: TFieldDB;
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
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
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
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    function getNewSiparisNo: string;
    function GetAddress: string;
    function ValidateDetay(ATable: TTable): Boolean; override;

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
    Property DovizKuru: TFieldDB read FDovizKuru write FDovizKuru;
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
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SatTeklif;

constructor TSatSiparisDetay.Create(ADatabase: TDatabase; ASiparis: TSatSiparis);
begin
  TableName := 'sat_siparis_detay';
  TableSourceCode := MODULE_SAT_SIP_KAYIT;
  inherited Create(ADatabase);

  FStok := TStkStokKarti.Create(ADatabase);

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
  FStokResim := TFieldDB.Create(FStok.StokResim.FieldName, FStok.StokResim.DataType, FStok.StokResim.Value, Self, 'Stok Resim');

  PrepareTableRequiredValues;
end;

destructor TSatSiparisDetay.Destroy;
begin
  FreeAndNil(FStok);
  inherited;
end;

procedure TSatSiparisDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FTeklifDetayID.FieldName,
        TableName + '.' + FIrsaliyeDetayID.FieldName,
        TableName + '.' + FFaturaDetayID.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FStokAciklama.FieldName,
        TableName + '.' + FKullaniciAciklama.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FOlcuBirimi.FieldName,
        TableName + '.' + FIskontoOrani.FieldName,
        TableName + '.' + FKdvOrani.FieldName,
        TableName + '.' + FFiyat.FieldName,
        TableName + '.' + FNetFiyat.FieldName,
        TableName + '.' + FTutar.FieldName,
        TableName + '.' + FIskontoTutar.FieldName,
        TableName + '.' + FNetTutar.FieldName,
        TableName + '.' + FKdvTutar.FieldName,
        TableName + '.' + FToplamTutar.FieldName,
        TableName + '.' + FIsAnaUrun.FieldName,
        TableName + '.' + FReferansAnaUrunID.FieldName,
        TableName + '.' + FGtipNo.FieldName,
        TableName + '.' + FEn.FieldName,
        TableName + '.' + FBoy.FieldName,
        TableName + '.' + FYukseklik.FieldName,
        TableName + '.' + FHacim.FieldName,
        TableName + '.' + FNetAgirlik.FieldName,
        TableName + '.' + FBrutAgirlik.FieldName,
        TableName + '.' + FKab.FieldName,
        addField(FStok.TableName, FStok.StokResim.FieldName, FStokResim.FieldName)
      ], [
        addJoin(jtLeft, FStok.TableName, FStok.StokKodu.FieldName, TableName, FStokKodu.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSatSiparisDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FTeklifDetayID.FieldName,
        TableName + '.' + FIrsaliyeDetayID.FieldName,
        TableName + '.' + FFaturaDetayID.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FStokAciklama.FieldName,
        TableName + '.' + FKullaniciAciklama.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FOlcuBirimi.FieldName,
        TableName + '.' + FIskontoOrani.FieldName,
        TableName + '.' + FKdvOrani.FieldName,
        TableName + '.' + FFiyat.FieldName,
        TableName + '.' + FNetFiyat.FieldName,
        TableName + '.' + FTutar.FieldName,
        TableName + '.' + FIskontoTutar.FieldName,
        TableName + '.' + FNetTutar.FieldName,
        TableName + '.' + FKdvTutar.FieldName,
        TableName + '.' + FToplamTutar.FieldName,
        TableName + '.' + FIsAnaUrun.FieldName,
        TableName + '.' + FReferansAnaUrunID.FieldName,
        TableName + '.' + FGtipNo.FieldName,
        TableName + '.' + FEn.FieldName,
        TableName + '.' + FBoy.FieldName,
        TableName + '.' + FYukseklik.FieldName,
        TableName + '.' + FHacim.FieldName,
        TableName + '.' + FNetAgirlik.FieldName,
        TableName + '.' + FBrutAgirlik.FieldName,
        TableName + '.' + FKab.FieldName,
        addField(FStok.TableName, FStok.StokResim.FieldName, FStokResim.FieldName)
      ], [
        addJoin(jtLeft, FStok.TableName, FStok.StokKodu.FieldName, TableName, FStokKodu.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSatSiparisDetay.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
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

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSatSiparisDetay.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
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

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
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
  FSehir := TFieldDB.Create(FSysCity.SehirAdi.FieldName, FSysCity.SehirAdi.DataType, '', Self, 'Þehir');
  FIlce := TFieldDB.Create('ilce', ftString, '', Self, 'Ýlçe');
  FMahalle := TFieldDB.Create('mahalle', ftString, '', Self, 'Mahalle');
  FCadde := TFieldDB.Create('cadde', ftString, '', Self, 'Cadde');
  FSokak := TFieldDB.Create('sokak', ftString, '', Self, 'Sokak');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftString, '', Self, 'Posta Kodu');
  FBinaAdi := TFieldDB.Create('bina_adi', ftString, '', Self, 'Bina Adý');
  FKapiNo := TFieldDB.Create('kapi_no', ftString, '', Self, 'Kapý No');
  FMusteriTemsilcisiID := TFieldDB.Create('musteri_temsilcisi_id', ftInteger, 0, Self, 'Müþteri Temsilci ID');
  FMusteriTemsilcisi := TFieldDB.Create(FTemsilci.AdSoyad.FieldName, FTemsilci.AdSoyad.DataType, '', Self, 'Müþteri Temsilci');
  FMuhattapAd := TFieldDB.Create('muhattap_ad', ftString, '', Self, 'Muhattap Ad');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, 'Referans');
  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, 'Para Birimi');
  FDovizKuru := TFieldDB.Create('doviz_kuru', ftBCD, 0, Self, 'Döviz Kuru');
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
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTeklifID.FieldName,
        TableName + '.' + FIrsaliyeID.FieldName,
        TableName + '.' + FFaturaID.FieldName,
        TableName + '.' + FTutar.FieldName,
        TableName + '.' + FIskontoTutar.FieldName,
        TableName + '.' + FAraToplam.FieldName,
        TableName + '.' + FKDVOran1.FieldName,
        TableName + '.' + FKDVTutar1.FieldName,
        TableName + '.' + FKDVOran2.FieldName,
        TableName + '.' + FKDVTutar2.FieldName,
        TableName + '.' + FKDVOran3.FieldName,
        TableName + '.' + FKDVTutar3.FieldName,
        TableName + '.' + FKDVOran4.FieldName,
        TableName + '.' + FKDVTutar4.FieldName,
        TableName + '.' + FKDVOran5.FieldName,
        TableName + '.' + FKDVTutar5.FieldName,
        TableName + '.' + FGenelToplam.FieldName,
        TableName + '.' + FIslemTipiID.FieldName,
        addField(FFaturaTipi.TableName, FFaturaTipi.FaturaTipi.FieldName, FIslemTipi.FieldName),
        TableName + '.' + FSiparisNo.FieldName,
        TableName + '.' + FSiparisTarihi.FieldName,
        TableName + '.' + FTeslimTarihi.FieldName,
        TableName + '.' + FMusteriKodu.FieldName,
        TableName + '.' + FMusteriAdi.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FUlkeID.FieldName,
        addField(FSysCountry.TableName, FSysCountry.UlkeAdi.FieldName, FUlke.FieldName),
        TableName + '.' + FSehirID.FieldName,
        addField(FSysCity.TableName, FSysCity.SehirAdi.FieldName, FSehir.FieldName),
        TableName + '.' + FIlce.FieldName,
        TableName + '.' + FMahalle.FieldName,
        TableName + '.' + FCadde.FieldName,
        TableName + '.' + FSokak.FieldName,
        TableName + '.' + FPostaKodu.FieldName,
        TableName + '.' + FBinaAdi.FieldName,
        TableName + '.' + FKapiNo.FieldName,
        TableName + '.' + FVergiNo.FieldName,
        TableName + '.' + FMusteriTemsilcisiID.FieldName,
        addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
        TableName + '.' + FMuhattapAd.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FDovizKuru.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FProformaNo.FieldName,
        TableName + '.' + FSiparisDurumID.FieldName,
        addField(FSetSiparisDurum.TableName, FSetSiparisDurum.SiparisDurum.FieldName, FSiparisDurum.FieldName),
        TableName + '.' + FTeslimSekliID.FieldName,
        addField(FSetTeslimSekli.TableName, FSetTeslimSekli.Aciklama.FieldName, FTeslimSekli.FieldName),
        TableName + '.' + FOdemeSekliID.FieldName,
        addField(FSetOdemeSekli.TableName, FSetOdemeSekli.OdemeSekli.FieldName, FOdemeSekli.FieldName),
        TableName + '.' + FPaketTipiID.FieldName,
        addField(FSetPaketTipi.TableName, FSetPaketTipi.PaketTipi.FieldName, FPaketTipi.FieldName),
        TableName + '.' + FTasimaUcretiID.FieldName,
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
      Active := True;
    end;
  end;
end;

procedure TSatSiparis.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTeklifID.FieldName,
        TableName + '.' + FIrsaliyeID.FieldName,
        TableName + '.' + FFaturaID.FieldName,
        TableName + '.' + FTutar.FieldName,
        TableName + '.' + FIskontoTutar.FieldName,
        TableName + '.' + FAraToplam.FieldName,
        TableName + '.' + FKDVOran1.FieldName,
        TableName + '.' + FKDVTutar1.FieldName,
        TableName + '.' + FKDVOran2.FieldName,
        TableName + '.' + FKDVTutar2.FieldName,
        TableName + '.' + FKDVOran3.FieldName,
        TableName + '.' + FKDVTutar3.FieldName,
        TableName + '.' + FKDVOran4.FieldName,
        TableName + '.' + FKDVTutar4.FieldName,
        TableName + '.' + FKDVOran5.FieldName,
        TableName + '.' + FKDVTutar5.FieldName,
        TableName + '.' + FGenelToplam.FieldName,
        TableName + '.' + FIslemTipiID.FieldName,
        addField(FFaturaTipi.TableName, FFaturaTipi.FaturaTipi.FieldName, FIslemTipi.FieldName),
        TableName + '.' + FSiparisNo.FieldName,
        TableName + '.' + FSiparisTarihi.FieldName,
        TableName + '.' + FTeslimTarihi.FieldName,
        TableName + '.' + FMusteriKodu.FieldName,
        TableName + '.' + FMusteriAdi.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FUlkeID.FieldName,
        addField(FSysCountry.TableName, FSysCountry.UlkeAdi.FieldName, FUlke.FieldName),
        TableName + '.' + FSehirID.FieldName,
        addField(FSysCity.TableName, FSysCity.SehirAdi.FieldName, FSehir.FieldName),
        TableName + '.' + FIlce.FieldName,
        TableName + '.' + FMahalle.FieldName,
        TableName + '.' + FCadde.FieldName,
        TableName + '.' + FSokak.FieldName,
        TableName + '.' + FPostaKodu.FieldName,
        TableName + '.' + FBinaAdi.FieldName,
        TableName + '.' + FKapiNo.FieldName,
        TableName + '.' + FVergiNo.FieldName,
        TableName + '.' + FMusteriTemsilcisiID.FieldName,
        addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
        TableName + '.' + FMuhattapAd.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FDovizKuru.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FProformaNo.FieldName,
        TableName + '.' + FSiparisDurumID.FieldName,
        addField(FSetSiparisDurum.TableName, FSetSiparisDurum.SiparisDurum.FieldName, FSiparisDurum.FieldName),
        TableName + '.' + FTeslimSekliID.FieldName,
        addField(FSetTeslimSekli.TableName, FSetTeslimSekli.Aciklama.FieldName, FTeslimSekli.FieldName),
        TableName + '.' + FOdemeSekliID.FieldName,
        addField(FSetOdemeSekli.TableName, FSetOdemeSekli.OdemeSekli.FieldName, FOdemeSekli.FieldName),
        TableName + '.' + FPaketTipiID.FieldName,
        addField(FSetPaketTipi.TableName, FSetPaketTipi.PaketTipi.FieldName, FPaketTipi.FieldName),
        TableName + '.' + FTasimaUcretiID.FieldName,
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
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSatSiparis.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
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
        FDovizKuru.FieldName,
        FAciklama.FieldName,
        FProformaNo.FieldName,
        FSiparisDurumID.FieldName,
        FTeslimSekliID.FieldName,
        FOdemeSekliID.FieldName,
        FPaketTipiID.FieldName,
        FTasimaUcretiID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;

      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSatSiparis.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
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
        FDovizKuru.FieldName,
        FAciklama.FieldName,
        FProformaNo.FieldName,
        FSiparisDurumID.FieldName,
        FTeslimSekliID.FieldName,
        FOdemeSekliID.FieldName,
        FPaketTipiID.FieldName,
        FTasimaUcretiID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
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
    SQL.Text := 'SELECT max(' + FSiparisNo.FieldName + '::integer) as ' + FSiparisNo.FieldName + ' FROM ' + Self.TableName;
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
    LTek.SelectToList(' AND ' + LTek.TableName + '.' + LTek.Id.FieldName + '=' + VarToStr(FTeklifID.Value), False, False);

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

procedure TSatSiparis.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  n1, vID: Integer;
  LTek: TSatTeklif;
begin
  Self.Insert(vID, True);
  Self.Id.Value := vID;
  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TSatSiparisDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
    TSatSiparisDetay(Self.ListDetay[n1]).Insert(vID, True);
  end;

  LTek := TSatTeklif.Create(Database);
  try
    LTek.SelectToList(' AND ' + LTek.TableName + '.' + LTek.Id.FieldName + '=' + VarToStr(FTeklifID.Value), False, False);
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
  n1, vID: Integer;
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
      TSatSiparisDetay(Self.ListDetay[n1]).Insert(vID, False);
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
