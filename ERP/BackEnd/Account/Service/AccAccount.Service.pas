unit AccAccount.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  AccAccount.Repository, AccAccount, AccAccount.Exception,
  AccAccountAddress, AccAccountAddress.Repository, SysAddress, SysAddress.Repository;

type
  TAccAccountService = class(TCrudService<TAccAccount>)
  private
    FRepo: IRepository<TAccAccount>;
    FLinkRepo: IRepository<TAccAccountAddress>;
    FSysAddressRepo: IRepository<TSysAddress>;

    procedure DoAdd(AEntity: TAccAccount);
    procedure DoUpdate(AEntity: TAccAccount);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TAccAccount);
    procedure ValidateUnique(AEntity: TAccAccount; AOperation: TCrudOperation);
    procedure CheckAddresses(AEntity: TAccAccount);
    procedure CheckTaxpayer(AEntity: TAccAccount);
    procedure CheckCode(AEntity: TAccAccount; AOperation: TCrudOperation);
    procedure SaveAddresses(AEntity: TAccAccount; AIsNew: Boolean);
    procedure DeleteSysAddressIfUnused(ASysAddressId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TAccAccount; AOperation: TCrudOperation); override;

    // Kart adresleri (tip başına birincil / ilk kayıt) DB'den AEntity.Addresses'a okunur
    procedure LoadAddresses(AEntity: TAccAccount);
    // Adres tipinin aktif dildeki adı (kart sekmeleri, hata mesajları)
    class function AddressTypeCaption(const AAddressType: string): string;

    // Hesap kodu yapısı: 3 haneli seviyeler, en çok üç seviye (120 / 120-001 / 120-001-001)
    class function IsValidCode(const ACode: string): Boolean;
    // Üst hesap kodu ('120-001-005' -> '120-001', '120' -> '')
    class function ParentCodeOf(const ACode: string): string;
    // Kartta kod seçimi (satır satır metin, ComboBox.Items.Text için): AParentCode '' = birinci seviye.
    // Altına hesap açılabilen (son hesap olmayan) bir alt seviye hesapları "kod - ad" / kullanılmayan kodlar
    function ParentAccountsText(const AParentCode: string): string;
    function FreeCodesText(const AParentCode: string): string;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TAccAccount>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TAccAccount; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TAccAccount; override;

    procedure Add(AEntity: TAccAccount); override;
    procedure Update(AEntity: TAccAccount); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccount; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccount>; override;
    procedure BusinessInsert(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  Ths.Helper.BaseTypes,
  System.RegularExpressions,
  SysPermission.Service, SysAddress.Service, AccLookup;

constructor TAccAccountService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TAccAccount, TAccAccountRepository>;
  FLinkRepo := Self.UoW.GetRepository<TAccAccountAddress, TAccAccountAddressRepository>;
  FSysAddressRepo := Self.UoW.GetRepository<TSysAddress, TSysAddressRepository>;
  Self.PermissionCode := PERMISSION_ACC_ACCOUNT;
end;

destructor TAccAccountService.Destroy;
begin
  inherited;
end;

procedure TAccAccountService.ValidateRequiredReferences(AEntity: TAccAccount);

  procedure Check(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  Check(AEntity.AccSetAccountTypeId, TLangKeys.TAccAccount.ColAccountType, 'Account Type');
end;

procedure TAccAccountService.ValidateUnique(AEntity: TAccAccount; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TAccAccount;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('code', '=', TValue.From<string>(AEntity.Code)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAccAccountExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TAccAccountService.ValidateBusinessRules(AEntity: TAccAccount; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
    AEntity.Name := UpperCaseTr(Trim(AEntity.Name));
    AEntity.Iban := AnsiUpperCase(Trim(AEntity.Iban));
    AEntity.IbanCurrency := Trim(AEntity.IbanCurrency);
    AEntity.EInvoicePackageName := Trim(AEntity.EInvoicePackageName);
    AEntity.Notes := Trim(AEntity.Notes);
    AEntity.TaxpayerName := Trim(AEntity.TaxpayerName);
    AEntity.TaxpayerName2 := Trim(AEntity.TaxpayerName2);
    AEntity.TaxpayerSurname := Trim(AEntity.TaxpayerSurname);
    AEntity.TaxOffice := Trim(AEntity.TaxOffice);
    AEntity.TaxNo := Trim(AEntity.TaxNo);
    AEntity.NaceCode := Trim(AEntity.NaceCode);
    AEntity.AuthorizedPerson1 := Trim(AEntity.AuthorizedPerson1);
    AEntity.AuthorizedPhone1 := Trim(AEntity.AuthorizedPhone1);
    AEntity.AuthorizedPerson2 := Trim(AEntity.AuthorizedPerson2);
    AEntity.AuthorizedPhone2 := Trim(AEntity.AuthorizedPhone2);
    AEntity.AuthorizedPerson3 := Trim(AEntity.AuthorizedPerson3);
    AEntity.AuthorizedPhone3 := Trim(AEntity.AuthorizedPhone3);
    AEntity.Fax := Trim(AEntity.Fax);
    AEntity.AccountantPhone := Trim(AEntity.AccountantPhone);
    AEntity.AccountantEmail := Trim(AEntity.AccountantEmail);
    AEntity.AccountantAuthorized := Trim(AEntity.AccountantAuthorized);
    ValidateRequiredReferences(AEntity);
    CheckCode(AEntity, AOperation);
    CheckTaxpayer(AEntity);
    // Hesap kodu yapısı: 120 / 120-001 / 120-001-001
    //   root_code = ilk 3 karakter, sub_code = üç seviyeli kodlarda üst (ara) hesap kodu
    AEntity.RootCode := Copy(AEntity.Code, 1, 3);
    if AEntity.Code.CountChar('-') >= 2 then
      AEntity.SubCode := Copy(AEntity.Code, 1, AEntity.Code.LastIndexOf('-'))
    else
      AEntity.SubCode := '';
    if (AEntity.DiscountRate < 0) or (AEntity.DiscountRate > 100) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TAccAccount.ColDiscountRate, 'Discount Rate') + ': ' +
        Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '100']));
    CheckAddresses(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

class function TAccAccountService.AddressTypeCaption(const AAddressType: string): string;
begin
  if AAddressType = ACC_ADDRESS_BILLING then
    Result := TLocalizationManager.Translate(TLangKeys.TAccAccount.AddressBilling, 'Billing Address')
  else if AAddressType = ACC_ADDRESS_SHIPPING then
    Result := TLocalizationManager.Translate(TLangKeys.TAccAccount.AddressShipping, 'Shipping Address')
  else if AAddressType = ACC_ADDRESS_LEGAL then
    Result := TLocalizationManager.Translate(TLangKeys.TAccAccount.AddressLegal, 'Legal Address')
  else if AAddressType = ACC_ADDRESS_OTHER then
    Result := TLocalizationManager.Translate(TLangKeys.TAccAccount.AddressOther, 'Other Address')
  else
    Result := AAddressType;
end;

class function TAccAccountService.IsValidCode(const ACode: string): Boolean;
begin
  Result := TRegEx.IsMatch(ACode, '^[0-9]{3}(-[0-9]{3}){0,2}$');
end;

class function TAccAccountService.ParentCodeOf(const ACode: string): string;
begin
  if ACode.LastIndexOf('-') > 0 then
    Result := Copy(ACode, 1, ACode.LastIndexOf('-'))
  else
    Result := '';
end;

function TAccAccountService.ParentAccountsText(const AParentCode: string): string;
begin
  if (AParentCode <> '') and not IsValidCode(AParentCode) then
    Exit('');
  Result := TAccAccountRepository(FRepo).ListParentAccounts(AParentCode, ACC_ACCOUNT_TYPE_DETAIL);
end;

function TAccAccountService.FreeCodesText(const AParentCode: string): string;
begin
  if (AParentCode <> '') and not IsValidCode(AParentCode) then
    Exit('');
  Result := TAccAccountRepository(FRepo).ListFreeCodes(AParentCode);
end;

// Kod biçimi; üst hesap var ve son hesap değil; alt hesabı olan hesabın kodu değişmez (alt kodlar üst koda bağlı)
procedure TAccAccountService.CheckCode(AEntity: TAccAccount; AOperation: TCrudOperation);
var
  LParent, LOldCode: string;
  LParentType: Int64;
begin
  if not IsValidCode(AEntity.Code) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TAccAccount.CodeFormat,
      'Account code must be in the form 999, 999-999 or 999-999-999.'));

  LParent := ParentCodeOf(AEntity.Code);
  if LParent <> '' then
  begin
    LParentType := TAccAccountRepository(FRepo).AccountTypeOf(LParent);
    if LParentType = 0 then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TAccAccount.CodeParentMissing,
        'Parent account %s does not exist.'), [LParent]));
    if LParentType = ACC_ACCOUNT_TYPE_DETAIL then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TAccAccount.CodeParentDetail,
        '%s is a detail account; no sub-account can be opened under it.'), [LParent]));
  end;

  if AOperation = coUpdate then
  begin
    LOldCode := TAccAccountRepository(FRepo).CodeOf(AEntity.Id);
    if (LOldCode <> '') and (LOldCode <> AEntity.Code) and TAccAccountRepository(FRepo).HasChildAccounts(LOldCode) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TAccAccount.CodeHasChildren,
        'The code of an account with sub-accounts cannot be changed.'));
  end;
