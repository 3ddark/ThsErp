unit SetAccCompanyLegalForm;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('acc_set_company_legal_form')]
  TSetAccCompanyLegalForm = class(TEntity)
  private
    FOwnershipId: Int64;
    FName: string;
  public
    [Column('ownership_id'), Required()]
    property OwnershipId: Int64 read FOwnershipId write FOwnershipId;

    [Column('name'), MaxLength(48), Required()]
    property Name: string read FName write FName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetAccCompanyLegalForm.Create();
begin
  inherited;
end;

destructor TSetAccCompanyLegalForm.Destroy;
begin
  inherited;
end;

end.
