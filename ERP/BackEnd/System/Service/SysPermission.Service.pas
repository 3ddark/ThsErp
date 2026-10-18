unit SysPermission.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysPermission.Repository, SysPermission, SysPermission.Exception,
  SysAccessRight.Service;

const
  // Yetki kodları: her form/kaynak için ayrı kod (sys_permission.permission_code).
  // Yeni kod eklenirken DB'de sys_permission + sys_permission_translation satırı da eklenmelidir.
  PERMISSION_TEMPLATE                     = 1;

  // System - Tanımlar
  PERMISSION_SYS_CITY                     = 1000;
  PERMISSION_SYS_COUNTRY                  = 1001;
  PERMISSION_SYS_REGION                   = 1002;
  PERMISSION_SYS_CURRENCY                 = 1003;
  PERMISSION_SYS_UOM_GROUP                = 1004;
  PERMISSION_SYS_UOM                      = 1005;
  PERMISSION_SYS_LANGUAGE                 = 1006;
  PERMISSION_SYS_DECIMAL_PLACE            = 1007;
  PERMISSION_SYS_ADDRESS                  = 1008;

  // System - Yönetim
  PERMISSION_SYS_USER                     = 1100;
  PERMISSION_SYS_ACCESS_RIGHT             = 1101;
  PERMISSION_SYS_PERMISSION               = 1102;
  PERMISSION_SYS_PERMISSION_GROUP         = 1103;
  PERMISSION_SYS_PERMISSION_TEMPLATE      = 1104;
  PERMISSION_SYS_USER_PERMISSION_TEMPLATE = 1105;
  PERMISSION_SYS_APPLICATION_SETTING      = 1106;
  PERMISSION_SYS_GRID_COLUMN              = 1107;
  PERMISSION_SYS_GRID_FILTER              = 1108;
  PERMISSION_SYS_GRID_SORT                = 1109;
  PERMISSION_SYS_VIEW_TABLE               = 1110;
  PERMISSION_SYS_MENU                     = 1111;
  PERMISSION_SYS_AUDIT_LOG                = 1112;
  PERMISSION_SYS_API_SERVICE              = 1113;   // entegrasyon (API) servisleri: firma ayarına bağlı bağlantı bilgileri

  // Employee
  PERMISSION_EMP_EMPLOYEE                 = 1021;   // + detaylar: ehliyet, dil bilgisi, adres
  PERMISSION_EMP_PERSON_TYPE              = 1022;
  PERMISSION_EMP_SECTION                  = 1023;
  PERMISSION_EMP_UNIT                     = 1024;
  PERMISSION_EMP_TASK                     = 1025;
  PERMISSION_EMP_TRANSPORTATION           = 1026;
  PERMISSION_EMP_LANGUAGE                 = 1027;
  PERMISSION_EMP_DRIVER_LICENSE_TYPE      = 1029;

  // Account (cari hesap)
  PERMISSION_ACC_ACCOUNT                  = 1031;   // + detay: hesap adresleri
  PERMISSION_ACC_BANK                     = 1032;   // + detay: banka şubeleri
  PERMISSION_ACC_GROUP                    = 1033;
  PERMISSION_ACC_REGION                   = 1034;
  PERMISSION_ACC_ACCOUNT_TYPE             = 1035;
  PERMISSION_ACC_OWNERSHIP_TYPE           = 1036;
  PERMISSION_ACC_COMPANY_LEGAL_FORM       = 1037;
  PERMISSION_ACC_ACCOUNT_TRANSACTION      = 1038;   // cari hesap hareketleri (salt okunur, kaynak belgelerden)

  // Stock (1040 boş: eski "stock-card-settings" silindi)
  PERMISSION_STK_INVENTORY                = 1041;   // + detaylar: resim, cins bilgisi
  PERMISSION_STK_TRANSACTION              = 1042;
  PERMISSION_STK_GROUP                    = 1043;
  PERMISSION_STK_WAREHOUSE                = 1044;
  PERMISSION_STK_PRODUCT_TYPE             = 1045;
  PERMISSION_STK_KIND_FAMILY              = 1046;
  PERMISSION_STK_KIND_PROPERTY            = 1047;
  PERMISSION_STK_INVENTORY_SUMMARY        = 1048;
  PERMISSION_STK_GTIP                     = 1049;   // GTİP kodları (stok kartı, DİİB satırı, fatura kalemi)

  // e-Belge (UBL-TR kod listeleri; einv_*)
  PERMISSION_EINV_PROFILE                 = 1050;   // senaryo (ProfileID)
  PERMISSION_EINV_INVOICE_TYPE            = 1051;   // fatura tipi (InvoiceTypeCode)
  PERMISSION_EINV_TAX_EXEMPTION           = 1052;   // istisna / muafiyet kodları
  PERMISSION_EINV_TAX_TYPE                = 1053;   // vergi türü kodları
  PERMISSION_EINV_WITHHOLDING             = 1054;   // tevkifat kodları
  PERMISSION_EINV_SERIES                  = 1055;   // e-belge serileri (GİB belge no: seri + yıl + sıra)
  PERMISSION_EINV_DELIVERY_TERM           = 1056;   // teslim şartları (INCOTERMS)
  PERMISSION_EINV_TRANSPORT_MODE          = 1057;   // taşıma şekilleri
  PERMISSION_EINV_PACKAGING_TYPE          = 1058;   // paket / kap cinsleri
  PERMISSION_EINV_PAYMENT_MEANS           = 1059;   // ödeme şekli kodları

  PERMISSION_PRD_BOM                      = 1061;   // reçete + hammadde / yan ürün / işçilik / paket bağlantıları
  PERMISSION_PRD_LABOUR                   = 1062;   // işçilik / gider tanımı
  PERMISSION_PRD_PACKET_RAW               = 1063;   // + paket kalemleri
  PERMISSION_PRD_PACKET_LABOUR            = 1064;   // + paket kalemleri

  // Finance (çek / senet / kredi kartı / POS)
  PERMISSION_FIN_CHEQUE_NOTE              = 1070;   // + hareketler (portföy giriş / ciro / tahsil ...)
  PERMISSION_FIN_CREDIT_CARD              = 1071;   // firma kredi kartları + hareketler
  PERMISSION_FIN_POS_TERMINAL             = 1072;   // POS tanımları + kredi kartı tahsilatları
  PERMISSION_FIN_MONEY_ACCOUNT            = 1073;   // kasa / banka hesapları + ekstre
  PERMISSION_FIN_MONEY_TRANSACTION        = 1074;   // tahsilat / ödeme / havale-EFT / virman / masraf
  PERMISSION_FIN_COMPANY_BANK_ACCOUNT     = 1075;   // firma banka hesapları (çek / senet / çıktılar)

  // Purchasing (satın alma)
  PERMISSION_PUR_REQUEST                  = 1080;   // talep + kalemleri
  PERMISSION_PUR_ORDER                    = 1081;   // sipariş + kalemleri
  PERMISSION_PUR_RECEIPT                  = 1082;   // mal kabul + kalemleri (stok girişi)
  PERMISSION_PUR_INVOICE                  = 1083;   // alış faturası + kalemleri

  // Accounting (muhasebe)
  PERMISSION_ACC_EXCHANGE_RATE            = 3001;
  PERMISSION_ACC_ACCOUNT_PLAN             = 3002;
  PERMISSION_ACC_TAX_RATE                 = 3003;
  PERMISSION_ACC_TRANSFER_CODE            = 3004;
  PERMISSION_ACC_VOUCHER                  = 3005;   // + detay: fiş satırları

  // Sales (satış)
  PERMISSION_SLS_OFFER                    = 1090;   // teklif + kalemleri
  PERMISSION_SLS_ORDER                    = 1091;   // sipariş + kalemleri
  PERMISSION_SLS_DISPATCH                 = 1092;   // sevk irsaliyesi + kalemleri (stok çıkışı)
  PERMISSION_SLS_INVOICE                  = 1093;   // satış faturası + kalemleri (irsaliyesiz kalem stok çıkışı)
  PERMISSION_SLS_DIIB                     = 1094;   // DİİB belgeleri + satırları (ihraç kayıtlı satış)
  PERMISSION_EINV_VEHICLE                 = 1095;   // araç / dorse tanımları (e-İrsaliye taşıma)
  PERMISSION_EINV_DRIVER                  = 1096;   // şoför tanımları (e-İrsaliye taşıma)
  PERMISSION_EINV_DOCUMENT_SETTING        = 1097;   // e-belge ayarları (firma: belge türü başına seri / gönderici etiketi / API servisi)

