unit Ths.Erp.Database.Table.SatTeklif;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.TableDetailed,
  Ths.Erp.Database.Table.SysOndalikHane,
  Ths.Erp.Database.Table.PrsPersonel,
  Ths.Erp.Database.Table.StkStokKarti,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SetEInvFaturaTipi,
  Ths.Erp.Database.Table.SetEinvTeslimSekli,
  Ths.Erp.Database.Table.SetEinvOdemeSekli,
  Ths.Erp.Database.Table.SetEinvPaketTipi,
  Ths.Erp.Database.Table.SetEinvTasimaUcreti,
  Ths.Erp.Database.Table.SetSatTeklifDurum,
  Ths.Erp.Database.Table.SetSatSiparisDurum,
  Ths.Erp.Database.Table.SatSiparis;

const
  ST_MAL_KODU            = 1;
  ST_MAL_ADI             = 2;
  ST_MIKTAR              = 3;
  ST_BIRIM               = 4;
  ST_KDV_ORANI           = 5;
  ST_FIYAT               = 6;
  ST_ISKONTO_ORANI       = 7;
  ST_NET_FIYAT           = 8;
  ST_TUTAR               = 9;
  ST_NET_TUTAR           = 10;
  ST_REFERANS            = 11;

type
  TSatTeklif = class;

  TSatTeklifDetay = class(TTable)
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
    FAnaUrunID: TFieldDB;
    FReferansAnaUrunID: TFieldDB;
    FVergiKodu: TFieldDB;
    FVergiMuafiyetKodu: TFieldDB;
    FDigerVergiKodu: TFieldDB;
    FGtipNo: TFieldDB;
    FStokResim: TFieldDB;
  published
    FStok: TStkStokKarti;
    constructor Create(ADatabase: TDatabase; ATeklif: TSatTeklif = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Teklif: TSatTeklif;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    function ToSiparisDetay: TSatSiparisDetay;

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
    Property AnaUrunID: TFieldDB read FAnaUrunID write FAnaUrunID;
    Property ReferansAnaUrunID: TFieldDB read FReferansAnaUrunID write FReferansAnaUrunID;
    Property VergiKodu: TFieldDB read FVergiKodu write FVergiKodu;
    Property VergiMuafiyetKodu: TFieldDB read FVergiMuafiyetKodu write FVergiMuafiyetKodu;
    Property DigerVergiKodu: TFieldDB read FDigerVergiKodu write FDigerVergiKodu;
    Property GtipNo: TFieldDB read FGtipNo write FGtipNo;
    Property StokResim: TFieldDB read FStokResim write FStokResim;
  end;

  TSatTeklif = class(TTableDetailed)
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
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FPostaKodu: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FMusteriTemsilcisiID: TFieldDB;
    FMusteriTemsilcisi: TFieldDB;
    FMuhattapAd: TFieldDB;
    FMuhattapTelefon: TFieldDB;
    FReferans: TFieldDB;
    FParaBirimi: TFieldDB;
    FDolarKur: TFieldDB;
    FEuroKur: TFieldDB;
    FAciklama: TFieldDB;
    FProformaNo: TFieldDB;
    FTeslimSekliID: TFieldDB;
    FTeslimSekli: TFieldDB;
    FOdemeSekliID: TFieldDB;
    FOdemeSekli: TFieldDB;
    FPaketTipiID: TFieldDB;
    FPaketTipi: TFieldDB;
    FTasimaUcretiID: TFieldDB;
    FTasimaUcreti: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
    function ValidateDetay(pTable: TTable): Boolean; override;
  published
    FFaturaTipi: TSetEinvFaturaTipi;
    FSysCountry: TSysUlke;
    FSysCity: TSysSehir;
    FTemsilci: TPrsPersonel;
    FSetTeklifDurum: TSetSatTeklifDurum;
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

    function ToSiparis: TSatSiparis;

    procedure AddDetay(ATable: TTable); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    function CopyDetail(ASrc: TSatTeklifDetay): TSatTeklifDetay;

    function GetAddress: string;

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
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property MusteriTemsilcisiID: TFieldDB read FMusteriTemsilcisiID write FMusteriTemsilcisiID;
    Property MusteriTemsilcisi: TFieldDB read FMusteriTemsilcisi write FMusteriTemsilcisi;
    Property MuhattapAd: TFieldDB read FMuhattapAd write FMuhattapAd;
    Property MuhattapTelefon: TFieldDB read FMuhattapTelefon write FMuhattapTelefon;
    Property Referans: TFieldDB read FReferans write FReferans;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property DolarKur: TFieldDB read FDolarKur write FDolarKur;
    Property EuroKur: TFieldDB read FEuroKur write FEuroKur;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property ProformaNo: TFieldDB read FProformaNo write FProformaNo;
    Property TeslimSekliID: TFieldDB read FTeslimSekliID write FTeslimSekliID;
    Property TeslimSekli: TFieldDB read FTeslimSekli write FTeslimSekli;
    Property OdemeSekliID: TFieldDB read FOdemeSekliID write FOdemeSekliID;
    Property OdemeSekli: TFieldDB read FOdemeSekli write FOdemeSekli;
    Property PaketTipiID: TFieldDB read FPaketTipiID write FPaketTipiID;
    Property PaketTipi: TFieldDB read FPaketTipi write FPaketTipi;
    Property TasimaUcretiID: TFieldDB read FTasimaUcretiID write FTasimaUcretiID;
    Property TasimaUcreti: TFieldDB read FTasimaUcreti write FTasimaUcreti;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSatTeklifDetay.Create(ADatabase: TDatabase; ATeklif: TSatTeklif);
begin
  TableName := 'sat_teklif_detay';
  TableSourceCode := MODULE_SAT_TEK_KAYIT;
  inherited Create(ADatabase);

  FStok := TStkStokKarti.Create(ADatabase);

  if ATeklif <> nil then
    Teklif := ATeklif;

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FTeklifDetayID := TFieldDB.Create('siparis_detay_id', ftInteger, 0, Self, '');
  FIrsaliyeDetayID := TFieldDB.Create('irsaliye_detay_id', ftInteger, 0, Self, '');
  FFaturaDetayID := TFieldDB.Create('fatura_detay_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, '');
  FStokAciklama := TFieldDB.Create('stok_aciklama', ftString, '', Self, '');
  FKullaniciAciklama := TFieldDB.Create('kullanici_aciklama', ftString, '', Self, '');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftString, '', Self, '');
  FIskontoOrani := TFieldDB.Create('iskonto_orani', ftFloat, 0, Self, '');
  FKdvOrani := TFieldDB.Create('kdv_orani', ftFloat, 0, Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftFloat, 0, Self, '');
  FNetFiyat := TFieldDB.Create('net_fiyat', ftFloat, 0, Self, '');
  FTutar := TFieldDB.Create('tutar', ftFloat, 0, Self, '');
  FIskontoTutar := TFieldDB.Create('iskonto_tutar', ftFloat, 0, Self, '');
  FNetTutar := TFieldDB.Create('net_tutar', ftFloat, 0, Self, '');
  FKdvTutar := TFieldDB.Create('kdv_tutar', ftFloat, 0, Self, '');
  FToplamTutar := TFieldDB.Create('toplam_tutar', ftFloat, 0, Self, '');
  FIsAnaUrun := TFieldDB.Create('is_ana_urun', ftBoolean, 0, Self, '');
  FAnaUrunID := TFieldDB.Create('ana_urun_id', ftInteger, 0, Self, '');
  FReferansAnaUrunID := TFieldDB.Create('referans_ana_urun_id', ftInteger, 0, Self, '');
  FVergiKodu := TFieldDB.Create('vergi_kodu', ftString, '', Self, '');
  FVergiMuafiyetKodu := TFieldDB.Create('vergi_muafiyet_kodu', ftString, '', Self, '');
  FDigerVergiKodu := TFieldDB.Create('diger_vergi_kodu', ftString, '', Self, '');
  FGtipNo := TFieldDB.Create('gtip_no', ftString, '', Self, '');
  FStokResim := TFieldDB.Create(FStok.StokResim.FieldName, FStok.StokResim.DataType, FStok.StokResim.Value, Self, 'Stok Resim');
end;

destructor TSatTeklifDetay.Destroy;
begin
  FStok.Free;
  inherited;
end;

procedure TSatTeklifDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
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
        TableName + '.' + FAnaUrunID.FieldName,
        TableName + '.' + FReferansAnaUrunID.FieldName,
        TableName + '.' + FVergiKodu.FieldName,
        TableName + '.' + FVergiMuafiyetKodu.FieldName,
        TableName + '.' + FDigerVergiKodu.FieldName,
        TableName + '.' + FGtipNo.FieldName,
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

procedure TSatTeklifDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FAnaUrunID.FieldName,
        TableName + '.' + FReferansAnaUrunID.FieldName,
        TableName + '.' + FVergiKodu.FieldName,
        TableName + '.' + FVergiMuafiyetKodu.FieldName,
        TableName + '.' + FDigerVergiKodu.FieldName,
        TableName + '.' + FGtipNo.FieldName,
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

function TSatTeklifDetay.ToSiparisDetay: TSatSiparisDetay;
var
  LStok: TStkStokKarti;
begin
  Result := TSatSiparisDetay.Create(Database);
  LStok := TStkStokKarti.Create(Database);
  try
    LStok.SelectToList(' AND ' + LStok.TableName + '.' + LStok.StokKodu.FieldName + '=' + QuotedStr(FStokKodu.Value), False, False);

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
    Result.VergiKodu.Value := FVergiKodu.Value;
    Result.VergiMuafiyetKodu.Value := FVergiMuafiyetKodu.Value;
    Result.DigerVergiKodu.Value := FDigerVergiKodu.Value;
    Result.GtipNo.Value := FGtipNo.Value;

    if LStok.List.Count = 1 then
    begin
      //stok kart� ve sipari� detay mm
      Result.En.Value := LStok.En.Value;
      Result.Boy.Value := LStok.Boy.Value;
      Result.Yukseklik.Value := LStok.Yukseklik.Value;
      //stok kart� ve sipari� detay kg birimi
      Result.NetAgirlik.Value := LStok.Agirlik.Value;
      Result.BrutAgirlik.Value := Result.NetAgirlik.Value;
    end;
  finally
    LStok.Free;
  end;
end;

procedure TSatTeklifDetay.Insert(out AID: Integer; APermissionControl: Boolean);
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
        FAnaUrunID.FieldName,
        FReferansAnaUrunID.FieldName,
        FVergiKodu.FieldName,
        FVergiMuafiyetKodu.FieldName,
        FDigerVergiKodu.FieldName,
        FGtipNo.FieldName
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

procedure TSatTeklifDetay.Update(APermissionControl: Boolean);
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
        FAnaUrunID.FieldName,
        FReferansAnaUrunID.FieldName,
        FVergiKodu.FieldName,
        FVergiMuafiyetKodu.FieldName,
        FDigerVergiKodu.FieldName,
        FGtipNo.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSatTeklifDetay.Clone: TTable;
begin
  Result := TSatTeklifDetay.Create(Database, Self.Teklif);
  CloneClassContent(Self, Result);
end;

constructor TSatTeklif.Create(ADatabase: TDatabase);
begin
  TableName := 'sat_teklif';
  TableSourceCode := MODULE_SAT_TEK_KAYIT;
  inherited Create(ADatabase);

  FSysCountry := TSysUlke.Create(Database);
  FSysCity := TSysSehir.Create(Database);
  FTemsilci := TPrsPersonel.Create(Database);
  FFaturaTipi := TSetEinvFaturaTipi.Create(Database);
  FSetTeklifDurum := TSetSatTeklifDurum.Create(Database);
  FSetTeslimSekli := TSetEinvTeslimSekli.Create(Database);
  FSetOdemeSekli := TSetEinvOdemeSekli.Create(Database);
  FSetPaketTipi := TSetEinvPaketTipi.Create(Database);
  FSetNakliyeUcreti := TSetEinvTasimaUcreti.Create(Database);

  FSiparisID := TFieldDB.Create('siparis_id', ftInteger, 0, Self, 'Sipari� ID');
  FIrsaliyeID := TFieldDB.Create('irsaliye_id', ftInteger, 0, Self, '�rsaliye ID');
  FFaturaID := TFieldDB.Create('fatura_id', ftInteger, 0, Self, 'Fatura ID');
  FIsSiparislesti := TFieldDB.Create('is_siparislesti', ftBoolean, False, Self, 'Sipari�le�ti');
  FTutar := TFieldDB.Create('tutar', ftFloat, 0, Self, 'Tutar');
  FIskontoTutar := TFieldDB.Create('iskonto_tutar', ftFloat, 0, Self, '�sk.Tutar');
  FAraToplam := TFieldDB.Create('ara_toplam', ftFloat, 0, Self, 'Ara Toplam');
  FKDVOran1 := TFieldDB.Create('kdv_oran1', ftFloat, 0, Self, 'KDV Oran1');
  FKDVTutar1 := TFieldDB.Create('kdv_tutar1', ftFloat, 0, Self, 'KDV Tutar1');
  FKDVOran2 := TFieldDB.Create('kdv_oran2', ftFloat, 0, Self, 'KDV Oran2');
  FKDVTutar2 := TFieldDB.Create('kdv_tutar2', ftFloat, 0, Self, 'KDV Tutar2');
  FKDVOran3 := TFieldDB.Create('kdv_oran3', ftFloat, 0, Self, 'KDV Oran3');
  FKDVTutar3 := TFieldDB.Create('kdv_tutar3', ftFloat, 0, Self, 'KDV Tutar3');
  FKDVOran4 := TFieldDB.Create('kdv_oran4', ftFloat, 0, Self, 'KDV Oran4');
  FKDVTutar4 := TFieldDB.Create('kdv_tutar4', ftFloat, 0, Self, 'KDV Tutar4');
  FKDVOran5 := TFieldDB.Create('kdv_oran5', ftFloat, 0, Self, 'KDV Oran5');
  FKDVTutar5 := TFieldDB.Create('kdv_tutar5', ftFloat, 0, Self, 'KDV Tutar5');
  FGenelToplam := TFieldDB.Create('genel_toplam', ftFloat, 0, Self, 'Genel Toplam');
  FIslemTipiID := TFieldDB.Create('islem_tipi_id', ftInteger, 0, Self, '��lem Tipi ID');
  FIslemTipi := TFieldDB.Create(FFaturaTipi.FaturaTipi.FieldName, FFaturaTipi.FaturaTipi.DataType, '', Self, '��lem Tipi');
  FTeklifNo := TFieldDB.Create('teklif_no', ftString, '', Self, 'Teklif No');
  FTeklifTarihi := TFieldDB.Create('teklif_tarihi', ftDateTime, 0, Self, 'Teklif Tarihi');
  FGecerlilikTarihi := TFieldDB.Create('gecerlilik_tarihi', ftDateTime, 0, Self, 'Ge�erlilik Tarihi');
  FMusteriKodu := TFieldDB.Create('musteri_kodu', ftString, '', Self, 'M��teri Kodu');
  FMusteriAdi := TFieldDB.Create('musteri_adi', ftString, '', Self, 'M��teri Ad�');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, 'Vergi Dairesi');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, 'Vergi No');
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self, '�lke ID');
  FUlke := TFieldDB.Create(FSysCountry.UlkeAdi.FieldName, FSysCountry.UlkeAdi.DataType, '', Self, '�lke Ad�');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, '�ehir ID');
  FSehir := TFieldDB.Create(FSysCity.SehirAdi.FieldName, FSysCity.SehirAdi.DataType, '', Self, '�ehir');
  FIlce := TFieldDB.Create('ilce', ftString, '', Self, '�l�e');
  FMahalle := TFieldDB.Create('mahalle', ftString, '', Self, 'Mahalle');
  FCadde := TFieldDB.Create('cadde', ftString, '', Self, 'Cadde');
  FSokak := TFieldDB.Create('sokak', ftString, '', Self, 'Sokak');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftString, '', Self, 'Posta Kodu');
  FBinaAdi := TFieldDB.Create('bina_adi', ftString, '', Self, 'Bina Ad�');
  FKapiNo := TFieldDB.Create('kapi_no', ftString, '', Self, 'Kap� No');
  FMusteriTemsilcisiID := TFieldDB.Create('musteri_temsilcisi_id', ftInteger, 0, Self, 'M��teri Temsilcisi ID');
  FMusteriTemsilcisi := TFieldDB.Create(FTemsilci.AdSoyad.FieldName, FTemsilci.AdSoyad.DataType, '', Self, 'M��teri Temsilcisi');
  FMuhattapAd := TFieldDB.Create('muhattap_ad', ftString, '', Self, 'Muhattap Ad');
  FMuhattapTelefon := TFieldDB.Create('muhattap_telefon', ftString, '', Self, 'Muhattap Telefon');
  FReferans := TFieldDB.Create('referans', ftString, '', Self, 'Referans');
  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, 'Para');
  FDolarKur := TFieldDB.Create('kur_dolar', ftFloat, 0, Self, 'Kur $');
  FEuroKur := TFieldDB.Create('kur_euro', ftFloat, 0, Self, 'Kur �');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'A��klama');
  FProformaNo := TFieldDB.Create('proforma_no', ftInteger, 0, Self, 'Proforma No');
  FTeslimSekliID := TFieldDB.Create('teslim_sekli_id', ftInteger, 0, Self, 'Teslim �ekli ID');
  FTeslimSekli := TFieldDB.Create(FSetTeslimSekli.Aciklama.FieldName, FSetTeslimSekli.Aciklama.DataType, '', Self, 'Teslim �ekli');
  FOdemeSekliID := TFieldDB.Create('odeme_sekli_id', ftInteger, 0, Self, '�deme �ekli ID');
  FOdemeSekli := TFieldDB.Create(FSetOdemeSekli.OdemeSekli.FieldName, FSetOdemeSekli.OdemeSekli.DataType, '', Self, '�deme �ekli');
  FPaketTipiID := TFieldDB.Create('paket_tipi_id', ftInteger, 0, Self, 'Paket Tipi ID');
  FPaketTipi := TFieldDB.Create(FSetPaketTipi.PaketTipi.FieldName, FSetPaketTipi.PaketTipi.DataType, '', Self, 'Paket Tipi');
  FTasimaUcretiID := TFieldDB.Create('tasima_ucreti_id', ftInteger, 0, Self, 'Ta��ma �creti ID');
  FTasimaUcreti := TFieldDB.Create(FSetNakliyeUcreti.TasimaUcreti.FieldName, FSetNakliyeUcreti.TasimaUcreti.DataType, '', Self, 'Ta��ma �creti');
