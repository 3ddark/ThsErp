unit ufrmDashboard;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.Variants, System.Math, System.StrUtils, System.Actions,
  System.Classes, System.SysUtils, System.DateUtils, System.Rtti, System.Generics.Collections,
  System.ImageList, System.Threading, Winapi.ShellAPI, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.Menus, Vcl.ActnList, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.Dialogs,
  Vcl.ToolWin, Vcl.ImgList, Vcl.StdActns, Vcl.CategoryButtons, Vcl.WinXCtrls,
  Vcl.Imaging.pngimage, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Stan.Intf, Ths.Utils.InfoWindow, udm, ufrmBase, ufrmBaseDBGrid,
  Ths.Database.TableDetailed, Ths.Database.Table,

  ufrmGrid, BaseService, BaseRepository, BaseEntity, ServiceContainer, UnitOfWork,
  StkCinsAileService, StkCinsAile, ufrmStkCinsAilelerX;

type
  TfrmDashboard = class(TfrmBase)
    PageControl1: TPageControl;
    tsgeneral: TTabSheet;
    tssales: TTabSheet;
    tsstock: TTabSheet;
    tsaccount: TTabSheet;
    tsemployee: TTabSheet;
    btnch_hesap_karti: TButton;
    actlstMain: TActionList;
    actsys_resource_group: TAction;
    actsys_resource: TAction;
    actsys_user: TAction;
    actsys_access_right: TAction;
    actsys_grid_column: TAction;
    actsys_grid_filter_sort: TAction;
    actsys_lang_gui_content: TAction;
    actsys_application_setting: TAction;
    actsys_application_setting_other: TAction;
    actsys_day: TAction;
    actsys_month: TAction;
    actsys_database_status: TAction;
    actsys_about: TAction;
    actsys_update_password: TAction;
    actsys_update: TAction;
    tmrcheck_is_update_required: TTimer;
    pnlToolbar: TPanel;
    lblTitle: TLabel;
    actsys_country: TAction;
    actsys_city: TAction;
    actacc_exchange_rate: TAction;
    actsys_currency: TAction;
    actsys_unit: TAction;
    btnch_hesap_karti_ara: TButton;
    actsys_region: TAction;
    btnch_banka: TButton;
    btnch_banka_subesi: TButton;
    btnset_ch_grup: TButton;
    btnset_ch_hesap_plani: TButton;
    btnset_ch_vergi_orani: TButton;
    btnch_bolge: TButton;
    btnstk_stok_karti: TButton;
    btnstk_cins_ozelligi: TButton;
    btnstk_stok_ambar: TButton;
    btnstk_stok_grubu: TButton;
    btnsat_teklif: TButton;
    btnsat_siparis: TButton;
    btnsat_teklif_rapor: TButton;
    btnsat_siparis_rapor: TButton;
    btnprs_personel: TButton;
    btnbbk_kayit: TButton;
    tsbom: TTabSheet;
    btnrct_recete: TButton;
    btnrct_iscilik_gideri: TButton;
    btnrct_paket_hammadde: TButton;
    tsaccounting: TTabSheet;
    btnmhs_doviz_kuru: TButton;
    actsys_unit_type: TAction;
    btnsys_olcu_birimleri: TButton;
    btnsys_para_birimleri: TButton;
    actsys_do_database_backup: TAction;
    mm1: TMainMenu;
    mnimenu_hakkinda: TMenuItem;
    ifreDeitir1: TMenuItem;
    DatabaseMonitor1: TMenuItem;
    VeritabanYedekAl1: TMenuItem;
    Hakknda2: TMenuItem;
    N3: TMenuItem;
    mnimenu_system: TMenuItem;
    mnisys_access_right: TMenuItem;
    mnisys_application_setting: TMenuItem;
    mnisys_city: TMenuItem;
    mnisys_country: TMenuItem;
    mnisys_day: TMenuItem;
    mnisys_grid_column: TMenuItem;
    mnisys_grid_filter_sort: TMenuItem;
    mnisys_lang_gui_content: TMenuItem;
    mnisys_region: TMenuItem;
    mnisys_month: TMenuItem;
    mnisys_resource: TMenuItem;
    mnisys_resource_group: TMenuItem;
    mnisys_unit: TMenuItem;
    mnisys_unit_type: TMenuItem;
    mnisys_user: TMenuItem;
    Gncelle1: TMenuItem;
    N2: TMenuItem;
    mniSystemSubSettings: TMenuItem;
    mniN4: TMenuItem;
    mniN7: TMenuItem;
    mniN8: TMenuItem;
    mniN9: TMenuItem;
    mniN10: TMenuItem;
    mnisys_currency: TMenuItem;
    mnimenu_satis: TMenuItem;
    mnimenu_alim: TMenuItem;
    mnimenu_muhasebe: TMenuItem;
    mnimenu_stok: TMenuItem;
    mnialim_teklif: TMenuItem;
    mnialim_siparis: TMenuItem;
    mnialim_irsaliye: TMenuItem;
    mnialim_fatura: TMenuItem;
    mnich_bankalar: TMenuItem;
    mnich_banka_subeleri: TMenuItem;
    actstk_ambarlar: TAction;
    actstk_cins_ozellikleri: TAction;
    actstk_gruplar: TAction;
    actstk_hareketler: TAction;
    actstk_stok_kartlari: TAction;
    actstk_stok_karti_ozetleri: TAction;
    mnistk_ambarlar: TMenuItem;
    mnistk_gruplar: TMenuItem;
    mnimuhasebe_ayarlar: TMenuItem;
    actset_ch_vergi_orani: TAction;
    mniset_ch_vergi_orani: TMenuItem;
    mnimenu_personel: TMenuItem;
    mnipersonel_ayarlar: TMenuItem;
    mniset_prs_bolumler: TMenuItem;
    mniset_prs_birimller: TMenuItem;
    mniset_prs_gorevler: TMenuItem;
    actset_prs_bolumler: TAction;
    actset_prs_birimler: TAction;
    actset_prs_gorevler: TAction;
    actset_prs_ehliyetler: TAction;
    actset_prs_lisanlar: TAction;
    actset_prs_lisan_seviyeleri: TAction;
    actset_prs_personel_tipleri: TAction;
    mniset_prs_ehliyetler: TMenuItem;
    mniset_prs_lisanlar: TMenuItem;
    mniset_prs_lisan_seviyeleri: TMenuItem;
    mniset_prs_personel_tipleri: TMenuItem;
    actprs_lisan_bilgileri: TAction;
    actprs_ehliyetler: TAction;
    actprs_personeller: TAction;
    mniprs_ehliyetler: TMenuItem;
    mniprs_lisan_bilgileri: TMenuItem;
    mniprs_personeller: TMenuItem;
    actals_teklifler: TAction;
    actch_bankalar: TAction;
    actch_banka_subeleri: TAction;
    actset_prs_tasima_servisleri: TAction;
    mniset_prs_tasima_servisleri: TMenuItem;
    btnTest: TButton;

