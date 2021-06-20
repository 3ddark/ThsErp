unit ufrmMain;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  System.Variants,
  System.Math,
  System.StrUtils,
  System.Actions,
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  System.Rtti,
  System.ImageList,
  System.Threading,
  Winapi.ShellAPI,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.ActnList,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  Vcl.DBCtrls,
  Vcl.Dialogs,
  Vcl.ToolWin,
  Vcl.ImgList,
  Vcl.StdActns,
  Vcl.CategoryButtons,
  Vcl.WinXCtrls,
  Vcl.Imaging.pngimage,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.Intf,
  Ths.Erp.Utils.InfoWindow,
  udm,
  ufrmBase,
  ufrmBaseDBGrid,
  Ths.Erp.Database.TableDetailed,
  Ths.Erp.Database.Table, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent;

type
  TfrmMain = class(TfrmBase)
    mniAddLanguageContent: TMenuItem;
    pmButtons: TPopupMenu;
    pb1: TProgressBar;
    PageControl1: TPageControl;
    tsGenel: TTabSheet;
    tssatis: TTabSheet;
    tsstok: TTabSheet;
    tsch: TTabSheet;
    tspersonel: TTabSheet;
    btnch_hesap_karti: TButton;
    ActionListMain: TActionList;
    actsys_kalite_form_tipi: TAction;
    actsys_kalite_form_no: TAction;
    actsys_kaynak_grubu: TAction;
    actsys_kaynak: TAction;
    actsys_kullanici: TAction;
    actsys_erisim_hakki: TAction;
    actsys_grid_kolon: TAction;
    actsys_grid_filtre_siralama: TAction;
    actsys_lisan: TAction;
    actsys_lisan_gui_icerik: TAction;
    actsys_mukellef_tipi: TAction;
    actsys_uygulama_ayari: TAction;
    actsys_uygulama_ayari_diger: TAction;
    actsys_guýn: TAction;
    actsys_ay: TAction;
    actstk_stok_karti: TAction;
    acturun_kabul_red_nedenleri: TAction;
    actquality_form_mail_recievers: TAction;
    actodeme_baslangic_donemleri: TAction;
    actset_teklif_tipleri: TAction;
    actteklif_durumlari: TAction;
    actset_efatura_fatura_tipi: TAction;
    actset_efatura_iletisim_kanali: TAction;
    actset_efatura_istisna_kodu: TAction;
    actsys_database_durum: TAction;
    pmAbout: TPopupMenu;
    mniabout1: TMenuItem;
    mnichange_password: TMenuItem;
    actsys_hakkinda: TAction;
    actsys_sifre_guncelle: TAction;
    actsys_uygulama_guncelle: TAction;
    mniupdate_application: TMenuItem;
    mniN5: TMenuItem;
    mniN6: TMenuItem;
    tmrcheck_is_update_required: TTimer;
    actsys_lisan_data_icerik: TAction;
    pnlToolbar: TPanel;
    imgMenu: TImage;
    lblTitle: TLabel;
    SV: TSplitView;
    catMenuItems: TCategoryButtons;
    actsys_ulke: TAction;
    actsys_sehir: TAction;
    actmhs_doviz_kuru: TAction;
    actsys_para_birimleri: TAction;
    actsys_olcu_birimleri: TAction;
    tlbMain: TToolBar;
    btnabout: TToolButton;
    actset_prs_bolum: TAction;
    actset_prs_birim: TAction;
    actset_prs_gorev: TAction;
    actset_prs_personel_tipi: TAction;
    actset_prs_cinsiyet: TAction;
    actset_prs_askerlik_durumu: TAction;
    actset_prs_rapor_tipi: TAction;
    actset_prs_medeni_durum: TAction;
    actset_prs_lisan_seviyesi: TAction;
    actset_prs_ehliyet: TAction;
    actset_prs_yeterlilik_belgesi: TAction;
    actset_prs_src_tipi: TAction;
    actset_prs_ayrilma_nedeni: TAction;
    actset_prs_mektup_tipi: TAction;
    actset_prs_tatil_tipi: TAction;
    actset_prs_egitim_seviyesi: TAction;
    actset_prs_lisan: TAction;
    actset_utd_dokuman_tipi: TAction;
    actset_utd_dosya_uzantisi: TAction;
    actutd_dokuman: TAction;
    actset_bbk_kayit_tipi: TAction;
    actset_bbk_bolge: TAction;
    actset_bbk_calisma_durumu: TAction;
    actset_bbk_finans_durumu: TAction;
    actset_bbk_firma_tipi: TAction;
    actset_bbk_fuar: TAction;
    actbbk_bolge_sehir: TAction;
    actbbk_kayit_asansor: TAction;
    actsat_teklif: TAction;
    actsat_teklif_rapor: TAction;
    actsat_siparis: TAction;
    actsat_siparis_rapor: TAction;
    actrct_recete: TAction;
    btnch_hesap_karti_ara: TButton;
    actstk_stok_grubu: TAction;
    actx1: TAction;
    actx2: TAction;
    actx3: TAction;
    actx4: TAction;
    actprs_personel_karti: TAction;
    actsys_bolge: TAction;
    actx5: TAction;
    actx6: TAction;
    actx7: TAction;
    actx8: TAction;
    actstk_stok_ambar: TAction;
    actstk_cins_ozelligi: TAction;
    actx9: TAction;
    actch_banka: TAction;
    actch_banka_subesi: TAction;
    btnch_banka: TButton;
    btnch_banka_subesi: TButton;
    actset_ch_firma_tipi: TAction;
    actset_ch_firma_turu: TAction;
    actset_ch_grup: TAction;
    actset_ch_hesap_plani: TAction;
    actset_ch_hesap_tipi: TAction;
    actset_ch_vergi_orani: TAction;
    btnset_ch_grup: TButton;
    btnset_ch_hesap_plani: TButton;
    btnset_ch_vergi_orani: TButton;
    actch_bolge: TAction;
    actch_hesap_karti: TAction;
    actch_hesap_karti_ara: TAction;
    btnch_bolge: TButton;
    actset_stk_urun_tipi: TAction;
    actstk_stok_hareketi: TAction;
    btnstk_stok_karti: TButton;
    btnstk_cins_ozelligi: TButton;
    btnstk_stok_ambar: TButton;
    btnstk_stok_grubu: TButton;
    btnstk_stok_hareketi: TButton;
    btnset_stk_urun_tipi: TButton;
    btnsat_teklif: TButton;
    btnsat_siparis: TButton;
    btnsat_teklif_rapor: TButton;
    btnsat_siparis_rapor: TButton;
    actset_prs_ayrilma_tipi: TAction;
    actset_prs_gecis_sistemi_karti: TAction;
    actset_prs_servis_araci: TAction;
    actprs_personel: TAction;
    btnprs_personel: TButton;
    btnset_prs_bolum: TButton;
    btnset_prs_birim: TButton;
    btnset_prs_gorev: TButton;
    btnset_prs_personel_tipi: TButton;
    btnset_prs_cinsiyet: TButton;
    btnset_prs_medeni_durum: TButton;
    btnset_prs_askerlik_durumu: TButton;
    btnset_prs_servis_araci: TButton;
    btnset_prs_lisan: TButton;
    btnset_prs_lisan_seviyesi: TButton;
    btnset_prs_yeterlilik_belgesi: TButton;
    btnset_prs_mektup_tipi: TButton;
    btnset_prs_egitim_seviyesi: TButton;
    btnset_prs_ehliyet: TButton;
    btnset_prs_ayrilma_nedeni: TButton;
    btnset_prs_ayrilma_tipi: TButton;
    btnset_prs_gecis_sistemi_karti: TButton;
    btnset_prs_rapor_tipi: TButton;
    btnset_prs_src_tipi: TButton;
    btnset_prs_tatil_tipi: TButton;
    btnutd_dokuman: TButton;
    btnbbk_kayit_asansor: TButton;
    tsrecete: TTabSheet;
    btnrct_recete: TButton;
    actset_rct_iscilik_gider_tipi: TAction;
    actrct_iscilik_gideri: TAction;
    actrct_paket_hammadde: TAction;
    btnrct_iscilik_gideri: TButton;
    btnrct_paket_hammadde: TButton;
    tsmhs: TTabSheet;
    btnmhs_doviz_kuru: TButton;

