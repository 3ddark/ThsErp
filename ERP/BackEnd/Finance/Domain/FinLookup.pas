unit FinLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // fin_cheque_note.doc_kind
  FIN_DOC_CHEQUE = 1;   // çek
  FIN_DOC_NOTE   = 2;   // senet

  // fin_cheque_note.direction
  FIN_DIR_RECEIVED = 1; // alınan (müşteri çeki / senedi)
  FIN_DIR_GIVEN    = 2; // verilen (kendi çekimiz / borç senedimiz)

  // fin_cheque_note.status = fin_cheque_note_transaction.transaction_type (DB CHECK 1-9)
  FIN_STATUS_IN_PORTFOLIO       = 1;  // portföyde (alınan belgenin açılışı)
  FIN_STATUS_ENDORSED           = 2;  // cariye ciro edildi
  FIN_STATUS_AT_BANK_COLLECTION = 3;  // bankaya tahsile verildi
  FIN_STATUS_AT_BANK_COLLATERAL = 4;  // bankaya teminata verildi
  FIN_STATUS_COLLECTED          = 5;  // tahsil edildi
  FIN_STATUS_BOUNCED            = 6;  // karşılıksız / protestolu
  FIN_STATUS_RETURNED           = 7;  // iade edildi / iade alındı
  FIN_STATUS_PAID               = 8;  // ödendi (verilen belge)
  FIN_STATUS_ISSUED             = 9;  // verildi / tedavülde (verilen belgenin açılışı)

  // fin_credit_card_transaction.transaction_type (DB CHECK 1-3)
  FIN_CARD_TX_SPENDING = 1;
  FIN_CARD_TX_PAYMENT  = 2;
  FIN_CARD_TX_REFUND   = 3;

  // fin_pos_transaction.transaction_type (DB CHECK 1-2)
  FIN_POS_TX_COLLECTION = 1;
  FIN_POS_TX_REFUND     = 2;

  // fin_money_account.account_kind (DB CHECK 1-2)
  FIN_MONEY_CASH = 1;   // kasa
  FIN_MONEY_BANK = 2;   // banka hesabı

  // fin_money_transaction.transaction_type (DB CHECK 1-7)
  FIN_MONEY_TX_COLLECTION = 1;  // tahsilat: cariden giriş (nakit / gelen havale-EFT)
  FIN_MONEY_TX_PAYMENT    = 2;  // ödeme: cariye çıkış (nakit / giden havale-EFT)
  FIN_MONEY_TX_TRANSFER   = 3;  // virman: kaynaktan çıkış, hedefe giriş
  FIN_MONEY_TX_EXPENSE    = 4;  // masraf / komisyon (çıkış)
  FIN_MONEY_TX_INTEREST   = 5;  // faiz geliri (giriş)
  FIN_MONEY_TX_OTHER_IN   = 6;
  FIN_MONEY_TX_OTHER_OUT  = 7;

  // fin_money_transaction.transfer_method (DB CHECK 1-5, NULL = belirtilmemiş)
  FIN_METHOD_CASH  = 1;
  FIN_METHOD_WIRE  = 2;  // havale
  FIN_METHOD_EFT   = 3;
  FIN_METHOD_FAST  = 4;
  FIN_METHOD_SWIFT = 5;

  // firma banka hesabı kullanım yeri (TFinCompanyBankAccountService.GetPrintLines)
  FIN_BANK_USAGE_CHEQUE = 1;
  FIN_BANK_USAGE_NOTE   = 2;
  FIN_BANK_USAGE_PRINT  = 3;

  // vw_fin_money_ledger.direction
  FIN_DIR_IN  = 1;
  FIN_DIR_OUT = 2;

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TFinLookupKind = (flkDocKind, flkDirection, flkChequeStatus, flkCardTxType, flkPosTxType,
                    flkMoneyAccountKind, flkMoneyTxType, flkTransferMethod, flkMoneyDirection);

  TFinLookup = class
  public
    class function Items(AKind: TFinLookupKind): TArray<string>;
    class function Text(AKind: TFinLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TFinLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TFinLookupKind);

    // Belgenin ilk durumu: alınan -> portföyde, verilen -> verildi
    class function InitialStatus(ADirection: Integer): SmallInt;
    // AFrom = 0: henüz hareket yok (yalnız açılış durumu)
    class function CanTransit(ADirection, AFrom, ATo: Integer): Boolean;
    class function PortfolioPrefix(ADocKind, ADirection: Integer): string;
    class function ChequeNoteListTitle(ADocKind, ADirection: Integer): string;
    // Boş ya da 4 rakam
    class function IsValidLastDigits(const AValue: string): Boolean;
    // Para hareketi kaynak hesaba giriş mi (virman kaynakta çıkıştır)
    class function IsIncomingMoneyTx(ATransactionType: Integer): Boolean;
    // Boşlukları atar, büyük harfe çevirir
    class function NormalizeIban(const AValue: string): string;
    // Boş ya da ISO 13616 (ülke kodu + kontrol hanesi, mod 97 = 1); TR için 26 karakter
    class function IsValidIban(const AValue: string): Boolean;
  end;

