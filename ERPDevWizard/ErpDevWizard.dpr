program ErpDevWizard;

{$I ThsERP.inc}

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {frmMainClassGenerator},
  Ths.Erp.Helper.BaseTypes in '..\ERP\BackEnd\Tools\Ths.Erp.Helper.BaseTypes.pas',
  Ths.Erp.Helper.Button in '..\ERP\BackEnd\Tools\Ths.Erp.Helper.Button.pas',
  Ths.Erp.Helper.ComboBox in '..\ERP\BackEnd\Tools\Ths.Erp.Helper.ComboBox.pas',
  Ths.Erp.Helper.Edit in '..\ERP\BackEnd\Tools\Ths.Erp.Helper.Edit.pas',
  Ths.Erp.Helper.Memo in '..\ERP\BackEnd\Tools\Ths.Erp.Helper.Memo.pas',
  Ths.Erp.Constants in '..\ERP\BackEnd\Framework\Ths.Erp.Constants.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Ths ERP Class Generator';
  Application.CreateForm(TfrmMainClassGenerator, frmMainClassGenerator);
  Application.Run;
end.
