unit AccAccount;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes, AccGroup, SetAccAccountType, AccRegion;

type
  [Table('acc_account')]
  TAccAccount = class(TEntity)
  private
    FCode: string;
    FName: string;
    FTypeId: Int64;
    FGroupId: Int64;
    FRegionId: Int64;
    FTaxpayerType: SmallInt;
    FTaxpayerName: string;
    FTaxpayerName2: string;
    FTaxpayerSurname: string;
    FTaxOffice: string;
    FTaxNo: string;
    FIBAN: string;
    FIBANCurrency: string;
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
    FNotes: string;
    FRootCode: string;
    FSubCode: string;
    FDiscountRate: Double;
    FEInvoiceActive: Boolean;
    FEInvoicePackageName: string;
    FAddressId: Int64;
    FIsPassive: Boolean;
    FGroup: TAccGroup;
    FType: TSetAccAccountType;
    FRegion: TAccRegion;
  public
    [Column('code'), MaxLength(16), Required()]
    property Code: string read FCode write FCode;

    [Column('name'), MaxLength(128), Required()]
    property Name: string read FName write FName;

    [Column('type_id')]
    property TypeId: Int64 read FTypeId write FTypeId;

    [Column('group_id')]
    property GroupId: Int64 read FGroupId write FGroupId;

    [Column('region_id')]
    property RegionId: Int64 read FRegionId write FRegionId;

    [Column('taxpayer_type')]
    property TaxpayerType: SmallInt read FTaxpayerType write FTaxpayerType;

    [Column('taxpayer_name'), MaxLength(32)]
    property TaxpayerName: string read FTaxpayerName write FTaxpayerName;

    [Column('taxpayer_name2'), MaxLength(32)]
    property TaxpayerName2: string read FTaxpayerName2 write FTaxpayerName2;

    [Column('taxpayer_surname'), MaxLength(32)]
    property TaxpayerSurname: string read FTaxpayerSurname write FTaxpayerSurname;

    [Column('tax_office'), MaxLength(64)]
    property TaxOffice: string read FTaxOffice write FTaxOffice;

    [Column('tax_no'), MaxLength(32)]
    property TaxNo: string read FTaxNo write FTaxNo;

    [Column('iban'), MaxLength(64)]
    property IBAN: string read FIBAN write FIBAN;

    [Column('iban_currency'), MaxLength(3)]
    property IBANCurrency: string read FIBANCurrency write FIBANCurrency;

    [Column('nace_code'), MaxLength(32)]
    property NaceCode: string read FNaceCode write FNaceCode;

    [Column('authorized_person_1'), MaxLength(64)]
    property AuthorizedPerson1: string read FAuthorizedPerson1 write FAuthorizedPerson1;

    [Column('authorized_phone_1'), MaxLength(32)]
    property AuthorizedPhone1: string read FAuthorizedPhone1 write FAuthorizedPhone1;

    [Column('authorized_person_2'), MaxLength(64)]
    property AuthorizedPerson2: string read FAuthorizedPerson2 write FAuthorizedPerson2;

    [Column('authorized_phone_2'), MaxLength(32)]
    property AuthorizedPhone2: string read FAuthorizedPhone2 write FAuthorizedPhone2;

    [Column('authorized_person_3'), MaxLength(64)]
    property AuthorizedPerson3: string read FAuthorizedPerson3 write FAuthorizedPerson3;

    [Column('authorized_phone_3'), MaxLength(32)]
    property AuthorizedPhone3: string read FAuthorizedPhone3 write FAuthorizedPhone3;

    [Column('fax'), MaxLength(32)]
    property Fax: string read FFax write FFax;

    [Column('accountant_phone'), MaxLength(32)]
    property AccountantPhone: string read FAccountantPhone write FAccountantPhone;

    [Column('accountant_email'), MaxLength(128)]
    property AccountantEmail: string read FAccountantEmail write FAccountantEmail;

    [Column('accountant_authorized'), MaxLength(32)]
    property AccountantAuthorized: string read FAccountantAuthorized write FAccountantAuthorized;

    [Column('notes'), MaxLength(512)]
    property Notes: string read FNotes write FNotes;

    [Column('root_code'), MaxLength(3)]
    property RootCode: string read FRootCode write FRootCode;

    [Column('sub_code'), MaxLength(8)]
    property SubCode: string read FSubCode write FSubCode;

    [Column('discount_rate')]
    property DiscountRate: Double read FDiscountRate write FDiscountRate;

    [Column('e_invoice_active'), Required()]
    property EInvoiceActive: Boolean read FEInvoiceActive write FEInvoiceActive;

    [Column('e_invoice_package_name'), MaxLength(128)]
    property EInvoicePackageName: string read FEInvoicePackageName write FEInvoicePackageName;

    [Column('address_id')]
    property AddressId: Int64 read FAddressId write FAddressId;

    [Column('is_passive'), Required()]
    property IsPassive: Boolean read FIsPassive write FIsPassive;

    [BelongsTo('group_id', 'id')]
    property Group: TAccGroup read FGroup write FGroup;

    [BelongsTo('type_id', 'id')]
    property Type: TSetAccAccountType read FType write FType;

    [BelongsTo('region_id', 'id')]
    property Region: TAccRegion read FRegion write FRegion;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TAccAccount.Create();
begin
  inherited;
  FGroup := TAccGroup.Create;
  FType := TSetAccAccountType.Create;
  FRegion := TAccRegion.Create;
end;

destructor TAccAccount.Destroy;
begin
  if Assigned(FGroup) then FreeAndNil(FGroup);
  if Assigned(FType) then FreeAndNil(FType);
  if Assigned(FRegion) then FreeAndNil(FRegion);

  inherited;
end;

end.
