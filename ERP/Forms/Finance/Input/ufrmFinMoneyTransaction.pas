unit ufrmFinMoneyTransaction;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinMoneyTransaction.Service, FinMoneyTransaction;

type
  TfrmFinMoneyTransaction = class(TfrmInputSimpleDB<TFinMoneyTransaction, TFinMoneyTransactionService>)
    pnlContent: TPanel;
    lblFinMoneyAccountId: TLabel;
    edtFinMoneyAccountId: TEdit;
    lblTransactionDate: TLabel;
    edtTransactionDate: TEdit;
    lblTransactionType: TLabel;
    cbbTransactionType: TComboBox;
    lblTransferMethod: TLabel;
    cbbTransferMethod: TComboBox;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblTargetFinMoneyAccountId: TLabel;
    edtTargetFinMoneyAccountId: TEdit;
    lblAmount: TLabel;
    edtAmount: TEdit;
    lblDocumentNo: TLabel;
    edtDocumentNo: TEdit;
    lblCounterpartyName: TLabel;
    edtCounterpartyName: TEdit;
    lblCounterpartyIban: TLabel;
    edtCounterpartyIban: TEdit;
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
  FinMoneyAccount, FinMoneyAccount.Service, ufrmFinMoneyAccounts,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmFinMoneyTransaction.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TransactionDate := StrToDateDef(edtTransactionDate.Text, 0);
  Table.TransactionType := cbbTransactionType.ItemIndex + 1;
  Table.TransferMethod := cbbTransferMethod.ItemIndex + 1;
  Table.Amount := StrToCurrDef(edtAmount.Text, 0);
  Table.DocumentNo := edtDocumentNo.Text;
  Table.CounterpartyName := edtCounterpartyName.Text;
  Table.CounterpartyIban := edtCounterpartyIban.Text;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmFinMoneyTransaction.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtFinMoneyAccountId.OnHelperProcess := HelperProcess;
  edtTransactionDate.thsInputDataType := itDate;
  TFinLookup.FillItems(cbbTransactionType.Items, flkMoneyTxType);
  TFinLookup.FillItems(cbbTransferMethod.Items, flkTransferMethod);
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtTargetFinMoneyAccountId.OnHelperProcess := HelperProcess;
  edtAmount.thsInputDataType := itFloat;
  edtDocumentNo.thsInputDataType := itString;
  edtDocumentNo.CharCase := TEditCharCase.ecUpperCase;
  edtCounterpartyName.thsInputDataType := itString;
  edtCounterpartyIban.thsInputDataType := itString;
  edtCounterpartyIban.CharCase := TEditCharCase.ecUpperCase;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmFinMoneyTransaction.FormShow(Sender: TObject);
begin
  inherited;
  if edtTransactionDate.CanFocus then
    edtTransactionDate.SetFocus;
end;

procedure TfrmFinMoneyTransaction.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.TitleSingular, 'Money Transaction');
  lblFinMoneyAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColFinMoneyAccountId, 'Cash / Bank Account');
  lblTransactionDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTransactionDate, 'Date');
  lblTransactionType.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTransactionType, 'Transaction Type');
  LIndex := cbbTransactionType.ItemIndex;
  TFinLookup.FillItems(cbbTransactionType.Items, flkMoneyTxType);
  cbbTransactionType.ItemIndex := LIndex;
  lblTransferMethod.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTransferMethod, 'Transfer Method');
  LIndex := cbbTransferMethod.ItemIndex;
  TFinLookup.FillItems(cbbTransferMethod.Items, flkTransferMethod);
  cbbTransferMethod.ItemIndex := LIndex;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColAccAccountId, 'Account');
  lblTargetFinMoneyAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColTargetFinMoneyAccountId, 'Target Account (Transfer)');
  lblAmount.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColAmount, 'Amount');
  lblDocumentNo.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColDocumentNo, 'Document / Receipt No');
  lblCounterpartyName.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColCounterpartyName, 'Sender / Receiver');
  lblCounterpartyIban.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColCounterpartyIban, 'Sender / Receiver IBAN');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TFinMoneyTransaction.ColDescription, 'Description');
end;

procedure TfrmFinMoneyTransaction.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmFinMoneyAccountId: TfrmFinMoneyAccounts;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmTargetFinMoneyAccountId: TfrmFinMoneyAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtFinMoneyAccountId.Name then
  begin
    LFrmFinMoneyAccountId := TfrmFinMoneyAccounts.Create(LEdit, TFinMoneyAccountService.Create, TFinMoneyAccount.Create);
    try
      LFrmFinMoneyAccountId.IsHelper := True;
      LFrmFinMoneyAccountId.ShowModal;
      if LFrmFinMoneyAccountId.DataTransfer then
        if LFrmFinMoneyAccountId.CleanAndClose then
        begin
          Table.FinMoneyAccountId := 0;
          Table.MoneyAccountName := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.FinMoneyAccountId := LFrmFinMoneyAccountId.Table.Id;
          Table.MoneyAccountName := LFrmFinMoneyAccountId.Table.Name;
          Table.Currency := LFrmFinMoneyAccountId.Table.Currency;
          LEdit.Text := Table.MoneyAccountName;
        end;
    finally
      LFrmFinMoneyAccountId.Free;
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
  end
  else if LEdit.Name = edtTargetFinMoneyAccountId.Name then
  begin
    LFrmTargetFinMoneyAccountId := TfrmFinMoneyAccounts.Create(LEdit, TFinMoneyAccountService.Create, TFinMoneyAccount.Create);
    try
      LFrmTargetFinMoneyAccountId.IsHelper := True;
      LFrmTargetFinMoneyAccountId.ShowModal;
      if LFrmTargetFinMoneyAccountId.DataTransfer then
        if LFrmTargetFinMoneyAccountId.CleanAndClose then
        begin
          Table.TargetFinMoneyAccountId := 0;
          Table.TargetMoneyAccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.TargetFinMoneyAccountId := LFrmTargetFinMoneyAccountId.Table.Id;
          Table.TargetMoneyAccountName := LFrmTargetFinMoneyAccountId.Table.Name;
          LEdit.Text := Table.TargetMoneyAccountName;
        end;
    finally
      LFrmTargetFinMoneyAccountId.Free;
    end;
  end;
end;

procedure TfrmFinMoneyTransaction.RefreshData;
begin
  inherited;
  edtFinMoneyAccountId.Text := Table.MoneyAccountName;
  if Table.TransactionDate > 0 then
    edtTransactionDate.Text := DateToStr(Table.TransactionDate)
  else
    edtTransactionDate.Text := '';
  cbbTransactionType.ItemIndex := Table.TransactionType - 1;
  cbbTransferMethod.ItemIndex := Table.TransferMethod - 1;
  edtAccAccountId.Text := Table.AccountName;
  edtTargetFinMoneyAccountId.Text := Table.TargetMoneyAccountName;
  edtAmount.Text := CurrToStr(Table.Amount);
  edtDocumentNo.Text := Table.DocumentNo;
  edtCounterpartyName.Text := Table.CounterpartyName;
  edtCounterpartyIban.Text := Table.CounterpartyIban;
  edtDescription.Text := Table.Description;
end;

end.
