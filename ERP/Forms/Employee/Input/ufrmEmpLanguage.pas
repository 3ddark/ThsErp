unit ufrmEmpLanguage;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpLanguage.Service, EmpLanguage;

type
  TfrmEmpLanguage = class(TfrmInputSimpleDB<TEmpLanguage, TEmpLanguageService>)
    pnlContent: TPanel;
    lblLanguageName: TLabel;
    edtLanguageName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
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
  edtLanguageName.thsInputDataType := itString;
end;

procedure TfrmEmpLanguage.FormShow(Sender: TObject);
begin
  inherited;
  if edtLanguageName.CanFocus then
    edtLanguageName.SetFocus;
end;

procedure TfrmEmpLanguage.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguage.TitleSingular, 'Foreign Language');
  lblLanguageName.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguage.ColLanguageName, 'Language');
end;

procedure TfrmEmpLanguage.RefreshData;
begin
  inherited;
  edtLanguageName.Text := Table.LanguageName;
end;

end.
