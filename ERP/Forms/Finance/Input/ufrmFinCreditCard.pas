unit ufrmFinCreditCard;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinCreditCard.Service, FinCreditCard;

type
  TfrmFinCreditCard = class(TfrmInputSimpleDB<TFinCreditCard, TFinCreditCardService>)
    pnlContent: TPanel;
    lblCardName: TLabel;
    edtCardName: TEdit;
    lblAccBankId: TLabel;
    edtAccBankId: TEdit;
    lblCardHolder: TLabel;
    edtCardHolder: TEdit;
    lblCardLastDigits: TLabel;
    edtCardLastDigits: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblCardLimit: TLabel;
    edtCardLimit: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblStatementDay: TLabel;
    edtStatementDay: TEdit;
    lblPaymentDay: TLabel;
    edtPaymentDay: TEdit;
    lblAccAccountCode: TLabel;
    edtAccAccountCode: TEdit;
    lblNotes: TLabel;
    mmoNotes: TMemo;
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
  AccBank, AccBank.Service, ufrmAccBanks,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmFinCreditCard.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.CardName := edtCardName.Text;
  Table.CardHolder := edtCardHolder.Text;
  Table.CardLastDigits := edtCardLastDigits.Text;
  Table.IsActive := chkIsActive.Checked;
  Table.CardLimit := StrToCurrDef(edtCardLimit.Text, 0);
  Table.StatementDay := StrToIntDef(edtStatementDay.Text, 0);
  Table.PaymentDay := StrToIntDef(edtPaymentDay.Text, 0);
  Table.Notes := mmoNotes.Text;
  inherited;
end;

procedure TfrmFinCreditCard.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCardName.thsInputDataType := itString;
  edtAccBankId.OnHelperProcess := HelperProcess;
  edtCardHolder.thsInputDataType := itString;
  edtCardLastDigits.thsInputDataType := itString;
  edtCardLimit.thsInputDataType := itFloat;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtStatementDay.thsInputDataType := itInteger;
  edtPaymentDay.thsInputDataType := itInteger;
  edtAccAccountCode.OnHelperProcess := HelperProcess;
end;

procedure TfrmFinCreditCard.FormShow(Sender: TObject);
begin
  inherited;
  if edtCardName.CanFocus then
    edtCardName.SetFocus;
end;

procedure TfrmFinCreditCard.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.TitleSingular, 'Company Credit Card');
  lblCardName.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardName, 'Card Name');
  lblAccBankId.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColAccBankId, 'Bank');
  lblCardHolder.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardHolder, 'Card Holder');
  lblCardLastDigits.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardLastDigits, 'Card Last 4 Digits');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColIsActive, 'Active');
  lblCardLimit.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCardLimit, 'Card Limit');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColCurrency, 'Currency');
  lblStatementDay.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColStatementDay, 'Statement Day');
  lblPaymentDay.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColPaymentDay, 'Payment Day');
  lblAccAccountCode.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColAccAccountCode, 'Accounting Account');
  lblNotes.Caption := TLocalizationManager.Translate(TLangKeys.TFinCreditCard.ColNotes, 'Notes');
end;

procedure TfrmFinCreditCard.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccBankId: TfrmAccBanks;
  LFrmCurrency: TfrmSysCurrencies;
  LFrmAccAccountCode: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccBankId.Name then
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
  end
  else if LEdit.Name = edtCurrency.Name then
  begin
    LFrmCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmCurrency.IsHelper := True;
      LFrmCurrency.ShowModal;
      if LFrmCurrency.DataTransfer then
        if LFrmCurrency.CleanAndClose then
        begin
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.Currency := LFrmCurrency.Table.Currency;
          LEdit.Text := Table.Currency;
        end;
    finally
      LFrmCurrency.Free;
    end;
  end
  else if LEdit.Name = edtAccAccountCode.Name then
  begin
    LFrmAccAccountCode := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountCode.IsHelper := True;
      LFrmAccAccountCode.ShowModal;
      if LFrmAccAccountCode.DataTransfer then
        if LFrmAccAccountCode.CleanAndClose then
        begin
          Table.AccAccountCode := '';
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountCode := LFrmAccAccountCode.Table.Code;
          Table.AccountName := LFrmAccAccountCode.Table.Name;
          LEdit.Text := Table.AccAccountCode;
        end;
    finally
      LFrmAccAccountCode.Free;
    end;
  end;
end;

procedure TfrmFinCreditCard.RefreshData;
begin
  inherited;
  edtCardName.Text := Table.CardName;
  edtAccBankId.Text := Table.BankName;
  edtCardHolder.Text := Table.CardHolder;
  edtCardLastDigits.Text := Table.CardLastDigits;
  chkIsActive.Checked := Table.IsActive;
  edtCardLimit.Text := CurrToStr(Table.CardLimit);
  edtCurrency.Text := Table.Currency;
  if Table.StatementDay > 0 then
    edtStatementDay.Text := IntToStr(Table.StatementDay)
  else
    edtStatementDay.Text := '';
  if Table.PaymentDay > 0 then
    edtPaymentDay.Text := IntToStr(Table.PaymentDay)
  else
    edtPaymentDay.Text := '';
  edtAccAccountCode.Text := Table.AccAccountCode;
  mmoNotes.Text := Table.Notes;
end;

end.
