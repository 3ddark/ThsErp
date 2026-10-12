unit ufrmFinChequeNoteTransaction;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinChequeNoteTransaction.Service, FinChequeNoteTransaction;

type
  TfrmFinChequeNoteTransaction = class(TfrmInputSimpleDB<TFinChequeNoteTransaction, TFinChequeNoteTransactionService>)
    pnlContent: TPanel;
    lblFinChequeNoteId: TLabel;
    edtFinChequeNoteId: TEdit;
    lblTransactionDate: TLabel;
    edtTransactionDate: TEdit;
    lblTransactionType: TLabel;
    cbbTransactionType: TComboBox;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
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
  FinChequeNote, FinChequeNote.Service, ufrmFinChequeNotes,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  AccBank, AccBank.Service, ufrmAccBanks;

procedure TfrmFinChequeNoteTransaction.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TransactionDate := StrToDateDef(edtTransactionDate.Text, 0);
  Table.TransactionType := cbbTransactionType.ItemIndex + 1;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmFinChequeNoteTransaction.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtFinChequeNoteId.OnHelperProcess := HelperProcess;
  edtTransactionDate.thsInputDataType := itDate;
  TFinLookup.FillItems(cbbTransactionType.Items, flkChequeStatus);
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmFinChequeNoteTransaction.FormShow(Sender: TObject);
begin
  inherited;
  if edtTransactionDate.CanFocus then
    edtTransactionDate.SetFocus;
end;

procedure TfrmFinChequeNoteTransaction.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.TitleSingular, 'Cheque / Note Transaction');
  lblFinChequeNoteId.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColFinChequeNoteId, 'Cheque / Note');
  lblTransactionDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColTransactionDate, 'Date');
  lblTransactionType.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColTransactionType, 'Transaction Type');
  LIndex := cbbTransactionType.ItemIndex;
  TFinLookup.FillItems(cbbTransactionType.Items, flkChequeStatus);
  cbbTransactionType.ItemIndex := LIndex;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColAccAccountId, 'Account');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColAccBankId, 'Bank');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TFinChequeNoteTransaction.ColDescription, 'Description');
end;

procedure TfrmFinChequeNoteTransaction.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmFinChequeNoteId: TfrmFinChequeNotes;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmAccBankId: TfrmAccBanks;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtFinChequeNoteId.Name then
  begin
    LFrmFinChequeNoteId := TfrmFinChequeNotes.Create(LEdit, TFinChequeNoteService.Create, TFinChequeNote.Create);
    try
      LFrmFinChequeNoteId.IsHelper := True;
      LFrmFinChequeNoteId.ShowModal;
      if LFrmFinChequeNoteId.DataTransfer then
        if LFrmFinChequeNoteId.CleanAndClose then
        begin
          Table.FinChequeNoteId := 0;
          Table.PortfolioNo := '';
          Table.SerialNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.FinChequeNoteId := LFrmFinChequeNoteId.Table.Id;
          Table.PortfolioNo := LFrmFinChequeNoteId.Table.PortfolioNo;
          Table.SerialNo := LFrmFinChequeNoteId.Table.SerialNo;
          LEdit.Text := Table.PortfolioNo;
        end;
    finally
      LFrmFinChequeNoteId.Free;
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
  else if LEdit.Name = edtAccBankId.Name then
  begin
    LFrmAccBankId := TfrmAccBanks.Create(LEdit, TAccBankService.Create, TAccBank.Create);
    try
      LFrmAccBankId.IsHelper := True;
      LFrmAccBankId.ShowModal;
      if LFrmAccBankId.DataTransfer then
        if LFrmAccBankId.CleanAndClose then
        begin
          Table.AccBankId := 0;
          Table.BankName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccBankId := LFrmAccBankId.Table.Id;
          Table.BankName := LFrmAccBankId.Table.BankName;
          LEdit.Text := Table.BankName;
        end;
    finally
      LFrmAccBankId.Free;
    end;
  end;
end;

procedure TfrmFinChequeNoteTransaction.RefreshData;
begin
  inherited;
  edtFinChequeNoteId.Text := Table.PortfolioNo;
  if Table.TransactionDate > 0 then
    edtTransactionDate.Text := DateToStr(Table.TransactionDate)
  else
    edtTransactionDate.Text := '';
  cbbTransactionType.ItemIndex := Table.TransactionType - 1;
  edtAccAccountId.Text := Table.AccountName;
  edtAccBankId.Text := Table.BankName;
  edtDescription.Text := Table.Description;
end;

end.