implementation

class function TFinLookup.Items(AKind: TFinLookupKind): TArray<string>;
begin
  case AKind of
    flkDocKind:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinOption.DocCheque, 'Cheque'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.DocNote, 'Promissory Note')];
    flkDirection:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinOption.DirReceived, 'Received (Customer)'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.DirGiven, 'Issued (Own)')];
    flkChequeStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinOption.StatusInPortfolio, 'In Portfolio'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusEndorsed, 'Endorsed'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusAtBankCollection, 'Sent for Collection'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusAtBankCollateral, 'Given as Collateral'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusCollected, 'Collected'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusBounced, 'Bounced / Protested'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusReturned, 'Returned'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusPaid, 'Paid'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.StatusIssued, 'Issued')];
    flkCardTxType:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinOption.CardTxSpending, 'Spending'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.CardTxPayment, 'Payment'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.CardTxRefund, 'Refund')];
    flkPosTxType:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinOption.PosTxCollection, 'Collection'),
                 TLocalizationManager.Translate(TLangKeys.TFinOption.PosTxRefund, 'Refund')];
    flkMoneyAccountKind:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.KindCash, 'Cash'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.KindBank, 'Bank Account')];
    flkMoneyTxType:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxCollection, 'Collection (from account)'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxPayment, 'Payment (to account)'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxTransfer, 'Transfer'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxExpense, 'Expense / Commission'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxInterest, 'Interest Income'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxOtherIn, 'Other Income'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.TxOtherOut, 'Other Expense')];
    flkTransferMethod:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.MethodCash, 'Cash'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.MethodWire, 'Wire Transfer'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.MethodEft, 'EFT'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.MethodFast, 'FAST'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.MethodSwift, 'SWIFT')];
    flkMoneyDirection:
      Result := [TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.DirIn, 'In'),
                 TLocalizationManager.Translate(TLangKeys.TFinMoneyOption.DirOut, 'Out')];
  else
    Result := [];
  end;
end;

