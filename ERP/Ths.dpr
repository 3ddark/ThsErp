program Ths;

{$I Ths.inc}

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  System.StartUpCopy,
  System.Classes,
  System.SysUtils,
  Winapi.Messages,
  Winapi.Windows,
  System.IOUtils,
  SynCommons in 'BackEnd\Tools\SynPDF\SynCommons.pas',
  SynLZ in 'BackEnd\Tools\SynPDF\SynLZ.pas',
  SynPdf in 'BackEnd\Tools\SynPDF\SynPdf.pas',
  SynGdiPlus in 'BackEnd\Tools\SynPDF\SynGdiPlus.pas',
  SynZip in 'BackEnd\Tools\SynPDF\SynZip.pas',
  SynCrypto in 'BackEnd\Tools\SynPDF\SynCrypto.pas',
  SynTable in 'BackEnd\Tools\SynPDF\SynTable.pas',
  mORMotReport in 'BackEnd\Tools\SynPDF\mORMotReport.pas',
  Ths.Helper.BaseTypes in 'BackEnd\Tools\Ths.Helper.BaseTypes.pas',
  Ths.Helper.Button in 'BackEnd\Tools\Ths.Helper.Button.pas',
  Ths.Helper.ComboBox in 'BackEnd\Tools\Ths.Helper.ComboBox.pas',
  Ths.Helper.CustomFileDialog in 'BackEnd\Tools\Ths.Helper.CustomFileDialog.pas',
  Ths.Helper.Edit in 'BackEnd\Tools\Ths.Helper.Edit.pas',
  Ths.Helper.Memo in 'BackEnd\Tools\Ths.Helper.Memo.pas',
  Ths.Helper.SpinEdit in 'BackEnd\Tools\Ths.Helper.SpinEdit.pas',
  Ths.Helper.StringGrid in 'BackEnd\Tools\Ths.Helper.StringGrid.pas',
  Ths.Helper.ThsList in 'BackEnd\Tools\Ths.Helper.ThsList.pas',
  Ths.Utils.SevenZip in 'BackEnd\Tools\Ths.Utils.SevenZip.pas',
  Ths.Utils.FluentXML in 'BackEnd\Tools\Ths.Utils.FluentXML.pas',
  Ths.Utils.InfoWindow in 'BackEnd\Tools\Ths.Utils.InfoWindow.pas',
  Ths.Utils.Logger in 'BackEnd\Tools\Ths.Utils.Logger.pas',
  udm in 'BackEnd\Core\udm.pas' {dm: TDataModule},
  Ths.Constants in 'BackEnd\Core\Ths.Constants.pas',
  Ths.Database.Connection.Settings in 'BackEnd\Core\Ths.Database.Connection.Settings.pas',
  Ths.Database in 'BackEnd\Core\Ths.Database.pas',
  Ths.Database.Table in 'BackEnd\Core\Ths.Database.Table.pas',
  Ths.Database.Table.View in 'BackEnd\Core\Ths.Database.Table.View.pas',
  Ths.Database.TableDetailed in 'BackEnd\Core\Ths.Database.TableDetailed.pas',
  Ths.Globals in 'BackEnd\Core\Ths.Globals.pas',
  ufrmAbout in 'Forms\ufrmAbout.pas' {frmAbout},
  ufrmBase in 'Forms\ufrmBase.pas' {frmBase},
  ufrmBaseInput in 'Forms\ufrmBaseInput.pas' {frmBaseInput},
  ufrmConfirmation in 'Forms\ufrmConfirmation.pas' {frmConfirmation},
  ufrmBaseDetaylar in 'Forms\DetailedInputForms\Factory\ufrmBaseDetaylar.pas' {frmBaseDetaylar},
  ufrmBaseDetaylarDetay in 'Forms\DetailedInputForms\Factory\ufrmBaseDetaylarDetay.pas' {frmBaseDetaylarDetay},
  ufrmBaseInputDB in 'Forms\InputForms\Factory\ufrmBaseInputDB.pas' {frmBaseInputDB},
  ufrmBaseOutput in 'Forms\OutputForms\Factory\ufrmBaseOutput.pas' {frmBaseOutput},
  ufrmBaseDBGrid in 'Forms\OutputForms\DbGrid\Factory\ufrmBaseDBGrid.pas' {frmBaseDBGrid},
  ufrmFilterDBGrid in 'Forms\OutputForms\DbGrid\Factory\ufrmFilterDBGrid.pas' {frmFilterDBGrid},
  ufrmBaseStrGrid in 'Forms\OutputForms\StrGrid\Factory\ufrmBaseStrGrid.pas' {frmBaseStrGrid},
  ufrmGiris in 'Forms\InputForms\Core\ufrmGiris.pas' {frmLogin},
  ufrmDashboard in 'Forms\InputForms\Core\ufrmDashboard.pas' {frmDashboard},
  ufrmCalculator in 'Forms\ufrmCalculator.pas' {frmCalculator},
  Ths.Database.Table.SysAdresler in 'BackEnd\Core\Ths.Database.Table.SysAdresler.pas',
  Ths.Database.Table.SysUygulamaAyarlari in 'BackEnd\Core\Ths.Database.Table.SysUygulamaAyarlari.pas',
  ufrmSysUygulamaAyari in 'Forms\InputForms\Core\ufrmSysUygulamaAyari.pas' {frmSysApplicationSetting},
  Ths.Database.Table.SysSehirler in 'BackEnd\Core\Ths.Database.Table.SysSehirler.pas',
  ufrmSysSehirler in 'Forms\OutputForms\DbGrid\Core\ufrmSysSehirler.pas' {frmSysSehirler},
  ufrmSysSehir in 'Forms\InputForms\Core\ufrmSysSehir.pas' {frmSysCity},
  Ths.Database.Table.SysBolgeler in 'BackEnd\Core\Ths.Database.Table.SysBolgeler.pas',
  ufrmSysBolgeler in 'Forms\OutputForms\DbGrid\Core\ufrmSysBolgeler.pas' {frmSysBolgeler},
  ufrmSysBolge in 'Forms\InputForms\Core\ufrmSysBolge.pas' {frmSysRegion},
  Ths.Database.Table.SysUlkeler in 'BackEnd\Core\Ths.Database.Table.SysUlkeler.pas',
  ufrmSysUlkeler in 'Forms\OutputForms\DbGrid\Core\ufrmSysUlkeler.pas' {frmSysCountries},
  ufrmSysUlke in 'Forms\InputForms\Core\ufrmSysUlke.pas' {frmSysUlke},
  Ths.Database.Table.SysGunler in 'BackEnd\Core\Ths.Database.Table.SysGunler.pas',
  ufrmSysGunler in 'Forms\OutputForms\DbGrid\Core\ufrmSysGunler.pas' {frmSysDays},
  ufrmSysGun in 'Forms\InputForms\Core\ufrmSysGun.pas' {frmSysDay},
  Ths.Database.Table.SysOndalikHaneler in 'BackEnd\Core\Ths.Database.Table.SysOndalikHaneler.pas',
  Ths.Database.Table.SysGridKolonlar in 'BackEnd\Core\Ths.Database.Table.SysGridKolonlar.pas',
  ufrmSysGridKolonlar in 'Forms\OutputForms\DbGrid\Core\ufrmSysGridKolonlar.pas' {frmSysGridKolonlar},
  ufrmSysGridKolon in 'Forms\InputForms\Core\ufrmSysGridKolon.pas' {frmSysGridColumn},
  Ths.Database.Table.SysGridFiltrelerSiralamalar in 'BackEnd\Core\Ths.Database.Table.SysGridFiltrelerSiralamalar.pas',
  ufrmSysGridFiltrelerSiralamalar in 'Forms\OutputForms\DbGrid\Core\ufrmSysGridFiltrelerSiralamalar.pas' {frmSysGridFiltrelerSiralamalar},
  ufrmSysGridFiltrelerSiralama in 'Forms\InputForms\Core\ufrmSysGridFiltrelerSiralama.pas' {frmSysGridFilterSort},
  Ths.Database.Table.SysLisanlar in 'BackEnd\Core\Ths.Database.Table.SysLisanlar.pas',
  ufrmSysLisanlar in 'Forms\OutputForms\DbGrid\Core\ufrmSysLisanlar.pas' {frmSysLisanlar},
  ufrmSysLisan in 'Forms\InputForms\Core\ufrmSysLisan.pas' {frmSysLang},
  Ths.Database.Table.SysLisanVeriIcerikler in 'BackEnd\Core\Ths.Database.Table.SysLisanVeriIcerikler.pas',
  ufrmSysLisanVeriIcerikler in 'Forms\OutputForms\DbGrid\Core\ufrmSysLisanVeriIcerikler.pas' {frmSysLangDataContents},
  ufrmSysLisanVeriIcerik in 'Forms\InputForms\Core\ufrmSysLisanVeriIcerik.pas' {frmSysLangDataContent},
  Ths.Database.Table.SysLisanGuiIcerikler in 'BackEnd\Core\Ths.Database.Table.SysLisanGuiIcerikler.pas',
  ufrmSysLisanGuiIcerikler in 'Forms\OutputForms\DbGrid\Core\ufrmSysLisanGuiIcerikler.pas' {frmSysLangGuiContents},
  ufrmSysLisanGuiIcerik in 'Forms\InputForms\Core\ufrmSysLisanGuiIcerik.pas' {frmSysLangGuiContent},
  Ths.Database.Table.SysAylar in 'BackEnd\Core\Ths.Database.Table.SysAylar.pas',
  ufrmSysAylar in 'Forms\OutputForms\DbGrid\Core\ufrmSysAylar.pas' {frmSysAylar},
  ufrmSysAy in 'Forms\InputForms\Core\ufrmSysAy.pas' {frmSysMonth},
  Ths.Database.Table.SysKaynaklar in 'BackEnd\Core\Ths.Database.Table.SysKaynaklar.pas',
  ufrmSysKaynaklar in 'Forms\OutputForms\DbGrid\Core\ufrmSysKaynaklar.pas' {frmSysKaynaklar},
  ufrmSysKaynak in 'Forms\InputForms\Core\ufrmSysKaynak.pas' {frmSysResource},
  Ths.Database.Table.SysKaynakGruplari in 'BackEnd\Core\Ths.Database.Table.SysKaynakGruplari.pas',
  ufrmSysKaynakGruplari in 'Forms\OutputForms\DbGrid\Core\ufrmSysKaynakGruplari.pas' {frmSysKaynakGruplari},
  ufrmSysKaynakGrubu in 'Forms\InputForms\Core\ufrmSysKaynakGrubu.pas' {frmSysResourceGroup},
  Ths.Database.Table.SysVergiMukellefTipleri in 'BackEnd\Core\Ths.Database.Table.SysVergiMukellefTipleri.pas',
  ufrmSysVergiMukellefTipleri in 'Forms\OutputForms\DbGrid\Core\ufrmSysVergiMukellefTipleri.pas' {frmSysVergiMukellefTipleri},
  ufrmSysMukellefTipi in 'Forms\InputForms\Core\ufrmSysMukellefTipi.pas' {frmSysTaxpayerType},
  Ths.Database.Table.SysParaBirimleri in 'BackEnd\Core\Ths.Database.Table.SysParaBirimleri.pas',
  ufrmSysParaBirimleri in 'Forms\OutputForms\DbGrid\Core\ufrmSysParaBirimleri.pas' {frmSysParaBirimleri},
  ufrmSysParaBirimi in 'Forms\InputForms\Core\ufrmSysParaBirimi.pas' {frmSysCurrency},
  Ths.Database.Table.SysOlcuBirimiTipleri in 'BackEnd\Core\Ths.Database.Table.SysOlcuBirimiTipleri.pas',
  ufrmSysOlcuBirimiTipleri in 'Forms\OutputForms\DbGrid\Core\ufrmSysOlcuBirimiTipleri.pas' {frmSysOlcuBirimiTipleri},
  ufrmSysOlcuBirimiTipi in 'Forms\InputForms\Core\ufrmSysOlcuBirimiTipi.pas' {ufrmSysOlcuBirimiTipi},
  Ths.Database.Table.SysOlcuBirimleri in 'BackEnd\Core\Ths.Database.Table.SysOlcuBirimleri.pas',
  ufrmSysOlcuBirimleri in 'Forms\OutputForms\DbGrid\Core\ufrmSysOlcuBirimleri.pas' {ufrmSysOlcuBirimleri},
  ufrmSysOlcuBirimi in 'Forms\InputForms\Core\ufrmSysOlcuBirimi.pas' {frmSysOlcuBirimi},
  Ths.Database.Table.SysKullanicilar in 'BackEnd\Core\Ths.Database.Table.SysKullanicilar.pas',
  ufrmSysKullanicilar in 'Forms\OutputForms\DbGrid\Core\ufrmSysKullanicilar.pas' {frmSysUsers},
  ufrmSysKullanici in 'Forms\InputForms\Core\ufrmSysKullanici.pas' {frmSysUser},
  Ths.Database.Table.SysErisimHaklari in 'BackEnd\Core\Ths.Database.Table.SysErisimHaklari.pas',
  ufrmSysErisimHaklari in 'Forms\OutputForms\DbGrid\Core\ufrmSysErisimHaklari.pas' {frmSysUserAccessRights},
  ufrmSysErisimHakki in 'Forms\InputForms\Core\ufrmSysErisimHakki.pas' {frmSysUserAccessRight},
  Ths.Database.Table.View.SysViewColumns in 'BackEnd\Core\Ths.Database.Table.View.SysViewColumns.pas',
  Ths.Database.Table.View.SysViewTables in 'BackEnd\Core\Ths.Database.Table.View.SysViewTables.pas',
  ufrmSysTablolar in 'Forms\OutputForms\DbGrid\Core\ufrmSysTablolar.pas' {frmSysTables},
  Ths.Database.Table.View.SysDbStatus in 'BackEnd\Core\Ths.Database.Table.View.SysDbStatus.pas',
  ufrmSysDatabaseMonitor in 'Forms\OutputForms\DbGrid\Core\ufrmSysDatabaseMonitor.pas' {frmSysDbStatus},
  ufrmSysSifreDegistir in 'Forms\InputForms\Core\ufrmSysSifreDegistir.pas' {frmSysChangePassword},
  Ths.Database.Table.SetPrsEhliyetler in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsEhliyetler.pas',
  ufrmSetEmpDrivingLicences in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpDrivingLicences.pas' {frmSetEmpDrivingLicences},
  ufrmSetEmpDrivingLicence in 'Forms\InputForms\Core\Prs\ufrmSetEmpDrivingLicence.pas' {frmSetEmpDrivingLicence},
  ufrmSetEmpEducationLevels in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpEducationLevels.pas' {frmSetEmpEducationLevels},
  ufrmSetEmpEducationLevel in 'Forms\InputForms\Core\Prs\ufrmSetEmpEducationLevel.pas' {frmSetEmpEducationLevel},
  Ths.Database.Table.SetPrsPersonelTipleri in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsPersonelTipleri.pas',
  ufrmSetPrsPersonelTipleri in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetPrsPersonelTipleri.pas' {frmSetEmpEmployeeTypes},
  ufrmSetPrsPersonelTipi in 'Forms\InputForms\Core\Prs\ufrmSetPrsPersonelTipi.pas' {frmSetEmpEmployeeType},
  Ths.Database.Table.SetPrsLisanlar in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsLisanlar.pas',
  ufrmSetEmpLanguages in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpLanguages.pas' {frmSetEmpLanguages},
  ufrmSetEmpLanguage in 'Forms\InputForms\Core\Prs\ufrmSetEmpLanguage.pas' {frmSetEmpLanguage},
  Ths.Database.Table.SetPrsLisanSeviyeleri in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsLisanSeviyeleri.pas',
  ufrmSetEmpLanguageLevels in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpLanguageLevels.pas' {frmSetEmpLanguageLevels},
  ufrmSetEmpLanguageLevel in 'Forms\InputForms\Core\Prs\ufrmSetEmpLanguageLevel.pas' {frmSetEmpLanguageLevel},
  Ths.Database.Table.SetPrsBolumler in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsBolumler.pas',
  ufrmSetEmpSections in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpSections.pas' {frmSetEmpSections},
  ufrmSetEmpSection in 'Forms\InputForms\Core\Prs\ufrmSetEmpSection.pas' {frmSetEmpSections},
  Ths.Database.Table.SetPrsGorevler in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsGorevler.pas',
  ufrmSetEmpTasks in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpTasks.pas' {frmSetEmpTasks},
  ufrmSetEmpTask in 'Forms\InputForms\Core\Prs\ufrmSetEmpTask.pas' {frmSetEmpTask},
  Ths.Database.Table.SetPrsTasimaServisleri in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsTasimaServisleri.pas',
  ufrmSetEmpTransportServices in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpTransportServices.pas' {frmSetEmpTransportServices},
  ufrmSetEmpTransportService in 'Forms\InputForms\Core\Prs\ufrmSetEmpTransportService.pas' {frmSetEmpTransportService},
  Ths.Database.Table.SetPrsBirimler in 'BackEnd\Core\Prs\Ths.Database.Table.SetPrsBirimler.pas',
  ufrmSetEmpUnits in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmSetEmpUnits.pas' {frmSetEmpUnits},
  ufrmSetEmpUnit in 'Forms\InputForms\Core\Prs\ufrmSetEmpUnit.pas' {frmSetEmpUnit},
  Ths.Database.Table.EmpEmployee in 'BackEnd\Core\Prs\Ths.Database.Table.EmpEmployee.pas',
  ufrmEmpEmployees in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmEmpEmployees.pas' {frmEmpEmployees},
  ufrmEmpEmployee in 'Forms\InputForms\Core\Prs\ufrmEmpEmployee.pas' {frmEmpEmployee},
  Ths.Database.Table.PrsLisanBilgileri in 'BackEnd\Core\Prs\Ths.Database.Table.PrsLisanBilgileri.pas',
  ufrmEmpLanguageAbilities in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmEmpLanguageAbilities.pas' {frmEmpLanguageAbilities},
  ufrmEmpLanguageAbility in 'Forms\InputForms\Core\Prs\ufrmEmpLanguageAbility.pas' {frmEmpLanguageAbility},
  Ths.Database.Table.PrsPersonelEhliyetleri in 'BackEnd\Core\Prs\Ths.Database.Table.PrsPersonelEhliyetleri.pas',
  ufrmEmpDrivingLicences in 'Forms\OutputForms\DbGrid\Core\Prs\ufrmEmpDrivingLicences.pas' {frmEmpDrivingLicences},
  ufrmEmpDrivingLicence in 'Forms\InputForms\Core\Prs\ufrmEmpDrivingLicence.pas' {frmEmpDrivingLicence},
  Ths.Database.Table.ChDovizKurlari in 'BackEnd\Account\Ths.Database.Table.ChDovizKurlari.pas',
  ufrmChDovizKurlari in 'Forms\OutputForms\DbGrid\Account\ufrmChDovizKurlari.pas' {frmChDovizKurlari},
  ufrmChDovizKuru in 'Forms\InputForms\Account\ufrmChDovizKuru.pas' {frmChDovizKuru},
  Ths.Database.Table.SetChFirmaTipi in 'BackEnd\Account\Ths.Database.Table.SetChFirmaTipi.pas',
  ufrmSetChFirmaTipleri in 'Forms\OutputForms\DbGrid\Account\ufrmSetChFirmaTipleri.pas' {frmSetChFirmaTipleri},
  ufrmSetChFirmaTipi in 'Forms\InputForms\Account\ufrmSetChFirmaTipi.pas' {frmSetChFirmaTipi},
  Ths.Database.Table.SetChFirmaTuru in 'BackEnd\Account\Ths.Database.Table.SetChFirmaTuru.pas',
  ufrmSetChFirmaTurleri in 'Forms\OutputForms\DbGrid\Account\ufrmSetChFirmaTurleri.pas' {frmSetChFirmaTurleri},
  ufrmSetChFirmaTuru in 'Forms\InputForms\Account\ufrmSetChFirmaTuru.pas' {frmSetChFirmaTuru},
  Ths.Database.Table.ChGruplar in 'BackEnd\Account\Ths.Database.Table.ChGruplar.pas',
  ufrmChGruplar in 'Forms\OutputForms\DbGrid\Account\ufrmChGruplar.pas' {frmChGruplar},
  ufrmChGrup in 'Forms\InputForms\Account\ufrmChGrup.pas' {frmChGrup},
  Ths.Database.Table.ChHesapPlanlari in 'BackEnd\Account\Ths.Database.Table.ChHesapPlanlari.pas',
  ufrmChHesapPlanlari in 'Forms\OutputForms\DbGrid\Account\ufrmChHesapPlanlari.pas' {frmChHesapPlanlari},
  ufrmChHesapPlani in 'Forms\InputForms\Account\ufrmChHesapPlani.pas' {frmChHesapPlani},
  Ths.Database.Table.SetChHesapTipi in 'BackEnd\Account\Ths.Database.Table.SetChHesapTipi.pas',
  ufrmSetChHesapTipleri in 'Forms\OutputForms\DbGrid\Account\ufrmSetChHesapTipleri.pas' {frmSetChHesapTipleri},
  ufrmSetChHesapTipi in 'Forms\InputForms\Account\ufrmSetChHesapTipi.pas' {frmSetChHesapTipi},
  Ths.Database.Table.SetChVergiOrani in 'BackEnd\Account\Ths.Database.Table.SetChVergiOrani.pas',
  ufrmSetChVergiOranlari in 'Forms\OutputForms\DbGrid\Account\ufrmSetChVergiOranlari.pas' {frmSetChVergiOranlari},
  ufrmSetChVergiOrani in 'Forms\InputForms\Account\ufrmSetChVergiOrani.pas' {frmSetChVergiOrani},
  Ths.Database.Table.ChBankalar in 'BackEnd\Account\Ths.Database.Table.ChBankalar.pas',
  ufrmChBankalar in 'Forms\OutputForms\DbGrid\Account\ufrmChBankalar.pas' {frmChBankalar},
  ufrmChBanka in 'Forms\InputForms\Account\ufrmChBanka.pas' {frmChBanka},
  Ths.Database.Table.ChBankaSubeleri in 'BackEnd\Account\Ths.Database.Table.ChBankaSubeleri.pas',
  ufrmChBankaSubeleri in 'Forms\OutputForms\DbGrid\Account\ufrmChBankaSubeleri.pas' {frmChBankaSubeleri},
  ufrmChBankaSubesi in 'Forms\InputForms\Account\ufrmChBankaSubesi.pas' {frmChBankaSubesi},
  Ths.Database.Table.ChBolgeler in 'BackEnd\Account\Ths.Database.Table.ChBolgeler.pas',
  ufrmChBolgeler in 'Forms\OutputForms\DbGrid\Account\ufrmChBolgeler.pas' {frmChBolgeler},
  ufrmChBolge in 'Forms\InputForms\Account\ufrmChBolge.pas' {frmChBolge},
  Ths.Database.Table.ChHesapKarti in 'BackEnd\Account\Ths.Database.Table.ChHesapKarti.pas',
  ufrmChHesapKartlari in 'Forms\OutputForms\DbGrid\Account\ufrmChHesapKartlari.pas' {frmHesapKartlari},
  ufrmChHesapKarti in 'Forms\InputForms\Account\ufrmChHesapKarti.pas' {frmHesapKarti},
  Ths.Database.Table.ChHesapKartiAra in 'BackEnd\Account\Ths.Database.Table.ChHesapKartiAra.pas',
  ufrmChHesapKartlariAra in 'Forms\OutputForms\DbGrid\Account\ufrmChHesapKartlariAra.pas' {frmHesapKartlariAra},
  ufrmChHesapKartiAra in 'Forms\InputForms\Account\ufrmChHesapKartiAra.pas' {frmHesapKartiAra},
  Ths.Database.Table.ChHesapHareketi in 'BackEnd\Account\Ths.Database.Table.ChHesapHareketi.pas',
  Ths.Database.Table.SetEinvFaturaTipi in 'BackEnd\Invoice\Ths.Database.Table.SetEinvFaturaTipi.pas',
  ufrmSetEinvFaturaTipleri in 'Forms\OutputForms\DbGrid\Invoice\ufrmSetEinvFaturaTipleri.pas' {frmSetEinvFaturaTipleri},
  ufrmSetEinvFaturaTipi in 'Forms\InputForms\Invoice\ufrmSetEinvFaturaTipi.pas' {frmSetEinvFaturaTipi},
  Ths.Database.Table.SetEinvIstisnaKodu in 'BackEnd\Invoice\Ths.Database.Table.SetEinvIstisnaKodu.pas',
  ufrmSetEinvIstisnaKodlari in 'Forms\OutputForms\DbGrid\Invoice\ufrmSetEinvIstisnaKodlari.pas' {frmSetEinvIstisnaKodlari},
  ufrmSetEinvIstisnaKodu in 'Forms\InputForms\Invoice\ufrmSetEinvIstisnaKodu.pas' {frmSetEinvIstisnaKodu},
  Ths.Database.Table.SetEinvOdemeSekli in 'BackEnd\Invoice\Ths.Database.Table.SetEinvOdemeSekli.pas',
  ufrmSetEinvOdemeSekilleri in 'Forms\OutputForms\DbGrid\Invoice\ufrmSetEinvOdemeSekilleri.pas' {frmSetEinvOdemeSekilleri},
  ufrmSetEinvOdemeSekli in 'Forms\InputForms\Invoice\ufrmSetEinvOdemeSekli.pas' {frmSetEinvOdemeSekli},
  Ths.Database.Table.SetEinvPaketTipi in 'BackEnd\Invoice\Ths.Database.Table.SetEinvPaketTipi.pas',
  ufrmSetEinvPaketTipleri in 'Forms\OutputForms\DbGrid\Invoice\ufrmSetEinvPaketTipleri.pas' {frmSetEinvPaketTipleri},
  ufrmSetEinvPaketTipi in 'Forms\InputForms\Invoice\ufrmSetEinvPaketTipi.pas' {frmSetEinvPaketTipi},
  Ths.Database.Table.SetEinvTasimaUcreti in 'BackEnd\Invoice\Ths.Database.Table.SetEinvTasimaUcreti.pas',
  ufrmSetEinvTasimaUcretleri in 'Forms\OutputForms\DbGrid\Invoice\ufrmSetEinvTasimaUcretleri.pas' {frmSetEinvNakliyeUcretleri},
  ufrmSetEinvTasimaUcreti in 'Forms\InputForms\Invoice\ufrmSetEinvTasimaUcreti.pas' {frmSetEinvTasimaUcreti},
  Ths.Database.Table.SetEinvTeslimSekli in 'BackEnd\Invoice\Ths.Database.Table.SetEinvTeslimSekli.pas',
  ufrmSetEinvTeslimSekilleri in 'Forms\OutputForms\DbGrid\Invoice\ufrmSetEinvTeslimSekilleri.pas' {frmSetEinvTeslimSekilleri},
  ufrmSetEinvTeslimSekli in 'Forms\InputForms\Invoice\ufrmSetEinvTeslimSekli.pas' {frmSetEinvTeslimSekli},
  Ths.Database.Table.SetSatTeklifDurum in 'BackEnd\Offer\Ths.Database.Table.SetSatTeklifDurum.pas',
  ufrmSetSatTeklifDurumlar in 'Forms\OutputForms\DbGrid\Offer\ufrmSetSatTeklifDurumlar.pas' {frmSetSatTeklifDurumlar},
  ufrmSetSatTeklifDurum in 'Forms\InputForms\Offer\ufrmSetSatTeklifDurum.pas' {frmSetSatTeklifDurum},
  Ths.Database.Table.SetTekTeklifTipi in 'BackEnd\Offer\Ths.Database.Table.SetTekTeklifTipi.pas',
  ufrmSetTekTeklifTipleri in 'Forms\OutputForms\DbGrid\Offer\ufrmSetTekTeklifTipleri.pas' {frmSetTekTeklifTipleri},
  ufrmSetTekTeklifTipi in 'Forms\InputForms\Offer\ufrmSetTekTeklifTipi.pas' {frmSetTekTeklifTipi},
  Ths.Database.Table.SatTeklif in 'BackEnd\Offer\Ths.Database.Table.SatTeklif.pas',
  ufrmSatTeklifler in 'Forms\OutputForms\DbGrid\Offer\ufrmSatTeklifler.pas' {frmSatTeklifler},
  ufrmSatTeklifDetay in 'Forms\DetailedInputForms\Offer\ufrmSatTeklifDetay.pas' {frmSatTeklifDetay},
  ufrmSatTeklifDetaylar in 'Forms\DetailedInputForms\Offer\ufrmSatTeklifDetaylar.pas' {frmSatTeklifDetaylar},
  Ths.Database.Table.UrtIscilikler in 'BackEnd\Uretim\Ths.Database.Table.UrtIscilikler.pas',
  ufrmUrtIscilikler in 'Forms\OutputForms\DbGrid\Uretim\ufrmUrtIscilikler.pas' {frmRctIscilikGiderleri},
  ufrmUrtIscilik in 'Forms\InputForms\Uretim\ufrmUrtIscilik.pas' {frmRctIscilikGideri},
  Ths.Database.Table.UrtReceteler in 'BackEnd\Uretim\Ths.Database.Table.UrtReceteler.pas',
  ufrmUrtReceteler in 'Forms\OutputForms\DbGrid\Uretim\ufrmUrtReceteler.pas' {frmRctReceteler},
  ufrmRctReceteDetaylar in 'Forms\DetailedInputForms\Uretim\ufrmRctReceteDetaylar.pas' {frmRctReceteDetaylar},
  ufrmRctReceteHammadde in 'Forms\DetailedInputForms\Uretim\ufrmRctReceteHammadde.pas' {frmRctReceteHammadde},
  ufrmRctReceteIscilik in 'Forms\DetailedInputForms\Uretim\ufrmRctReceteIscilik.pas' {frmRctReceteIscilik},
  ufrmRctReceteYanUrun in 'Forms\DetailedInputForms\Uretim\ufrmRctReceteYanUrun.pas' {frmRctReceteYanUrun},
  Ths.Database.Table.UrtPaketHammaddeler in 'BackEnd\Uretim\Ths.Database.Table.UrtPaketHammaddeler.pas',
  ufrmUrtPaketHammaddeler in 'Forms\OutputForms\DbGrid\Uretim\ufrmUrtPaketHammaddeler.pas' {frmRctPaketHammaddeler},
  ufrmRctPaketHammaddeDetaylar in 'Forms\DetailedInputForms\Uretim\ufrmRctPaketHammaddeDetaylar.pas' {frmRctPaketHammaddeDetaylar},
  ufrmRctPaketHammaddeDetay in 'Forms\DetailedInputForms\Uretim\ufrmRctPaketHammaddeDetay.pas' {frmRctPaketHammaddeDetay},
  Ths.Database.Table.StkCinsOzellikleri in 'BackEnd\Stock\Ths.Database.Table.StkCinsOzellikleri.pas',
  ufrmStkCinsOzellikleri in 'Forms\OutputForms\DbGrid\Stock\ufrmStkCinsOzellikleri.pas' {frmStkCinsOzellikleri},
  ufrmStkCinsOzelligi in 'Forms\InputForms\Stock\ufrmStkCinsOzelligi.pas' {frmStkCinsOzelligi},
  Ths.Database.Table.StkGruplar in 'BackEnd\Stock\Ths.Database.Table.StkGruplar.pas',
  ufrmStkStokGruplari in 'Forms\OutputForms\DbGrid\Stock\ufrmStkStokGruplari.pas' {frmStkStokGruplari},
  ufrmStkStokGrubu in 'Forms\InputForms\Stock\ufrmStkStokGrubu.pas' {frmStkStokGrubu},
  Ths.Database.Table.StkAmbarlar in 'BackEnd\Stock\Ths.Database.Table.StkAmbarlar.pas',
  ufrmStkStokAmbarlar in 'Forms\OutputForms\DbGrid\Stock\ufrmStkStokAmbarlar.pas' {frmStkStokAmbarlar},
  ufrmStkStokAmbar in 'Forms\InputForms\Stock\ufrmStkStokAmbar.pas' {frmStkStokAmbar},
  Ths.Database.Table.StkStokKarti in 'BackEnd\Stock\Ths.Database.Table.StkStokKarti.pas',
  ufrmStkStokKartlari in 'Forms\OutputForms\DbGrid\Stock\ufrmStkStokKartlari.pas' {frmStkStokKartlari},
  ufrmStkStokKarti in 'Forms\InputForms\Stock\ufrmStkStokKarti.pas' {frmStkStokKarti},
  Ths.Database.Table.StkStokHareketi in 'BackEnd\Stock\Ths.Database.Table.StkStokHareketi.pas',
  ufrmStkStokHareketleri in 'Forms\OutputForms\DbGrid\Stock\ufrmStkStokHareketleri.pas' {frmStkStokHareketleri},
  Ths.Database.Table.OthMailReciever in 'BackEnd\Ths.Database.Table.OthMailReciever.pas',
  ufrmOthMailRecievers in 'Forms\OutputForms\DbGrid\ufrmOthMailRecievers.pas' {frmOthMailRecievers},
  ufrmOthMailReciever in 'Forms\InputForms\ufrmOthMailReciever.pas' {frmOthMailReciever},
  Ths.Database.Table.SetSatSiparisDurum in 'BackEnd\Order\Ths.Database.Table.SetSatSiparisDurum.pas',
  ufrmSetSatSiparisDurumlar in 'Forms\OutputForms\DbGrid\Order\ufrmSetSatSiparisDurumlar.pas' {frmSetSatSiparisDurumlar},
  ufrmSetSatSiparisDurum in 'Forms\InputForms\Order\ufrmSetSatSiparisDurum.pas' {frmSetSatSiparisDurum},
  Ths.Database.Table.SatSiparis in 'BackEnd\Order\Ths.Database.Table.SatSiparis.pas',
  ufrmSatSiparisler in 'Forms\OutputForms\DbGrid\Order\ufrmSatSiparisler.pas' {frmSatSiparisler},
  ufrmSatSiparisDetaylar in 'Forms\DetailedInputForms\Order\ufrmSatSiparisDetaylar.pas' {frmSatSiparisDetaylar},
  ufrmSatSiparisDetay in 'Forms\DetailedInputForms\Order\ufrmSatSiparisDetay.pas' {frmSatSiparisDetay},
  Ths.Database.Table.SatSiparisRapor in 'BackEnd\Order\Ths.Database.Table.SatSiparisRapor.pas',
  ufrmSatSiparislerRapor in 'Forms\OutputForms\DbGrid\Order\ufrmSatSiparislerRapor.pas' {frmSatSiparislerRapor},
  Ths.Database.Table.SetOdemeBaslangicDonemi in 'BackEnd\Ths.Database.Table.SetOdemeBaslangicDonemi.pas',
  ufrmSetOdemeBaslangicDonemleri in 'Forms\OutputForms\DbGrid\ufrmSetOdemeBaslangicDonemleri.pas' {frmSetOdemeBaslangicDonemleri},
  ufrmSetOdemeBaslangicDonemi in 'Forms\InputForms\ufrmSetOdemeBaslangicDonemi.pas' {frmSetOdemeBaslangicDonemi},
  ufrmTarihHaftaSecici in 'Forms\InputForms\Tools\ufrmTarihHaftaSecici.pas' {frmTarihHaftaSecici},
  Ths.Database.Table.SetBbkCalismaDurumu in 'BackEnd\Databank\Ths.Database.Table.SetBbkCalismaDurumu.pas',
  ufrmSetBbkCalismaDurumlari in 'Forms\OutputForms\DbGrid\Databank\ufrmSetBbkCalismaDurumlari.pas' {frmSetBbkCalismaDurumlari},
  ufrmSetBbkCalismaDurumu in 'Forms\InputForms\Databank\ufrmSetBbkCalismaDurumu.pas' {frmSetBbkCalismaDurumu},
  Ths.Database.Table.SetBbkFinansDurumu in 'BackEnd\Databank\Ths.Database.Table.SetBbkFinansDurumu.pas',
  ufrmSetBbkFinansDurumu in 'Forms\InputForms\Databank\ufrmSetBbkFinansDurumu.pas' {frmSetBbkFinansDurumu},
  ufrmSetBbkFinansDurumlari in 'Forms\OutputForms\DbGrid\Databank\ufrmSetBbkFinansDurumlari.pas' {frmSetBbkFinansDurumlari},
  Ths.Database.Table.SetBbkFirmaTipi in 'BackEnd\Databank\Ths.Database.Table.SetBbkFirmaTipi.pas',
  ufrmSetBbkFirmaTipleri in 'Forms\OutputForms\DbGrid\Databank\ufrmSetBbkFirmaTipleri.pas' {frmSetBbkFirmaTipleri},
  ufrmSetBbkFirmaTipi in 'Forms\InputForms\Databank\ufrmSetBbkFirmaTipi.pas' {frmSetBbkFirmaTipi},
  Ths.Database.Table.BbkKayit in 'BackEnd\Databank\Ths.Database.Table.BbkKayit.pas',
  ufrmBbkKayitlar in 'Forms\OutputForms\DbGrid\Databank\ufrmBbkKayitlar.pas' {frmBbkKayitlar},
  ufrmBbkKayit in 'Forms\InputForms\Databank\ufrmBbkKayit.pas' {frmBbkKayit};