end;

destructor TSatTeklif.Destroy;
begin
  FSysCountry.Free;
  FSysCity.Free;
  FTemsilci.Free;
  FFaturaTipi.Free;
  FSetTeklifDurum.Free;
  FSetTeslimSekli.Free;
  FSetOdemeSekli.Free;
  FSetPaketTipi.Free;
  FSetNakliyeUcreti.Free;

  inherited;
end;

procedure TSatTeklif.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FSiparisID.FieldName,
        TableName + '.' + FIrsaliyeID.FieldName,
        TableName + '.' + FFaturaID.FieldName,
        TableName + '.' + FIsSiparislesti.FieldName,
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
        TableName + '.' + FTeklifNo.FieldName,
        TableName + '.' + FTeklifTarihi.FieldName,
        TableName + '.' + FGecerlilikTarihi.FieldName,
        TableName + '.' + FMusteriKodu.FieldName,
        TableName + '.' + FMusteriAdi.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNo.FieldName,
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
        TableName + '.' + FMusteriTemsilcisiID.FieldName,
        addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
        TableName + '.' + FMuhattapAd.FieldName,
        TableName + '.' + FMuhattapTelefon.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FDolarKur.FieldName,
        TableName + '.' + FEuroKur.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FProformaNo.FieldName,
        TableName + '.' + FTeslimSekliID.FieldName,
        addField(FSetTeslimSekli.TableName, FSetTeslimSekli.TeslimSekli.FieldName, FTeslimSekli.FieldName),
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

