﻿unit Ths.Database.Table.SatTeklif;

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
  Ths.Database.Table.SetEinvTeslimSekli,
  Ths.Database.Table.SetEinvOdemeSekli,
  Ths.Database.Table.SetEinvPaketTipi,
  Ths.Database.Table.SetEinvTasimaUcreti,
  Ths.Database.Table.SetSatTeklifDurum,
  Ths.Database.Table.SetSatSiparisDurum,
  Ths.Database.Table.SatSiparis;

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
    FReferansAnaUrunID: TFieldDB;
    FGtipNo: TFieldDB;
  published
    FStokResim: TFieldDB;

    FStkStokKarti: TStkKart;
    constructor Create(ADatabase: TDatabase; ATeklif: TSatTeklif = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Teklif: TSatTeklif;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

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
    Property ReferansAnaUrunID: TFieldDB read FReferansAnaUrunID write FReferansAnaUrunID;
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
    FDovizKuruUsd: TFieldDB;
    FDovizKuruEur: TFieldDB;
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
    FSetTeslimSekli: TSetEinvTeslimSekli;
    FSetOdemeSekli: TSetEinvOdemeSekli;
    FSetPaketTipi: TSetEinvPaketTipi;
    FSetNakliyeUcreti: TSetEinvTasimaUcreti;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    function ToSiparis: TSatSiparis;

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
    Property DovizKuruUsd: TFieldDB read FDovizKuruUsd write FDovizKuruUsd;
    Property DovizKuruEur: TFieldDB read FDovizKuruEur write FDovizKuruEur;
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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.View.SysViewColumns;

constructor TSatTeklifDetay.Create(ADatabase: TDatabase; ATeklif: TSatTeklif);
begin
  TableName := 'sat_teklif_detaylari';
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
  FKdvOrani := TFieldDB.Create('kdv_orani', ftBCD, 0, Self, '');
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

destructor TSatTeklifDetay.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  inherited;
end;

function TSatTeklifDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
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
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSatTeklifDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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

function TSatTeklifDetay.ToSiparisDetay: TSatSiparisDetay;
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
      //stok kartı ve sipariş detay mm
      Result.En.Value := LStok.En.Value;
      Result.Boy.Value := LStok.Boy.Value;
      Result.Yukseklik.Value := LStok.Yukseklik.Value;
      //stok kartı ve sipariş detay kg birimi
      Result.NetAgirlik.Value := LStok.Agirlik.Value;
      Result.BrutAgirlik.Value := Result.NetAgirlik.Value;
    end;
  finally
    LStok.Free;
  end;
end;

procedure TSatTeklifDetay.DoInsert(APermissionControl: Boolean);
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

procedure TSatTeklifDetay.DoUpdate(APermissionControl: Boolean);
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

function TSatTeklifDetay.Clone: TTable;
begin
  Result := TSatTeklifDetay.Create(Database, Self.Teklif);
  CloneClassContent(Self, Result);
end;

constructor TSatTeklif.Create(ADatabase: TDatabase);
begin
  TableName := 'sat_teklifler';
  TableSourceCode := MODULE_SAT_TEK_KAYIT;
  inherited Create(ADatabase);

  FSysUlke := TSysUlke.Create(Database);
  FSysSehir := TSysSehir.Create(Database);
  FTemsilci := TPrsPersonel.Create(Database);
  FFaturaTipi := TSetEinvFaturaTipi.Create(Database);
  FSetTeklifDurum := TSetSatTeklifDurum.Create(Database);
  FSetTeslimSekli := TSetEinvTeslimSekli.Create(Database);
  FSetOdemeSekli := TSetEinvOdemeSekli.Create(Database);
  FSetPaketTipi := TSetEinvPaketTipi.Create(Database);
  FSetNakliyeUcreti := TSetEinvTasimaUcreti.Create(Database);

  FSiparisID := TFieldDB.Create('siparis_id', ftInteger, 0, Self);
  FIrsaliyeID := TFieldDB.Create('irsaliye_id', ftInteger, 0, Self);
  FFaturaID := TFieldDB.Create('fatura_id', ftInteger, 0, Self);
  FIsSiparislesti := TFieldDB.Create('is_siparislesti', ftBoolean, False, Self);
  FTutar := TFieldDB.Create('tutar', ftBCD, 0, Self, 'Tutar');
  FIskontoTutar := TFieldDB.Create('iskonto_tutar', ftBCD, 0, Self);
  FAraToplam := TFieldDB.Create('ara_toplam', ftBCD, 0, Self);
  FKDVOran1 := TFieldDB.Create('kdv_oran1', ftBCD, 0, Self);
  FKDVTutar1 := TFieldDB.Create('kdv_tutar1', ftBCD, 0, Self);
  FKDVOran2 := TFieldDB.Create('kdv_oran2', ftBCD, 0, Self);
  FKDVTutar2 := TFieldDB.Create('kdv_tutar2', ftBCD, 0, Self);
  FKDVOran3 := TFieldDB.Create('kdv_oran3', ftBCD, 0, Self);
  FKDVTutar3 := TFieldDB.Create('kdv_tutar3', ftBCD, 0, Self);
  FKDVOran4 := TFieldDB.Create('kdv_oran4', ftBCD, 0, Self);
  FKDVTutar4 := TFieldDB.Create('kdv_tutar4', ftBCD, 0, Self);
  FKDVOran5 := TFieldDB.Create('kdv_oran5', ftBCD, 0, Self);
  FKDVTutar5 := TFieldDB.Create('kdv_tutar5', ftBCD, 0, Self);
  FGenelToplam := TFieldDB.Create('genel_toplam', ftBCD, 0, Self);
  FIslemTipiID := TFieldDB.Create('islem_tipi_id', ftInteger, 0, Self);
  FIslemTipi := TFieldDB.Create(FFaturaTipi.FaturaTipi.FieldName, FFaturaTipi.FaturaTipi.DataType, '', Self);
  FTeklifNo := TFieldDB.Create('teklif_no', ftWideString, '', Self);
  FTeklifTarihi := TFieldDB.Create('teklif_tarihi', ftDateTime, 0, Self);
  FGecerlilikTarihi := TFieldDB.Create('gecerlilik_tarihi', ftDateTime, 0, Self);
  FMusteriKodu := TFieldDB.Create('musteri_kodu', ftWideString, '', Self);
  FMusteriAdi := TFieldDB.Create('musteri_adi', ftWideString, '', Self);
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftWideString, '', Self);
  FVergiNo := TFieldDB.Create('vergi_no', ftWideString, '', Self);
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self);
  FUlke := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self);
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self);
  FSehir := TFieldDB.Create(FSysSehir.Sehir.FieldName, FSysSehir.Sehir.DataType, '', Self);
  FIlce := TFieldDB.Create('ilce', ftWideString, '', Self);
  FMahalle := TFieldDB.Create('mahalle', ftWideString, '', Self);
  FCadde := TFieldDB.Create('cadde', ftWideString, '', Self);
  FSokak := TFieldDB.Create('sokak', ftWideString, '', Self);
  FPostaKodu := TFieldDB.Create('posta_kodu', ftWideString, '', Self);
  FBinaAdi := TFieldDB.Create('bina_adi', ftWideString, '', Self);
  FKapiNo := TFieldDB.Create('kapi_no', ftWideString, '', Self);
  FMusteriTemsilcisiID := TFieldDB.Create('musteri_temsilcisi_id', ftInteger, 0, Self);
  FMusteriTemsilcisi := TFieldDB.Create(FTemsilci.AdSoyad.FieldName, FTemsilci.AdSoyad.DataType, FTemsilci.AdSoyad.Value, Self);
  FMuhattapAd := TFieldDB.Create('muhattap_ad', ftWideString, '', Self);
  FMuhattapTelefon := TFieldDB.Create('muhattap_telefon', ftWideString, '', Self);
  FReferans := TFieldDB.Create('referans', ftWideString, '', Self);
  FParaBirimi := TFieldDB.Create('para_birimi', ftWideString, '', Self);
  FDovizKuruUsd := TFieldDB.Create('doviz_kuru_usd', ftBCD, 0, Self);
  FDovizKuruEur := TFieldDB.Create('doviz_kuru_eur', ftBCD, 0, Self);
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self);
  FProformaNo := TFieldDB.Create('proforma_no', ftInteger, 0, Self);
  FTeslimSekliID := TFieldDB.Create('teslim_sekli_id', ftInteger, 0, Self);
  FTeslimSekli := TFieldDB.Create(FSetTeslimSekli.TeslimSekli.FieldName, FSetTeslimSekli.TeslimSekli.DataType, '', Self);
  FOdemeSekliID := TFieldDB.Create('odeme_sekli_id', ftInteger, 0, Self);
  FOdemeSekli := TFieldDB.Create(FSetOdemeSekli.OdemeSekli.FieldName, FSetOdemeSekli.OdemeSekli.DataType, '', Self);
  FPaketTipiID := TFieldDB.Create('paket_tipi_id', ftInteger, 0, Self);
  FPaketTipi := TFieldDB.Create(FSetPaketTipi.PaketTipi.FieldName, FSetPaketTipi.PaketTipi.DataType, '', Self);
  FTasimaUcretiID := TFieldDB.Create('tasima_ucreti_id', ftInteger, 0, Self);
  FTasimaUcreti := TFieldDB.Create(FSetNakliyeUcreti.TasimaUcreti.FieldName, FSetNakliyeUcreti.TasimaUcreti.DataType, '', Self);

  PrepareTableRequiredValues;
