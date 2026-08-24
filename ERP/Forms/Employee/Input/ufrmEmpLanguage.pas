unit ufrmEmpLanguage;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpLanguage.Service, EmpLanguage, LocalizationManager;

type
  TfrmEmpLanguage = class(TfrmInputSimpleDB<TEmpLanguage, TEmpLanguageService>)
    pnlContent: TPanel;
    lblLanguageName: TLabel;
    edtLanguageName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmEmpLanguage.BtnAcceptClick(Sender: TObject);
begin
  Table.LanguageName := edtLanguageName.Text;
  inherited;
end;

procedure TfrmEmpLanguage.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmEmpLanguage.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtLanguageName.SetFocus;
end;

procedure TfrmEmpLanguage.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_language.title_singular', 'Yabancı Dil');
  lblLanguageName.Caption := TLocalizationManager.Translate('emp_language.lbl_language_name', 'Dil Adı');
end;

procedure TfrmEmpLanguage.InitializeInputCase;
begin
  inherited;
  edtLanguageName.thsInputDataType := itString;
  edtLanguageName.MaxLength := 16;
end;

procedure TfrmEmpLanguage.RefreshData;
begin
  inherited;
  edtLanguageName.Text := Table.LanguageName;
end;

end.
