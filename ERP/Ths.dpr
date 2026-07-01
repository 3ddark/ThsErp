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
  ufrmBase in 'Forms\Core\ufrmBase.pas' {frmBase},
  ufrmAbout in 'Forms\Core\ufrmAbout.pas' {frmAbout},
  ufrmCalculator in 'Forms\Core\ufrmCalculator.pas' {frmCalculator},
  ufrmConfirmation in 'Forms\Core\ufrmConfirmation.pas' {frmConfirmation},
  ufrmLogin in 'Forms\System\ufrmLogin.pas' {frmLogin},
  ufrmDashboard in 'Forms\System\ufrmDashboard.pas' {frmDashboard},
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
  Auth.Service in 'BackEnd\Core\Auth.Service.pas',
  SysCity in 'BackEnd\System\Domain\SysCity.pas',
  SysCity.Repository in 'BackEnd\System\Repository\SysCity.Repository.pas',
  SysCity.Service in 'BackEnd\System\Service\SysCity.Service.pas',
  ufrmSysCity in 'Forms\System\ufrmSysCity.pas' {frmSysCity},
  ufrmSysCities in 'Forms\System\ufrmSysCities.pas' {frmSysCities},
  SysAccessRight in 'BackEnd\System\Domain\SysAccessRight.pas',
  SysAccessRight.Repository in 'BackEnd\System\Repository\SysAccessRight.Repository.pas',
  SysAccessRight.Service in 'BackEnd\System\Service\SysAccessRight.Service.pas',
  SysUser in 'BackEnd\System\Domain\SysUser.pas',
  SysPermission in 'BackEnd\System\Domain\SysPermission.pas',
  SysResourceGroup in 'BackEnd\System\Domain\SysResourceGroup.pas',
  SysPermissionGroup in 'BackEnd\System\Domain\SysPermissionGroup.pas',
  EmpPerson in 'BackEnd\Employee\Domain\EmpPerson.pas',
  EmpPersonType in 'BackEnd\Employee\Domain\EmpPersonType.pas',
  EmpUnit in 'BackEnd\Employee\Domain\EmpUnit.pas',
  EmpSection in 'BackEnd\Employee\Domain\EmpSection.pas',
  EmpTask in 'BackEnd\Employee\Domain\EmpTask.pas',
  SysAddress in 'BackEnd\System\Domain\SysAddress.pas',
  SysAddress.Repository in 'BackEnd\System\Repository\SysAddress.Repository.pas',
  SysAddress.Service in 'BackEnd\System\Service\SysAddress.Service.pas',
  SysCountry in 'BackEnd\System\Domain\SysCountry.pas',
  SysRegion in 'BackEnd\System\Domain\SysRegion.pas',
  SysViewColumn in 'BackEnd\System\Domain\SysViewColumn.pas',
  SysUser.Repository in 'BackEnd\System\Repository\SysUser.Repository.pas',
  SysPermission.Repository in 'BackEnd\System\Repository\SysPermission.Repository.pas',
  SysPermissionGroup.Repository in 'BackEnd\System\Repository\SysPermissionGroup.Repository.pas',
  EmpPerson.Repository in 'BackEnd\Employee\Repository\EmpPerson.Repository.pas',
  EmpPersonType.Repository in 'BackEnd\Employee\Repository\EmpPersonType.Repository.pas',
  EmpUnit.Repository in 'BackEnd\Employee\Repository\EmpUnit.Repository.pas',
  EmpSection.Repository in 'BackEnd\Employee\Repository\EmpSection.Repository.pas',
  EmpTask.Repository in 'BackEnd\Employee\Repository\EmpTask.Repository.pas',
  SysCountry.Repository in 'BackEnd\System\Repository\SysCountry.Repository.pas',
  SysRegion.Repository in 'BackEnd\System\Repository\SysRegion.Repository.pas',
  SysUser.Service in 'BackEnd\System\Service\SysUser.Service.pas',
  SysPermission.Service in 'BackEnd\System\Service\SysPermission.Service.pas',
  SysResourceGroup.Service in 'BackEnd\System\Service\SysResourceGroup.Service.pas',
  SysPermissionGroup.Service in 'BackEnd\System\Service\SysPermissionGroup.Service.pas',
  EmpPerson.Service in 'BackEnd\Employee\Service\EmpPerson.Service.pas',
  EmpPersonType.Service in 'BackEnd\Employee\Service\EmpPersonType.Service.pas',
  EmpUnit.Service in 'BackEnd\Employee\Service\EmpUnit.Service.pas',
  EmpSection.Service in 'BackEnd\Employee\Service\EmpSection.Service.pas',
  EmpTask.Service in 'BackEnd\Employee\Service\EmpTask.Service.pas',
  SysCountry.Service in 'BackEnd\System\Service\SysCountry.Service.pas',
  SysRegion.Service in 'BackEnd\System\Service\SysRegion.Service.pas',
  ufrmSysCountries in 'Forms\System\ufrmSysCountries.pas',
  ufrmSysCountry in 'Forms\System\ufrmSysCountry.pas' {frmSysCountry},
  ufrmSysRegion in 'Forms\System\ufrmSysRegion.pas' {frmSysRegion},
  ufrmSysRegions in 'Forms\System\ufrmSysRegions.pas' {frmSysRegions},
  SysResourceGroup.Repository in 'BackEnd\System\Repository\SysResourceGroup.Repository.pas';

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
