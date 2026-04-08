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
  udm in 'BackEnd\Core\udm.pas' {dm: TDataModule},
  SynCommons in 'BackEnd\Tools\SynPDF\SynCommons.pas',
  SynLZ in 'BackEnd\Tools\SynPDF\SynLZ.pas',
  SynPdf in 'BackEnd\Tools\SynPDF\SynPdf.pas',
  SynGdiPlus in 'BackEnd\Tools\SynPDF\SynGdiPlus.pas',
  SynZip in 'BackEnd\Tools\SynPDF\SynZip.pas',
  SynTable in 'BackEnd\Tools\SynPDF\SynTable.pas',
  SynCrypto in 'BackEnd\Tools\SynPDF\SynCrypto.pas',
  mORMotReport in 'BackEnd\Tools\SynPDF\mORMotReport.pas',
  Bcrypt in 'Utils\Bcrypt.pas',
  Ths.Helper.BaseTypes in 'BackEnd\Tools\Ths.Helper.BaseTypes.pas',
  Ths.Helper.Button in 'BackEnd\Tools\Ths.Helper.Button.pas',
  Ths.Helper.ComboBox in 'BackEnd\Tools\Ths.Helper.ComboBox.pas',
  Ths.Helper.CustomFileDialog in 'BackEnd\Tools\Ths.Helper.CustomFileDialog.pas',
  Ths.Helper.Edit in 'BackEnd\Tools\Ths.Helper.Edit.pas',
  Ths.Helper.Memo in 'BackEnd\Tools\Ths.Helper.Memo.pas',
  Ths.Helper.SpinEdit in 'BackEnd\Tools\Ths.Helper.SpinEdit.pas',
  Ths.Helper.StringGrid in 'BackEnd\Tools\Ths.Helper.StringGrid.pas',
  Ths.Helper.ThsList in 'BackEnd\Tools\Ths.Helper.ThsList.pas',
  Ths.Utils.Images in 'BackEnd\Tools\Ths.Utils.Images.pas',
  Ths.DialogHelper in 'BackEnd\Tools\Ths.DialogHelper.pas',
  Ths.Database.Connection.Settings in 'BackEnd\Core\Ths.Database.Connection.Settings.pas',
  Ths.Globals in 'BackEnd\Core\Ths.Globals.pas',
  Ths.Constants in 'BackEnd\Core\Ths.Constants.pas',
  ufrmAbout in 'Forms\ufrmAbout.pas' {frmAbout},
  ufrmBase in 'Forms\ufrmBase.pas' {frmBase},
  ufrmConfirmation in 'Forms\ufrmConfirmation.pas' {frmConfirmation},
  ufrmLogin in 'Forms\InputForms\Core\ufrmLogin.pas' {frmLogin},
  ufrmDashboard in 'Forms\InputForms\Core\ufrmDashboard.pas' {frmDashboard},
  ufrmCalculator in 'Forms\ufrmCalculator.pas' {frmCalculator},
  Logger in 'BackEnd\Core\Logger.pas',
  SharedFormTypes in 'BackEnd\Core\Base\New\SharedFormTypes.pas',
  EntityAttributes in 'BackEnd\Core\Base\New\EntityAttributes.pas',
  Entity in 'BackEnd\Core\Base\New\Entity.pas',
  FilterCriterion in 'BackEnd\Core\Base\New\FilterCriterion.pas',
  LocalizationManager in 'BackEnd\Core\Base\New\LocalizationManager.pas',
  ConnectionManager in 'BackEnd\Core\Base\New\ConnectionManager.pas',
  Repository in 'BackEnd\Core\Base\New\Repository.pas',
  Service in 'BackEnd\Core\Base\New\Service.pas',
  UnitOfWork in 'BackEnd\Core\Base\New\UnitOfWork.pas',
  MetaProvider in 'BackEnd\Core\MetaProvider.pas',
  Password.Helper in 'BackEnd\Core\Base\New\Password.Helper.pas',
  AppContext in 'BackEnd\Core\AppContext.pas',
  UserContext in 'BackEnd\Core\UserContext.pas',
  ufrmGrid in 'Forms\Core\ufrmGrid.pas',
  ufrmInputSimpleDB in 'Forms\Core\ufrmInputSimpleDB.pas',
  Auth.Service in 'BackEnd\System\Service\Auth.Service.pas',
  SysUser in 'BackEnd\System\Domain\SysUser.pas',
  SysUser.Repository in 'BackEnd\System\Repository\SysUser.Repository.pas',
  SysUser.Service in 'BackEnd\System\Service\SysUser.Service.pas',
  SysAccessRight in 'BackEnd\System\Domain\SysAccessRight.pas',
  SysAccessRight.Repository in 'BackEnd\System\Repository\SysAccessRight.Repository.pas',
  SysCity in 'BackEnd\System\Domain\SysCity.pas',
  SysCity.Repository in 'BackEnd\System\Repository\SysCity.Repository.pas',
  SysCity.Service in 'BackEnd\System\Service\SysCity.Service.pas',
  ufrmSysCity in 'Forms\System\ufrmSysCity.pas' {frmSysCity},
  ufrmSysCities in 'Forms\System\ufrmSysCities.pas' {frmSysCities},
  SysCountry in 'BackEnd\System\Domain\SysCountry.pas',
  SysCountry.Repository in 'BackEnd\System\Repository\SysCountry.Repository.pas',
  SysCountry.Service in 'BackEnd\System\Service\SysCountry.Service.pas',
  ufrmSysCountry in 'Forms\System\ufrmSysCountry.pas' {frmSysCountry},
  ufrmSysCountries in 'Forms\System\ufrmSysCountries.pas' {frmSysCountries},
  SysRegion in 'BackEnd\System\Domain\SysRegion.pas',
  SysRegion.Repository in 'BackEnd\System\Repository\SysRegion.Repository.pas',
  SysRegion.Service in 'BackEnd\System\Service\SysRegion.Service.pas',
  ufrmSysRegion in 'Forms\System\ufrmSysRegion.pas' {frmSysRegion},
  ufrmSysRegions in 'Forms\System\ufrmSysRegions.pas' {frmSysRegions},
  SysUomType in 'BackEnd\System\Domain\SysUomType.pas',
  SysUomType.Repository in 'BackEnd\System\Repository\SysUomType.Repository.pas',
  SysUomType.Service in 'BackEnd\System\Service\SysUomType.Service.pas',
  ufrmSysUomTypes in 'Forms\System\ufrmSysUomTypes.pas' {frmSysUomTypes},
  ufrmSysUomType in 'Forms\System\ufrmSysUomType.pas' {frmSysUomType},
  SysUom in 'BackEnd\System\Domain\SysUom.pas',
  SysUom.Repository in 'BackEnd\System\Repository\SysUom.Repository.pas',
  SysUom.Service in 'BackEnd\System\Service\SysUom.Service.pas',
  ufrmSysUoms in 'Forms\System\ufrmSysUoms.pas' {frmSysUoms},
  ufrmSysUom in 'Forms\System\ufrmSysUom.pas' {frmSysUom},
  SysAddress in 'BackEnd\System\Domain\SysAddress.pas',
  SysApplicationSetting in 'BackEnd\System\Domain\SysApplicationSetting.pas',
  SysCurrency in 'BackEnd\System\Domain\SysCurrency.pas',
  SysDay in 'BackEnd\System\Domain\SysDay.pas',
  SysDecimalPlace in 'BackEnd\System\Domain\SysDecimalPlace.pas',
  SysGridColumn in 'BackEnd\System\Domain\SysGridColumn.pas',
  SysGuiContent in 'BackEnd\System\Domain\SysGuiContent.pas',
  SysGridFilter in 'BackEnd\System\Domain\SysGridFilter.pas',
  SysMonth in 'BackEnd\System\Domain\SysMonth.pas',
  SysPermission in 'BackEnd\System\Domain\SysPermission.pas',
  SysPermissionGroup in 'BackEnd\System\Domain\SysPermissionGroup.pas',
  SysViewColumn in 'BackEnd\System\Domain\SysViewColumn.pas',
  SysParaBirimiRepository in 'BackEnd\System\Repository\SysParaBirimiRepository.pas',
  SysPermission.Repository in 'BackEnd\System\Repository\SysPermission.Repository.pas',
  SysPermissionGroup.Repository in 'BackEnd\System\Repository\SysPermissionGroup.Repository.pas',
  SysViewColumn.Repository in 'BackEnd\System\Repository\SysViewColumn.Repository.pas',
  SysParaBirimiService in 'BackEnd\System\Service\SysParaBirimiService.pas',
  SysPermissionGroup.Service in 'BackEnd\System\Service\SysPermissionGroup.Service.pas',
  SysViewColumn.Service in 'BackEnd\System\Service\SysViewColumn.Service.pas',
  SysLanguage in 'BackEnd\System\Domain\SysLanguage.pas',
  PrsDriverLicence in 'BackEnd\Person\PrsDriverLicence.pas',
  PrsLanguageAbility in 'BackEnd\Person\PrsLanguageAbility.pas',
  PrsPerson in 'BackEnd\Person\PrsPerson.pas',
  SetPrsUnit in 'BackEnd\Person\SetPrsUnit.pas',
  SetPrsSection in 'BackEnd\Person\SetPrsSection.pas',
  SetPrsDriverLicenceType in 'BackEnd\Person\SetPrsDriverLicenceType.pas',
  SetPrsTask in 'BackEnd\Person\SetPrsTask.pas',
  SetPrsLanguage in 'BackEnd\Person\SetPrsLanguage.pas',
  SetPrsLanguageLevel in 'BackEnd\Person\SetPrsLanguageLevel.pas',
  SetPrsPersonType in 'BackEnd\Person\SetPrsPersonType.pas',
  SetPrsTransportation in 'BackEnd\Person\SetPrsTransportation.pas';

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

  TStyleManager.TrySetStyle('Iceberg Classico');
  Application.Title := 'THS ERP';
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfrmDashboard, frmDashboard);
  if TfrmLogin.Execute then
  begin
    Application.ShowMainForm := True;
    Application.Run;
  end
  else
  begin
    Application.Terminate;
  end;
end.
