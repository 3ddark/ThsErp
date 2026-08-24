unit ufrmEmpLanguageLevel;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpLanguageLevel.Service, EmpLanguageLevel, LocalizationManager;

type
  TfrmEmpLanguageLevel = class(TfrmInputSimpleDB<TEmpLanguageLevel, TEmpLanguageLevelService>)
    pnlContent: TPanel;
    lblLanguageLevel: TLabel;
    edtLanguageLevel: TEdit;
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

procedure TfrmEmpLanguageLevel.BtnAcceptClick(Sender: TObject);
begin
  Table.LanguageLevel := edtLanguageLevel.Text;
  inherited;
end;

procedure TfrmEmpLanguageLevel.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmEmpLanguageLevel.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtLanguageLevel.SetFocus;
end;

procedure TfrmEmpLanguageLevel.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_language_level.title_singular', 'Dil Seviyesi');
  lblLanguageLevel.Caption := TLocalizationManager.Translate('emp_language_level.lbl_language_level', 'Dil Seviyesi');
end;

procedure TfrmEmpLanguageLevel.InitializeInputCase;
begin
  inherited;
  edtLanguageLevel.thsInputDataType := itString;
  edtLanguageLevel.MaxLength := 16;
end;

procedure TfrmEmpLanguageLevel.RefreshData;
begin
  inherited;
  edtLanguageLevel.Text := Table.LanguageLevel;
end;

end.
