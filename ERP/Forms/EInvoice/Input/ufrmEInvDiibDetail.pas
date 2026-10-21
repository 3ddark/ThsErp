unit ufrmEInvDiibDetail;

// DİİB belgesi: başlık (einv_diib) + satırlar (Table.Lines, einv_diib_line) tek ekranda; satırlar bellekte belge
// servisiyle eklenir / değişir / çıkar (satır formu TfrmEInvDiibLine), Onayla tek transaction'da yazar.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Vcl.ComCtrls, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvDiib.Service, EInvDiib,
  EInvDiibLine, EInvDiibLine.Service;

type
  TfrmEInvDiibDetail = class(TfrmInputDetailedDB<TEInvDiib, TEInvDiibService>)
    pnlContent: TPanel;
    lblDocumentNo: TLabel;
    edtDocumentNo: TEdit;
    lblHolderType: TLabel;
    cbbHolderType: TComboBox;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblIssueDate: TLabel;
    edtIssueDate: TEdit;
    lblValidUntil: TLabel;
    edtValidUntil: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FPageLines: TTabSheet;
    FLines: TDetailSet<TEInvDiibLine>;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, Grid.Types, ufrmEInvDiibLine,
  EInvLookup,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmEInvDiibDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.DocumentNo := edtDocumentNo.Text;
  Table.HolderType := cbbHolderType.ItemIndex + 1;
  Table.IssueDate := StrToDateDef(edtIssueDate.Text, 0);
  Table.ValidUntil := StrToDateDef(edtValidUntil.Text, 0);
  Table.Description := edtDescription.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvDiibDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtDocumentNo.thsInputDataType := itString;
  edtDocumentNo.CharCase := TEditCharCase.ecUpperCase;
  TEInvLookup.FillItems(cbbHolderType.Items, elkDiibHolder);
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtIssueDate.thsInputDataType := itDate;
  edtValidUntil.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;

  // Satırlar = Table.Lines (satır no sırasıyla)
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TEInvDiib.MenuLines, 'Lines'));
  FLines := AddDetail<TEInvDiibLine>(FPageLines, 'vw_einv_diib_line',
    function: TObjectList<TEInvDiibLine>
    begin
      Result := Table.Lines;
    end,
    function: TEInvDiibLine
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TEInvDiibLine)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TEInvDiibLine)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TEInvDiibLine; AMode: TInputFormMode): TForm
    begin
      Result := TfrmEInvDiibLine.Create(Self, TEInvDiibLineService.Create, ALine, AMode, nil);
    end);
  FLines.Grid.AddFooterColumn('quantity', atSum, TDecimalPlaces.DisplayFormat(TDecimalPlaces.Quantity));
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('einv_diib_id', 0);
  FLines.Grid.SetColumnProperty('document_no', 0);
  FLines.Grid.SetColumnProperty('holder_type', 0);
  FLines.Grid.SetColumnProperty('acc_account_id', 0);
  FLines.Grid.SetColumnProperty('account_name', 0);
  FLines.Grid.SetColumnProperty('einv_gtip_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('sys_uom_id', 0);
  FLines.Grid.SetColumnProperty('uom_einv_code', 0);
  FLines.Grid.SetColumnProperty('diib_is_active', 0);
  FLines.Grid.SetColumnProperty('valid_until', 0);
  FLines.Grid.SetColumnProperty('gtip_code', 100);
  FLines.Grid.SetColumnProperty('inventory_name', 160);
  FLines.Grid.SetColumnProperty('line_code', 80);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('product_description', 240);
end;

procedure TfrmEInvDiibDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtDocumentNo.CanFocus then
    edtDocumentNo.SetFocus;
end;

procedure TfrmEInvDiibDetail.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.TitleSingular, 'DIIB Certificate');
  lblDocumentNo.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColDocumentNo, 'DIIB No');
  lblHolderType.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColHolderType, 'Certificate Holder');
  LIndex := cbbHolderType.ItemIndex;
  TEInvLookup.FillItems(cbbHolderType.Items, elkDiibHolder);
  cbbHolderType.ItemIndex := LIndex;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColAccAccountId, 'Customer / Exporter');
  lblIssueDate.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColIssueDate, 'Issue Date');
  lblValidUntil.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColValidUntil, 'Valid Until');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColDescription, 'Description');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.ColIsActive, 'Active');

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDiib.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('line_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineCode, 'Line Code'));
    FLines.Grid.SetColumnTitle('line_kind', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColLineKind, 'Line Kind'));
    FLines.Grid.SetColumnTitle('gtip_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColGtipCode, 'Gtip Code'));
    FLines.Grid.SetColumnTitle('gtip_name', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColGtipName, 'Gtip Name'));
    FLines.Grid.SetColumnTitle('product_description', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColProductDescription, 'Product Description'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColInventoryCode, 'Inventory Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColInventoryName, 'Inventory Name'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_code', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColUnitCode, 'Unit Code'));
    FLines.Grid.SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvDiibLine.ColIsActive, 'Is Active'));
  end;
end;

procedure TfrmEInvDiibDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccAccountId.Name then
  begin
    LFrmAccAccountId := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountId.IsHelper := True;
      LFrmAccAccountId.ShowModal;
      if LFrmAccAccountId.DataTransfer then
        if LFrmAccAccountId.CleanAndClose then
        begin
          Table.AccAccountId := 0;
          Table.AccountCode := '';
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
        end;
    finally
      LFrmAccAccountId.Free;
    end;
  end;
end;

procedure TfrmEInvDiibDetail.RefreshData;
begin
  inherited;
  edtDocumentNo.Text := Table.DocumentNo;
  cbbHolderType.ItemIndex := Table.HolderType - 1;
  edtAccAccountId.Text := Table.AccountName;
  if Table.IssueDate > 0 then
    edtIssueDate.Text := DateToStr(Table.IssueDate)
  else
    edtIssueDate.Text := '';
  if Table.ValidUntil > 0 then
    edtValidUntil.Text := DateToStr(Table.ValidUntil)
  else
    edtValidUntil.Text := '';
  edtDescription.Text := Table.Description;
  chkIsActive.Checked := Table.IsActive;
end;

end.