/// <summary>
///   Kullanýcýnýn eriþim yetkisine göre yapýlacak iþlemler burada olacak
/// </summary>
/// <remarks>
///   Login olan kullanýcýya ait haklara göre yapýlacak iþlemler burada yapýlýyor.
///   Ana formda kullanýcýnýn sahip olduðu yetkilere göre butonlar açýlýyor.
/// </remarks>
/// <example>
///   Yeni Kayýt Ekle Buton baþlýðý için ButtonAdd
/// </example>
    procedure SetSession;
    procedure ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
    procedure mniAddLanguageContentClick(Sender: TObject);
    procedure actsys_kaynak_grubuExecute(Sender: TObject);
    procedure actsys_kaynakExecute(Sender: TObject);
    procedure actsys_kullaniciExecute(Sender: TObject);
    procedure actsys_erisim_hakkiExecute(Sender: TObject);
    procedure actsys_grid_kolonExecute(Sender: TObject);
    procedure actsys_grid_filtre_siralamaExecute(Sender: TObject);
    procedure actsys_lisanExecute(Sender: TObject);
    procedure actsys_lisan_gui_icerikExecute(Sender: TObject);
    procedure actsys_mukellef_tipiExecute(Sender: TObject);
    procedure actsys_uygulama_ayariExecute(Sender: TObject);
    procedure actsys_uygulama_ayari_digerExecute(Sender: TObject);
    procedure actsys_ayExecute(Sender: TObject);
    procedure actsys_guýnExecute(Sender: TObject);
    procedure actsys_kalite_form_tipiExecute(Sender: TObject);
    procedure actsys_kalite_form_noExecute(Sender: TObject);
    procedure acturun_kabul_red_nedenleriExecute(Sender: TObject);
    procedure actquality_form_mail_recieversExecute(Sender: TObject);
    procedure actodeme_baslangic_donemleriExecute(Sender: TObject);
    procedure actset_teklif_tipleriExecute(Sender: TObject);
    procedure actteklif_durumlariExecute(Sender: TObject);
    procedure actset_efatura_fatura_tipiExecute(Sender: TObject);
    procedure actset_efatura_iletisim_kanaliExecute(Sender: TObject);
    procedure actset_efatura_istisna_koduExecute(Sender: TObject);
    procedure actsys_database_durumExecute(Sender: TObject);
    procedure actsys_hakkindaExecute(Sender: TObject);
    procedure actsys_sifre_guncelleExecute(Sender: TObject);
    procedure actsys_uygulama_guncelleExecute(Sender: TObject);
    procedure tmrcheck_is_update_requiredTimer(Sender: TObject);
    procedure actsys_lisan_data_icerikExecute(Sender: TObject);
    procedure imgMenuClick(Sender: TObject);
    procedure actsys_ulkeExecute(Sender: TObject);
    procedure actsys_sehirExecute(Sender: TObject);
    procedure actmhs_doviz_kuruExecute(Sender: TObject);
    procedure actset_prs_bolumExecute(Sender: TObject);
    procedure actset_prs_egitim_seviyesiExecute(Sender: TObject);
    procedure actset_prs_tatil_tipiExecute(Sender: TObject);
    procedure actset_prs_mektup_tipiExecute(Sender: TObject);
    procedure actset_prs_ayrilma_nedeniExecute(Sender: TObject);
    procedure actset_prs_src_tipiExecute(Sender: TObject);
    procedure actset_prs_yeterlilik_belgesiExecute(Sender: TObject);
    procedure actset_prs_ehliyetExecute(Sender: TObject);
    procedure actset_prs_lisan_seviyesiExecute(Sender: TObject);
    procedure actset_prs_lisanExecute(Sender: TObject);
    procedure actset_prs_medeni_durumExecute(Sender: TObject);
    procedure actset_prs_rapor_tipiExecute(Sender: TObject);
    procedure actset_prs_askerlik_durumuExecute(Sender: TObject);
    procedure actset_prs_cinsiyetExecute(Sender: TObject);
    procedure actset_prs_personel_tipiExecute(Sender: TObject);
    procedure actset_prs_gorevExecute(Sender: TObject);
    procedure actset_prs_birimExecute(Sender: TObject);
    procedure ActionListMainExecute(Action: TBasicAction; var Handled: Boolean);
    procedure actsys_para_birimleriExecute(Sender: TObject);
    procedure actsys_olcu_birimleriExecute(Sender: TObject);
    procedure actset_utd_dokuman_tipiExecute(Sender: TObject);
    procedure actset_utd_dosya_uzantisiExecute(Sender: TObject);
    procedure actutd_dokumanExecute(Sender: TObject);
    procedure actset_bbk_kayit_tipiExecute(Sender: TObject);
    procedure actset_bbk_bolgeExecute(Sender: TObject);
    procedure actset_bbk_calisma_durumuExecute(Sender: TObject);
    procedure actset_bbk_finans_durumuExecute(Sender: TObject);
    procedure actset_bbk_firma_tipiExecute(Sender: TObject);
    procedure actset_bbk_fuarExecute(Sender: TObject);
    procedure actbbk_bolge_sehirExecute(Sender: TObject);
    procedure actbbk_kayit_asansorExecute(Sender: TObject);
    procedure actsat_teklifExecute(Sender: TObject);
    procedure actrct_receteExecute(Sender: TObject);
    procedure actstk_stok_grubuExecute(Sender: TObject);
    procedure actstk_cins_ozelligiExecute(Sender: TObject);
    procedure actstk_stok_ambarExecute(Sender: TObject);
    procedure actch_bankaExecute(Sender: TObject);
    procedure actch_banka_subesiExecute(Sender: TObject);
    procedure actch_hesap_karti_araExecute(Sender: TObject);
    procedure actch_hesap_kartiExecute(Sender: TObject);
    procedure actch_bolgeExecute(Sender: TObject);
    procedure actset_ch_firma_tipiExecute(Sender: TObject);
    procedure actset_ch_firma_turuExecute(Sender: TObject);
    procedure actset_ch_grupExecute(Sender: TObject);
    procedure actset_ch_hesap_planiExecute(Sender: TObject);
    procedure actset_ch_hesap_tipiExecute(Sender: TObject);
    procedure actset_ch_vergi_oraniExecute(Sender: TObject);
    procedure actset_stk_urun_tipiExecute(Sender: TObject);
    procedure actstk_stok_kartiExecute(Sender: TObject);
    procedure actstk_stok_hareketiExecute(Sender: TObject);
    procedure actprs_personelExecute(Sender: TObject);
    procedure actset_prs_servis_araciExecute(Sender: TObject);
    procedure actsat_siparis_raporExecute(Sender: TObject);
    procedure actsat_siparisExecute(Sender: TObject);
    procedure actrct_iscilik_gideriExecute(Sender: TObject);
    procedure actrct_paket_hammaddeExecute(Sender: TObject);
    procedure actset_rct_iscilik_gider_tipiExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FIsFormShow: Boolean;
    procedure SetTitleFromLangContent(Sender: TControl = nil);
    procedure SetButtonPopup(Sender: TControl = nil);
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
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Vcl.Themes,
  ufrmAbout,
  Ths.Erp.Utils.FluentXML,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Constants,
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  ufrmSysLisanGuiIcerik,
  ufrmSysSifreGuncelle,
  NetGsm_SMS,

  Ths.Erp.Database.Table.SysUlke, ufrmSysUlkeler,
  Ths.Erp.Database.Table.SysSehir, ufrmSysSehirler,
  Ths.Erp.Database.Table.SysKullanici, ufrmSysKullanicilar,
  Ths.Erp.Database.Table.SysErisimHakki, ufrmSysErisimHaklari,
  Ths.Erp.Database.Table.SysKaynakGrup, ufrmSysKaynakGruplari,
  Ths.Erp.Database.Table.SysKaynak, ufrmSysKaynaklar,
  Ths.Erp.Database.Table.SysLisan, ufrmSysLisanlar,
  Ths.Erp.Database.Table.SysGun, ufrmSysGunler,
  Ths.Erp.Database.Table.SysAy, ufrmSysAylar,
  Ths.Erp.Database.Table.SysLisanGuiIcerik, ufrmSysLisanGuiIcerikler,
  Ths.Erp.Database.Table.SysGridKolon, ufrmSysGridKolonlar,
  Ths.Erp.Database.Table.SysLisanDataIcerik, ufrmSysLisanDataIcerikler,
  Ths.Erp.Database.Table.SysKaliteFormNo, ufrmSysKaliteFormNolar,
  Ths.Erp.Database.Table.SysKaliteFormTipi, ufrmSysKaliteFormTipleri,
  Ths.Erp.Database.Table.SysGridFiltreSiralama, ufrmSysGridFiltreSiralamalar,
  Ths.Erp.Database.Table.SysOlcuBirimi, ufrmSysOlcuBirimleri,
  Ths.Erp.Database.Table.SysParaBirimi, ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.SysMukellefTipi, ufrmSysMukellefTipleri,
  Ths.Erp.Database.Table.SysUygulamaAyari, ufrmSysUygulamaAyari,
  Ths.Erp.Database.Table.SysUygulamaAyariDiger, ufrmSysUygulamaAyariDiger,
  Ths.Erp.Database.Table.View.SysDbStatus, ufrmSysDbStatus,

  Ths.Erp.Database.Table.MhsDovizKuru, ufrmMhsDovizKurlari,

  Ths.Erp.Database.Table.PrsPersonel, ufrmPrsPersoneller,
  Ths.Erp.Database.Table.PrsPersonelGecmisi,
  Ths.Erp.Database.Table.PrsLisanBilgisi, ufrmPrsLisanBilgileri,
  Ths.Erp.Database.Table.PrsSrcBilgisi, ufrmPrsSrcBilgileri,
  Ths.Erp.Database.Table.PrsEhliyetBilgisi, ufrmPrsEhliyetBilgileri,
  Ths.Erp.Database.Table.SetPrsBolum, ufrmSetPrsBolumler,
  Ths.Erp.Database.Table.SetPrsBirim, ufrmSetPrsBirimler,
  Ths.Erp.Database.Table.SetPrsGorev, ufrmSetPrsGorevler,
  Ths.Erp.Database.Table.SetPrsPersonelTipi, ufrmSetPrsPersonelTipleri,
  Ths.Erp.Database.Table.SetPrsCinsiyet, ufrmSetPrsCinsiyetler,
  Ths.Erp.Database.Table.SetPrsAskerlikDurumu, ufrmSetPrsAskerlikDurumlari,
  Ths.Erp.Database.Table.SetPrsRaporTipi, ufrmSetPrsRaporTipleri,
  Ths.Erp.Database.Table.SetPrsAyrilmaTipi, ufrmSetPrsAyrilmaTipleri,
  Ths.Erp.Database.Table.SetPrsMedeniDurum, ufrmSetPrsMedeniDurumlar,
  Ths.Erp.Database.Table.SetPrsLisan, ufrmSetPrsLisanlar,
  Ths.Erp.Database.Table.SetPrsLisanSeviyesi, ufrmSetPrsLisanSeviyeleri,
  Ths.Erp.Database.Table.SetPrsEhliyet, ufrmSetPrsEhliyetler,
  Ths.Erp.Database.Table.SetPrsYeterlilikBelgesi, ufrmSetPrsYeterlilikBelgeleri,
  Ths.Erp.Database.Table.SetPrsSrcTipi, ufrmSetPrsSrcTipleri,
  Ths.Erp.Database.Table.SetPrsAyrilmaNedeni, ufrmSetPrsAyrilmaNedenleri,
  Ths.Erp.Database.Table.SetPrsMektupTipi, ufrmSetPrsMektupTipleri,
  Ths.Erp.Database.Table.SetPrsTatilTipi, ufrmSetPrsTatilTipleri,
  Ths.Erp.Database.Table.SetPrsServisAraci, ufrmSetPrsServisAraclari,
  Ths.Erp.Database.Table.SetPrsEgitimSeviyesi, ufrmSetPrsEgitimSeviyeleri,

  Ths.Erp.Database.Table.SetEinvFaturaTipi, ufrmSetEinvFaturaTipleri,
  Ths.Erp.Database.Table.SetEinvIstisnaKodu, ufrmSetEinvIstisnaKodlari,

  Ths.Erp.Database.Table.SetTekTeklifTipi, ufrmSetTekTeklifTipleri,
  Ths.Erp.Database.Table.SetSatTeklifDurum, ufrmSetSatTeklifDurumlar,
  Ths.Erp.Database.Table.SatTeklif, ufrmSatTeklifler,

  Ths.Erp.Database.Table.SetSatSiparisDurum, ufrmSetSatSiparisDurumlar,
  Ths.Erp.Database.Table.SatSiparis, ufrmSatSiparisler,
  Ths.Erp.Database.Table.SatSiparisRapor, ufrmSatSiparislerRapor,

  Ths.Erp.Database.Table.RctRecete, ufrmRctReceteler,
  Ths.Erp.Database.Table.SetRctIscilikGiderTipi, ufrmSetRctIscilikGiderTipleri,
  Ths.Erp.Database.Table.RctIscilikGideri, ufrmRctIscilikGiderleri,
  Ths.Erp.Database.Table.RctPaketHammadde, ufrmRctPaketHammaddeler,

  Ths.Erp.Database.Table.SetChFirmaTipi, ufrmSetChFirmaTipleri,
  Ths.Erp.Database.Table.SetChFirmaTuru, ufrmSetChFirmaTurleri,
  Ths.Erp.Database.Table.SetChGrup, ufrmSetChGruplar,
  Ths.Erp.Database.Table.SetChHesapPlani, ufrmSetChHesapPlanlari,
  Ths.Erp.Database.Table.SetChHesapTipi, ufrmSetChHesapTipleri,
  Ths.Erp.Database.Table.SetChVergiOrani, ufrmSetChVergiOranlari,
  Ths.Erp.Database.Table.ChBanka, ufrmChBankalar,
  Ths.Erp.Database.Table.ChBankaSubesi, ufrmChBankaSubeleri,
  Ths.Erp.Database.Table.ChBolge, ufrmChBolgeler,
  Ths.Erp.Database.Table.ChHesapKarti, ufrmChHesapKartlari,
  Ths.Erp.Database.Table.ChHesapKartiAra, ufrmChHesapKartlariAra,

  Ths.Erp.Database.Table.SetStkUrunTipi, ufrmSetStkUrunTipleri,
  Ths.Erp.Database.Table.StkCinsOzelligi, ufrmStkCinsOzellikleri,
  Ths.Erp.Database.Table.StkStokGrubu, ufrmStkStokGruplari,
  Ths.Erp.Database.Table.StkStokKarti, ufrmStkStokKartlari,
  Ths.Erp.Database.Table.StkStokHareketi, ufrmStkStokHareketleri,
  Ths.Erp.Database.Table.StkStokAmbar, ufrmStkStokAmbarlar,

  Ths.Erp.Database.Table.SetUtdDokumanTipi, ufrmSetUtdDokumanTipleri,
  Ths.Erp.Database.Table.SetUtdDosyaUzantisi, ufrmSetUtdDosyaUzantilari,
  Ths.Erp.Database.Table.UtdDokuman, ufrmUtdDokumanlar,

  Ths.Erp.Database.Table.AyarEFaturaIletisimKanali, ufrmAyarEFaturaIletisimKanallari,
  Ths.Erp.Database.Table.UrunKabulRedNedeni, ufrmUrunKabulRedNedenleri,
  Ths.Erp.Database.Table.OthMailReciever, ufrmOthMailRecievers,
  Ths.Erp.Database.Table.SetOdemeBaslangicDonemi, ufrmSetOdemeBaslangicDonemleri,

  Ths.Erp.Database.Table.Arac.Arac, ufrmAracTakipAraclar,

  Ths.Erp.Database.Table.SetBbkKayitTipi, ufrmSetBbkKayitTipleri,
  Ths.Erp.Database.Table.SetBbkBolge, ufrmSetBbkBolgeler,
  Ths.Erp.Database.Table.SetBbkCalismaDurumu, ufrmSetBbkCalismaDurumlari,
  Ths.Erp.Database.Table.SetBbkFinansDurumu, ufrmSetBbkFinansDurumlari,
  Ths.Erp.Database.Table.SetBbkFirmatipi, ufrmSetBbkFirmaTipleri,
  Ths.Erp.Database.Table.SetBbkFuar, ufrmSetBbkFuarlar,
  Ths.Erp.Database.Table.BbkBolgeSehir, ufrmBbkBolgeSehirler,
  Ths.Erp.Database.Table.BbkKayit, ufrmBbkKayitlar;

