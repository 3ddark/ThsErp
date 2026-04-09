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
  Vcl.Imaging.pngimage, Data.DB, FireDAC.Comp.Client, udm, ufrmBase, ufrmGrid,

  ConnectionManager, Logger, MetaProvider,
  AppContext, UserContext, UnitOfWork,
  ufrmSysRegions, SysRegion.Service, SysRegion,
  ufrmSysCities, SysCity.Service, SysCity,
  ufrmSysCountries, SysCountry.Service, SysCountry,
  ufrmSysUomTypes, SysUomType.Service, SysUomType,
  ufrmSysUoms, SysUom.Service, SysUom;

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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Constants,
  Ths.Globals;

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
//
end;

procedure TfrmDashboard.actbbk_kayitExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_bankalarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_banka_subeleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_bolgeExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_hesap_kartiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actch_hesap_karti_araExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_update_passwordExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actlstMainExecute(Action: TBasicAction; var Handled: Boolean);
begin
//  if SV.Opened then
//    SV.Opened := not SV.Opened;
end;

procedure TfrmDashboard.actodeme_baslangic_donemleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_birimlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_bolumlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_ehliyetlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_gorevlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actprs_ehliyetlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actprs_lisan_bilgileriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actprs_personellerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsat_siparisExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsat_siparis_raporExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsat_teklifExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_bbk_calisma_durumuExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_bbk_finans_durumuExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_bbk_firma_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_firma_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_firma_turuExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_grupExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_hesap_planiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_hesap_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_ch_vergi_oraniExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_efatura_fatura_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_efatura_istisna_koduExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_odeme_sekliExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_paket_tipiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_tasima_ucretiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_einv_teslim_sekliExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_birimExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_bolumExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_gorevExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_lisanExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_lisanlarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_lisan_seviyeleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_personel_tipleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_prs_tasima_servisleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_ambarlarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_cins_ozellikleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_gruplarExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_hareketlerExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_hareketiExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_karti_ozetleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actstk_stok_kartlariExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_cityExecute(Sender: TObject);
begin
  TfrmSysCities.Create(Self, TSysCityService.Create, TSysCity.Create).Show;
end;

procedure TfrmDashboard.actsys_grid_columnExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_countryExecute(Sender: TObject);
begin
  TfrmSysCountries.Create(Self, TSysCountryService.Create, TSysCountry.Create).Show;
end;

procedure TfrmDashboard.actsys_dayExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_database_statusExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_do_database_backupExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_grid_filter_sortExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actacc_exchange_rateExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_lang_gui_contentExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_monthExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_regionExecute(Sender: TObject);
begin
  TfrmSysRegions.Create(Self, TSysRegionService.Create, TSysRegion.Create).Show;
end;

procedure TfrmDashboard.actsys_unit_typeExecute(Sender: TObject);
begin
  TfrmSysUomTypes.Create(Self, TSysUomTypeService.Create, TSysUomType.Create).Show;
end;

procedure TfrmDashboard.actsys_unitExecute(Sender: TObject);
begin
  TfrmSysUoms.Create(Self, TSysUomService.Create, TSysUom.Create).Show;
end;

procedure TfrmDashboard.actsys_currencyExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_resourceExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_resource_groupExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_application_settingExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_userExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actsys_access_rightExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actteklif_durumlariExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actset_teklif_tipleriExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actquality_form_mail_recieversExecute(Sender: TObject);
begin
//
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
//
end;

procedure TfrmDashboard.actrct_paket_hammaddeExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.actrct_receteExecute(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.btnCloseClick(Sender: TObject);
begin
  if CustomMsgDlg('Uygulama sonlandırılacak. Devam etmek istediğine emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Onay') = mrYes then
    inherited;
end;

procedure TfrmDashboard.btnTestClick(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.tmrcheck_is_update_requiredTimer(Sender: TObject);
var
  LSurum: string;
  LMr: Integer;
begin
  Exit;
  //interval 1 minute
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
      UpdateApplicationExe
    else
      tmrcheck_is_update_required.Enabled := False;
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
  Path: string;
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
  //
  inherited;
end;

procedure TfrmDashboard.FormActivate(Sender: TObject);
begin
//
end;

procedure TfrmDashboard.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  inherited;
end;

procedure TfrmDashboard.FormCreate(Sender: TObject);
begin
  inherited;

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

    if TConnectionManager.Instance.GetConnection(ContextMain).Connected then
      stbBase.Panels.Items[STATUS_SQL_SERVER].Text := TConnectionManager.Instance.GetConnection(ContextMain).Params.Values['Server'];

  if stbBase.Panels.Count >= STATUS_DATE+1 then
    if TConnectionManager.Instance.GetConnection(ContextMain).Connected then
      stbBase.Panels.Items[STATUS_DATE].Text := DateToStr(Now);

  if stbBase.Panels.Count >= STATUS_USERNAME+1 then

    if TConnectionManager.Instance.GetConnection(ContextMain).Connected then
      stbBase.Panels.Items[STATUS_USERNAME].Text := TAppContext.Instance.CurrentUser.GetUsername;

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

//  if GSysKullanici.IsYonetici.Value then
//  begin
    mnimenu_system.Visible := True;
//  end
//  else
  begin
//    mnimenu_system.Visible := False;

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

  TUnitOfWork.Initialize(TConnectionManager.Instance.GetConnection(ContextMain));
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
//var
//  LRights: TSysErisimHakki;
//  n1: Integer;
begin
  ResetSession(pnlMain);
  btnTest.Enabled := True;
(*  LRights := TSysErisimHakki.Create(GDataBase);
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
*)
end;

Initialization

finalization
  if TConnectionManager.Instance <> nil then
    FreeAndNil(TConnectionManager.Instance);
  TAppContext.Finalize;

end.
