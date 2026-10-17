unit ufrmEInvWithholding;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvWithholding.Service, EInvWithholding;

type
  TfrmEInvWithholding = class(TfrmInputSimpleDB<TEInvWithholding, TEInvWithholdingService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblRate: TLabel;
    edtRate: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvWithholding.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.Rate := StrToCurrDef(edtRate.Text, 0);
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvWithholding.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  edtRate.thsInputDataType := itFloat;
end;

procedure TfrmEInvWithholding.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvWithholding.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.TitleSingular, 'Withholding Code');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColCode, 'Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColName, 'Description');
  lblRate.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColRate, 'Withholding Rate (%)');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColIsActive, 'Active');
end;

procedure TfrmEInvWithholding.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  edtRate.Text := CurrToStr(Table.Rate);
  chkIsActive.Checked := Table.IsActive;
end;

end.