procedure TSatTeklif.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FSiparisID.FieldName,
        TableName + '.' + FIrsaliyeID.FieldName,
        TableName + '.' + FFaturaID.FieldName,
        TableName + '.' + FIsSiparislesti.FieldName,
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
        TableName + '.' + FTeklifNo.FieldName,
        TableName + '.' + FTeklifTarihi.FieldName,
        TableName + '.' + FGecerlilikTarihi.FieldName,
        TableName + '.' + FMusteriKodu.FieldName,
        TableName + '.' + FMusteriAdi.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNo.FieldName,
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
        TableName + '.' + FMusteriTemsilcisiID.FieldName,
        addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
        TableName + '.' + FMuhattapAd.FieldName,
        TableName + '.' + FMuhattapTelefon.FieldName,
        TableName + '.' + FReferans.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FDolarKur.FieldName,
        TableName + '.' + FEuroKur.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FProformaNo.FieldName,
        TableName + '.' + FTeslimSekliID.FieldName,
        addField(FSetTeslimSekli.TableName, FSetTeslimSekli.TeslimSekli.FieldName, FTeslimSekli.FieldName),
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

procedure TSatTeklif.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
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
        FCadde.FieldName,
        FSokak.FieldName,
        FPostaKodu.FieldName,
        FBinaAdi.FieldName,
        FKapiNo.FieldName,
        FMusteriTemsilcisiID.FieldName,
        FMuhattapAd.FieldName,
        FMuhattapTelefon.FieldName,
        FReferans.FieldName,
        FParaBirimi.FieldName,
        FDolarKur.FieldName,
        FEuroKur.FieldName,
        FAciklama.FieldName,
        FProformaNo.FieldName,
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