end;

// Mükellef tipine göre: tüzel kişi -> vergi dairesi + 10 haneli VKN; gerçek kişi -> ad, soyad + 11 haneli TCKN (vergi no
// alanında, vergi dairesi isteğe bağlı); tip yok (muhasebe hesabı) -> mükellef bilgisi tutulmaz. Tipe ait olmayan alanlar
// boşaltılır (form da gizler); e-belge tarafı (ReadAccountParty) aynı tipe göre okur
procedure TAccAccountService.CheckTaxpayer(AEntity: TAccAccount);

  procedure Require(const AValue, AKey, ADefault: string);
  begin
    if AValue = '' then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

  procedure RequireDigits(const AValue: string; ALength: Integer; const AKey, ADefault: string);
  var
    LChar: Char;
    LValid: Boolean;
  begin
    Require(AValue, AKey, ADefault);
    LValid := Length(AValue) = ALength;
    for LChar in AValue do
      LValid := LValid and CharInSet(LChar, ['0'..'9']);
    if not LValid then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TAccAccount.TaxNoDigits,
        '%s must consist of %d digits.'), [TLocalizationManager.Translate(AKey, ADefault), ALength]));
  end;

begin
  case AEntity.TaxpayerType of
    ACC_TAXPAYER_LEGAL:
      begin
        AEntity.TaxpayerName := '';
        AEntity.TaxpayerName2 := '';
        AEntity.TaxpayerSurname := '';
        Require(AEntity.TaxOffice, TLangKeys.TAccAccount.ColTaxOffice, 'Tax Office');
        RequireDigits(AEntity.TaxNo, 10, TLangKeys.TAccAccount.ColTaxNo, 'Tax No');
      end;
    ACC_TAXPAYER_REAL:
      begin
        Require(AEntity.TaxpayerName, TLangKeys.TAccAccount.ColTaxpayerName, 'Taxpayer Name');
        Require(AEntity.TaxpayerSurname, TLangKeys.TAccAccount.ColTaxpayerSurname, 'Taxpayer Surname');
        RequireDigits(AEntity.TaxNo, 11, TLangKeys.TAccAccount.ColCitizenNo, 'Citizenship No');
      end;
  else
    AEntity.TaxpayerType := 0;
    AEntity.TaxpayerName := '';
    AEntity.TaxpayerName2 := '';
    AEntity.TaxpayerSurname := '';
    AEntity.TaxOffice := '';
    AEntity.TaxNo := '';
  end;