/// <summary>
///   Kullanıcının erişim yetkisine göre yapılacak işlemler burada olacak
/// </summary>
/// <remarks>
///   Login olan kullanıcıya ait haklara göre yapılacak işlemler burada yapılıyor.
///   Ana formda kullanıcının sahip olduğu yetkilere göre butonlar açılıyor.
/// </remarks>
/// <example>
///   Yeni Kayıt Ekle Buton başlığı için ButtonAdd
/// </example>
    procedure SetSession;
    procedure FormActivate(Sender: TObject);
    procedure ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
    procedure tmrcheck_is_update_requiredTimer(Sender: TObject);
    procedure actsys_resource_groupExecute(Sender: TObject);
    procedure actsys_resourceExecute(Sender: TObject);
    procedure actsys_userExecute(Sender: TObject);
    procedure actsys_access_rightExecute(Sender: TObject);
    procedure actsys_grid_columnExecute(Sender: TObject);
    procedure actsys_grid_filter_sortExecute(Sender: TObject);
    procedure actsys_lang_gui_contentExecute(Sender: TObject);
    procedure actsys_application_settingExecute(Sender: TObject);
    procedure actsys_monthExecute(Sender: TObject);
    procedure actsys_dayExecute(Sender: TObject);
    procedure actquality_form_mail_recieversExecute(Sender: TObject);
    procedure actodeme_baslangic_donemleriExecute(Sender: TObject);
    procedure actset_teklif_tipleriExecute(Sender: TObject);
    procedure actteklif_durumlariExecute(Sender: TObject);
    procedure actset_efatura_fatura_tipiExecute(Sender: TObject);
    procedure actset_efatura_istisna_koduExecute(Sender: TObject);
    procedure actsys_database_statusExecute(Sender: TObject);
    procedure actsys_aboutExecute(Sender: TObject);
    procedure actsys_update_passwordExecute(Sender: TObject);
    procedure actsys_updateExecute(Sender: TObject);
    procedure actsys_countryExecute(Sender: TObject);
    procedure actsys_cityExecute(Sender: TObject);
    procedure actacc_exchange_rateExecute(Sender: TObject);
    procedure actset_prs_bolumExecute(Sender: TObject);
    procedure actset_prs_lisanExecute(Sender: TObject);
    procedure actset_prs_gorevExecute(Sender: TObject);
    procedure actset_prs_birimExecute(Sender: TObject);
    procedure actlstMainExecute(Action: TBasicAction; var Handled: Boolean);
    procedure actsys_currencyExecute(Sender: TObject);
    procedure actsys_unitExecute(Sender: TObject);
    procedure actset_bbk_calisma_durumuExecute(Sender: TObject);
    procedure actset_bbk_finans_durumuExecute(Sender: TObject);
    procedure actset_bbk_firma_tipiExecute(Sender: TObject);
    procedure actbbk_kayitExecute(Sender: TObject);
    procedure actsat_teklifExecute(Sender: TObject);
    procedure actrct_receteExecute(Sender: TObject);
    procedure actch_hesap_karti_araExecute(Sender: TObject);
    procedure actch_hesap_kartiExecute(Sender: TObject);
    procedure actch_bolgeExecute(Sender: TObject);
    procedure actset_ch_firma_tipiExecute(Sender: TObject);
    procedure actset_ch_firma_turuExecute(Sender: TObject);
    procedure actset_ch_grupExecute(Sender: TObject);
    procedure actset_ch_hesap_planiExecute(Sender: TObject);
    procedure actset_ch_hesap_tipiExecute(Sender: TObject);
    procedure actstk_stok_hareketiExecute(Sender: TObject);
    procedure actsat_siparis_raporExecute(Sender: TObject);
    procedure actsat_siparisExecute(Sender: TObject);
    procedure actrct_iscilik_gideriExecute(Sender: TObject);
    procedure actrct_paket_hammaddeExecute(Sender: TObject);
    procedure actsys_unit_typeExecute(Sender: TObject);
    procedure actsys_regionExecute(Sender: TObject);
    procedure actsys_do_database_backupExecute(Sender: TObject);
    procedure actset_einv_odeme_sekliExecute(Sender: TObject);
    procedure actset_einv_paket_tipiExecute(Sender: TObject);
    procedure actset_einv_tasima_ucretiExecute(Sender: TObject);
    procedure actset_einv_teslim_sekliExecute(Sender: TObject);
    procedure actstk_ambarlarExecute(Sender: TObject);
    procedure actstk_gruplarExecute(Sender: TObject);
    procedure actstk_hareketlerExecute(Sender: TObject);
    procedure actstk_stok_kartlariExecute(Sender: TObject);
    procedure actstk_stok_karti_ozetleriExecute(Sender: TObject);
    procedure actstk_cins_ozellikleriExecute(Sender: TObject);
    procedure actset_ch_vergi_oraniExecute(Sender: TObject);
    procedure actset_prs_bolumlerExecute(Sender: TObject);
    procedure actset_prs_birimlerExecute(Sender: TObject);
    procedure actset_prs_gorevlerExecute(Sender: TObject);
    procedure actprs_ehliyetlerExecute(Sender: TObject);
    procedure actprs_lisan_bilgileriExecute(Sender: TObject);
    procedure actprs_personellerExecute(Sender: TObject);
    procedure actset_prs_lisanlarExecute(Sender: TObject);
    procedure actset_prs_ehliyetlerExecute(Sender: TObject);
    procedure actset_prs_lisan_seviyeleriExecute(Sender: TObject);
    procedure actset_prs_personel_tipleriExecute(Sender: TObject);
    procedure actals_tekliflerExecute(Sender: TObject);
    procedure actch_bankalarExecute(Sender: TObject);
    procedure actch_banka_subeleriExecute(Sender: TObject);
    procedure actset_prs_tasima_servisleriExecute(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
  private
    FIsFormShow: Boolean;
  published
    procedure btnCloseClick(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormKeyPress(Sender: TObject; var Key: Char); override;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormShow(Sender: TObject); override;
  public
    destructor Destroy; override;

    procedure UpdateApplicationExe;
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}

uses
  Vcl.Themes,
  ufrmAbout,
  Ths.Utils.FluentXML,
  Logger,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Constants,
  Ths.Globals,
  ufrmSysGuiIcerik,
  ufrmSysSifreDegistir,
  Ths.Utils.TCMBDovizKuru,
  Ths.Utils.DatabaseTools,

  Ths.Database.Table.SysUlkeler, ufrmSysUlkeler,
  Ths.Database.Table.SysSehirler, ufrmSysSehirler,
  Ths.Database.Table.SysBolgeler, ufrmSysBolgeler,
  Ths.Database.Table.SysKullanicilar, ufrmSysKullanicilar,
  Ths.Database.Table.SysErisimHaklari, ufrmSysErisimHaklari,
  Ths.Database.Table.SysKaynakGruplari, ufrmSysKaynakGruplari,
  Ths.Database.Table.SysKaynaklar, ufrmSysKaynaklar,
  Ths.Database.Table.SysGunler, ufrmSysGunler,
  Ths.Database.Table.SysAylar, ufrmSysAylar,
  Ths.Database.Table.SysGuiIcerikler, ufrmSysGuiIcerikler,
  Ths.Database.Table.SysGridKolonlar, ufrmSysGridKolonlar,
  Ths.Database.Table.SysGridFiltrelerSiralamalar, ufrmSysGridFiltrelerSiralamalar,
  Ths.Database.Table.SysOlcuBirimleri, ufrmSysOlcuBirimleri,
  Ths.Database.Table.SysOlcuBirimiTipleri, ufrmSysOlcuBirimiTipleri,
  Ths.Database.Table.SysParaBirimleri, ufrmSysParaBirimleri,
  Ths.Database.Table.SysUygulamaAyarlari, ufrmSysUygulamaAyari,
  Ths.Database.Table.View.SysDbStatus, ufrmSysDatabaseMonitor,

  Ths.Database.Table.ChDovizKurlari, ufrmChDovizKurlari,

  Ths.Database.Table.PrsPersoneller, ufrmPrsPersoneller,
  Ths.Database.Table.PrsLisanBilgileri, ufrmPrsLisanBilgileri,
  Ths.Database.Table.PrsEhliyetler, ufrmPrsEhliyetler,
  Ths.Database.Table.SetPrsBolumler, ufrmSetPrsBolumler,
  Ths.Database.Table.SetPrsBirimler, ufrmSetPrsBirimler,
  Ths.Database.Table.SetPrsGorevler, ufrmSetPrsGorevler,
  Ths.Database.Table.SetPrsEhliyetler, ufrmSetPrsEhliyetler,
  Ths.Database.Table.SetPrsPersonelTipleri, ufrmSetPrsPersonelTipleri,
  Ths.Database.Table.SetPrsLisanlar, ufrmSetPrsLisanlar,
  Ths.Database.Table.SetPrsLisanSeviyeleri, ufrmSetPrsLisanSeviyeleri,
  Ths.Database.Table.SetPrsTasimaServisleri, ufrmSetPrsTasimaServisleri,

  Ths.Database.Table.SetEinvFaturaTipleri, ufrmSetEinvFaturaTipleri,
  Ths.Database.Table.SetEinvIstisnaKodu, ufrmSetEinvIstisnaKodlari,
  Ths.Database.Table.SetEinvTeslimSekli, ufrmSetEinvTeslimSekilleri,
  Ths.Database.Table.SetEinvPaketTipi, ufrmSetEinvPaketTipleri,
  Ths.Database.Table.SetEinvTasimaUcreti, ufrmSetEinvTasimaUcretleri,
  Ths.Database.Table.SetEinvOdemeSekli, ufrmSetEinvOdemeSekilleri,

  Ths.Database.Table.AlsTeklifler, ufrmAlsTeklifler,

  Ths.Database.Table.SetTekTeklifTipi, ufrmSetTekTeklifTipleri,
  Ths.Database.Table.SetSatTeklifDurum, ufrmSetSatTeklifDurumlar,
  Ths.Database.Table.SatTeklif, ufrmSatTeklifler,

  Ths.Database.Table.SetSatSiparisDurum, ufrmSetSatSiparisDurumlar,
  Ths.Database.Table.SatSiparis, ufrmSatSiparisler,
  Ths.Database.Table.SatSiparisRapor, ufrmSatSiparislerRapor,

  Ths.Database.Table.UrtReceteler, ufrmUrtReceteler,
  Ths.Database.Table.UrtIscilikler, ufrmUrtIscilikler,
  Ths.Database.Table.UrtPaketHammaddeler, ufrmUrtPaketHammaddeler,

  Ths.Database.Table.SetChFirmaTipi, ufrmSetChFirmaTipleri,
  Ths.Database.Table.SetChFirmaTuru, ufrmSetChFirmaTurleri,
  Ths.Database.Table.ChGruplar, ufrmChGruplar,
  Ths.Database.Table.ChHesapPlanlari, ufrmChHesapPlanlari,
  Ths.Database.Table.SetChHesapTipi, ufrmSetChHesapTipleri,
  Ths.Database.Table.SetChVergiOranlari, ufrmSetChVergiOranlari,
  Ths.Database.Table.ChBankalar, ufrmChBankalar,
  Ths.Database.Table.ChBankaSubeleri, ufrmChBankaSubeleri,
  Ths.Database.Table.ChBolgeler, ufrmChBolgeler,
  Ths.Database.Table.ChHesapKarti, ufrmChHesapKartlari,
  Ths.Database.Table.ChHesapKartiAra, ufrmChHesapKartlariAra,

  Ths.Database.Table.StkCinsOzellikleri, ufrmStkCinsOzellikleri,
  Ths.Database.Table.StkGruplar, ufrmStkGruplar,
  Ths.Database.Table.StkKartlar, ufrmStkKartlar,
  Ths.Database.Table.StkStokHareketi, ufrmStkStokHareketleri,
  Ths.Database.Table.StkAmbarlar, ufrmStkStokAmbarlar,
  
  Ths.Database.Table.OthMailReciever, ufrmOthMailRecievers,
  Ths.Database.Table.SetOdemeBaslangicDonemi, ufrmSetOdemeBaslangicDonemleri,

  Ths.Database.Table.SetBbkCalismaDurumu, ufrmSetBbkCalismaDurumlari,
  Ths.Database.Table.SetBbkFinansDurumu, ufrmSetBbkFinansDurumlari,
  Ths.Database.Table.SetBbkFirmatipi, ufrmSetBbkFirmaTipleri,
  Ths.Database.Table.BbkKayit, ufrmBbkKayitlar;

procedure TfrmDashboard.actsys_aboutExecute(Sender: TObject);
var
  LTs: TTabSheet;
begin
  LTs := PageControl1.ActivePage;
  TfrmAbout.Create(Application).ShowModal;
  SetSession;

  if LTs.TabVisible then
    PageControl1.ActivePage := LTs;
end;

procedure TfrmDashboard.actals_tekliflerExecute(Sender: TObject);
begin
  TfrmAlsTeklifler.Create(Self, Self, TAlsTeklif.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actbbk_kayitExecute(Sender: TObject);
begin
  TfrmBbkKayitlar.Create(Self, Self, TBbkKayit.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actch_bankalarExecute(Sender: TObject);
begin
  TfrmChBankalar.Create(Self, Self, TChBanka.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actch_banka_subeleriExecute(Sender: TObject);
begin
  TfrmChBankaSubeleri.Create(Self, Self, TChBankaSubesi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actch_bolgeExecute(Sender: TObject);
begin
  TfrmChBolgeler.Create(Self, Self, TChBolge.Create(GDataBase)).Show;
end;

procedure TfrmDashboard.actch_hesap_kartiExecute(Sender: TObject);
begin
  TfrmHesapKartlari.Create(Self, Self, TChHesapKarti.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actch_hesap_karti_araExecute(Sender: TObject);
begin
  TfrmHesapKartlariAra.Create(Self, Self, TChHesapKartiAra.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_update_passwordExecute(Sender: TObject);
var
  LUser: TSysKullanici;
begin
  LUser := TSysKullanici(GSysKullanici.Clone);
  TfrmSysSifreDegistir.Create(Self, nil, LUser, ifmUpdate).ShowModal;
end;

procedure TfrmDashboard.actlstMainExecute(Action: TBasicAction; var Handled: Boolean);
begin
//  if SV.Opened then
//    SV.Opened := not SV.Opened;
end;

procedure TfrmDashboard.actodeme_baslangic_donemleriExecute(Sender: TObject);
begin
  TfrmSetOdemeBaslangicDonemleri.Create(Self, Self, TSetOdemeBaslangicDonemi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_birimlerExecute(Sender: TObject);
begin
  TfrmSetPrsBirimler.Create(Self, Self, TSetPrsBirim.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_bolumlerExecute(Sender: TObject);
begin
  TfrmSetPrsBolumler.Create(Self, Self, TSetPrsBolum.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_ehliyetlerExecute(Sender: TObject);
begin
  TfrmSetPrsEhliyetler.Create(Self, Self, TSetPrsEhliyet.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_gorevlerExecute(Sender: TObject);
begin
  TfrmSetPrsGorevler.Create(Self, Self, TSetPrsGorev.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actprs_ehliyetlerExecute(Sender: TObject);
begin
  TfrmPrsEhliyetler.Create(Self, Self, TPrsEhliyet.Create(GDatabase), fomNormal).Show
end;

procedure TfrmDashboard.actprs_lisan_bilgileriExecute(Sender: TObject);
begin
  TfrmPrsLisanBilgileri.Create(Self, Self, TPrsLisanBilgisi.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actprs_personellerExecute(Sender: TObject);
begin
  TfrmPrsPersoneller.Create(Self, Self, TPrsPersonel.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsat_siparisExecute(Sender: TObject);
begin
  TfrmSatSiparisler.Create(Self, Self, TSatSiparis.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsat_siparis_raporExecute(Sender: TObject);
begin
  TfrmSatSiparislerRapor.Create(Self, Self, TSatSiparisRapor.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsat_teklifExecute(Sender: TObject);
begin
  TfrmSatTeklifler.Create(Self, Self, TSatTeklif.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_bbk_calisma_durumuExecute(Sender: TObject);
begin
  TfrmSetBbkCalismaDurumlari.Create(Self, Self, TSetBbkCalismaDurumu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_bbk_finans_durumuExecute(Sender: TObject);
begin
  TfrmSetBbkFinansDurumlari.Create(Self, Self, TSetBbkFinansDurumu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_bbk_firma_tipiExecute(Sender: TObject);
begin
  TfrmSetBbkFirmaTipleri.Create(Self, Self, TSetBbkFirmaTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_ch_firma_tipiExecute(Sender: TObject);
begin
  TfrmSetChFirmaTipleri.Create(Self, Self, TSetChFirmaTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_ch_firma_turuExecute(Sender: TObject);
begin
  TfrmSetChFirmaTurleri.Create(Self, Self, TSetChFirmaTuru.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_ch_grupExecute(Sender: TObject);
begin
  TfrmChGruplar.Create(Self, Self, TChGrup.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_ch_hesap_planiExecute(Sender: TObject);
begin
  TfrmChHesapPlanlari.Create(Self, Self, TChHesapPlani.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_ch_hesap_tipiExecute(Sender: TObject);
begin
  TfrmSetChHesapTipleri.Create(Self, Self, TSetChHesapTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_ch_vergi_oraniExecute(Sender: TObject);
begin
  TfrmSetChVergiOranlari.Create(Self, Self, TSetChVergiOrani.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_efatura_fatura_tipiExecute(Sender: TObject);
begin
  TfrmSetEinvFaturaTipleri.Create(Self, Self, TSetEinvFaturaTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_efatura_istisna_koduExecute(Sender: TObject);
begin
  TfrmSetEinvIstisnaKodlari.Create(Self, Self, TSetEinvIstisnaKodu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_einv_odeme_sekliExecute(Sender: TObject);
begin
  TfrmSetEinvOdemeSekilleri.Create(Self, Self, TSetEinvOdemeSekli.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_einv_paket_tipiExecute(Sender: TObject);
begin
  TfrmSetEinvPaketTipleri.Create(Self, Self, TSetEinvPaketTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_einv_tasima_ucretiExecute(Sender: TObject);
begin
  TfrmSetEinvTasimaUcretleri.Create(Self, Self, TSetEinvTasimaUcreti.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_einv_teslim_sekliExecute(Sender: TObject);
begin
  TfrmSetEinvTeslimSekilleri.Create(Self, Self, TSetEinvTeslimSekli.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_birimExecute(Sender: TObject);
begin
  TfrmSetPrsBirimler.Create(Self, Self, TSetPrsBirim.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_bolumExecute(Sender: TObject);
begin
  TfrmSetPrsBolumler.Create(Self, Self, TSetPrsBolum.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_gorevExecute(Sender: TObject);
begin
  TfrmSetPrsGorevler.Create(Self, Self, TSetPrsGorev.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_lisanExecute(Sender: TObject);
begin
  TfrmSetPrsLisanlar.Create(Self, Self, TSetPrsLisan.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_lisanlarExecute(Sender: TObject);
begin
  TfrmSetPrsLisanlar.Create(Self, Self, TSetPrsLisan.Create(GDatabase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_lisan_seviyeleriExecute(Sender: TObject);
begin
  TfrmSetPrsLisanSeviyeleri.Create(Self, Self, TSetPrsLisanSeviyesi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_personel_tipleriExecute(Sender: TObject);
begin
  TfrmSetPrsPersonelTipleri.Create(Self, Self, TSetPrsPersonelTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_prs_tasima_servisleriExecute(Sender: TObject);
begin
  TfrmSetPrsTasimaServisleri.Create(Self, Self, TSetPrsTasimaServisi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actstk_ambarlarExecute(Sender: TObject);
begin
  TfrmStkStokAmbarlar.Create(Self, Self, TStkAmbar.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actstk_cins_ozellikleriExecute(Sender: TObject);
begin
  TfrmStkCinsOzellikleri.Create(Self, Self, TStkCinsOzellik.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actstk_gruplarExecute(Sender: TObject);
begin
  TfrmStkGruplar.Create(Self, Self, TStkGruplar.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actstk_hareketlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_hareketiExecute(Sender: TObject);
begin
//  TfrmStkStokHareketleri.Create(Self, Self, TStkStokHareketi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actstk_stok_karti_ozetleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_kartlariExecute(Sender: TObject);
begin
  TfrmStkKartlar.Create(Self, Self, TStkKart.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_cityExecute(Sender: TObject);
begin
  TfrmSysSehirler.Create(Self, Self, TSysSehir.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_grid_columnExecute(Sender: TObject);
begin
  TfrmSysGridKolonlar.Create(Self, Self, TSysGridKolon.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_countryExecute(Sender: TObject);
begin
  TfrmSysUlkeler.Create(Self, Self, TSysUlke.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_dayExecute(Sender: TObject);
begin
  TfrmSysGunler.Create(Self, Self, TSysGun.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_database_statusExecute(Sender: TObject);
begin
  TfrmSysDatabaseMonitor.Create(Self, Self, TSysDBStatus.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_do_database_backupExecute(Sender: TObject);
begin
  Ths.Utils.DatabaseTools.TDatabaseTools.DoDatabaseBackup;
end;

procedure TfrmDashboard.actsys_grid_filter_sortExecute(Sender: TObject);
begin
  TfrmSysGridFiltrelerSiralamalar.Create(Self, Self, TSysGridFiltreSiralama.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actacc_exchange_rateExecute(Sender: TObject);
begin
  TfrmChDovizKurlari.Create(Self, Self, TChDovizKuru.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_lang_gui_contentExecute(Sender: TObject);
begin
  TfrmSysGuiIcerikler.Create(Self, Self, TSysGuiIcerik.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_monthExecute(Sender: TObject);
begin
  TfrmSysAylar.Create(Self, Self, TSysAy.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_regionExecute(Sender: TObject);
begin
  TfrmSysBolgeler.Create(Self, Self, TSysBolge.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_unit_typeExecute(Sender: TObject);
begin
  TfrmSysOlcuBirimiTipleri.Create(Self, Self, TSysOlcuBirimiTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_unitExecute(Sender: TObject);
begin
  TfrmSysOlcuBirimleri.Create(Self, Self, TSysOlcuBirimi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_currencyExecute(Sender: TObject);
begin
  TfrmSysParaBirimleri.Create(Self, Self, TSysParaBirimi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_resourceExecute(Sender: TObject);
begin
  TfrmSysKaynaklar.Create(Self, Self, TSysKaynak.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_resource_groupExecute(Sender: TObject);
begin
  TfrmSysKaynakGruplari.Create(Self, Self, TSysKaynakGrubu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_application_settingExecute(Sender: TObject);
var
  LAppSetting: TSysUygulamaAyari;
begin
  LAppSetting := TSysUygulamaAyari.Create(GDataBase);
  LAppSetting.LogicalSelect('', False, False, True);
  if LAppSetting.List.Count = 0 then
  begin
    LAppSetting.Clear;
    TfrmSysUygulamaAyari.Create(Self, nil, LAppSetting, ifmNewRecord).ShowModal
  end else if LAppSetting.List.Count = 1 then
    TfrmSysUygulamaAyari.Create(Self, nil, LAppSetting, ifmRewiev).ShowModal;
end;

procedure TfrmDashboard.actsys_userExecute(Sender: TObject);
begin
  TfrmSysKullanicilar.Create(Self, Self, TSysKullanici.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_access_rightExecute(Sender: TObject);
begin
  TfrmSysErisimHaklari.Create(Self, Self, TSysErisimHakki.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actteklif_durumlariExecute(Sender: TObject);
begin
  TfrmSetSatTeklifDurumlar.Create(Self, Self, TSetSatTeklifDurum.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actset_teklif_tipleriExecute(Sender: TObject);
begin
  TfrmSetTekTeklifTipleri.Create(Self, Self, TSetTekTeklifTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actquality_form_mail_recieversExecute(Sender: TObject);
begin
  TfrmOthMailRecievers.Create(Self, Self, TOthMailReciever.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actsys_updateExecute(Sender: TObject);
begin
  if CustomMsgDlg('Güncelleme işlemini yapmak istediğin emin misin?',
    mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Güncelleme Onayı') = mrYes
  then
    UpdateApplicationExe;
end;

procedure TfrmDashboard.actrct_iscilik_gideriExecute(Sender: TObject);
begin
  TfrmUrtIscilikler.Create(Self, Self, TUrtIscilik.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actrct_paket_hammaddeExecute(Sender: TObject);
begin
  TfrmRctPaketHammaddeler.Create(Self, Self, TUrtPaketHammadde.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.actrct_receteExecute(Sender: TObject);
begin
  TfrmRctReceteler.Create(Self, Self, TUrtRecete.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmDashboard.btnCloseClick(Sender: TObject);
begin
  if CustomMsgDlg('Uygulama sonlandırılacak. Devam etmek istediğine emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Onay') = mrYes then
    inherited;
end;

procedure TfrmDashboard.btnTestClick(Sender: TObject);
begin
  TfrmStkCinsAilelerX.Create(Self, TServiceContainer.Instance.StkCinsAileService as TStkCinsAileService, TStkCinsAile.Create).Show;
end;

procedure TfrmDashboard.tmrcheck_is_update_requiredTimer(Sender: TObject);
var
  LSurum: string;
  LMr: Integer;
  LQry: TFDQuery;
begin
  //interval değeri kadar süre sonrasında kullanıcı sürüm kotrolü yapıyor
  //süre 60000 olarak 1 dakika olacak şekilde ayarlandı
  LQry := GDataBase.NewQuery();
  try
    LQry.SQL.Text := 'SELECT ' + GSysApplicationSetting.Versiyon.FieldName + ' FROM ' + GSysApplicationSetting.TableName;
    LQry.Open;
    LQry.First;
    LSurum := LQry.Fields.Fields[0].AsString;
  finally
    LQry.Free;
  end;

  if APP_VERSION <> LSurum then
  begin
    LMr := CustomMsgDlg(( 'Programda yeni bir güncellemeniz var. Şimdi güncellemek ister misin?' + AddLBs(2) +
                          'Sistemsel hatalar veya kritik güncellemeler yapıldığı için güncellemeyi bir an önce yapmanız önerilir.'),
                          mtConfirmation,
                          mbYesNo,
                          ['Evet Güncelle', 'Hayır Sonra Güncelle'],
                          mbNo,
                          'Kullanıcı Güncelleme Onayı');
    if LMr = mrYes then
      UpdateApplicationExe;
  end;
end;

procedure TfrmDashboard.UpdateApplicationExe;
const
  SEVENZIP = '7z.dll';
  SETT_NAME = 'GlobalSettings.ini';
  FLD_SETTINGS = 'Settings';
  FLD_REPORT = 'Reports';
  FLD_RESOURCE = 'Resource';
  FLD_LIB = 'Lib';
var
  Path: string;//LNewName, LOldName,
  LAppName, LAppNameBak: string;
begin
  LAppName := ExtractFileName(Application.ExeName);
  LAppNameBak := LAppName.Replace(FILE_EXT_EXE, FILE_EXT_BAK);
  Path := GUygulamaAnaDizin;
(*
  if GSysApplicationSettingsOther.PathUpdate.Value <> '' then
  begin
    if  FileExists(GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + LAppNameBak)
    and FileExists(GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_SETTINGS + PathDelim + SETT_NAME)
    then
    begin
      //The application.exe file is kept with the .bak extension for the possibility of virus infection in the Server.
      DeleteFile(Path + PathDelim + LAppNameBak); //delete local file .bak extension
      RenameFile(Application.ExeName, Path + PathDelim + LAppNameBak);  //rename local file extension .exe to .bak

      LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + LAppNameBak;
      LOldName := Path + PathDelim + LAppName;
      CopyFile(PWideChar(LNewName), PWideChar(LOldName), true); //copy remote .bak to local .exe

      if DeleteFile(Path + FLD_SETTINGS + PathDelim + SETT_NAME) then //delete local settings file
      begin
        LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_SETTINGS + PathDelim + SETT_NAME;
        LOldName := Path + FLD_SETTINGS + PathDelim + SETT_NAME;
        CopyFile(PWideChar(LNewName), PWideChar(LOldName), True); //copy remote settings file to local settings
      end
      else
        raise Exception.Create('Ayar dosyası güncellenemedi!!!');


      LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_REPORT + PathDelim;
      LOldName := Path + FLD_REPORT + PathDelim;
      CopyFolder(LNewName, LOldName); //copy remote report files to local folder

      LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_RESOURCE + PathDelim;
      LOldName := Path + FLD_RESOURCE + PathDelim;
      CopyFolder(LNewName, LOldName); //copy remote resource files to local folder

      //lib klasörü yoksa kopyala
      if not DirectoryExists(Path + FLD_LIB) then
      begin
        LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim;
        LOldName := Path + FLD_LIB + PathDelim;
        CopyFolder(LNewName, LOldName); //copy remote library files to local folder
      end;

      //7z.dll yoksa kopyala
      if not FileExists(Path + FLD_LIB + PathDelim + SEVENZIP)  //local de yoksa
         and FileExists(GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim + SEVENZIP)  //sunucuda varsa
      then
      begin
        LNewName := GSysApplicationSettingsOther.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim + SEVENZIP;
        LOldName := Path + FLD_LIB + PathDelim + SEVENZIP;
        CopyFile(PWideChar(LNewName), PWideChar(LOldName), True); //copy remote settings file to local settings
      end;

      ShellExecute(Handle, 'OPEN', PChar(Application.ExeName), nil, nil, SW_SHOW);  //open updated new file app

      Application.Terminate;
    end
    else
      raise Exception.Create(GSysApplicationSettingsOther.PathUpdate.Value + AddLBs(2) + 'Güncelleme klasöründe dosyalar bulunamadı');
  end
  else
    raise Exception.Create('Güncelleme klasörü sistemde tanımlı değil!!!');
*)
end;

destructor TfrmDashboard.Destroy;
begin
  inherited;
end;

procedure TfrmDashboard.FormActivate(Sender: TObject);
var
  LKurList: TTCMBDovizKuruList;
  LDovizKuru: TChDovizKuru;
  LKurOK: Boolean;
  n1: Integer;
  n2: Integer;
begin
  if not FIsFormShow then
  begin
    FIsFormShow := True;
    LKurOK := False;
    LDovizKuru := TChDovizKuru.Create(GDataBase);
    try
      try
        GDataBase.Connection.StartTransaction;
        LDovizKuru.SelectToList(' AND ' + LDovizKuru.KurTarihi.QryName + '=' + QuotedStr(DateToStr(GDataBase.DateDB)), False, False);
        if LDovizKuru.List.Count = 0 then
        begin
          if CustomMsgDlg(
            TranslateText('Döviz kuru girilmemiş otomatik olarak TCMB Döviz kurlarından girilmesini ister misin?', FrameworkLang.MessageOtomatikDovizKuru, LngMsgData, LngSystem),
            mtConfirmation, mbYesNo, [TranslateText('Evet', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem),
                                      TranslateText('Hayır', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)], mbNo,
                                      TranslateText('Onay', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem)) = mrYes
          then
          begin
            LKurList := TMerkezBankDovizKurlari.TCMB_DovizKurlari(GDataBase.DateDB);
            for n1 := 0 to Length(LKurList)-1 do
              for n2 := 0 to GParaBirimi.List.Count-1 do
                if LKurList[n1].Kod = TSysParaBirimi(GParaBirimi.List[n2]).Para.Value then
                begin
                  LDovizKuru.Clear;
                  LDovizKuru.KurTarihi.Value := LKurList[n1].Tarih;
                  LDovizKuru.Para.Value := LKurList[n1].Kod;
                  LDovizKuru.Kur.Value := LKurList[n1].ForexSelling;
                  LDovizKuru.Insert(False);

                  LKurOK := True;
                  Break;
                end;
            Self.Show;
          end;
        end;

        if LKurOK then
        begin
          LDovizKuru.Clear;
          LDovizKuru.SelectToList(' AND ' + LDovizKuru.Para.QryName + '=' + QuotedStr(GSysApplicationSetting.Para.AsString), False, False);
          if LDovizKuru.List.Count = 0 then
          begin
            LDovizKuru.KurTarihi.Value := GDataBase.DateDB;
            LDovizKuru.Para.Value := GSysApplicationSetting.Para.AsString;
            LDovizKuru.Kur.Value := 1;
            LDovizKuru.Insert(False);
          end;
        end;
      except
        if GDatabase.Connection.InTransaction then
          GDataBase.Connection.Rollback;
      end;
    finally
      if GDatabase.Connection.InTransaction then
        GDataBase.Connection.Commit;
      LDovizKuru.Free;
    end;
  end;
//  BringWindowToTop(Self.Handle);
  SetFocusedControl(Self);
end;

procedure TfrmDashboard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  inherited;
end;

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  inherited;

  GUygulamaAnaDizin := ExtractFilePath(Application.ExeName);

  btnClose.Visible := True;
  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;

//  todo
//  1 yapıldı permision code listesini duzenle butun erisim izinleri kodlar üzerinden yürüyecek şekilde değişklik yap
//  2 standart erisim kodları için döküman ayarla sabit bilgi olarak girilsin
//  3 yapıldı sys visible colum sınıfı için ön yüz hazırla
//  4 kısmen sistem ayarları için sınıf tanımla. ondalıklı hane formatı, para formatı, tarih formatı, butun sistem bu formatlar üzerinde ilerleyecek
//  5 yapıldı Output formda arama penceresini ayarla kısmen yapıldı. kontrol edilecek
//  6 input formlar icin helper penceresi tasarla
//  7 yapıldı excel rapor
//  8 yazıcı ekranı
//  9 detaylı form
//  10 stringgrid base form
end;

procedure TfrmDashboard.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //Key := 0;
end;

procedure TfrmDashboard.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    inherited;
end;

procedure TfrmDashboard.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F6 then
    inherited;
end;

procedure TfrmDashboard.FormShow(Sender: TObject);
  procedure addPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
  begin
    with stbBase.Panels.Add do
    begin
      Width := AWidth;
      Style := AStyle;
    end;
  end;
begin
  inherited;

  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);
  addPanel(80, psOwnerDraw);

  if stbBase.Panels.Count >= STATUS_SQL_SERVER+1 then
    if GDataBase.Connection.Connected then
      stbBase.Panels.Items[STATUS_SQL_SERVER].Text := GDataBase.Connection.Params.Values['Server'];

  if stbBase.Panels.Count >= STATUS_DATE+1 then
    if GDataBase.Connection.Connected then
      stbBase.Panels.Items[STATUS_DATE].Text := DateToStr(GDataBase.GetToday);

  if stbBase.Panels.Count >= STATUS_USERNAME+1 then
    if GDataBase.Connection.Connected then
      stbBase.Panels.Items[STATUS_USERNAME].Text := GSysKullanici.KullaniciAdi.Value;

  if stbBase.Panels.Count >= STATUS_KEY_F4+1 then
    stbBase.Panels.Items[STATUS_KEY_F4].Text := 'F4 ' + TranslateText('DELETE', FrameworkLang.StatusDelete, LngStatus, LngSystem);
  if stbBase.Panels.Count >= STATUS_KEY_F5+1 then
    stbBase.Panels.Items[STATUS_KEY_F5].Text := 'F5 ' + TranslateText('CONFIRM', FrameworkLang.StatusAccept, LngStatus, LngSystem);
  if stbBase.Panels.Count >= STATUS_KEY_F6+1 then
    stbBase.Panels.Items[STATUS_KEY_F6].Text := 'F6 ' + TranslateText('CANCEL', FrameworkLang.StatusCancel, LngStatus, LngSystem);
  if stbBase.Panels.Count >= STATUS_KEY_F7+1 then
    stbBase.Panels.Items[STATUS_KEY_F7].Text := 'F7 ' + TranslateText('ADD RECORD', FrameworkLang.StatusAdd, LngStatus, LngSystem);
  if stbBase.Panels.Count >= STATUS_KEY_F11+1 then
    stbBase.Panels.Items[STATUS_KEY_F11].Text := 'F11 ' + TranslateText('OPACITY', FrameworkLang.StatusOpacity, LngStatus, LngSystem);


  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);

  if GSysKullanici.IsYonetici.Value then
  begin
    mnimenu_system.Visible := True;
  end
  else
  begin
    mnimenu_system.Visible := False;

    tsemployee.TabVisible := False;
    tsaccount.TabVisible := False;
    tsstock.TabVisible := False;
    tssales.TabVisible := False;
    tsgeneral.TabVisible := False;
  end;

  FocusedFirstControl(PageControl1.ActivePage);

  tmrcheck_is_update_required.Enabled := True;

  Caption := Caption + ' v' + APP_VERSION;

  SetSession();
  FIsFormShow := False;

  TUnitOfWork.Initialize(GDataBase.Connection);
end;

procedure TfrmDashboard.ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
var
  nIndex: Integer;
  PanelContainer: TWinControl;

  procedure DisableButtons(Sender: TWinControl);
  var
    nIndex: Integer;
  begin
    if (Sender.ClassType = TButton) then
    begin
      TButton(Sender).Enabled := False;
    end
    else
    begin
      for nIndex := 0 to Sender.ControlCount -1 do
      begin
        if Sender.Controls[nIndex].ClassType = TButton then
          TButton(Sender.Controls[nIndex]).Enabled := False
      end;
    end;
  end;

begin
  PanelContainer := nil;

  if pPanelGroupboxPagecontrolTabsheet = nil then
    PanelContainer := pnlMain
  else
  begin
    if pPanelGroupboxPagecontrolTabsheet.ClassType = TPanel then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TPanel
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TGroupBox then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TGroupBox
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TPageControl then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TPageControl
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TTabSheet then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TTabSheet;
  end;

  if (FormMode=ifmNone) then
  begin
    for nIndex := 0 to PanelContainer.ControlCount -1 do
    begin
      if PanelContainer.Controls[nIndex].ClassType = TPanel then
        DisableButtons(PanelContainer.Controls[nIndex] as TPanel);

      if PanelContainer.Controls[nIndex].ClassType = TGroupBox then
        DisableButtons(PanelContainer.Controls[nIndex] as TGroupBox);

      if PanelContainer.Controls[nIndex].ClassType = TPageControl then
        ResetSession( (PanelContainer.Controls[nIndex] as TPageControl) );
//        for nIndex2 := 0 to (PanelContainer.Controls[nIndex] as TPageControl).PageCount-1 do
//          DisableButtons((PanelContainer.Controls[nIndex] as TPageControl).Pages[nIndex2]);

      if PanelContainer.Controls[nIndex].ClassType = TTabSheet then
//        DisableButtons(PanelContainer.Controls[nIndex] as TTabSheet);
        ResetSession( (PanelContainer.Controls[nIndex] as TTabSheet) );

      if PanelContainer.Controls[nIndex].ClassType = TButton then
        DisableButtons( TButton(PanelContainer.Controls[nIndex]) );
    end;
  end;
end;

procedure TfrmDashboard.SetSession;
var
  LRights: TSysErisimHakki;
  n1: Integer;
begin
  ResetSession(pnlMain);
  btnTest.Enabled := True;
  LRights := TSysErisimHakki.Create(GDataBase);
  try
    LRights.SelectToList(' AND ' + LRights.TableName + '.' + LRights.KullaniciID.FieldName + '=' + VarToStr(GSysKullanici.Id.Value), False, False);
    for n1 := 0 to LRights.List.Count-1 do
    begin
      if (TSysErisimHakki(LRights.List[n1]).IsOkuma.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsEkleme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsGuncelleme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsSilme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsOzel.Value)
      then
      begin
        //Genel
        if CheckStringInArray(MODULE_SISTEM, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SISTEM_AYAR then
          begin
            //
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SISTEM_DIGER then
          begin
            btnsys_olcu_birimleri.Enabled := True;
            btnsys_para_birimleri.Enabled := True;
          end;

        //Genel
        if CheckStringInArray(MODULE_GENEL, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsStock.TabVisible then
            tsStock.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_BBK_AYAR then
          begin
            //
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_BBK_KAYIT then
          begin
            btnbbk_kayit.Enabled := True;
          end;
        end

        //Cari Hesap
        else if CheckStringInArray(MODULE_CH, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsaccount.TabVisible then
            tsaccount.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_CH_AYAR then
          begin
            btnset_ch_grup.Enabled := True;
            btnset_ch_hesap_plani.Enabled := True;
            btnset_ch_vergi_orani.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_CH_KAYIT then
          begin
            btnch_banka.Enabled := True;
            btnch_banka_subesi.Enabled := True;
            btnch_bolge.Enabled := True;
            btnch_hesap_karti.Enabled := True;
            btnch_hesap_karti_ara.Enabled := True;
          end;
        end

        //Muhasebe
        else if CheckStringInArray(MODULE_MHS, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsaccounting.TabVisible then
            tsaccounting.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_MHS_AYAR then
          begin

          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_MHS_DOVIZ_KURU then
          begin
            btnmhs_doviz_kuru.Enabled := True;
          end;
        end

        //Stok Kartı
        else if CheckStringInArray(MODULE_STK, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsStock.TabVisible then
            tsStock.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_STK_KAYIT then
          begin
            btnstk_stok_karti.Enabled := True;
            btnstk_cins_ozelligi.Enabled := True;
            btnstk_stok_ambar.Enabled := True;
            btnstk_stok_grubu.Enabled := True;
          end;
        end
        //Reçete
        else if CheckStringInArray(MODULE_RCT, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsbom.TabVisible then
            tsbom.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_RCT_RECETE_AYAR then
          begin
            btnrct_paket_hammadde.Enabled := True;
            btnrct_iscilik_gideri.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_RCT_RECETE_KAYIT then
          begin
            btnrct_recete.Enabled := True;
          end;
        end
        //Personel
        else if CheckStringInArray(MODULE_PERSONEL, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsemployee.TabVisible then
            tsemployee.TabVisible := True;
          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_PRS_AYAR then
          begin

          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_PRS_KAYIT then
          begin
            btnprs_personel.Enabled := True;
          end
        end
        //Satış
        else if CheckStringInArray(MODULE_TSIF, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tssales.TabVisible then
            tssales.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_TSIF_AYAR then
          begin
//            actset_efatura_fatura_tipi.Enabled := True;
//            actset_efatura_iletisim_kanali.Enabled := True;
//            actset_efatura_istisna_kodu.Enabled := True;
//            actset_teklif_tipleri.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_TEK_KAYIT then
          begin
            btnsat_teklif.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_SIP_KAYIT then
          begin
            btnsat_siparis.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_TEK_RAPOR then
          begin
            btnsat_teklif_rapor.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_SAT_SIP_RAPOR then
          begin
            btnsat_siparis_rapor.Enabled := True;
          end
        end
      end;
    end;
  finally
    FreeAndNil(LRights);
  end;
end;

Initialization

end.