procedure TSatTeklif.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
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
        FCadde.FieldName,
        FSokak.FieldName,
        FPostaKodu.FieldName,
        FBinaAdi.FieldName,
        FKapiNo.FieldName,
        FMusteriTemsilcisiID.FieldName,
        FMuhattapAd.FieldName,
        FMuhattapTelefon.FieldName,
        FReferans.FieldName,
        FParaBirimi.FieldName,
        FDolarKur.FieldName,
        FEuroKur.FieldName,
        FAciklama.FieldName,
        FProformaNo.FieldName,
        FTeslimSekliID.FieldName,
        FOdemeSekliID.FieldName,
        FPaketTipiID.FieldName,
        FTasimaUcretiID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.Notify;
  end;
end;

function TSatTeklif.Clone: TTable;
begin
  Result := TSatTeklif.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

function TSatTeklif.ToSiparis: TSatSiparis;
var
  ASip: TSatSiparis;
  LSipDetay: TSatSiparisDetay;
  LSiparisDurum: TSetSatSiparisDurum;
  LTekDetay: TSatTeklifDetay;
  n1: Integer;
begin
  LSiparisDurum := TSetSatSiparisDurum.Create(Database);
  LTekDetay := TSatTeklifDetay.Create(Database, Self);
  try
    LSiparisDurum.SelectToList(' AND ' + LSiparisDurum.Id.FieldName + '=' + Ord(TSatSiparisDurum.Beklemede).ToString, False, False);

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
    ASip.MusteriTemsilcisiID.Value := GSysKullanici.PersonelKartiID.Value;
    ASip.MusteriTemsilcisi.Value := GSysKullanici.PersonelAdSoyad.Value;
    ASip.MuhattapAd.Value := Self.MuhattapAd.Value;
    ASip.Referans.Value := Self.Referans.Value;
    ASip.ParaBirimi.Value := Self.ParaBirimi.Value;
    ASip.DolarKur.Value := Self.DolarKur.Value;
    ASip.EuroKur.Value := Self.EuroKur.Value;
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


    LTekDetay.SelectToList(' AND ' + LTekDetay.HeaderID.FieldName + '=' + VarToStr(Self.Id.Value), False, False);
    for n1 := 0 to LTekDetay.List.Count-1 do
    begin
      LSipDetay := TSatTeklifDetay(LTekDetay.List[n1]).ToSiparisDetay;
      LSipDetay.HeaderID.Value := ASip.Id.Value;

      ASip.AddDetay(LSipDetay);
    end;

    Result := ASip;
  finally
    LSiparisDurum.Free;
    LTekDetay.Free;
  end;