end;

// Doldurulan adreste şehir zorunlu (sys_address.sys_city_id NOT NULL); tümüyle boş adres = adres yok
procedure TAccAccountService.CheckAddresses(AEntity: TAccAccount);
var
  LCard: TAccAccountCardAddress;
begin
  if not AEntity.AddressesAssigned then
    Exit;
  for LCard in AEntity.Addresses do
  begin
    TSysAddressService.Normalize(LCard.Address);
    if not TSysAddressService.IsEmpty(LCard.Address) and (LCard.Address.SysCityId <= 0) then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TAccAccount.AddressCity,
        '%s: a city must be selected.'), [AddressTypeCaption(LCard.AddressType)]));
  end;
end;

procedure TAccAccountService.LoadAddresses(AEntity: TAccAccount);
var
  LLinks: TObjectList<TAccAccountAddress>;
  LLink, LItem: TAccAccountAddress;
  LCard: TAccAccountCardAddress;
  LSource: TSysAddress;
begin
  LLinks := TAccAccountAddressRepository(FLinkRepo).FindByAccount(AEntity.Id);
  try
    for LCard in AEntity.Addresses do
    begin
      // FindByAccount sırası: tipin ilk kaydı kart adresidir
      LLink := nil;
      for LItem in LLinks do
        if LItem.AddressType = LCard.AddressType then
        begin
          LLink := LItem;
          Break;
        end;

      LCard.LinkId := 0;
      LSource := nil;
      if Assigned(LLink) then
      begin
        LCard.LinkId := LLink.Id;
        LSource := FSysAddressRepo.FindById(LLink.SysAddressId, False);
      end;
      if not Assigned(LSource) then
        LSource := TSysAddress.Create;
      try
        TSysAddressService.CopyValues(LSource, LCard.Address, False);
      finally
        LSource.Free;
      end;
    end;
  finally
    LLinks.Free;
  end;
  AEntity.AddressesAssigned := True;
