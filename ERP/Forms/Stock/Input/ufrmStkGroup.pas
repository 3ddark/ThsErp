unit ufrmStkGroup;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkGroup.Service, StkGroup;

type
  TfrmStkGroup = class(TfrmInputSimpleDB<TStkGroup, TStkGroupService>)
    pnlContent: TPanel;
    lblName: TLabel;
    edtName: TEdit;
    lblVatRate: TLabel;
    cbbVatRate: TComboBox;
    lblRawMaterialStockAccount: TLabel;
    edtRawMaterialStockAccount: TEdit;
    lblRawMaterialUsageAccount: TLabel;
    edtRawMaterialUsageAccount: TEdit;
    lblSemiProductAccount: TLabel;
    edtSemiProductAccount: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    // KDV oranı yalnız muhasebe ayarlarındaki tanımlı oranlardan (acc_set_tax_rate) seçilir
    procedure FillVatRates;
    procedure SelectVatRate(ARate: Currency);
    function SelectedVatRate: Currency;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  AccAccount, AccAccount.Service, ufrmAccAccounts;                              // TfrmAccAccounts helper output form

procedure TfrmStkGroup.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Name := edtName.Text;
  Table.VatRate := SelectedVatRate;
  inherited;
end;

procedure TfrmStkGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtRawMaterialStockAccount.OnHelperProcess := HelperProcess;
  edtRawMaterialUsageAccount.OnHelperProcess := HelperProcess;
  edtSemiProductAccount.OnHelperProcess := HelperProcess;
  edtName.thsInputDataType := itString;
  edtName.CharCase := TEditCharCase.ecUpperCase;
  cbbVatRate.thsRequiredData := True;
  FillVatRates;
end;

procedure TfrmStkGroup.FormShow(Sender: TObject);
begin
  inherited;
  if edtName.CanFocus then
    edtName.SetFocus;
end;

procedure TfrmStkGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.TitleSingular, 'Stock Group');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.ColName, 'Group Name');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.ColVatRate, 'VAT Rate (%)');
  lblRawMaterialStockAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.ColRawMaterialStockAccount, 'Raw Material Stock Account');
  lblRawMaterialUsageAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.ColRawMaterialUsageAccount, 'Raw Material Usage Account');
  lblSemiProductAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.ColSemiProductAccount, 'Semi-Product Account');
end;

procedure TfrmStkGroup.FillVatRates;
var
  LRate: Currency;
begin
  cbbVatRate.Items.BeginUpdate;
  try
    cbbVatRate.Items.Clear;
    for LRate in Service.GetVatRates do
      cbbVatRate.Items.Add(FormatFloat('0.##', LRate));
  finally
    cbbVatRate.Items.EndUpdate;
  end;
end;

// Yeni kayıtta / listede olmayan oranda seçim boş kalır (zorunlu alan, kaydetmede uyarılır)
procedure TfrmStkGroup.SelectVatRate(ARate: Currency);
begin
  cbbVatRate.ItemIndex := cbbVatRate.Items.IndexOf(FormatFloat('0.##', ARate));
end;

function TfrmStkGroup.SelectedVatRate: Currency;
begin
  if cbbVatRate.ItemIndex < 0 then
    Result := 0
  else
    Result := StrToCurrDef(cbbVatRate.Items[cbbVatRate.ItemIndex], 0);
end;

procedure TfrmStkGroup.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmRawMaterialStockAccount: TfrmAccAccounts;
  LFrmRawMaterialUsageAccount: TfrmAccAccounts;
  LFrmSemiProductAccount: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtRawMaterialStockAccount.Name then
  begin
    LFrmRawMaterialStockAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmRawMaterialStockAccount.IsHelper := True;
      LFrmRawMaterialStockAccount.ShowModal;
      if LFrmRawMaterialStockAccount.DataTransfer then
        if LFrmRawMaterialStockAccount.CleanAndClose then
        begin
          Table.RawMaterialStockAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.RawMaterialStockAccount := LFrmRawMaterialStockAccount.Table.Code;
          LEdit.Text := Table.RawMaterialStockAccount;
        end;
    finally
      LFrmRawMaterialStockAccount.Free;
    end;
  end
  else if LEdit.Name = edtRawMaterialUsageAccount.Name then
  begin
    LFrmRawMaterialUsageAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmRawMaterialUsageAccount.IsHelper := True;
      LFrmRawMaterialUsageAccount.ShowModal;
      if LFrmRawMaterialUsageAccount.DataTransfer then
        if LFrmRawMaterialUsageAccount.CleanAndClose then
        begin
          Table.RawMaterialUsageAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.RawMaterialUsageAccount := LFrmRawMaterialUsageAccount.Table.Code;
          LEdit.Text := Table.RawMaterialUsageAccount;
        end;
    finally
      LFrmRawMaterialUsageAccount.Free;
    end;
  end
  else if LEdit.Name = edtSemiProductAccount.Name then
  begin
    LFrmSemiProductAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmSemiProductAccount.IsHelper := True;
      LFrmSemiProductAccount.ShowModal;
      if LFrmSemiProductAccount.DataTransfer then
        if LFrmSemiProductAccount.CleanAndClose then
        begin
          Table.SemiProductAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SemiProductAccount := LFrmSemiProductAccount.Table.Code;
          LEdit.Text := Table.SemiProductAccount;
        end;
    finally
      LFrmSemiProductAccount.Free;
    end;
  end;
end;

procedure TfrmStkGroup.RefreshData;
begin
  inherited;
  edtName.Text := Table.Name;
  SelectVatRate(Table.VatRate);
  edtRawMaterialStockAccount.Text := Table.RawMaterialStockAccount;
  edtRawMaterialUsageAccount.Text := Table.RawMaterialUsageAccount;
  edtSemiProductAccount.Text := Table.SemiProductAccount;
end;

end.
