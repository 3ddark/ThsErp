unit ItModules;

interface

procedure RunModuleTests;

implementation

uses
  System.SysUtils, System.StrUtils, System.Math, System.DateUtils, System.Classes, System.Rtti, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, SharedFormTypes, FilterCriterion,
  UnitOfWork, AppContext, ItSpecific, SysDecimalPlace.Cache,
  StkLookup, StkTransaction, StkTransaction.Service, StkInventory, StkInventory.Service,
  StkCardKindInfo, StkCardKindInfo.Service,
  AccAccount, AccAccount.Service, AccAccountAddress, AccAccountAddress.Service,
  AccTransferCode, AccTransferCode.Service,
  SysAddress, SysAddress.Service, SysUser, SysUser.Service, SysUser.Repository,
  SysAccessRight, SysAccessRight.Service, SysUserPermissionTemplate, SysUserPermissionTemplate.Service,
  SysGridFilter, SysGridFilter.Service,
  EmpEmployee, EmpEmployee.Service, EmpPersonAddress, EmpPersonAddress.Service,
  EmpTransportation, EmpTransportation.Service, Password.Helper, Auth.Service, Db.ErrorTranslator, LocalizationManager,
  FinLookup, FinChequeNote, FinChequeNote.Service, FinChequeNoteTransaction, FinChequeNoteTransaction.Service,
  FinCreditCard, FinCreditCard.Service, FinCreditCardTransaction, FinCreditCardTransaction.Service,
  FinPosTerminal, FinPosTerminal.Service, FinPosTransaction, FinPosTransaction.Service,
  FinMoneyAccount, FinMoneyAccount.Service, FinMoneyTransaction, FinMoneyTransaction.Service,
  FinMoneyLedger, FinMoneyLedger.Service, FinCompanyBankAccount, FinCompanyBankAccount.Service,
  PurLookup, PurRequest, PurRequest.Service, PurRequestDetail, PurRequestDetail.Service,
  PurOrder, PurOrder.Service, PurOrderDetail, PurOrderDetail.Service,
  PurReceipt, PurReceipt.Service, PurReceiptDetail, PurReceiptDetail.Service,
  PurInvoice, PurInvoice.Service, PurInvoiceDetail, PurInvoiceDetail.Service,
  PurQuotation, PurQuotation.Service, PurQuotationDetail,
  QcLookup, QcSetting, QcSetting.Service, QcRule, QcRule.Service, QcInspection, QcInspection.Service,
  SlsLookup, SlsOffer, SlsOffer.Service, SlsOfferDetail, SlsOfferDetail.Service,
  AccExchangeRate, AccExchangeRate.Service, Tcmb.ExchangeRates,
  SlsOrder, SlsOrder.Service, SlsOrderDetail, SlsOrderDetail.Service,
  SlsDispatch, SlsDispatch.Service, SlsDispatchDetail, SlsDispatchDetail.Service,
  SlsInvoice, SlsInvoice.Repository, SlsInvoice.Service, SlsInvoiceDetail, SlsInvoiceDetail.Service,
  EInvDocument, EInvDocument.Service, EInvSeries, EInvSeries.Repository,
  AccLookup, AccAccountTransaction, AccAccountTransaction.Service,
  SysDashboard, SysDashboard.Service,
  EInvLookup, EInvGtip, EInvGtip.Service, EInvWithholding, EInvWithholding.Service,
  EInvDiib, EInvDiib.Service, EInvDiibLine, EInvDiibLine.Service,
  AccVoucher, AccVoucher.Service, AccVoucherDetail,
  PrdBom, PrdBom.Service, PrdBomRaw, PrdBomLabour, PrdBomByProduct, PrdPacketRaw, PrdPacketRaw.Service, PrdPacketRawDetail,
  EInvVehicle, EInvVehicle.Service, EInvDriver, EInvDriver.Service,
  ApiService.Config, SysApiService, SysApiService.Service, SysApiService.ConfigSource,
  EInvDocumentSetting, EInvDocumentSetting.Service, EInvIntegrator, EInvIntegrator.ELogo;

var
  GMod, GEnt: string;

function UoW: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

procedure Ctx(const AMod, AEnt: string);
begin
  GMod := AMod;
  GEnt := AEnt;
end;

procedure Check(const AStep: string; ACond: Boolean; const AMsg: string = '');
begin
  if ACond then Report('PASS', GMod, GEnt, AStep, AMsg)
  else Report('FAIL', GMod, GEnt, AStep, AMsg);
end;

procedure Expect(const AStep: string; AProc: TProc);
begin
  // servisler hata durumunda transaction'ı geri alır; çağıran sonrasında Begin_ ile yeniden başlar
  try
    AProc();
    Report('FAIL', GMod, GEnt, AStep, 'expected error, none raised');
  except
    on E: Exception do
      Report('PASS', GMod, GEnt, AStep, 'rejected: ' + E.Message);
  end;
end;

function Scalar(const ASql: string): Variant; overload;
begin
  Result := UoW.Connection.ExecSQLScalar(ASql);
end;

function Scalar(const ASql: string; const AParams: array of Variant): Variant; overload;
begin
  Result := UoW.Connection.ExecSQLScalar(ASql, AParams);
end;

function S(const V: Variant): string;
begin
  if VarIsNull(V) or VarIsEmpty(V) then Result := '<null>' else Result := VarToStr(V);
end;

function Num(const V: Variant): Double;
begin
  if VarIsNull(V) or VarIsEmpty(V) then Result := -999999 else Result := V;
end;

function Near(A, B: Double): Boolean;
begin
  Result := Abs(A - B) < 0.00001;
end;

procedure Begin_;
begin
  if UoW.InTransaction then UoW.Rollback;
  UoW.BeginTransaction;
end;

procedure End_;
begin
  if UoW.InTransaction then UoW.Rollback;
end;

{ ---------------------------------------------------------------- Stock }

function NewTx(AType: SmallInt; AInv, AFrom, ATo: Int64; AQty, AAmount: Currency; AOpening: Boolean = False): TStkTransaction;
begin
  Result := TStkTransaction.Create;
  Result.TransactionDate := Date;
  Result.TransactionType := AType;
  Result.StkInventoryId := AInv;
  Result.FromStkWarehouseId := AFrom;
  Result.ToStkWarehouseId := ATo;
  Result.Quantity := AQty;
  Result.Amount := AAmount;
  Result.IsOpening := AOpening;
end;

procedure CheckSummary(const AStep: string; AInv: Int64; AQty, AAvg: Double);
var
  Q, A: Variant;
begin
  Q := Scalar('SELECT current_quantity FROM stk_inventory_summary WHERE stk_inventory_id = ' + AInv.ToString);
  A := Scalar('SELECT average_cost FROM stk_inventory_summary WHERE stk_inventory_id = ' + AInv.ToString);
  Check(AStep, Near(Num(Q), AQty) and Near(Num(A), AAvg),
    Format('qty %s (exp %g), avg %s (exp %g)', [S(Q), AQty, S(A), AAvg]));
end;

procedure TestStockTransactions;
var
  Svc: TStkTransactionService;
  T1, T2, T3, T4, T5, X: TStkTransaction;
  Inv, Inv2, W1, W2: Int64;
begin
  Ctx('Stock', 'TStkTransaction');
  Inv := Scalar('SELECT min(id) FROM stk_inventory');
  Inv2 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv.ToString);
  W1 := Scalar('SELECT min(id) FROM stk_warehouse');
  W2 := Scalar('SELECT max(id) FROM stk_warehouse');
  Svc := TStkTransactionService.Create;
  T1 := nil; T2 := nil; T3 := nil; T4 := nil; T5 := nil;
  try
    Begin_;
    try
      T1 := NewTx(STK_TRANSACTION_IN, Inv, 0, W1, 10, 100, True);
      Svc.BusinessInsert(T1, False, False, True);
      CheckSummary('opening in 10 x 10', Inv, 10, 10);
      Check('opening price', Near(Num(Scalar('SELECT opening_price FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv.ToString)), 10));

      T2 := NewTx(STK_TRANSACTION_IN, Inv, 0, W1, 5, 75);
      T2.AmountForeign := 2.5;
      T2.Currency := 'USD';
      Svc.BusinessInsert(T2, False, False, True);
      CheckSummary('in 5 x 15', Inv, 15, 175 / 15);
      Check('last buy price/rate',
        Near(Num(Scalar('SELECT last_buy_price FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv.ToString)), 15) and
        Near(Num(Scalar('SELECT last_buy_exchange_rate FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv.ToString)), 30),
        S(Scalar('SELECT last_buy_price::text || '' / '' || last_buy_exchange_rate::text || '' / '' || coalesce(last_buy_currency, ''-'') FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv.ToString)));

      T3 := NewTx(STK_TRANSACTION_OUT, Inv, W1, W2, 3, 0);
      Svc.BusinessInsert(T3, False, False, True);
      CheckSummary('out 3', Inv, 12, 175 / 15);
      Check('out clears target warehouse', VarIsNull(Scalar('SELECT to_stk_warehouse_id FROM stk_transaction WHERE id = ' + T3.Id.ToString)));

      T4 := NewTx(STK_TRANSACTION_TRANSFER, Inv, W1, W2, 2, 0);
      Svc.BusinessInsert(T4, False, False, True);
      CheckSummary('transfer keeps total', Inv, 12, 175 / 15);
      Check('warehouse stock (source)',
        Near(Num(Scalar('SELECT quantity FROM vw_stk_inventory_warehouse WHERE stk_inventory_id = :i AND stk_warehouse_id = :w', [Inv, W1])), 10),
        S(Scalar('SELECT quantity FROM vw_stk_inventory_warehouse WHERE stk_inventory_id = :i AND stk_warehouse_id = :w', [Inv, W1])));
      Check('warehouse stock (target)',
        Near(Num(Scalar('SELECT quantity FROM vw_stk_inventory_warehouse WHERE stk_inventory_id = :i AND stk_warehouse_id = :w', [Inv, W2])), 2),
        S(Scalar('SELECT quantity FROM vw_stk_inventory_warehouse WHERE stk_inventory_id = :i AND stk_warehouse_id = :w', [Inv, W2])));

      // ondalık hassasiyet (money ile 2 haneye yuvarlanıyordu)
      T5 := NewTx(STK_TRANSACTION_IN, Inv, 0, W1, 0.125, 1.2345);
      Svc.BusinessInsert(T5, False, False, True);
      Check('decimal quantity 0.125', Near(Num(Scalar('SELECT quantity FROM stk_transaction WHERE id = ' + T5.Id.ToString)), 0.125),
        S(Scalar('SELECT quantity::text || '' / '' || amount::text FROM stk_transaction WHERE id = ' + T5.Id.ToString)));
      Check('decimal amount 1.2345', Near(Num(Scalar('SELECT amount FROM stk_transaction WHERE id = ' + T5.Id.ToString)), 1.2345));
      CheckSummary('in 0.125', Inv, 12.125, (175 + 1.2345) / 15.125);

      Check('view current_quantity = summary',
        S(Scalar('SELECT current_quantity::text FROM vw_stk_inventory WHERE id = ' + Inv.ToString)) =
        S(Scalar('SELECT current_quantity::text FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv.ToString)),
        S(Scalar('SELECT current_quantity::text FROM vw_stk_inventory WHERE id = ' + Inv.ToString)));

      // update: çıkış miktarı 3 -> 4
      X := Svc.BusinessFindById(T3.Id, False, True, True);
      try
        X.Quantity := 4;
        Svc.BusinessUpdate(X, False, False, True);
      finally
        X.Free;
      end;
      CheckSummary('update out 3 -> 4', Inv, 11.125, (175 + 1.2345) / 15.125);

      // update: girişi başka stoğa taşı -> iki özet de yenilenir
      X := Svc.BusinessFindById(T2.Id, False, True, True);
      try
        X.StkInventoryId := Inv2;
        Svc.BusinessUpdate(X, False, False, True);
      finally
        X.Free;
      end;
      CheckSummary('move in to other card (old)', Inv, 6.125, (100 + 1.2345) / 10.125);
      CheckSummary('move in to other card (new)', Inv2, 5 + Num(Scalar('SELECT COALESCE(sum(CASE transaction_type WHEN 1 THEN quantity WHEN 2 THEN -quantity ELSE 0 END),0) FROM stk_transaction WHERE stk_inventory_id = :i AND id <> :t', [Inv2, T2.Id])),
        Num(Scalar('SELECT average_cost FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv2.ToString)));

      // delete opening
      X := Svc.FindById(T1.Id, False);
      try
        Svc.BusinessDelete(X, False, False, True);
      finally
        X.Free;
      end;
      CheckSummary('delete opening', Inv, -3.875, 1.2345 / 0.125);
      Check('opening cleared', Near(Num(Scalar('SELECT opening_quantity FROM stk_inventory_summary WHERE stk_inventory_id = ' + Inv.ToString)), 0));
    except
      on E: Exception do Report('FAIL', GMod, GEnt, 'flow', E.ClassName + ': ' + E.Message);
    end;
    End_;

    // kural ihlalleri
    Begin_;
    Expect('quantity 0', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_IN, Inv, 0, W1, 0, 0);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('negative amount', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_IN, Inv, 0, W1, 1, -5);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('out without source', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_OUT, Inv, 0, W1, 1, 0);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('in without target', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_IN, Inv, W1, 0, 1, 0);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('transfer same warehouse', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_TRANSFER, Inv, W1, W1, 1, 0);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('opening as out', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_OUT, Inv, W1, 0, 1, 0, True);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('invalid type 9', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(9, Inv, W1, W2, 1, 0);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    Begin_;
    Expect('missing inventory', procedure
      var T: TStkTransaction;
      begin
        T := NewTx(STK_TRANSACTION_IN, 0, 0, W1, 1, 0);
        try Svc.BusinessInsert(T, False, False, True); finally T.Free; end;
      end);
    End_;
  finally
    End_;
    T1.Free; T2.Free; T3.Free; T4.Free; T5.Free;
    Svc.Free;
  end;
end;

procedure TestStockInventory;
var
  Svc: TStkInventoryService;
  E: TStkInventory;
  Id: Int64;
  LAcc: string;
begin
  Ctx('Stock', 'TStkInventory');
  Id := Scalar('SELECT min(id) FROM stk_inventory');
  LAcc := Scalar('SELECT min(code) FROM acc_account');
  Svc := TStkInventoryService.Create;
  try
    try
      Begin_;
      E := Svc.BusinessFindById(Id, False, True, True);
      try
        E.HasVatRate := False;
        Svc.BusinessUpdate(E, False, False, True);
        Check('empty VAT stays NULL', VarIsNull(Scalar('SELECT vat_rate FROM stk_inventory WHERE id = ' + Id.ToString)),
          S(Scalar('SELECT vat_rate FROM stk_inventory WHERE id = ' + Id.ToString)));
        Check('empty VAT -> group VAT in account view',
          S(Scalar('SELECT vat_rate::text FROM vw_stk_inventory_account WHERE id = ' + Id.ToString)) =
          S(Scalar('SELECT g.vat_rate::text FROM stk_inventory i JOIN stk_group g ON g.id = i.stk_group_id WHERE i.id = ' + Id.ToString)),
          S(Scalar('SELECT vat_rate::text FROM vw_stk_inventory_account WHERE id = ' + Id.ToString)));

        // Karta özel KDV yalnız tanımlı oranlardan (acc_set_tax_rate): en büyük tanımlı oran
        E.HasVatRate := True;
        E.VatRate := Num(Scalar('SELECT max(tax_rate) FROM acc_set_tax_rate'));
        Svc.BusinessUpdate(E, False, False, True);
        Check('defined VAT saved', S(Scalar('SELECT vat_rate::text FROM stk_inventory WHERE id = ' + Id.ToString)) =
          S(Scalar('SELECT max(tax_rate)::text FROM acc_set_tax_rate')),
          S(Scalar('SELECT vat_rate::text FROM stk_inventory WHERE id = ' + Id.ToString)));

        E.SalesAccount := ' ' + LAcc + ' ';
        Svc.BusinessUpdate(E, False, False, True);
        Check('override account saved (trimmed)', S(Scalar('SELECT sales_account FROM stk_inventory WHERE id = ' + Id.ToString)) = LAcc,
          S(Scalar('SELECT sales_account FROM stk_inventory WHERE id = ' + Id.ToString)));
        Check('resolved account uses override', S(Scalar('SELECT sales_account FROM vw_stk_inventory_account WHERE id = ' + Id.ToString)) = LAcc);

        E.BuyingPrice := 12.3456;
        Svc.BusinessUpdate(E, False, False, True);
        Check('buying price 4 decimals', Near(Num(Scalar('SELECT buying_price FROM stk_inventory WHERE id = ' + Id.ToString)), 12.3456),
          S(Scalar('SELECT buying_price FROM stk_inventory WHERE id = ' + Id.ToString)));
      finally
        E.Free;
      end;
      End_;

      Begin_;
      Expect('unknown override account', procedure
        var X: TStkInventory;
        begin
          X := Svc.FindById(Id, False);
          try
            X.SalesAccount := 'NO-SUCH-ACC';
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('undefined VAT 7.5', procedure
        var X: TStkInventory;
        begin
          X := Svc.FindById(Id, False);
          try
            X.HasVatRate := True;
            X.VatRate := 7.5;
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('VAT 101', procedure
        var X: TStkInventory;
        begin
          X := Svc.FindById(Id, False);
          try
            X.HasVatRate := True;
            X.VatRate := 101;
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('missing group', procedure
        var X: TStkInventory;
        begin
          X := Svc.FindById(Id, False);
          try
            X.Id := 0;
            X.Code := 'IT-NEW-1';
            X.StkGroupId := 0;
            Svc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);

      // yeni kart + resim
      Begin_;
      E := Svc.FindById(Id, False);
      try
        E.Id := 0;
        E.Code := 'IT-NEW-2';
        E.Name := 'IT YENİ KART ₺';
        E.Image := TBytes.Create($89, $50, $4E, $47);
        Svc.BusinessInsert(E, False, False, True);
        Check('insert new card', E.Id > 0);
        Check('unicode name', S(Scalar('SELECT name FROM stk_inventory WHERE id = ' + E.Id.ToString)) = 'IT YENİ KART ₺',
          S(Scalar('SELECT name FROM stk_inventory WHERE id = ' + E.Id.ToString)));
        Check('image saved', Num(Scalar('SELECT count(*) FROM stk_image WHERE stk_inventory_id = ' + E.Id.ToString)) = 1);
        Svc.BusinessDelete(E, False, False, True);
        Check('delete cascades image', Num(Scalar('SELECT count(*) FROM stk_image WHERE stk_inventory_id = ' + E.Id.ToString)) = 0);
      finally
        E.Free;
      end;
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    Svc.Free;
  end;
end;

procedure TestStockKindInfo;
var
  Svc: TStkCardKindInfoService;
  E, R: TStkCardKindInfo;
begin
  Ctx('Stock', 'TStkCardKindInfo');
  Svc := TStkCardKindInfoService.Create;
  E := TStkCardKindInfo.Create;
  try
    try
      Begin_;
      E.StkInventoryId := Scalar('SELECT min(id) FROM stk_inventory');
      E.StkKindPropertyId := Scalar('SELECT min(id) FROM stk_kind_property');
      E.S1 := 'IT ş ₺';
      E.I1 := 42;
      E.D1 := 1.5;
      Svc.BusinessInsert(E, False, False, True);
      Check('insert', E.Id > 0);
      R := Svc.FindById(E.Id, False);
      try
        Check('roundtrip', Assigned(R) and (R.S1 = 'IT ş ₺') and (R.I1 = 42) and Near(R.D1, 1.5),
          IfThen(Assigned(R), R.S1, 'nil'));
        R.S2 := 'two';
        Svc.BusinessUpdate(R, False, False, True);
        Svc.BusinessDelete(R, False, False, True);
        Check('delete', Num(Scalar('SELECT count(*) FROM stk_card_kind_info WHERE id = ' + E.Id.ToString)) = 0);
      finally
        R.Free;
      end;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    E.Free;
    Svc.Free;
  end;
end;

{ -------------------------------------------------------------- Account }

procedure TestAccount;
var
  Svc: TAccAccountService;
  ASvc: TAccAccountAddressService;
  AdSvc: TSysAddressService;
  E: TAccAccount;
  Ad: TSysAddress;
  AA: TAccAccountAddress;
  Base: Int64;
begin
  Ctx('Account', 'TAccAccount');
  Base := Scalar('SELECT min(id) FROM acc_account WHERE code LIKE ''___-%''');
  Svc := TAccAccountService.Create;
  ASvc := TAccAccountAddressService.Create;
  AdSvc := TSysAddressService.Create;
  try
    try
      Begin_;
      E := Svc.FindById(Base, False);
      try
        E.Id := 0;
        E.Code := ' ' + Copy(E.Code, 1, 7) + '-077 ';
        E.Name := 'it deneme hesabı';
        Svc.BusinessInsert(E, False, False, True);
        Check('insert', E.Id > 0, E.Code);
        Check('root_code', S(Scalar('SELECT root_code FROM acc_account WHERE id = ' + E.Id.ToString)) = Copy(Trim(E.Code), 1, 3),
          S(Scalar('SELECT root_code FROM acc_account WHERE id = ' + E.Id.ToString)));
        Check('sub_code', S(Scalar('SELECT sub_code FROM acc_account WHERE id = ' + E.Id.ToString)) = Copy(E.Code, 1, 7),
          S(Scalar('SELECT sub_code FROM acc_account WHERE id = ' + E.Id.ToString)));
        Check('name upper (tr)', S(Scalar('SELECT name FROM acc_account WHERE id = ' + E.Id.ToString)) = 'İT DENEME HESABI',
          S(Scalar('SELECT name FROM acc_account WHERE id = ' + E.Id.ToString)));
        Check('code trimmed', S(Scalar('SELECT code FROM acc_account WHERE id = ' + E.Id.ToString)) = Trim(E.Code));

        // adres
        Ad := TSysAddress.Create;
        try
          Ad.SysCityId := Scalar('SELECT min(id) FROM sys_city');
          Ad.District := 'IT İlçe';
          Ad.Street := 'IT Sokak';
          AdSvc.BusinessInsert(Ad, False, False, True);
          Check('address insert', Ad.Id > 0);
          AA := TAccAccountAddress.Create;
          try
            AA.AccAccountId := E.Id;
            AA.SysAddressId := Ad.Id;
            AA.AddressType := 'BILLING';
            AA.IsPrimary := True;
            ASvc.BusinessInsert(AA, False, False, True);
            Check('account address insert', AA.Id > 0);
            Check('account address view', Num(Scalar('SELECT count(*) FROM vw_acc_account_address WHERE acc_account_id = ' + E.Id.ToString)) >= 1);
            AA.AddressType := 'SHIPPING';
            ASvc.BusinessUpdate(AA, False, False, True);
            Check('account address update', S(Scalar('SELECT address_type FROM acc_account_address WHERE id = ' + AA.Id.ToString)) = 'SHIPPING');
          finally
            AA.Free;
          end;
        finally
          Ad.Free;
        end;

        Svc.BusinessDelete(E, False, False, True);
        Check('delete account', Num(Scalar('SELECT count(*) FROM acc_account WHERE id = ' + E.Id.ToString)) = 0);
      finally
        E.Free;
      end;
      End_;

      Begin_;
      Expect('discount 150', procedure
        var X: TAccAccount;
        begin
          X := Svc.FindById(Base, False);
          try
            X.DiscountRate := 150;
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('duplicate code', procedure
        var X: TAccAccount;
        begin
          X := Svc.FindById(Base, False);
          try
            X.Id := 0;
            X.Name := 'IT DUP';
            Svc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('invalid address type', procedure
        var X: TAccAccountAddress;
        begin
          X := TAccAccountAddress.Create;
          try
            X.AccAccountId := Base;
            X.SysAddressId := Scalar('SELECT min(id) FROM sys_address');
            X.AddressType := 'XYZ';
            ASvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    AdSvc.Free;
    ASvc.Free;
    Svc.Free;
  end;
end;

function Card(AEntity: TAccAccount; const AType: string): TAccAccountCardAddress;
var
  LItem: TAccAccountCardAddress;
begin
  Result := nil;
  for LItem in AEntity.Addresses do
    if LItem.AddressType = AType then
      Exit(LItem);
end;

// Cari kartındaki adres sekmeleri: hesapla aynı transaction, yalnız değişen adres yazılır
procedure TestAccountCardAddresses;
var
  Svc: TAccAccountService;
  ASvc: TAccAccountAddressService;
  E, L: TAccAccount;
  AA: TAccAccountAddress;
  Base, City, BillSys, ShipSys, ShipLink, BillLink: Int64;
  BillCtid, ShipCtid: string;

  function Ctid(ASysAddressId: Int64): string;
  begin
    Result := S(Scalar('SELECT ctid::text FROM sys_address WHERE id = ' + ASysAddressId.ToString));
  end;

  function LinkCount(AAccountId: Int64): Integer;
  begin
    Result := Round(Num(Scalar('SELECT count(*) FROM acc_account_address WHERE acc_account_id = ' + AAccountId.ToString)));
  end;

begin
  Ctx('Account', 'TAccAccount.Addresses');
  Base := Scalar('SELECT min(id) FROM acc_account WHERE code LIKE ''___-%''');
  City := Scalar('SELECT min(id) FROM sys_city');
  Svc := TAccAccountService.Create;
  ASvc := TAccAccountAddressService.Create;
  try
    try
      Begin_;
      E := Svc.FindById(Base, False);
      try
        Check('list entity has no addresses', not E.AddressesAssigned);
        E.Id := 0;
        E.Code := Copy(E.Code, 1, 7) + '-078';
        E.Name := 'IT ADRES HESABI';
        E.AddressesAssigned := True;
        with Card(E, ACC_ADDRESS_BILLING).Address do
        begin
          SysCityId := City;
          District := ' IT İlçe ';
          Street := 'IT Fatura Sokak';
          Email := 'fatura@it.test';
          Web := 'www.it.test';
        end;
        with Card(E, ACC_ADDRESS_SHIPPING).Address do
        begin
          SysCityId := City;
          Street := 'IT Sevk Sokak';
        end;
        Svc.BusinessInsert(E, False, False, True);
        Check('insert account + addresses', E.Id > 0);
        Check('two links', LinkCount(E.Id) = 2, IntToStr(LinkCount(E.Id)));
        BillLink := Card(E, ACC_ADDRESS_BILLING).LinkId;
        BillSys := Card(E, ACC_ADDRESS_BILLING).Address.Id;
        ShipLink := Card(E, ACC_ADDRESS_SHIPPING).LinkId;
        ShipSys := Card(E, ACC_ADDRESS_SHIPPING).Address.Id;
        Check('ids set', (BillLink > 0) and (BillSys > 0) and (ShipLink > 0) and (ShipSys > 0));
        Check('billing primary', S(Scalar('SELECT is_primary::text FROM acc_account_address WHERE id = ' + BillLink.ToString)) = 'true');
        Check('billing type', S(Scalar('SELECT address_type FROM acc_account_address WHERE id = ' + BillLink.ToString)) = 'BILLING');
        Check('email stored', S(Scalar('SELECT email FROM sys_address WHERE id = ' + BillSys.ToString)) = 'fatura@it.test');
        Check('district trimmed', S(Scalar('SELECT district FROM sys_address WHERE id = ' + BillSys.ToString)) = 'IT İlçe');
        Check('empty legal not stored', Num(Scalar('SELECT count(*) FROM acc_account_address WHERE acc_account_id = ' + E.Id.ToString +
          ' AND address_type = ''LEGAL''')) = 0);

        // okuma: kart adresleri dolu gelir
        L := Svc.BusinessFindById(E.Id, False, False, True);
        try
          Check('load assigned', L.AddressesAssigned);
          Check('load billing', (Card(L, ACC_ADDRESS_BILLING).LinkId = BillLink) and
            (Card(L, ACC_ADDRESS_BILLING).Address.Street = 'IT Fatura Sokak') and
            (Card(L, ACC_ADDRESS_BILLING).Address.Web = 'www.it.test'));
          Check('load city name', Assigned(Card(L, ACC_ADDRESS_BILLING).Address.SysCity) and
            (Card(L, ACC_ADDRESS_BILLING).Address.SysCity.CityName <> ''));
          Check('load legal empty', Card(L, ACC_ADDRESS_LEGAL).LinkId = 0);

          // değişiklik yok -> adres satırlarına yazma yok (ctid aynı kalır)
          BillCtid := Ctid(BillSys);
          ShipCtid := Ctid(ShipSys);
          Svc.BusinessUpdate(L, False, False, True);
          Check('unchanged billing not written', Ctid(BillSys) = BillCtid, BillCtid + ' -> ' + Ctid(BillSys));
          Check('unchanged shipping not written', Ctid(ShipSys) = ShipCtid);

          // yalnız fatura adresi değişir
          Card(L, ACC_ADDRESS_BILLING).Address.Street := 'IT Yeni Sokak';
          Svc.BusinessUpdate(L, False, False, True);
          Check('changed billing written', S(Scalar('SELECT street FROM sys_address WHERE id = ' + BillSys.ToString)) = 'IT Yeni Sokak');
          Check('same sys_address updated', Card(L, ACC_ADDRESS_BILLING).Address.Id = BillSys);
          Check('shipping still not written', Ctid(ShipSys) = ShipCtid);

          // sevk adresi boşaltılır -> bağlantı + sys_address silinir
          Card(L, ACC_ADDRESS_SHIPPING).Address.SysCityId := 0;
          Card(L, ACC_ADDRESS_SHIPPING).Address.Street := '';
          Svc.BusinessUpdate(L, False, False, True);
          Check('cleared link deleted', Num(Scalar('SELECT count(*) FROM acc_account_address WHERE id = ' + ShipLink.ToString)) = 0);
          Check('cleared sys_address deleted', Num(Scalar('SELECT count(*) FROM sys_address WHERE id = ' + ShipSys.ToString)) = 0);
          Check('cleared ids reset', Card(L, ACC_ADDRESS_SHIPPING).LinkId = 0);

          // yeni yasal adres güncellemede eklenir
          Card(L, ACC_ADDRESS_LEGAL).Address.SysCityId := City;
          Card(L, ACC_ADDRESS_LEGAL).Address.Street := 'IT Yasal Sokak';
          Svc.BusinessUpdate(L, False, False, True);
          Check('legal added on update', Num(Scalar('SELECT count(*) FROM acc_account_address WHERE acc_account_id = ' + E.Id.ToString +
            ' AND address_type = ''LEGAL''')) = 1);

          // paylaşılan adres (başka hesap aynı sys_address'e bağlı) değiştirilmez: bu hesaba kopya açılır
          AA := TAccAccountAddress.Create;
          try
            AA.AccAccountId := Base;
            AA.SysAddressId := BillSys;
            AA.AddressType := 'OTHER';
            ASvc.BusinessInsert(AA, False, False, True);
          finally
            AA.Free;
          end;
          Card(L, ACC_ADDRESS_BILLING).Address.DoorNumber := '12';
          Svc.BusinessUpdate(L, False, False, True);
          Check('shared address untouched', S(Scalar('SELECT door_number FROM sys_address WHERE id = ' + BillSys.ToString)) = '<null>');
          Check('copy created for card', (Card(L, ACC_ADDRESS_BILLING).Address.Id <> BillSys) and
            (S(Scalar('SELECT door_number FROM sys_address WHERE id = ' + Card(L, ACC_ADDRESS_BILLING).Address.Id.ToString)) = '12'));
          Check('link repointed', Num(Scalar('SELECT sys_address_id FROM acc_account_address WHERE id = ' + BillLink.ToString)) =
            Card(L, ACC_ADDRESS_BILLING).Address.Id);
        finally
          L.Free;
        end;

        // adresleri yüklenmemiş hesap (liste nesnesi) güncellenince adreslere dokunulmaz
        L := Svc.FindById(E.Id, False);
        try
          L.Notes := 'IT';
          Svc.BusinessUpdate(L, False, False, True);
          Check('header-only update keeps addresses', LinkCount(E.Id) = 2, IntToStr(LinkCount(E.Id)));
        finally
          L.Free;
        end;

        // hesap silinince kendi adresleri de silinir
        L := Svc.FindById(E.Id, False, True);
        try
          BillSys := Card(L, ACC_ADDRESS_BILLING).Address.Id;
          ShipSys := Card(L, ACC_ADDRESS_LEGAL).Address.Id;
          Svc.BusinessDelete(L, False, False, True);
          Check('delete account', Num(Scalar('SELECT count(*) FROM acc_account WHERE id = ' + E.Id.ToString)) = 0);
          Check('delete own addresses', Num(Scalar('SELECT count(*) FROM sys_address WHERE id IN (' + BillSys.ToString + ',' +
            ShipSys.ToString + ')')) = 0);
        finally
          L.Free;
        end;
      finally
        E.Free;
      end;
      End_;

      Begin_;
      Expect('address without city', procedure
        var X: TAccAccount;
        begin
          X := Svc.FindById(Base, False, True);
          try
            Card(X, ACC_ADDRESS_OTHER).Address.SysCityId := 0;
            Card(X, ACC_ADDRESS_OTHER).Address.District := 'IT';
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    ASvc.Free;
    Svc.Free;
  end;
end;

// Mükellef tipi: tüzel -> vergi dairesi + 10 haneli VKN, gerçek -> ad, soyad + 11 haneli TCKN, tip yok -> bilgi tutulmaz
procedure SaveTaxpayer(Svc: TAccAccountService; Base: Int64; AType: SmallInt; const AName, ASurname, AOffice, ATaxNo: string);
var
  X: TAccAccount;
begin
  X := Svc.FindById(Base, False);
  try
    X.TaxpayerType := AType;
    X.TaxpayerName := AName;
    X.TaxpayerName2 := 'IKINCI';
    X.TaxpayerSurname := ASurname;
    X.TaxOffice := AOffice;
    X.TaxNo := ATaxNo;
    Svc.BusinessUpdate(X, False, False, True);
  finally
    X.Free;
  end;
end;

procedure TestAccountTaxpayer;
var
  Svc: TAccAccountService;
  Base: Int64;

  function Col(const AColumn: string): string;
  begin
    Result := S(Scalar('SELECT ' + AColumn + '::text FROM acc_account_taxpayer WHERE acc_account_id = ' + Base.ToString));
  end;

begin
  Ctx('Account', 'TAccAccount.Taxpayer');
  Base := Scalar('SELECT min(id) FROM acc_account WHERE code LIKE ''___-%''');
  Svc := TAccAccountService.Create;
  try
    try
      Begin_;
      Expect('legal without tax office', procedure begin SaveTaxpayer(Svc, Base, ACC_TAXPAYER_LEGAL, '', '', '', '1234567890'); end);
      Begin_;
      Expect('legal tax no 9 digits', procedure begin SaveTaxpayer(Svc, Base, ACC_TAXPAYER_LEGAL, '', '', 'PENDİK', '123456789'); end);
      Begin_;
      Expect('legal tax no not numeric', procedure begin SaveTaxpayer(Svc, Base, ACC_TAXPAYER_LEGAL, '', '', 'PENDİK', '12345A7890'); end);
      Begin_;
      SaveTaxpayer(Svc, Base, ACC_TAXPAYER_LEGAL, 'AD', 'SOYAD', ' PENDİK ', ' 1234567890 ');
      Check('legal saved', (Col('taxpayer_type') = '1') and (Col('tax_no') = '1234567890') and (Col('tax_office') = 'PENDİK'));
      Check('legal clears person names', (Col('taxpayer_name') = '<null>') and (Col('taxpayer_name2') = '<null>') and
        (Col('taxpayer_surname') = '<null>'));
      End_;

      Begin_;
      Expect('real without surname', procedure begin SaveTaxpayer(Svc, Base, ACC_TAXPAYER_REAL, 'AHMET', '', '', '12345678901'); end);
      Begin_;
      Expect('real citizen no 10 digits', procedure begin SaveTaxpayer(Svc, Base, ACC_TAXPAYER_REAL, 'AHMET', 'YILMAZ', '', '1234567890'); end);
      Begin_;
      SaveTaxpayer(Svc, Base, ACC_TAXPAYER_REAL, 'AHMET', 'YILMAZ', '', '12345678901');
      Check('real saved', (Col('taxpayer_type') = '2') and (Col('tax_no') = '12345678901') and (Col('taxpayer_surname') = 'YILMAZ') and
        (Col('taxpayer_name2') = 'IKINCI'));
      Check('real tax office optional', Col('tax_office') = '<null>');
      End_;

      Begin_;
      SaveTaxpayer(Svc, Base, 0, 'AHMET', 'YILMAZ', 'PENDİK', '12345678901');
      Check('no type clears taxpayer info', (Col('taxpayer_type') = '<null>') and (Col('tax_no') = '<null>') and
        (Col('tax_office') = '<null>') and (Col('taxpayer_name') = '<null>'));
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    Svc.Free;
  end;
end;

// Hesap kodu: 3 haneli seviyeler, ana kod hesap planında ve kod plan seviyesini aşmaz, üst hesap var, alt hesabı olanın
// kodu değişmez; hesap tipi koddan + plan seviyesinden türetilir; kart listeleri plana göre
procedure InsertAccountCode(Svc: TAccAccountService; ABase: Int64; const ACode: string);
var
  X: TAccAccount;
begin
  X := Svc.FindById(ABase, False);
  try
    X.Id := 0;
    X.Code := ACode;
    X.Name := 'IT KOD';
    Svc.BusinessInsert(X, False, False, True);
  finally
    X.Free;
  end;
end;

procedure TestAccountCode;
var
  Svc: TAccAccountService;
  Base: Int64;
  Items: TStringList;
  FreeCode, Detail, Code: string;

  function TypeOf(const ACode: string): string;
  begin
    Result := S(Scalar('SELECT acc_set_account_type_id::text FROM acc_account WHERE code = ''' + ACode + ''''));
  end;

begin
  Ctx('Account', 'TAccAccount.Code');
  Base := Scalar('SELECT id FROM acc_account WHERE code = ''120-001''');
  Detail := S(Scalar('SELECT min(code) FROM acc_account WHERE acc_set_account_type_id = 3 AND code ~ ''^[0-9]{3}-[0-9]{3}$'''));
  Svc := TAccAccountService.Create;
  Items := TStringList.Create;
  try
    try
      Check('code format', TAccAccountService.IsValidCode('120-001-089') and TAccAccountService.IsValidCode('120') and
        not TAccAccountService.IsValidCode('120-1-89') and not TAccAccountService.IsValidCode('120-001-001-001') and
        not TAccAccountService.IsValidCode('12A'));
      Check('parent code', (TAccAccountService.ParentCodeOf('120-001-005') = '120-001') and (TAccAccountService.ParentCodeOf('120') = ''));

      Items.Text := Svc.FreeCodesText('120-001');
      Check('free codes skip used', (Items.Count > 0) and (Items.IndexOf('120-001-001') < 0) and
        (Items[0] = S(Scalar('SELECT min(c) FROM (SELECT ''120-001-'' || lpad(n::text, 3, ''0'') c FROM generate_series(1, 999) n) s ' +
        'WHERE NOT EXISTS (SELECT 1 FROM acc_account a WHERE a.code = s.c)'))), Items[0] + ' / ' + IntToStr(Items.Count));
      FreeCode := Items[0];
      Items.Text := Svc.FreeCodesText('');
      Check('free main codes from plan', (Items.Count > 0) and (Items.IndexOf('120') < 0) and
        (Num(Scalar('SELECT count(*) FROM acc_account_plan WHERE code = ''' + Items[0] + '''')) = 1));
      Check('type for levels', (TAccAccountService.AccountTypeFor(1, 1) = ACC_ACCOUNT_TYPE_DETAIL) and
        (TAccAccountService.AccountTypeFor(1, 3) = ACC_ACCOUNT_TYPE_MAIN) and
        (TAccAccountService.AccountTypeFor(2, 3) = ACC_ACCOUNT_TYPE_INTERMEDIATE) and
        (TAccAccountService.AccountTypeFor(2, 2) = ACC_ACCOUNT_TYPE_DETAIL) and
        (TAccAccountService.AccountTypeFor(3, 3) = ACC_ACCOUNT_TYPE_DETAIL));
      Check('no free codes under detail level', (Svc.FreeCodesText('600') = '') and (Svc.FreeCodesText('153-001') = ''));
      Items.Text := Svc.ParentAccountsText('120');
      Check('intermediate list', Items.IndexOf('120-001 - ' + S(Scalar('SELECT name FROM acc_account WHERE id = ' + Base.ToString))) >= 0,
        Items.Text);
      Items.Text := Svc.ParentAccountsText('');
      Check('single level plan codes are not parents', (Items.Count > 0) and (Items.Text.IndexOf('600 - ') < 0));
      Check('invalid parent returns nothing', Svc.FreeCodesText('12-1') = '');

      Begin_;
      InsertAccountCode(Svc, Base, FreeCode);
      Check('insert first free code', Num(Scalar('SELECT count(*) FROM acc_account WHERE code = ''' + FreeCode + '''')) = 1);
      Check('level 3 of 3 -> detail', TypeOf(FreeCode) = '3', TypeOf(FreeCode));
      Items.Text := Svc.FreeCodesText('120');
      Code := Items[0];
      InsertAccountCode(Svc, Base, Code);
      Check('level 2 of 3 -> intermediate', TypeOf(Code) = '2', Code + ' ' + TypeOf(Code));
      Items.Text := Svc.FreeCodesText('153');
      Code := Items[0];
      InsertAccountCode(Svc, Base, Code);
      Check('level 2 of 2 -> detail', TypeOf(Code) = '3', Code + ' ' + TypeOf(Code));
      Code := S(Scalar('SELECT min(p.code) FROM acc_account_plan p WHERE p.level = 1 AND NOT EXISTS (SELECT 1 FROM acc_account a WHERE a.code = p.code)'));
      if Code <> '<null>' then
      begin
        InsertAccountCode(Svc, Base, Code);
        Check('level 1 of 1 -> detail', TypeOf(Code) = '3', Code + ' ' + TypeOf(Code));
      end;
      Code := S(Scalar('SELECT min(p.code) FROM acc_account_plan p WHERE p.level > 1 AND NOT EXISTS (SELECT 1 FROM acc_account a WHERE a.code = p.code)'));
      if Code <> '<null>' then
      begin
        InsertAccountCode(Svc, Base, Code);
        Check('level 1 of 2+ -> main', TypeOf(Code) = '1', Code + ' ' + TypeOf(Code));
      end;
      End_;

      Begin_;
      Expect('bad format 120-1-90', procedure begin InsertAccountCode(Svc, Base, '120-1-90'); end);
      Begin_;
      Expect('parent missing', procedure begin InsertAccountCode(Svc, Base, '120-999-001'); end);
      Begin_;
      Expect('deeper than plan level', procedure begin InsertAccountCode(Svc, Base, '153-001-001'); end);
      Begin_;
      Expect('main code not in plan', procedure begin InsertAccountCode(Svc, Base, '997'); end);
      Begin_;
      Expect('code change with children', procedure
        var X: TAccAccount;
        begin
          X := Svc.FindById(Base, False);
          try
            X.Code := '120-099';
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    Items.Free;
    Svc.Free;
  end;
end;

procedure TestTransferCode;
var
  Svc: TAccTransferCodeService;
  E: TAccTransferCode;
begin
  Ctx('Account', 'TAccTransferCode');
  Svc := TAccTransferCodeService.Create;
  E := TAccTransferCode.Create;
  try
    try
      Begin_;
      E.TransferCode := 'IT1';
      E.Description := 'IT aktarım';
      E.Account := Scalar('SELECT min(code) FROM acc_account');
      Svc.BusinessInsert(E, False, False, True);
      Check('insert', E.Id > 0);
      Check('grid/view row', Num(Scalar('SELECT count(*) FROM vw_acc_transfer_code WHERE id = ' + E.Id.ToString)) >= 1);
      E.Description := 'IT aktarım 2';
      Svc.BusinessUpdate(E, False, False, True);
      Check('update', S(Scalar('SELECT description FROM acc_transfer_code WHERE id = ' + E.Id.ToString)) = 'IT aktarım 2');
      Svc.BusinessDelete(E, False, False, True);
      Check('delete', Num(Scalar('SELECT count(*) FROM acc_transfer_code WHERE id = ' + E.Id.ToString)) = 0);
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    E.Free;
    Svc.Free;
  end;
end;

{ ------------------------------------------------------------- Employee }

procedure TestEmployee;
var
  Svc: TEmpEmployeeService;
  PSvc: TEmpPersonAddressService;
  TSvc: TEmpTransportationService;
  AdSvc: TSysAddressService;
  E: TEmpEmployee;
  PA: TEmpPersonAddress;
  Ad: TSysAddress;
  Tr: TEmpTransportation;
  Base: Int64;
begin
  Ctx('Employee', 'TEmpEmployee');
  Base := Scalar('SELECT min(id) FROM emp_employee');
  Svc := TEmpEmployeeService.Create;
  PSvc := TEmpPersonAddressService.Create;
  TSvc := TEmpTransportationService.Create;
  AdSvc := TSysAddressService.Create;
  try
    try
      Begin_;
      Tr := TEmpTransportation.Create;
      try
        Tr.CarNo := 99;
        Tr.CarName := 'IT SERVİS';
        TSvc.BusinessInsert(Tr, False, False, True);
        Ctx('Employee', 'TEmpTransportation');
        Check('insert', Tr.Id > 0);
        Ctx('Employee', 'TEmpEmployee');

        E := Svc.FindById(Base, False);
        try
          E.Id := 0;
          E.Name := '  Ayşe ';
          E.Surname := ' Çelik  ';
          E.FullName := 'wrong';
          E.EmpTransportationId := Tr.Id;
          E.MilitaryStatus := 77;
          E.BloodType := 'Q+';
          E.SalaryAmount := 12345.6789;
          Svc.BusinessInsert(E, False, False, True);
          Check('insert', E.Id > 0);
          Check('full_name derived', S(Scalar('SELECT full_name FROM emp_employee WHERE id = ' + E.Id.ToString)) = 'Ayşe Çelik',
            S(Scalar('SELECT full_name FROM emp_employee WHERE id = ' + E.Id.ToString)));
          Check('invalid military -> NULL', VarIsNull(Scalar('SELECT military_status FROM emp_employee WHERE id = ' + E.Id.ToString)));
          Check('invalid blood -> NULL', VarIsNull(Scalar('SELECT blood_type FROM emp_employee WHERE id = ' + E.Id.ToString)));
          Check('salary numeric(18,2) rounding', Near(Num(Scalar('SELECT salary_amount FROM emp_employee WHERE id = ' + E.Id.ToString)), 12345.68),
            S(Scalar('SELECT salary_amount FROM emp_employee WHERE id = ' + E.Id.ToString)));
          Check('transportation name in view', S(Scalar('SELECT transportation_name FROM vw_emp_employee WHERE id = :i AND locale = ''tr-TR''', [E.Id])) <> '<null>',
            S(Scalar('SELECT transportation_name FROM vw_emp_employee WHERE id = :i AND locale = ''tr-TR''', [E.Id])));

          Ad := TSysAddress.Create;
          try
            Ad.SysCityId := Scalar('SELECT min(id) FROM sys_city');
            Ad.District := 'IT';
            AdSvc.BusinessInsert(Ad, False, False, True);
            PA := TEmpPersonAddress.Create;
            try
              PA.EmpEmployeeId := E.Id;
              PA.SysAddressId := Ad.Id;
              PA.AddressType := 'HOME';
              PA.IsPrimary := True;
              PSvc.BusinessInsert(PA, False, False, True);
              Ctx('Employee', 'TEmpPersonAddress');
              Check('insert', PA.Id > 0);
              Check('view', Num(Scalar('SELECT count(*) FROM vw_emp_person_address WHERE emp_employee_id = ' + E.Id.ToString)) = 1);
              PSvc.BusinessDelete(PA, False, False, True);
              Check('delete', Num(Scalar('SELECT count(*) FROM emp_person_address WHERE id = ' + PA.Id.ToString)) = 0);
              Ctx('Employee', 'TEmpEmployee');
            finally
              PA.Free;
            end;
          finally
            Ad.Free;
          end;

          Svc.BusinessDelete(E, False, False, True);
          Check('delete', Num(Scalar('SELECT count(*) FROM emp_employee WHERE id = ' + E.Id.ToString)) = 0);
        finally
          E.Free;
        end;
      finally
        Tr.Free;
      end;
      End_;

      Begin_;
      Expect('missing person type', procedure
        var X: TEmpEmployee;
        begin
          X := Svc.FindById(Base, False);
          try
            X.EmpPersonTypeId := 0;
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('gender 5', procedure
        var X: TEmpEmployee;
        begin
          X := Svc.FindById(Base, False);
          try
            X.Gender := 5;
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('child 31', procedure
        var X: TEmpEmployee;
        begin
          X := Svc.FindById(Base, False);
          try
            X.Child := 31;
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('empty name', procedure
        var X: TEmpEmployee;
        begin
          X := Svc.FindById(Base, False);
          try
            X.Name := '   ';
            Svc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    AdSvc.Free;
    TSvc.Free;
    PSvc.Free;
    Svc.Free;
  end;
end;

{ --------------------------------------------------------------- System }

procedure TestUsers;
var
  Svc: TSysUserService;
  U: TSysUser;
  NPerm, NRight: Integer;
  Auth: TAuthService;
  LR: TLoginResult;
begin
  Ctx('System', 'TSysUser');
  Svc := TSysUserService.Create;
  try
    try
      Begin_;
      U := TSysUser.Create;
      try
        U.Username := '  it_kullanıcı ';
        U.UserPassword := 'abc';
        U.Active := True;
        U.EmpEmployeeId := Scalar('SELECT min(id) FROM emp_employee');
        Svc.BusinessInsert(U, False, False, True);
        Check('insert', U.Id > 0);
        Check('username upper + trim (tr)', S(Scalar('SELECT username FROM sys_user WHERE id = ' + U.Id.ToString)) = 'İT_KULLANICI',
          S(Scalar('SELECT username FROM sys_user WHERE id = ' + U.Id.ToString)));
        Check('password stored as bcrypt', S(Scalar('SELECT user_password FROM sys_user WHERE id = ' + U.Id.ToString)).StartsWith('$2'));
        Check('password verifies', TPasswordHelper.VerifyPassword('abc', S(Scalar('SELECT user_password FROM sys_user WHERE id = ' + U.Id.ToString))));
        NPerm := Scalar('SELECT count(*) FROM sys_permission');
        NRight := Scalar('SELECT count(*) FROM sys_access_right WHERE sys_user_id = ' + U.Id.ToString);
        Check('access right row per permission', NPerm = NRight, Format('%d permissions, %d rows', [NPerm, NRight]));
        Check('new user has no effective rights',
          Num(Scalar('SELECT count(*) FROM vw_sys_user_effective_permission WHERE sys_user_id = :u AND (is_read OR is_add OR is_update OR is_delete OR is_special)', [U.Id])) = 0);

        Svc.ResetPassword(U.Id, 'xyz9', True);
        Check('reset password keeps caller transaction', UoW.InTransaction);
        Check('reset password hash', TPasswordHelper.VerifyPassword('xyz9', S(Scalar('SELECT user_password FROM sys_user WHERE id = ' + U.Id.ToString))));

        // hash view'da yok; login tablodan okur
        Check('vw_sys_user hides password', Num(Scalar('SELECT count(*) FROM information_schema.columns ' +
          'WHERE table_name = ''vw_sys_user'' AND column_name = ''user_password''')) = 0);
        Auth := TAuthService.Create;
        try
          LR := Auth.Login('İT_KULLANICI', 'xyz9');
          Check('login', LR.Success and (LR.UserId = U.Id), LR.ErrorMessage);
          LR := Auth.Login('İT_KULLANICI', 'xyz8');
          Check('login wrong password', (not LR.Success) and (LR.Status = lsInvalidPassword), LR.ErrorMessage);
        finally
          Auth.Free;
        end;

        Expect('duplicate username (case/trim)', procedure
          var X: TSysUser;
          begin
            X := TSysUser.Create;
            try
              X.Username := 'it_KULLANICI';
              X.UserPassword := 'abc';
              X.EmpEmployeeId := Scalar('SELECT min(id) FROM emp_employee');
              Svc.BusinessInsert(X, False, False, True);
            finally X.Free; end;
          end);
      finally
        U.Free;
      end;
      Begin_;
      Expect('short password', procedure
        var X: TSysUser;
        begin
          X := TSysUser.Create;
          try
            X.Username := 'IT_SHORT';
            X.UserPassword := 'a';
            X.EmpEmployeeId := Scalar('SELECT min(id) FROM emp_employee');
            Svc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('missing employee', procedure
        var X: TSysUser;
        begin
          X := TSysUser.Create;
          try
            X.Username := 'IT_NOEMP';
            X.UserPassword := 'abc123';
            Svc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    Svc.Free;
  end;
end;

procedure TestPermissions;
const
  CODE = 1001;
var
  RSvc: TSysAccessRightService;
  TSvc: TSysUserPermissionTemplateService;
  URepo: TSysUserRepository;
  AR: TSysAccessRight;
  ARId, TplId: Int64;
  Link: TSysUserPermissionTemplate;
  StkCode: Integer;

  function AsTest(AType: TPermissionType; ACode: Integer): Boolean;
  begin
    // SetUser eski kullanıcıyı serbest bırakır -> her seferinde taze nesne yükle
    TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(4), False);
    try
      Result := UoW.IsAuthorized(ACode, AType, True);
    finally
      TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(1), False);
    end;
  end;

begin
  Ctx('System', 'TSysAccessRight');
  RSvc := TSysAccessRightService.Create;
  TSvc := TSysUserPermissionTemplateService.Create;
  URepo := TSysUserRepository.Create(UoW.Connection);
  try
    try
      Begin_;
      // TEST kullanıcısının şablonlarını kaldır, haklarını sıfırla
      UoW.Connection.ExecSQL('DELETE FROM sys_user_permission_template WHERE sys_user_id = 4');
      UoW.Connection.ExecSQL('UPDATE sys_access_right SET is_read=false, is_add=false, is_update=false, is_delete=false, is_special=false, ' +
        'deny_read=false, deny_add=false, deny_update=false, deny_delete=false, deny_special=false WHERE sys_user_id = 4');
      Check('no template, no override -> no read', not AsTest(ptRead, CODE));

      ARId := Scalar('SELECT a.id FROM sys_access_right a JOIN sys_permission p ON p.id = a.sys_permission_id ' +
        'WHERE a.sys_user_id = 4 AND p.permission_code = ' + CODE.ToString);
      AR := RSvc.BusinessFindById(ARId, False, True, True);
      try
        AR.IsRead := True;
        RSvc.BusinessUpdate(AR, False, False, True);
        Check('is_read override grants', AsTest(ptRead, CODE));
        Check('is_read does not grant add', not AsTest(ptAddRecord, CODE));

        Expect('grant + deny same flag', procedure
          begin
            AR.IsRead := True;
            AR.DenyRead := True;
            RSvc.BusinessUpdate(AR, False, False, True);
          end);
      finally
        AR.Free;
      end;

      // şablon ataması
      Begin_;
      UoW.Connection.ExecSQL('DELETE FROM sys_user_permission_template WHERE sys_user_id = 4');
      TplId := Scalar('SELECT t.id FROM sys_permission_template t JOIN sys_permission_template_right r ON r.sys_permission_template_id = t.id ' +
        'JOIN sys_permission p ON p.id = r.sys_permission_id WHERE p.permission_code = 1041 AND r.is_read ORDER BY t.id LIMIT 1');
      StkCode := 1041;
      Ctx('System', 'TSysUserPermissionTemplate');
      Link := TSysUserPermissionTemplate.Create;
      try
        Link.SysUserId := 4;
        Link.SysPermissionTemplateId := TplId;
        TSvc.BusinessInsert(Link, False, False, True);
        Check('template assignment', Link.Id > 0);
        Check('template grants read', AsTest(ptRead, StkCode));

        UoW.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = true WHERE sys_user_id = 4 AND sys_permission_id = ' +
          '(SELECT id FROM sys_permission WHERE permission_code = 1041)');
        Check('deny wins over template', not AsTest(ptRead, StkCode));
        UoW.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = false WHERE sys_user_id = 4');

        UoW.Connection.ExecSQL('UPDATE sys_permission_template SET active = false WHERE id = ' + TplId.ToString);
        Check('inactive template grants nothing', not AsTest(ptRead, StkCode));
        UoW.Connection.ExecSQL('UPDATE sys_permission_template SET active = true WHERE id = ' + TplId.ToString);

        Expect('duplicate assignment', procedure
          var X: TSysUserPermissionTemplate;
          begin
            X := TSysUserPermissionTemplate.Create;
            try
              X.SysUserId := 4;
              X.SysPermissionTemplateId := TplId;
              TSvc.BusinessInsert(X, False, False, True);
            finally X.Free; end;
          end);
      finally
        Link.Free;
      end;
      End_;

      // süper kullanıcı her şeyi yapabilir
      Ctx('System', 'TSysAccessRight');
      Check('super user bypass', UoW.IsAuthorized(CODE, ptDelete, True));
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    URepo.Free;
    TSvc.Free;
    RSvc.Free;
  end;
end;

procedure TestGridFilter;
var
  Svc: TSysGridFilterService;
  E: TSysGridFilter;
begin
  Ctx('System', 'TSysGridFilter');
  Svc := TSysGridFilterService.Create;
  E := TSysGridFilter.Create;
  try
    try
      Begin_;
      E.TableName := 'vw_it_test';
      E.FilterContent := 'name LIKE ''%ş%''';
      Svc.BusinessInsert(E, False, False, True);
      Check('insert', E.Id > 0);
      E.FilterContent := 'x = 1';
      Svc.BusinessUpdate(E, False, False, True);
      Check('update', S(Scalar('SELECT filter_content FROM sys_grid_filter WHERE id = ' + E.Id.ToString)) = 'x = 1');
      Expect('duplicate table', procedure
        var X: TSysGridFilter;
        begin
          X := TSysGridFilter.Create;
          try
            X.TableName := 'vw_it_test';
            X.FilterContent := 'y';
            Svc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    E.Free;
    Svc.Free;
  end;
end;

{ ---------------------------------------------------------------- Finance }

function NewNote(ASvc: TFinChequeNoteService; AKind, ADir: SmallInt; const ASerial: string; ABank: Int64): TFinChequeNote;
begin
  Result := TFinChequeNote.Create;
  Result.DocKind := AKind;
  Result.Direction := ADir;
  Result.SerialNo := ASerial;
  Result.IssueDate := Date;
  Result.DueDate := Date + 30;
  Result.Amount := 1500.5;
  Result.AccAccountId := Scalar('SELECT min(id) FROM acc_account');
  Result.AccBankId := ABank;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewNoteTx(ASvc: TFinChequeNoteTransactionService; ANote: Int64; AType: SmallInt; ADate: TDate;
  AAccount: Int64 = 0; ABank: Int64 = 0): TFinChequeNoteTransaction;
begin
  Result := TFinChequeNoteTransaction.Create;
  Result.FinChequeNoteId := ANote;
  Result.TransactionType := AType;
  Result.TransactionDate := ADate;
  Result.AccAccountId := AAccount;
  Result.AccBankId := ABank;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NoteStatus(ANote: Int64): Integer;
begin
  Result := Scalar('SELECT status FROM fin_cheque_note WHERE id = ' + ANote.ToString);
end;

procedure TestFinanceChequeNotes;
var
  NSvc: TFinChequeNoteService;
  TSvc: TFinChequeNoteTransactionService;
  N, N2, G: TFinChequeNote;
  T3, T5, TG: TFinChequeNoteTransaction;
  Bank, Acc: Int64;
begin
  Ctx('Finance', 'TFinChequeNote');
  Bank := Scalar('SELECT min(id) FROM acc_bank');
  Acc := Scalar('SELECT min(id) FROM acc_account');
  NSvc := TFinChequeNoteService.Create;
  TSvc := TFinChequeNoteTransactionService.Create;
  N := nil; N2 := nil; G := nil; T3 := nil; T5 := nil; TG := nil;
  try
    try
      Begin_;
      N := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, ' it-a100 ', Bank);
      Check('insert cheque', N.Id > 0, N.PortfolioNo);
      Check('portfolio no MC######', StartsText('MC', N.PortfolioNo) and (Length(N.PortfolioNo) = 8), N.PortfolioNo);
      Check('serial upper/trim', S(Scalar('SELECT serial_no FROM fin_cheque_note WHERE id = ' + N.Id.ToString)) = 'IT-A100');
      Check('currency default', S(Scalar('SELECT currency FROM fin_cheque_note WHERE id = ' + N.Id.ToString)) =
        S(Scalar('SELECT fn_default_currency()')));
      Check('status in portfolio', NoteStatus(N.Id) = FIN_STATUS_IN_PORTFOLIO);
      Check('opening tx', S(Scalar('SELECT string_agg(transaction_type::text || ''/'' || acc_account_id::text, '','') ' +
        'FROM fin_cheque_note_transaction WHERE fin_cheque_note_id = ' + N.Id.ToString)) = '1/' + Acc.ToString,
        S(Scalar('SELECT string_agg(transaction_type::text, '','') FROM fin_cheque_note_transaction WHERE fin_cheque_note_id = ' + N.Id.ToString)));

      N2 := NewNote(NSvc, FIN_DOC_NOTE, FIN_DIR_RECEIVED, 'IT-S1', 0);
      Check('note without bank', N2.Id > 0, N2.PortfolioNo);
      Check('portfolio no MS', StartsText('MS', N2.PortfolioNo), N2.PortfolioNo);
      Check('next number', N2.PortfolioNo <> N.PortfolioNo);

      // tahsile ver -> tahsil -> son hareketi sil
      T3 := NewNoteTx(TSvc, N.Id, FIN_STATUS_AT_BANK_COLLECTION, Date, 0, Bank);
      Check('tx to bank', NoteStatus(N.Id) = FIN_STATUS_AT_BANK_COLLECTION);
      Check('current holder = bank', S(Scalar('SELECT current_holder FROM vw_fin_cheque_note WHERE id = ' + N.Id.ToString)) =
        S(Scalar('SELECT bank_name FROM acc_bank WHERE id = ' + Bank.ToString)));
      T5 := NewNoteTx(TSvc, N.Id, FIN_STATUS_COLLECTED, Date + 1);
      Check('tx collected', NoteStatus(N.Id) = FIN_STATUS_COLLECTED);
      T5.Description := 'it açıklama';
      TSvc.BusinessUpdate(T5, False, False, True);
      Check('update last tx', S(Scalar('SELECT description FROM fin_cheque_note_transaction WHERE id = ' + T5.Id.ToString)) = 'it açıklama');
      TSvc.BusinessDelete(T5, False, False, True);
      Check('delete last tx -> status back', NoteStatus(N.Id) = FIN_STATUS_AT_BANK_COLLECTION);
      TSvc.BusinessDelete(T3, False, False, True);
      Check('delete tx -> in portfolio', NoteStatus(N.Id) = FIN_STATUS_IN_PORTFOLIO);

      // yalnız açılış varken belge güncellemesi açılış hareketini senkronlar
      N.IssueDate := Date - 2;
      N.DueDate := Date + 10;
      NSvc.BusinessUpdate(N, False, False, True);
      Check('opening tx date synced', S(Scalar('SELECT transaction_date FROM fin_cheque_note_transaction WHERE fin_cheque_note_id = ' + N.Id.ToString)) =
        S(Scalar('SELECT issue_date FROM fin_cheque_note WHERE id = ' + N.Id.ToString)));

      // verilen çek
      G := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_GIVEN, 'IT-K1', Bank);
      Check('given cheque KC + issued', StartsText('KC', G.PortfolioNo) and (NoteStatus(G.Id) = FIN_STATUS_ISSUED), G.PortfolioNo);
      TG := NewNoteTx(TSvc, G.Id, FIN_STATUS_PAID, Date);
      Check('given -> paid', NoteStatus(G.Id) = FIN_STATUS_PAID);

      NSvc.BusinessDelete(N2, False, False, True);
      Check('delete note (opening only)', Num(Scalar('SELECT count(*) FROM fin_cheque_note_transaction WHERE fin_cheque_note_id = ' + N2.Id.ToString)) = 0);
      End_;

      // ---- kural ihlalleri (her biri kendi transaction'ında)
      Begin_;
      Expect('duplicate serial same bank', procedure
        begin
          NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-D1', Bank).Free;
          NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'it-d1', Bank).Free;
        end);
      Begin_;
      Expect('cheque without bank', procedure
        begin
          NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-B0', 0).Free;
        end);
      Begin_;
      Expect('due before issue', procedure
        var X: TFinChequeNote;
        begin
          X := TFinChequeNote.Create;
          try
            X.DocKind := FIN_DOC_NOTE; X.Direction := FIN_DIR_RECEIVED; X.SerialNo := 'IT-DD';
            X.IssueDate := Date; X.DueDate := Date - 1; X.Amount := 10; X.AccAccountId := Acc;
            NSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('amount 0', procedure
        var X: TFinChequeNote;
        begin
          X := TFinChequeNote.Create;
          try
            X.DocKind := FIN_DOC_NOTE; X.Direction := FIN_DIR_RECEIVED; X.SerialNo := 'IT-A0';
            X.IssueDate := Date; X.DueDate := Date; X.Amount := 0; X.AccAccountId := Acc;
            NSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('invalid transition 3 -> 2', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T1', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_AT_BANK_COLLECTION, Date, 0, Bank).Free;
            NewNoteTx(TSvc, X.Id, FIN_STATUS_ENDORSED, Date, Acc).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('closed document (collected -> bounced)', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T2', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_COLLECTED, Date).Free;
            NewNoteTx(TSvc, X.Id, FIN_STATUS_BOUNCED, Date).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('date before previous', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T3', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_COLLECTED, Date - 5).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('endorse without account', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T4', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_ENDORSED, Date).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('collection without bank', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T5', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_AT_BANK_COLLECTION, Date).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('given cheque -> in portfolio', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_GIVEN, 'IT-T6', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_IN_PORTFOLIO, Date).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('delete non-last tx', procedure
        var X: TFinChequeNote; A, B: TFinChequeNoteTransaction;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T7', Bank);
          A := NewNoteTx(TSvc, X.Id, FIN_STATUS_AT_BANK_COLLECTION, Date, 0, Bank);
          B := NewNoteTx(TSvc, X.Id, FIN_STATUS_COLLECTED, Date);
          try
            TSvc.BusinessDelete(A, False, False, True);
          finally X.Free; A.Free; B.Free; end;
        end);
      Begin_;
      Expect('delete opening tx', procedure
        var X: TFinChequeNote; L: TList<TFinChequeNoteTransaction>; F: TFilterCriteria;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T8', Bank);
          F := TFilterCriteria.Create;
          F.Add(TFilterCriterion.New('fin_cheque_note_id', '=', TValue.From<Int64>(X.Id)));
          L := TSvc.BusinessFind(F, False, False, True);
          try
            TSvc.BusinessDelete(L[0], False, False, True);
          finally X.Free; F.Free; L.Free; end;
        end);
      Begin_;
      Expect('delete note with transactions', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-T9', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_COLLECTED, Date).Free;
            NSvc.BusinessDelete(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('change direction after transactions', procedure
        var X: TFinChequeNote;
        begin
          X := NewNote(NSvc, FIN_DOC_CHEQUE, FIN_DIR_RECEIVED, 'IT-TA', Bank);
          try
            NewNoteTx(TSvc, X.Id, FIN_STATUS_COLLECTED, Date).Free;
            X.Direction := FIN_DIR_GIVEN;
            NSvc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    N.Free; N2.Free; G.Free; T3.Free; T5.Free; TG.Free;
    TSvc.Free;
    NSvc.Free;
  end;
end;

function NewCard(ASvc: TFinCreditCardService; const AName: string; ALimit: Currency): TFinCreditCard;
begin
  Result := TFinCreditCard.Create;
  Result.CardName := AName;
  Result.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
  Result.CardLimit := ALimit;
  Result.CardLastDigits := '1234';
  Result.StatementDay := 5;
  Result.PaymentDay := 15;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewCardTx(ASvc: TFinCreditCardTransactionService; ACard: Int64; AType: SmallInt; AAmount: Currency;
  AInst: SmallInt = 1): TFinCreditCardTransaction;
begin
  Result := TFinCreditCardTransaction.Create;
  Result.FinCreditCardId := ACard;
  Result.TransactionType := AType;
  Result.Amount := AAmount;
  Result.InstallmentCount := AInst;
  ASvc.BusinessInsert(Result, False, False, True);
end;

procedure TestFinanceCreditCards;
var
  CSvc: TFinCreditCardService;
  TSvc: TFinCreditCardTransactionService;
  C: TFinCreditCard;
  T1, T2, T3: TFinCreditCardTransaction;
begin
  Ctx('Finance', 'TFinCreditCard');
  CSvc := TFinCreditCardService.Create;
  TSvc := TFinCreditCardTransactionService.Create;
  C := nil; T1 := nil; T2 := nil; T3 := nil;
  try
    try
      Begin_;
      C := NewCard(CSvc, 'IT KART', 1000);
      Check('insert card', C.Id > 0);
      Check('currency default', S(Scalar('SELECT currency FROM fin_credit_card WHERE id = ' + C.Id.ToString)) <> '<null>');
      T1 := NewCardTx(TSvc, C.Id, FIN_CARD_TX_SPENDING, 600, 3);
      Check('spending', Near(Num(Scalar('SELECT balance FROM vw_fin_credit_card WHERE id = ' + C.Id.ToString)), 600) and
        Near(Num(Scalar('SELECT available_limit FROM vw_fin_credit_card WHERE id = ' + C.Id.ToString)), 400));
      Check('installment amount', Near(Num(Scalar('SELECT installment_amount FROM vw_fin_credit_card_transaction WHERE id = ' + T1.Id.ToString)), 200));
      T2 := NewCardTx(TSvc, C.Id, FIN_CARD_TX_PAYMENT, 200);
      Check('payment', Near(Num(Scalar('SELECT balance FROM vw_fin_credit_card WHERE id = ' + C.Id.ToString)), 400));
      T3 := NewCardTx(TSvc, C.Id, FIN_CARD_TX_SPENDING, 500.25);
      Check('spending within limit', Near(Num(Scalar('SELECT balance FROM vw_fin_credit_card WHERE id = ' + C.Id.ToString)), 900.25));
      T3.Amount := 600;
      TSvc.BusinessUpdate(T3, False, False, True);
      Check('update up to limit', Near(Num(Scalar('SELECT available_limit FROM vw_fin_credit_card WHERE id = ' + C.Id.ToString)), 0));
      TSvc.BusinessDelete(T3, False, False, True);
      Check('delete tx', Near(Num(Scalar('SELECT balance FROM vw_fin_credit_card WHERE id = ' + C.Id.ToString)), 400));
      C.CardLimit := 5000;
      C.StatementDay := 0;
      CSvc.BusinessUpdate(C, False, False, True);
      Check('statement day 0 -> NULL', S(Scalar('SELECT statement_day FROM fin_credit_card WHERE id = ' + C.Id.ToString)) = '<null>');
      End_;

      Begin_;
      Expect('limit exceeded', procedure
        var X: TFinCreditCard;
        begin
          X := NewCard(CSvc, 'IT L', 1000);
          try
            NewCardTx(TSvc, X.Id, FIN_CARD_TX_SPENDING, 800).Free;
            NewCardTx(TSvc, X.Id, FIN_CARD_TX_SPENDING, 300).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('installments on payment', procedure
        var X: TFinCreditCard;
        begin
          X := NewCard(CSvc, 'IT P', 0);
          try
            NewCardTx(TSvc, X.Id, FIN_CARD_TX_PAYMENT, 100, 2).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('installments 40', procedure
        var X: TFinCreditCard;
        begin
          X := NewCard(CSvc, 'IT I', 0);
          try
            NewCardTx(TSvc, X.Id, FIN_CARD_TX_SPENDING, 100, 40).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('passive card spending', procedure
        var X: TFinCreditCard;
        begin
          X := NewCard(CSvc, 'IT PS', 0);
          try
            X.IsActive := False;
            CSvc.BusinessUpdate(X, False, False, True);
            NewCardTx(TSvc, X.Id, FIN_CARD_TX_SPENDING, 100).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('last digits 12a4', procedure
        var X: TFinCreditCard;
        begin
          X := TFinCreditCard.Create;
          try
            X.CardName := 'IT D'; X.AccBankId := Scalar('SELECT min(id) FROM acc_bank'); X.CardLastDigits := '12a4';
            CSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('statement day 32', procedure
        var X: TFinCreditCard;
        begin
          X := TFinCreditCard.Create;
          try
            X.CardName := 'IT D'; X.AccBankId := Scalar('SELECT min(id) FROM acc_bank'); X.StatementDay := 32;
            CSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('duplicate card name', procedure
        begin
          NewCard(CSvc, 'IT DUP', 0).Free;
          NewCard(CSvc, 'IT DUP', 0).Free;
        end);
      Begin_;
      Expect('delete card with transactions', procedure
        var X: TFinCreditCard;
        begin
          X := NewCard(CSvc, 'IT DEL', 0);
          try
            NewCardTx(TSvc, X.Id, FIN_CARD_TX_SPENDING, 100).Free;
            CSvc.BusinessDelete(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    C.Free; T1.Free; T2.Free; T3.Free;
    TSvc.Free;
    CSvc.Free;
  end;
end;

function NewPos(ASvc: TFinPosTerminalService; const AName: string; ARate: Currency; ADays: SmallInt): TFinPosTerminal;
begin
  Result := TFinPosTerminal.Create;
  Result.PosName := AName;
  Result.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
  Result.CommissionRate := ARate;
  Result.BlockedDays := ADays;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewPosTx(ASvc: TFinPosTransactionService; APos: Int64; AAmount, ARate: Currency): TFinPosTransaction;
begin
  Result := TFinPosTransaction.Create;
  Result.FinPosTerminalId := APos;
  Result.AccAccountId := Scalar('SELECT min(id) FROM acc_account');
  Result.Amount := AAmount;
  Result.CommissionRate := ARate;
  ASvc.BusinessInsert(Result, False, False, True);
end;

procedure TestFinancePos;
var
  PSvc: TFinPosTerminalService;
  TSvc: TFinPosTransactionService;
  P: TFinPosTerminal;
  T1, T2: TFinPosTransaction;
begin
  Ctx('Finance', 'TFinPosTerminal');
  PSvc := TFinPosTerminalService.Create;
  TSvc := TFinPosTransactionService.Create;
  P := nil; T1 := nil; T2 := nil;
  try
    try
      Begin_;
      P := NewPos(PSvc, 'IT POS', 1.75, 30);
      Check('insert pos', P.Id > 0);
      T1 := NewPosTx(TSvc, P.Id, 1000, 1.75);
      Check('commission 17.50 / net 982.50', Near(Num(Scalar('SELECT commission_amount FROM fin_pos_transaction WHERE id = ' + T1.Id.ToString)), 17.5) and
        Near(Num(Scalar('SELECT net_amount FROM fin_pos_transaction WHERE id = ' + T1.Id.ToString)), 982.5));
      Check('value date = date + 30', S(Scalar('SELECT value_date - transaction_date FROM fin_pos_transaction WHERE id = ' + T1.Id.ToString)) = '30');
      T2 := NewPosTx(TSvc, P.Id, 333.33, 1.75);
      Check('commission rounding 5.83', Near(Num(Scalar('SELECT commission_amount FROM fin_pos_transaction WHERE id = ' + T2.Id.ToString)), 5.83),
        S(Scalar('SELECT commission_amount FROM fin_pos_transaction WHERE id = ' + T2.Id.ToString)));
      T2.TransactionType := FIN_POS_TX_REFUND;
      T2.Amount := 100;
      TSvc.BusinessUpdate(T2, False, False, True);
      Check('refund update recalculated', Near(Num(Scalar('SELECT net_amount FROM fin_pos_transaction WHERE id = ' + T2.Id.ToString)), 98.25));
      Check('pos totals', Near(Num(Scalar('SELECT total_amount FROM vw_fin_pos_terminal WHERE id = ' + P.Id.ToString)), 900) and
        Near(Num(Scalar('SELECT total_net FROM vw_fin_pos_terminal WHERE id = ' + P.Id.ToString)), 884.25),
        S(Scalar('SELECT total_net FROM vw_fin_pos_terminal WHERE id = ' + P.Id.ToString)));
      TSvc.BusinessDelete(T2, False, False, True);
      Check('delete tx', Num(Scalar('SELECT count(*) FROM fin_pos_transaction WHERE fin_pos_terminal_id = ' + P.Id.ToString)) = 1);
      End_;

      Begin_;
      Expect('rate 120', procedure
        begin
          NewPos(PSvc, 'IT R', 120, 0).Free;
        end);
      Begin_;
      Expect('blocked days 400', procedure
        begin
          NewPos(PSvc, 'IT B', 1, 400).Free;
        end);
      Begin_;
      Expect('duplicate pos name', procedure
        begin
          NewPos(PSvc, 'IT DUP', 1, 0).Free;
          NewPos(PSvc, 'IT DUP', 1, 0).Free;
        end);
      Begin_;
      Expect('value date before transaction', procedure
        var X: TFinPosTerminal; Y: TFinPosTransaction;
        begin
          X := NewPos(PSvc, 'IT V', 1, 0);
          Y := TFinPosTransaction.Create;
          try
            Y.FinPosTerminalId := X.Id; Y.AccAccountId := Scalar('SELECT min(id) FROM acc_account'); Y.Amount := 10;
            Y.ValueDate := Date - 1;
            TSvc.BusinessInsert(Y, False, False, True);
          finally X.Free; Y.Free; end;
        end);
      Begin_;
      Expect('missing account', procedure
        var X: TFinPosTerminal; Y: TFinPosTransaction;
        begin
          X := NewPos(PSvc, 'IT A', 1, 0);
          Y := TFinPosTransaction.Create;
          try
            Y.FinPosTerminalId := X.Id; Y.Amount := 10;
            TSvc.BusinessInsert(Y, False, False, True);
          finally X.Free; Y.Free; end;
        end);
      Begin_;
      Expect('passive pos', procedure
        var X: TFinPosTerminal;
        begin
          X := NewPos(PSvc, 'IT PP', 1, 0);
          try
            X.IsActive := False;
            PSvc.BusinessUpdate(X, False, False, True);
            NewPosTx(TSvc, X.Id, 10, 1).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('delete pos with transactions', procedure
        var X: TFinPosTerminal;
        begin
          X := NewPos(PSvc, 'IT PD', 1, 0);
          try
            NewPosTx(TSvc, X.Id, 10, 1).Free;
            PSvc.BusinessDelete(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    P.Free; T1.Free; T2.Free;
    TSvc.Free;
    PSvc.Free;
  end;
end;

function NewMoneyAccount(ASvc: TFinMoneyAccountService; AKind: SmallInt; const ACode: string; const AIban: string = ''): TFinMoneyAccount;
begin
  Result := TFinMoneyAccount.Create;
  Result.AccountKind := AKind;
  Result.Code := ACode;
  Result.Name := 'IT ' + ACode;
  if AKind = FIN_MONEY_BANK then
  begin
    Result.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
    Result.Iban := AIban;
  end;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewMoneyTx(ASvc: TFinMoneyTransactionService; AAcc: Int64; AType: SmallInt; AAmount: Currency;
  ATarget: Int64 = 0; ACurrent: Int64 = 0): TFinMoneyTransaction;
begin
  Result := TFinMoneyTransaction.Create;
  Result.FinMoneyAccountId := AAcc;
  Result.TransactionType := AType;
  Result.Amount := AAmount;
  Result.TargetFinMoneyAccountId := ATarget;
  Result.AccAccountId := ACurrent;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function MoneyBalance(AAcc: Int64): Double;
begin
  Result := Num(Scalar('SELECT balance FROM vw_fin_money_account WHERE id = ' + AAcc.ToString));
end;

procedure TestFinanceMoney;
var
  ASvc: TFinMoneyAccountService;
  TSvc: TFinMoneyTransactionService;
  LSvc: TFinMoneyLedgerService;
  K, B, C: TFinMoneyAccount;
  T1, T2, T3: TFinMoneyTransaction;
  Cari: Int64;
  L: TFinMoneyLedger;
begin
  Ctx('Finance', 'TFinMoneyTransaction');
  Cari := Scalar('SELECT min(id) FROM acc_account');
  ASvc := TFinMoneyAccountService.Create;
  TSvc := TFinMoneyTransactionService.Create;
  LSvc := TFinMoneyLedgerService.Create;
  K := nil; B := nil; C := nil; T1 := nil; T2 := nil; T3 := nil;
  try
    try
      Begin_;
      K := NewMoneyAccount(ASvc, FIN_MONEY_CASH, ' it-k01 ');
      Check('insert cash', K.Id > 0);
      Check('code upper/trim', S(Scalar('SELECT code FROM fin_money_account WHERE id = ' + K.Id.ToString)) = 'IT-K01');
      B := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-B01', 'tr33 0006 1005 1978 6457 8413 26');
      Check('insert bank + iban normalized', S(Scalar('SELECT iban FROM fin_money_account WHERE id = ' + B.Id.ToString)) = 'TR330006100519786457841326',
        S(Scalar('SELECT iban FROM fin_money_account WHERE id = ' + B.Id.ToString)));

      // kasa: banka bilgisi temizlenir
      C := TFinMoneyAccount.Create;
      C.AccountKind := FIN_MONEY_CASH; C.Code := 'IT-K02'; C.Name := 'IT K02';
      C.AccBankId := Scalar('SELECT min(id) FROM acc_bank'); C.AccountNo := '123';
      ASvc.BusinessInsert(C, False, False, True);
      Check('cash clears bank fields', S(Scalar('SELECT acc_bank_id FROM fin_money_account WHERE id = ' + C.Id.ToString)) = '<null>');

      T1 := TFinMoneyTransaction.Create;
      T1.FinMoneyAccountId := B.Id; T1.TransactionType := FIN_MONEY_TX_COLLECTION; T1.TransferMethod := FIN_METHOD_EFT;
      T1.AccAccountId := Cari; T1.Amount := 5000; T1.DocumentNo := ' d-1 '; T1.CounterpartyIban := 'TR33 0006 1005 1978 6457 8413 26';
      TSvc.BusinessInsert(T1, False, False, True);
      Check('incoming EFT', Near(MoneyBalance(B.Id), 5000));
      Check('document no upper', S(Scalar('SELECT document_no FROM fin_money_transaction WHERE id = ' + T1.Id.ToString)) = 'D-1');

      T2 := NewMoneyTx(TSvc, B.Id, FIN_MONEY_TX_TRANSFER, 1200, K.Id);
      Check('transfer bank -> cash', Near(MoneyBalance(B.Id), 3800) and Near(MoneyBalance(K.Id), 1200),
        Format('bank %g cash %g', [MoneyBalance(B.Id), MoneyBalance(K.Id)]));
      Check('ledger 2 lines for transfer', Num(Scalar('SELECT count(*) FROM vw_fin_money_ledger WHERE fin_money_transaction_id = ' + T2.Id.ToString)) = 2);
      Check('ledger running balance', Near(Num(Scalar('SELECT balance FROM vw_fin_money_ledger WHERE fin_money_account_id = ' + B.Id.ToString +
        ' ORDER BY transaction_date DESC, id DESC LIMIT 1')), 3800));

      T3 := NewMoneyTx(TSvc, K.Id, FIN_MONEY_TX_EXPENSE, 15.5);
      Check('cash expense', Near(MoneyBalance(K.Id), 1184.5));

      // banka hesabı eksiye düşebilir (KMH)
      NewMoneyTx(TSvc, B.Id, FIN_MONEY_TX_PAYMENT, 10000, 0, Cari).Free;
      Check('bank overdraft allowed', Near(MoneyBalance(B.Id), -6200));

      T2.Amount := 1000;
      TSvc.BusinessUpdate(T2, False, False, True);
      Check('update transfer', Near(MoneyBalance(K.Id), 984.5));

      // ekstre salt okunur; kilitli okuma view'da FOR UPDATE kullanmaz
      L := LSvc.BusinessFindById(T2.Id * 2, False, True, True);
      try
        Check('ledger find (lock ignored)', Assigned(L) and (L.FinMoneyTransactionId = T2.Id));
      finally
        L.Free;
      end;
      End_;

      // ---- kural ihlalleri
      Begin_;
      Expect('cash insufficient', procedure
        var X: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_CASH, 'IT-KX');
          try
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_OTHER_IN, 100).Free;
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_PAYMENT, 150, 0, Cari).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('delete transfer makes cash negative', procedure
        var X, Y: TFinMoneyAccount; Tr: TFinMoneyTransaction;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_CASH, 'IT-KY');
          Y := NewMoneyAccount(ASvc, FIN_MONEY_CASH, 'IT-KZ');
          NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_OTHER_IN, 100).Free;
          Tr := NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_TRANSFER, 100, Y.Id);
          try
            NewMoneyTx(TSvc, Y.Id, FIN_MONEY_TX_EXPENSE, 50).Free;
            TSvc.BusinessDelete(Tr, False, False, True);
          finally X.Free; Y.Free; Tr.Free; end;
        end);
      Begin_;
      Expect('invalid iban', procedure
        begin
          NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BI', 'TR330006100519786457841327').Free;
        end);
      Begin_;
      Expect('bank account without bank', procedure
        var X: TFinMoneyAccount;
        begin
          X := TFinMoneyAccount.Create;
          try
            X.AccountKind := FIN_MONEY_BANK; X.Code := 'IT-BN'; X.Name := 'IT BN';
            ASvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('duplicate code', procedure
        begin
          NewMoneyAccount(ASvc, FIN_MONEY_CASH, 'IT-DUP').Free;
          NewMoneyAccount(ASvc, FIN_MONEY_CASH, 'it-dup').Free;
        end);
      Begin_;
      Expect('duplicate iban', procedure
        begin
          NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-I1', 'TR330006100519786457841326').Free;
          NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-I2', 'TR330006100519786457841326').Free;
        end);
      Begin_;
      Expect('transfer to same account', procedure
        var X: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BS');
          try
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_TRANSFER, 10, X.Id).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('transfer currency mismatch', procedure
        var X, Y: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BC1');
          Y := TFinMoneyAccount.Create;
          try
            Y.AccountKind := FIN_MONEY_BANK; Y.Code := 'IT-BC2'; Y.Name := 'IT BC2';
            Y.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
            Y.Currency := Scalar('SELECT currency FROM sys_currency WHERE currency <> fn_default_currency() ORDER BY id LIMIT 1');
            ASvc.BusinessInsert(Y, False, False, True);
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_TRANSFER, 10, Y.Id).Free;
          finally X.Free; Y.Free; end;
        end);
      Begin_;
      Expect('collection without account', procedure
        var X: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BA');
          try
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_COLLECTION, 10).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('passive account', procedure
        var X: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BP');
          try
            X.IsActive := False;
            ASvc.BusinessUpdate(X, False, False, True);
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_OTHER_IN, 10).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('delete account with transactions', procedure
        var X: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BD');
          try
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_OTHER_IN, 10).Free;
            ASvc.BusinessDelete(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('currency change after transactions', procedure
        var X: TFinMoneyAccount;
        begin
          X := NewMoneyAccount(ASvc, FIN_MONEY_BANK, 'IT-BK');
          try
            NewMoneyTx(TSvc, X.Id, FIN_MONEY_TX_OTHER_IN, 10).Free;
            X.Currency := Scalar('SELECT currency FROM sys_currency WHERE currency <> fn_default_currency() ORDER BY id LIMIT 1');
            ASvc.BusinessUpdate(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('ledger is read-only', procedure
        var X: TFinMoneyLedger;
        begin
          X := TFinMoneyLedger.Create;
          try
            LSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    K.Free; B.Free; C.Free; T1.Free; T2.Free; T3.Free;
    LSvc.Free;
    TSvc.Free;
    ASvc.Free;
  end;
end;

function NewCompanyBank(ASvc: TFinCompanyBankAccountService; const AIban: string; ACheque, ANote: Boolean): TFinCompanyBankAccount;
begin
  Result := TFinCompanyBankAccount.Create;
  Result.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
  Result.BranchCode := ' 1234 ';
  Result.BranchName := 'IT Merkez';
  Result.SysCityId := Scalar('SELECT min(id) FROM sys_city');
  Result.AccountNo := '6297711';
  Result.Iban := AIban;
  Result.AccountHolder := 'IT LTD';
  Result.ShowOnCheque := ACheque;
  Result.ShowOnNote := ANote;
  ASvc.BusinessInsert(Result, False, False, True);
end;

procedure TestCompanyBankAccounts;
var
  CSvc: TFinCompanyBankAccountService;
  NSvc: TFinChequeNoteService;
  A: TFinCompanyBankAccount;
  N: TFinChequeNote;
  Lines: TArray<string>;
  Acc: Int64;
begin
  Ctx('Finance', 'TFinCompanyBankAccount');
  Acc := Scalar('SELECT min(id) FROM acc_account');
  CSvc := TFinCompanyBankAccountService.Create;
  NSvc := TFinChequeNoteService.Create;
  A := nil;
  try
    try
      Begin_;
      A := NewCompanyBank(CSvc, 'tr33 0006 1005 1978 6457 8413 26', True, False);
      Check('insert', A.Id > 0);
      Check('iban normalized / branch upper', S(Scalar('SELECT iban || ''/'' || branch_code FROM fin_company_bank_account WHERE id = ' + A.Id.ToString)) =
        'TR330006100519786457841326/1234');
      Check('print text', Pos('IBAN: TR33 0006 1005 1978 6457 8413 26', S(Scalar('SELECT print_text FROM vw_fin_company_bank_account WHERE id = ' + A.Id.ToString))) > 0,
        S(Scalar('SELECT print_text FROM vw_fin_company_bank_account WHERE id = ' + A.Id.ToString)));
      Lines := CSvc.GetPrintLines(FIN_BANK_USAGE_CHEQUE);
      Check('print lines (cheque)', Length(Lines) = Num(Scalar('SELECT count(*) FROM fin_company_bank_account WHERE is_active AND show_on_cheque')));
      Lines := CSvc.GetPrintLines(FIN_BANK_USAGE_NOTE);
      Check('print lines (note) excludes', Length(Lines) = Num(Scalar('SELECT count(*) FROM fin_company_bank_account WHERE is_active AND show_on_note')));

      // kendi çekimiz: banka / hesap no / para birimi firma hesabından
      N := TFinChequeNote.Create;
      try
        N.DocKind := FIN_DOC_CHEQUE; N.Direction := FIN_DIR_GIVEN; N.SerialNo := 'IT-CB1';
        N.IssueDate := Date; N.DueDate := Date + 30; N.Amount := 100; N.AccAccountId := Acc;
        N.FinCompanyBankAccountId := A.Id;
        NSvc.BusinessInsert(N, False, False, True);
        Check('own cheque from company account', S(Scalar('SELECT acc_bank_id || ''/'' || bank_account_no || ''/'' || currency FROM fin_cheque_note WHERE id = ' + N.Id.ToString)) =
          S(Scalar('SELECT acc_bank_id || ''/'' || account_no || ''/'' || currency FROM fin_company_bank_account WHERE id = ' + A.Id.ToString)));
        Check('view company iban', S(Scalar('SELECT company_bank_iban FROM vw_fin_cheque_note WHERE id = ' + N.Id.ToString)) = 'TR330006100519786457841326');
      finally
        N.Free;
      end;

      // alınan çekte firma hesabı tutulmaz
      N := TFinChequeNote.Create;
      try
        N.DocKind := FIN_DOC_CHEQUE; N.Direction := FIN_DIR_RECEIVED; N.SerialNo := 'IT-CB2';
        N.IssueDate := Date; N.DueDate := Date + 30; N.Amount := 100; N.AccAccountId := Acc;
        N.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
        N.FinCompanyBankAccountId := A.Id;
        NSvc.BusinessInsert(N, False, False, True);
        Check('received cheque clears company account', S(Scalar('SELECT fin_company_bank_account_id FROM fin_cheque_note WHERE id = ' + N.Id.ToString)) = '<null>');
      finally
        N.Free;
      end;
      End_;

      Begin_;
      Expect('invalid iban', procedure
        begin
          NewCompanyBank(CSvc, 'TR330006100519786457841327', True, True).Free;
        end);
      Begin_;
      Expect('duplicate iban', procedure
        begin
          NewCompanyBank(CSvc, 'TR330006100519786457841326', True, True).Free;
          NewCompanyBank(CSvc, 'TR33 0006 1005 1978 6457 8413 26', True, True).Free;
        end);
      Begin_;
      Expect('sort order 1000', procedure
        var X: TFinCompanyBankAccount;
        begin
          X := TFinCompanyBankAccount.Create;
          try
            X.AccBankId := Scalar('SELECT min(id) FROM acc_bank'); X.Iban := 'TR330006100519786457841326'; X.SortOrder := 1000;
            CSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('account not enabled for notes', procedure
        var X: TFinCompanyBankAccount; Y: TFinChequeNote;
        begin
          X := NewCompanyBank(CSvc, 'TR330006100519786457841326', True, False);
          Y := TFinChequeNote.Create;
          try
            Y.DocKind := FIN_DOC_NOTE; Y.Direction := FIN_DIR_GIVEN; Y.SerialNo := 'IT-CB3';
            Y.IssueDate := Date; Y.DueDate := Date; Y.Amount := 10; Y.AccAccountId := Acc; Y.FinCompanyBankAccountId := X.Id;
            NSvc.BusinessInsert(Y, False, False, True);
          finally X.Free; Y.Free; end;
        end);
      Begin_;
      Expect('currency mismatch', procedure
        var X: TFinCompanyBankAccount; Y: TFinChequeNote;
        begin
          X := NewCompanyBank(CSvc, 'TR330006100519786457841326', True, False);
          Y := TFinChequeNote.Create;
          try
            Y.DocKind := FIN_DOC_CHEQUE; Y.Direction := FIN_DIR_GIVEN; Y.SerialNo := 'IT-CB4';
            Y.IssueDate := Date; Y.DueDate := Date; Y.Amount := 10; Y.AccAccountId := Acc; Y.FinCompanyBankAccountId := X.Id;
            Y.Currency := Scalar('SELECT currency FROM sys_currency WHERE currency <> fn_default_currency() ORDER BY id LIMIT 1');
            NSvc.BusinessInsert(Y, False, False, True);
          finally X.Free; Y.Free; end;
        end);
      Begin_;
      Expect('delete used account', procedure
        var X: TFinCompanyBankAccount; Y: TFinChequeNote;
        begin
          X := NewCompanyBank(CSvc, 'TR330006100519786457841326', True, False);
          Y := TFinChequeNote.Create;
          try
            Y.DocKind := FIN_DOC_CHEQUE; Y.Direction := FIN_DIR_GIVEN; Y.SerialNo := 'IT-CB5';
            Y.IssueDate := Date; Y.DueDate := Date; Y.Amount := 10; Y.AccAccountId := Acc; Y.FinCompanyBankAccountId := X.Id;
            NSvc.BusinessInsert(Y, False, False, True);
            CSvc.BusinessDelete(X, False, False, True);
          finally X.Free; Y.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    A.Free;
    NSvc.Free;
    CSvc.Free;
  end;
end;

{ ---------------------------------------------------------------- Purchasing }

function NewRequest(ASvc: TPurRequestService): TPurRequest;
begin
  Result := TPurRequest.Create;
  Result.EmpEmployeeId := Scalar('SELECT min(id) FROM emp_employee');
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewRequestLine(ASvc: TPurRequestDetailService; AReq, AInv: Int64; AQty: Currency): TPurRequestDetail;
begin
  Result := TPurRequestDetail.Create;
  Result.PurRequestId := AReq;
  Result.StkInventoryId := AInv;
  Result.Quantity := AQty;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewOrder(ASvc: TPurOrderService; AAccount: Int64): TPurOrder;
begin
  Result := TPurOrder.Create;
  Result.AccAccountId := AAccount;
  Result.StkWarehouseId := Scalar('SELECT min(id) FROM stk_warehouse');
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewOrderLine(ASvc: TPurOrderDetailService; AOrder, AInv: Int64; AQty, APrice: Currency): TPurOrderDetail;
begin
  Result := TPurOrderDetail.Create;
  Result.PurOrderId := AOrder;
  Result.StkInventoryId := AInv;
  Result.Quantity := AQty;
  Result.UnitPrice := APrice;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function StockQty(AInv: Int64): Double;
var
  V: Variant;
begin
  V := Scalar('SELECT current_quantity FROM stk_inventory_summary WHERE stk_inventory_id = ' + AInv.ToString);
  if VarIsNull(V) or VarIsEmpty(V) then Result := 0 else Result := V;
end;

function FirstId(const ASql: string): Int64;
var
  V: Variant;
begin
  V := Scalar(ASql);
  if VarIsNull(V) or VarIsEmpty(V) then Result := 0 else Result := V;
end;

procedure TestPurchasing;
var
  RSvc: TPurRequestService;
  RDSvc: TPurRequestDetailService;
  OSvc: TPurOrderService;
  ODSvc: TPurOrderDetailService;
  PSvc: TPurReceiptService;
  PDSvc: TPurReceiptDetailService;
  FSvc: TPurInvoiceService;
  FDSvc: TPurInvoiceDetailService;
  StSvc: TStkTransactionService;
  Req: TPurRequest;
  OD: TPurOrderDetail;
  PD: TPurReceiptDetail;
  Inv1, Inv3, Supplier, Supplier2, OrderId, ReceiptId, InvoiceId, LineId, StId: Int64;
  Qty1Before, Qty3Before: Double;
  Lst: TList<TPurOrderDetail>;
  F: TFilterCriteria;
  St: TStkTransaction;
  Fi: TPurInvoice;
  Rc: TPurReceipt;
begin
  Ctx('Purchasing', 'flow');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv3 := Scalar('SELECT id FROM stk_inventory WHERE buying_currency = fn_default_currency() AND buying_price > 0 AND id <> ' +
    Inv1.ToString + ' ORDER BY id LIMIT 1');
  Supplier := Scalar('SELECT min(id) FROM acc_account');
  Supplier2 := Scalar('SELECT max(id) FROM acc_account');
  RSvc := TPurRequestService.Create;
  RDSvc := TPurRequestDetailService.Create;
  OSvc := TPurOrderService.Create;
  ODSvc := TPurOrderDetailService.Create;
  PSvc := TPurReceiptService.Create;
  PDSvc := TPurReceiptDetailService.Create;
  FSvc := TPurInvoiceService.Create;
  FDSvc := TPurInvoiceDetailService.Create;
  StSvc := TStkTransactionService.Create;
  Req := nil;
  try
    try
      Begin_;
      Qty1Before := StockQty(Inv1);
      Qty3Before := StockQty(Inv3);

      // ---- talep
      Req := NewRequest(RSvc);
      Check('request insert', StartsText('PT', Req.RequestNo) and (Length(Req.RequestNo) = 8), Req.RequestNo);
      NewRequestLine(RDSvc, Req.Id, Inv1, 10).Free;
      NewRequestLine(RDSvc, Req.Id, Inv3, 5).Free;
      RSvc.ChangeStatus(Req.Id, PUR_REQ_APPROVED, True);
      Check('request approved', Num(Scalar('SELECT status FROM pur_request WHERE id = ' + Req.Id.ToString)) = PUR_REQ_APPROVED);

      // ---- talepten sipariş
      OrderId := OSvc.CreateFromRequest(Req.Id, Supplier, True);
      Check('order from request', StartsText('PS', S(Scalar('SELECT order_no FROM pur_order WHERE id = ' + OrderId.ToString))) and
        (Num(Scalar('SELECT count(*) FROM pur_order_detail WHERE pur_order_id = ' + OrderId.ToString)) = 2));
      Check('line numbers', S(Scalar('SELECT string_agg(line_no::text, '','' ORDER BY line_no) FROM pur_order_detail WHERE pur_order_id = ' + OrderId.ToString)) = '1,2');
      Check('request ordered (status 4)', Num(Scalar('SELECT status FROM pur_request WHERE id = ' + Req.Id.ToString)) = PUR_REQ_ORDERED);
      Check('ordered quantity', Near(Num(Scalar('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + Req.Id.ToString)), 15));
      Check('price suggested (same currency)', Num(Scalar('SELECT unit_price FROM pur_order_detail WHERE pur_order_id = ' + OrderId.ToString +
        ' AND stk_inventory_id = ' + Inv3.ToString)) > 0);
      Check('vat from group', Near(Num(Scalar('SELECT vat_rate FROM pur_order_detail WHERE pur_order_id = ' + OrderId.ToString + ' AND stk_inventory_id = ' + Inv3.ToString)),
        Num(Scalar('SELECT COALESCE(i.vat_rate, g.vat_rate, 0) FROM stk_inventory i JOIN stk_group g ON g.id = i.stk_group_id WHERE i.id = ' + Inv3.ToString))));

      // satır tutarları: 10 x 2,50 = 25,00; %10 iskonto 2,50; net 22,50; %20 KDV 4,50; toplam 27,00
      OD := ODSvc.FindById(FirstId('SELECT id FROM pur_order_detail WHERE pur_order_id = ' + OrderId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString), False);
      try
        OD.UnitPrice := 2.5;
        OD.DiscountRate := 10;
        OD.VatRate := 20;
        ODSvc.BusinessUpdate(OD, False, False, True);
        LineId := OD.Id;
      finally
        OD.Free;
      end;
      Check('line amounts', S(Scalar('SELECT gross_amount || ''/'' || discount_amount || ''/'' || net_amount || ''/'' || vat_amount || ''/'' || total_amount ' +
        'FROM pur_order_detail WHERE id = ' + LineId.ToString)) = '25.00/2.50/22.50/4.50/27.00',
        S(Scalar('SELECT gross_amount || ''/'' || discount_amount || ''/'' || net_amount || ''/'' || vat_amount || ''/'' || total_amount FROM pur_order_detail WHERE id = ' + LineId.ToString)));
      Check('order totals = sum of lines', Num(Scalar('SELECT count(*) FROM pur_order o WHERE o.id = ' + OrderId.ToString +
        ' AND o.total_amount = (SELECT sum(total_amount) FROM pur_order_detail WHERE pur_order_id = o.id) ' +
        ' AND o.net_amount = (SELECT sum(net_amount) FROM pur_order_detail WHERE pur_order_id = o.id)')) = 1);

      OSvc.ChangeStatus(OrderId, PUR_ORD_APPROVED, True);
      Check('order approved', Num(Scalar('SELECT status FROM pur_order WHERE id = ' + OrderId.ToString)) = PUR_ORD_APPROVED);

      // ---- siparişten mal kabul (stok girişi)
      ReceiptId := PSvc.CreateFromOrder(OrderId, Scalar('SELECT min(id) FROM stk_warehouse'), True);
      Check('receipt from order', StartsText('MK', S(Scalar('SELECT receipt_no FROM pur_receipt WHERE id = ' + ReceiptId.ToString))) and
        (Num(Scalar('SELECT count(*) FROM pur_receipt_detail WHERE pur_receipt_id = ' + ReceiptId.ToString)) = 2));
      Check('stock transactions created', Num(Scalar('SELECT count(*) FROM stk_transaction t JOIN pur_receipt_detail d ON d.id = t.pur_receipt_detail_id ' +
        'WHERE d.pur_receipt_id = ' + ReceiptId.ToString + ' AND t.transaction_type = 1')) = 2);
      Check('stock summary +10 / +5', Near(StockQty(Inv1), Qty1Before + 10) and Near(StockQty(Inv3), Qty3Before + 5),
        Format('%g -> %g', [Qty1Before, StockQty(Inv1)]));
      Check('unit cost = net price', Near(Num(Scalar('SELECT unit_price FROM pur_receipt_detail WHERE pur_order_detail_id = ' + LineId.ToString)), 2.25));
      Check('order received (status 4)', Num(Scalar('SELECT status FROM pur_order WHERE id = ' + OrderId.ToString)) = PUR_ORD_RECEIVED);

      PD := PDSvc.FindById(FirstId('SELECT id FROM pur_receipt_detail WHERE pur_order_detail_id = ' + LineId.ToString), False);
      try
        PD.Quantity := 6;
        PDSvc.BusinessUpdate(PD, False, False, True);
      finally
        PD.Free;
      end;
      Check('receipt line reduced -> stock +6', Near(StockQty(Inv1), Qty1Before + 6));
      Check('order partial (status 3)', Num(Scalar('SELECT status FROM pur_order WHERE id = ' + OrderId.ToString)) = PUR_ORD_PARTIAL);
      Check('order received quantity', Near(Num(Scalar('SELECT received_quantity FROM pur_order_detail WHERE id = ' + LineId.ToString)), 6));

      // stok hareketleri ekranından değiştirilemez
      StId := FirstId('SELECT t.id FROM stk_transaction t JOIN pur_receipt_detail d ON d.id = t.pur_receipt_detail_id WHERE d.pur_receipt_id = ' + ReceiptId.ToString + ' LIMIT 1');
      St := StSvc.FindById(StId, False);
      try
        try
          StSvc.Delete(St.Id);
          Check('stock tx from receipt locked', False, 'delete allowed');
        except
          on E: Exception do Check('stock tx from receipt locked', Pos('mal kabul', AnsiLowerCase(E.Message)) > 0, E.Message);
        end;
      finally
        St.Free;
      end;

      // ---- mal kabulden fatura
      InvoiceId := FSvc.CreateFromReceipt(ReceiptId, '', True);
      Fi := FSvc.FindById(InvoiceId, False);
      try
        Check('invoice from receipt', Assigned(Fi) and (Fi.InvoiceNo = S(Scalar('SELECT receipt_no FROM pur_receipt WHERE id = ' + ReceiptId.ToString))), Fi.InvoiceNo);
        Check('invoice lines', Num(Scalar('SELECT count(*) FROM pur_invoice_detail WHERE pur_invoice_id = ' + InvoiceId.ToString)) = 2);
        Check('invoice uses order price/discount/vat', S(Scalar('SELECT f.unit_price || ''/'' || f.discount_rate || ''/'' || f.vat_rate || ''/'' || f.quantity FROM pur_invoice_detail f ' +
          'JOIN pur_receipt_detail d ON d.id = f.pur_receipt_detail_id WHERE d.pur_order_detail_id = ' + LineId.ToString)) = '2.500000/10.00/20.00/6.000000',
          S(Scalar('SELECT f.unit_price || ''/'' || f.discount_rate || ''/'' || f.vat_rate || ''/'' || f.quantity FROM pur_invoice_detail f JOIN pur_receipt_detail d ON d.id = f.pur_receipt_detail_id WHERE d.pur_order_detail_id = ' + LineId.ToString)));
        Check('invoice totals = sum of lines', Num(Scalar('SELECT count(*) FROM pur_invoice f WHERE f.id = ' + InvoiceId.ToString +
          ' AND f.total_amount = (SELECT sum(total_amount) FROM pur_invoice_detail WHERE pur_invoice_id = f.id) AND f.total_amount > 0')) = 1);
        Check('nothing left to invoice', Num(Scalar('SELECT sum(remaining_invoice_quantity) FROM vw_pur_receipt_detail WHERE pur_receipt_id = ' + ReceiptId.ToString)) = 0);

        // geri alma: fatura -> mal kabul -> sipariş taslağa -> iptal
        FSvc.BusinessDelete(Fi, False, False, True);
      finally
        Fi.Free;
      end;
      Rc := PSvc.FindById(ReceiptId, False);
      try
        PSvc.BusinessDelete(Rc, False, False, True);
      finally
        Rc.Free;
      end;
      Check('receipt delete -> stock back', Near(StockQty(Inv1), Qty1Before) and Near(StockQty(Inv3), Qty3Before));
      Check('receipt delete -> order approved', Num(Scalar('SELECT status FROM pur_order WHERE id = ' + OrderId.ToString)) = PUR_ORD_APPROVED);
      OSvc.ChangeStatus(OrderId, PUR_ORD_CANCELLED, True);
      Check('cancel order -> request reopened', (Num(Scalar('SELECT status FROM pur_request WHERE id = ' + Req.Id.ToString)) = PUR_REQ_APPROVED) and
        Near(Num(Scalar('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + Req.Id.ToString)), 0));
      End_;

      // ---- kural ihlalleri
      Begin_;
      Expect('approve request without lines', procedure
        var X: TPurRequest;
        begin
          X := NewRequest(RSvc);
          try RSvc.ChangeStatus(X.Id, PUR_REQ_APPROVED, True); finally X.Free; end;
        end);
      Begin_;
      Expect('line on approved request', procedure
        var X: TPurRequest;
        begin
          X := NewRequest(RSvc);
          try
            NewRequestLine(RDSvc, X.Id, Inv1, 1).Free;
            RSvc.ChangeStatus(X.Id, PUR_REQ_APPROVED, True);
            NewRequestLine(RDSvc, X.Id, Inv3, 1).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('duplicate stock on request', procedure
        var X: TPurRequest;
        begin
          X := NewRequest(RSvc);
          try
            NewRequestLine(RDSvc, X.Id, Inv1, 1).Free;
            NewRequestLine(RDSvc, X.Id, Inv1, 2).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('order from draft request', procedure
        var X: TPurRequest;
        begin
          X := NewRequest(RSvc);
          try
            NewRequestLine(RDSvc, X.Id, Inv1, 1).Free;
            OSvc.CreateFromRequest(X.Id, Supplier, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('discount 150', procedure
        var X: TPurOrder; L: TPurOrderDetail;
        begin
          X := NewOrder(OSvc, Supplier);
          L := TPurOrderDetail.Create;
          try
            L.PurOrderId := X.Id; L.StkInventoryId := Inv1; L.Quantity := 1; L.DiscountRate := 150;
            ODSvc.BusinessInsert(L, False, False, True);
          finally X.Free; L.Free; end;
        end);
      Begin_;
      Expect('duplicate line no', procedure
        var X: TPurOrder; L: TPurOrderDetail;
        begin
          X := NewOrder(OSvc, Supplier);
          NewOrderLine(ODSvc, X.Id, Inv1, 1, 1).Free;
          L := TPurOrderDetail.Create;
          try
            L.PurOrderId := X.Id; L.LineNo := 1; L.StkInventoryId := Inv3; L.Quantity := 1;
            ODSvc.BusinessInsert(L, False, False, True);
          finally X.Free; L.Free; end;
        end);
      Begin_;
      Expect('line on approved order', procedure
        var X: TPurOrder;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 1, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            NewOrderLine(ODSvc, X.Id, Inv3, 1, 1).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('manual status received', procedure
        var X: TPurOrder;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 1, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            OSvc.ChangeStatus(X.Id, PUR_ORD_RECEIVED, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('receipt for draft order', procedure
        var X: TPurOrder;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 1, 1).Free;
            PSvc.CreateFromOrder(X.Id, Scalar('SELECT min(id) FROM stk_warehouse'), True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('receipt of another supplier''s order', procedure
        var X: TPurOrder; R: TPurReceipt;
        begin
          X := NewOrder(OSvc, Supplier);
          R := TPurReceipt.Create;
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 1, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            R.AccAccountId := Supplier2; R.StkWarehouseId := Scalar('SELECT min(id) FROM stk_warehouse'); R.PurOrderId := X.Id;
            PSvc.BusinessInsert(R, False, False, True);
          finally X.Free; R.Free; end;
        end);
      Begin_;
      Expect('over receipt', procedure
        var X: TPurOrder; Rid: Int64; D: TPurReceiptDetail;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 10, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            Rid := PSvc.CreateFromOrder(X.Id, Scalar('SELECT min(id) FROM stk_warehouse'), True);
            D := PDSvc.FindById(FirstId('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + Rid.ToString), False);
            try
              D.Quantity := 11;
              PDSvc.BusinessUpdate(D, False, False, True);
            finally D.Free; end;
          finally X.Free; end;
        end);
      Begin_;
      Expect('reduce invoiced receipt line', procedure
        var X: TPurOrder; Rid: Int64; D: TPurReceiptDetail;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 10, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            Rid := PSvc.CreateFromOrder(X.Id, Scalar('SELECT min(id) FROM stk_warehouse'), True);
            FSvc.CreateFromReceipt(Rid, 'IT-F-1', True);
            D := PDSvc.FindById(FirstId('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + Rid.ToString), False);
            try
              D.Quantity := 5;
              PDSvc.BusinessUpdate(D, False, False, True);
            finally D.Free; end;
          finally X.Free; end;
        end);
      Begin_;
      Expect('delete invoiced receipt', procedure
        var X: TPurOrder; Rid: Int64; R: TPurReceipt;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 10, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            Rid := PSvc.CreateFromOrder(X.Id, Scalar('SELECT min(id) FROM stk_warehouse'), True);
            FSvc.CreateFromReceipt(Rid, 'IT-F-2', True);
            R := PSvc.FindById(Rid, False);
            try PSvc.BusinessDelete(R, False, False, True); finally R.Free; end;
          finally X.Free; end;
        end);
      Begin_;
      Expect('over invoice', procedure
        var X: TPurOrder; Rid, Fid: Int64; D: TPurInvoiceDetail;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 10, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            Rid := PSvc.CreateFromOrder(X.Id, Scalar('SELECT min(id) FROM stk_warehouse'), True);
            Fid := FSvc.CreateFromReceipt(Rid, 'IT-F-3', True);
            D := FDSvc.FindById(FirstId('SELECT id FROM pur_invoice_detail WHERE pur_invoice_id = ' + Fid.ToString), False);
            try
              D.Quantity := 11;
              FDSvc.BusinessUpdate(D, False, False, True);
            finally D.Free; end;
          finally X.Free; end;
        end);
      Begin_;
      Expect('duplicate invoice no', procedure
        var A, B: TPurInvoice;
        begin
          A := TPurInvoice.Create; B := TPurInvoice.Create;
          try
            A.InvoiceNo := 'IT-DUP'; A.AccAccountId := Supplier; FSvc.BusinessInsert(A, False, False, True);
            B.InvoiceNo := ' it-dup '; B.AccAccountId := Supplier; FSvc.BusinessInsert(B, False, False, True);
          finally A.Free; B.Free; end;
        end);
      Begin_;
      Expect('delete order with receipts', procedure
        var X: TPurOrder;
        begin
          X := NewOrder(OSvc, Supplier);
          try
            NewOrderLine(ODSvc, X.Id, Inv1, 10, 1).Free;
            OSvc.ChangeStatus(X.Id, PUR_ORD_APPROVED, True);
            PSvc.CreateFromOrder(X.Id, Scalar('SELECT min(id) FROM stk_warehouse'), True);
            OSvc.ChangeStatus(X.Id, PUR_ORD_CANCELLED, True);
          finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    Req.Free;
    StSvc.Free;
    FDSvc.Free; FSvc.Free; PDSvc.Free; PSvc.Free; ODSvc.Free; OSvc.Free; RDSvc.Free; RSvc.Free;
  end;
end;

procedure TestAccountTransactions;
var
  TxSvc: TAccAccountTransactionService;
  FSvc: TPurInvoiceService;
  FDSvc: TPurInvoiceDetailService;
  MSvc: TFinMoneyTransactionService;
  ASvc: TFinMoneyAccountService;
  NSvc: TFinChequeNoteService;
  F: TPurInvoice;
  FD: TPurInvoiceDetail;
  M: TFinMoneyTransaction;
  B: TFinMoneyAccount;
  N: TFinChequeNote;
  Filter: TFilterCriteria;
  Lst: TList<TAccAccountTransaction>;
  Row: TAccAccountTransaction;
  Acc: Int64;
  Opened: Integer;
  Obj: TObject;
  URepo: TSysUserRepository;
begin
  Ctx('Account', 'TAccAccountTransaction');
  Acc := Scalar('SELECT max(id) FROM acc_account');
  TxSvc := TAccAccountTransactionService.Create;
  FSvc := TPurInvoiceService.Create;
  FDSvc := TPurInvoiceDetailService.Create;
  MSvc := TFinMoneyTransactionService.Create;
  ASvc := TFinMoneyAccountService.Create;
  NSvc := TFinChequeNoteService.Create;
  try
    try
      Begin_;
      // alış faturası 1000 (alacak), banka ödemesi 400 (borç), verilen çek 250 (borç)
      F := TPurInvoice.Create;
      FD := TPurInvoiceDetail.Create;
      try
        F.InvoiceNo := 'IT-ATX-1'; F.AccAccountId := Acc;
        FSvc.BusinessInsert(F, False, False, True);
        FD.PurInvoiceId := F.Id; FD.StkInventoryId := Scalar('SELECT min(id) FROM stk_inventory'); FD.Quantity := 10; FD.UnitPrice := 100;
        FDSvc.BusinessInsert(FD, False, False, True);
      finally
        FD.Free;
      end;
      B := TFinMoneyAccount.Create;
      M := TFinMoneyTransaction.Create;
      N := TFinChequeNote.Create;
      try
        B.AccountKind := FIN_MONEY_BANK; B.Code := 'IT-ATX'; B.Name := 'IT ATX'; B.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
        ASvc.BusinessInsert(B, False, False, True);
        M.FinMoneyAccountId := B.Id; M.TransactionType := FIN_MONEY_TX_PAYMENT; M.AccAccountId := Acc; M.Amount := 400;
        M.TransferMethod := FIN_METHOD_EFT; M.DocumentNo := 'IT-EFT-1';
        MSvc.BusinessInsert(M, False, False, True);
        N.DocKind := FIN_DOC_CHEQUE; N.Direction := FIN_DIR_GIVEN; N.SerialNo := 'IT-ATX-C'; N.IssueDate := Date; N.DueDate := Date + 10;
        N.Amount := 250; N.AccAccountId := Acc; N.AccBankId := Scalar('SELECT min(id) FROM acc_bank');
        NSvc.BusinessInsert(N, False, False, True);

        Check('invoice -> credit', Near(Num(Scalar('SELECT credit FROM vw_acc_account_transaction WHERE source_type = 5 AND document_id = ' + F.Id.ToString)), 1000));
        Check('payment -> debit', Near(Num(Scalar('SELECT debit FROM vw_acc_account_transaction WHERE source_type = 1 AND document_id = ' + M.Id.ToString)), 400));
        Check('given cheque -> debit', Near(Num(Scalar('SELECT debit FROM vw_acc_account_transaction WHERE source_type = 2 AND document_id = ' + N.Id.ToString)), 250));
        Check('unique ids', Num(Scalar('SELECT count(*) - count(DISTINCT id) FROM vw_acc_account_transaction')) = 0);

        // servisten (yetki kontrollü) cari filtresiyle okuma + her satırın kaynağı kendi servisinden açılabilir
        Filter := TFilterCriteria.Create;
        try
          Filter.Add(TFilterCriterion.New('acc_account_id', '=', TValue.From<Int64>(Acc)));
          Lst := TxSvc.BusinessFind(Filter, False, False, True);
          try
            Check('list by account', Lst.Count >= 3, IntToStr(Lst.Count));
            Opened := 0;
            for Row in Lst do
            begin
              Obj := nil;
              case Row.SourceType of
                ACC_TX_SRC_MONEY: Obj := MSvc.BusinessFindById(Row.DocumentId, False, False, True);
                ACC_TX_SRC_CHEQUE_NOTE: Obj := NSvc.BusinessFindById(Row.DocumentId, False, False, True);
                ACC_TX_SRC_PUR_INVOICE: Obj := FSvc.BusinessFindById(Row.DocumentId, False, False, True);
              else
                Inc(Opened);  // POS / kredi kartı: bu testte üretilmedi
                Continue;
              end;
              if Assigned(Obj) then
                Inc(Opened);
              Obj.Free;
            end;
            Check('every source document resolvable', Opened = Lst.Count, Format('%d / %d', [Opened, Lst.Count]));
          finally
            Lst.Free;
          end;
        finally
          Filter.Free;
        end;
        Check('running balance', Near(Num(Scalar('SELECT balance FROM vw_acc_account_transaction WHERE acc_account_id = ' + Acc.ToString +
          ' AND currency = fn_default_currency() ORDER BY transaction_date DESC, id DESC LIMIT 1')),
          Num(Scalar('SELECT sum(debit - credit) FROM vw_acc_account_transaction WHERE acc_account_id = ' + Acc.ToString + ' AND currency = fn_default_currency()'))));
      finally
        B.Free; M.Free; N.Free; F.Free;
      end;
      End_;

      // yetki: TEST kullanıcısı (id 4) alış faturasını okuyamaz (deny), para hareketini okuyabilir (is_read)
      Begin_;
      F := TPurInvoice.Create;
      M := TFinMoneyTransaction.Create;
      B := TFinMoneyAccount.Create;
      URepo := TSysUserRepository.Create(UoW.Connection);
      try
        F.InvoiceNo := 'IT-ATX-2'; F.AccAccountId := Acc;
        FSvc.BusinessInsert(F, False, False, True);
        B.AccountKind := FIN_MONEY_CASH; B.Code := 'IT-ATX-K'; B.Name := 'IT ATX K';
        ASvc.BusinessInsert(B, False, False, True);
        M.FinMoneyAccountId := B.Id; M.TransactionType := FIN_MONEY_TX_COLLECTION; M.AccAccountId := Acc; M.Amount := 10;
        MSvc.BusinessInsert(M, False, False, True);
        UoW.Connection.ExecSQL('UPDATE sys_access_right a SET deny_read = true, is_read = false FROM sys_permission p ' +
          'WHERE p.id = a.sys_permission_id AND a.sys_user_id = 4 AND p.permission_code = 1083');
        UoW.Connection.ExecSQL('UPDATE sys_access_right a SET is_read = true, deny_read = false FROM sys_permission p ' +
          'WHERE p.id = a.sys_permission_id AND a.sys_user_id = 4 AND p.permission_code IN (1038, 1074)');
        TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(4), False);
        try
          try
            FSvc.BusinessFindById(F.Id, False, False, True).Free;
            Check('source without read right is refused', False, 'opened');
          except
            on E: Exception do Check('source without read right is refused', True, E.ClassName + ': ' + E.Message);
          end;
          try
            Obj := MSvc.BusinessFindById(M.Id, False, False, True);
            Check('source with read right opens', Assigned(Obj));
            Obj.Free;
          except
            on E: Exception do Check('source with read right opens', False, E.Message);
          end;
        finally
          TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(1), False);
        end;
      finally
        URepo.Free; F.Free; M.Free; B.Free;
      end;
      End_;

      Begin_;
      Expect('read-only', procedure
        var X: TAccAccountTransaction;
        begin
          X := TAccAccountTransaction.Create;
          try TxSvc.BusinessInsert(X, False, False, True); finally X.Free; end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    NSvc.Free; ASvc.Free; MSvc.Free; FDSvc.Free; FSvc.Free; TxSvc.Free;
  end;
end;

function KpiKeys(const AKpis: TArray<TDashboardKpi>): string;
var
  K: TDashboardKpi;
begin
  Result := '';
  for K in AKpis do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + K.Key;
  end;
end;

function ChartKeys(const ACharts: TArray<TDashboardChart>): string;
var
  C: TDashboardChart;
begin
  Result := '';
  for C in ACharts do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + C.Key;
  end;
end;

// Noktalar ardışık ve artan tarihli mi (AStepDays = 0: yalnız artan)
function PointsOrdered(const APoints: TArray<TDashboardPoint>; AStepDays: Integer): Boolean;
var
  I: Integer;
begin
  for I := 1 to High(APoints) do
    if (AStepDays > 0) and (Round(APoints[I].Day - APoints[I - 1].Day) <> AStepDays) or
       (AStepDays = 0) and (APoints[I].Day <= APoints[I - 1].Day) then
      Exit(False);
  Result := True;
end;

procedure TestDashboard;
var
  Svc: TSysDashboardService;
  Kpis: TArray<TDashboardKpi>;
  K: TDashboardKpi;
  Charts: TArray<TDashboardChart>;
  C: TDashboardChart;
  URepo: TSysUserRepository;
  Found, RatiosOk: Boolean;
begin
  Ctx('System', 'TSysDashboard');
  Svc := TSysDashboardService.Create;
  URepo := TSysUserRepository.Create(UoW.Connection);
  try
    try
      Begin_;
      // süper kullanıcı: tüm göstergeler hatasız (bir sorgu hata verirse liste eksik kalır)
      Kpis := Svc.GetKpis;
      Check('super user: all 23 kpis', Length(Kpis) = 23, IntToStr(Length(Kpis)) + ': ' + KpiKeys(Kpis));
      Found := False;
      for K in Kpis do
        if K.Key = KPI_FX_RATES then
        begin
          Found := True;
          Check('fx: one rate per currency', K.Count = Num(Scalar('SELECT count(DISTINCT currency) FROM acc_exchange_rate')),
            IntToStr(K.Count));
        end
        else if K.Key = KPI_STOCK_CARDS then
          Check('stock cards count', K.Count = Num(Scalar('SELECT count(*) FROM stk_inventory')))
        else if K.Key = KPI_USERS then
          Check('active users', K.Count = Num(Scalar('SELECT count(*) FROM sys_user WHERE active')));
      Check('fx kpi present', Found);

      // kart oranları 0..1 (veya -1 = yok), trend serileri
      RatiosOk := True;
      for K in Kpis do
      begin
        if (K.Ratio > 1) or ((K.Ratio < 0) and (K.Ratio <> -1)) then
          RatiosOk := False;
        if MatchStr(K.Key, [KPI_MONEY_TODAY, KPI_STOCK_TX_TODAY]) then
          Check('trend 14 days: ' + K.Key, (Length(K.Trend) = DASHBOARD_TREND_DAYS) and PointsOrdered(K.Trend, 1)
            and (Round(K.Trend[High(K.Trend)].Day) = Round(Date)), IntToStr(Length(K.Trend)));
        if K.Key = KPI_FX_RATES then
          Check('fx trend ordered', (Length(K.Trend) > 1) and (Length(K.Trend) <= DASHBOARD_TREND_DAYS)
            and PointsOrdered(K.Trend, 0), IntToStr(Length(K.Trend)));
        if K.Key = KPI_STOCK_TX_TODAY then
          Check('stock trend today = kpi count', Round(K.Trend[High(K.Trend)].Value) = K.Count);
      end;
      Check('kpi ratios in range', RatiosOk);

      // genel bakış grafikleri
      Charts := Svc.GetCharts;
      Check('super user: all 4 charts', ChartKeys(Charts) = CHART_MONEY_FLOW + ',' + CHART_CHEQUE_DUE + ',' +
        CHART_STOCK_FLOW + ',' + CHART_FX_TREND, ChartKeys(Charts));
      for C in Charts do
        if MatchStr(C.Key, [CHART_MONEY_FLOW, CHART_STOCK_FLOW]) then
          Check('chart 14 days: ' + C.Key, (Length(C.Points) = DASHBOARD_TREND_DAYS) and PointsOrdered(C.Points, 1)
            and (Round(C.Points[High(C.Points)].Day) = Round(Date)), IntToStr(Length(C.Points)))
        else if C.Key = CHART_CHEQUE_DUE then
          Check('cheque chart: 8 weeks from monday', (Length(C.Points) = 8) and PointsOrdered(C.Points, 7)
            and (DayOfTheWeek(C.Points[0].Day) = 1) and (C.Points[0].Day <= Date) and (C.Points[0].Day > Date - 7),
            IntToStr(Length(C.Points)))
        else if C.Key = CHART_FX_TREND then
          Check('fx chart: last point = latest USD rate', (Length(C.Points) > 0) and (Length(C.Points) <= 30)
            and PointsOrdered(C.Points, 0) and SameValue(C.Points[High(C.Points)].Value,
            Num(Scalar('SELECT rate FROM acc_exchange_rate WHERE currency = ''USD'' ORDER BY rate_date DESC, id DESC LIMIT 1')), 0.00001),
            IntToStr(Length(C.Points)));
      for C in Charts do
        if C.Key = CHART_MONEY_FLOW then
          Check('money chart currency = default', C.Currency = Scalar('SELECT public.fn_default_currency()'), C.Currency);

      // TEST (id 4): yalnız kur + satın alma siparişi okuma; diğer her şey engelli
      UoW.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = true, is_read = false WHERE sys_user_id = 4');
      UoW.Connection.ExecSQL('UPDATE sys_access_right a SET deny_read = false, is_read = true FROM sys_permission p ' +
        'WHERE p.id = a.sys_permission_id AND a.sys_user_id = 4 AND p.permission_code IN (3001, 1081)');
      TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(4), False);
      try
        Kpis := Svc.GetKpis;
        Check('limited user: only permitted kpis', KpiKeys(Kpis) = KPI_FX_RATES + ',' + KPI_PUR_ORDERS_OPEN + ',' + KPI_PUR_ORDERS_MONTH,
          KpiKeys(Kpis));
        Charts := Svc.GetCharts;
        Check('limited user: only permitted charts', ChartKeys(Charts) = CHART_FX_TREND, ChartKeys(Charts));
        UoW.Connection.ExecSQL('UPDATE sys_access_right SET deny_read = true, is_read = false WHERE sys_user_id = 4');
        Kpis := Svc.GetKpis;
        Check('no rights: no kpis', Length(Kpis) = 0, KpiKeys(Kpis));
        Check('no rights: no charts', Length(Svc.GetCharts) = 0);
      finally
        TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(1), False);
      end;
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    URepo.Free;
    Svc.Free;
  end;
end;

{ ---------------------------------------------------------------- Sales }

function NewOffer(ASvc: TSlsOfferService; AAccount: Int64): TSlsOffer;
begin
  Result := TSlsOffer.Create;
  Result.AccAccountId := AAccount;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewOfferLine(ASvc: TSlsOfferDetailService; AOffer, AInv: Int64; AQty, APrice, ADisc, AVat: Currency): TSlsOfferDetail;
begin
  Result := TSlsOfferDetail.Create;
  Result.SlsOfferId := AOffer;
  Result.StkInventoryId := AInv;
  Result.Quantity := AQty;
  Result.UnitPrice := APrice;
  Result.DiscountRate := ADisc;
  Result.VatRate := AVat;
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewSlsOrder(ASvc: TSlsOrderService; AAccount: Int64): TSlsOrder;
begin
  Result := TSlsOrder.Create;
  Result.AccAccountId := AAccount;
  Result.StkWarehouseId := Scalar('SELECT min(id) FROM stk_warehouse');
  ASvc.BusinessInsert(Result, False, False, True);
end;

function NewSlsOrderLine(ASvc: TSlsOrderDetailService; AOrder, AInv: Int64; AQty, APrice: Currency): TSlsOrderDetail;
begin
  Result := TSlsOrderDetail.Create;
  Result.SlsOrderId := AOrder;
  Result.StkInventoryId := AInv;
  Result.Quantity := AQty;
  Result.UnitPrice := APrice;
  Result.VatRate := 20;   // tanımlı KDV oranı (acc_set_tax_rate)
  ASvc.BusinessInsert(Result, False, False, True);
end;

// Onaylı, tek kalemli sipariş (kural testleri için)
function ApprovedSlsOrder(OSvc: TSlsOrderService; ODSvc: TSlsOrderDetailService; AAccount, AInv: Int64; AQty: Currency): Int64;
var
  X: TSlsOrder;
begin
  X := NewSlsOrder(OSvc, AAccount);
  try
    NewSlsOrderLine(ODSvc, X.Id, AInv, AQty, 1).Free;
    OSvc.ChangeStatus(X.Id, SLS_ORD_APPROVED, True);
    Result := X.Id;
  finally
    X.Free;
  end;
end;

procedure TestSales;
var
  FfSvc: TSlsOfferService;
  FfDSvc: TSlsOfferDetailService;
  OSvc: TSlsOrderService;
  ODSvc: TSlsOrderDetailService;
  PSvc: TSlsDispatchService;
  PDSvc: TSlsDispatchDetailService;
  FSvc: TSlsInvoiceService;
  FDSvc: TSlsInvoiceDetailService;
  StSvc: TStkTransactionService;
  Off: TSlsOffer;
  PD: TSlsDispatchDetail;
  Inv1, Inv3, Customer, Customer2, Wh, OrderId, DispatchId, InvoiceId, Invoice2Id, LineId, StId: Int64;
  Qty1Before, Qty3Before: Double;
  St: TStkTransaction;
  Fi: TSlsInvoice;
  Dp: TSlsDispatch;
begin
  Ctx('Sales', 'flow');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv3 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Customer := Scalar('SELECT min(id) FROM acc_account');
  Customer2 := Scalar('SELECT max(id) FROM acc_account');
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  FfSvc := TSlsOfferService.Create;
  FfDSvc := TSlsOfferDetailService.Create;
  OSvc := TSlsOrderService.Create;
  ODSvc := TSlsOrderDetailService.Create;
  PSvc := TSlsDispatchService.Create;
  PDSvc := TSlsDispatchDetailService.Create;
  FSvc := TSlsInvoiceService.Create;
  FDSvc := TSlsInvoiceDetailService.Create;
  StSvc := TStkTransactionService.Create;
  Off := nil;
  try
    try
      Begin_;
      Qty1Before := StockQty(Inv1);
      Qty3Before := StockQty(Inv3);

      // ---- teklif: 10 x 2,50 = 25,00; %10 iskonto 2,50; net 22,50; %20 KDV 4,50; toplam 27,00
      Off := NewOffer(FfSvc, Customer);
      Check('offer insert', StartsText('ST', Off.OfferNo) and (Length(Off.OfferNo) = 8), Off.OfferNo);
      NewOfferLine(FfDSvc, Off.Id, Inv1, 10, 2.5, 10, 20).Free;
      NewOfferLine(FfDSvc, Off.Id, Inv3, 5, 4, 0, 10).Free;
      Check('offer line amounts', S(Scalar('SELECT gross_amount || ''/'' || discount_amount || ''/'' || net_amount || ''/'' || vat_amount || ''/'' || total_amount ' +
        'FROM sls_offer_detail WHERE sls_offer_id = ' + Off.Id.ToString + ' AND stk_inventory_id = ' + Inv1.ToString)) = '25.00/2.50/22.50/4.50/27.00');
      Check('offer totals = sum of lines', Num(Scalar('SELECT total_amount FROM sls_offer WHERE id = ' + Off.Id.ToString)) = 27 + 22);
      FfSvc.ChangeStatus(Off.Id, SLS_OFF_SENT, True);
      Check('offer sent', Num(Scalar('SELECT status FROM sls_offer WHERE id = ' + Off.Id.ToString)) = SLS_OFF_SENT);

      // ---- tekliften sipariş
      OrderId := OSvc.CreateFromOffer(Off.Id, True);
      Check('order from offer', StartsText('SS', S(Scalar('SELECT order_no FROM sls_order WHERE id = ' + OrderId.ToString))) and
        (Num(Scalar('SELECT count(*) FROM sls_order_detail WHERE sls_order_id = ' + OrderId.ToString)) = 2));
      Check('order customer = offer customer', FirstId('SELECT acc_account_id FROM sls_order WHERE id = ' + OrderId.ToString) = Customer);
      Check('offer prices copied', S(Scalar('SELECT unit_price || ''/'' || discount_rate || ''/'' || vat_rate FROM sls_order_detail WHERE sls_order_id = ' +
        OrderId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString)) = '2.500000/10.00/20.00');
      Check('order totals = offer totals', Num(Scalar('SELECT total_amount FROM sls_order WHERE id = ' + OrderId.ToString)) = 49);
      Check('offer ordered (status 4)', Num(Scalar('SELECT status FROM sls_offer WHERE id = ' + Off.Id.ToString)) = SLS_OFF_ORDERED);
      Check('offer ordered quantity', Near(Num(Scalar('SELECT sum(ordered_quantity) FROM sls_offer_detail WHERE sls_offer_id = ' + Off.Id.ToString)), 15));
      LineId := FirstId('SELECT id FROM sls_order_detail WHERE sls_order_id = ' + OrderId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      OSvc.ChangeStatus(OrderId, SLS_ORD_APPROVED, True);

      // ---- siparişten sevk irsaliyesi (stok çıkışı)
      DispatchId := PSvc.CreateFromOrder(OrderId, Wh, True);
      Check('dispatch from order', StartsText('SI', S(Scalar('SELECT dispatch_no FROM sls_dispatch WHERE id = ' + DispatchId.ToString))) and
        (Num(Scalar('SELECT count(*) FROM sls_dispatch_detail WHERE sls_dispatch_id = ' + DispatchId.ToString)) = 2));
      Check('stock out transactions', Num(Scalar('SELECT count(*) FROM stk_transaction t JOIN sls_dispatch_detail d ON d.id = t.sls_dispatch_detail_id ' +
        'WHERE d.sls_dispatch_id = ' + DispatchId.ToString + ' AND t.transaction_type = 2 AND t.from_stk_warehouse_id = ' + Wh.ToString)) = 2);
      Check('stock summary -10 / -5', Near(StockQty(Inv1), Qty1Before - 10) and Near(StockQty(Inv3), Qty3Before - 5),
        Format('%g -> %g', [Qty1Before, StockQty(Inv1)]));
      Check('dispatch price = net price', Near(Num(Scalar('SELECT unit_price FROM sls_dispatch_detail WHERE sls_order_detail_id = ' + LineId.ToString)), 2.25));
      Check('order delivered (status 4)', Num(Scalar('SELECT status FROM sls_order WHERE id = ' + OrderId.ToString)) = SLS_ORD_DELIVERED);

      PD := PDSvc.FindById(FirstId('SELECT id FROM sls_dispatch_detail WHERE sls_order_detail_id = ' + LineId.ToString), False);
      try
        PD.Quantity := 6;
        PDSvc.BusinessUpdate(PD, False, False, True);
      finally
        PD.Free;
      end;
      Check('dispatch line reduced -> stock -6', Near(StockQty(Inv1), Qty1Before - 6));
      Check('order partial (status 3)', Num(Scalar('SELECT status FROM sls_order WHERE id = ' + OrderId.ToString)) = SLS_ORD_PARTIAL);
      Check('order delivered quantity', Near(Num(Scalar('SELECT delivered_quantity FROM sls_order_detail WHERE id = ' + LineId.ToString)), 6));

      // stok hareketleri ekranından değiştirilemez
      StId := FirstId('SELECT t.id FROM stk_transaction t JOIN sls_dispatch_detail d ON d.id = t.sls_dispatch_detail_id WHERE d.sls_dispatch_id = ' + DispatchId.ToString + ' LIMIT 1');
      St := StSvc.FindById(StId, False);
      try
        try
          StSvc.Delete(St.Id);
          Check('stock tx from dispatch locked', False, 'delete allowed');
        except
          on E: Exception do Check('stock tx from dispatch locked', Pos('irsaliye', AnsiLowerCase(E.Message)) > 0, E.Message);
        end;
      finally
        St.Free;
      end;

      // ---- siparişin kalanından irsaliyeli fatura (stok faturadan düşer)
      Invoice2Id := FSvc.CreateFromOrder(OrderId, Wh, True);
      Check('invoice from order', StartsText('SF', S(Scalar('SELECT invoice_no FROM sls_invoice WHERE id = ' + Invoice2Id.ToString))) and
        (S(Scalar('SELECT count(*) || ''/'' || sum(quantity)::numeric(18,2) FROM sls_invoice_detail WHERE sls_invoice_id = ' + Invoice2Id.ToString)) = '1/4.00'),
        S(Scalar('SELECT count(*) || ''/'' || sum(quantity)::numeric(18,2) FROM sls_invoice_detail WHERE sls_invoice_id = ' + Invoice2Id.ToString)));
      Check('invoice with delivery -> stock -10', Near(StockQty(Inv1), Qty1Before - 10));
      Check('invoice stock tx', Num(Scalar('SELECT count(*) FROM stk_transaction t JOIN sls_invoice_detail d ON d.id = t.sls_invoice_detail_id ' +
        'WHERE d.sls_invoice_id = ' + Invoice2Id.ToString + ' AND t.transaction_type = 2')) = 1);
      Check('order delivered again (status 4)', Num(Scalar('SELECT status FROM sls_order WHERE id = ' + OrderId.ToString)) = SLS_ORD_DELIVERED);

      // ---- irsaliyeden fatura
      InvoiceId := FSvc.CreateFromDispatch(DispatchId, True);
      Fi := FSvc.FindById(InvoiceId, False);
      try
        Check('invoice from dispatch', Assigned(Fi) and StartsText('SF', Fi.InvoiceNo) and (Fi.InvoiceNo <> S(Scalar('SELECT invoice_no FROM sls_invoice WHERE id = ' + Invoice2Id.ToString))), Fi.InvoiceNo);
        Check('invoice lines', Num(Scalar('SELECT count(*) FROM sls_invoice_detail WHERE sls_invoice_id = ' + InvoiceId.ToString)) = 2);
        Check('no stock tx for dispatch invoice', Num(Scalar('SELECT count(*) FROM stk_transaction t JOIN sls_invoice_detail d ON d.id = t.sls_invoice_detail_id ' +
          'WHERE d.sls_invoice_id = ' + InvoiceId.ToString)) = 0);
        Check('stock unchanged by dispatch invoice', Near(StockQty(Inv1), Qty1Before - 10));
        Check('invoice uses order price/discount/vat', S(Scalar('SELECT f.unit_price || ''/'' || f.discount_rate || ''/'' || f.vat_rate || ''/'' || f.quantity FROM sls_invoice_detail f ' +
          'JOIN sls_dispatch_detail d ON d.id = f.sls_dispatch_detail_id WHERE d.sls_order_detail_id = ' + LineId.ToString)) = '2.500000/10.00/20.00/6.000000');
        Check('invoice totals = sum of lines', Num(Scalar('SELECT count(*) FROM sls_invoice f WHERE f.id = ' + InvoiceId.ToString +
          ' AND f.total_amount = (SELECT sum(total_amount) FROM sls_invoice_detail WHERE sls_invoice_id = f.id) AND f.total_amount > 0')) = 1);
        Check('nothing left to invoice', Num(Scalar('SELECT sum(remaining_invoice_quantity) FROM vw_sls_dispatch_detail WHERE sls_dispatch_id = ' + DispatchId.ToString)) = 0);
        Check('account transaction (debit)', Num(Scalar('SELECT count(*) FROM vw_acc_account_transaction t JOIN sls_invoice f ON f.id = t.document_id ' +
          'WHERE t.source_type = ' + IntToStr(ACC_TX_SRC_SLS_INVOICE) + ' AND f.id IN (' + InvoiceId.ToString + ', ' + Invoice2Id.ToString + ') ' +
          '  AND t.debit = f.total_amount AND t.credit = 0 AND t.acc_account_id = ' + Customer.ToString)) = 2);
        Check('source text', TAccLookup.Text(alkTxSource, ACC_TX_SRC_SLS_INVOICE) <> '');

        // geri alma: faturalar -> irsaliye -> sipariş iptal -> teklif yeniden açık
        FSvc.BusinessDelete(Fi, False, False, True);
      finally
        Fi.Free;
      end;
      Fi := FSvc.FindById(Invoice2Id, False);
      try
        FSvc.BusinessDelete(Fi, False, False, True);
      finally
        Fi.Free;
      end;
      Check('invoice delete -> stock back to -6', Near(StockQty(Inv1), Qty1Before - 6));
      Check('invoice delete -> order partial', Num(Scalar('SELECT status FROM sls_order WHERE id = ' + OrderId.ToString)) = SLS_ORD_PARTIAL);
      Dp := PSvc.FindById(DispatchId, False);
      try
        PSvc.BusinessDelete(Dp, False, False, True);
      finally
        Dp.Free;
      end;
      Check('dispatch delete -> stock back', Near(StockQty(Inv1), Qty1Before) and Near(StockQty(Inv3), Qty3Before));
      Check('dispatch delete -> order approved', Num(Scalar('SELECT status FROM sls_order WHERE id = ' + OrderId.ToString)) = SLS_ORD_APPROVED);
      OSvc.ChangeStatus(OrderId, SLS_ORD_CANCELLED, True);
      Check('cancel order -> offer reopened', (Num(Scalar('SELECT status FROM sls_offer WHERE id = ' + Off.Id.ToString)) = SLS_OFF_SENT) and
        Near(Num(Scalar('SELECT sum(ordered_quantity) FROM sls_offer_detail WHERE sls_offer_id = ' + Off.Id.ToString)), 0));
      End_;

      // ---- kural ihlalleri
      Begin_;
      Expect('send offer without lines', procedure
        var X: TSlsOffer;
        begin
          X := NewOffer(FfSvc, Customer);
          try FfSvc.ChangeStatus(X.Id, SLS_OFF_SENT, True); finally X.Free; end;
        end);
      Begin_;
      Expect('line on sent offer', procedure
        var X: TSlsOffer;
        begin
          X := NewOffer(FfSvc, Customer);
          try
            NewOfferLine(FfDSvc, X.Id, Inv1, 1, 1, 0, 20).Free;
            FfSvc.ChangeStatus(X.Id, SLS_OFF_SENT, True);
            NewOfferLine(FfDSvc, X.Id, Inv3, 1, 1, 0, 20).Free;
          finally X.Free; end;
        end);
      Begin_;
      Expect('order from draft offer', procedure
        var X: TSlsOffer;
        begin
          X := NewOffer(FfSvc, Customer);
          try
            NewOfferLine(FfDSvc, X.Id, Inv1, 1, 1, 0, 20).Free;
            OSvc.CreateFromOffer(X.Id, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('offer valid until before date', procedure
        var X: TSlsOffer;
        begin
          X := TSlsOffer.Create;
          try
            X.AccAccountId := Customer; X.OfferDate := Date; X.ValidUntil := Date - 1;
            FfSvc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('manual status delivered', procedure
        var Oid: Int64;
        begin
          Oid := ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 1);
          OSvc.ChangeStatus(Oid, SLS_ORD_DELIVERED, True);
        end);
      Begin_;
      Expect('dispatch for draft order', procedure
        var X: TSlsOrder;
        begin
          X := NewSlsOrder(OSvc, Customer);
          try
            NewSlsOrderLine(ODSvc, X.Id, Inv1, 1, 1).Free;
            PSvc.CreateFromOrder(X.Id, Wh, True);
          finally X.Free; end;
        end);
      Begin_;
      Expect('dispatch of another customer''s order', procedure
        var Oid: Int64; R: TSlsDispatch;
        begin
          Oid := ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 1);
          R := TSlsDispatch.Create;
          try
            R.AccAccountId := Customer2; R.StkWarehouseId := Wh; R.SlsOrderId := Oid;
            PSvc.BusinessInsert(R, False, False, True);
          finally R.Free; end;
        end);
      Begin_;
      Expect('over delivery (dispatch)', procedure
        var Did: Int64; D: TSlsDispatchDetail;
        begin
          Did := PSvc.CreateFromOrder(ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 10), Wh, True);
          D := PDSvc.FindById(FirstId('SELECT id FROM sls_dispatch_detail WHERE sls_dispatch_id = ' + Did.ToString), False);
          try
            D.Quantity := 11;
            PDSvc.BusinessUpdate(D, False, False, True);
          finally D.Free; end;
        end);
      Begin_;
      Expect('over delivery (dispatch + invoice)', procedure
        var Oid, Fid: Int64; D: TSlsInvoiceDetail;
        begin
          Oid := ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 10);
          Fid := FSvc.CreateFromOrder(Oid, Wh, True);
          D := FDSvc.FindById(FirstId('SELECT id FROM sls_invoice_detail WHERE sls_invoice_id = ' + Fid.ToString), False);
          try
            D.Quantity := 5;
            FDSvc.BusinessUpdate(D, False, False, True);
          finally D.Free; end;
          // 5 faturada, kalan 5'ten fazlası irsaliyeye eklenemez
          PSvc.CreateFromOrder(Oid, Wh, True);
          D := FDSvc.FindById(FirstId('SELECT id FROM sls_invoice_detail WHERE sls_invoice_id = ' + Fid.ToString), False);
          try
            D.Quantity := 6;
            FDSvc.BusinessUpdate(D, False, False, True);
          finally D.Free; end;
        end);
      Begin_;
      Expect('invoice line without warehouse', procedure
        var A: TSlsInvoice; L: TSlsInvoiceDetail;
        begin
          A := TSlsInvoice.Create; L := TSlsInvoiceDetail.Create;
          try
            A.AccAccountId := Customer; FSvc.BusinessInsert(A, False, False, True);
            L.SlsInvoiceId := A.Id; L.StkInventoryId := Inv1; L.Quantity := 1; L.UnitPrice := 1; L.VatRate := 20;
            FDSvc.BusinessInsert(L, False, False, True);
          finally A.Free; L.Free; end;
        end);
      Begin_;
      Expect('clear warehouse of invoice with stock lines', procedure
        var Fid: Int64; A: TSlsInvoice;
        begin
          Fid := FSvc.CreateFromOrder(ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 2), Wh, True);
          A := FSvc.FindById(Fid, False);
          try
            A.StkWarehouseId := 0;
            FSvc.BusinessUpdate(A, False, False, True);
          finally A.Free; end;
        end);
      Begin_;
      Expect('over invoice (dispatch)', procedure
        var Did, Fid: Int64; D: TSlsInvoiceDetail;
        begin
          Did := PSvc.CreateFromOrder(ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 10), Wh, True);
          Fid := FSvc.CreateFromDispatch(Did, True);
          D := FDSvc.FindById(FirstId('SELECT id FROM sls_invoice_detail WHERE sls_invoice_id = ' + Fid.ToString), False);
          try
            D.Quantity := 11;
            FDSvc.BusinessUpdate(D, False, False, True);
          finally D.Free; end;
        end);
      Begin_;
      Expect('delete invoiced dispatch', procedure
        var Did: Int64; R: TSlsDispatch;
        begin
          Did := PSvc.CreateFromOrder(ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 10), Wh, True);
          FSvc.CreateFromDispatch(Did, True);
          R := PSvc.FindById(Did, False);
          try PSvc.BusinessDelete(R, False, False, True); finally R.Free; end;
        end);
      Begin_;
      Expect('duplicate invoice no', procedure
        var A, B: TSlsInvoice;
        begin
          A := TSlsInvoice.Create; B := TSlsInvoice.Create;
          try
            A.InvoiceNo := 'IT-SDUP'; A.AccAccountId := Customer; FSvc.BusinessInsert(A, False, False, True);
            B.InvoiceNo := ' it-sdup '; B.AccAccountId := Customer2; FSvc.BusinessInsert(B, False, False, True);
          finally A.Free; B.Free; end;
        end);
      Begin_;
      Expect('cancel order with deliveries', procedure
        var Oid: Int64;
        begin
          Oid := ApprovedSlsOrder(OSvc, ODSvc, Customer, Inv1, 10);
          FSvc.CreateFromOrder(Oid, Wh, True);
          OSvc.ChangeStatus(Oid, SLS_ORD_CANCELLED, True);
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    Off.Free;
    StSvc.Free;
    FDSvc.Free; FSvc.Free; PDSvc.Free; PSvc.Free; ODSvc.Free; OSvc.Free; FfDSvc.Free; FfSvc.Free;
  end;
end;

// Teklif belgesi (başlık + Lines) form olmadan: TSlsOfferService NewLine / RemoveLine / Recalculate / PrepareCopy +
// BusinessSaveWithDetails (tek transaction, DetailList durum modeli: Id > 0 güncelle, Deleted sil, Id < 0 ekle),
// BusinessFindById kalemleri getirir, kayıt sonrası Reload. Commit yok (AWithCommit = False): test transaction'ı geri alınır.
// TCMB bülteni (ayrıştırma, cuma -> cumartesi / pazar, elle girilen kur korunur), kur fonksiyonu, teklif kurları ve
// belgeye ait ayrıntılı adres (kopya, düzenleme, temizleme, yalnız başlık güncellemesi, kopya belge, silme)
// Para birimi değişimi: kalem fiyatları kurla çevrilir, fiyat hanesine (sys_decimal_place.price) yuvarlanır
// (bellekte; kurlar ve hane ayarı transaction içinde değişip geri alınır)
procedure TestSalesOfferCurrencyChange;
var
  Svc: TSlsOfferService;
  Off: TSlsOffer;
  Line: TSlsOfferDetail;
  Base: string;
begin
  Ctx('Sales', 'offer currency');
  Svc := TSlsOfferService.Create;
  Off := TSlsOffer.Create;
  try
    try
      Begin_;
      Base := S(Scalar('SELECT public.fn_default_currency()'));
      UoW.Connection.ExecSQL('INSERT INTO acc_exchange_rate (rate_date, rate, currency) VALUES ' +
        '(''2032-03-03'', 49.4889, ''USD''), (''2032-03-03'', 57.1234, ''EUR'')');
      UoW.Connection.ExecSQL('UPDATE sys_decimal_place SET price = 4, total = 2');
      TDecimalPlaces.Invalidate;
      Off.OfferDate := EncodeDate(2032, 3, 3);
      Off.BaseCurrency := Base;
      Off.Currency := Base;
      Off.ExchangeRate := 1;
      Line := TSlsOfferDetail.Create;
      Line.Quantity := 2;
      Line.UnitPrice := 1000;
      Line.VatRate := 20;
      Line.HeaderEntity := Off;
      Off.Lines.Add(Line);

      Svc.ChangeCurrency(Off, 'USD', 1);
      Check(Base + ' -> USD: 1000 / 49.4889', Near(Line.UnitPrice, 20.2066), CurrToStr(Line.UnitPrice));
      Check('document rate = USD rate', (Off.Currency = 'USD') and Near(Off.ExchangeRate, 49.4889), CurrToStr(Off.ExchangeRate));
      Check('line + totals recalculated', Near(Line.GrossAmount, 40.41) and Near(Line.VatAmount, 8.08) and
        Near(Off.TotalAmount, 48.49) and (Line.Currency = 'USD'), CurrToStr(Off.TotalAmount));

      Svc.ChangeCurrency(Off, 'EUR', Off.ExchangeRate);
      Check('USD -> EUR (cross via base)', Near(Line.UnitPrice, 17.506) and Near(Off.ExchangeRate, 57.1234), CurrToStr(Line.UnitPrice));

      Svc.ChangeCurrency(Off, Base, Off.ExchangeRate);
      Check('EUR -> ' + Base + ' (round trip within 0.01)', Near(Line.UnitPrice, 1000.0022) and Near(Off.ExchangeRate, 1),
        CurrToStr(Line.UnitPrice));

      // ekranda elle değiştirilen kur kullanılır
      Svc.ChangeCurrency(Off, 'USD', 1);
      Svc.ChangeCurrency(Off, Base, 50);
      Check('user-entered old rate (50)', Near(Line.UnitPrice, 1010.33), CurrToStr(Line.UnitPrice));

      Expect('currency without rate rejected', procedure begin Svc.ChangeCurrency(Off, 'XXX', 1); end);
      Check('rejected change keeps currency + prices', (Off.Currency = Base) and Near(Line.UnitPrice, 1010.33));

      // fiyat hanesi 2: 1000 / 49.4889 = 20.21
      UoW.Connection.ExecSQL('UPDATE sys_decimal_place SET price = 2');
      TDecimalPlaces.Invalidate;
      Line.UnitPrice := 1000;
      Svc.ChangeCurrency(Off, 'USD', 1);
      Check('price decimals 2 -> 20.21', Near(Line.UnitPrice, 20.21) and (TDecimalPlaces.Price = 2), CurrToStr(Line.UnitPrice));
      Check('round half away from zero', Near(TDecimalPlaces.RoundTo(2.675, 2), 2.68) and Near(TDecimalPlaces.RoundTo(-2.675, 2), -2.68) and
        Near(TDecimalPlaces.RoundTo(1.2345, 0), 1));
    except
      on E: Exception do
        Check('offer currency change', False, E.ClassName + ': ' + E.Message);
    end;
  finally
    End_;
    TDecimalPlaces.Invalidate;
    Off.Free;
    Svc.Free;
  end;
end;

procedure TestSalesOfferRatesAndAddresses;
const
  FRIDAY = 47487;   // 2030-01-04 (cuma)
var
  RSvc: TAccExchangeRateService;
  Svc: TSlsOfferService;
  Bulletin: TTcmbBulletin;
  Rate: TAccExchangeRate;
  Off, Head, Copy: TSlsOffer;
  Customer, Customer2, SysAddrId, BillId, ShipId, OffId, OldShipId, OldBillId: Int64;
  Count: Integer;

  function SampleXml(const AUsd: string): TBytes;
  begin
    Result := TEncoding.UTF8.GetBytes(
      '<?xml version="1.0" encoding="UTF-8"?>' +
      '<Tarih_Date Tarih="04.01.2030" Date="01/04/2030" Bulten_No="2030/3">' +
      '<Currency CrossOrder="0" Kod="USD" CurrencyCode="USD"><Unit>1</Unit><Isim>ABD DOLARI</Isim>' +
      '<ForexBuying>' + AUsd + '</ForexBuying><ForexSelling>40.2000</ForexSelling>' +
      '<BanknoteBuying>40.0500</BanknoteBuying><BanknoteSelling>40.2500</BanknoteSelling></Currency>' +
      '<Currency CrossOrder="9" Kod="EUR" CurrencyCode="EUR"><Unit>1</Unit><Isim>EURO</Isim>' +
      '<ForexBuying>45.5000</ForexBuying><ForexSelling>45.6000</ForexSelling>' +
      '<BanknoteBuying>45.4000</BanknoteBuying><BanknoteSelling>45.7000</BanknoteSelling></Currency>' +
      '<Currency CrossOrder="13" Kod="JPY" CurrencyCode="JPY"><Unit>100</Unit><Isim>JAPON YENI</Isim>' +
      '<ForexBuying>26.0000</ForexBuying><ForexSelling>26.2000</ForexSelling>' +
      '<BanknoteBuying></BanknoteBuying><BanknoteSelling></BanknoteSelling></Currency>' +
      '<Currency CrossOrder="20" Kod="XDR" CurrencyCode="XDR"><Unit>1</Unit><Isim>OZEL CEKME HAKKI</Isim>' +
      '<ForexBuying>54.0000</ForexBuying><ForexSelling></ForexSelling>' +
      '<BanknoteBuying></BanknoteBuying><BanknoteSelling></BanknoteSelling></Currency>' +
      '</Tarih_Date>');
  end;

  function RateOf(const ACur: string; ADate: TDate): string;
  begin
    Result := S(Scalar('SELECT rate || ''/'' || source FROM acc_exchange_rate WHERE currency = ''' + ACur +
      ''' AND rate_date = ''' + FormatDateTime('yyyy-mm-dd', ADate) + ''''));
  end;

  function OfferCol(const ACol: string): Int64;
  begin
    Result := FirstId('SELECT ' + ACol + ' FROM sls_offer WHERE id = ' + OffId.ToString);
  end;

begin
  Ctx('Sales', 'offer rates / addresses');
  RSvc := TAccExchangeRateService.Create;
  Svc := TSlsOfferService.Create;
  Off := nil;
  Head := nil;
  Copy := nil;
  try
    try
      // ---- TCMB bülteni
      Bulletin := TTcmbClient.Parse(SampleXml('40.1234'));
      Check('tcmb parse date', SameDate(Bulletin.BulletinDate, FRIDAY), DateToStr(Bulletin.BulletinDate));
      Check('tcmb parse rates', (Length(Bulletin.Rates) = 4) and (Bulletin.Rates[0].Currency = 'USD') and
        SameValue(Bulletin.Rates[0].ForexBuying, 40.1234, 1E-9) and SameValue(Bulletin.Rates[2].ForexBuying, 0.26, 1E-9) and
        (Bulletin.Rates[3].ForexSelling = 0), Length(Bulletin.Rates).ToString);
      Check('tcmb archive url', TTcmbClient.BulletinUrl(FRIDAY) = 'https://www.tcmb.gov.tr/kurlar/203001/04012030.xml',
        TTcmbClient.BulletinUrl(FRIDAY));

      Begin_;
      Check('base currency TRY', S(Scalar('SELECT fn_default_currency()')) = 'TRY');
      // cumartesi için elle girilmiş EUR kuru: TCMB çekişi ezmemeli
      Rate := TAccExchangeRate.Create;
      try
        Rate.RateDate := FRIDAY + 1;
        Rate.Currency := 'EUR';
        Rate.Rate := 50;
        RSvc.BusinessInsert(Rate, False, False, True);
      finally
        Rate.Free;
      end;
      Count := RSvc.ImportTcmbBulletin(Bulletin, True);
      Check('tcmb import friday -> sat / sun (known currencies, manual kept)', Count = 5, Count.ToString);
      Check('tcmb friday USD', RateOf('USD', FRIDAY) = '40.123400/TCMB', RateOf('USD', FRIDAY));
      Check('tcmb saturday / sunday = friday', (RateOf('USD', FRIDAY + 1) = '40.123400/TCMB') and
        (RateOf('USD', FRIDAY + 2) = '40.123400/TCMB'), RateOf('USD', FRIDAY + 2));
      Check('tcmb manual rate kept', RateOf('EUR', FRIDAY + 1) = '50.000000/MANUAL', RateOf('EUR', FRIDAY + 1));
      Check('tcmb four rates stored', S(Scalar('SELECT forex_selling || ''/'' || banknote_buying || ''/'' || banknote_selling ' +
        'FROM acc_exchange_rate WHERE currency = ''USD'' AND rate_date = ''2030-01-04''')) = '40.200000/40.050000/40.250000');
      Count := RSvc.ImportTcmbBulletin(TTcmbClient.Parse(SampleXml('40.5000')), True);
      Check('tcmb re-import updates TCMB rows', (Count = 5) and (RateOf('USD', FRIDAY + 2) = '40.500000/TCMB'), RateOf('USD', FRIDAY + 2));
      Check('rate on monday = last bulletin', SameValue(RSvc.GetRate('USD', FRIDAY + 3), 40.5, 1E-6), CurrToStr(RSvc.GetRate('USD', FRIDAY + 3)));
      Check('rate of base currency = 1', RSvc.GetRate('TRY', FRIDAY) = 1);
      Check('needs update only without rate', not RSvc.NeedsTcmbUpdate(FRIDAY + 1) and RSvc.NeedsTcmbUpdate(FRIDAY + 4));

      // ---- teklif kurları: boş kur teklif tarihinden (cumartesi -> cuma bülteni), rapor kurları USD / EUR
      Off := TSlsOffer.Create;
      Off.AccAccountId := Scalar('SELECT min(id) FROM acc_account');
      Off.OfferDate := FRIDAY + 1;
      Off.Currency := 'USD';
      Svc.BusinessInsert(Off, False, False, True);
      Check('offer base currency / rate from date', S(Scalar('SELECT base_currency || ''/'' || exchange_rate || ''/'' || usd_rate || ''/'' || eur_rate ' +
        'FROM sls_offer WHERE id = ' + Off.Id.ToString)) = 'TRY/40.500000/40.500000/50.000000',
        S(Scalar('SELECT base_currency || ''/'' || exchange_rate || ''/'' || usd_rate || ''/'' || eur_rate FROM sls_offer WHERE id = ' + Off.Id.ToString)));
      FreeAndNil(Off);
      Off := TSlsOffer.Create;
      Off.AccAccountId := Scalar('SELECT min(id) FROM acc_account');
      Off.OfferDate := FRIDAY;
      Off.Currency := 'USD';
      Off.ExchangeRate := 41;
      Svc.BusinessInsert(Off, False, False, True);
      Check('offer manual exchange rate kept', Num(Scalar('SELECT exchange_rate FROM sls_offer WHERE id = ' + Off.Id.ToString)) = 41);
      FreeAndNil(Off);
      Expect('offer foreign currency without rate', procedure
        var X: TSlsOffer;
        begin
          X := TSlsOffer.Create;
          try
            X.AccAccountId := Scalar('SELECT min(id) FROM acc_account');
            X.OfferDate := EncodeDate(1990, 1, 1);
            X.Currency := 'USD';
            Svc.BusinessInsert(X, False, False, True);
          finally X.Free; end;
        end);
      End_;

      // ---- belgeye ait ayrıntılı adres
      Begin_;
      Customer := Scalar('SELECT min(id) FROM acc_account');
      Customer2 := Scalar('SELECT max(id) FROM acc_account');
      SysAddrId := FirstId('INSERT INTO sys_address (sys_city_id, district, neighborhood, street, building_name, door_number, zip_code) ' +
        'SELECT min(id), ''Merkez'', ''Cumhuriyet Mah.'', ''Test Sk.'', ''A Blok'', ''7'', ''06000'' FROM sys_city RETURNING id');
      BillId := FirstId('INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type) VALUES (' +
        Customer.ToString + ', ' + SysAddrId.ToString + ', ''BILLING'') RETURNING id');
      ShipId := FirstId('INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type) VALUES (' +
        Customer.ToString + ', ' + SysAddrId.ToString + ', ''SHIPPING'') RETURNING id');

      Off := TSlsOffer.Create;
      Off.AccAccountId := Customer;
      Svc.ApplyDefaultAddresses(Off);
      Check('offer default addresses copied', (Off.BillingAddressId = BillId) and (Off.ShippingAddressId = ShipId) and
        (Off.BillingAddress.Street = 'Test Sk.') and (Off.BillingAddress.Id = 0) and (Off.BillingAddress.SysCityId > 0));
      Off.ShippingAddress.DoorNumber := '9';
      Off.ShippingAddress.BuildingName := 'Depo';
      Svc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      Check('offer owns address copies', (OfferCol('billing_sys_address_id') > 0) and (OfferCol('billing_sys_address_id') <> SysAddrId) and
        (OfferCol('shipping_sys_address_id') > 0) and (OfferCol('shipping_sys_address_id') <> OfferCol('billing_sys_address_id')));
      Check('offer edited shipping address', S(Scalar('SELECT building_name || ''/'' || door_number FROM sys_address WHERE id = ' +
        OfferCol('shipping_sys_address_id').ToString)) = 'Depo/9');
      Check('account address unchanged', S(Scalar('SELECT door_number FROM sys_address WHERE id = ' + SysAddrId.ToString)) = '7');
      Scalar('UPDATE sys_address SET street = ''Yeni Sk.'' WHERE id = ' + SysAddrId.ToString + ' RETURNING id');
      Check('offer keeps its address', S(Scalar('SELECT street FROM sys_address WHERE id = ' + OfferCol('billing_sys_address_id').ToString)) = 'Test Sk.');
      Check('offer list address text', ContainsText(S(Scalar('SELECT billing_address FROM vw_sls_offer WHERE id = ' + OffId.ToString)), 'Test Sk., A Blok, 7'),
        S(Scalar('SELECT billing_address FROM vw_sls_offer WHERE id = ' + OffId.ToString)));
      FreeAndNil(Off);

      Off := Svc.BusinessFindById(OffId, False, False, True);
      Check('offer addresses loaded', (Off.BillingAddress.Id = OfferCol('billing_sys_address_id')) and (Off.BillingAddress.Street = 'Test Sk.') and
        Assigned(Off.BillingAddress.SysCity) and (Off.BillingAddress.SysCity.CityName <> '') and (Off.ShippingAddress.DoorNumber = '9'));
      // teslimat adresi temizlenir: belgenin adres kaydı silinir
      OldShipId := OfferCol('shipping_sys_address_id');
      Svc.ApplyAccountAddress(Off, True, 0);
      Off.BillingAddress.ZipCode := '06100';
      Svc.BusinessSaveWithDetails(Off, False, True);
      Check('offer cleared shipping address deleted', (OfferCol('shipping_sys_address_id') = 0) and (OfferCol('shipping_address_id') = 0) and
        (Num(Scalar('SELECT count(*) FROM sys_address WHERE id = ' + OldShipId.ToString)) = 0));
      Check('offer billing address updated in place', S(Scalar('SELECT zip_code FROM sys_address WHERE id = ' +
        OfferCol('billing_sys_address_id').ToString)) = '06100');

      // adresleri yüklenmemiş başlık güncellemesi adrese dokunmaz
      OldBillId := OfferCol('billing_sys_address_id');
      Head := Svc.FindById(OffId, False);
      Head.Description := 'yalnız başlık';
      Svc.BusinessUpdate(Head, False, False, True);
      Check('header-only update keeps address', (OfferCol('billing_sys_address_id') = OldBillId) and
        (Num(Scalar('SELECT count(*) FROM sys_address WHERE id = ' + OldBillId.ToString)) = 1));

      // kopya belge kendi adres kaydını alır
      Copy := Off.Clone;
      Svc.PrepareCopy(Copy);
      Svc.BusinessSaveWithDetails(Copy, False, True);
      Check('copied offer has own address', (FirstId('SELECT billing_sys_address_id FROM sls_offer WHERE id = ' + Copy.Id.ToString) > 0) and
        (FirstId('SELECT billing_sys_address_id FROM sls_offer WHERE id = ' + Copy.Id.ToString) <> OldBillId) and
        (S(Scalar('SELECT s.zip_code FROM sls_offer o JOIN sys_address s ON s.id = o.billing_sys_address_id WHERE o.id = ' + Copy.Id.ToString)) = '06100'));

      // silinen teklifin adresi de silinir
      Svc.BusinessDelete(Off, False, False, True);
      Check('deleted offer address removed', Num(Scalar('SELECT count(*) FROM sys_address WHERE id = ' + OldBillId.ToString)) = 0);

      Expect('offer address of another customer', procedure
        var X: TSlsOffer;
        begin
          X := TSlsOffer.Create;
          try
            X.AccAccountId := Customer2;
            Svc.ApplyAccountAddress(X, False, BillId);
          finally X.Free; end;
        end);
      Expect('offer address without city', procedure
        var X: TSlsOffer;
        begin
          X := TSlsOffer.Create;
          try
            X.AccAccountId := Customer;
            X.BillingAddress.Street := 'Şehirsiz Sk.';
            Svc.BusinessSaveWithDetails(X, False, True);
          finally X.Free; end;
        end);
      End_;

      // canlı TCMB (ağ yoksa yalnız uyarı)
      try
        Bulletin := TTcmbClient.Fetch;
        Check('tcmb live today.xml', (Bulletin.BulletinDate > EncodeDate(2020, 1, 1)) and (Length(Bulletin.Rates) > 5),
          DateToStr(Bulletin.BulletinDate) + ' / ' + Length(Bulletin.Rates).ToString);
      except
        on E: Exception do
          Report('WARN', 'Sales', 'offer rates / addresses', 'tcmb live today.xml', E.Message);
      end;
    except
      on E: Exception do
        Report('FAIL', 'Sales', 'offer rates / addresses', 'unexpected', E.Message);
    end;
  finally
    End_;
    Copy.Free;
    Head.Free;
    Off.Free;
    Svc.Free;
    RSvc.Free;
  end;
end;

procedure TestSalesOfferDocument;
var
  Svc: TSlsOfferService;
  Off, Copy: TSlsOffer;
  L, LTemp: TSlsOfferDetail;
  Inv1, Inv3, Customer, OffId, Line1Id, Line2Id: Int64;
  LNo1, LNo2: SmallInt;

  function AddL(AOffer: TSlsOffer; AInv: Int64; AQty, APrice: Currency): TSlsOfferDetail;
  begin
    Result := Svc.NewLine(AOffer);
    Result.StkInventoryId := AInv;
    Result.Quantity := AQty;
    Result.UnitPrice := APrice;
    Result.VatRate := 20;
    Svc.Recalculate(AOffer);
  end;

  function LineCount: Integer;
  begin
    Result := Trunc(Num(Scalar('SELECT count(*) FROM sls_offer_detail WHERE sls_offer_id = ' + OffId.ToString)));
  end;

  function DbTotal: Double;
  begin
    Result := Num(Scalar('SELECT total_amount FROM sls_offer WHERE id = ' + OffId.ToString));
  end;

  function NewOffer: TSlsOffer;
  begin
    Result := TSlsOffer.Create;
    Result.AccAccountId := Customer;
  end;

begin
  Ctx('Sales', 'offer document');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv3 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Customer := Scalar('SELECT min(id) FROM acc_account');
  OffId := 0;
  Svc := TSlsOfferService.Create;
  Off := nil;
  Copy := nil;
  try
    try
      Begin_;
      // ---- yeni teklif + 2 kalem bellekte: 10 x 2 +%20 = 24; 5 x 4 +%20 = 24
      Off := NewOffer;
      AddL(Off, Inv1, 10, 2);
      L := AddL(Off, Inv3, 5, 4);
      Check('new lines: temp ids, line no, header ref', (Off.Lines[0].Id = -1) and (Off.Lines[1].Id = -2) and
        (Off.Lines[0].LineNo = 1) and (Off.Lines[1].LineNo = 2) and (L.Header = Off));
      Check('in-memory totals', Near(Off.TotalAmount, 48) and Near(Off.NetAmount, 40) and Near(Off.VatAmount, 8));
      LTemp := AddL(Off, Inv1, 1, 1);
      Svc.RemoveLine(Off, LTemp);   // yeni kalem: listeden çıkar, DB'ye gitmez
      Check('remove new line: dropped from list', (Off.Lines.Count = 2) and Near(Off.TotalAmount, 48));

      Svc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      Check('insert header + lines', (OffId > 0) and (LineCount = 2), OffId.ToString);
      Check('reload: real ids, master id, view fields', (Off.Lines.Count = 2) and (Off.Lines[0].Id > 0) and
        (Off.Lines[1].Id > 0) and (Off.Lines[0].SlsOfferId = OffId) and (Off.Lines[0].InventoryCode <> '') and
        (Off.Lines[0].Header = Off));
      Check('header totals from lines (DB)', Near(DbTotal, 48));
      Check('no commit (AWithCommit = False)', UoW.InTransaction);
      FreeAndNil(Off);

      // ---- form dışı: oku (kalemler gelir) -> 1. kalem değişir, 2. silinir, yeni kalem eklenir (1 x 10 +%20 = 12)
      Off := Svc.BusinessFindById(OffId, False, False, True);
      Check('BusinessFindById loads lines (line no order)', Assigned(Off) and (Off.Lines.Count = 2) and
        (Off.Lines[0].LineNo < Off.Lines[1].LineNo) and (Off.Lines[1].Header.OfferNo = Off.OfferNo));
      Line1Id := Off.Lines[0].Id;
      Line2Id := Off.Lines[1].Id;
      Off.Lines[0].Quantity := 20;
      Svc.RemoveLine(Off, Off.Lines[1]);
      Check('remove saved line: marked deleted', Off.Lines[1].Deleted and (Off.Lines.Count = 2));
      AddL(Off, Inv3, 1, 10);
      Check('recalculated (deleted line excluded)', Near(Off.TotalAmount, 48 + 12));
      Off.Description := 'IT DOCUMENT';
      Svc.BusinessSaveWithDetails(Off, False, True);
      Check('update: line count', LineCount = 2);
      Check('modified line keeps id', Near(Num(Scalar('SELECT quantity FROM sls_offer_detail WHERE id = ' + Line1Id.ToString)), 20));
      Check('deleted line removed', Num(Scalar('SELECT count(*) FROM sls_offer_detail WHERE id = ' + Line2Id.ToString)) = 0);
      Check('header updated + totals', (S(Scalar('SELECT description FROM sls_offer WHERE id = ' + OffId.ToString)) = 'IT DOCUMENT') and
        Near(DbTotal, 48 + 12));
      Check('reload: deleted gone, new line has id', (Off.Lines.Count = 2) and not Off.Lines[0].Deleted and
        not Off.Lines[1].Deleted and (Off.Lines[1].Id > 0));

      // ---- satır no takası (UNIQUE (sls_offer_id, line_no) commit'te kontrol edilir)
      LNo1 := Off.Lines[0].LineNo;
      LNo2 := Off.Lines[1].LineNo;
      Off.Lines[0].LineNo := LNo2;
      Off.Lines[1].LineNo := LNo1;
      Svc.BusinessSaveWithDetails(Off, False, True);
      UoW.Connection.ExecSQL('SET CONSTRAINTS sls_offer_detail_line_key IMMEDIATE');
      Check('line no swap saved', Near(Num(Scalar('SELECT line_no FROM sls_offer_detail WHERE id = ' + Line1Id.ToString)), LNo2));
      UoW.Connection.ExecSQL('SET CONSTRAINTS sls_offer_detail_line_key DEFERRED');

      // ---- aynı satır no iki kalemde: servis reddeder (DB'ye gitmeden)
      Off.Lines[1].LineNo := Off.Lines[0].LineNo;
      Expect('duplicate line no rejected', procedure begin Svc.BusinessSaveWithDetails(Off, False, True); end);
      Check('rejected save: rolled back', not UoW.InTransaction);
      FreeAndNil(Off);

      // ---- geçersiz kalem (miktar 0): tümü geri alınır, yeni kalem geçici id'sine, silinen işareti korunur
      Begin_;
      Off := NewOffer;
      AddL(Off, Inv1, 2, 5);
      Svc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      Svc.RemoveLine(Off, Off.Lines[0]);
      LTemp := AddL(Off, Inv3, 0, 1);
      Expect('invalid line rejected', procedure begin Svc.BusinessSaveWithDetails(Off, False, True); end);
      Check('failed save: temp id restored, deleted kept', (LTemp.Id < 0) and Off.Lines[0].Deleted and (Off.Id = OffId));
      Check('failed save: transaction rolled back', not UoW.InTransaction);
      FreeAndNil(Off);

      // ---- tanımsız KDV oranı (acc_set_tax_rate'te 17 yok) reddedilir
      Begin_;
      Off := NewOffer;
      AddL(Off, Inv1, 1, 1).VatRate := 17;
      Expect('undefined VAT rate rejected', procedure begin Svc.BusinessSaveWithDetails(Off, False, True); end);
      FreeAndNil(Off);

      // ---- taslak dışı teklif: kalem değişikliği reddedilir
      Begin_;
      Off := NewOffer;
      AddL(Off, Inv1, 3, 2);
      Svc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      Svc.ChangeStatus(OffId, SLS_OFF_SENT, True);
      Off.Lines[0].Quantity := 4;
      Expect('non-draft offer rejected', procedure begin Svc.BusinessSaveWithDetails(Off, False, True); end);
      FreeAndNil(Off);

      // ---- kopya: yeni başlık + yeni kalemler (kaynak değişmez)
      Begin_;
      Off := NewOffer;
      AddL(Off, Inv1, 3, 2);
      Svc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      FreeAndNil(Off);
      Off := Svc.BusinessFindById(OffId, False, False, True);
      Copy := Off.Clone;
      Check('clone: deep, header ref to clone', (Copy.Lines.Count = Off.Lines.Count) and (Copy.Lines[0] <> Off.Lines[0]) and
        (Copy.Lines[0].Header = Copy));
      FreeAndNil(Off);
      Svc.PrepareCopy(Copy);
      Check('prepare copy', (Copy.Id = 0) and (Copy.OfferNo = '') and (Copy.Status = SLS_OFF_DRAFT) and (Copy.Lines[0].Id < 0));
      Svc.BusinessSaveWithDetails(Copy, False, True);
      Check('copy saved as new document', (Copy.Id > 0) and (Copy.Id <> OffId) and (Copy.Lines.Count = 1) and
        (Copy.Lines[0].Id > 0) and (Copy.OfferNo <> ''));
      Check('copy source unchanged', Num(Scalar('SELECT count(*) FROM sls_offer_detail WHERE sls_offer_id = ' + OffId.ToString)) = 1);
    except
      on E: Exception do
        Check('offer document flow', False, E.Message);
    end;
  finally
    End_;
    Copy.Free;
    Off.Free;
    Svc.Free;
  end;
end;

// Sipariş belgesi (başlık + Lines, TDocumentService): tekliften oluşturma (bellekte kurulup belge kaydıyla), form dışı
// değiştir / sil / ekle + bağlı teklifin siparişe aktarılan miktarı ve durumu, onaylıda başlık değişir / kalem değişmez,
// satır no takası, kopya (teklif bağlantısı düşer). Commit yok: test transaction'ı geri alınır.
procedure TestSalesOrderDocument;
var
  OffSvc: TSlsOfferService;
  Svc: TSlsOrderService;
  Off: TSlsOffer;
  Ord, Copy: TSlsOrder;
  L: TSlsOfferDetail;
  OL: TSlsOrderDetail;
  Inv1, Inv3, Customer, OffId, OrdId, OffLine1, OffLine2: Int64;
  LNo1, LNo2: SmallInt;

  function OfferOrdered(AOfferLineId: Int64): Double;
  begin
    Result := Num(Scalar('SELECT ordered_quantity FROM sls_offer_detail WHERE id = ' + AOfferLineId.ToString));
  end;

  function OfferStatus: Integer;
  begin
    Result := Trunc(Num(Scalar('SELECT status FROM sls_offer WHERE id = ' + OffId.ToString)));
  end;

begin
  Ctx('Sales', 'order document');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv3 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Customer := Scalar('SELECT min(id) FROM acc_account');
  OffSvc := TSlsOfferService.Create;
  Svc := TSlsOrderService.Create;
  Off := nil;
  Ord := nil;
  Copy := nil;
  try
    try
      Begin_;
      // ---- gönderilmiş teklif: 10 x 2, 5 x 4 (KDV %20)
      Off := TSlsOffer.Create;
      Off.AccAccountId := Customer;
      L := OffSvc.NewLine(Off); L.StkInventoryId := Inv1; L.Quantity := 10; L.UnitPrice := 2; L.VatRate := 20;
      L := OffSvc.NewLine(Off); L.StkInventoryId := Inv3; L.Quantity := 5; L.UnitPrice := 4; L.VatRate := 20;
      OffSvc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      OffLine1 := Off.Lines[0].Id;
      OffLine2 := Off.Lines[1].Id;
      OffSvc.ChangeStatus(OffId, SLS_OFF_SENT, True);
      FreeAndNil(Off);

      // ---- tekliften sipariş: kalemler teklife bağlı, teklif tamamen siparişe döndü
      OrdId := Svc.CreateFromOffer(OffId, True);
      Ord := Svc.BusinessFindById(OrdId, False, False, True);
      Check('create from offer: lines + links', Assigned(Ord) and (Ord.Lines.Count = 2) and
        (Ord.Lines[0].SlsOfferDetailId = OffLine1) and (Ord.Lines[1].SlsOfferDetailId = OffLine2) and
        (Ord.Lines[0].Header = Ord));
      Check('create from offer: totals', Near(Ord.TotalAmount, 48) and
        Near(Num(Scalar('SELECT total_amount FROM sls_order WHERE id = ' + OrdId.ToString)), 48));
      Check('offer fully ordered', Near(OfferOrdered(OffLine1), 10) and Near(OfferOrdered(OffLine2), 5) and
        (OfferStatus = SLS_OFF_ORDERED));
      Check('still in transaction (no commit)', UoW.InTransaction);

      // ---- form dışı: 1. kalem 10 -> 6, 2. kalem silinir, serbest kalem eklenir (1 x 10 +%20 = 12)
      Ord.Lines[0].Quantity := 6;
      Svc.RemoveLine(Ord, Ord.Lines[1]);
      OL := Svc.NewLine(Ord); OL.StkInventoryId := Inv1; OL.Quantity := 1; OL.UnitPrice := 10; OL.VatRate := 20;
      Svc.Recalculate(Ord);
      Svc.BusinessSaveWithDetails(Ord, False, True);
      Check('update: line count', Num(Scalar('SELECT count(*) FROM sls_order_detail WHERE sls_order_id = ' + OrdId.ToString)) = 2);
      Check('offer ordered qty follows order (old + new links)', Near(OfferOrdered(OffLine1), 6) and Near(OfferOrdered(OffLine2), 0));
      Check('offer back to sent (partly ordered)', OfferStatus = SLS_OFF_SENT);
      Check('order totals: 6 x 2 +%20 + 12', Near(Num(Scalar('SELECT total_amount FROM sls_order WHERE id = ' + OrdId.ToString)), 14.4 + 12));
      Check('reload: ids, header refs', (Ord.Lines.Count = 2) and (Ord.Lines[1].Id > 0) and (Ord.Lines[1].Header = Ord));

      // ---- taslakta satır no takası (UNIQUE commit'te)
      LNo1 := Ord.Lines[0].LineNo;
      LNo2 := Ord.Lines[1].LineNo;
      Ord.Lines[0].LineNo := LNo2;
      Ord.Lines[1].LineNo := LNo1;
      Svc.BusinessSaveWithDetails(Ord, False, True);
      UoW.Connection.ExecSQL('SET CONSTRAINTS sls_order_detail_line_key IMMEDIATE');
      Check('line no swap saved', Ord.Lines.Count = 2);
      UoW.Connection.ExecSQL('SET CONSTRAINTS sls_order_detail_line_key DEFERRED');

      // ---- onaylı sipariş: başlık değişir, kalem değişikliği / yeni kalem reddedilir
      Svc.ChangeStatus(OrdId, SLS_ORD_APPROVED, True);
      FreeAndNil(Ord);
      Ord := Svc.BusinessFindById(OrdId, False, False, True);
      Ord.Description := 'IT APPROVED';
      Svc.BusinessSaveWithDetails(Ord, False, True);
      Check('approved: header saved', S(Scalar('SELECT description FROM sls_order WHERE id = ' + OrdId.ToString)) = 'IT APPROVED');
      Ord.Lines[0].Quantity := Ord.Lines[0].Quantity + 1;
      Expect('approved: line change rejected', procedure begin Svc.BusinessSaveWithDetails(Ord, False, True); end);
      FreeAndNil(Ord);

      Begin_;
      // ---- kopya: yeni taslak, teklif bağlantısı düşer (teklifin siparişe aktarılanı değişmez)
      Off := TSlsOffer.Create;
      Off.AccAccountId := Customer;
      L := OffSvc.NewLine(Off); L.StkInventoryId := Inv1; L.Quantity := 4; L.UnitPrice := 1; L.VatRate := 20;
      OffSvc.BusinessSaveWithDetails(Off, False, True);
      OffId := Off.Id;
      OffLine1 := Off.Lines[0].Id;
      OffSvc.ChangeStatus(OffId, SLS_OFF_SENT, True);
      FreeAndNil(Off);
      OrdId := Svc.CreateFromOffer(OffId, True);
      Ord := Svc.BusinessFindById(OrdId, False, False, True);
      Copy := Ord.Clone;
      FreeAndNil(Ord);
      Svc.PrepareCopy(Copy);
      Check('prepare copy: new, no offer link', (Copy.Id = 0) and (Copy.OrderNo = '') and (Copy.Status = SLS_ORD_DRAFT) and
        (Copy.Lines[0].Id < 0) and (Copy.Lines[0].SlsOfferDetailId = 0));
      Svc.BusinessSaveWithDetails(Copy, False, True);
      Check('copy saved', (Copy.Id > 0) and (Copy.Id <> OrdId) and (Copy.Lines.Count = 1) and (Copy.OrderNo <> ''));
      Check('copy does not count for offer', Near(OfferOrdered(OffLine1), 4));

      // ---- tanımsız KDV oranı reddedilir
      Copy.Lines[0].VatRate := 17;
      Expect('undefined VAT rate rejected', procedure begin Svc.BusinessSaveWithDetails(Copy, False, True); end);
    except
      on E: Exception do
        Check('order document flow', False, E.Message);
    end;
  finally
    End_;
    Copy.Free;
    Ord.Free;
    Off.Free;
    Svc.Free;
    OffSvc.Free;
  end;
end;

// Alış belgeleri (TDocumentService): talep belgesi (satır no takası, aynı stok iki kez reddi), talepten sipariş (talebin
// sipariş edilen miktarı = belge hook'u), onaylı siparişte kalem kilidi, siparişten mal kabul (stok hareketi = kalem
// hook'u, siparişin teslim alınan miktarı = belge hook'u), belge içi fazla teslim reddi, mal kabulden fatura, belge içi
// fazla faturalama reddi, faturalanan mal kabul kalemi kilidi, sipariş kopyası. Commit yok: transaction geri alınır.
procedure TestPurchaseDocuments;
var
  RSvc: TPurRequestService;
  OSvc: TPurOrderService;
  PSvc: TPurReceiptService;
  FSvc: TPurInvoiceService;
  Req: TPurRequest;
  Ord, Copy: TPurOrder;
  Rc: TPurReceipt;
  Fi: TPurInvoice;
  RL: TPurRequestDetail;
  PL: TPurReceiptDetail;
  FL: TPurInvoiceDetail;
  Inv1, Inv2, Supplier, Wh, ReqId, OrdId, RcId, FiId: Int64;
  LNo1, LNo2: SmallInt;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  // Onaylı talep: 10 x Inv1, 4 x Inv2
  function MakeRequest: Int64;
  var
    LReq: TPurRequest;
    LL: TPurRequestDetail;
  begin
    LReq := TPurRequest.Create;
    try
      LL := RSvc.NewLine(LReq); LL.StkInventoryId := Inv1; LL.Quantity := 10;
      LL := RSvc.NewLine(LReq); LL.StkInventoryId := Inv2; LL.Quantity := 4;
      RSvc.BusinessSaveWithDetails(LReq, False, True);
      Result := LReq.Id;
    finally
      LReq.Free;
    end;
    RSvc.ChangeStatus(Result, PUR_REQ_APPROVED, True);
  end;

  // Talepten onaylı sipariş, fiyat 2 / KDV %20; AOnlyInv1: Inv2 kalemi çıkarılır
  function MakeOrder(ARequestId: Int64; AOnlyInv1: Boolean): Int64;
  var
    LOrd: TPurOrder;
    i: Integer;
  begin
    Result := OSvc.CreateFromRequest(ARequestId, Supplier, True);
    LOrd := OSvc.BusinessFindById(Result, False, False, True);
    try
      for i := LOrd.Lines.Count - 1 downto 0 do
        if AOnlyInv1 and (LOrd.Lines[i].StkInventoryId <> Inv1) then
          OSvc.RemoveLine(LOrd, LOrd.Lines[i])
        else
        begin
          LOrd.Lines[i].UnitPrice := 2;
          LOrd.Lines[i].DiscountRate := 0;
          LOrd.Lines[i].VatRate := 20;
        end;
      OSvc.Recalculate(LOrd);
      OSvc.BusinessSaveWithDetails(LOrd, False, True);
    finally
      LOrd.Free;
    end;
    OSvc.ChangeStatus(Result, PUR_ORD_APPROVED, True);
  end;

begin
  Ctx('Purchasing', 'documents');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv2 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Supplier := Scalar('SELECT min(id) FROM acc_account');
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  RSvc := TPurRequestService.Create;
  OSvc := TPurOrderService.Create;
  PSvc := TPurReceiptService.Create;
  FSvc := TPurInvoiceService.Create;
  Req := nil;
  Ord := nil;
  Copy := nil;
  Rc := nil;
  Fi := nil;
  try
    try
      // ---- talep belgesi: kalemlerle kayıt, satır no takası; aynı stok iki kez reddedilir
      Begin_;
      Req := TPurRequest.Create;
      RL := RSvc.NewLine(Req); RL.StkInventoryId := Inv1; RL.Quantity := 10;
      RL := RSvc.NewLine(Req); RL.StkInventoryId := Inv2; RL.Quantity := 4;
      RSvc.BusinessSaveWithDetails(Req, False, True);
      ReqId := Req.Id;
      Check('request: saved with lines', (ReqId > 0) and (Req.Lines.Count = 2) and (Req.Lines[0].Id > 0) and
        (Req.Lines[0].LineNo = 1) and (Req.Lines[1].LineNo = 2) and (Req.Lines[0].Header = Req));
      Check('request: lines in DB', Q('SELECT count(*) FROM pur_request_detail WHERE pur_request_id = ' + ReqId.ToString) = 2);
      LNo1 := Req.Lines[0].LineNo;
      LNo2 := Req.Lines[1].LineNo;
      Req.Lines[0].LineNo := LNo2;
      Req.Lines[1].LineNo := LNo1;
      RSvc.BusinessSaveWithDetails(Req, False, True);
      UoW.Connection.ExecSQL('SET CONSTRAINTS pur_request_detail_line_key IMMEDIATE');
      Check('request: line no swap saved', Req.Lines.Count = 2);
      UoW.Connection.ExecSQL('SET CONSTRAINTS pur_request_detail_line_key DEFERRED');
      RL := RSvc.NewLine(Req); RL.StkInventoryId := Inv1; RL.Quantity := 1;
      Expect('request: same stock twice rejected', procedure begin RSvc.BusinessSaveWithDetails(Req, False, True); end);
      FreeAndNil(Req);

      // ---- talepten sipariş: kalemler talebe bağlı, talebin sipariş edilen miktarı belgeyi izler; onaylıda kalem kilidi
      Begin_;
      ReqId := MakeRequest;
      OrdId := OSvc.CreateFromRequest(ReqId, Supplier, True);
      Ord := OSvc.BusinessFindById(OrdId, False, False, True);
      Check('order from request: lines + links', Assigned(Ord) and (Ord.Lines.Count = 2) and
        (Ord.Lines[0].PurRequestDetailId > 0) and (Ord.Lines[1].PurRequestDetailId > 0) and (Ord.Lines[0].Header = Ord));
      Check('request fully ordered', Near(Q('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + ReqId.ToString), 14));
      Ord.Lines[0].UnitPrice := 2; Ord.Lines[0].DiscountRate := 0; Ord.Lines[0].VatRate := 20;
      Ord.Lines[1].UnitPrice := 2; Ord.Lines[1].DiscountRate := 0; Ord.Lines[1].VatRate := 20;
      OSvc.Recalculate(Ord);
      OSvc.BusinessSaveWithDetails(Ord, False, True);
      Check('order totals: 14 x 2 x 1.2', Near(Q('SELECT total_amount FROM pur_order WHERE id = ' + OrdId.ToString), 33.6) and
        Near(Ord.TotalAmount, 33.6));
      OSvc.RemoveLine(Ord, Ord.Lines[1]);
      OSvc.BusinessSaveWithDetails(Ord, False, True);
      Check('order: line removed, request ordered qty follows',
        (Q('SELECT count(*) FROM pur_order_detail WHERE pur_order_id = ' + OrdId.ToString) = 1) and
        Near(Q('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + ReqId.ToString), Ord.Lines[0].Quantity));
      OSvc.ChangeStatus(OrdId, PUR_ORD_APPROVED, True);
      FreeAndNil(Ord);
      Ord := OSvc.BusinessFindById(OrdId, False, False, True);
      Ord.Lines[0].Quantity := Ord.Lines[0].Quantity + 1;
      Expect('approved order: line change rejected', procedure begin OSvc.BusinessSaveWithDetails(Ord, False, True); end);
      FreeAndNil(Ord);

      // ---- siparişten mal kabul: kalem başına stok hareketi, siparişin teslim alınan miktarı; belge içi fazla teslim
      Begin_;
      OrdId := MakeOrder(MakeRequest, True);
      RcId := PSvc.CreateFromOrder(OrdId, Wh, True);
      Rc := PSvc.BusinessFindById(RcId, False, False, True);
      Check('receipt from order: lines', Assigned(Rc) and (Rc.Lines.Count = 1) and (Rc.Lines[0].PurOrderDetailId > 0) and
        (Rc.Lines[0].LineNo = 1) and Near(Rc.Lines[0].Quantity, 10) and Near(Rc.Lines[0].UnitPrice, 2));
      Check('receipt: stock transaction per line',
        Q('SELECT count(*) FROM stk_transaction WHERE pur_receipt_detail_id = ' + Rc.Lines[0].Id.ToString) = 1);
      Check('order fully received', Near(Q('SELECT sum(received_quantity) FROM pur_order_detail WHERE pur_order_id = ' + OrdId.ToString), 10));
      Rc.Lines[0].Quantity := 7;
      PSvc.BusinessSaveWithDetails(Rc, False, True);
      Check('receipt: stock transaction follows quantity',
        Near(Q('SELECT quantity FROM stk_transaction WHERE pur_receipt_detail_id = ' + Rc.Lines[0].Id.ToString), 7));
      Check('order received follows receipt', Near(Q('SELECT sum(received_quantity) FROM pur_order_detail WHERE pur_order_id = ' + OrdId.ToString), 7));
      Check('receipt: amount in memory', Near(PSvc.TotalAmount(Rc), 14));
      PL := PSvc.NewLine(Rc); PL.StkInventoryId := Inv1; PL.Quantity := 4; PL.UnitPrice := 2;
      PL.PurOrderDetailId := Rc.Lines[0].PurOrderDetailId;
      Expect('receipt: over-receipt within document rejected', procedure begin PSvc.BusinessSaveWithDetails(Rc, False, True); end);
      FreeAndNil(Rc);

      // ---- mal kabulden fatura; belge içi fazla faturalama
      Begin_;
      RcId := PSvc.CreateFromOrder(MakeOrder(MakeRequest, True), Wh, True);
      FiId := FSvc.CreateFromReceipt(RcId, 'IT-PUR-DOC-1', True);
      Fi := FSvc.BusinessFindById(FiId, False, False, True);
      Check('invoice from receipt: lines + totals', Assigned(Fi) and (Fi.Lines.Count = 1) and Near(Fi.Lines[0].Quantity, 10) and
        Near(Fi.TotalAmount, 24) and Near(Q('SELECT total_amount FROM pur_invoice WHERE id = ' + FiId.ToString), 24));
      Check('receipt line invoiced', Near(Q('SELECT invoiced_quantity FROM vw_pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString), 10));
      FL := FSvc.NewLine(Fi); FL.StkInventoryId := Inv1; FL.Quantity := 1; FL.UnitPrice := 2; FL.VatRate := 20;
      FL.PurReceiptDetailId := Fi.Lines[0].PurReceiptDetailId;
      Expect('invoice: over-invoice within document rejected', procedure begin FSvc.BusinessSaveWithDetails(Fi, False, True); end);
      FreeAndNil(Fi);

      // ---- faturalanan mal kabul kalemi azaltılamaz / silinemez
      Begin_;
      RcId := PSvc.CreateFromOrder(MakeOrder(MakeRequest, True), Wh, True);
      FSvc.CreateFromReceipt(RcId, 'IT-PUR-DOC-2', True);
      Rc := PSvc.BusinessFindById(RcId, False, False, True);
      Rc.Lines[0].Quantity := 5;
      Expect('receipt: invoiced line cannot go below invoiced', procedure begin PSvc.BusinessSaveWithDetails(Rc, False, True); end);
      FreeAndNil(Rc);
      Begin_;
      RcId := PSvc.CreateFromOrder(MakeOrder(MakeRequest, True), Wh, True);
      FSvc.CreateFromReceipt(RcId, 'IT-PUR-DOC-3', True);
      Rc := PSvc.BusinessFindById(RcId, False, False, True);
      PSvc.RemoveLine(Rc, Rc.Lines[0]);
      Expect('receipt: invoiced line cannot be deleted', procedure begin PSvc.BusinessSaveWithDetails(Rc, False, True); end);
      FreeAndNil(Rc);

      // ---- sipariş kopyası: yeni taslak, talep bağlantısı düşer; tanımsız KDV reddedilir
      Begin_;
      OrdId := MakeOrder(MakeRequest, False);
      Ord := OSvc.BusinessFindById(OrdId, False, False, True);
      Copy := Ord.Clone;
      FreeAndNil(Ord);
      OSvc.PrepareCopy(Copy);
      Check('order copy: new, no request link', (Copy.Id = 0) and (Copy.OrderNo = '') and (Copy.Status = PUR_ORD_DRAFT) and
        (Copy.Lines[0].Id < 0) and (Copy.Lines[0].PurRequestDetailId = 0) and Near(Copy.Lines[0].ReceivedQuantity, 0));
      OSvc.BusinessSaveWithDetails(Copy, False, True);
      Check('order copy saved', (Copy.Id > 0) and (Copy.Id <> OrdId) and (Copy.Lines.Count = 2) and (Copy.OrderNo <> ''));
      Check('copy does not count for request', Near(Q('SELECT sum(ordered_quantity) FROM pur_request_detail d JOIN pur_order_detail o ' +
        'ON o.pur_request_detail_id = d.id WHERE o.pur_order_id = ' + OrdId.ToString), 14));
      Copy.Lines[0].VatRate := 17;
      Expect('order: undefined VAT rate rejected', procedure begin OSvc.BusinessSaveWithDetails(Copy, False, True); end);
    except
      on E: Exception do
        Check('purchase document flow', False, E.Message);
    end;
  finally
    End_;
    Fi.Free;
    Rc.Free;
    Copy.Free;
    Ord.Free;
    Req.Free;
    FSvc.Free;
    PSvc.Free;
    OSvc.Free;
    RSvc.Free;
  end;
end;

// Alış teklifi (talep -> tedarikçi başına teklif -> karşılaştırma -> onaya gönder -> onay -> sipariş): talepten teklif,
// tedarikçi başına tek açık teklif, karşılaştırma fiyat sırası, talep başına tek seçili teklif, taslak dışı kilit, onayda
// diğer tekliflerin "seçilmedi" olması, tekliften sipariş (fiyat / talep bağı / talebin sipariş miktarı), sipariş silinince
// teklifin onaylıya dönmesi, kopya ve silme kuralları. Commit yok: test transaction'ı geri alınır.
procedure TestPurchaseQuotation;
var
  RSvc: TPurRequestService;
  QSvc: TPurQuotationService;
  OSvc: TPurOrderService;
  URepo: TSysUserRepository;
  Q1, Q2, Copy: TPurQuotation;
  Ord: TPurOrder;
  Inv1, Inv2, S1, S2, ReqId, DraftReqId, Q1Id, Q2Id, OrdId: Int64;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  // Talep: 10 x Inv1, 4 x Inv2; AApprove: onaylı
  function MakeRequest(AApprove: Boolean): Int64;
  var
    LReq: TPurRequest;
    LL: TPurRequestDetail;
  begin
    LReq := TPurRequest.Create;
    try
      LL := RSvc.NewLine(LReq); LL.StkInventoryId := Inv1; LL.Quantity := 10;
      LL := RSvc.NewLine(LReq); LL.StkInventoryId := Inv2; LL.Quantity := 4;
      RSvc.BusinessSaveWithDetails(LReq, False, True);
      Result := LReq.Id;
    finally
      LReq.Free;
    end;
    if AApprove then
      RSvc.ChangeStatus(Result, PUR_REQ_APPROVED, True);
  end;

  // Talepten tedarikçi teklifi; Inv1 / Inv2 birim fiyatları, KDV %20
  function MakeQuotation(ARequestId, ASupplier: Int64; APrice1, APrice2: Currency): Int64;
  var
    LQuo: TPurQuotation;
    LLine: TPurQuotationDetail;
  begin
    Result := QSvc.CreateFromRequest(ARequestId, ASupplier, True);
    LQuo := QSvc.BusinessFindById(Result, False, False, True);
    try
      for LLine in LQuo.Lines do
      begin
        if LLine.StkInventoryId = Inv1 then
          LLine.UnitPrice := APrice1
        else
          LLine.UnitPrice := APrice2;
        LLine.DiscountRate := 0;
        LLine.VatRate := 20;
      end;
      LQuo.PaymentTermDays := 30;
      LQuo.DeliveryDays := 7;
      LQuo.PaymentTerms := 'IT 30 gun vadeli';
      QSvc.Recalculate(LQuo);
      QSvc.BusinessSaveWithDetails(LQuo, False, True);
    finally
      LQuo.Free;
    end;
  end;

  // TEST kullanıcısı (id 4): şablonsuz, teklif yetkisi okuma + güncelleme (+ isteğe bağlı özel = onay)
  procedure SetTestUserRights(ASpecial: Boolean);
  begin
    UoW.Connection.ExecSQL('DELETE FROM sys_user_permission_template WHERE sys_user_id = 4');
    UoW.Connection.ExecSQL('UPDATE sys_access_right SET is_read=false, is_add=false, is_update=false, is_delete=false, is_special=false, ' +
      'deny_read=false, deny_add=false, deny_update=false, deny_delete=false, deny_special=false WHERE sys_user_id = 4');
    UoW.Connection.ExecSQL('UPDATE sys_access_right SET is_read = true, is_update = true, is_special = ' + BoolToStr(ASpecial, True) +
      ' WHERE sys_user_id = 4 AND sys_permission_id = (SELECT id FROM sys_permission WHERE permission_code = 1084)');
  end;

  procedure AsTestUser(AProc: TProc);
  begin
    // SetUser eski kullanıcıyı serbest bırakır -> her seferinde taze nesne yükle
    TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(4), False);
    try
      AProc();
    finally
      TAppContext.Instance.CurrentUser.User := URepo.FindById(TValue.From<Int64>(1), False);
    end;
  end;

begin
  Ctx('Purchasing', 'quotation');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv2 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  S1 := Scalar('SELECT min(id) FROM acc_account');
  S2 := Scalar('SELECT min(id) FROM acc_account WHERE id > ' + S1.ToString);
  RSvc := TPurRequestService.Create;
  QSvc := TPurQuotationService.Create;
  OSvc := TPurOrderService.Create;
  URepo := TSysUserRepository.Create(UoW.Connection);
  Q1 := nil;
  Q2 := nil;
  Copy := nil;
  Ord := nil;
  try
    try
      Begin_;
      ReqId := MakeRequest(True);

      // ---- talepten tedarikçi başına teklif: kalemler talebe bağlı, açık miktarlar
      Q1Id := MakeQuotation(ReqId, S1, 2, 3);
      Q1 := QSvc.BusinessFindById(Q1Id, False, False, True);
      Check('quotation from request: lines + links', Assigned(Q1) and (Q1.Lines.Count = 2) and (Q1.PurRequestId = ReqId) and
        (Q1.Lines[0].PurRequestDetailId > 0) and (Q1.Lines[1].PurRequestDetailId > 0) and (Q1.Status = PUR_QUO_DRAFT) and
        (Q1.QuotationNo <> '') and (Q1.Lines[0].Header = Q1));
      Check('quotation totals: (10 x 2 + 4 x 3) x 1.2', Near(Q1.TotalAmount, 38.4) and
        Near(Q('SELECT total_amount FROM pur_quotation WHERE id = ' + Q1Id.ToString), 38.4));
      Check('quotation keeps terms', (Q1.PaymentTermDays = 30) and (Q1.DeliveryDays = 7) and (Q1.PaymentTerms <> ''));
      Check('quotation does not touch request quantities',
        Near(Q('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + ReqId.ToString), 0));
      FreeAndNil(Q1);
      Expect('same supplier twice for a request rejected', procedure begin QSvc.CreateFromRequest(ReqId, S1, True); end);

      Begin_;
      ReqId := MakeRequest(True);
      DraftReqId := MakeRequest(False);
      Expect('quotation for draft request rejected', procedure begin QSvc.CreateFromRequest(DraftReqId, S1, True); end);
      Begin_;
      ReqId := MakeRequest(True);
      Q1Id := MakeQuotation(ReqId, S1, 2, 3);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);

      // ---- karşılaştırma: talep kalemi başına fiyat sırası (ana para biriminde net birim fiyat)
      Check('comparison: one row per supplier and request line',
        Q('SELECT count(*) FROM vw_pur_quotation_comparison WHERE pur_request_id = ' + ReqId.ToString) = 4);
      Check('comparison: best price for Inv1 is supplier 2',
        Q('SELECT pur_quotation_id FROM vw_pur_quotation_comparison WHERE pur_request_id = ' + ReqId.ToString +
          ' AND stk_inventory_id = ' + Inv1.ToString + ' AND price_rank = 1') = Q2Id);
      Check('comparison: best price for Inv2 is supplier 1',
        Q('SELECT pur_quotation_id FROM vw_pur_quotation_comparison WHERE pur_request_id = ' + ReqId.ToString +
          ' AND stk_inventory_id = ' + Inv2.ToString + ' AND price_rank = 1') = Q1Id);

      // ---- seçim + onaya gönderme: talep başına tek seçili teklif, taslak dışı kilit
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      Check('selected quotation pending approval', Q('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString) = PUR_QUO_PENDING);
      Expect('second selection for the same request rejected', procedure begin QSvc.ChangeStatus(Q1Id, PUR_QUO_PENDING, True); end);
      Begin_;
      ReqId := MakeRequest(True);
      Q1Id := MakeQuotation(ReqId, S1, 2, 3);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      Q2 := QSvc.BusinessFindById(Q2Id, False, False, True);
      Q2.Lines[0].UnitPrice := 1;
      Expect('pending quotation cannot be changed', procedure begin QSvc.BusinessSaveWithDetails(Q2, False, True); end);
      FreeAndNil(Q2);

      // ---- onay: diğer açık teklifler seçilmedi olur; onay bilgisi yazılır
      Begin_;
      ReqId := MakeRequest(True);
      Q1Id := MakeQuotation(ReqId, S1, 2, 3);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      Expect('draft cannot be approved directly', procedure begin QSvc.ChangeStatus(Q1Id, PUR_QUO_APPROVED, True); end);
      Begin_;
      ReqId := MakeRequest(True);
      Q1Id := MakeQuotation(ReqId, S1, 2, 3);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_APPROVED, True);
      Check('approved', Q('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString) = PUR_QUO_APPROVED);
      Check('approval time recorded', Q('SELECT count(*) FROM pur_quotation WHERE approved_at IS NOT NULL AND id = ' + Q2Id.ToString) = 1);
      Check('other quotation not selected', Q('SELECT status FROM pur_quotation WHERE id = ' + Q1Id.ToString) = PUR_QUO_NOT_SELECTED);

      // ---- tekliften sipariş: mevcut sipariş servisi, fiyatlar / koşullar tekliften, kalemler talebe bağlı
      OrdId := QSvc.CreateOrder(Q2Id, True);
      Ord := OSvc.BusinessFindById(OrdId, False, False, True);
      Check('order from quotation: lines, prices, request links', Assigned(Ord) and (Ord.Lines.Count = 2) and
        (Ord.Status = PUR_ORD_DRAFT) and (Ord.AccAccountId = S2) and (Ord.PaymentTermDays = 30) and
        (Ord.Lines[0].PurRequestDetailId > 0) and Near(Ord.TotalAmount, (10 * 1.5 + 4 * 3.5) * 1.2));
      Check('quotation ordered + linked to order',
        (Q('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString) = PUR_QUO_ORDERED) and
        (Q('SELECT pur_order_id FROM pur_quotation WHERE id = ' + Q2Id.ToString) = OrdId));
      Check('request ordered quantity follows the order',
        Near(Q('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + ReqId.ToString), 14));
      Check('request -> quotation -> order link readable',
        Q('SELECT count(*) FROM vw_pur_quotation WHERE id = ' + Q2Id.ToString + ' AND order_no IS NOT NULL AND request_no IS NOT NULL') = 1);
      Expect('ordered quotation cannot be converted again', procedure begin QSvc.CreateOrder(Q2Id, True); end);

      // ---- sipariş silinince teklif onaylıya döner, talep miktarı geri alınır
      Begin_;
      ReqId := MakeRequest(True);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_APPROVED, True);
      OrdId := QSvc.CreateOrder(Q2Id, True);
      FreeAndNil(Ord);
      Ord := OSvc.BusinessFindById(OrdId, False, False, True);
      OSvc.BusinessDelete(Ord, False, False, True);
      Check('order deleted: quotation back to approved, link cleared',
        (Q('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString) = PUR_QUO_APPROVED) and
        (Q('SELECT count(*) FROM pur_quotation WHERE pur_order_id IS NULL AND id = ' + Q2Id.ToString) = 1));
      Check('order deleted: request quantity released',
        Near(Q('SELECT sum(ordered_quantity) FROM pur_request_detail WHERE pur_request_id = ' + ReqId.ToString), 0));

      // ---- kopya: yeni taslak, sipariş / onay bağı yok; aynı tedarikçinin açık teklifi varken reddedilir
      Q2 := QSvc.BusinessFindById(Q2Id, False, False, True);
      Copy := Q2.Clone;
      QSvc.PrepareCopy(Copy);
      Check('copy: new draft without order / approval', (Copy.Id = 0) and (Copy.QuotationNo = '') and
        (Copy.Status = PUR_QUO_DRAFT) and (Copy.PurOrderId = 0) and (Copy.ApprovedSysUserId = 0) and (Copy.Lines[0].Id < 0));
      Expect('copy for the same supplier rejected', procedure begin QSvc.BusinessSaveWithDetails(Copy, False, True); end);
      Begin_;
      ReqId := MakeRequest(True);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_APPROVED, True);
      FreeAndNil(Q2);
      Q2 := QSvc.BusinessFindById(Q2Id, False, False, True);
      Expect('approved quotation cannot be deleted', procedure begin QSvc.BusinessDelete(Q2, False, False, True); end);
      Begin_;
      ReqId := MakeRequest(True);
      Q1Id := MakeQuotation(ReqId, S1, 2, 3);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_REJECTED, True);
      Check('rejected quotation frees the selection',
        Q('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString) = PUR_QUO_REJECTED);
      QSvc.ChangeStatus(Q1Id, PUR_QUO_PENDING, True);
      Check('another quotation selectable after rejection', Q('SELECT status FROM pur_quotation WHERE id = ' + Q1Id.ToString) = PUR_QUO_PENDING);

      // ---- onay / red özel yetki ister; onaya gönderme güncelleme yetkisiyle yapılır
      Begin_;
      ReqId := MakeRequest(True);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      SetTestUserRights(False);
      AsTestUser(procedure
        begin
          Check('without special right: approval not offered', not QSvc.CanApprove);
          QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
          Check('update right: quotation sent for approval', Num(Scalar('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString)) = PUR_QUO_PENDING);
          Expect('without special right: approval rejected', procedure begin QSvc.ChangeStatus(Q2Id, PUR_QUO_APPROVED, True); end);
        end);
      Begin_;
      ReqId := MakeRequest(True);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      SetTestUserRights(False);
      AsTestUser(procedure
        begin
          Expect('without special right: rejection rejected', procedure begin QSvc.ChangeStatus(Q2Id, PUR_QUO_REJECTED, True); end);
        end);
      Begin_;
      ReqId := MakeRequest(True);
      Q2Id := MakeQuotation(ReqId, S2, 1.5, 3.5);
      QSvc.ChangeStatus(Q2Id, PUR_QUO_PENDING, True);
      SetTestUserRights(True);
      AsTestUser(procedure
        begin
          Check('special right: approval offered', QSvc.CanApprove);
          QSvc.ChangeStatus(Q2Id, PUR_QUO_APPROVED, True);
        end);
      Check('special right: approved, approver recorded',
        (Q('SELECT status FROM pur_quotation WHERE id = ' + Q2Id.ToString) = PUR_QUO_APPROVED) and
        (Q('SELECT approved_sys_user_id FROM pur_quotation WHERE id = ' + Q2Id.ToString) = 4));
    except
      on E: Exception do
        Check('purchase quotation flow', False, E.Message);
    end;
  finally
    End_;
    Ord.Free;
    Copy.Free;
    Q2.Free;
    Q1.Free;
    URepo.Free;
    OSvc.Free;
    QSvc.Free;
    RSvc.Free;
  end;
end;

// Giriş kalite kontrol (gevşek bağlı): modül kapalıyken kontrol listesi boş, kayıt reddedilir, mal kabul -> fatura akışı
// aynen çalışır; açıkken kart / grup kuralı (kart grubu ezer), kontrol sonucu (uygun / uygunsuz / karar), mal kabul
// kalemi başına tek kayıt, red ambarına transfer, miktar değişince yeniden kontrol, kalem silinince kayıt + transfer
// silinir. Commit yok.
procedure TestQualityControl;
var
  PSvc: TPurReceiptService;
  FSvc: TPurInvoiceService;
  SSvc: TQcSettingService;
  RuSvc: TQcRuleService;
  ISvc: TQcInspectionService;
  TxSvc: TStkTransactionService;
  Tx: TStkTransaction;
  Rc: TPurReceipt;
  Setting: TQcSetting;
  Rule: TQcRule;
  Insp: TQcInspection;
  Inv1, Inv2, Grp1, Supplier, Wh, Wh2, RcId, Line1, Line2: Int64;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  // Mal kabul: 10 x Inv1, 5 x Inv2 (birim fiyat 2)
  function MakeReceipt: Int64;
  var
    LRc: TPurReceipt;
    LL: TPurReceiptDetail;
  begin
    LRc := TPurReceipt.Create;
    try
      LRc.AccAccountId := Supplier;
      LRc.StkWarehouseId := Wh;
      LL := PSvc.NewLine(LRc); LL.StkInventoryId := Inv1; LL.Quantity := 10; LL.UnitPrice := 2;
      LL := PSvc.NewLine(LRc); LL.StkInventoryId := Inv2; LL.Quantity := 5; LL.UnitPrice := 2;
      PSvc.BusinessSaveWithDetails(LRc, False, True);
      Result := LRc.Id;
    finally
      LRc.Free;
    end;
  end;

  function NewInspection(ALine: Int64; ARejected: Currency; ADisposition: SmallInt): TQcInspection;
  begin
    Result := TQcInspection.Create;
    Result.PurReceiptDetailId := ALine;
    Result.RejectedQuantity := ARejected;
    Result.Disposition := ADisposition;
  end;

  procedure SetEnabled(AEnabled: Boolean; ARejectWh: Int64);
  begin
    if not Assigned(Setting) then
      Setting := SSvc.BusinessFindSetting(False, False, True);
    if not Assigned(Setting) then
    begin
      Setting := TQcSetting.Create;
      Setting.IsEnabled := AEnabled;
      Setting.RejectStkWarehouseId := ARejectWh;
      SSvc.BusinessInsert(Setting, False, False, True);
    end
    else
    begin
      Setting.IsEnabled := AEnabled;
      Setting.RejectStkWarehouseId := ARejectWh;
      SSvc.BusinessUpdate(Setting, False, False, True);
    end;
  end;

begin
  Ctx('Quality', 'incoming inspection');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv2 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Grp1 := Scalar('SELECT stk_group_id FROM stk_inventory WHERE id = ' + Inv1.ToString);
  Supplier := Scalar('SELECT min(id) FROM acc_account');
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  Wh2 := FirstId('SELECT min(id) FROM stk_warehouse WHERE id > ' + Wh.ToString);
  PSvc := TPurReceiptService.Create;
  FSvc := TPurInvoiceService.Create;
  SSvc := TQcSettingService.Create;
  RuSvc := TQcRuleService.Create;
  ISvc := TQcInspectionService.Create;
  TxSvc := TStkTransactionService.Create;
  Tx := nil;
  Rc := nil;
  Setting := nil;
  Rule := nil;
  Insp := nil;
  try
    try
      // ---- modül kapalı: kontrol adımı yok, mal kabul -> fatura akışı aynen
      Begin_;
      UoW.Connection.ExecSQL('UPDATE qc_setting SET is_enabled = false');
      RcId := MakeReceipt;
      Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      Check('disabled: module reports off', not SSvc.IsEnabled);
      Check('disabled: nothing awaits inspection', Q('SELECT count(*) FROM vw_qc_receipt_line') = 0);
      Insp := NewInspection(Line1, 0, 0);
      Expect('disabled: inspection rejected', procedure begin ISvc.BusinessInsert(Insp, False, False, True); end);
      FreeAndNil(Insp);
      Begin_;
      UoW.Connection.ExecSQL('UPDATE qc_setting SET is_enabled = false');
      RcId := MakeReceipt;
      FSvc.CreateFromReceipt(RcId, 'IT-QC-1', True);
      Check('disabled: receipt stock + invoice unaffected',
        (Q('SELECT count(*) FROM stk_transaction t JOIN pur_receipt_detail d ON d.id = t.pur_receipt_detail_id WHERE d.pur_receipt_id = ' + RcId.ToString) = 2) and
        (Q('SELECT count(*) FROM pur_invoice WHERE invoice_no = ''IT-QC-1''') = 1));

      // ---- modül açık + kurallar: grup kuralı Inv1'i kapsar, kart kuralı Inv2'yi muaf tutar
      Begin_;
      SetEnabled(True, 0);
      Check('enabled: module reports on', SSvc.IsEnabled);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      Rule.StkInventoryId := Inv1;
      Expect('rule: group and card together rejected', procedure begin RuSvc.BusinessInsert(Rule, False, False, True); end);
      FreeAndNil(Rule);
      Begin_;
      FreeAndNil(Setting);
      SetEnabled(True, 0);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      Rule.InspectionCriteria := 'IT olcu + gorsel kontrol';
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      Expect('rule: duplicate group rejected', procedure begin RuSvc.BusinessInsert(Rule, False, False, True); end);
      FreeAndNil(Rule);

      Begin_;
      FreeAndNil(Setting);
      SetEnabled(True, Wh2);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      Rule.InspectionCriteria := 'IT olcu + gorsel kontrol';
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      Rule := TQcRule.Create;
      Rule.StkInventoryId := Inv2;
      Rule.IsRequired := False;
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      RcId := MakeReceipt;
      Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      Line2 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv2.ToString);
      Check('enabled: required line awaits inspection',
        Q('SELECT qc_status FROM vw_qc_receipt_line WHERE id = ' + Line1.ToString) = QC_STATUS_PENDING);
      Check('enabled: card rule exempts its stock', Q('SELECT count(*) FROM vw_qc_receipt_line WHERE id = ' + Line2.ToString) = 0);
      Check('enabled: criteria shown', Q('SELECT count(*) FROM vw_qc_receipt_line WHERE inspection_criteria IS NOT NULL AND id = ' + Line1.ToString) = 1);

      // ---- kontrol kaydı kuralları
      Insp := NewInspection(Line2, 0, 0);
      Expect('inspection: stock without requirement rejected', procedure begin ISvc.BusinessInsert(Insp, False, False, True); end);
      FreeAndNil(Insp);
      Begin_;
      FreeAndNil(Setting);
      SetEnabled(True, Wh2);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      RcId := MakeReceipt;
      Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      Insp := NewInspection(Line1, 3, 0);
      Expect('inspection: disposition required for rejected quantity', procedure begin ISvc.BusinessInsert(Insp, False, False, True); end);
      FreeAndNil(Insp);
      Begin_;
      FreeAndNil(Setting);
      SetEnabled(True, Wh2);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      RcId := MakeReceipt;
      Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      Insp := NewInspection(Line1, 11, QC_DISP_RETURN);
      Expect('inspection: rejected above received rejected', procedure begin ISvc.BusinessInsert(Insp, False, False, True); end);
      FreeAndNil(Insp);

      Begin_;
      FreeAndNil(Setting);
      SetEnabled(True, Wh2);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      RcId := MakeReceipt;
      Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      Insp := NewInspection(Line1, 3, QC_DISP_RETURN);
      ISvc.BusinessInsert(Insp, False, False, True);
      Check('inspection: quantities + result from service', (Insp.Id > 0) and (Insp.InspectionNo <> '') and
        Near(Insp.Quantity, 10) and Near(Insp.AcceptedQuantity, 7) and (Insp.InspectionResult = QC_RESULT_PARTIAL) and
        (Insp.StkInventoryId = Inv1));
      Check('inspection: line inspected', Q('SELECT qc_status FROM vw_qc_receipt_line WHERE id = ' + Line1.ToString) = QC_STATUS_DONE);
      if Wh2 > 0 then
      begin
        Check('inspection: rejected quantity transferred to reject warehouse',
          (Q('SELECT count(*) FROM stk_transaction WHERE transaction_type = 3 AND qc_inspection_id = ' + Insp.Id.ToString +
             ' AND from_stk_warehouse_id = ' + Wh.ToString + ' AND to_stk_warehouse_id = ' + Wh2.ToString) = 1) and
          Near(Q('SELECT quantity FROM stk_transaction WHERE qc_inspection_id = ' + Insp.Id.ToString), 3));
        Insp.RejectedQuantity := 0;
        ISvc.BusinessUpdate(Insp, False, False, True);
        Check('inspection: transfer removed when all accepted', (Insp.InspectionResult = QC_RESULT_ACCEPTED) and (Insp.Disposition = 0) and
          (Q('SELECT count(*) FROM stk_transaction WHERE qc_inspection_id = ' + Insp.Id.ToString) = 0));
      end;
      FreeAndNil(Insp);
      Insp := NewInspection(Line1, 0, 0);
      Expect('inspection: one record per receipt line', procedure begin ISvc.BusinessInsert(Insp, False, False, True); end);
      FreeAndNil(Insp);

      // ---- mal kabul değişir: yeniden kontrol; kalem silinir: kayıt + transfer silinir (mal kabul engellenmez)
      Begin_;
      FreeAndNil(Setting);
      SetEnabled(True, Wh2);
      Rule := TQcRule.Create;
      Rule.StkGroupId := Grp1;
      RuSvc.BusinessInsert(Rule, False, False, True);
      FreeAndNil(Rule);
      RcId := MakeReceipt;
      Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
      Insp := NewInspection(Line1, 2, QC_DISP_SCRAP);
      ISvc.BusinessInsert(Insp, False, False, True);
      Rc := PSvc.BusinessFindById(RcId, False, False, True);
      Rc.Lines[0].Quantity := 8;
      PSvc.BusinessSaveWithDetails(Rc, False, True);
      Check('receipt changed: re-inspection needed', Q('SELECT qc_status FROM vw_qc_receipt_line WHERE id = ' + Line1.ToString) = QC_STATUS_RECHECK);
      PSvc.RemoveLine(Rc, Rc.Lines[0]);
      PSvc.BusinessSaveWithDetails(Rc, False, True);
      Check('receipt line deleted: inspection + transfer removed',
        (Q('SELECT count(*) FROM qc_inspection WHERE id = ' + Insp.Id.ToString) = 0) and
        (Q('SELECT count(*) FROM stk_transaction WHERE qc_inspection_id = ' + Insp.Id.ToString) = 0));
      FreeAndNil(Insp);
      FreeAndNil(Rc);

      // ---- red ambarı transferi stok hareketleri ekranından değişmez / silinmez (yalnız kontrol kaydından)
      if Wh2 > 0 then
      begin
        Begin_;
        FreeAndNil(Setting);
        SetEnabled(True, Wh2);
        Rule := TQcRule.Create;
        Rule.StkGroupId := Grp1;
        RuSvc.BusinessInsert(Rule, False, False, True);
        FreeAndNil(Rule);
        RcId := MakeReceipt;
        Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
        Insp := NewInspection(Line1, 2, QC_DISP_SCRAP);
        ISvc.BusinessInsert(Insp, False, False, True);
        Tx := TxSvc.BusinessFindById(FirstId('SELECT id FROM stk_transaction WHERE qc_inspection_id = ' + Insp.Id.ToString), False, False, True);
        Check('transfer row readable from stock', Assigned(Tx) and (Tx.TransactionType = 3));
        Tx.Quantity := 1;
        Expect('stock screen: inspection transfer cannot be changed', procedure begin TxSvc.BusinessUpdate(Tx, False, False, True); end);
        FreeAndNil(Tx);
        FreeAndNil(Insp);
        Begin_;
        FreeAndNil(Setting);
        SetEnabled(True, Wh2);
        Rule := TQcRule.Create;
        Rule.StkGroupId := Grp1;
        RuSvc.BusinessInsert(Rule, False, False, True);
        FreeAndNil(Rule);
        RcId := MakeReceipt;
        Line1 := Scalar('SELECT id FROM pur_receipt_detail WHERE pur_receipt_id = ' + RcId.ToString + ' AND stk_inventory_id = ' + Inv1.ToString);
        Insp := NewInspection(Line1, 2, QC_DISP_SCRAP);
        ISvc.BusinessInsert(Insp, False, False, True);
        Tx := TxSvc.BusinessFindById(FirstId('SELECT id FROM stk_transaction WHERE qc_inspection_id = ' + Insp.Id.ToString), False, False, True);
        Expect('stock screen: inspection transfer cannot be deleted', procedure begin TxSvc.BusinessDelete(Tx, False, False, True); end);
        FreeAndNil(Tx);
        FreeAndNil(Insp);
        Begin_;
        FreeAndNil(Setting);
      end;

      // ---- modül kapatılınca liste boş, mevcut kayıtlar silinebilir
      SetEnabled(False, 0);
      Check('disabled again: nothing awaits inspection', Q('SELECT count(*) FROM vw_qc_receipt_line') = 0);
    except
      on E: Exception do
        Check('quality control flow', False, E.Message);
    end;
  finally
    End_;
    Tx.Free;
    Insp.Free;
    Rule.Free;
    Setting.Free;
    Rc.Free;
    TxSvc.Free;
    ISvc.Free;
    RuSvc.Free;
    SSvc.Free;
    FSvc.Free;
    PSvc.Free;
  end;
end;

// İrsaliye + fatura belgeleri (TDocumentService): siparişten irsaliye (stok hareketi = kalem hook'u, siparişin sevk
// miktarı + irsaliye durumu = belge hook'u), form dışı düzenleme, belge içi fazla sevk, irsaliyeden fatura (irsaliye
// kapanır), faturalanan kalem kilidi, faturadan kalem çıkınca irsaliye yeniden bekler, irsaliyeli fatura (stok faturadan),
// belge içi fazla faturalama, ambarsız stoklu fatura reddi. Commit yok: test transaction'ı geri alınır.
procedure TestSalesDispatchInvoiceDocument;
var
  OffSvc: TSlsOfferService;
  OrdSvc: TSlsOrderService;
  DspSvc: TSlsDispatchService;
  InvSvc: TSlsInvoiceService;
  Off: TSlsOffer;
  Dsp: TSlsDispatch;
  Inv: TSlsInvoice;
  L: TSlsOfferDetail;
  DL: TSlsDispatchDetail;
  IL: TSlsInvoiceDetail;
  Inv1, Inv3, Customer, Wh, OrdId, DspId, InvId, OrdLine1, DspLine1: Int64;

  function NewOrder(AQty1, AQty2: Currency): Int64;
  var
    LOff: TSlsOffer;
    LLine: TSlsOfferDetail;
  begin
    LOff := TSlsOffer.Create;
    try
      LOff.AccAccountId := Customer;
      LLine := OffSvc.NewLine(LOff); LLine.StkInventoryId := Inv1; LLine.Quantity := AQty1; LLine.UnitPrice := 10; LLine.VatRate := 20;
      LLine := OffSvc.NewLine(LOff); LLine.StkInventoryId := Inv3; LLine.Quantity := AQty2; LLine.UnitPrice := 5; LLine.VatRate := 20;
      OffSvc.BusinessSaveWithDetails(LOff, False, True);
      OffSvc.ChangeStatus(LOff.Id, SLS_OFF_SENT, True);
      Result := OrdSvc.CreateFromOffer(LOff.Id, True);
      OrdSvc.ChangeStatus(Result, SLS_ORD_APPROVED, True);
    finally
      LOff.Free;
    end;
  end;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

begin
  Ctx('Sales', 'dispatch + invoice document');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv3 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Customer := Scalar('SELECT min(id) FROM acc_account');
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  OffSvc := TSlsOfferService.Create;
  OrdSvc := TSlsOrderService.Create;
  DspSvc := TSlsDispatchService.Create;
  InvSvc := TSlsInvoiceService.Create;
  Off := nil;
  Dsp := nil;
  Inv := nil;
  try
    try
      Begin_;
      // ---- sipariş 10 + 4 -> irsaliye (tamamı)
      OrdId := NewOrder(10, 4);
      OrdLine1 := Trunc(Q('SELECT id FROM sls_order_detail WHERE sls_order_id = ' + OrdId.ToString + ' AND line_no = 1'));
      DspId := DspSvc.CreateFromOrder(OrdId, Wh, True);
      Dsp := DspSvc.BusinessFindById(DspId, False, False, True);
      Check('dispatch from order: lines, line no, header ref', Assigned(Dsp) and (Dsp.Lines.Count = 2) and
        (Dsp.Lines[0].LineNo = 1) and (Dsp.Lines[1].LineNo = 2) and (Dsp.Lines[0].Header = Dsp));
      Check('dispatch status waiting', Dsp.Status = SLS_DSP_WAITING);
      Check('line hook: stock transactions', Q('SELECT count(*) FROM stk_transaction t JOIN sls_dispatch_detail d ON d.id = t.sls_dispatch_detail_id ' +
        ' WHERE d.sls_dispatch_id = ' + DspId.ToString) = 2);
      Check('document hook: order delivered', (Q('SELECT delivered_quantity FROM sls_order_detail WHERE id = ' + OrdLine1.ToString) = 10) and
        (Q('SELECT status FROM sls_order WHERE id = ' + OrdId.ToString) = SLS_ORD_DELIVERED));
      Check('dispatch total from lines', Near(Dsp.TotalAmount, 10 * 10 + 4 * 5));

      // ---- form dışı: 1. kalem 10 -> 7 (stok hareketi + sevk miktarı izler, sipariş kısmi)
      DspLine1 := Dsp.Lines[0].Id;
      Dsp.Lines[0].Quantity := 7;
      DspSvc.BusinessSaveWithDetails(Dsp, False, True);
      Check('edit: stock tx follows', Q('SELECT quantity FROM stk_transaction WHERE sls_dispatch_detail_id = ' + DspLine1.ToString) = 7);
      Check('edit: order partial', (Q('SELECT delivered_quantity FROM sls_order_detail WHERE id = ' + OrdLine1.ToString) = 7) and
        (Q('SELECT status FROM sls_order WHERE id = ' + OrdId.ToString) = SLS_ORD_PARTIAL));

      // ---- belge içi fazla sevk: aynı sipariş kalemine ikinci satır 3 + 1 > açık 3
      DL := DspSvc.NewLine(Dsp); DL.StkInventoryId := Inv1; DL.Quantity := 4; DL.UnitPrice := 10; DL.SlsOrderDetailId := OrdLine1;
      Expect('over-delivery across lines rejected', procedure begin DspSvc.BusinessSaveWithDetails(Dsp, False, True); end);
      FreeAndNil(Dsp);

      Begin_;
      OrdId := NewOrder(10, 4);
      DspId := DspSvc.CreateFromOrder(OrdId, Wh, True);
      // ---- irsaliyeden fatura: irsaliye kapanır, fatura kalemi stok hareketi yazmaz
      InvId := InvSvc.CreateFromDispatch(DspId, True);
      Check('dispatch closed after invoice', Q('SELECT status FROM sls_dispatch WHERE id = ' + DspId.ToString) = SLS_DSP_CLOSED);
      Check('dispatch-linked invoice lines: no stock tx', Q('SELECT count(*) FROM stk_transaction t JOIN sls_invoice_detail d ON d.id = t.sls_invoice_detail_id ' +
        ' WHERE d.sls_invoice_id = ' + InvId.ToString) = 0);

      // ---- faturalanan irsaliye kalemi azaltılamaz / silinemez
      Dsp := DspSvc.BusinessFindById(DspId, False, False, True);
      Check('dispatch line invoiced qty loaded', Dsp.Lines[0].InvoicedQuantity = 10);
      Dsp.Lines[0].Quantity := 5;
      Expect('invoiced line cannot be reduced', procedure begin DspSvc.BusinessSaveWithDetails(Dsp, False, True); end);
      FreeAndNil(Dsp);

      Begin_;
      OrdId := NewOrder(10, 4);
      DspId := DspSvc.CreateFromOrder(OrdId, Wh, True);
      InvId := InvSvc.CreateFromDispatch(DspId, True);
      Dsp := DspSvc.BusinessFindById(DspId, False, False, True);
      DspSvc.RemoveLine(Dsp, Dsp.Lines[0]);
      Expect('invoiced line cannot be deleted', procedure begin DspSvc.BusinessSaveWithDetails(Dsp, False, True); end);
      FreeAndNil(Dsp);

      Begin_;
      OrdId := NewOrder(10, 4);
      DspId := DspSvc.CreateFromOrder(OrdId, Wh, True);
      InvId := InvSvc.CreateFromDispatch(DspId, True);
      // ---- faturadan kalem çıkar: irsaliye yeniden bekler
      Inv := InvSvc.BusinessFindById(InvId, False, False, True);
      Check('invoice loads lines + header ref', (Inv.Lines.Count = 2) and (Inv.Lines[0].Header = Inv));
      InvSvc.RemoveLine(Inv, Inv.Lines[1]);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('dispatch waiting again', Q('SELECT status FROM sls_dispatch WHERE id = ' + DspId.ToString) = SLS_DSP_WAITING);
      Check('invoice totals: 10 x 10 +%20', Near(Q('SELECT total_amount FROM sls_invoice WHERE id = ' + InvId.ToString), 120));

      // ---- belge içi fazla faturalama: aynı irsaliye kalemine ikinci satır
      IL := InvSvc.NewLine(Inv); IL.StkInventoryId := Inv1; IL.Quantity := 1; IL.UnitPrice := 10; IL.VatRate := 20;
      IL.SlsDispatchDetailId := Inv.Lines[0].SlsDispatchDetailId;
      Expect('over-invoice across lines rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);

      Begin_;
      // ---- irsaliyeli fatura (siparişten): stok faturadan düşer, kalem silinince hareket ve sevk miktarı geri
      OrdId := NewOrder(10, 4);
      OrdLine1 := Trunc(Q('SELECT id FROM sls_order_detail WHERE sls_order_id = ' + OrdId.ToString + ' AND line_no = 1'));
      InvId := InvSvc.CreateFromOrder(OrdId, Wh, True);
      Inv := InvSvc.BusinessFindById(InvId, False, False, True);
      Check('invoice from order: stock tx per line', Q('SELECT count(*) FROM stk_transaction t JOIN sls_invoice_detail d ON d.id = t.sls_invoice_detail_id ' +
        ' WHERE d.sls_invoice_id = ' + InvId.ToString) = 2);
      Inv.Lines[0].Quantity := 6;
      InvSvc.RemoveLine(Inv, Inv.Lines[1]);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('invoice edit: stock tx + delivered follow', (Q('SELECT quantity FROM stk_transaction WHERE sls_invoice_detail_id = ' + Inv.Lines[0].Id.ToString) = 6) and
        (Q('SELECT delivered_quantity FROM sls_order_detail WHERE id = ' + OrdLine1.ToString) = 6) and
        (Q('SELECT count(*) FROM stk_transaction t JOIN sls_invoice_detail d ON d.id = t.sls_invoice_detail_id WHERE d.sls_invoice_id = ' + InvId.ToString) = 1));

      // ---- stoklu (irsaliyesiz) kalem varken ambar boş olamaz
      Inv.StkWarehouseId := 0;
      Expect('stock line without warehouse rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
    except
      on E: Exception do
        Check('dispatch + invoice document flow', False, E.Message);
    end;
  finally
    End_;
    Inv.Free;
    Dsp.Free;
    Off.Free;
    InvSvc.Free;
    DspSvc.Free;
    OrdSvc.Free;
    OffSvc.Free;
  end;
end;

{ ---------------------------------------------------------------- e-Belge (UBL-TR) }

// Muhasebe fişi (TDocumentService): dengeli fiş kaydı (fiş no + yevmiye no servis), toplamlar kalemlerden, kalem
// değişikliği / çıkarma, dengesiz fiş reddi, SON olmayan hesap reddi, borç + alacak aynı satırda reddi, kopya.
// Reddedilen kayıt transaction'ı geri aldığı için her red yeni transaction'da kurulur.
procedure TestAccountingVoucher;
var
  Svc: TAccVoucherService;
  V, Copy: TAccVoucher;
  L: TAccVoucherDetail;
  Acc1, Acc2, MainAcc, VId: Int64;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  function NewVoucher(ADebit, ACredit: Currency): TAccVoucher;
  begin
    Result := TAccVoucher.Create;
    Result.VoucherType := ACC_VOUCHER_ADJUSTMENT;
    Result.Description := 'IT FIS';
    L := Svc.NewLine(Result); L.AccAccountId := Acc1; L.Debit := ADebit;
    L := Svc.NewLine(Result); L.AccAccountId := Acc2; L.Credit := ACredit;
  end;

begin
  Ctx('Account', 'voucher document');
  Acc1 := Scalar('SELECT min(id) FROM acc_account WHERE acc_set_account_type_id = 3');
  Acc2 := Scalar('SELECT max(id) FROM acc_account WHERE acc_set_account_type_id = 3');
  MainAcc := Scalar('SELECT min(id) FROM acc_account WHERE acc_set_account_type_id = 1');
  Svc := TAccVoucherService.Create;
  V := nil;
  Copy := nil;
  try
    try
      Begin_;
      V := NewVoucher(100, 100);
      Svc.BusinessSaveWithDetails(V, False, True);
      VId := V.Id;
      Check('voucher: saved, numbers by service', (VId > 0) and (V.VoucherNo <> '') and (V.JournalNo > 0) and
        (V.Lines.Count = 2) and (V.Lines[0].Id > 0) and (V.Lines[1].LineNo = 2) and (V.Lines[0].AccountCode <> ''));
      Check('voucher: totals from lines', Near(Q('SELECT total_debit FROM acc_voucher WHERE id = ' + VId.ToString), 100) and
        Near(Q('SELECT total_credit FROM acc_voucher WHERE id = ' + VId.ToString), 100));
      // 3 kalem: 100 borç = 60 + 40 alacak
      V.Lines[1].Credit := 60;
      L := Svc.NewLine(V); L.AccAccountId := Acc2; L.Credit := 40;
      Svc.BusinessSaveWithDetails(V, False, True);
      Check('voucher: changed + added line', (Q('SELECT count(*) FROM acc_voucher_detail WHERE acc_voucher_id = ' + VId.ToString) = 3) and
        Near(Q('SELECT total_credit FROM acc_voucher WHERE id = ' + VId.ToString), 100));
      Copy := V.Clone;
      Svc.PrepareCopy(Copy);
      Check('voucher copy: new numbers later, new lines', (Copy.Id = 0) and (Copy.VoucherNo = '') and (Copy.JournalNo = 0) and (Copy.Lines[0].Id < 0));
      Svc.BusinessSaveWithDetails(Copy, False, True);
      Check('voucher copy saved', (Copy.Id > 0) and (Copy.VoucherNo <> V.VoucherNo) and (Copy.JournalNo = V.JournalNo + 1));
      Svc.RemoveLine(V, V.Lines[2]);
      Expect('voucher: unbalanced after line removal rejected', procedure begin Svc.BusinessSaveWithDetails(V, False, True); end);
      FreeAndNil(V);
      FreeAndNil(Copy);

      Begin_;
      V := NewVoucher(100, 90);
      Expect('voucher: unbalanced rejected', procedure begin Svc.BusinessSaveWithDetails(V, False, True); end);
      FreeAndNil(V);

      Begin_;
      V := NewVoucher(100, 100);
      V.Lines[0].AccAccountId := MainAcc;
      Expect('voucher: main (non-detail) account rejected', procedure begin Svc.BusinessSaveWithDetails(V, False, True); end);
      FreeAndNil(V);

      Begin_;
      V := NewVoucher(100, 100);
      V.Lines[0].Credit := 5;
      Expect('voucher: debit and credit on one line rejected', procedure begin Svc.BusinessSaveWithDetails(V, False, True); end);
      FreeAndNil(V);

      Begin_;
      V := TAccVoucher.Create;
      Expect('voucher: no lines rejected', procedure begin Svc.BusinessSaveWithDetails(V, False, True); end);
    except
      on E: Exception do
        Check('voucher document flow', False, E.Message);
    end;
  finally
    End_;
    Copy.Free;
    V.Free;
    Svc.Free;
  end;
end;

// Üretim + DİİB belgeleri: reçete (beş liste tek kayıt: hammadde ana liste, işçilik / yan ürün ek listeler; satır no
// takası, ek listeden çıkarma, ürün kendi hammaddesi olamaz, aynı işçilik iki kez reddi, kopya), hammadde paketi,
// DİİB belgesi (satır kodu tekil). Commit yok: transaction geri alınır; reddedilen kayıt transaction'ı geri aldığı için
// her red yeni transaction'da kurulur.
procedure TestProductionDocuments;
var
  BSvc: TPrdBomService;
  PSvc: TPrdPacketRawService;
  DSvc: TEInvDiibService;
  Bom, Copy: TPrdBom;
  Pk: TPrdPacketRaw;
  Dib: TEInvDiib;
  R: TPrdBomRaw;
  Lb: TPrdBomLabour;
  Bp: TPrdBomByProduct;
  PL: TPrdPacketRawDetail;
  DL: TEInvDiibLine;
  Product, Inv1, Inv2, Labour, Gtip, BomId: Int64;
  LNo1, LNo2: SmallInt;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  function NewBom: TPrdBom;
  begin
    Result := TPrdBom.Create;
    Result.StkInventoryId := Product;
    Result.BomName := 'IT BOM DOC';
    Result.BaseQuantity := 1;
    Result.IsActive := True;
    R := BSvc.NewLine(Result); R.StkInventoryId := Inv1; R.Quantity := 2;
    R := BSvc.NewLine(Result); R.StkInventoryId := Inv2; R.Quantity := 3; R.ScrapRate := 10;
    Lb := BSvc.CreateItem<TPrdBomLabour>(Result, Result.Labours); Lb.PrdLabourId := Labour; Lb.Quantity := 1.5;
    BSvc.AddItem<TPrdBomLabour>(Result, Result.Labours, Lb);
    Bp := BSvc.CreateItem<TPrdBomByProduct>(Result, Result.ByProducts); Bp.StkInventoryId := Inv1; Bp.Quantity := 0.5;
    BSvc.AddItem<TPrdBomByProduct>(Result, Result.ByProducts, Bp);
  end;

begin
  Ctx('Production', 'documents');
  Product := Scalar('SELECT max(id) FROM stk_inventory');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Inv2 := Scalar('SELECT min(id) FROM stk_inventory WHERE id > ' + Inv1.ToString);
  Labour := Scalar('SELECT min(id) FROM prd_labour');
  Gtip := Scalar('SELECT min(id) FROM einv_gtip');
  BSvc := TPrdBomService.Create;
  PSvc := TPrdPacketRawService.Create;
  DSvc := TEInvDiibService.Create;
  Bom := nil;
  Copy := nil;
  Pk := nil;
  Dib := nil;
  try
    try
      // ---- reçete: beş liste tek kayıtta
      Begin_;
      Bom := NewBom;
      BSvc.BusinessSaveWithDetails(Bom, False, True);
      BomId := Bom.Id;
      Check('bom: saved with lists', (BomId > 0) and (Bom.Raws.Count = 2) and (Bom.Labours.Count = 1) and (Bom.ByProducts.Count = 1) and
        (Bom.Raws[0].Id > 0) and (Bom.Labours[0].Id > 0) and (Bom.Labours[0].LineNo = 1) and (Bom.Raws[1].Header = Bom));
      Check('bom: rows in DB', (Q('SELECT count(*) FROM prd_bom_raw WHERE prd_bom_id = ' + BomId.ToString) = 2) and
        (Q('SELECT count(*) FROM prd_bom_labour WHERE prd_bom_id = ' + BomId.ToString) = 1) and
        (Q('SELECT count(*) FROM prd_bom_by_product WHERE prd_bom_id = ' + BomId.ToString) = 1));
      FreeAndNil(Bom);
      Bom := BSvc.BusinessFindById(BomId, False, False, True);
      Check('bom: reload all lists', (Bom.Raws.Count = 2) and (Bom.Labours.Count = 1) and (Bom.ByProducts.Count = 1) and
        (Bom.PacketRaws.Count = 0) and (Bom.Labours[0].Header = Bom));
      LNo1 := Bom.Raws[0].LineNo;
      LNo2 := Bom.Raws[1].LineNo;
      Bom.Raws[0].LineNo := LNo2;
      Bom.Raws[1].LineNo := LNo1;
      BSvc.RemoveItem<TPrdBomByProduct>(Bom.ByProducts, Bom.ByProducts[0]);
      BSvc.BusinessSaveWithDetails(Bom, False, True);
      UoW.Connection.ExecSQL('SET CONSTRAINTS prd_bom_raw_line_key IMMEDIATE');
      Check('bom: raw line swap + by-product removed', (Bom.Raws.Count = 2) and (Bom.ByProducts.Count = 0) and
        (Q('SELECT count(*) FROM prd_bom_by_product WHERE prd_bom_id = ' + BomId.ToString) = 0));
      UoW.Connection.ExecSQL('SET CONSTRAINTS prd_bom_raw_line_key DEFERRED');
      Lb := BSvc.CreateItem<TPrdBomLabour>(Bom, Bom.Labours); Lb.PrdLabourId := Labour; Lb.Quantity := 1;
      BSvc.AddItem<TPrdBomLabour>(Bom, Bom.Labours, Lb);
      Expect('bom: same labour twice rejected', procedure begin BSvc.BusinessSaveWithDetails(Bom, False, True); end);
      FreeAndNil(Bom);

      // ---- ürün kendi hammaddesi olamaz; kopya yeni reçete (ad yeniden)
      Begin_;
      Bom := NewBom;
      BSvc.BusinessSaveWithDetails(Bom, False, True);
      Copy := Bom.Clone;
      BSvc.PrepareCopy(Copy);
      Copy.BomName := 'IT BOM DOC COPY';
      Check('bom copy: new lines in all lists', (Copy.Id = 0) and (Copy.Raws[0].Id < 0) and (Copy.Labours[0].Id < 0) and
        (Copy.ByProducts[0].Id < 0) and (Copy.Labours[0].PrdBomId = 0));
      BSvc.BusinessSaveWithDetails(Copy, False, True);
      Check('bom copy saved', (Copy.Id > 0) and (Copy.Id <> Bom.Id) and (Q('SELECT count(*) FROM prd_bom_labour WHERE prd_bom_id = ' + Copy.Id.ToString) = 1));
      R := BSvc.NewLine(Bom); R.StkInventoryId := Product; R.Quantity := 1;
      Expect('bom: product as own raw material rejected', procedure begin BSvc.BusinessSaveWithDetails(Bom, False, True); end);
      FreeAndNil(Bom);
      FreeAndNil(Copy);

      // ---- hammadde paketi
      Begin_;
      Pk := TPrdPacketRaw.Create;
      Pk.PacketName := 'IT PACKET DOC';
      PL := PSvc.NewLine(Pk); PL.StkInventoryId := Inv1; PL.Quantity := 4;
      PL := PSvc.NewLine(Pk); PL.StkInventoryId := Inv2; PL.Quantity := 1;
      PSvc.BusinessSaveWithDetails(Pk, False, True);
      Check('packet: saved with lines', (Pk.Id > 0) and (Pk.Lines.Count = 2) and (Pk.Lines[1].LineNo = 2) and
        (Q('SELECT count(*) FROM prd_packet_raw_detail WHERE prd_packet_raw_id = ' + Pk.Id.ToString) = 2));
      PSvc.RemoveLine(Pk, Pk.Lines[0]);
      PSvc.BusinessSaveWithDetails(Pk, False, True);
      Check('packet: line removed', (Pk.Lines.Count = 1) and (Q('SELECT count(*) FROM prd_packet_raw_detail WHERE prd_packet_raw_id = ' + Pk.Id.ToString) = 1));
      FreeAndNil(Pk);

      // ---- DİİB belgesi: satırlar, satır kodu tekil
      Begin_;
      Dib := TEInvDiib.Create;
      Dib.DocumentNo := 'IT-DIIB-DOC';
      Dib.HolderType := EINV_DIIB_OWN;
      Dib.IsActive := True;
      DL := DSvc.NewLine(Dib); DL.LineCode := '1'; DL.LineKind := 1; DL.EinvGtipId := Gtip; DL.ProductDescription := 'IT PRODUCT'; DL.Quantity := 10;
      DL := DSvc.NewLine(Dib); DL.LineCode := '2'; DL.LineKind := 1; DL.EinvGtipId := Gtip; DL.ProductDescription := 'IT PRODUCT 2'; DL.Quantity := 5;
      DSvc.BusinessSaveWithDetails(Dib, False, True);
      Check('diib: saved with lines', (Dib.Id > 0) and (Dib.Lines.Count = 2) and (Dib.Lines[0].Id > 0) and
        (Q('SELECT count(*) FROM einv_diib_line WHERE einv_diib_id = ' + Dib.Id.ToString) = 2));
      Dib.Lines[1].LineCode := '1';
      Expect('diib: duplicate line code rejected', procedure begin DSvc.BusinessSaveWithDetails(Dib, False, True); end);
    except
      on E: Exception do
        Check('production document flow', False, E.Message);
    end;
  finally
    End_;
    Dib.Free;
    Pk.Free;
    Copy.Free;
    Bom.Free;
    DSvc.Free;
    PSvc.Free;
    BSvc.Free;
  end;
end;

procedure TestEInvoice;
var
  GtipSvc: TEInvGtipService;
  WhSvc: TEInvWithholdingService;
  DiibSvc: TEInvDiibService;
  DiibLineSvc: TEInvDiibLineService;
  InvSvc: TSlsInvoiceService;
  LineSvc: TSlsInvoiceDetailService;
  G: TEInvGtip;
  W: TEInvWithholding;
  D: TEInvDiib;
  DL: TEInvDiibLine;
  Inv: TSlsInvoice;
  IL: TSlsInvoiceDetail;
  Inv1, Customer, Customer2, Wh, GtipA, OwnDiib, OwnLine, CustLine, OtherLine, InvId, LineId: Int64;
  PIdArchive, PIdExport, TSales, TExempt, TExportReg, TWithholding, Ex301, Ex702, Ex351, DtCif, DtFab, TmSea, PkBox, Wh602: Int64;
  Ex555, PmCash: Int64;
  Sc: TSlsEInvScope;
  DocSvc: TEInvDocumentService;
  Doc: TEInvDocument;
  LHtml: string;
  SerRepo: TEInvSeriesRepository;
  LUuid: string;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  function IdOf(const ATable, ACode: string): Int64;
  begin
    Result := Scalar('SELECT id FROM ' + ATable + ' WHERE code = ' + QuotedStr(ACode));
  end;

  function NewGtip(const ACode, AName: string): Int64;
  var
    LG: TEInvGtip;
  begin
    LG := TEInvGtip.Create;
    try
      LG.Code := ACode;
      LG.Name := AName;
      GtipSvc.BusinessInsert(LG, False, False, True);
      Result := LG.Id;
    finally
      LG.Free;
    end;
  end;

  function NewDiibLine(ADiibId: Int64; const ALineCode: string; AGtipId, AInventoryId: Int64): Int64;
  var
    LL: TEInvDiibLine;
  begin
    LL := TEInvDiibLine.Create;
    try
      LL.EinvDiibId := ADiibId;
      LL.LineCode := ALineCode;
      LL.EinvGtipId := AGtipId;
      LL.StkInventoryId := AInventoryId;
      LL.Quantity := 100;
      if AInventoryId <= 0 then
        LL.ProductDescription := 'Test urun';
      DiibLineSvc.BusinessInsert(LL, False, False, True);
      Result := LL.Id;
    finally
      LL.Free;
    end;
  end;

  // Yeni transaction + GTİP (stok kartına bağlı) + firmamızın / müşterinin / başka müşterinin DİİB satırları
  // (beklenen ret transaction'ı geri aldığı için her senaryo kendi verisini kurar)
  procedure Fresh;
  var
    LD: TEInvDiib;
  begin
    Begin_;
    GtipA := NewGtip('020622000000', 'Dana karaciğeri');
    UoW.Connection.ExecSQL('UPDATE stk_inventory SET einv_gtip_id = ' + GtipA.ToString + ' WHERE id = ' + Inv1.ToString);
    LD := TEInvDiib.Create;
    try
      LD.DocumentNo := 'DIIB-CUST-1'; LD.HolderType := EINV_DIIB_CUSTOMER; LD.AccAccountId := Customer;
      DiibSvc.BusinessInsert(LD, False, False, True);
      CustLine := NewDiibLine(LD.Id, 'A-1', GtipA, Inv1);
    finally
      LD.Free;
    end;
    LD := TEInvDiib.Create;
    try
      LD.DocumentNo := 'DIIB-OWN-1'; LD.HolderType := EINV_DIIB_OWN;
      DiibSvc.BusinessInsert(LD, False, False, True);
      OwnLine := NewDiibLine(LD.Id, 'S-1', GtipA, Inv1);
    finally
      LD.Free;
    end;
    LD := TEInvDiib.Create;
    try
      LD.DocumentNo := 'DIIB-CUST-2'; LD.HolderType := EINV_DIIB_CUSTOMER; LD.AccAccountId := Customer2;
      DiibSvc.BusinessInsert(LD, False, False, True);
      OtherLine := NewDiibLine(LD.Id, 'X-1', GtipA, 0);
    finally
      LD.Free;
    end;
  end;

  // XML testleri: satıcı (uygulama ayarları) + alıcının mükellef bilgisi ve fatura adresi
  procedure PrepareParties;
  begin
    UoW.Connection.ExecSQL('UPDATE sys_application_setting SET tax_no = ''1234567801'', tax_authority = ''Test VD'', ' +
      'taxpayer_type = ''VKN'', company_title = ''Ths Test A.Ş.'', sys_address_id = 3');
    UoW.Connection.ExecSQL('INSERT INTO acc_account_taxpayer (acc_account_id, taxpayer_type, taxpayer_name, tax_office, tax_no) ' +
      'VALUES (' + Customer.ToString + ', 1, ''Müşteri & Ortakları A.Ş.'', ''Kadıköy'', ''1111111111'') ' +
      'ON CONFLICT (acc_account_id) DO UPDATE SET taxpayer_type = 1, taxpayer_name = EXCLUDED.taxpayer_name, ' +
      'taxpayer_name2 = NULL, tax_office = EXCLUDED.tax_office, tax_no = EXCLUDED.tax_no');
    UoW.Connection.ExecSQL('WITH a AS (INSERT INTO sys_address (sys_city_id, district, street, door_number) ' +
      'SELECT sys_city_id, ''KADIKÖY'', ''Test Sokak'', ''5'' FROM sys_address WHERE id = 3 RETURNING id) ' +
      'INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type, is_primary) ' +
      'SELECT ' + Customer.ToString + ', id, ''BILLING'', true FROM a');
  end;

  // kayıtlı XML: şemaya uygun + beklenen parçalar
  procedure CheckDoc(const AName: string; AInvoiceId: Int64; const AParts: array of string);
  var
    LDoc: TEInvDocument;
    LPart, LMissing: string;
  begin
    LDoc := DocSvc.BusinessFindByInvoice(AInvoiceId, True);
    try
      LMissing := '';
      if Assigned(LDoc) then
        for LPart in AParts do
          if not LDoc.XmlContent.Contains(LPart) then
            LMissing := LMissing + ' [' + LPart + ']';
      if not Assigned(LDoc) then
        Check(AName, False, 'no einv_document')
      else
      begin
        // eksik parça: tutar bölümü teşhis için rapora
        if LMissing <> '' then
          LMissing := LMissing + ' ' + Copy(LDoc.XmlContent, Pos('<cac:LegalMonetaryTotal>', LDoc.XmlContent), 500);
        Check(AName, LDoc.IsValid and (LMissing = ''), LDoc.ValidationMessage + LMissing);
      end;
    finally
      LDoc.Free;
    end;
  end;

  // irsaliyesiz (stoklu) fatura: senaryo / tip / istisna verilir, kalem KDV oranıyla
  function NewInvoice(AAccountId, AProfileId, ATypeId, AExemptionId: Int64; AVat: Currency): TSlsInvoice;
  begin
    Result := TSlsInvoice.Create;
    Result.AccAccountId := AAccountId;
    Result.StkWarehouseId := Wh;
    Result.EinvProfileId := AProfileId;
    Result.EinvInvoiceTypeId := ATypeId;
    Result.EinvTaxExemptionId := AExemptionId;
    IL := InvSvc.NewLine(Result);
    IL.StkInventoryId := Inv1;
    IL.Quantity := 2;
    IL.UnitPrice := 50;
    IL.VatRate := AVat;
  end;

begin
  Ctx('EInvoice', 'code lists + DIIB + sales invoice');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Customer := Scalar('SELECT min(id) FROM acc_account');
  Customer2 := Scalar('SELECT min(id) FROM acc_account WHERE id > ' + Customer.ToString);
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  PIdArchive := IdOf('einv_profile', 'EARSIVFATURA');
  PIdExport := IdOf('einv_profile', 'IHRACAT');
  TSales := IdOf('einv_invoice_type', 'SATIS');
  TExempt := IdOf('einv_invoice_type', 'ISTISNA');
  TExportReg := IdOf('einv_invoice_type', 'IHRACKAYITLI');
  TWithholding := IdOf('einv_invoice_type', 'TEVKIFAT');
  Ex301 := IdOf('einv_tax_exemption', '301');
  Ex702 := IdOf('einv_tax_exemption', '702');
  Ex351 := IdOf('einv_tax_exemption', '351');
  DtCif := IdOf('einv_delivery_term', 'CIF');
  DtFab := IdOf('einv_delivery_term', 'FAB');
  TmSea := IdOf('einv_transport_mode', '1');
  PkBox := IdOf('einv_packaging_type', 'BX');
  Wh602 := IdOf('einv_withholding', '602');
  Ex555 := IdOf('einv_tax_exemption', '555');
  PmCash := Scalar('SELECT min(id) FROM einv_payment_means');
  Check('seed: code lists (UBL-TR Kod Listeleri v1.43)',
    (Q('SELECT count(*) FROM einv_profile') = 16) and (Q('SELECT count(*) FROM einv_invoice_type') = 18) and
    (Q('SELECT count(*) FROM einv_tax_exemption') = 112) and (Q('SELECT count(*) FROM einv_withholding') = 52) and
    (Q('SELECT count(*) FROM einv_packaging_type') = 27) and
    (Q('SELECT count(*) FROM einv_delivery_term WHERE is_incoterms AND is_active') = 15) and
    (Q('SELECT count(*) FROM einv_tax_type') = 29) and (Q('SELECT rate FROM einv_withholding WHERE code = ''602''') = 90));

  GtipSvc := TEInvGtipService.Create;
  WhSvc := TEInvWithholdingService.Create;
  DiibSvc := TEInvDiibService.Create;
  DiibLineSvc := TEInvDiibLineService.Create;
  InvSvc := TSlsInvoiceService.Create;
  LineSvc := TSlsInvoiceDetailService.Create;
  G := nil; W := nil; D := nil; DL := nil; Inv := nil;
  try
    try
      // ---- GTİP: noktalı giriş 12 haneye, geçersiz / mükerrer ret, kullanımdaki silinmez
      Begin_;
      GtipA := NewGtip('0206.22.00.00.00', 'Dana karaciğeri');
      Check('gtip normalized to 12 digits', S(Scalar('SELECT code FROM einv_gtip WHERE id = ' + GtipA.ToString)) = '020622000000');
      G := TEInvGtip.Create;
      G.Code := '1234'; G.Name := 'x';
      Expect('gtip invalid (not 12 digits) rejected', procedure begin GtipSvc.BusinessInsert(G, False, False, True); end);
      FreeAndNil(G);
      Begin_;
      GtipA := NewGtip('020622000000', 'Dana karaciğeri');
      G := TEInvGtip.Create;
      G.Code := '0206 22 00 00 00'; G.Name := 'tekrar';
      Expect('gtip duplicate rejected', procedure begin GtipSvc.BusinessInsert(G, False, False, True); end);
      FreeAndNil(G);
      Begin_;
      GtipA := NewGtip('020622000000', 'Dana karaciğeri');
      UoW.Connection.ExecSQL('UPDATE stk_inventory SET einv_gtip_id = ' + GtipA.ToString + ' WHERE id = ' + Inv1.ToString);
      G := GtipSvc.BusinessFindById(GtipA, False, False, True);
      Expect('gtip in use cannot be deleted', procedure begin GtipSvc.BusinessDelete(G, False, False, True); end);
      FreeAndNil(G);

      // ---- tevkifat oranı 0 < oran <= 100
      Begin_;
      W := TEInvWithholding.Create;
      W.Code := '999'; W.Name := 'Test'; W.Rate := 120;
      Expect('withholding rate > 100 rejected', procedure begin WhSvc.BusinessInsert(W, False, False, True); end);
      FreeAndNil(W);

      // ---- DİİB: firmamızın belgesinde cari yok, müşteri belgesinde zorunlu, tarih aralığı, satır kodu tekil
      Begin_;
      D := TEInvDiib.Create;
      D.DocumentNo := 'diib-own-1'; D.HolderType := EINV_DIIB_OWN; D.AccAccountId := Customer;
      DiibSvc.BusinessInsert(D, False, False, True);
      OwnDiib := D.Id;
      Check('own DIIB: number upper, account cleared', (S(Scalar('SELECT document_no FROM einv_diib WHERE id = ' + OwnDiib.ToString)) = 'DIIB-OWN-1') and
        (S(Scalar('SELECT acc_account_id FROM einv_diib WHERE id = ' + OwnDiib.ToString)) = '<null>'));
      FreeAndNil(D);
      D := TEInvDiib.Create;
      D.DocumentNo := 'DIIB-CUST-X'; D.HolderType := EINV_DIIB_CUSTOMER;
      Expect('customer DIIB without account rejected', procedure begin DiibSvc.BusinessInsert(D, False, False, True); end);
      FreeAndNil(D);
      Begin_;
      D := TEInvDiib.Create;
      D.DocumentNo := 'DIIB-CUST-1'; D.HolderType := EINV_DIIB_CUSTOMER; D.AccAccountId := Customer;
      D.IssueDate := Date; D.ValidUntil := Date - 1;
      Expect('DIIB validity before issue date rejected', procedure begin DiibSvc.BusinessInsert(D, False, False, True); end);
      FreeAndNil(D);

      Fresh;
      UoW.Connection.ExecSQL('UPDATE stk_inventory SET diib_product_description = ''Kartta DIIB tanimi'' WHERE id = ' + Inv1.ToString);
      OwnDiib := Scalar('SELECT id FROM einv_diib WHERE document_no = ''DIIB-OWN-1''');
      OwnLine := NewDiibLine(OwnDiib, 's-2', 0, Inv1);
      Check('DIIB line: gtip + description from stock card', (Q('SELECT einv_gtip_id FROM einv_diib_line WHERE id = ' + OwnLine.ToString) = GtipA) and
        (S(Scalar('SELECT product_description FROM einv_diib_line WHERE id = ' + OwnLine.ToString)) = 'Kartta DIIB tanimi') and
        (S(Scalar('SELECT line_code FROM einv_diib_line WHERE id = ' + OwnLine.ToString)) = 'S-2'));
      DL := TEInvDiibLine.Create;
      DL.EinvDiibId := OwnDiib; DL.LineCode := 's-1'; DL.EinvGtipId := GtipA; DL.StkInventoryId := Inv1;
      Expect('DIIB line code duplicate rejected', procedure begin DiibLineSvc.BusinessInsert(DL, False, False, True); end);
      FreeAndNil(DL);

      // ---- fatura: kağıt (senaryosuz) fatura e-belge kimliği taşımaz
      Begin_;
      UoW.Connection.ExecSQL('UPDATE stk_inventory SET einv_gtip_id = NULL WHERE id = ' + Inv1.ToString);
      Inv := NewInvoice(Customer, 0, 0, 0, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      Check('paper invoice: no uuid / status', (S(Scalar('SELECT einv_uuid FROM sls_invoice WHERE id = ' + InvId.ToString)) = '<null>') and
        (S(Scalar('SELECT einv_status FROM sls_invoice WHERE id = ' + InvId.ToString)) = '<null>'));
      FreeAndNil(Inv);

      // ---- e-arşiv: taslak durum + ETTN üretilir, güncellemede ETTN değişmez, kopyada boşalır
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      LUuid := Inv.EinvUuid;
      Check('e-archive: draft + uuid', (Inv.EinvStatus = EINV_STATUS_DRAFT) and (Length(LUuid) = 36) and
        (S(Scalar('SELECT einv_uuid::text FROM sls_invoice WHERE id = ' + InvId.ToString)) = LUuid),
        Format('status %d, uuid "%s", db "%s"', [Inv.EinvStatus, LUuid, S(Scalar('SELECT einv_uuid::text FROM sls_invoice WHERE id = ' + InvId.ToString))]));
      Inv.Description := 'degisti';
      Inv.EinvUuid := '';
      Inv.EinvStatus := EINV_STATUS_ACCEPTED;
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('update keeps uuid + status (service-maintained)', (Inv.EinvUuid = LUuid) and (Inv.EinvStatus = EINV_STATUS_DRAFT),
        Format('status %d, uuid "%s"', [Inv.EinvStatus, Inv.EinvUuid]));
      InvSvc.PrepareCopy(Inv);
      Check('copy clears uuid / status', (Inv.EinvUuid = '') and (Inv.EinvStatus = 0));
      FreeAndNil(Inv);

      // ---- senaryo var, tip yok -> ret; e-Fatura mükellefi önerisi
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, 0, 0, 20);
      Expect('profile without invoice type rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Inv := TSlsInvoice.Create;
      InvSvc.SuggestEInv(Inv, True);
      Check('suggest: e-invoice user -> TEMELFATURA / SATIS', (Inv.ProfileCode = 'TEMELFATURA') and (Inv.EinvInvoiceTypeId = TSales));
      FreeAndNil(Inv);
      Inv := TSlsInvoice.Create;
      InvSvc.SuggestEInv(Inv, False);
      Check('suggest: other -> EARSIVFATURA', Inv.EinvProfileId = PIdArchive);
      FreeAndNil(Inv);

      // ---- istisna: kod zorunlu, kod tipi uyumu, %0 KDV yalnız istisna koduyla
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TExempt, 0, 20);
      Expect('ISTISNA without exemption code rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 0);
      Expect('0% VAT without exemption code rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, Ex351, 0);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('SATIS + 351 + 0% VAT accepted', (Inv.Id > 0) and (Inv.VatAmount = 0));
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, Ex702, 0);
      Expect('exemption 702 on SATIS rejected (type mismatch)', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);

      // ---- ihraç kayıtlı (702): kalemde GTİP + alıcı DİİB satırı zorunlu
      Fresh;
      Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
      Expect('702 line without buyer DIIB rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Fresh;
      Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
      Inv.Lines[0].BuyerEinvDiibLineId := OtherLine;
      Expect('buyer DIIB line of another customer rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Fresh;
      Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
      Inv.Lines[0].BuyerEinvDiibLineId := CustLine;
      Inv.Lines[0].SellerEinvDiibLineId := CustLine;
      Expect('seller DIIB line must be own certificate', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Fresh;
      UoW.Connection.ExecSQL('UPDATE stk_inventory SET einv_gtip_id = NULL WHERE id = ' + Inv1.ToString);
      Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
      Inv.Lines[0].BuyerEinvDiibLineId := CustLine;
      Inv.Lines[0].SellerEinvDiibLineId := OwnLine;
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      Check('702 saved: gtip from DIIB line, codes in view',
        (Q('SELECT einv_gtip_id FROM sls_invoice_detail WHERE sls_invoice_id = ' + InvId.ToString) = GtipA) and
        (S(Scalar('SELECT buyer_diib_line_code || ''/'' || seller_diib_line_code || ''/'' || gtip_code FROM vw_sls_invoice_detail WHERE sls_invoice_id = ' + InvId.ToString)) = 'A-1/S-1/020622000000') and
        (S(Scalar('SELECT diib_product_description FROM vw_sls_invoice_detail WHERE sls_invoice_id = ' + InvId.ToString)) <> '<null>'));
      FreeAndNil(Inv);
      // kullanılan DİİB satırı silinmez
      DL := DiibLineSvc.BusinessFindById(CustLine, False, False, True);
      Expect('DIIB line used on invoice cannot be deleted', procedure begin DiibLineSvc.BusinessDelete(DL, False, False, True); end);
      FreeAndNil(DL);
      Fresh;
      Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
      Inv.Lines[0].BuyerEinvDiibLineId := CustLine;
      LineId := NewGtip('840510000000', 'Gaz jeneratörü');
      Inv.Lines[0].EinvGtipId := LineId;
      Expect('line GTIP different from DIIB line GTIP rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);

      // ---- ihracat senaryosu: INCOTERMS teslim şartı + taşıma şekli + kalemde GTİP / kap cinsi / kap adedi
      Fresh;
      Inv := NewInvoice(Customer, PIdExport, TExempt, Ex301, 0);
      Expect('export without delivery term rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Fresh;
      Inv := NewInvoice(Customer, PIdExport, TExempt, Ex301, 0);
      Inv.EinvDeliveryTermId := DtFab;
      Inv.EinvTransportModeId := TmSea;
      Expect('export with non-INCOTERMS delivery term rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Fresh;
      Inv := NewInvoice(Customer, PIdExport, TExempt, Ex301, 0);
      Inv.EinvDeliveryTermId := DtCif;
      Inv.EinvTransportModeId := TmSea;
      Expect('export line without package rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Fresh;
      Inv := NewInvoice(Customer, PIdExport, TExempt, Ex301, 0);
      Inv.EinvDeliveryTermId := DtCif;
      Inv.EinvTransportModeId := TmSea;
      Inv.Lines[0].EinvPackagingTypeId := PkBox;
      Inv.Lines[0].PackageQuantity := 3;
      Inv.Lines[0].PackageNo := 'cnt-1';
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('export saved: gtip from stock card, package no upper',
        (Q('SELECT einv_gtip_id FROM sls_invoice_detail WHERE sls_invoice_id = ' + Inv.Id.ToString) = GtipA) and
        (S(Scalar('SELECT package_no FROM sls_invoice_detail WHERE sls_invoice_id = ' + Inv.Id.ToString)) = 'CNT-1'));
      FreeAndNil(Inv);

      // ---- KDV istisnası (requires_zero_vat) KDV'li kalemlere uygulanmaz; 555 KDV'li kalemle kullanılır
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TExempt, Ex301, 20);
      Expect('KDV exemption 301 without a 0% VAT line rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, Ex555, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('SATIS + 555 with VAT line accepted', (Inv.Id > 0) and (Inv.VatAmount > 0));
      FreeAndNil(Inv);

      // ---- uygulanamayan alanlar kayda gitmez: ihracat dışında teslim / taşıma / gümrük, 702 dışında DİİB, GTİP / kap
      Fresh;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      Inv.EinvDeliveryTermId := DtCif;
      Inv.EinvTransportModeId := TmSea;
      Inv.CustomsDeclarationNo := 'GCB-1';
      Inv.GtbRefNo := 'REF-1';
      Inv.ActualExportDate := Date;
      Inv.Lines[0].EinvGtipId := GtipA;
      Inv.Lines[0].EinvPackagingTypeId := PkBox;
      Inv.Lines[0].PackageQuantity := 3;
      Inv.Lines[0].PackageNo := 'CNT-9';
      Inv.Lines[0].BuyerEinvDiibLineId := CustLine;
      Inv.Lines[0].SellerEinvDiibLineId := OwnLine;
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      Check('non-export: export header fields cleared',
        S(Scalar('SELECT concat_ws(''/'', einv_delivery_term_id, einv_transport_mode_id, customs_declaration_no, gtb_ref_no, actual_export_date) ' +
          'FROM sls_invoice WHERE id = ' + InvId.ToString)) = '',
        S(Scalar('SELECT concat_ws(''/'', einv_delivery_term_id, einv_transport_mode_id, customs_declaration_no, gtb_ref_no, actual_export_date) ' +
          'FROM sls_invoice WHERE id = ' + InvId.ToString)));
      Check('non-702 / non-export: DIIB codes, GTIP, package cleared',
        S(Scalar('SELECT concat_ws(''/'', seller_einv_diib_line_id, buyer_einv_diib_line_id, einv_gtip_id, einv_packaging_type_id, ' +
          'package_no, package_quantity) FROM sls_invoice_detail WHERE sls_invoice_id = ' + InvId.ToString)) = '',
        S(Scalar('SELECT concat_ws(''/'', seller_einv_diib_line_id, buyer_einv_diib_line_id, einv_gtip_id, einv_packaging_type_id, ' +
          'package_no, package_quantity) FROM sls_invoice_detail WHERE sls_invoice_id = ' + InvId.ToString)));
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, 0, 0, 0, 20);
      Inv.EinvPaymentMeansId := PmCash;
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('paper invoice: payment means cleared', S(Scalar('SELECT einv_payment_means_id FROM sls_invoice WHERE id = ' + Inv.Id.ToString)) = '<null>');
      FreeAndNil(Inv);

      // ---- form kapsamı (GetEInvScope) + tip önerisi
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
      Sc := InvSvc.EInvScope(Inv);
      Check('scope 702: DIIB + customs line, needs 0% VAT, no export header',
        Sc.DiibAllowed and Sc.CustomsLine and Sc.GtipRequired and Sc.ExemptionNeedsZeroVat and Sc.HasZeroVatLine and
        not Sc.IsExport and not Sc.PackageRequired and not Sc.WithholdingAllowed);
      Inv.EinvInvoiceTypeId := TSales;
      Sc := InvSvc.EInvScope(Inv);
      Check('scope: 702 on SATIS = type mismatch', Sc.ExemptionTypeMismatch);
      Inv.EinvTaxExemptionId := 0;
      Inv.Lines[0].VatRate := 20;
      Sc := InvSvc.EInvScope(Inv);
      Check('scope SATIS: no DIIB / customs line, exemption still available (555)',
        not Sc.DiibAllowed and not Sc.CustomsLine and not Sc.ExemptionRequired and Sc.ExemptionAvailable and not Sc.HasZeroVatLine);
      Inv.EinvProfileId := PIdExport;
      Inv.EinvInvoiceTypeId := TExempt;
      Sc := InvSvc.EInvScope(Inv);
      Check('scope IHRACAT: export header + package required', Sc.IsExport and Sc.PackageRequired and Sc.CustomsLine and Sc.ExemptionRequired);
      Inv.EinvProfileId := 0;
      Inv.EinvInvoiceTypeId := 0;
      Sc := InvSvc.EInvScope(Inv);
      Check('scope paper: withholding allowed, no e-doc fields', Sc.WithholdingAllowed and not Sc.IsEDoc and not Sc.IsExport);
      FreeAndNil(Inv);
      Inv := TSlsInvoice.Create;
      Inv.EinvProfileId := PIdExport;
      Inv.ProfileCode := 'IHRACAT';
      InvSvc.SuggestInvoiceType(Inv);
      Check('suggest type: IHRACAT -> ISTISNA', Inv.EinvInvoiceTypeId = TExempt);
      FreeAndNil(Inv);

      // ---- UBL-TR XML: kayıtta üretilir + GİB şemasıyla doğrulanır (einv_document), önizleme, numara sayacı
      DocSvc := TEInvDocumentService.Create;
      try
        Begin_;
        PrepareParties;
        Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
        InvSvc.BusinessSaveWithDetails(Inv, False, True);
        InvId := Inv.Id;
        CheckDoc('xml e-archive SATIS: schema valid', InvId,
          ['<cbc:ProfileID>EARSIVFATURA</cbc:ProfileID>', '<cbc:ID>EAR' + IntToStr(YearOf(Inv.InvoiceDate)) + '000000000</cbc:ID>',
           'Müşteri &amp; Ortakları', '<cbc:UUID>' + UpperCase(Inv.EinvUuid) + '</cbc:UUID>', 'schemeID="VKN">1111111111']);
        Doc := DocSvc.BusinessFindByInvoice(InvId, True);
        try
          LHtml := '';
          if Assigned(Doc) then
            LHtml := TEInvDocumentService.ToHtml(Doc);
          Check('xml preview (general.xslt) html', LHtml.Length > 1000, IntToStr(LHtml.Length));
        finally
          FreeAndNil(Doc);
        end;
        Inv.EinvProfileId := 0;
        Inv.EinvInvoiceTypeId := 0;
        InvSvc.BusinessSaveWithDetails(Inv, False, True);
        Check('paper invoice: e-document xml removed', Q('SELECT count(*) FROM einv_document WHERE sls_invoice_id = ' + InvId.ToString) = 0);
        FreeAndNil(Inv);

        Begin_;
        PrepareParties;
        Inv := NewInvoice(Customer, PIdArchive, TWithholding, 0, 20);
        Inv.Lines[0].EinvWithholdingId := Wh602;
        InvSvc.BusinessSaveWithDetails(Inv, False, True);
        CheckDoc('xml TEVKIFAT: schema valid + withholding', Inv.Id,
          ['<cac:WithholdingTaxTotal>', '<cbc:TaxTypeCode>602</cbc:TaxTypeCode>', '>102.00</cbc:PayableAmount>', '>120.00</cbc:TaxInclusiveAmount>']);
        FreeAndNil(Inv);

        Fresh;
        PrepareParties;
        Inv := NewInvoice(Customer, PIdExport, TExempt, Ex301, 0);
        Inv.EinvDeliveryTermId := DtCif;
        Inv.EinvTransportModeId := TmSea;
        Inv.Lines[0].EinvPackagingTypeId := PkBox;
        Inv.Lines[0].PackageQuantity := 3;
        Inv.Lines[0].PackageNo := 'CNT-1';
        InvSvc.BusinessSaveWithDetails(Inv, False, True);
        CheckDoc('xml IHRACAT: schema valid + GTB customer / export buyer / customs', Inv.Id,
          ['schemeID="VKN">' + EINV_EXPORT_CUSTOMER_VKN, 'schemeID="PARTYTYPE">EXPORT', 'schemeID="INCOTERMS">CIF',
           '<cbc:RequiredCustomsID>020622000000</cbc:RequiredCustomsID>', '<cbc:PackagingTypeCode>BX</cbc:PackagingTypeCode>',
           '<cbc:TaxExemptionReasonCode>301</cbc:TaxExemptionReasonCode>']);
        FreeAndNil(Inv);

        Fresh;
        PrepareParties;
        Inv := NewInvoice(Customer, PIdArchive, TExportReg, Ex702, 0);
        Inv.Lines[0].BuyerEinvDiibLineId := CustLine;
        Inv.Lines[0].SellerEinvDiibLineId := OwnLine;
        InvSvc.BusinessSaveWithDetails(Inv, False, True);
        CheckDoc('xml IHRACKAYITLI 702: schema valid + DIIB line codes', Inv.Id,
          ['schemeID="ALICIDIBSATIRKOD">A-1', 'schemeID="SATICIDIBSATIRKOD">S-1', '<cbc:TaxExemptionReasonCode>702</cbc:TaxExemptionReasonCode>']);
        FreeAndNil(Inv);

        // eksik satıcı vergi no: kayıt olur, XML geçersiz + mesaj
        Begin_;
        PrepareParties;
        UoW.Connection.ExecSQL('UPDATE sys_application_setting SET tax_no = NULL');
        Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
        InvSvc.BusinessSaveWithDetails(Inv, False, True);
        Check('xml: missing seller tax no -> saved, invalid with message',
          (Inv.Id > 0) and (S(Scalar('SELECT is_valid::text FROM einv_document WHERE sls_invoice_id = ' + Inv.Id.ToString)) = 'false') and
          (S(Scalar('SELECT validation_message FROM einv_document WHERE sls_invoice_id = ' + Inv.Id.ToString)) <> '<null>'),
          S(Scalar('SELECT validation_message FROM einv_document WHERE sls_invoice_id = ' + Inv.Id.ToString)));
        FreeAndNil(Inv);

        // GİB numara sayacı: yıl içinde artar, belge no biçimi
        Begin_;
        SerRepo := TEInvSeriesRepository(UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>);
        LineId := Scalar('SELECT id FROM einv_series WHERE code = ''EFT''');
        Check('series counter: 1, 2 + number format',
          (SerRepo.NextNumber(LineId, 2099) = 1) and (SerRepo.NextNumber(LineId, 2099) = 2) and
          TEInvLookup.IsValidEInvNo(TEInvLookup.MakeEInvNo('EFT', 2099, 2)) and
          (TEInvLookup.MakeEInvNo('EFT', 2099, 2) = 'EFT2099000000002'));
        End_;
      finally
        DocSvc.Free;
      end;

      // ---- tevkifat: tip tevkifat ise en az bir kalemde kod, tutar = KDV x oran, cari borç = toplam - tevkifat
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TWithholding, 0, 20);
      Expect('TEVKIFAT without withholding line rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      Inv.Lines[0].EinvWithholdingId := Wh602;
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      // 2 x 50 = 100, KDV 20, tevkifat %90 = 18
      Check('withholding amounts (line / header / payable)',
        Near(Q('SELECT withholding_amount FROM sls_invoice_detail WHERE sls_invoice_id = ' + InvId.ToString), 18) and
        Near(Q('SELECT withholding_amount FROM sls_invoice WHERE id = ' + InvId.ToString), 18) and
        Near(Q('SELECT payable_amount FROM vw_sls_invoice WHERE id = ' + InvId.ToString), 102));
      Check('account transaction debit = total - withholding',
        Near(Q('SELECT debit FROM vw_acc_account_transaction WHERE source_type = 6 AND source_id = ' + InvId.ToString), 102));
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      Inv.Lines[0].EinvWithholdingId := Wh602;
      Expect('withholding on SATIS rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);

      // ---- pasif kod: yeni seçimde ret, kayıtlı (değişmeyen) belgede güncelleme serbest
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      UoW.Connection.ExecSQL('UPDATE einv_profile SET is_active = false WHERE id = ' + PIdArchive.ToString);
      Inv.Description := 'pasif senaryo, degismedi';
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      Check('passive profile kept on unchanged invoice', Inv.Description = 'pasif senaryo, degismedi');
      FreeAndNil(Inv);
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      Expect('passive profile on new invoice rejected', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);

      // ---- gönderilmiş e-belge kilidi: başlık / kalem / silme reddedilir
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      LineId := Inv.Lines[0].Id;
      UoW.Connection.ExecSQL('UPDATE sls_invoice SET einv_status = ' + IntToStr(EINV_STATUS_SENT) + ' WHERE id = ' + InvId.ToString);
      FreeAndNil(Inv);
      Inv := InvSvc.BusinessFindById(InvId, False, False, True);
      Inv.Description := 'gonderildikten sonra';
      Expect('sent invoice cannot be updated', procedure begin InvSvc.BusinessSaveWithDetails(Inv, False, True); end);
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      LineId := Inv.Lines[0].Id;
      UoW.Connection.ExecSQL('UPDATE sls_invoice SET einv_status = ' + IntToStr(EINV_STATUS_SENT) + ' WHERE id = ' + InvId.ToString);
      Inv.EinvStatus := EINV_STATUS_SENT;
      Expect('sent invoice cannot be deleted', procedure begin InvSvc.BusinessDelete(Inv, False, False, True); end);
      FreeAndNil(Inv);
      Begin_;
      Inv := NewInvoice(Customer, PIdArchive, TSales, 0, 20);
      InvSvc.BusinessSaveWithDetails(Inv, False, True);
      InvId := Inv.Id;
      LineId := Inv.Lines[0].Id;
      UoW.Connection.ExecSQL('UPDATE sls_invoice SET einv_status = ' + IntToStr(EINV_STATUS_SENT) + ' WHERE id = ' + InvId.ToString);
      FreeAndNil(Inv);
      IL := LineSvc.BusinessFindById(LineId, False, False, True);
      try
        IL.Quantity := 5;
        Expect('sent invoice line cannot be changed (line service)', procedure begin LineSvc.BusinessUpdate(IL, False, False, True); end);
      finally
        IL.Free;
      end;
    except
      on E: Exception do
        Check('e-invoice flow', False, E.Message);
    end;
  finally
    End_;
    Inv.Free;
    DL.Free;
    D.Free;
    W.Free;
    G.Free;
    LineSvc.Free;
    InvSvc.Free;
    DiibLineSvc.Free;
    DiibSvc.Free;
    WhSvc.Free;
    GtipSvc.Free;
  end;
end;

{ ---------------------------------------------------------------- DB error messages }

procedure TestDbErrors;

  function RaiseOf(const ASql: string; ARollback: Boolean = True): string;
  begin
    Result := '<no error>';
    Begin_;
    try
      UoW.Connection.ExecSQL(ASql);
    except
      on E: Exception do
      begin
        // uygulamada servis / form hatadan önce rollback yapar
        if ARollback and UoW.InTransaction then
          UoW.Rollback;
        Result := TDbErrorTranslator.Translate(E);
      end;
    end;
    End_;
  end;

var
  LMsg, LCityTitle: string;
  LCountryId: Int64;
  LPlain: Exception;
begin
  Ctx('Core', 'TDbErrorTranslator');
  // yalnız şehirde kullanılan ülke (stok kartında değil): detay şehirler olmalı
  LCountryId := Scalar('SELECT sys_country_id FROM sys_city WHERE sys_country_id NOT IN ' +
    '(SELECT sys_country_id FROM stk_inventory WHERE sys_country_id IS NOT NULL) ORDER BY id LIMIT 1');
  LCityTitle := TLocalizationManager.Translate(TLangKeys.TSysCity.TitlePlural, 'sys_city');

  LMsg := RaiseOf('DELETE FROM sys_country WHERE id = ' + LCountryId.ToString);
  Check('fk in use', LMsg.StartsWith(TLocalizationManager.Translate(TLangKeys.TDbError.FkInUse)) and LMsg.Contains(LCityTitle), LMsg);

  // NO ACTION (tek örnek: sys_menu üst klasör) -> 23503, ana tablo mesajda
  LMsg := RaiseOf('DELETE FROM sys_menu WHERE menu_code = (SELECT parent_code FROM sys_menu WHERE parent_code IS NOT NULL LIMIT 1)');
  Check('fk in use (no action)', LMsg.StartsWith(TLocalizationManager.Translate(TLangKeys.TDbError.FkInUse)), LMsg);

  LMsg := RaiseOf('INSERT INTO sys_city (city_name, sys_country_id) VALUES (''IT CITY'', -1)');
  Check('fk missing', LMsg.StartsWith(TLocalizationManager.Translate(TLangKeys.TDbError.FkMissing)) and
    LMsg.Contains(TLocalizationManager.Translate(TLangKeys.TSysCountry.TitlePlural, 'sys_country')), LMsg);

  LMsg := RaiseOf('DELETE FROM sys_country WHERE id = ' + LCountryId.ToString, False);
  Check('fk in aborted transaction', LMsg.StartsWith(TLocalizationManager.Translate(TLangKeys.TDbError.FkInUse)), LMsg);

  LMsg := RaiseOf('INSERT INTO sys_city (city_name, sys_country_id) SELECT city_name, sys_country_id FROM sys_city ORDER BY id LIMIT 1');
  Check('unique', LMsg.StartsWith(TLocalizationManager.Translate(TLangKeys.TDbError.Unique)), LMsg);

  LMsg := RaiseOf('INSERT INTO sys_city (city_name, sys_country_id) VALUES (NULL, ' + LCountryId.ToString + ')');
  Check('not null', LMsg.StartsWith(TLocalizationManager.Translate(TLangKeys.TDbError.NotNull)) and LMsg.Contains('city_name'), LMsg);

  LMsg := RaiseOf('SELECT 1/0');
  Check('other db error not translated', LMsg = '', LMsg);

  LPlain := Exception.Create('plain');
  try
    Check('plain exception message kept', TDbErrorTranslator.FriendlyMessage(LPlain) = 'plain');
  finally
    LPlain.Free;
  end;
end;

{ ---------------------------------------------------------------- e-İrsaliye }

procedure TestEDespatch;
var
  VehSvc: TEInvVehicleService;
  DrvSvc: TEInvDriverService;
  DspSvc: TSlsDispatchService;
  DspLineSvc: TSlsDispatchDetailService;
  DocSvc: TEInvDocumentService;
  Dsp: TSlsDispatch;
  DL: TSlsDispatchDetail;
  Doc: TEInvDocument;
  Inv1, Customer, Carrier, Wh, PDesp, PInvoice, Truck, Trailer1, Trailer2, Driver1, Driver2, DspId: Int64;
  LHtml: string;

  function NewVehicle(const APlate: string; ATrailer: Boolean): Int64;
  var
    V: TEInvVehicle;
  begin
    V := TEInvVehicle.Create;
    try
      V.PlateNo := APlate;
      V.IsTrailer := ATrailer;
      VehSvc.BusinessInsert(V, False, False, True);
      Result := V.Id;
    finally
      V.Free;
    end;
  end;

  function NewDriver(const AFirst, AFamily, ANationalId: string): Int64;
  var
    D: TEInvDriver;
  begin
    D := TEInvDriver.Create;
    try
      D.FirstName := AFirst;
      D.FamilyName := AFamily;
      D.NationalId := ANationalId;
      DrvSvc.BusinessInsert(D, False, False, True);
      Result := D.Id;
    finally
      D.Free;
    end;
  end;

  // Yeni transaction + taraflar (firma VKN / adres, müşterinin sevk adresi, taşıyıcı) + e-İrsaliye serisi + araçlar / şoförler
  // (beklenen ret transaction'ı geri aldığı için her senaryo kendi verisini kurar)
  procedure Fresh;
  begin
    Begin_;
    UoW.Connection.ExecSQL('UPDATE sys_application_setting SET tax_no = ''1234567801'', tax_authority = ''Test VD'', ' +
      'taxpayer_type = ''VKN'', company_title = ''Ths Test A.Ş.'', sys_address_id = 3');
    UoW.Connection.ExecSQL('INSERT INTO acc_account_taxpayer (acc_account_id, taxpayer_type, taxpayer_name, tax_office, tax_no) ' +
      'VALUES (' + Customer.ToString + ', 1, ''Alıcı Ltd. Şti.'', ''Kadıköy'', ''1111111111''), ' +
      '(' + Carrier.ToString + ', 1, ''Taşıyıcı Lojistik A.Ş.'', ''Ulus'', ''2222222222'') ' +
      'ON CONFLICT (acc_account_id) DO UPDATE SET taxpayer_type = 1, taxpayer_name = EXCLUDED.taxpayer_name, ' +
      'taxpayer_name2 = NULL, tax_office = EXCLUDED.tax_office, tax_no = EXCLUDED.tax_no');
    UoW.Connection.ExecSQL('WITH a AS (INSERT INTO sys_address (sys_city_id, district, street, door_number) ' +
      'SELECT sys_city_id, ''ÇANKAYA'', ''Depo Caddesi'', ''7'' FROM sys_address WHERE id = 3 RETURNING id) ' +
      'INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type, is_primary) ' +
      'SELECT ' + Customer.ToString + ', id, ''SHIPPING'', false FROM a');
    UoW.Connection.ExecSQL('INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type, is_primary) ' +
      'VALUES (' + Carrier.ToString + ', 3, ''LEGAL'', true)');
    // e-İrsaliye serisi firma ayarındaki belge türü satırından
    UoW.Connection.ExecSQL('WITH s AS (INSERT INTO einv_series (code, name, series_scope, is_active) ' +
      'VALUES (''ITI'', ''IT e-Irsaliye'', 3, true) RETURNING id) ' +
      'UPDATE einv_document_setting SET einv_series_id = (SELECT id FROM s) WHERE series_scope = 3');
    Truck := NewVehicle('34 abc-123', False);
    Trailer1 := NewVehicle('34 DR 001', True);
    Trailer2 := NewVehicle('34DR002', True);
    Driver1 := NewDriver('Mehmet', 'Öztürk', '10000000146');
    Driver2 := NewDriver('Ayşe', 'Kaya', '12345678950');
  end;

  function NewDispatch(AProfileId: Int64): TSlsDispatch;
  begin
    Result := TSlsDispatch.Create;
    Result.AccAccountId := Customer;
    Result.StkWarehouseId := Wh;
    Result.EinvProfileId := AProfileId;
    DL := DspSvc.NewLine(Result);
    DL.StkInventoryId := Inv1;
    DL.Quantity := 3;
    DL.UnitPrice := 40;
    DL.Description := 'Test sevk';
  end;

  // kaydet; beklenmeyen hata rapora
  function Save(ADsp: TSlsDispatch): Boolean;
  begin
    try
      DspSvc.BusinessSaveWithDetails(ADsp, False, True);
      Result := True;
    except
      on E: Exception do
      begin
        Report('FAIL', GMod, GEnt, 'save', E.ClassName + ': ' + E.Message);
        Result := False;
      end;
    end;
  end;

  procedure ExpectSave(const AStep: string; ADsp: TSlsDispatch);
  begin
    Expect(AStep, procedure
      begin
        DspSvc.BusinessSaveWithDetails(ADsp, False, True);
      end);
  end;

  procedure CheckDoc(const AName: string; ADispatchId: Int64; const AParts, AAbsent: array of string);
  var
    LDoc: TEInvDocument;
    LPart, LMissing: string;
  begin
    LDoc := DocSvc.BusinessFindByDispatch(ADispatchId, True);
    try
      if not Assigned(LDoc) then
      begin
        Check(AName, False, 'no einv_document');
        Exit;
      end;
      LMissing := '';
      for LPart in AParts do
        if not LDoc.XmlContent.Contains(LPart) then
          LMissing := LMissing + ' [missing ' + LPart + ']';
      for LPart in AAbsent do
        if LDoc.XmlContent.Contains(LPart) then
          LMissing := LMissing + ' [unexpected ' + LPart + ']';
      Check(AName, LDoc.IsValid and (LMissing = ''), LDoc.ValidationMessage + LMissing);
    finally
      LDoc.Free;
    end;
  end;

begin
  Ctx('EInvoice', 'e-despatch advice');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Customer := Scalar('SELECT min(id) FROM acc_account');
  Carrier := Scalar('SELECT min(id) FROM acc_account WHERE id > ' + Customer.ToString);
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  PDesp := Scalar('SELECT id FROM einv_profile WHERE code = ''TEMELIRSALIYE''');
  PInvoice := Scalar('SELECT id FROM einv_profile WHERE code = ''TEMELFATURA''');
  VehSvc := TEInvVehicleService.Create;
  DrvSvc := TEInvDriverService.Create;
  DspSvc := TSlsDispatchService.Create;
  DspLineSvc := TSlsDispatchDetailService.Create;
  DocSvc := TEInvDocumentService.Create;
  try
    try
      // ---- araç / şoför tanımları
      Fresh;
      Check('plate normalized', S(Scalar('SELECT plate_no FROM einv_vehicle WHERE id = ' + Truck.ToString)) = '34ABC123');
      Check('valid national id', TEInvLookup.IsValidNationalId('10000000146') and not TEInvLookup.IsValidNationalId('12345678901'));
      Expect('duplicate plate', procedure
        var V: TEInvVehicle;
        begin
          V := TEInvVehicle.Create;
          try
            V.PlateNo := '34ABC 123'; V.IsTrailer := False;
            VehSvc.BusinessInsert(V, False, False, True);
          finally
            V.Free;
          end;
        end);
      Fresh;
      Expect('invalid plate', procedure
        var V: TEInvVehicle;
        begin
          V := TEInvVehicle.Create;
          try
            V.PlateNo := 'A-1'; V.IsTrailer := False;
            VehSvc.BusinessInsert(V, False, False, True);
          finally
            V.Free;
          end;
        end);
      Fresh;
      Expect('invalid national id', procedure
        var D: TEInvDriver;
        begin
          D := TEInvDriver.Create;
          try
            D.FirstName := 'Ali'; D.FamilyName := 'Veli'; D.NationalId := '12345678901';
            DrvSvc.BusinessInsert(D, False, False, True);
          finally
            D.Free;
          end;
        end);
      Fresh;
      Expect('duplicate national id', procedure
        var D: TEInvDriver;
        begin
          D := TEInvDriver.Create;
          try
            D.FirstName := 'Ali'; D.FamilyName := 'Veli'; D.NationalId := '10000000146';
            DrvSvc.BusinessInsert(D, False, False, True);
          finally
            D.Free;
          end;
        end);

      // ---- e-İrsaliye: araç + dorseler + iki şoför; XML şemaya uygun, fiyatsız
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.EinvVehicleId := Truck;
        Dsp.Trailer1EinvVehicleId := Trailer1;
        Dsp.Trailer2EinvVehicleId := Trailer2;
        Dsp.Driver1EinvDriverId := Driver1;
        Dsp.Driver2EinvDriverId := Driver2;
        if Save(Dsp) then
        begin
          DspId := Dsp.Id;
          Check('uuid generated', Length(Dsp.EinvUuid) = 36, Dsp.EinvUuid);
          Check('status draft', Dsp.EinvStatus = EINV_STATUS_DRAFT);
          Check('despatch time set', Dsp.DespatchTime > 0);
          Check('reload view fields', (Dsp.ProfileCode = 'TEMELIRSALIYE') and (Dsp.VehiclePlate = '34ABC123') and
            (Dsp.Driver1Name = 'Mehmet Öztürk'), Dsp.ProfileCode + ' / ' + Dsp.VehiclePlate + ' / ' + Dsp.Driver1Name);
          CheckDoc('despatch xml valid (truck)', DspId,
            ['<DespatchAdvice', 'TEMELIRSALIYE', '<cbc:DespatchAdviceTypeCode>SEVK', 'schemeID="PLAKA">34ABC123',
             'schemeID="DORSEPLAKA">34DR001', 'schemeID="DORSEPLAKA">34DR002', '<cbc:NationalityID>10000000146',
             '<cbc:NationalityID>12345678950', '<cbc:ID>ITI' + IntToStr(YearOf(Date)) + '000000000', 'ÇANKAYA',
             '<cbc:ActualDespatchDate>', '<cbc:DeliveredQuantity unitCode=', 'Test sevk'],
            ['PriceAmount', 'LineExtensionAmount', 'ValueAmount', '<cac:CarrierParty>']);
          Doc := DocSvc.BusinessFindByDispatch(DspId, True);
          try
            LHtml := TEInvDocumentService.ToHtml(Doc);
            Check('preview html (irsaliye.xslt)', LHtml.Contains('34ABC123'), Copy(LHtml, 1, 200));
          finally
            Doc.Free;
          end;
          // kopya: e-belge kimliği / durumu kopyalanmaz, taşıma kalır
          DspSvc.PrepareCopy(Dsp);
          Check('copy clears e-document identity', (Dsp.EinvUuid = '') and (Dsp.EinvStatus = 0) and (Dsp.EinvVehicleId = Truck));
        end;
      finally
        Dsp.Free;
      end;
      Expect('vehicle in use cannot be deleted', procedure
        var V: TEInvVehicle;
        begin
          V := VehSvc.BusinessFindById(Truck, False, False, True);
          try
            VehSvc.BusinessDelete(V, False, False, True);
          finally
            V.Free;
          end;
        end);

      // ---- yalnız taşıyıcı firma
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.CarrierAccAccountId := Carrier;
        if Save(Dsp) then
          CheckDoc('despatch xml valid (carrier)', Dsp.Id, ['<cac:CarrierParty>', '2222222222', '<cac:Despatch>'],
            ['<cac:ShipmentStage>', 'DORSEPLAKA']);
      finally
        Dsp.Free;
      end;

      // ---- kurallar
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        ExpectSave('transport required', Dsp);
      finally
        Dsp.Free;
      end;
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.EinvVehicleId := Trailer1;
        Dsp.Driver1EinvDriverId := Driver1;
        ExpectSave('trailer as vehicle', Dsp);
      finally
        Dsp.Free;
      end;
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.EinvVehicleId := Truck;
        Dsp.Trailer1EinvVehicleId := Truck;
        Dsp.Driver1EinvDriverId := Driver1;
        ExpectSave('vehicle as trailer', Dsp);
      finally
        Dsp.Free;
      end;
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.EinvVehicleId := Truck;
        Dsp.Driver1EinvDriverId := Driver1;
        Dsp.Driver2EinvDriverId := Driver1;
        ExpectSave('same driver twice', Dsp);
      finally
        Dsp.Free;
      end;
      Fresh;
      Dsp := NewDispatch(PInvoice);
      try
        Dsp.CarrierAccAccountId := Carrier;
        ExpectSave('invoice profile on despatch', Dsp);
      finally
        Dsp.Free;
      end;

      // ---- kağıt irsaliye: taşıma zorunlu değil, e-belge yok
      Fresh;
      Dsp := NewDispatch(0);
      try
        if Save(Dsp) then
        begin
          Check('paper despatch has no e-document', (Dsp.EinvUuid = '') and (Dsp.EinvStatus = 0) and
            (Num(Scalar('SELECT count(*) FROM einv_document WHERE sls_dispatch_id = ' + Dsp.Id.ToString)) = 0));
          DspSvc.SuggestEDespatch(Dsp, True);
          Check('suggest TEMELIRSALIYE for e-despatch customer', Dsp.EinvProfileId = PDesp);
        end;
      finally
        Dsp.Free;
      end;

      // ---- gönderilmiş e-İrsaliye kilitli: başlık / kalem / silme
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.CarrierAccAccountId := Carrier;
        if Save(Dsp) then
        begin
          DspId := Dsp.Id;
          UoW.Connection.ExecSQL('UPDATE sls_dispatch SET einv_status = 3 WHERE id = ' + DspId.ToString);
          Dsp.Description := 'changed';
          ExpectSave('sent despatch locked (save)', Dsp);
        end;
      finally
        Dsp.Free;
      end;
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.CarrierAccAccountId := Carrier;
        if Save(Dsp) then
        begin
          DspId := Dsp.Id;
          UoW.Connection.ExecSQL('UPDATE sls_dispatch SET einv_status = 3 WHERE id = ' + DspId.ToString);
          Expect('sent despatch locked (line)', procedure
            var LLine: TSlsDispatchDetail;
            begin
              LLine := TSlsDispatchDetail.Create;
              try
                LLine.SlsDispatchId := DspId;
                LLine.StkInventoryId := Inv1;
                LLine.Quantity := 1;
                DspLineSvc.BusinessInsert(LLine, False, False, True);
              finally
                LLine.Free;
              end;
            end);
        end;
      finally
        Dsp.Free;
      end;
      Fresh;
      Dsp := NewDispatch(PDesp);
      try
        Dsp.CarrierAccAccountId := Carrier;
        if Save(Dsp) then
        begin
          DspId := Dsp.Id;
          UoW.Connection.ExecSQL('UPDATE sls_dispatch SET einv_status = 3 WHERE id = ' + DspId.ToString);
          Expect('sent despatch locked (delete)', procedure
            var LDsp: TSlsDispatch;
            begin
              LDsp := DspSvc.BusinessFindById(DspId, False, False, True);
              try
                DspSvc.BusinessDelete(LDsp, False, False, True);
              finally
                LDsp.Free;
              end;
            end);
        end;
      finally
        Dsp.Free;
      end;
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    DocSvc.Free;
    DspLineSvc.Free;
    DspSvc.Free;
    DrvSvc.Free;
    VehSvc.Free;
  end;
end;

{ ---------------------------------------------------------------- entegrasyon servisleri + e-belge ayarları }

procedure TestApiServices;
var
  ApiSvc: TSysApiServiceService;
  SetSvc: TEInvDocumentSettingService;
  A: TSysApiService;
  C: TApiServiceConfig;
  SerRepo: TEInvSeriesRepository;
  LSeriesId, LId: Int64;
  LEnc: string;

  function NewService(const AKind, APassword, AOptions: string): TSysApiService;
  begin
    Result := TSysApiService.Create;
    Result.ServiceKind := AKind;
    Result.ProviderCode := 'test';
    Result.Environment := API_ENV_TEST;
    Result.BaseUrl := 'https://test.example/api';
    Result.Username := 'it-user';
    Result.Password := APassword;
    Result.ApiKey := 'KEY-123';
    Result.Options := AOptions;
  end;

begin
  Ctx('System', 'TSysApiService');
  ApiSvc := TSysApiServiceService.Create;
  SetSvc := TEInvDocumentSettingService.Create;
  try
    try
      Begin_;
      A := NewService('it_service', 'p@ss Şifre', '{"branch": "merkez"}');
      try
        ApiSvc.BusinessInsert(A, False, False, True);
        LId := A.Id;
      finally
        A.Free;
      end;
      LEnc := S(Scalar('SELECT password_enc FROM sys_api_service WHERE id = ' + LId.ToString));
      Check('password stored encrypted', (LEnc <> '') and (LEnc <> '<null>') and not LEnc.Contains('p@ss'), LEnc);
      Check('company link', Num(Scalar('SELECT sys_application_setting_id FROM sys_api_service WHERE id = ' + LId.ToString)) =
        Num(Scalar('SELECT min(id) FROM sys_application_setting')));
      C := TApiServiceConfigs.Get('it_service');
      Check('config via TApiServiceConfigs', C.Found and C.Active and C.IsTest and (C.ProviderCode = 'TEST') and
        (C.Password = 'p@ss Şifre') and (C.ApiKey = 'KEY-123') and (C.Option('branch') = 'merkez') and (C.TimeoutSeconds = 60),
        C.ProviderCode + ' / ' + C.Password + ' / ' + C.Option('branch'));
      Check('unknown kind not found', not TApiServiceConfigs.Get('it_missing').Found);

      // güncelleme: boş parola eskisini korur; sil işareti siler
      A := ApiSvc.BusinessFindById(LId, False, False, True);
      try
        Check('view shows only presence', A.HasPassword and A.HasApiKey and (A.Password = ''));
        A.Description := 'changed';
        ApiSvc.BusinessUpdate(A, False, False, True);
      finally
        A.Free;
      end;
      Check('empty password keeps saved', TApiServiceConfigs.Get('it_service').Password = 'p@ss Şifre');
      A := ApiSvc.BusinessFindById(LId, False, False, True);
      try
        A.ClearSecrets := True;
        ApiSvc.BusinessUpdate(A, False, False, True);
      finally
        A.Free;
      end;
      C := TApiServiceConfigs.Get('it_service');
      Check('clear secrets', (C.Password = '') and (C.ApiKey = '') and
        VarIsNull(Scalar('SELECT password_enc FROM sys_api_service WHERE id = ' + LId.ToString)));

      Expect('duplicate service kind', procedure
        var X: TSysApiService;
        begin
          X := TSysApiService.Create;
          try
            X.ServiceKind := 'IT_Service'; X.Environment := API_ENV_TEST;
            ApiSvc.BusinessInsert(X, False, False, True);
          finally
            X.Free;
          end;
        end);
      Begin_;
      Expect('invalid service kind', procedure
        var X: TSysApiService;
        begin
          X := TSysApiService.Create;
          try
            X.ServiceKind := '1-bad'; X.Environment := API_ENV_TEST;
            ApiSvc.BusinessInsert(X, False, False, True);
          finally
            X.Free;
          end;
        end);
      Begin_;
      Expect('options must be a JSON object', procedure
        var X: TSysApiService;
        begin
          X := TSysApiService.Create;
          try
            X.ServiceKind := 'it_json'; X.Environment := API_ENV_TEST; X.Options := '[1, 2]';
            ApiSvc.BusinessInsert(X, False, False, True);
          finally
            X.Free;
          end;
        end);

      // ---- e-belge ayarları: varsayılan seri firma ayarından, seri belge türüyle uyumlu
      Ctx('EInvoice', 'TEInvDocumentSetting');
      Begin_;
      SerRepo := TEInvSeriesRepository(UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>);
      Check('three document types per company', Num(Scalar('SELECT count(*) FROM einv_document_setting')) >= 3);
      Check('default series from company settings', SerRepo.DefaultSeries(EINV_SERIES_INVOICE, LSeriesId) =
        S(Scalar('SELECT s.code FROM einv_document_setting d JOIN einv_series s ON s.id = d.einv_series_id WHERE d.series_scope = 1')));
      LId := Scalar('SELECT id FROM einv_document_setting WHERE series_scope = 3');
      Expect('series of another document type', procedure
        var X: TEInvDocumentSetting;
        begin
          X := SetSvc.BusinessFindById(LId, False, False, True);
          try
            X.EinvSeriesId := Scalar('SELECT min(id) FROM einv_series WHERE series_scope = 1');
            SetSvc.BusinessUpdate(X, False, False, True);
          finally
            X.Free;
          end;
        end);
      End_;
    except
      on Ex: Exception do Report('FAIL', GMod, GEnt, 'flow', Ex.ClassName + ': ' + Ex.Message);
    end;
  finally
    End_;
    SetSvc.Free;
    ApiSvc.Free;
  end;
end;

{ ---------------------------------------------------------------- e-Document integrator }

// Sahte sağlayıcı (ağ yok): son gönderim isteği saklanır, hata / uzak durum testten ayarlanır
type
  TItFakeIntegrator = class(TInterfacedObject, IEInvIntegrator)
  private
    FUser: string;
  public
    constructor Create(const AConfig: TApiServiceConfig);
    function TestConnection: string;
    function Send(const ARequest: TEInvSendRequest): TEInvSendResult;
    function QueryStatus(AKind: TEInvDocKind; const AUuid: string): TEInvStatusResult;
    function QueryTaxpayer(const ATaxNo: string): TEInvTaxpayerInfo;
  end;

var
  GFakeLast: TEInvSendRequest;
  GFakeSendCount: Integer;
  GFakeFail: string;
  GFakeStatus: TEInvRemoteStatus;

constructor TItFakeIntegrator.Create(const AConfig: TApiServiceConfig);
begin
  inherited Create;
  FUser := AConfig.Username;
end;

function TItFakeIntegrator.TestConnection: string;
begin
  Result := 'fake user=' + FUser;
end;

function TItFakeIntegrator.Send(const ARequest: TEInvSendRequest): TEInvSendResult;
begin
  Inc(GFakeSendCount);
  GFakeLast := ARequest;
  if GFakeFail <> '' then
    raise EEInvIntegratorException.Create(GFakeFail);
  Result.ProviderRef := 'REF-' + GFakeSendCount.ToString;
  Result.Message := 'queued';
end;

function TItFakeIntegrator.QueryStatus(AKind: TEInvDocKind; const AUuid: string): TEInvStatusResult;
begin
  Result.Status := GFakeStatus;
  Result.Code := 1300;
  Result.Description := 'fake status';
end;

function TItFakeIntegrator.QueryTaxpayer(const ATaxNo: string): TEInvTaxpayerInfo;
begin
  Result := Default(TEInvTaxpayerInfo);
  Result.Found := True;
  Result.TaxNo := ATaxNo;
  Result.Title := 'FAKE A.S.';
  Result.InvoicePkAliases := ['urn:mail:defaultpk@fake.test'];
  Result.InvoiceGbAliases := ['urn:mail:defaultgb@fake.test'];
end;

procedure TestEInvIntegrator;
var
  InvSvc: TSlsInvoiceService;
  DocSvc: TEInvDocumentService;
  ApiSvc: TSysApiServiceService;
  A: TSysApiService;
  Inv: TSlsInvoice;
  IL: TSlsInvoiceDetail;
  Inv1, Customer, Wh, PArchive, PBasic, TSales, ApiId, InvId: Int64;
  LNo, LPing: string;
  LInfo: TEInvTaxpayerInfo;
  LYear: string;

  function Q(const ASql: string): Double;
  begin
    Result := Num(Scalar(ASql));
  end;

  function InvStatus(AId: Int64): Integer;
  begin
    Result := Round(Q('SELECT COALESCE(einv_status, 0) FROM sls_invoice WHERE id = ' + AId.ToString));
  end;

  function InvNo(AId: Int64): string;
  begin
    Result := S(Scalar('SELECT einv_no FROM sls_invoice WHERE id = ' + AId.ToString));
  end;

  function NewInvoice(AProfileId: Int64): Int64;
  var
    LInv: TSlsInvoice;
  begin
    LInv := TSlsInvoice.Create;
    try
      LInv.AccAccountId := Customer;
      LInv.StkWarehouseId := Wh;
      LInv.EinvProfileId := AProfileId;
      LInv.EinvInvoiceTypeId := TSales;
      IL := InvSvc.NewLine(LInv);
      IL.StkInventoryId := Inv1;
      IL.Quantity := 2;
      IL.UnitPrice := 50;
      IL.VatRate := 20;
      InvSvc.BusinessSaveWithDetails(LInv, False, True);
      Result := LInv.Id;
    finally
      LInv.Free;
    end;
  end;

  // satıcı / alıcı (XML şemaya uygun olsun) + test entegrasyon servisi (sahte sağlayıcı) tüm belge türlerine bağlı
  procedure Setup;
  begin
    Begin_;
    UoW.Connection.ExecSQL('UPDATE sys_application_setting SET tax_no = ''1234567801'', tax_authority = ''Test VD'', ' +
      'taxpayer_type = ''VKN'', company_title = ''Ths Test A.Ş.'', sys_address_id = 3');
    UoW.Connection.ExecSQL('INSERT INTO acc_account_taxpayer (acc_account_id, taxpayer_type, taxpayer_name, tax_office, tax_no) ' +
      'VALUES (' + Customer.ToString + ', 1, ''Müşteri A.Ş.'', ''Kadıköy'', ''1111111111'') ' +
      'ON CONFLICT (acc_account_id) DO UPDATE SET taxpayer_type = 1, taxpayer_name = EXCLUDED.taxpayer_name, ' +
      'taxpayer_name2 = NULL, tax_office = EXCLUDED.tax_office, tax_no = EXCLUDED.tax_no');
    UoW.Connection.ExecSQL('WITH a AS (INSERT INTO sys_address (sys_city_id, district, street, door_number) ' +
      'SELECT sys_city_id, ''KADIKÖY'', ''Test Sokak'', ''5'' FROM sys_address WHERE id = 3 RETURNING id) ' +
      'INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type, is_primary) ' +
      'SELECT ' + Customer.ToString + ', id, ''BILLING'', true FROM a');
    UoW.Connection.ExecSQL('UPDATE acc_account SET e_invoice_active = false, e_invoice_pk_alias = NULL, e_invoice_gb_alias = NULL ' +
      'WHERE id = ' + Customer.ToString);
    A := TSysApiService.Create;
    try
      A.ServiceKind := 'it_einv';
      A.ProviderCode := 'itfake';
      A.Environment := API_ENV_TEST;
      A.BaseUrl := 'https://fake.test/api';
      A.Username := 'it-user';
      A.Password := 'secret';
      A.Options := '{}';
      ApiSvc.BusinessInsert(A, False, False, True);
      ApiId := A.Id;
    finally
      A.Free;
    end;
    UoW.Connection.ExecSQL('UPDATE einv_document_setting SET sys_api_service_id = ' + ApiId.ToString +
      ', sender_alias = NULL, receiver_alias = NULL');
    GFakeSendCount := 0;
    GFakeFail := '';
    GFakeStatus := ersDelivered;
    GFakeLast := Default(TEInvSendRequest);
  end;

begin
  Ctx('EInvoice', 'integrator (send / status / taxpayer)');
  TEInvIntegrators.RegisterProvider('ITFAKE',
    function(const AConfig: TApiServiceConfig): IEInvIntegrator
    begin
      Result := TItFakeIntegrator.Create(AConfig);
    end);
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Customer := Scalar('SELECT min(id) FROM acc_account');
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  PArchive := Scalar('SELECT id FROM einv_profile WHERE code = ''EARSIVFATURA''');
  PBasic := Scalar('SELECT id FROM einv_profile WHERE code = ''TEMELFATURA''');
  TSales := Scalar('SELECT id FROM einv_invoice_type WHERE code = ''SATIS''');
  LYear := IntToStr(YearOf(Date));
  Check('eLogo provider registered', TEInvIntegrators.IsRegistered(ELOGO_PROVIDER_CODE));
  Check('eLogo status map (GIB envelope codes)',
    (TELogoIntegrator.MapStatus(1300, False) = ersDelivered) and (TELogoIntegrator.MapStatus(1100, False) = ersProcessing) and
    (TELogoIntegrator.MapStatus(1220, False) = ersProcessing) and (TELogoIntegrator.MapStatus(1163, False) = ersFailed) and
    (TELogoIntegrator.MapStatus(0, False) = ersUnknown) and (TELogoIntegrator.MapStatus(1300, True) = ersCancelled));
  Check('eLogo services seeded (3 kinds, linked to settings)',
    Q('SELECT count(*) FROM einv_document_setting d JOIN sys_api_service a ON a.id = d.sys_api_service_id WHERE a.provider_code = ''ELOGO''') = 3);

  InvSvc := TSlsInvoiceService.Create;
  DocSvc := TEInvDocumentService.Create;
  ApiSvc := TSysApiServiceService.Create;
  try
    try
      // ---- e-Arşiv: numara gönderimde verilir, XML gerçek numarayla yeniden üretilir, durum 3 + gönderim bilgisi
      Setup;
      InvId := NewInvoice(PArchive);
      Check('archive draft before send', (InvStatus(InvId) = EINV_STATUS_DRAFT) and (InvNo(InvId) = '<null>'));
      DocSvc.BusinessSendInvoice(InvId, True);
      LNo := InvNo(InvId);
      Check('archive sent: status 3 + GIB number', (InvStatus(InvId) = EINV_STATUS_SENT) and LNo.StartsWith('EAR' + LYear) and
        (Length(LNo) = 16) and not LNo.EndsWith('000000000'), LNo);
      Check('archive request: kind / no aliases / xml with number', (GFakeSendCount = 1) and (GFakeLast.Kind = edkArchive) and
        (GFakeLast.SenderAlias = '') and (GFakeLast.ReceiverAlias = '') and (GFakeLast.EInvNo = LNo) and
        GFakeLast.Xml.Contains('<cbc:ID>' + LNo + '</cbc:ID>'));
      Check('archive transmission saved', (S(Scalar('SELECT provider_code FROM einv_document WHERE sls_invoice_id = ' + InvId.ToString)) = 'ITFAKE') and
        (S(Scalar('SELECT provider_ref FROM einv_document WHERE sls_invoice_id = ' + InvId.ToString)) = 'REF-1') and
        (S(Scalar('SELECT sent_at IS NOT NULL FROM einv_document WHERE sls_invoice_id = ' + InvId.ToString)) = 'True'));
      Expect('sent document cannot be sent again', procedure begin DocSvc.BusinessSendInvoice(InvId, True); end);

      // ---- durum sorgusu: eşleme + kesinleşmiş durum geri düşmez
      GFakeStatus := ersFailed;
      DocSvc.BusinessQueryInvoiceStatus(InvId, True);
      Check('status query: failed -> 6 + code saved', (InvStatus(InvId) = EINV_STATUS_ERROR) and
        (Q('SELECT status_code FROM einv_document WHERE sls_invoice_id = ' + InvId.ToString) = 1300));
      GFakeStatus := ersAccepted;
      DocSvc.BusinessQueryInvoiceStatus(InvId, True);
      GFakeStatus := ersDelivered;
      DocSvc.BusinessQueryInvoiceStatus(InvId, True);
      Check('status query: accepted stays accepted', InvStatus(InvId) = EINV_STATUS_ACCEPTED);
      GFakeStatus := ersUnknown;

      // ---- gönderim hatası: durum 6 + mesaj, numara korunur; yeniden gönderimde aynı numara
      InvId := NewInvoice(PArchive);
      Expect('integrator error is reported', procedure begin GFakeFail := 'network down'; DocSvc.BusinessSendInvoice(InvId, True); end);
      LNo := InvNo(InvId);
      Check('failed send: status 6 + message, number kept', (InvStatus(InvId) = EINV_STATUS_ERROR) and (LNo <> '<null>') and
        S(Scalar('SELECT status_message FROM einv_document WHERE sls_invoice_id = ' + InvId.ToString)).Contains('network down'));
      GFakeFail := '';
      DocSvc.BusinessSendInvoice(InvId, True);
      Check('resend after error: sent with same number', (InvStatus(InvId) = EINV_STATUS_SENT) and (InvNo(InvId) = LNo));
      InvId := NewInvoice(PArchive);
      Expect('status query of unsent document rejected', procedure begin DocSvc.BusinessQueryInvoiceStatus(InvId, True); end);

      // ---- e-Fatura: gönderici GB + alıcı PK zorunlu; eksikken numara harcanmaz
      InvId := NewInvoice(PBasic);
      Expect('e-invoice without sender alias rejected', procedure begin DocSvc.BusinessSendInvoice(InvId, True); end);
      Check('rejected send: still draft, no number', (InvStatus(InvId) = EINV_STATUS_DRAFT) and (InvNo(InvId) = '<null>'));
      UoW.Connection.ExecSQL('UPDATE einv_document_setting SET sender_alias = ''urn:mail:defaultgb@ths.test'' WHERE series_scope = 1');
      Expect('e-invoice without receiver PK rejected', procedure begin DocSvc.BusinessSendInvoice(InvId, True); end);
      UoW.Connection.ExecSQL('UPDATE acc_account SET e_invoice_active = true, e_invoice_pk_alias = ''urn:mail:defaultpk@musteri.test'' ' +
        'WHERE id = ' + Customer.ToString);
      DocSvc.BusinessSendInvoice(InvId, True);
      Check('e-invoice sent with aliases', (InvStatus(InvId) = EINV_STATUS_SENT) and InvNo(InvId).StartsWith('EFT' + LYear) and
        (GFakeLast.Kind = edkInvoice) and (GFakeLast.SenderAlias = 'urn:mail:defaultgb@ths.test') and
        (GFakeLast.ReceiverAlias = 'urn:mail:defaultpk@musteri.test') and (GFakeLast.ReceiverTaxNo = '1111111111'),
        InvNo(InvId) + ' / ' + GFakeLast.ReceiverAlias);

      // ---- mükellef sorgusu + bağlantı testi + servis / sağlayıcı denetimleri
      Expect('taxpayer query: invalid tax no rejected', procedure begin DocSvc.BusinessQueryTaxpayer('123', True); end);
      LInfo := DocSvc.BusinessQueryTaxpayer('1111111111', True);
      Check('taxpayer query via integrator', LInfo.Found and (Length(LInfo.InvoicePkAliases) = 1) and
        (LInfo.InvoicePkAliases[0] = 'urn:mail:defaultpk@fake.test'));
      Check('test connection uses service credentials', DocSvc.BusinessTestConnection(EINV_SERIES_INVOICE, True).Contains('it-user'));
      UoW.Connection.ExecSQL('UPDATE sys_api_service SET provider_code = ''NOPE'' WHERE id = ' + ApiId.ToString);
      Expect('unknown provider rejected', procedure begin DocSvc.BusinessTestConnection(EINV_SERIES_INVOICE, True); end);
      UoW.Connection.ExecSQL('UPDATE sys_api_service SET provider_code = ''ITFAKE'', is_active = false WHERE id = ' + ApiId.ToString);
      Expect('inactive service rejected', procedure begin DocSvc.BusinessTestConnection(EINV_SERIES_INVOICE, True); end);
      End_;
    except
      on E: Exception do
        Check('integrator tests', False, E.ClassName + ': ' + E.Message);
    end;
  finally
    End_;
    ApiSvc.Free;
    DocSvc.Free;
    InvSvc.Free;
  end;

  // ---- eLogo canlı uç (kimlik bilgisi gerektirmeyen Ping): ağ yoksa uyarı
  try
    LPing := TELogoIntegrator.Ping('https://pb.elogo.com.tr/PostBoxService.svc', 20);
    Check('eLogo PostBox Ping (SOAP client)', LPing = 'OK', LPing);
  except
    on E: Exception do
      Report('WARN', GMod, GEnt, 'eLogo PostBox Ping (network)', E.Message);
  end;
end;

// e-İrsaliye gönderimi (sahte sağlayıcı): e-İrsaliye serisi / GB / carinin e-İrsaliye PK etiketi, durum, hata + yeniden gönderim
procedure TestEDespatchIntegrator;
var
  DspSvc: TSlsDispatchService;
  DocSvc: TEInvDocumentService;
  ApiSvc: TSysApiServiceService;
  A: TSysApiService;
  Inv1, Customer, Wh, PDesp, Truck, Driver, ApiId, DspId: Int64;
  LNo, LYear: string;

  function DspStatus(AId: Int64): Integer;
  begin
    Result := Round(Num(Scalar('SELECT COALESCE(einv_status, 0) FROM sls_dispatch WHERE id = ' + AId.ToString)));
  end;

  function DspNo(AId: Int64): string;
  begin
    Result := S(Scalar('SELECT einv_no FROM sls_dispatch WHERE id = ' + AId.ToString));
  end;

  function NewDispatch: Int64;
  var
    LDsp: TSlsDispatch;
    LLine: TSlsDispatchDetail;
  begin
    LDsp := TSlsDispatch.Create;
    try
      LDsp.AccAccountId := Customer;
      LDsp.StkWarehouseId := Wh;
      LDsp.EinvProfileId := PDesp;
      LDsp.EinvVehicleId := Truck;
      LDsp.Driver1EinvDriverId := Driver;
      LLine := DspSvc.NewLine(LDsp);
      LLine.StkInventoryId := Inv1;
      LLine.Quantity := 3;
      LLine.UnitPrice := 40;
      DspSvc.BusinessSaveWithDetails(LDsp, False, True);
      Result := LDsp.Id;
    finally
      LDsp.Free;
    end;
  end;

begin
  Ctx('EInvoice', 'integrator (e-despatch)');
  Inv1 := Scalar('SELECT min(id) FROM stk_inventory');
  Customer := Scalar('SELECT min(id) FROM acc_account');
  Wh := Scalar('SELECT min(id) FROM stk_warehouse');
  PDesp := Scalar('SELECT id FROM einv_profile WHERE code = ''TEMELIRSALIYE''');
  LYear := IntToStr(YearOf(Date));
  Check('e-despatch series seeded and linked', S(Scalar('SELECT s.code FROM einv_document_setting d JOIN einv_series s ' +
    'ON s.id = d.einv_series_id WHERE d.series_scope = 3 AND s.series_scope = 3 AND s.is_active')) <> '<null>');

  DspSvc := TSlsDispatchService.Create;
  DocSvc := TEInvDocumentService.Create;
  ApiSvc := TSysApiServiceService.Create;
  try
    try
      Begin_;
      UoW.Connection.ExecSQL('UPDATE sys_application_setting SET tax_no = ''1234567801'', tax_authority = ''Test VD'', ' +
        'taxpayer_type = ''VKN'', company_title = ''Ths Test A.Ş.'', sys_address_id = 3');
      UoW.Connection.ExecSQL('INSERT INTO acc_account_taxpayer (acc_account_id, taxpayer_type, taxpayer_name, tax_office, tax_no) ' +
        'VALUES (' + Customer.ToString + ', 1, ''Alıcı Ltd. Şti.'', ''Kadıköy'', ''1111111111'') ' +
        'ON CONFLICT (acc_account_id) DO UPDATE SET taxpayer_type = 1, taxpayer_name = EXCLUDED.taxpayer_name, ' +
        'taxpayer_name2 = NULL, tax_office = EXCLUDED.tax_office, tax_no = EXCLUDED.tax_no');
      UoW.Connection.ExecSQL('WITH a AS (INSERT INTO sys_address (sys_city_id, district, street, door_number) ' +
        'SELECT sys_city_id, ''ÇANKAYA'', ''Depo Caddesi'', ''7'' FROM sys_address WHERE id = 3 RETURNING id) ' +
        'INSERT INTO acc_account_address (acc_account_id, sys_address_id, address_type, is_primary) ' +
        'SELECT ' + Customer.ToString + ', id, ''SHIPPING'', false FROM a');
      // fatura etiketleri bilerek farklı: irsaliyede e-İrsaliye PK'sı kullanılmalı
      UoW.Connection.ExecSQL('UPDATE acc_account SET e_invoice_active = true, e_invoice_pk_alias = ''urn:mail:faturapk@musteri.test'', ' +
        'e_despatch_active = false, e_despatch_pk_alias = NULL, e_despatch_gb_alias = NULL WHERE id = ' + Customer.ToString);
      Truck := Scalar('INSERT INTO einv_vehicle (plate_no, is_trailer) VALUES (''34ITD001'', false) RETURNING id');
      Driver := Scalar('INSERT INTO einv_driver (first_name, family_name, national_id) VALUES (''Mehmet'', ''Öztürk'', ''10000000146'') RETURNING id');
      A := TSysApiService.Create;
      try
        A.ServiceKind := 'it_edsp';
        A.ProviderCode := 'itfake';
        A.Environment := API_ENV_TEST;
        A.BaseUrl := 'https://fake.test/api';
        A.Username := 'it-user';
        A.Password := 'secret';
        A.Options := '{}';
        ApiSvc.BusinessInsert(A, False, False, True);
        ApiId := A.Id;
      finally
        A.Free;
      end;
      UoW.Connection.ExecSQL('UPDATE einv_document_setting SET sys_api_service_id = ' + ApiId.ToString +
        ', sender_alias = NULL WHERE series_scope = 3');
      GFakeSendCount := 0;
      GFakeFail := '';
      GFakeStatus := ersUnknown;

      DspId := NewDispatch;
      Check('despatch draft before send', (DspStatus(DspId) = EINV_STATUS_DRAFT) and (DspNo(DspId) = '<null>'));
      Expect('despatch without sender alias rejected', procedure begin DocSvc.BusinessSendDispatch(DspId, True); end);
      UoW.Connection.ExecSQL('UPDATE einv_document_setting SET sender_alias = ''urn:mail:irsaliyegb@ths.test'' WHERE series_scope = 3');
      Expect('despatch without receiver e-despatch PK rejected (invoice PK not used)',
        procedure begin DocSvc.BusinessSendDispatch(DspId, True); end);
      Check('rejected despatch: still draft, no number', (DspStatus(DspId) = EINV_STATUS_DRAFT) and (DspNo(DspId) = '<null>'));

      UoW.Connection.ExecSQL('UPDATE acc_account SET e_despatch_active = true, ' +
        'e_despatch_pk_alias = ''urn:mail:irsaliyepk@musteri.test'' WHERE id = ' + Customer.ToString);
      DocSvc.BusinessSendDispatch(DspId, True);
      LNo := DspNo(DspId);
      Check('despatch sent: status 3 + e-despatch series number', (DspStatus(DspId) = EINV_STATUS_SENT) and (Length(LNo) = 16) and
        Copy(LNo, 4, 4).Equals(LYear) and not LNo.EndsWith('000000000') and
        (Copy(LNo, 1, 3) = S(Scalar('SELECT s.code FROM einv_document_setting d JOIN einv_series s ON s.id = d.einv_series_id ' +
        'WHERE d.series_scope = 3'))), LNo);
      Check('despatch request: kind / aliases / xml', (GFakeLast.Kind = edkDespatch) and
        (GFakeLast.SenderAlias = 'urn:mail:irsaliyegb@ths.test') and (GFakeLast.ReceiverAlias = 'urn:mail:irsaliyepk@musteri.test') and
        GFakeLast.Xml.Contains('<DespatchAdvice') and GFakeLast.Xml.Contains('<cbc:ID>' + LNo + '</cbc:ID>'),
        GFakeLast.ReceiverAlias);
      Check('despatch transmission saved', (S(Scalar('SELECT provider_code FROM einv_document WHERE sls_dispatch_id = ' + DspId.ToString)) = 'ITFAKE') and
        (S(Scalar('SELECT sent_at IS NOT NULL FROM einv_document WHERE sls_dispatch_id = ' + DspId.ToString)) = 'True'));
      Expect('sent despatch cannot be sent again', procedure begin DocSvc.BusinessSendDispatch(DspId, True); end);
      Expect('sent despatch cannot be regenerated', procedure begin DocSvc.BusinessRegenerateDispatch(DspId, True); end);

      GFakeStatus := ersDelivered;
      DocSvc.BusinessQueryDispatchStatus(DspId, True);
      Check('despatch status query: delivered -> sent', DspStatus(DspId) = EINV_STATUS_SENT);
      GFakeStatus := ersFailed;
      DocSvc.BusinessQueryDispatchStatus(DspId, True);
      Check('despatch status query: failed -> error', DspStatus(DspId) = EINV_STATUS_ERROR);

      DspId := NewDispatch;
      Expect('despatch integrator error reported', procedure begin GFakeFail := 'timeout'; DocSvc.BusinessSendDispatch(DspId, True); end);
      LNo := DspNo(DspId);
      Check('failed despatch: status 6 + number kept', (DspStatus(DspId) = EINV_STATUS_ERROR) and (LNo <> '<null>'));
      GFakeFail := '';
      DocSvc.BusinessSendDispatch(DspId, True);
      Check('despatch resend: same number', (DspStatus(DspId) = EINV_STATUS_SENT) and (DspNo(DspId) = LNo));
      End_;
    except
      on E: Exception do
        Check('e-despatch integrator tests', False, E.ClassName + ': ' + E.Message);
    end;
  finally
    End_;
    ApiSvc.Free;
    DocSvc.Free;
    DspSvc.Free;
  end;
end;

procedure RunModuleTests;
begin
  UoW.Connection.ExecSQL('SET lc_messages TO ''C''');
  TestStockTransactions;
  TestStockInventory;
  TestStockKindInfo;
  TestAccount;
  TestAccountCardAddresses;
  TestAccountTaxpayer;
  TestAccountCode;
  TestTransferCode;
  TestEmployee;
  TestUsers;
  TestDbErrors;
  TestPermissions;
  TestGridFilter;
  TestFinanceChequeNotes;
  TestFinanceCreditCards;
  TestFinancePos;
  TestFinanceMoney;
  TestPurchasing;
  TestPurchaseDocuments;
  TestPurchaseQuotation;
  TestQualityControl;
  TestSales;
  TestSalesOfferDocument;
  TestSalesOfferRatesAndAddresses;
  TestSalesOfferCurrencyChange;
  TestSalesOrderDocument;
  TestSalesDispatchInvoiceDocument;
  TestProductionDocuments;
  TestAccountingVoucher;
  TestEInvoice;
  TestEDespatch;
  TestApiServices;
  TestEInvIntegrator;
  TestEDespatchIntegrator;
  TestCompanyBankAccounts;
  TestAccountTransactions;
  TestDashboard;
end;

end.