type
  TSysPermissionService = class(TCrudService<TSysPermission>)
  private
    FRepo: IRepository<TSysPermission>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysPermission; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysPermission>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysPermission; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysPermission; override;

    procedure Add(AEntity: TSysPermission); override;
    procedure Update(AEntity: TSysPermission); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermission; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermission>; override;
    procedure BusinessInsert(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysPermissionService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysPermission, TSysPermissionRepository>;
  Self.PermissionCode := PERMISSION_SYS_PERMISSION;
end;

destructor TSysPermissionService.Destroy;
begin
  inherited;
end;

function TSysPermissionService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysPermission>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TSysPermissionService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysPermission;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysPermissionService.BusinessInsert(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
var
  LSvc: TSysAccessRightService;
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    ValidateAll(AEntity, coInsert);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    //add permission to all user with false permission
    LSvc := TSysAccessRightService.Create;
    try
      LSvc.AddPermissionToAllUser(AEntity.Id, False, False);
    finally
      LSvc.Free;
    end;

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysPermissionService.BusinessUpdate(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    ValidateAll(AEntity, coUpdate);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysPermissionService.BusinessDelete(AEntity: TSysPermission; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    ValidateAll(AEntity, coDelete);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TSysPermissionService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysPermissionService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysPermission>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysPermissionService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysPermission;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysPermissionService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysPermission;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysPermissionService.Add(AEntity: TSysPermission);
begin
  FRepo.Add(AEntity);
end;

procedure TSysPermissionService.Update(AEntity: TSysPermission);
begin
  FRepo.Update(AEntity);
end;

procedure TSysPermissionService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysPermissionService.ValidateBusinessRules(AEntity: TSysPermission; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysPermission;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('permission_key', '=', TValue.From<string>(AEntity.PermissionKey)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysPermissionExceptionKeyUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;

    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('permission_code', '=', TValue.From<Integer>(AEntity.PermissionCode)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise ESysPermissionExceptionCodeUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

end.