end;

procedure TAccAccountService.DeleteSysAddressIfUnused(ASysAddressId: Int64);
begin
  if (ASysAddressId > 0) and not TAccAccountAddressRepository(FLinkRepo).IsSysAddressShared(ASysAddressId, 0) then
    FSysAddressRepo.Delete(ASysAddressId);
end;

// Kart adresleri hesapla aynı transaction'da yazılır. Yalnız değişen adres için SQL çalışır:
//   boşaltılan -> bağlantı (+ başka yerde kullanılmıyorsa sys_address) silinir
//   yeni       -> sys_address + acc_account_address (tipin başka kaydı yoksa birincil)
//   değişen    -> sys_address güncellenir; adres başka kayıtla paylaşılıyorsa bu hesaba kopyası açılır
// Hata olursa bellekteki id'ler eski haline döner (rollback'i çağıran yapar)
procedure TAccAccountService.SaveAddresses(AEntity: TAccAccount; AIsNew: Boolean);

  function FindLink(ALinks: TObjectList<TAccAccountAddress>; ACard: TAccAccountCardAddress): TAccAccountAddress;
  var
    LItem: TAccAccountAddress;
  begin
    Result := nil;
    if ACard.LinkId <= 0 then
      Exit;
    for LItem in ALinks do
      if (LItem.Id = ACard.LinkId) and (LItem.AddressType = ACard.AddressType) then
        Exit(LItem);
  end;

  function HasType(ALinks: TObjectList<TAccAccountAddress>; const AAddressType: string): Boolean;
  var
    LItem: TAccAccountAddress;
  begin
    Result := False;
    for LItem in ALinks do
      if LItem.AddressType = AAddressType then
        Exit(True);
  end;

var
  LLinks: TObjectList<TAccAccountAddress>;
  LLink, LNewLink: TAccAccountAddress;
  LCard: TAccAccountCardAddress;
  LOld: TSysAddress;
  LSavedIds: TArray<Int64>;
  LSame: Boolean;
  I: Integer;