class function TFinLookup.Text(AKind: TFinLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TFinLookup.IsValid(AKind: TFinLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TFinLookup.FillItems(AItems: TStrings; AKind: TFinLookupKind);
var
  LText: string;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    for LText in Items(AKind) do
      AItems.Add(LText);
  finally
    AItems.EndUpdate;
  end;
end;

class function TFinLookup.InitialStatus(ADirection: Integer): SmallInt;
begin
  if ADirection = FIN_DIR_GIVEN then
    Result := FIN_STATUS_ISSUED
  else
    Result := FIN_STATUS_IN_PORTFOLIO;
end;

class function TFinLookup.CanTransit(ADirection, AFrom, ATo: Integer): Boolean;
begin
  if AFrom = 0 then
    Exit(ATo = InitialStatus(ADirection));

  if ADirection = FIN_DIR_GIVEN then
  begin
    case AFrom of
      FIN_STATUS_ISSUED:  Result := ATo in [FIN_STATUS_PAID, FIN_STATUS_BOUNCED, FIN_STATUS_RETURNED];
      FIN_STATUS_BOUNCED: Result := ATo in [FIN_STATUS_PAID, FIN_STATUS_RETURNED];
    else
      Result := False;  // ödendi / iade alındı: kapanmış belge
    end;
  end
  else
  begin
    case AFrom of
      FIN_STATUS_IN_PORTFOLIO:
        Result := ATo in [FIN_STATUS_ENDORSED, FIN_STATUS_AT_BANK_COLLECTION, FIN_STATUS_AT_BANK_COLLATERAL,
                          FIN_STATUS_COLLECTED, FIN_STATUS_BOUNCED, FIN_STATUS_RETURNED];
      // cirodan geri dönüş (portföye) veya karşılıksız çıkması
      FIN_STATUS_ENDORSED:
        Result := ATo in [FIN_STATUS_IN_PORTFOLIO, FIN_STATUS_BOUNCED];
      // bankadan: tahsil / karşılıksız / portföye geri
      FIN_STATUS_AT_BANK_COLLECTION, FIN_STATUS_AT_BANK_COLLATERAL:
        Result := ATo in [FIN_STATUS_IN_PORTFOLIO, FIN_STATUS_COLLECTED, FIN_STATUS_BOUNCED];
      // karşılıksız: sonradan tahsil, müşteriye iade veya yeniden portföy
      FIN_STATUS_BOUNCED:
        Result := ATo in [FIN_STATUS_IN_PORTFOLIO, FIN_STATUS_COLLECTED, FIN_STATUS_RETURNED];
    else
      Result := False;  // tahsil edildi / iade edildi: kapanmış belge
    end;
  end;
end;

class function TFinLookup.PortfolioPrefix(ADocKind, ADirection: Integer): string;
begin
  if ADocKind = FIN_DOC_NOTE then
  begin
    if ADirection = FIN_DIR_GIVEN then
      Result := 'BS'    // borç senedi
    else
      Result := 'MS';   // müşteri senedi
  end
  else
  begin
    if ADirection = FIN_DIR_GIVEN then
      Result := 'KC'    // kendi çekimiz
    else
      Result := 'MC';   // müşteri çeki
  end;
end;

class function TFinLookup.ChequeNoteListTitle(ADocKind, ADirection: Integer): string;
begin
  if ADocKind = FIN_DOC_NOTE then
  begin
    if ADirection = FIN_DIR_GIVEN then
      Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitleDebitNotes, 'Debit Promissory Notes')
    else
      Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitleCustomerNotes, 'Customer Promissory Notes');
  end
  else
  begin
    if ADirection = FIN_DIR_GIVEN then
      Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitleOwnCheques, 'Own Cheques')
    else
      Result := TLocalizationManager.Translate(TLangKeys.TFinChequeNote.TitleCustomerCheques, 'Customer Cheques');
  end;
end;

class function TFinLookup.IsValidLastDigits(const AValue: string): Boolean;
var
  LChar: Char;
begin
  if AValue = '' then
    Exit(True);
  if Length(AValue) <> 4 then
    Exit(False);
  for LChar in AValue do
    if not CharInSet(LChar, ['0'..'9']) then
      Exit(False);
  Result := True;
end;

class function TFinLookup.IsIncomingMoneyTx(ATransactionType: Integer): Boolean;
begin
  Result := ATransactionType in [FIN_MONEY_TX_COLLECTION, FIN_MONEY_TX_INTEREST, FIN_MONEY_TX_OTHER_IN];
end;

class function TFinLookup.NormalizeIban(const AValue: string): string;
begin
  Result := UpperCase(StringReplace(Trim(AValue), ' ', '', [rfReplaceAll]));
end;

class function TFinLookup.IsValidIban(const AValue: string): Boolean;
var
  LIban, LDigits: string;
  LChar: Char;
  I, LRemainder: Integer;
begin
  LIban := NormalizeIban(AValue);
  if LIban = '' then
    Exit(True);
  if (Length(LIban) < 15) or (Length(LIban) > 34) then
    Exit(False);
  if (Copy(LIban, 1, 2) = 'TR') and (Length(LIban) <> 26) then
    Exit(False);
  for I := 1 to Length(LIban) do
  begin
    LChar := LIban[I];
    if (I <= 2) and not CharInSet(LChar, ['A'..'Z']) then
      Exit(False);
    if (I in [3, 4]) and not CharInSet(LChar, ['0'..'9']) then
      Exit(False);
    if not CharInSet(LChar, ['A'..'Z', '0'..'9']) then
      Exit(False);
  end;

  // ilk 4 karakter sona alınır, harfler 10..35 olur, mod 97 = 1
  LIban := Copy(LIban, 5, MaxInt) + Copy(LIban, 1, 4);
  LDigits := '';
  for LChar in LIban do
    if CharInSet(LChar, ['A'..'Z']) then
      LDigits := LDigits + IntToStr(Ord(LChar) - Ord('A') + 10)
    else
      LDigits := LDigits + LChar;

  LRemainder := 0;
  for LChar in LDigits do
    LRemainder := (LRemainder * 10 + Ord(LChar) - Ord('0')) mod 97;
  Result := LRemainder = 1;
end;

end.
