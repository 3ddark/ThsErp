Program Ths;

{$I Ths.inc}

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  System.StartUpCopy,
  System.Classes,
  System.SysUtils,
  System.IOUtils,
  Winapi.Messages,
  Winapi.Windows,
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
  ufrmBase in 'Forms\Core\Base\ufrmBase.pas' {frmBase},
  ufrmAbout in 'Forms\Core\Input\ufrmAbout.pas' {frmAbout},
  ufrmCalculator in 'Forms\Core\Input\ufrmCalculator.pas' {frmCalculator},
  ufrmConfirmation in 'Forms\Core\Input\ufrmConfirmation.pas' {frmConfirmation},
  ufrmLogin in 'Forms\Core\Input\ufrmLogin.pas' {frmLogin},
  ufrmDashboard in 'Forms\Core\Input\ufrmDashboard.pas' {frmDashboard},
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
  ufrmGrid in 'Forms\Core\Base\ufrmGrid.pas',
  ufrmInputSimpleDB in 'Forms\Core\Base\ufrmInputSimpleDB.pas',
  Auth.Service in 'BackEnd\Core\Auth.Service.pas',
  SysAccessRight in 'BackEnd\System\Domain\SysAccessRight.pas',
  SysAccessRight.Repository in 'BackEnd\System\Repository\SysAccessRight.Repository.pas',
  SysAccessRight.Service in 'BackEnd\System\Service\SysAccessRight.Service.pas',
  ufrmSysAccessRight in 'Forms\System\Input\ufrmSysAccessRight.pas' {frmSysAccessRight},
  ufrmSysAccessRights in 'Forms\System\Output\ufrmSysAccessRights.pas' {frmSysAccessRights},
  SysAddress in 'BackEnd\System\Domain\SysAddress.pas',
  SysAddress.Repository in 'BackEnd\System\Repository\SysAddress.Repository.pas',
  SysAddress.Service in 'BackEnd\System\Service\SysAddress.Service.pas',
  ufrmSysAddress in 'Forms\System\Input\ufrmSysAddress.pas' {frmSysAddress},
  ufrmSysAddresses in 'Forms\System\Output\ufrmSysAddresses.pas' {frmSysAddresses},
  SysApplicationSetting in 'BackEnd\System\Domain\SysApplicationSetting.pas',
  SysApplicationSetting.Repository in 'BackEnd\System\Repository\SysApplicationSetting.Repository.pas',
  SysApplicationSetting.Service in 'BackEnd\System\Service\SysApplicationSetting.Service.pas',
  ufrmSysApplicationSetting in 'Forms\System\Input\ufrmSysApplicationSetting.pas' {frmSysApplicationSetting},
  SysCity in 'BackEnd\System\Domain\SysCity.pas',
  SysCity.Repository in 'BackEnd\System\Repository\SysCity.Repository.pas',
  SysCity.Service in 'BackEnd\System\Service\SysCity.Service.pas',
  ufrmSysCity in 'Forms\System\Input\ufrmSysCity.pas' {frmSysCity},
  ufrmSysCities in 'Forms\System\Output\ufrmSysCities.pas' {frmSysCities},
  SysCountry in 'BackEnd\System\Domain\SysCountry.pas',
  SysCountry.Repository in 'BackEnd\System\Repository\SysCountry.Repository.pas',
  SysCountry.Service in 'BackEnd\System\Service\SysCountry.Service.pas',
  ufrmSysCountry in 'Forms\System\Input\ufrmSysCountry.pas' {frmSysCountry},
  ufrmSysCountries in 'Forms\System\Output\ufrmSysCountries.pas' {frmSysCountries},
  SysCurrency in 'BackEnd\System\Domain\SysCurrency.pas',
  SysCurrency.Repository in 'BackEnd\System\Repository\SysCurrency.Repository.pas',
  SysCurrency.Service in 'BackEnd\System\Service\SysCurrency.Service.pas',
  ufrmSysCurrency in 'Forms\System\Input\ufrmSysCurrency.pas' {frmSysCurrency},
  ufrmSysCurrencies in 'Forms\System\Output\ufrmSysCurrencies.pas' {frmSysCurrencies},
  SysDay in 'BackEnd\System\Domain\SysDay.pas',
  SysDay.Repository in 'BackEnd\System\Repository\SysDay.Repository.pas',
  SysDay.Service in 'BackEnd\System\Service\SysDay.Service.pas',
  ufrmSysDay in 'Forms\System\Input\ufrmSysDay.pas' {frmSysDay},
  ufrmSysDays in 'Forms\System\Output\ufrmSysDays.pas' {frmSysDays},
  SysDecimalPlace in 'BackEnd\System\Domain\SysDecimalPlace.pas',
  SysDecimalPlace.Repository in 'BackEnd\System\Repository\SysDecimalPlace.Repository.pas',
  SysDecimalPlace.Service in 'BackEnd\System\Service\SysDecimalPlace.Service.pas',
  ufrmSysDecimalPlace in 'Forms\System\Input\ufrmSysDecimalPlace.pas' {frmSysDecimalPlace},
  ufrmSysDecimalPlaces in 'Forms\System\Output\ufrmSysDecimalPlaces.pas' {frmSysDecimalPlaces},
  SysGridColumn in 'BackEnd\System\Domain\SysGridColumn.pas',
  SysGridColumn.Repository in 'BackEnd\System\Repository\SysGridColumn.Repository.pas',
  SysGridColumn.Service in 'BackEnd\System\Service\SysGridColumn.Service.pas',
  ufrmSysGridColumn in 'Forms\System\Input\ufrmSysGridColumn.pas' {frmSysGridColumn},
  ufrmSysGridColumns in 'Forms\System\Output\ufrmSysGridColumns.pas' {frmSysGridColumns},
  SysGridColumnTitle in 'BackEnd\System\Domain\SysGridColumnTitle.pas',
  SysGridColumnTitle.Repository in 'BackEnd\System\Repository\SysGridColumnTitle.Repository.pas',
  SysGridColumnTitle.Service in 'BackEnd\System\Service\SysGridColumnTitle.Service.pas',
  ufrmSysGridColumnTitle in 'Forms\System\Input\ufrmSysGridColumnTitle.pas' {frmSysGridColumnTitle},
  ufrmSysGridColumnTitles in 'Forms\System\Output\ufrmSysGridColumnTitles.pas' {frmSysGridColumnTitles},
  SysGridFilter in 'BackEnd\System\Domain\SysGridFilter.pas',
  SysGridFilter.Repository in 'BackEnd\System\Repository\SysGridFilter.Repository.pas',
  SysGridFilter.Service in 'BackEnd\System\Service\SysGridFilter.Service.pas',
  ufrmSysGridFilter in 'Forms\System\Input\ufrmSysGridFilter.pas' {frmSysGridFilter},
  ufrmSysGridFilters in 'Forms\System\Output\ufrmSysGridFilters.pas' {frmSysGridFilters},
  SysGridSort in 'BackEnd\System\Domain\SysGridSort.pas',
  SysGridSort.Repository in 'BackEnd\System\Repository\SysGridSort.Repository.pas',
  SysGridSort.Service in 'BackEnd\System\Service\SysGridSort.Service.pas',
  ufrmSysGridSort in 'Forms\System\Input\ufrmSysGridSort.pas' {frmSysGridSort},
  ufrmSysGridSorts in 'Forms\System\Output\ufrmSysGridSorts.pas' {frmSysGridSorts},
  SysGuiContent in 'BackEnd\System\Domain\SysGuiContent.pas',
  SysGuiContent.Repository in 'BackEnd\System\Repository\SysGuiContent.Repository.pas',
  SysGuiContent.Service in 'BackEnd\System\Service\SysGuiContent.Service.pas',
  ufrmSysGuiContent in 'Forms\System\Input\ufrmSysGuiContent.pas' {frmSysGuiContent},
  ufrmSysGuiContents in 'Forms\System\Output\ufrmSysGuiContents.pas' {frmSysGuiContents},
  SysLanguage in 'BackEnd\System\Domain\SysLanguage.pas',
  SysLanguage.Repository in 'BackEnd\System\Repository\SysLanguage.Repository.pas',
  SysLanguage.Service in 'BackEnd\System\Service\SysLanguage.Service.pas',
  ufrmSysLanguage in 'Forms\System\Input\ufrmSysLanguage.pas' {frmSysLanguage},
  ufrmSysLanguages in 'Forms\System\Output\ufrmSysLanguages.pas' {frmSysLanguages},
  SysMonth in 'BackEnd\System\Domain\SysMonth.pas',
  SysMonth.Repository in 'BackEnd\System\Repository\SysMonth.Repository.pas',
  SysMonth.Service in 'BackEnd\System\Service\SysMonth.Service.pas',
  ufrmSysMonth in 'Forms\System\Input\ufrmSysMonth.pas' {frmSysMonth},
  ufrmSysMonths in 'Forms\System\Output\ufrmSysMonths.pas' {frmSysMonths},
  SysPermission in 'BackEnd\System\Domain\SysPermission.pas',
  SysPermission.Repository in 'BackEnd\System\Repository\SysPermission.Repository.pas',
  SysPermission.Service in 'BackEnd\System\Service\SysPermission.Service.pas',
  ufrmSysPermission in 'Forms\System\Input\ufrmSysPermission.pas' {frmSysPermission},
  ufrmSysPermissions in 'Forms\System\Output\ufrmSysPermissions.pas' {frmSysPermissions},
  SysPermissionGroup in 'BackEnd\System\Domain\SysPermissionGroup.pas',
  SysPermissionGroup.Repository in 'BackEnd\System\Repository\SysPermissionGroup.Repository.pas',
  SysPermissionGroup.Service in 'BackEnd\System\Service\SysPermissionGroup.Service.pas',
  ufrmSysPermissionGroup in 'Forms\System\Input\ufrmSysPermissionGroup.pas' {frmSysPermissionGroup},
  ufrmSysPermissionGroups in 'Forms\System\Output\ufrmSysPermissionGroups.pas' {frmSysPermissionGroups},
  SysRegion in 'BackEnd\System\Domain\SysRegion.pas',
  SysRegion.Repository in 'BackEnd\System\Repository\SysRegion.Repository.pas',
  SysRegion.Service in 'BackEnd\System\Service\SysRegion.Service.pas',
  ufrmSysRegion in 'Forms\System\Input\ufrmSysRegion.pas' {frmSysRegion},
  ufrmSysRegions in 'Forms\System\Output\ufrmSysRegions.pas' {frmSysRegions},
  SysUom in 'BackEnd\System\Domain\SysUom.pas',
  SysUom.Repository in 'BackEnd\System\Repository\SysUom.Repository.pas',
  SysUom.Service in 'BackEnd\System\Service\SysUom.Service.pas',
  ufrmSysUom in 'Forms\System\Input\ufrmSysUom.pas' {frmSysUom},
  ufrmSysUoms in 'Forms\System\Output\ufrmSysUoms.pas' {frmSysUoms},
  SysUomType in 'BackEnd\System\Domain\SysUomType.pas',
  SysUomType.Repository in 'BackEnd\System\Repository\SysUomType.Repository.pas',
  SysUomType.Service in 'BackEnd\System\Service\SysUomType.Service.pas',
  ufrmSysUomType in 'Forms\System\Input\ufrmSysUomType.pas' {frmSysUomType},
  ufrmSysUomTypes in 'Forms\System\Output\ufrmSysUomTypes.pas' {frmSysUomTypes},
  SysUser in 'BackEnd\System\Domain\SysUser.pas',
  SysUser.Repository in 'BackEnd\System\Repository\SysUser.Repository.pas',
  SysUser.Service in 'BackEnd\System\Service\SysUser.Service.pas',
  ufrmSysUser in 'Forms\System\Input\ufrmSysUser.pas' {frmSysUser},
  ufrmSysUsers in 'Forms\System\Output\ufrmSysUsers.pas' {frmSysUsers},
  SysViewTable in 'BackEnd\System\Domain\SysViewTable.pas',
  SysViewTable.Repository in 'BackEnd\System\Repository\SysViewTable.Repository.pas',
  SysViewTable.Service in 'BackEnd\System\Service\SysViewTable.Service.pas',
  ufrmSysViewTables in 'Forms\System\Output\ufrmSysViewTables.pas' {frmSysViewTables},
  SysViewColumn in 'BackEnd\System\Domain\SysViewColumn.pas',
  SysViewColumn.Repository in 'BackEnd\System\Repository\SysViewColumn.Repository.pas',
  SysViewColumn.Service in 'BackEnd\System\Service\SysViewColumn.Service.pas',
  EmpPerson in 'BackEnd\Employee\Domain\EmpPerson.pas',
  EmpPerson.Repository in 'BackEnd\Employee\Repository\EmpPerson.Repository.pas',
  EmpPerson.Service in 'BackEnd\Employee\Service\EmpPerson.Service.pas',
  EmpPersonType in 'BackEnd\Employee\Domain\EmpPersonType.pas',
  EmpUnit in 'BackEnd\Employee\Domain\EmpUnit.pas',
  EmpSection in 'BackEnd\Employee\Domain\EmpSection.pas',
  EmpTask in 'BackEnd\Employee\Domain\EmpTask.pas',
  EmpPersonType.Repository in 'BackEnd\Employee\Repository\EmpPersonType.Repository.pas',
  EmpUnit.Repository in 'BackEnd\Employee\Repository\EmpUnit.Repository.pas',
  EmpSection.Repository in 'BackEnd\Employee\Repository\EmpSection.Repository.pas',
  EmpTask.Repository in 'BackEnd\Employee\Repository\EmpTask.Repository.pas',
  EmpPersonType.Service in 'BackEnd\Employee\Service\EmpPersonType.Service.pas',
  EmpUnit.Service in 'BackEnd\Employee\Service\EmpUnit.Service.pas',
  EmpSection.Service in 'BackEnd\Employee\Service\EmpSection.Service.pas',
  EmpTask.Service in 'BackEnd\Employee\Service\EmpTask.Service.pas';

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
