unit AccAccount;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('acc_account')]
  TAccAccount = class(TEntity)
  private
    FCode: string;
    FName: string;
    FAccSetAccountTypeId: Int64;
    FAccGroupId: Int64;
    FAccRegionId: Int64;
    FRootCode: string;
    FSubCode: string;
    FIban: string;
    FIbanCurrency: string;
    FDiscountRate: Currency;
    FEInvoiceActive: Boolean;
    FEInvoicePackageName: string;
    FIsPassive: Boolean;
    FNotes: string;
    FTaxpayerType: SmallInt;
    FTaxpayerName: string;
    FTaxpayerName2: string;
    FTaxpayerSurname: string;
    FTaxOffice: string;
    FTaxNo: string;
    FNaceCode: string;
    FAuthorizedPerson1: string;
    FAuthorizedPhone1: string;
    FAuthorizedPerson2: string;
    FAuthorizedPhone2: string;
    FAuthorizedPerson3: string;
    FAuthorizedPhone3: string;
    FFax: string;
    FAccountantPhone: string;
    FAccountantEmail: string;
    FAccountantAuthorized: string;

    // View (vw_acc_account) okunabilir alanları
    FAccountTypeName: string;
    FGroupName: string;
    FRegionName: string;
  public
    [Column('code')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property Code: string read FCode write FCode;

    [Column('name')]
    [MaxLength(128), Required(TLangKeys.TValidation.Required, True)]
    property Name: string read FName write FName;

    [Column('acc_set_account_type_id')]
    property AccSetAccountTypeId: Int64 read FAccSetAccountTypeId write FAccSetAccountTypeId;

    [Column('acc_group_id')]
    property AccGroupId: Int64 read FAccGroupId write FAccGroupId;

    [Column('acc_region_id')]
    property AccRegionId: Int64 read FAccRegionId write FAccRegionId;

    [Column('root_code')]
    [MaxLength(3)]
    property RootCode: string read FRootCode write FRootCode;

    [Column('sub_code')]
    [MaxLength(8)]
    property SubCode: string read FSubCode write FSubCode;

    [Column('iban')]
    [MaxLength(64)]
    property Iban: string read FIban write FIban;

    [Column('iban_currency')]
    [MaxLength(3)]
    property IbanCurrency: string read FIbanCurrency write FIbanCurrency;

    [Column('discount_rate')]
    property DiscountRate: Currency read FDiscountRate write FDiscountRate;

    [Column('e_invoice_active')]
    property EInvoiceActive: Boolean read FEInvoiceActive write FEInvoiceActive;

    [Column('e_invoice_package_name')]
    [MaxLength(128)]
    property EInvoicePackageName: string read FEInvoicePackageName write FEInvoicePackageName;

    [Column('is_passive')]
    property IsPassive: Boolean read FIsPassive write FIsPassive;

    [Column('notes')]
    [MaxLength(512)]
    property Notes: string read FNotes write FNotes;

    [Column('taxpayer_type')]
    property TaxpayerType: SmallInt read FTaxpayerType write FTaxpayerType;

    [Column('taxpayer_name')]
    [MaxLength(32)]
    property TaxpayerName: string read FTaxpayerName write FTaxpayerName;

    [Column('taxpayer_name2')]
    [MaxLength(32)]
    property TaxpayerName2: string read FTaxpayerName2 write FTaxpayerName2;

    [Column('taxpayer_surname')]
    [MaxLength(32)]
    property TaxpayerSurname: string read FTaxpayerSurname write FTaxpayerSurname;

    [Column('tax_office')]
    [MaxLength(64)]
    property TaxOffice: string read FTaxOffice write FTaxOffice;

    [Column('tax_no')]
    [MaxLength(32)]
    property TaxNo: string read FTaxNo write FTaxNo;

    [Column('nace_code')]
    [MaxLength(32)]
    property NaceCode: string read FNaceCode write FNaceCode;

    [Column('authorized_person_1')]
    [MaxLength(64)]
    property AuthorizedPerson1: string read FAuthorizedPerson1 write FAuthorizedPerson1;

    [Column('authorized_phone_1')]
    [MaxLength(32)]
    property AuthorizedPhone1: string read FAuthorizedPhone1 write FAuthorizedPhone1;

    [Column('authorized_person_2')]
    [MaxLength(64)]
    property AuthorizedPerson2: string read FAuthorizedPerson2 write FAuthorizedPerson2;

    [Column('authorized_phone_2')]
    [MaxLength(32)]
    property AuthorizedPhone2: string read FAuthorizedPhone2 write FAuthorizedPhone2;

    [Column('authorized_person_3')]
    [MaxLength(64)]
    property AuthorizedPerson3: string read FAuthorizedPerson3 write FAuthorizedPerson3;

    [Column('authorized_phone_3')]
    [MaxLength(32)]
    property AuthorizedPhone3: string read FAuthorizedPhone3 write FAuthorizedPhone3;

    [Column('fax')]
    [MaxLength(32)]
    property Fax: string read FFax write FFax;

    [Column('accountant_phone')]
    [MaxLength(32)]
    property AccountantPhone: string read FAccountantPhone write FAccountantPhone;

    [Column('accountant_email')]
    [MaxLength(128)]
    property AccountantEmail: string read FAccountantEmail write FAccountantEmail;

    [Column('accountant_authorized')]
    [MaxLength(32)]
    property AccountantAuthorized: string read FAccountantAuthorized write FAccountantAuthorized;

    [NotMapped]
    property AccountTypeName: string read FAccountTypeName write FAccountTypeName;

    [NotMapped]
    property GroupName: string read FGroupName write FGroupName;

    [NotMapped]
    property RegionName: string read FRegionName write FRegionName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TAccAccount;
  end;

implementation

constructor TAccAccount.Create;
begin
  inherited;
end;

destructor TAccAccount.Destroy;
begin
  inherited;
end;

function TAccAccount.Clone: TAccAccount;
begin
  Result := TAccAccount.Create;
  Result.Id := Self.Id;
  Result.Code := Self.Code;
  Result.Name := Self.Name;
  Result.AccSetAccountTypeId := Self.AccSetAccountTypeId;
  Result.AccGroupId := Self.AccGroupId;
  Result.AccRegionId := Self.AccRegionId;
  Result.RootCode := Self.RootCode;
  Result.SubCode := Self.SubCode;
  Result.Iban := Self.Iban;
  Result.IbanCurrency := Self.IbanCurrency;
  Result.DiscountRate := Self.DiscountRate;
  Result.EInvoiceActive := Self.EInvoiceActive;
  Result.EInvoicePackageName := Self.EInvoicePackageName;
  Result.IsPassive := Self.IsPassive;
  Result.Notes := Self.Notes;
  Result.TaxpayerType := Self.TaxpayerType;
  Result.TaxpayerName := Self.TaxpayerName;
  Result.TaxpayerName2 := Self.TaxpayerName2;
  Result.TaxpayerSurname := Self.TaxpayerSurname;
  Result.TaxOffice := Self.TaxOffice;
  Result.TaxNo := Self.TaxNo;
  Result.NaceCode := Self.NaceCode;
  Result.AuthorizedPerson1 := Self.AuthorizedPerson1;
  Result.AuthorizedPhone1 := Self.AuthorizedPhone1;
  Result.AuthorizedPerson2 := Self.AuthorizedPerson2;
  Result.AuthorizedPhone2 := Self.AuthorizedPhone2;
  Result.AuthorizedPerson3 := Self.AuthorizedPerson3;
  Result.AuthorizedPhone3 := Self.AuthorizedPhone3;
  Result.Fax := Self.Fax;
  Result.AccountantPhone := Self.AccountantPhone;
  Result.AccountantEmail := Self.AccountantEmail;
  Result.AccountantAuthorized := Self.AccountantAuthorized;
  Result.AccountTypeName := Self.AccountTypeName;
  Result.GroupName := Self.GroupName;
  Result.RegionName := Self.RegionName;
end;

end.