{$R *.res}

procedure MemLeakFix;
begin
  CheckSynchronize;
end;

begin
  Application.Initialize;
  Application.DefaultFont.Name := 'Tahoma';

  Application.UpdateFormatSettings := False;
  Formatsettings.ThousandSeparator := '.';
  Formatsettings.DecimalSeparator := ',';
  Formatsettings.DateSeparator := '.';
  Formatsettings.ShortDateFormat := 'dd.mm.yyyy';
  Formatsettings.LongDateFormat  := 'dd.mm.yyyy dddd';
  Formatsettings.ShortTimeFormat := 'HH:mm';
  Formatsettings.LongTimeFormat  := 'HH:mm:ss';
  Formatsettings.TimeSeparator   := ':';

{$WARN SYMBOL_PLATFORM OFF}
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := {$IFDEF MSWINDOWS}DebugHook <> 0;{$ELSE}True;{$ENDIF MSWINDOWS}
  {$ENDIF}
{$WARN SYMBOL_PLATFORM ON}

  AddExitProc(MemLeakFix);

  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.Title := 'THS ERP';
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmDashboard, frmDashboard);
  if TfrmGiris.Execute then
  begin
    Application.ShowMainForm := True;
    Application.Run;
  end
  else
  begin
    Application.Terminate;
  end;
end.
