unit ufrmFinCreditCardTransaction;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinCreditCardTransaction.Service, FinCreditCardTransaction;

type
  TfrmFinCreditCardTransaction = class(TfrmInputSimpleDB<TFinCreditCardTransaction, TFinCreditCardTransactionService>)
    pnlContent: TPanel;
    lblFinCreditCardId: TLabel;
    edtFinCreditCardId: TEdit;
    lblTransactionDate: TLabel;
    edtTransactionDate: TEdit;
    lblTransactionType: TLabel;
    cbbTransactionType: TComboBox;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblAmount: TLabel;
    edtAmount: TEdit;
    lblInstallmentCount: TLabel;
    edtInstallmentCount: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
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
  FinLookup,
  FinCreditCard, FinCreditCard.Service, ufrmFinCreditCards,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmFinCreditCardTransaction.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TransactionDate := StrToDateDef(edtTransactionDate.Text, 0);
  Table.TransactionType := cbbTransactionType.ItemIndex + 1;
  Table.Amount := StrToCurrDef(edtAmount.Text, 0);
  Table.InstallmentCount := StrToIntDef(edtInstallmentCount.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmFinCreditCardTransaction.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtFinCreditCardId.OnHelperProcess := HelperProcess;
  edtTransactionDate.thsInputDataType := itDate;
  TFinLookup.FillItems(cbbTransactionType.Items, flkCardTxType);
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtAmount.thsInputDataType := itFloat;
  edtInstallmentCount.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmFinCreditCardTransaction.FormShow(Sender: TObject);
begin
  inherited;
  if edtTransactionDate.CanFocus then
    edtTransactionDate.SetFocus;
end;

procedure TfrmFinCreditCardTransaction.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.TitleSingular, 'Credit Card Transaction');
  lblFinCreditCardId.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColFinCreditCardId, 'Credit Card');
  lblTransactionDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColTransactionDate, 'Date');
  lblTransactionType.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColTransactionType, 'Transaction Type');
  LIndex := cbbTransactionType.ItemIndex;
  TFinLookup.FillItems(cbbTransactionType.Items, flkCardTxType);
  cbbTransactionType.ItemIndex := LIndex;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColAccAccountId, 'Account (Merchant)');
  lblAmount.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColAmount, 'Amount');
  lblInstallmentCount.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColInstallmentCount, 'Installments');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCardTransaction.ColDescription, 'Description');
end;

procedure TfrmFinCreditCardTransaction.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmFinCreditCardId: TfrmFinCreditCards;
  LFrmAccAccountId: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtFinCreditCardId.Name then
  begin
    LFrmFinCreditCardId := TfrmFinCreditCards.Create(LEdit, TFinCreditCardService.Create, TFinCreditCard.Create);
    try
      LFrmFinCreditCardId.IsHelper := True;
      LFrmFinCreditCardId.ShowModal;
      if LFrmFinCreditCardId.DataTransfer then
        if LFrmFinCreditCardId.CleanAndClose then
        begin
          Table.FinCreditCardId := 0;
          Table.CardName := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.FinCreditCardId := LFrmFinCreditCardId.Table.Id;
          Table.CardName := LFrmFinCreditCardId.Table.CardName;
          Table.Currency := LFrmFinCreditCardId.Table.Currency;
          LEdit.Text := Table.CardName;
        end;
    finally
      LFrmFinCreditCardId.Free;
    end;
  end
  else if LEdit.Name = edtAccAccountId.Name then
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

procedure TfrmFinCreditCardTransaction.RefreshData;
begin
  inherited;
  edtFinCreditCardId.Text := Table.CardName;
  if Table.TransactionDate > 0 then
    edtTransactionDate.Text := DateToStr(Table.TransactionDate)
  else
    edtTransactionDate.Text := '';
  cbbTransactionType.ItemIndex := Table.TransactionType - 1;
  edtAccAccountId.Text := Table.AccountName;
  edtAmount.Text := CurrToStr(Table.Amount);
  edtInstallmentCount.Text := IntToStr(Table.InstallmentCount);
  edtDescription.Text := Table.Description;
end;

end.
