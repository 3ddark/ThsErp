unit ItModules;

interface

procedure RunModuleTests;

implementation

uses
  System.SysUtils, System.StrUtils, System.Classes, System.Rtti, System.Variants, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client, SharedFormTypes, FilterCriterion,
  UnitOfWork, AppContext, ItSpecific,
  StkLookup, StkTransaction, StkTransaction.Service, StkInventory, StkInventory.Service,
  StkCardKindInfo, StkCardKindInfo.Service,
  AccAccount, AccAccount.Service, AccAccountAddress, AccAccountAddress.Service,
  AccTransferCode, AccTransferCode.Service,
  SysAddress, SysAddress.Service, SysUser, SysUser.Service, SysUser.Repository,
  SysAccessRight, SysAccessRight.Service, SysUserPermissionTemplate, SysUserPermissionTemplate.Service,
  SysGridFilter, SysGridFilter.Service,
  EmpEmployee, EmpEmployee.Service, EmpPersonAddress, EmpPersonAddress.Service,
  EmpTransportation, EmpTransportation.Service, Password.Helper,
  FinLookup, FinChequeNote, FinChequeNote.Service, FinChequeNoteTransaction, FinChequeNoteTransaction.Service,
  FinCreditCard, FinCreditCard.Service, FinCreditCardTransaction, FinCreditCardTransaction.Service,
  FinPosTerminal, FinPosTerminal.Service, FinPosTransaction, FinPosTransaction.Service,
  FinMoneyAccount, FinMoneyAccount.Service, FinMoneyTransaction, FinMoneyTransaction.Service,
  FinMoneyLedger, FinMoneyLedger.Service, FinCompanyBankAccount, FinCompanyBankAccount.Service,
  PurLookup, PurRequest, PurRequest.Service, PurRequestDetail, PurRequestDetail.Service,
  PurOrder, PurOrder.Service, PurOrderDetail, PurOrderDetail.Service,
  PurReceipt, PurReceipt.Service, PurReceiptDetail, PurReceiptDetail.Service,
  PurInvoice, PurInvoice.Service, PurInvoiceDetail, PurInvoiceDetail.Service,
  AccLookup, AccAccountTransaction, AccAccountTransaction.Service;

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

        E.HasVatRate := True;
        E.VatRate := 8.5;
        Svc.BusinessUpdate(E, False, False, True);
        Check('VAT 8.5 saved', Near(Num(Scalar('SELECT vat_rate FROM stk_inventory WHERE id = ' + Id.ToString)), 8.5),
          S(Scalar('SELECT vat_rate FROM stk_inventory WHERE id = ' + Id.ToString)));

        E.HasVatRate := True;
        E.VatRate := 0;
        Svc.BusinessUpdate(E, False, False, True);
        Check('VAT 0 saved as 0 (not NULL)', S(Scalar('SELECT vat_rate::text FROM stk_inventory WHERE id = ' + Id.ToString)) = '0.00',
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
  Inv3 := Scalar('SELECT id FROM stk_inventory WHERE buying_currency = fn_default_currency() AND buying_price > 0 ORDER BY id LIMIT 1');
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

procedure RunModuleTests;
begin
  UoW.Connection.ExecSQL('SET lc_messages TO ''C''');
  TestStockTransactions;
  TestStockInventory;
  TestStockKindInfo;
  TestAccount;
  TestTransferCode;
  TestEmployee;
  TestUsers;
  TestPermissions;
  TestGridFilter;
  TestFinanceChequeNotes;
  TestFinanceCreditCards;
  TestFinancePos;
  TestFinanceMoney;
  TestPurchasing;
  TestCompanyBankAccounts;
  TestAccountTransactions;
end;

end.