procedure TfrmMain.actsys_hakkindaExecute(Sender: TObject);
var
  LTs: TTabSheet;
begin
  LTs := PageControl1.ActivePage;
  TfrmAbout.Create(Application).ShowModal;
  SetSession;

  if LTs.TabVisible then
    PageControl1.ActivePage := LTs;
end;

procedure TfrmMain.actbbk_bolge_sehirExecute(Sender: TObject);
begin
  TfrmBbkBolgeSehirler.Create(Self, Self, TBbkBolgeSehir.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actbbk_kayit_asansorExecute(Sender: TObject);
begin
  TfrmBbkKayitlar.Create(Self, Self, TBbkKayit.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actch_bankaExecute(Sender: TObject);
begin
  TfrmChBankalar.Create(Self, Self, TChBanka.Create(GDataBase)).Show;
end;

procedure TfrmMain.actch_banka_subesiExecute(Sender: TObject);
begin
  TfrmChBankaSubeleri.Create(Self, Self, TChBankaSubesi.Create(GDataBase)).Show;
end;

procedure TfrmMain.actch_bolgeExecute(Sender: TObject);
begin
  TfrmChBolgeler.Create(Self, Self, TChBolge.Create(GDataBase)).Show;
end;

procedure TfrmMain.actch_hesap_kartiExecute(Sender: TObject);
begin
  TfrmHesapKartlari.Create(Self, Self, TChHesapKarti.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actch_hesap_karti_araExecute(Sender: TObject);
begin
  TfrmHesapKartlariAra.Create(Self, Self, TChHesapKartiAra.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_sifre_guncelleExecute(Sender: TObject);
var
  vUser: TSysKullanici;
begin
  vUser := TSysKullanici(GSysKullanici.Clone);
  TfrmSysSifreGuncelle.Create(Self, nil, vUser, ifmUpdate).ShowModal;
end;

procedure TfrmMain.ActionListMainExecute(Action: TBasicAction; var Handled: Boolean);
begin
  if SV.Opened then
    SV.Opened := not SV.Opened;
end;

procedure TfrmMain.actodeme_baslangic_donemleriExecute(Sender: TObject);
begin
  TfrmSetOdemeBaslangicDonemleri.Create(Self, Self, TSetOdemeBaslangicDonemi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actprs_personelExecute(Sender: TObject);
begin
  TfrmPrsPersoneller.Create(Self, Self, TPrsPersonel.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsat_siparisExecute(Sender: TObject);
begin
  TfrmSatSiparisler.Create(Self, Self, TSatSiparis.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsat_siparis_raporExecute(Sender: TObject);
begin
  TfrmSatSiparislerRapor.Create(Self, Self, TSatSiparisRapor.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsat_teklifExecute(Sender: TObject);
begin
  TfrmSatTeklifler.Create(Self, Self, TSatTeklif.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_bbk_bolgeExecute(Sender: TObject);
begin
  TfrmSetBbkBolgeler.Create(Self, Self, TSetBbkBolge.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_bbk_calisma_durumuExecute(Sender: TObject);
begin
  TfrmSetBbkCalismaDurumlari.Create(Self, Self, TSetBbkCalismaDurumu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_bbk_finans_durumuExecute(Sender: TObject);
begin
  TfrmSetBbkFinansDurumlari.Create(Self, Self, TSetBbkFinansDurumu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_bbk_firma_tipiExecute(Sender: TObject);
begin
  TfrmSetBbkFirmaTipleri.Create(Self, Self, TSetBbkFirmaTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_bbk_fuarExecute(Sender: TObject);
begin
  TfrmSetBbkFuarlar.Create(Self, Self, TSetBbkFuar.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_bbk_kayit_tipiExecute(Sender: TObject);
begin
  TfrmSetBbkKayitTipleri.Create(Self, Self, TSetBbkKayitTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_ch_firma_tipiExecute(Sender: TObject);
begin
  TfrmSetChFirmaTipleri.Create(Self, Self, TSetChFirmaTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_ch_firma_turuExecute(Sender: TObject);
begin
  TfrmSetChFirmaTurleri.Create(Self, Self, TSetChFirmaTuru.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_ch_grupExecute(Sender: TObject);
begin
  TfrmSetChGruplar.Create(Self, Self, TSetChGrup.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_ch_hesap_planiExecute(Sender: TObject);
begin
  TfrmSetChHesapPlanlari.Create(Self, Self, TSetChHesapPlani.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_ch_hesap_tipiExecute(Sender: TObject);
begin
  TfrmSetChHesapTipleri.Create(Self, Self, TSetChHesapTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_ch_vergi_oraniExecute(Sender: TObject);
begin
  TfrmSetChVergiOranlari.Create(Self, Self, TSetChVergiOrani.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_efatura_fatura_tipiExecute(Sender: TObject);
begin
  TfrmSetEinvFaturaTipleri.Create(Self, Self, TSetEinvFaturaTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_efatura_iletisim_kanaliExecute(Sender: TObject);
begin
  TfrmAyarEFaturaIletisimKanallari.Create(Self, Self, TAyarEFaturaIletisimKanali.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_efatura_istisna_koduExecute(Sender: TObject);
begin
  TfrmSetEinvIstisnaKodlari.Create(Self, Self, TSetEinvIstisnaKodu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_askerlik_durumuExecute(Sender: TObject);
begin
  TfrmSetPrsAskerlikDurumlari.Create(Self, Self, TSetPrsAskerlikDurumu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_ayrilma_nedeniExecute(Sender: TObject);
begin
  TfrmSetPrsAyrilmaNedenleri.Create(Self, Self, TSetPrsAyrilmaNedeni.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_birimExecute(Sender: TObject);
begin
  TfrmSetPrsBirimler.Create(Self, Self, TSetPrsBirim.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_bolumExecute(Sender: TObject);
begin
  TfrmSetPrsBolumler.Create(Self, Self, TSetPrsBolum.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_cinsiyetExecute(Sender: TObject);
begin
  TfrmSetPrsCinsiyetler.Create(Self, Self, TSetPrsCinsiyet.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_egitim_seviyesiExecute(Sender: TObject);
begin
  TfrmSetPrsEgitimSeviyeleri.Create(Self, Self, TSetPrsEgitimSeviyesi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_ehliyetExecute(Sender: TObject);
begin
  TfrmSetPrsEhliyetler.Create(Self, Self, TSetPrsEhliyet.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_gorevExecute(Sender: TObject);
begin
  TfrmSetPrsGorevler.Create(Self, Self, TSetPrsGorev.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_lisanExecute(Sender: TObject);
begin
  TfrmSetPrsLisanlar.Create(Self, Self, TSetPrsLisan.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_lisan_seviyesiExecute(Sender: TObject);
begin
  TfrmSetPrsLisanSeviyeleri.Create(Self, Self, TSetPrsLisanSeviyesi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_medeni_durumExecute(Sender: TObject);
begin
  TfrmSetPrsMedeniDurumlar.Create(Self, Self, TSetPrsMedeniDurum.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_mektup_tipiExecute(Sender: TObject);
begin
  TfrmSetPrsMektupTipleri.Create(Self, Self, TSetPrsMektupTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_yeterlilik_belgesiExecute(Sender: TObject);
begin
  TfrmSetPrsYeterlilikBelgeleri.Create(Self, Self, TSetPrsYeterlilikBelgesi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_rct_iscilik_gider_tipiExecute(Sender: TObject);
//var
//  LServis: smsnn;
//  LCevap: string;
//  HTTPCli: TNetHTTPClient;
//  rsp: IHTTPResponse;
begin
  TfrmSetRctIscilikGiderTipleri.Create(Self, Self, TSetRctIscilikGiderTipi.Create(GDataBase), fomNormal).Show;
//  LServis := Getsmsnn();
//  LCevap := LServis.smsGonder1NV2(
//    '2163945055',
//    'AYBEY5055',
//    'AYBEY ELEK.',
//    'Delphi SOAP mesaj gönderme örek',
//    ['905556258796'],
//    'TR',
//    '',
//    '',
//    '1834siner',
//    0);
//
//
//  try
//    HTTPCli := TNetHTTPClient.Create(nil);
//    try
//      rsp := HTTPCli.Get('https://api.netgsm.com.tr/sms/send/get/?' +
//        'usercode=' + '2163945055' + '&' +
//        'password=' + 'AYBEY5055' + '&' +
//        'gsmno=' + '5556258796' + '&' +
//        'message=' + 'Delphi7 Indy sms ornek' + '&' +
//        'msgheader=' + 'AYBEY ELEK.');
//      LCevap := rsp.ContentAsString(TEncoding.UTF8);
//    finally
//      HTTPCli.Free;
//    end;
//  except
//    on E: Exception do
//      ShowMessage(E.ClassName, ': ', E.Message);
//  end;
//
//  ShowMessage(LCevap);
end;

procedure TfrmMain.actset_stk_urun_tipiExecute(Sender: TObject);
begin
  if not ExistForm(TfrmSetStkUrunTipleri) then
    TfrmSetStkUrunTipleri.Create(Self, Self, TSetStkUrunTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_personel_tipiExecute(Sender: TObject);
begin
  TfrmSetPrsPersonelTipleri.Create(Self, Self, TSetPrsPersonelTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_rapor_tipiExecute(Sender: TObject);
begin
  TfrmSetPrsRaporTipleri.Create(Self, Self, TSetPrsRaporTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_servis_araciExecute(Sender: TObject);
begin
  TfrmSetPrsServisAraclari.Create(Self, Self, TSetPrsServisAraci.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_src_tipiExecute(Sender: TObject);
begin
  TfrmSetPrsSrcTipleri.Create(Self, Self, TSetPrsSrcTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_prs_tatil_tipiExecute(Sender: TObject);
begin
  TfrmSetPrsTatilTipleri.Create(Self, Self, TSetPrsTatilTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_utd_dokuman_tipiExecute(Sender: TObject);
begin
  TfrmSetUtdDokumanTipleri.Create(Self, Self, TSetUtdDokumanTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_utd_dosya_uzantisiExecute(Sender: TObject);
begin
  TfrmSetUtdDosyaUzantilari.Create(Self, Self, TSetUtdDosyaUzantisi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actstk_cins_ozelligiExecute(Sender: TObject);
begin
  TfrmStkCinsOzellikleri.Create(Self, Self, TStkCinsOzelligi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actstk_stok_ambarExecute(Sender: TObject);
begin
  TfrmStkStokAmbarlar.Create(Self, Self, TStkStokAmbar.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actstk_stok_grubuExecute(Sender: TObject);
begin
  TfrmStkStokGruplari.Create(Self, Self, TStkStokGrubu.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actstk_stok_hareketiExecute(Sender: TObject);
begin
  TfrmStkStokHareketleri.Create(Self, Self, TStkStokHareketi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actstk_stok_kartiExecute(Sender: TObject);
begin
  TfrmStkStokKartlari.Create(Self, Self, TStkStokKarti.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_sehirExecute(Sender: TObject);
begin
  TfrmSysSehirler.Create(Self, Self, TSysSehir.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_grid_kolonExecute(Sender: TObject);
begin
  TfrmSysGridKolonlar.Create(Self, Self, TSysGridKolon.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_ulkeExecute(Sender: TObject);
begin
  TfrmSysUlkeler.Create(Self, Self, TSysUlke.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_guýnExecute(Sender: TObject);
begin
  TfrmSysGunler.Create(Self, Self, TSysGun.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_database_durumExecute(Sender: TObject);
begin
  TfrmSysDbStatus.Create(Self, Self, TSysDBStatus.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_grid_filtre_siralamaExecute(Sender: TObject);
begin
  TfrmSysGridFiltreSiralamalar.Create(Self, Self, TSysGridFiltreSiralama.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actmhs_doviz_kuruExecute(Sender: TObject);
begin
  TfrmMhsDovizKurlari.Create(Self, Self, TMhsDovizKuru.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_lisanExecute(Sender: TObject);
begin
  TfrmSysLisanlar.Create(Self, Self, TSysLisan.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_lisan_data_icerikExecute(Sender: TObject);
begin
  TfrmSysLisanDataIcerikler.Create(Self, Self, TSysLisanDataIcerik.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_lisan_gui_icerikExecute(Sender: TObject);
begin
  TfrmSysLisanGuiIcerikler.Create(Self, Self, TSysLisanGuiIcerik.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_ayExecute(Sender: TObject);
begin
  TfrmSysAylar.Create(Self, Self, TSysAy.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_olcu_birimleriExecute(Sender: TObject);
begin
  TfrmSysOlcuBirimleri.Create(Self, Self, TSysOlcuBirimi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_uygulama_ayari_digerExecute(Sender: TObject);
var
  vApplicationSettingOther: TSysUygulamaAyariDiger;
begin
  vApplicationSettingOther := TSysUygulamaAyariDiger.Create(GDataBase);
  vApplicationSettingOther.SelectToList('', False);
  if vApplicationSettingOther.List.Count = 0 then
  begin
    vApplicationSettingOther.Clear;
    TfrmSysUygulamaAyariDiger.Create(Self, nil, vApplicationSettingOther, ifmNewRecord).ShowModal
  end else if vApplicationSettingOther.List.Count = 1 then
    TfrmSysUygulamaAyariDiger.Create(Self, nil, vApplicationSettingOther, ifmRewiev).ShowModal;
end;

procedure TfrmMain.actsys_para_birimleriExecute(Sender: TObject);
begin
  TfrmSysParaBirimleri.Create(Self, Self, TSysParaBirimi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_kaynakExecute(Sender: TObject);
begin
  TfrmSysKaynaklar.Create(Self, Self, TSysKaynak.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_kaynak_grubuExecute(Sender: TObject);
begin
  TfrmSysKaynakGruplari.Create(Self, Self, TSysKaynakGrup.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_kalite_form_noExecute(Sender: TObject);
begin
  TfrmSysKaliteFormNolar.Create(Self, Self, TSysQualityFormNumber.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_kalite_form_tipiExecute(Sender: TObject);
begin
  TfrmSysKaliteFormTipleri.Create(Self, Self, TSysKaliteFormTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_uygulama_ayariExecute(Sender: TObject);
var
  vApplicationSetting: TSysUygulamaAyari;
begin
  vApplicationSetting := TSysUygulamaAyari.Create(GDataBase);
  vApplicationSetting.SelectToList('', False);
  if vApplicationSetting.List.Count = 0 then
  begin
    vApplicationSetting.Clear;
    TfrmSysUygulamaAyari.Create(Self, nil, vApplicationSetting, ifmNewRecord).ShowModal
  end else if vApplicationSetting.List.Count = 1 then
    TfrmSysUygulamaAyari.Create(Self, nil, vApplicationSetting, ifmRewiev).ShowModal;
end;

procedure TfrmMain.actsys_mukellef_tipiExecute(Sender: TObject);
begin
  TfrmSysMukellefTipleri.Create(Self, Self, TSysMukellefTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_kullaniciExecute(Sender: TObject);
begin
  TfrmSysKullanicilar.Create(Self, Self, TSysKullanici.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_erisim_hakkiExecute(Sender: TObject);
begin
  TfrmSysUserAccessRights.Create(Self, Self, TSysErisimHakki.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actteklif_durumlariExecute(Sender: TObject);
begin
  TfrmSetSatTeklifDurumlar.Create(Self, Self, TSetSatTeklifDurum.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actset_teklif_tipleriExecute(Sender: TObject);
begin
  TfrmSetTekTeklifTipleri.Create(Self, Self, TSetTekTeklifTipi.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actquality_form_mail_recieversExecute(Sender: TObject);
begin
  TfrmOthMailRecievers.Create(Self, Self, TOthMailReciever.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actsys_uygulama_guncelleExecute(Sender: TObject);
begin
  if CustomMsgDlg('Güncelleme iþlemini yapmak istediðin emin misin?',
    mtConfirmation, mbYesNo, ['Evet', 'Hayýr'], mbNo, 'Güncelleme Onayý') = mrYes
  then
    UpdateApplicationExe;
end;

procedure TfrmMain.actrct_iscilik_gideriExecute(Sender: TObject);
begin
  TfrmRctIscilikGiderleri.Create(Self, Self, TRctIscilikGideri.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actrct_paket_hammaddeExecute(Sender: TObject);
begin
  TfrmRctPaketHammaddeler.Create(Self, Self, TRctPaketHammadde.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actrct_receteExecute(Sender: TObject);
begin
  TfrmRctReceteler.Create(Self, Self, TRctRecete.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.acturun_kabul_red_nedenleriExecute(Sender: TObject);
begin
  TfrmUrunKabulRedNedenleri.Create(Self, Self, TUrunKabulRedNedeni.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.actutd_dokumanExecute(Sender: TObject);
begin
  TfrmUtdDokumanlar.Create(Self, Self, TUtdDokuman.Create(GDataBase), fomNormal).Show;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  if CustomMsgDlg(
    TranslateText('Uygulama kapatýlacak. Kapatmak istediðine emin misin?', FrameworkLang.MessageApplicationTerminate, LngMsgData, LngSystem),
    mtConfirmation, mbYesNo, [TranslateText('Evet', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem),
                              TranslateText('Hayýr', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)], mbNo,
                              TranslateText('Onay', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem)) = mrYes
  then
    inherited;
end;

procedure TfrmMain.SetTitleFromLangContent(Sender: TControl);
var
  n1: Integer;
  LText: string;
begin
  //Ana formdaki butonlarýn isimleri þu formata uygun olacak. btn + herhangi bir isim btnCity veya btncity
  //dil dosyasýna bakarken de "ButonCaption.Main.city" þeklinde olacak
  if Sender = nil then
  begin
    Sender := pnlMain;
    SetTitleFromLangContent(Sender);
  end;


  for n1 := 0 to TWinControl(Sender).ControlCount-1 do
  begin
    if TWinControl(Sender).Controls[n1].ClassType = TPageControl then
      SetTitleFromLangContent(TWinControl(Sender).Controls[n1])
    else if TWinControl(Sender).Controls[n1].ClassType = TTabSheet then
    begin
      LText :=
        TranslateText(
          TTabSheet(TWinControl(Sender).Controls[n1]).Caption,
          StringReplace(TTabSheet(TWinControl(Sender).Controls[n1]).Name, PRX_TABSHEET, '', [rfReplaceAll]),
          LngTab, LngMainTable
        );
      if LText <> '' then
        TTabSheet(TWinControl(Sender).Controls[n1]).Caption := LText;

      SetTitleFromLangContent(TWinControl(Sender).Controls[n1])
    end
    else if TWinControl(Sender).Controls[n1].ClassType = TButton then
    begin
      LText :=
          TranslateText(
              TButton(TWinControl(Sender).Controls[n1]).Caption,
              StringReplace(TButton(TWinControl(Sender).Controls[n1]).Name, PRX_BUTTON, '', [rfReplaceAll]),
              LngButton, LngMainTable
          );
      if LText <> '' then
        TButton(TWinControl(Sender).Controls[n1]).Caption := LText;
    end;
  end;
end;

procedure TfrmMain.tmrcheck_is_update_requiredTimer(Sender: TObject);
var
  LSurum: string;
  LMr: Integer;
  LQry: TFDQuery;
begin
  //interval deðeri kadar süre sonrasýnda kullanýcý sürüm kotrolü yapýyor
  //süre 60000 olarak 1 dakika olacak þekilde ayarlandý
  LQry := GDataBase.NewQuery();
  try
    LQry.SQL.Text := 'SELECT ' + GSysUygulamaAyari.UygulamaSurum.FieldName + ' FROM ' + GSysUygulamaAyari.TableName;
    LQry.Open;
    LQry.First;
    LSurum := LQry.Fields.Fields[0].AsString;
  finally
    LQry.Free;
  end;

  if APP_VERSION <> LSurum then
  begin
    LMr := CustomMsgDlg(('Programda yeni bir güncellemeniz var. Þimdi güncellemek ister misin?' + AddLBs(2) +
                         'Sistemsel hatalar veya kritik güncellemeler yapýldýðý için güncellemeyi bir an önce yapmanýz önerilir.'),
                        mtConfirmation,
                        mbYesNo,
                        ['Evet Güncelle', 'Hayýr Sonra Güncelle'],
                        mbNo,
                        'Kullanýcý Güncelleme Onayý');
    if LMr = mrYes then
      UpdateApplicationExe;
  end;
end;

procedure TfrmMain.UpdateApplicationExe;
const
  SEVENZIP = '7z.dll';
  SETT_NAME = 'GlobalSettings.ini';
  FLD_SETTINGS = 'Settings';
  FLD_REPORT = 'Reports';
  FLD_RESOURCE = 'Resource';
  FLD_LIB = 'Lib';
var
  Path, LOldName, LNewName: string;
  LAppName, LAppNameBak: string;
begin
  LAppName := ExtractFileName(Application.ExeName);
  LAppNameBak := LAppName.Replace(FILE_EXT_EXE, FILE_EXT_BAK);
  Path := GUygulamaAnaDizin;

  if GSysUygulamaAyariDiger.PathUpdate.Value <> '' then
  begin
    if  FileExists(GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + LAppNameBak)
    and FileExists(GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_SETTINGS + PathDelim + SETT_NAME)
    then
    begin
      //The application.exe file is kept with the .bak extension for the possibility of virus infection in the Server.
      DeleteFile(Path + PathDelim + LAppNameBak); //delete local file .bak extension
      RenameFile(Application.ExeName, Path + PathDelim + LAppNameBak);  //rename local file extension .exe to .bak

      LNewName := GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + LAppNameBak;
      LOldName := Path + PathDelim + LAppName;
      CopyFile(PWideChar(LNewName), PWideChar(LOldName), true); //copy remote .bak to local .exe

      if DeleteFile(Path + FLD_SETTINGS + PathDelim + SETT_NAME) then //delete local settings file
      begin
        LNewName := GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_SETTINGS + PathDelim + SETT_NAME;
        LOldName := Path + FLD_SETTINGS + PathDelim + SETT_NAME;
        CopyFile(PWideChar(LNewName), PWideChar(LOldName), True); //copy remote settings file to local settings
      end
      else
        raise Exception.Create('Ayar dosyasý güncellenemedi!!!');


      LNewName := GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_REPORT + PathDelim;
      LOldName := Path + FLD_REPORT + PathDelim;
      CopyFolder(LNewName, LOldName); //copy remote report files to local folder

      LNewName := GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_RESOURCE + PathDelim;
      LOldName := Path + FLD_RESOURCE + PathDelim;
      CopyFolder(LNewName, LOldName); //copy remote resource files to local folder

      //lib klasörü yoksa kopyala
      if not DirectoryExists(Path + FLD_LIB) then
      begin
        LNewName := GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim;
        LOldName := Path + FLD_LIB + PathDelim;
        CopyFolder(LNewName, LOldName); //copy remote library files to local folder
      end;

      //7z.dll yoksa kopyala
      if not FileExists(Path + FLD_LIB + PathDelim + SEVENZIP)  //local de yoksa
         and FileExists(GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim + SEVENZIP)  //sunucuda varsa
      then
      begin
        LNewName := GSysUygulamaAyariDiger.PathUpdate.Value + PathDelim + FLD_LIB + PathDelim + SEVENZIP;
        LOldName := Path + FLD_LIB + PathDelim + SEVENZIP;
        CopyFile(PWideChar(LNewName), PWideChar(LOldName), True); //copy remote settings file to local settings
      end;

      ShellExecute(Handle, 'OPEN', PChar(Application.ExeName), nil, nil, SW_SHOW);  //open updated new file app

      Application.Terminate;
    end
    else
      raise Exception.Create(GSysUygulamaAyariDiger.PathUpdate.Value + AddLBs(2) + 'Güncelleme klasöründe dosyalar bulunamadý');
  end
  else
    raise Exception.Create('Güncelleme klasörü sistemde tanýmlý deðil!!!');
end;

procedure TfrmMain.SetButtonPopup(Sender: TControl = nil);
var
  n1: Integer;
begin
  if Sender = nil then
  begin
    Sender := pnlMain;
    SetButtonPopup(Sender);
  end;


  for n1 := 0 to TWinControl(Sender).ControlCount-1 do begin
    if TWinControl(Sender).Controls[n1].ClassType = TPageControl then
      SetButtonPopup(TWinControl(Sender).Controls[n1])
    else if TWinControl(Sender).Controls[n1].ClassType = TTabSheet then begin
      TTabSheet(TWinControl(Sender).Controls[n1]).PopupMenu := pmButtons;
      SetButtonPopup(TWinControl(Sender).Controls[n1])
    end else if TWinControl(Sender).Controls[n1].ClassType = TButton then begin
      TButton(TWinControl(Sender).Controls[n1]).PopupMenu := pmButtons;
    end;
  end;

end;

destructor TfrmMain.Destroy;
begin
  if stbBase.Panels.Count > 0 then
  begin
    repeat
      stbBase.Panels.Items[stbBase.Panels.Count-1].Free;
    until (stbBase.Panels.Count = 0);
  end;
  stbBase.Free;

  inherited;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
var
  LKurList: TTCMBDovizKuruList;
  LDovizKuru: TMhsDovizKuru;
  n1: Integer;
  n2: Integer;
  LID: Integer;
begin
  if not FIsFormShow then
  begin
    FIsFormShow := True;

    LDovizKuru := TMhsDovizKuru.Create(GDataBase);
    try
      LDovizKuru.SelectToList(' AND ' + LDovizKuru.Tarih.QryName + '=' + QuotedStr(DateToStr(GDataBase.DateDB)), False, False);
      if LDovizKuru.List.Count = 0 then
      begin
        if CustomMsgDlg(
          TranslateText('Döviz kuru girilmemiþ otomatik olarak TCMB Döviz kurlarýndan girilmesini ister misin?', FrameworkLang.MessageOtomatikDovizKuru, LngMsgData, LngSystem),
          mtConfirmation, mbYesNo, [TranslateText('Evet', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem),
                                    TranslateText('Hayýr', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)], mbNo,
                                    TranslateText('Onay', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem)) = mrYes
        then
        begin
          LKurList := TCMB_DovizKurlari;
          for n1 := 0 to Length(LKurList)-1 do
          begin
            for n2 := 0 to GParaBirimi.List.Count-1 do
            begin
              if LKurList[n1].Kod = TSysParaBirimi(GParaBirimi.List[n2]).ParaBirimi.Value then
              begin
                LDovizKuru.Clear;
                LDovizKuru.Tarih.Value := LKurList[n1].Tarih;
                LDovizKuru.ParaBirimi.Value := LKurList[n1].Kod;
                LDovizKuru.Kur.Value := LKurList[n1].ForexSelling;
                LDovizKuru.Insert(LID, False);
              end;
            end;

          end;
        end;
      end;
    finally
      LDovizKuru.Free;
    end;

  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  inherited;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  inherited;
  FIsFormShow := False;
  GUygulamaAnaDizin := ExtractFilePath(Application.ExeName);

  btnClose.Visible := True;
  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;

  mniAddLanguageContent.ImageIndex := IMG_ADD_DATA;

//  todo
//  1 yapýldý permision code listesini duzenle butun erisim izinleri kodlar üzerinden yürüyecek þekilde deðiþklik yap
//  2 standart erisim kodlarý için döküman ayarla sabit bilgi olarak girilsin
//  3 yapýldý sys visible colum sýnýfý için ön yüz hazýrla
//  4 kýsmen sistem ayarlarý için sýnýf tanýmla. ondalýklý hane formatý, para formatý, tarih formatý, butun sistem bu formatlar üzerinde ilerleyecek
//  5 yapýldý Output formda arama penceresini ayarla kýsmen yapýldý. kontrol edilecek
//  6 input formlar icin helper penceresi tasarla
//  7 yapýldý excel rapor
//  8 yazýcý ekraný
//  9 detaylý form
//  10 stringgrid base form
  SV.Visible := False;
  SV.Close;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //Key := 0;
end;

procedure TfrmMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    inherited;
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F6 then
    inherited;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  inherited;

  if stbBase.Panels.Count >= STATUS_SQL_SERVER+1 then
    if GDataBase.Connection.Connected then
      stbBase.Panels.Items[STATUS_SQL_SERVER].Text :=
          GDataBase.Connection.Params.Values['Server'];

  if stbBase.Panels.Count >= STATUS_DATE+1 then
    if GDataBase.Connection.Connected then
      stbBase.Panels.Items[STATUS_DATE].Text :=
          DateToStr(GDataBase.GetToday);

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

  SetTitleFromLangContent();

  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);

  if GSysKullanici.IsSuperKullanici.Value then
    SetButtonPopup();

  if GSysKullanici.IsYonetici.Value then
  begin
    SV.Close;
    SV.Visible := True;
    imgMenu.Visible := True;
  end
  else
  begin
    SV.Visible := False;
    imgMenu.Visible := False;

    tspersonel.TabVisible := False;
    tsch.TabVisible := False;
    tsstok.TabVisible := False;
    tssatis.TabVisible := False;
    tsGenel.TabVisible := False;
  end;

  FocusedFirstControl(PageControl1.ActivePage);

  mniAddLanguageContent.Caption := TranslateText(mniAddLanguageContent.Caption, FrameworkLang.PopupAddLangGuiContent, LngPopup, LngSystem);

  tmrcheck_is_update_required.Enabled := True;

  Caption := Caption + ' v' + APP_VERSION;

  SetSession();
end;

procedure TfrmMain.imgMenuClick(Sender: TObject);
begin
  if SV.Opened then
    SV.Close
  else
  begin
    SV.BringToFront;
    SV.Open;
  end;
end;

procedure TfrmMain.mniAddLanguageContentClick(Sender: TObject);
var
  vSysLangGuiContent: TSysLisanGuiIcerik;
  vCode, vValue, vContentType, vTableName: string;
begin
  if pmButtons.PopupComponent.ClassType = TButton then
  begin
    vCode := StringReplace(pmButtons.PopupComponent.Name, PRX_BUTTON, '', [rfReplaceAll]);
    vContentType := LngButton;
    vTableName := LngMainTable;
    vValue := TButton(pmButtons.PopupComponent).Caption;
  end
  else
  if pmButtons.PopupComponent.ClassType = TTabSheet then
  begin
    vCode := StringReplace(pmButtons.PopupComponent.Name, PRX_TABSHEET, '', [rfReplaceAll]);
    vContentType := LngTab;
    vTableName := LngMainTable;
    vValue := TTabSheet(pmButtons.PopupComponent).Caption;
  end;


  vSysLangGuiContent := TSysLisanGuiIcerik.Create(GDataBase);

  vSysLangGuiContent.Lisan.Value := GDataBase.ConnSetting.Language;
  vSysLangGuiContent.Kod.Value := vCode;
  vSysLangGuiContent.IcerikTipi.Value := vContentType;
  vSysLangGuiContent.TabloAdi.Value := vTableName;
  vSysLangGuiContent.Deger.Value := vValue;

  TfrmSysLisanGuiIcerik.Create(Self, nil, vSysLangGuiContent, ifmCopyNewRecord).ShowModal;


  SetTitleFromLangContent();
end;

procedure TfrmMain.ResetSession(pPanelGroupboxPagecontrolTabsheet: TWinControl);
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

procedure TfrmMain.SetSession;
var
  LRights: TSysErisimHakki;
  n1: Integer;
begin
  ResetSession(pnlMain);

  LRights := TSysErisimHakki.Create(GDataBase);
  try
    LRights.SelectToList(' AND ' + LRights.TableName + '.' + LRights.KullaniciID.FieldName + '=' + VarToStr(GSysKullanici.Id.Value), False, False);
    for n1 := 0 to LRights.List.Count-1 do
    begin
      if (TSysErisimHakki(LRights.List[n1]).IsOkuma.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsYeniKayit.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsGuncelleme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsSilme.Value)
      or (TSysErisimHakki(LRights.List[n1]).IsOzel.Value)
      then
      begin
        //Cari Hesap
        if CheckStringInArray(MODULE_CH, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsch.TabVisible then
            tsch.TabVisible := True;

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
          if not tsmhs.TabVisible then
            tsmhs.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_MHS_AYAR then
          begin
            
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_MHS_DOVIZ_KURU then
          begin
            btnmhs_doviz_kuru.Enabled := True;
          end;
        end

        //Stok Kartý
        else if CheckStringInArray(MODULE_STK, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsStok.TabVisible then
            tsStok.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_STK_AYAR then
          begin
            btnset_stk_urun_tipi.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_STK_KAYIT then
          begin
            btnstk_stok_karti.Enabled := True;
            btnstk_cins_ozelligi.Enabled := True;
            btnstk_stok_ambar.Enabled := True;
            btnstk_stok_grubu.Enabled := True;
            btnstk_stok_hareketi.Enabled := True;
          end;
        end
        //Reçete
        else if CheckStringInArray(MODULE_RCT, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tsrecete.TabVisible then
            tsrecete.TabVisible := True;

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
          if not tsPersonel.TabVisible then
            tsPersonel.TabVisible := True;
          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_PRS_AYAR then
          begin
            btnset_prs_bolum.Enabled := True;
            btnset_prs_birim.Enabled := True;
            btnset_prs_gorev.Enabled := True;
            btnset_prs_personel_tipi.Enabled := True;
            btnset_prs_cinsiyet.Enabled := True;
            btnset_prs_medeni_durum.Enabled := True;
            btnset_prs_askerlik_durumu.Enabled := True;
            btnset_prs_servis_araci.Enabled := True;
            btnset_prs_lisan.Enabled := True;
            btnset_prs_lisan_seviyesi.Enabled := True;
            btnset_prs_yeterlilik_belgesi.Enabled := True;
            btnset_prs_mektup_tipi.Enabled := True;
            btnset_prs_egitim_seviyesi.Enabled := True;
            btnset_prs_ehliyet.Enabled := True;
            btnset_prs_ayrilma_nedeni.Enabled := True;
            btnset_prs_ayrilma_tipi.Enabled := True;
            btnset_prs_gecis_sistemi_karti.Enabled := True;
            btnset_prs_rapor_tipi.Enabled := True;
            btnset_prs_src_tipi.Enabled := True;
            btnset_prs_tatil_tipi.Enabled := True;
          end
          else if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_PRS_KAYIT then
          begin
            btnprs_personel.Enabled := True;
          end
        end
        //Satýþ
        else if CheckStringInArray(MODULE_TSIF, VarToStr(TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value)) then
        begin
          if not tssatis.TabVisible then
            tssatis.TabVisible := True;

          if TSysErisimHakki(LRights.List[n1]).KaynakKodu.Value = MODULE_TSIF_AYAR then
          begin
            actset_efatura_fatura_tipi.Enabled := True;
            actset_efatura_iletisim_kanali.Enabled := True;
            actset_efatura_istisna_kodu.Enabled := True;
            actset_teklif_tipleri.Enabled := True;
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
    LRights.Free;
  end;
end;

Initialization

end.

