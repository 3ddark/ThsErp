unit ufrmAccSetTaxRate;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccSetTaxRate.Service, AccSetTaxRate;

type
  TfrmAccSetTaxRate = class(TfrmInputSimpleDB<TAccSetTaxRate, TAccSetTaxRateService>)
    pnlContent: TPanel;
    lblTaxRate: TLabel;
    edtTaxRate: TEdit;
    lblSalesAccount: TLabel;
    edtSalesAccount: TEdit;
    lblSalesReturnAccount: TLabel;
    edtSalesReturnAccount: TEdit;
    lblPurchaseAccount: TLabel;
    edtPurchaseAccount: TEdit;
    lblPurchaseReturnAccount: TLabel;
    edtPurchaseReturnAccount: TEdit;
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
  AccAccount, AccAccount.Service, ufrmAccAccounts;                              // TfrmAccAccounts helper output form

procedure TfrmAccSetTaxRate.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TaxRate := StrToCurrDef(edtTaxRate.Text, 0);
  inherited;
end;

procedure TfrmAccSetTaxRate.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSalesAccount.OnHelperProcess := HelperProcess;
  edtSalesReturnAccount.OnHelperProcess := HelperProcess;
  edtPurchaseAccount.OnHelperProcess := HelperProcess;
  edtPurchaseReturnAccount.OnHelperProcess := HelperProcess;
  edtTaxRate.thsInputDataType := itFloat;
end;

procedure TfrmAccSetTaxRate.FormShow(Sender: TObject);
begin
  inherited;
  if edtTaxRate.CanFocus then
    edtTaxRate.SetFocus;
end;

procedure TfrmAccSetTaxRate.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.TitleSingular, 'Tax Rate');
  lblTaxRate.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColTaxRate, 'Tax Rate');
  lblSalesAccount.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColSalesAccount, 'Sales Account');
  lblSalesReturnAccount.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColSalesReturnAccount, 'Sales Return Account');
  lblPurchaseAccount.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColPurchaseAccount, 'Purchase Account');
  lblPurchaseReturnAccount.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColPurchaseReturnAccount, 'Purchase Return Account');
end;

procedure TfrmAccSetTaxRate.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmSalesAccount: TfrmAccAccounts;
  LFrmSalesReturnAccount: TfrmAccAccounts;
  LFrmPurchaseAccount: TfrmAccAccounts;
  LFrmPurchaseReturnAccount: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtSalesAccount.Name then
  begin
    LFrmSalesAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmSalesAccount.IsHelper := True;
      LFrmSalesAccount.ShowModal;
      if LFrmSalesAccount.DataTransfer then
        if LFrmSalesAccount.CleanAndClose then
        begin
          Table.SalesAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SalesAccount := LFrmSalesAccount.Table.Code;
          LEdit.Text := Table.SalesAccount;
        end;
    finally
      LFrmSalesAccount.Free;
    end;
  end
  else if LEdit.Name = edtSalesReturnAccount.Name then
  begin
    LFrmSalesReturnAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmSalesReturnAccount.IsHelper := True;
      LFrmSalesReturnAccount.ShowModal;
      if LFrmSalesReturnAccount.DataTransfer then
        if LFrmSalesReturnAccount.CleanAndClose then
        begin
          Table.SalesReturnAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SalesReturnAccount := LFrmSalesReturnAccount.Table.Code;
          LEdit.Text := Table.SalesReturnAccount;
        end;
    finally
      LFrmSalesReturnAccount.Free;
    end;
  end
  else if LEdit.Name = edtPurchaseAccount.Name then
  begin
    LFrmPurchaseAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmPurchaseAccount.IsHelper := True;
      LFrmPurchaseAccount.ShowModal;
      if LFrmPurchaseAccount.DataTransfer then
        if LFrmPurchaseAccount.CleanAndClose then
        begin
          Table.PurchaseAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurchaseAccount := LFrmPurchaseAccount.Table.Code;
          LEdit.Text := Table.PurchaseAccount;
        end;
    finally
      LFrmPurchaseAccount.Free;
    end;
  end
  else if LEdit.Name = edtPurchaseReturnAccount.Name then
  begin
    LFrmPurchaseReturnAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmPurchaseReturnAccount.IsHelper := True;
      LFrmPurchaseReturnAccount.ShowModal;
      if LFrmPurchaseReturnAccount.DataTransfer then
        if LFrmPurchaseReturnAccount.CleanAndClose then
        begin
          Table.PurchaseReturnAccount := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurchaseReturnAccount := LFrmPurchaseReturnAccount.Table.Code;
          LEdit.Text := Table.PurchaseReturnAccount;
        end;
    finally
      LFrmPurchaseReturnAccount.Free;
    end;
  end;
end;

procedure TfrmAccSetTaxRate.RefreshData;
begin
  inherited;
  edtTaxRate.Text := CurrToStr(Table.TaxRate);
  edtSalesAccount.Text := Table.SalesAccount;
  edtSalesReturnAccount.Text := Table.SalesReturnAccount;
  edtPurchaseAccount.Text := Table.PurchaseAccount;
  edtPurchaseReturnAccount.Text := Table.PurchaseReturnAccount;
end;

end.