end;

destructor TSatTeklif.Destroy;
begin
  FSysUlke.Free;
  FSysSehir.Free;
  FTemsilci.Free;
  FFaturaTipi.Free;
  FSetTeklifDurum.Free;
  FSetTeslimSekli.Free;
  FSetOdemeSekli.Free;
  FSetPaketTipi.Free;
  FSetNakliyeUcreti.Free;

  inherited;
end;

function TSatTeklif.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
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
      FCadde.QryName,
      FSokak.QryName,
      FPostaKodu.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FMusteriTemsilcisiID.QryName,
      addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
      FMuhattapAd.QryName,
      FMuhattapTelefon.QryName,
      FReferans.QryName,
      FParaBirimi.QryName,
      FDovizKuruUsd.QryName,
      FDovizKuruEur.QryName,
      FAciklama.QryName,
      FProformaNo.QryName,
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
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
      addJoin(jtLeft, FTemsilci.TableName, FTemsilci.Id.FieldName, TableName, FMusteriTemsilcisiID.FieldName),
      addJoin(jtLeft, FSetTeslimSekli.TableName, FSetTeslimSekli.Id.FieldName, TableName, FTeslimSekliID.FieldName),
      addJoin(jtLeft, FSetOdemeSekli.TableName, FSetOdemeSekli.Id.FieldName, TableName, FOdemeSekliID.FieldName),
      addJoin(jtLeft, FSetPaketTipi.TableName, FSetPaketTipi.Id.FieldName, TableName, FPaketTipiID.FieldName),
      addJoin(jtLeft, FSetNakliyeUcreti.TableName, FSetNakliyeUcreti.Id.FieldName, TableName, FTasimaUcretiID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSatTeklif.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FCadde.QryName,
      FSokak.QryName,
      FPostaKodu.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FMusteriTemsilcisiID.QryName,
      addField(FTemsilci.TableName, FTemsilci.AdSoyad.FieldName, FMusteriTemsilcisi.FieldName),
      FMuhattapAd.QryName,
      FMuhattapTelefon.QryName,
      FReferans.QryName,
      FParaBirimi.QryName,
      FDovizKuruUsd.QryName,
      FDovizKuruEur.QryName,
      FAciklama.QryName,
      FProformaNo.QryName,
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
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
      addJoin(jtLeft, FTemsilci.TableName, FTemsilci.Id.FieldName, TableName, FMusteriTemsilcisiID.FieldName),
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
  end;
end;

procedure TSatTeklif.DoInsert(APermissionControl: Boolean);
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
      FDovizKuruUsd.FieldName,
      FDovizKuruEur.FieldName,
      FAciklama.FieldName,
      FProformaNo.FieldName,
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
  end;
end;

procedure TSatTeklif.PubRefreshHeader;
begin
  RefreshHeader;
end;

procedure TSatTeklif.DoUpdate(APermissionControl: Boolean);
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
      FDovizKuruUsd.FieldName,
      FDovizKuruEur.FieldName,
      FAciklama.FieldName,
      FProformaNo.FieldName,
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

function TSatTeklif.GetAddress: string;
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

procedure TSatTeklif.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(True);
  for n1 := 0 to Self.ListDetay.Count-1 do
  begin
    TSatTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    TSatTeklifDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
    TSatTeklifDetay(Self.ListDetay[n1]).Insert(True);
  end;
end;

procedure TSatTeklif.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  n1, n2: Integer;
  LDetay: TSatTeklifDetay;
  ATeklif: TSatTeklif;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);

  for n1 := 0 to List.Count-1 do
  begin
    ATeklif := TSatTeklif(List[n1]);

    LDetay := TSatTeklifDetay.Create(Database, ATeklif);
    try
      LDetay.SelectToList(' AND ' + LDetay.HeaderID.QryName + '=' + ATeklif.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LDetay.List.Count-1 do
        ATeklif.AddDetay(TSatTeklifDetay(LDetay.List[n2]).Clone, n2 = LDetay.List.Count-1);
    finally
      LDetay.Free;
    end;
  end;
end;

procedure TSatTeklif.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
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
      TSatTeklifDetay(Self.ListDetay[n1]).Insert(False);
    end;
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count-1 do
    if TSatTeklifDetay(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TSatTeklifDetay(Self.ListSilinenDetay[n1]).Delete(False);
end;

procedure TSatTeklif.AddDetay(ATable: TTable; ALastItem: Boolean = False);
begin
  TSatTeklifDetay(ATable).Teklif := Self;
  Self.ListDetay.Add(TSatTeklifDetay(ATable));
  if ALastItem then RefreshHeader;
end;

procedure TSatTeklif.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TSatTeklif.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
  if CompareValue(TSatTeklifDetay(ATable).Miktar.Value, 0, EPSILON) = EqualsValue then
    raise Exception.Create('Sıfır miktar ile kayıt yapılamaz!');
end;

procedure TSatTeklif.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

end.