begin
  if not AEntity.AddressesAssigned then
    Exit;

  SetLength(LSavedIds, AEntity.Addresses.Count * 2);
  for I := 0 to AEntity.Addresses.Count - 1 do
  begin
    LSavedIds[I * 2] := AEntity.Addresses[I].LinkId;
    LSavedIds[I * 2 + 1] := AEntity.Addresses[I].Address.Id;
  end;

  // yeni hesapta (kopya dahil) bellekteki id'ler başka hesaba ait olabilir: hepsi yeni kayıt
  if AIsNew then
    LLinks := TObjectList<TAccAccountAddress>.Create(True)
  else
    LLinks := TAccAccountAddressRepository(FLinkRepo).FindByAccount(AEntity.Id);
  try
    try
      for LCard in AEntity.Addresses do
      begin
        LLink := FindLink(LLinks, LCard);

        if TSysAddressService.IsEmpty(LCard.Address) then
        begin
          if Assigned(LLink) then
          begin
            FLinkRepo.Delete(LLink);
            DeleteSysAddressIfUnused(LLink.SysAddressId);
          end;
          LCard.LinkId := 0;
          LCard.Address.Id := 0;
          Continue;
        end;

        if not Assigned(LLink) then
        begin
          LCard.Address.Id := 0;
          FSysAddressRepo.Add(LCard.Address);
          LNewLink := TAccAccountAddress.Create;
          try
            LNewLink.AccAccountId := AEntity.Id;
            LNewLink.SysAddressId := LCard.Address.Id;
            LNewLink.AddressType := LCard.AddressType;
            LNewLink.IsPrimary := not HasType(LLinks, LCard.AddressType);
            FLinkRepo.Add(LNewLink);
            LCard.LinkId := LNewLink.Id;
          finally
            LNewLink.Free;
          end;
          Continue;
        end;

        LOld := FSysAddressRepo.FindById(LLink.SysAddressId, False);
        try
          LSame := Assigned(LOld) and TSysAddressService.SameValues(LOld, LCard.Address);
        finally
          LOld.Free;
        end;
        if LSame then
        begin
          LCard.Address.Id := LLink.SysAddressId;
          Continue;
        end;

        if TAccAccountAddressRepository(FLinkRepo).IsSysAddressShared(LLink.SysAddressId, LLink.Id) then
        begin
          LCard.Address.Id := 0;
          FSysAddressRepo.Add(LCard.Address);
          LLink.SysAddressId := LCard.Address.Id;
          FLinkRepo.Update(LLink);
        end
        else
        begin
          LCard.Address.Id := LLink.SysAddressId;
          FSysAddressRepo.Update(LCard.Address);
        end;
      end;
    except
      for I := 0 to AEntity.Addresses.Count - 1 do
      begin
        AEntity.Addresses[I].LinkId := LSavedIds[I * 2];
        AEntity.Addresses[I].Address.Id := LSavedIds[I * 2 + 1];
      end;
      raise;
    end;
  finally
    LLinks.Free;
  end;
end;

procedure TAccAccountService.DoAdd(AEntity: TAccAccount);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
  try
    SaveAddresses(AEntity, True);
  except
    AEntity.Id := 0;
    raise;
  end;
end;

procedure TAccAccountService.DoUpdate(AEntity: TAccAccount);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
  SaveAddresses(AEntity, False);
end;

procedure TAccAccountService.DoDelete(AId: Int64);
var
  LEntity: TAccAccount;
  LLinks: TObjectList<TAccAccountAddress>;
  LLink: TAccAccountAddress;
begin
  LEntity := FRepo.FindById(AId, False);
  LLinks := nil;
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    LLinks := TAccAccountAddressRepository(FLinkRepo).FindByAccount(AId);
    FRepo.Delete(LEntity);
    // bağlantılar CASCADE ile silindi; hesaba ait adres kayıtları da kaldırılır
    for LLink in LLinks do
      DeleteSysAddressIfUnused(LLink.SysAddressId);
  finally
    LLinks.Free;
    LEntity.Free;
  end;
end;

function TAccAccountService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TAccAccount>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TAccAccountService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TAccAccount;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
    if Assigned(Result) then
      LoadAddresses(Result);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccAccountService.BusinessInsert(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccAccountService.BusinessUpdate(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TAccAccountService.BusinessDelete(AEntity: TAccAccount; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TAccAccountService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TAccAccountService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TAccAccount>;
var
  LItem: TAccAccount;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities then
    for LItem in Result do
      LoadAddresses(LItem);
end;

function TAccAccountService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TAccAccount;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadAddresses(Result);
end;

function TAccAccountService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TAccAccount;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TAccAccountService.Add(AEntity: TAccAccount);
begin
  DoAdd(AEntity);
end;

procedure TAccAccountService.Update(AEntity: TAccAccount);
begin
  DoUpdate(AEntity);
end;

procedure TAccAccountService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
