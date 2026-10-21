unit ufrmAccAccountTransactions;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccAccountTransaction.Service, AccAccountTransaction;

type
  TfrmAccAccountTransactions = class(TfrmGrid<TAccAccountTransaction, TAccAccountTransactionService>)
  private
    FFixedMasterName: string;
    FmniShowSource: TMenuItem;
    procedure mniShowSourceClick(Sender: TObject);
    procedure SourceTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedAccount(AAccountId: Int64; const AAccountName: string);
    // Satırı oluşturan kaynak belgeyi (fatura, çek / senet, tahsilat ...) kendi ekranında açar; okuma yetkisi kaynak serviste denetlenir
    procedure OpenSourceDocument(ASourceType: Integer; ADocumentId: Int64);
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  AccLookup,
  AccAccountTransaction.Exception,
  FinMoneyTransaction, FinMoneyTransaction.Service, ufrmFinMoneyTransaction,
  FinChequeNote, FinChequeNote.Service, ufrmFinChequeNote,
  FinPosTransaction, FinPosTransaction.Service, ufrmFinPosTransaction,
  FinCreditCardTransaction, FinCreditCardTransaction.Service, ufrmFinCreditCardTransaction,
  PurInvoice, PurInvoice.Service, ufrmPurInvoiceDetail,
  SlsInvoice, SlsInvoice.Service, ufrmSlsInvoiceDetail;

procedure TfrmAccAccountTransactions.SourceTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TAccLookup.Text(alkTxSource, Sender.AsInteger);
end;
procedure TfrmAccAccountTransactions.SetFixedAccount(AAccountId: Int64; const AAccountName: string);
begin
  FFixedMasterName := AAccountName;
  AddFixedFilter('acc_account_id', AAccountId);
end;

procedure TfrmAccAccountTransactions.OpenSourceDocument(ASourceType: Integer; ADocumentId: Int64);
var
  LFinMoneyTransactionSvc: TFinMoneyTransactionService;
  LFinMoneyTransaction: TFinMoneyTransaction;
  LFinChequeNoteSvc: TFinChequeNoteService;
  LFinChequeNote: TFinChequeNote;
  LFinPosTransactionSvc: TFinPosTransactionService;
  LFinPosTransaction: TFinPosTransaction;
  LFinCreditCardTransactionSvc: TFinCreditCardTransactionService;
  LFinCreditCardTransaction: TFinCreditCardTransaction;
  LPurInvoiceSvc: TPurInvoiceService;
  LPurInvoice: TPurInvoice;
  LSlsInvoiceSvc: TSlsInvoiceService;
  LSlsInvoice: TSlsInvoice;
