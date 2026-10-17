unit ufrmEInvTaxExemption;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvTaxExemption.Service, EInvTaxExemption;

type
  TfrmEInvTaxExemption = class(TfrmInputSimpleDB<TEInvTaxExemption, TEInvTaxExemptionService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblExemptionGroup: TLabel;
    cbbExemptionGroup: TComboBox;
    lblEinvInvoiceTypeId: TLabel;
    edtEinvInvoiceTypeId: TEdit;
    lblRequiresGtip: TLabel;
    chkRequiresGtip: TCheckBox;
    lblRequiresDiib: TLabel;
    chkRequiresDiib: TCheckBox;
    lblRequiresZeroVat: TLabel;
    chkRequiresZeroVat: TCheckBox;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup,
  EInvInvoiceType, EInvInvoiceType.Service, ufrmEInvInvoiceTypes;

procedure TfrmEInvTaxExemption.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.ExemptionGroup := cbbExemptionGroup.ItemIndex + 1;
  Table.RequiresGtip := chkRequiresGtip.Checked;
  Table.RequiresDiib := chkRequiresDiib.Checked;
  Table.RequiresZeroVat := chkRequiresZeroVat.Checked;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvTaxExemption.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  TEInvLookup.FillItems(cbbExemptionGroup.Items, elkExemptionGroup);
  edtEinvInvoiceTypeId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEInvTaxExemption.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvTaxExemption.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.TitleSingular, 'Tax Exemption Code');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColCode, 'Exemption Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColName, 'Reason');
  lblExemptionGroup.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColExemptionGroup, 'Exemption Group');
  LIndex := cbbExemptionGroup.ItemIndex;
  TEInvLookup.FillItems(cbbExemptionGroup.Items, elkExemptionGroup);
  cbbExemptionGroup.ItemIndex := LIndex;
  lblEinvInvoiceTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColEinvInvoiceTypeId, 'Invoice Type');
  lblRequiresGtip.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColRequiresGtip, 'GTIP Required on Lines');
  lblRequiresZeroVat.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColRequiresZeroVat, 'Needs a 0% VAT Line');
  lblRequiresDiib.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColRequiresDiib, 'DIIB Line Code Required');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxExemption.ColIsActive, 'Active');
end;

procedure TfrmEInvTaxExemption.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEinvInvoiceTypeId: TfrmEInvInvoiceTypes;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtEinvInvoiceTypeId.Name then
  begin
    LFrmEinvInvoiceTypeId := TfrmEInvInvoiceTypes.Create(LEdit, TEInvInvoiceTypeService.Create, TEInvInvoiceType.Create);
    try
      LFrmEinvInvoiceTypeId.IsHelper := True;
      LFrmEinvInvoiceTypeId.ShowModal;
      if LFrmEinvInvoiceTypeId.DataTransfer then
        if LFrmEinvInvoiceTypeId.CleanAndClose then
        begin
          Table.EinvInvoiceTypeId := 0;
          Table.InvoiceTypeCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EinvInvoiceTypeId := LFrmEinvInvoiceTypeId.Table.Id;
          Table.InvoiceTypeCode := LFrmEinvInvoiceTypeId.Table.Code;
          LEdit.Text := Table.InvoiceTypeCode;
        end;
    finally
      LFrmEinvInvoiceTypeId.Free;
    end;
  end;
end;

procedure TfrmEInvTaxExemption.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  cbbExemptionGroup.ItemIndex := Table.ExemptionGroup - 1;
  edtEinvInvoiceTypeId.Text := Table.InvoiceTypeCode;
  chkRequiresGtip.Checked := Table.RequiresGtip;
  chkRequiresDiib.Checked := Table.RequiresDiib;
  chkRequiresZeroVat.Checked := Table.RequiresZeroVat;
  chkIsActive.Checked := Table.IsActive;
end;

end.