end;

function TSatTeklif.CopyDetail(ASrc: TSatTeklifDetay): TSatTeklifDetay;
begin
  Result := TSatTeklifDetay(ASrc.Clone)
end;

function TSatTeklif.GetAddress: string;
begin
  Result := '';
  if FMahalle.Value <> '' then
    Result := Result + FMahalle.Value + ' MAH. ';

  if FCadde.Value <> '' then
    Result := Result + FCadde.Value + ' CD. ';

  if FSokak.Value <> '' then
    Result := Result + FSokak.Value + ' SK. ';

  if FKapiNo.Value <> '' then
    Result := Result + ' NO: ' + FKapiNo.Value;
end;

procedure TSatTeklif.RefreshHeader;
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
    if (FKDVOran1.Value = 0) and (FKDVOran1.Value <> TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran1.Value := TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran2.Value = 0) and (FKDVOran2.Value <> TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran2.Value := TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran3.Value = 0) and (FKDVOran3.Value <> TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran3.Value := TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran4.Value = 0) and (FKDVOran4.Value <> TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran4.Value := TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value
    else if (FKDVOran5.Value = 0) and (FKDVOran5.Value <> TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value) then
      FKDVOran5.Value := TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value
  end;

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    if FKDVOran1.Value = TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar1.Value := FKDVTutar1.Value + TSatTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran2.Value = TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar2.Value := FKDVTutar2.Value + TSatTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran3.Value = TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar3.Value := FKDVTutar3.Value + TSatTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran4.Value = TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar4.Value := FKDVTutar4.Value + TSatTeklifDetay(ListDetay[n1]).KdvTutar.Value
    else if FKDVOran5.Value = TSatTeklifDetay(ListDetay[n1]).KdvOrani.Value then
      FKDVTutar5.Value := FKDVTutar5.Value + TSatTeklifDetay(ListDetay[n1]).KdvTutar.Value;

    FTutar.Value         := FTutar.Value        + TSatTeklifDetay(ListDetay[n1]).Tutar.Value;
    FIskontoTutar.Value  := FIskontoTutar.Value + TSatTeklifDetay(ListDetay[n1]).IskontoTutar.Value;
    FAraToplam.Value     := FTutar.Value - FIskontoTutar.Value;
    FGenelToplam.Value   := FGenelToplam.Value  + TSatTeklifDetay(ListDetay[n1]).ToplamTutar.Value;
  end;
end;

procedure TSatTeklif.BusinessDelete(APermissionControl: Boolean);
begin
  inherited;
  //
end;

procedure TSatTeklif.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  n1, vID: Integer;
begin
  Self.Insert(vID, True);
  Self.Id.Value := vID;
  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TSatTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    TSatTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
    TSatTeklifDetay(Self.ListDetay[n1]).Insert(vID, True);
  end;
end;

procedure TSatTeklif.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  LDetay: TSatTeklifDetay;
  n1: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);

  LDetay := TSatTeklifDetay.Create(Database, Self);
  try
    LDetay.SelectToList(' AND ' + LDetay.TableName + '.' + LDetay.HeaderID.FieldName + '=' + VarToStr(Self.Id.Value), ALock, APermissionControl);
    for n1 := 0 to LDetay.List.Count-1 do
      TSatTeklif(Self).AddDetay( TSatTeklifDetay(TSatTeklifDetay(LDetay.List[n1]).Clone) );
  finally
    LDetay.Free;
  end;
end;

procedure TSatTeklif.BusinessUpdate(APermissionControl: Boolean);
var
  n1, vID: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TSatTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    if TSatTeklifDetay(Self.ListDetay[n1]).Id.Value > 0 then
    begin
      TSatTeklifDetay(Self.ListDetay[n1]).Update(False);
    end
    else
    begin
      TSatTeklifDetay(Self.ListDetay[n1]).Insert(vID, False);
    end;
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count-1 do
    if TSatTeklifDetay(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TSatTeklifDetay(Self.ListSilinenDetay[n1]).Delete(False);
end;

procedure TSatTeklif.AddDetay(ATable: TTable);
begin
  TSatTeklifDetay(ATable).Teklif := Self;
  Self.ListDetay.Add(ATable);
  RefreshHeader;
end;

procedure TSatTeklif.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TSatTeklif.ValidateDetay(pTable: TTable): Boolean;
begin
  Result := True;
end;

procedure TSatTeklif.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

end.