begin
  case ASourceType of
    ACC_TX_SRC_MONEY:
      begin
        LFinMoneyTransactionSvc := TFinMoneyTransactionService.Create;
        try
          LFinMoneyTransaction := LFinMoneyTransactionSvc.BusinessFindById(ADocumentId, False, False, True);
          if not Assigned(LFinMoneyTransaction) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocumentId]));
        except
          LFinMoneyTransactionSvc.Free;
          raise;
        end;
        // form servisi ve kaydı sahiplenir; güncelleme / silme yetkileri formda ayrıca denetlenir
        TfrmFinMoneyTransaction.Create(Self, LFinMoneyTransactionSvc, LFinMoneyTransaction, ifmRewiev, Self.RefreshParentGrid, ivmNormal, True).Show;
      end;
    ACC_TX_SRC_CHEQUE_NOTE:
      begin
        LFinChequeNoteSvc := TFinChequeNoteService.Create;
        try
          LFinChequeNote := LFinChequeNoteSvc.BusinessFindById(ADocumentId, False, False, True);
          if not Assigned(LFinChequeNote) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocumentId]));
        except
          LFinChequeNoteSvc.Free;
          raise;
        end;
        // form servisi ve kaydı sahiplenir; güncelleme / silme yetkileri formda ayrıca denetlenir
        TfrmFinChequeNote.Create(Self, LFinChequeNoteSvc, LFinChequeNote, ifmRewiev, Self.RefreshParentGrid, ivmNormal, True).Show;
      end;
    ACC_TX_SRC_POS:
      begin
        LFinPosTransactionSvc := TFinPosTransactionService.Create;
        try
          LFinPosTransaction := LFinPosTransactionSvc.BusinessFindById(ADocumentId, False, False, True);
          if not Assigned(LFinPosTransaction) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocumentId]));
        except
          LFinPosTransactionSvc.Free;
          raise;
        end;
        // form servisi ve kaydı sahiplenir; güncelleme / silme yetkileri formda ayrıca denetlenir
        TfrmFinPosTransaction.Create(Self, LFinPosTransactionSvc, LFinPosTransaction, ifmRewiev, Self.RefreshParentGrid, ivmNormal, True).Show;
      end;
    ACC_TX_SRC_CREDIT_CARD:
      begin
        LFinCreditCardTransactionSvc := TFinCreditCardTransactionService.Create;
        try
          LFinCreditCardTransaction := LFinCreditCardTransactionSvc.BusinessFindById(ADocumentId, False, False, True);
          if not Assigned(LFinCreditCardTransaction) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocumentId]));
        except
          LFinCreditCardTransactionSvc.Free;
          raise;
        end;
        // form servisi ve kaydı sahiplenir; güncelleme / silme yetkileri formda ayrıca denetlenir
        TfrmFinCreditCardTransaction.Create(Self, LFinCreditCardTransactionSvc, LFinCreditCardTransaction, ifmRewiev, Self.RefreshParentGrid, ivmNormal, True).Show;
      end;
    ACC_TX_SRC_PUR_INVOICE:
      begin
        LPurInvoiceSvc := TPurInvoiceService.Create;
        try
          LPurInvoice := LPurInvoiceSvc.BusinessFindById(ADocumentId, False, False, True);
          if not Assigned(LPurInvoice) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocumentId]));
        except
          LPurInvoiceSvc.Free;
          raise;
        end;
        // form servisi ve kaydı sahiplenir; güncelleme / silme yetkileri formda ayrıca denetlenir
        TfrmPurInvoiceDetail.Create(Self, LPurInvoiceSvc, LPurInvoice, ifmRewiev, Self.RefreshParentGrid, ivmNormal, True).Show;
      end;
    ACC_TX_SRC_SLS_INVOICE:
      begin
        LSlsInvoiceSvc := TSlsInvoiceService.Create;
        try
          LSlsInvoice := LSlsInvoiceSvc.BusinessFindById(ADocumentId, False, False, True);
          if not Assigned(LSlsInvoice) then
            raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [ADocumentId]));
        except
          LSlsInvoiceSvc.Free;
          raise;
        end;
        TfrmSlsInvoiceDetail.Create(Self, LSlsInvoiceSvc, LSlsInvoice, ifmRewiev, Self.RefreshParentGrid, ivmNormal, True).Show;
      end;
  else
    raise EAccAccountTransactionExceptionUnknownSource.Create;
  end;
end;

procedure TfrmAccAccountTransactions.mniShowSourceClick(Sender: TObject);
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  OpenSourceDocument(Table.SourceType, Table.DocumentId);
end;

procedure TfrmAccAccountTransactions.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniShowSource := AddMenu(TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.MenuShowSource, 'Show Details'), 'mniShowSource', mniShowSourceClick);
end;

function TfrmAccAccountTransactions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  // Salt okunur liste: giriş formu yok
  Result := nil;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccAccountTransactions.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.AccountCode := FieldText('account_code');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmAccAccountTransactions.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('acc_account_id', 0);
  SetColumnProperty('source_id', 0);
  SetColumnProperty('document_id', 0);
  LField := Grd.DataSource.DataSet.FindField('source_type');
  if Assigned(LField) then
    LField.OnGetText := SourceTypeGetText;
end;

procedure TfrmAccAccountTransactions.FormShow(Sender: TObject);
begin
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmAccAccountTransactions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.TitlePlural, 'Account Transactions');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('transaction_date', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColTransactionDate, 'Date'));
  SetColumnTitle('source_type', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColSourceType, 'Source'));
  SetColumnTitle('document_no', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColDocumentNo, 'Document No'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColDescription, 'Description'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColCurrency, 'Currency'));
  SetColumnTitle('debit', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColDebit, 'Debit'));
  SetColumnTitle('credit', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColCredit, 'Credit'));
  SetColumnTitle('balance', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColBalance, 'Balance'));
  SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColAccountCode, 'Account Code'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.ColAccountName, 'Account'));
  if Assigned(FmniShowSource) then
    FmniShowSource.Caption := TLocalizationManager.Translate(TLangKeys.TAccAccountTransaction.MenuShowSource, 'Show Details');
end;

end.
