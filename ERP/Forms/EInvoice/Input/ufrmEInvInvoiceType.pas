unit ufrmEInvInvoiceType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvInvoiceType.Service, EInvInvoiceType;

type
  TfrmEInvInvoiceType = class(TfrmInputSimpleDB<TEInvInvoiceType, TEInvInvoiceTypeService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblRequiresExemption: TLabel;
    chkRequiresExemption: TCheckBox;
    lblRequiresWithholding: TLabel;
    chkRequiresWithholding: TCheckBox;
    lblIsReturn: TLabel;
    chkIsReturn: TCheckBox;
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

procedure TfrmEInvInvoiceType.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.RequiresExemption := chkRequiresExemption.Checked;
  Table.RequiresWithholding := chkRequiresWithholding.Checked;
  Table.IsReturn := chkIsReturn.Checked;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvInvoiceType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
end;

procedure TfrmEInvInvoiceType.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvInvoiceType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.TitleSingular, 'e-Invoice Type');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColCode, 'Invoice Type Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColName, 'Name');
  lblRequiresExemption.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColRequiresExemption, 'Exemption Code Required');
  lblRequiresWithholding.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColRequiresWithholding, 'Withholding Required');
  lblIsReturn.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColIsReturn, 'Return Invoice');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvInvoiceType.ColIsActive, 'Active');
end;

procedure TfrmEInvInvoiceType.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  chkRequiresExemption.Checked := Table.RequiresExemption;
  chkRequiresWithholding.Checked := Table.RequiresWithholding;
  chkIsReturn.Checked := Table.IsReturn;
  chkIsActive.Checked := Table.IsActive;
end;

end.
