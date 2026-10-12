unit ufrmFinPosTransaction;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  FinPosTransaction.Service, FinPosTransaction;

type
  TfrmFinPosTransaction = class(TfrmInputSimpleDB<TFinPosTransaction, TFinPosTransactionService>)
    pnlContent: TPanel;
    lblFinPosTerminalId: TLabel;
    edtFinPosTerminalId: TEdit;
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
    lblCommissionRate: TLabel;
    edtCommissionRate: TEdit;
    lblCommissionAmount: TLabel;
    edtCommissionAmount: TEdit;
    lblNetAmount: TLabel;
    edtNetAmount: TEdit;
    lblValueDate: TLabel;
    edtValueDate: TEdit;
    lblCardHolder: TLabel;
    edtCardHolder: TEdit;
    lblCardLastDigits: TLabel;
    edtCardLastDigits: TEdit;
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
  FinPosTerminal, FinPosTerminal.Service, ufrmFinPosTerminals,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmFinPosTransaction.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.TransactionDate := StrToDateDef(edtTransactionDate.Text, 0);
  Table.TransactionType := cbbTransactionType.ItemIndex + 1;
  Table.Amount := StrToCurrDef(edtAmount.Text, 0);
  Table.InstallmentCount := StrToIntDef(edtInstallmentCount.Text, 0);
  Table.Description := edtDescription.Text;
  Table.CommissionRate := StrToCurrDef(edtCommissionRate.Text, 0);
  Table.ValueDate := StrToDateDef(edtValueDate.Text, 0);
  Table.CardHolder := edtCardHolder.Text;
  Table.CardLastDigits := edtCardLastDigits.Text;
  inherited;
end;

procedure TfrmFinPosTransaction.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtFinPosTerminalId.OnHelperProcess := HelperProcess;
  edtTransactionDate.thsInputDataType := itDate;
  TFinLookup.FillItems(cbbTransactionType.Items, flkPosTxType);
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtAmount.thsInputDataType := itFloat;
  edtInstallmentCount.thsInputDataType := itInteger;
  edtDescription.thsInputDataType := itString;
  edtCommissionRate.thsInputDataType := itFloat;
  edtValueDate.thsInputDataType := itDate;
  edtCardHolder.thsInputDataType := itString;
  edtCardLastDigits.thsInputDataType := itString;
end;

procedure TfrmFinPosTransaction.FormShow(Sender: TObject);
begin
  inherited;
  if edtTransactionDate.CanFocus then
    edtTransactionDate.SetFocus;
end;

procedure TfrmFinPosTransaction.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.TitleSingular, 'POS Collection');
  lblFinPosTerminalId.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColFinPosTerminalId, 'POS');
  lblTransactionDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColTransactionDate, 'Date');
  lblTransactionType.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColTransactionType, 'Transaction Type');
  LIndex := cbbTransactionType.ItemIndex;
  TFinLookup.FillItems(cbbTransactionType.Items, flkPosTxType);
  cbbTransactionType.ItemIndex := LIndex;
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColAccAccountId, 'Account (Customer)');
  lblAmount.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColAmount, 'Amount');
  lblInstallmentCount.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColInstallmentCount, 'Installments');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColDescription, 'Description');
  lblCommissionRate.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCommissionRate, 'Commission Rate (%)');
  lblCommissionAmount.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCommissionAmount, 'Commission Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColNetAmount, 'Net Amount');
  lblValueDate.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColValueDate, 'Value Date');
  lblCardHolder.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCardHolder, 'Card Holder');
  lblCardLastDigits.Caption := TLocalizationManager.Translate(TLangKeys.TFinPosTransaction.ColCardLastDigits, 'Card Last 4 Digits');
end;

procedure TfrmFinPosTransaction.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmFinPosTerminalId: TfrmFinPosTerminals;
  LFrmAccAccountId: TfrmAccAccounts;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtFinPosTerminalId.Name then
  begin
    LFrmFinPosTerminalId := TfrmFinPosTerminals.Create(LEdit, TFinPosTerminalService.Create, TFinPosTerminal.Create);
    try
      LFrmFinPosTerminalId.IsHelper := True;
      LFrmFinPosTerminalId.ShowModal;
      if LFrmFinPosTerminalId.DataTransfer then
        if LFrmFinPosTerminalId.CleanAndClose then
        begin
          Table.FinPosTerminalId := 0;
          Table.PosName := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.FinPosTerminalId := LFrmFinPosTerminalId.Table.Id;
          Table.PosName := LFrmFinPosTerminalId.Table.PosName;
          Table.Currency := LFrmFinPosTerminalId.Table.Currency;
          LEdit.Text := Table.PosName;
        end;
      // Seçilen POS'un komisyon oranı öneri olarak gelir
      if LFrmFinPosTerminalId.DataTransfer and not LFrmFinPosTerminalId.CleanAndClose then
      begin
        Table.CommissionRate := LFrmFinPosTerminalId.Table.CommissionRate;
        edtCommissionRate.Text := CurrToStr(Table.CommissionRate);
      end;
    finally
      LFrmFinPosTerminalId.Free;
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

procedure TfrmFinPosTransaction.RefreshData;
begin
  inherited;
  edtFinPosTerminalId.Text := Table.PosName;
  if Table.TransactionDate > 0 then
    edtTransactionDate.Text := DateToStr(Table.TransactionDate)
  else
    edtTransactionDate.Text := '';
  cbbTransactionType.ItemIndex := Table.TransactionType - 1;
  edtAccAccountId.Text := Table.AccountName;
  edtAmount.Text := CurrToStr(Table.Amount);
  edtInstallmentCount.Text := IntToStr(Table.InstallmentCount);
  edtDescription.Text := Table.Description;
  edtCommissionRate.Text := CurrToStr(Table.CommissionRate);
  edtCommissionAmount.Text := CurrToStr(Table.CommissionAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  if Table.ValueDate > 0 then
    edtValueDate.Text := DateToStr(Table.ValueDate)
  else
    edtValueDate.Text := '';
  edtCardHolder.Text := Table.CardHolder;
  edtCardLastDigits.Text := Table.CardLastDigits;
end;

end.
