unit SysResource;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes, SysResourceGroup;

type
  [Table('sys_kaynaklar')]
  TSysResource = class(TEntity)
  private
    FKod: string;
    Fad: string;
    FUstId: Int64; // FK → sys_kaynak_gruplari.id (parent resource group)
    FSiraNo: Smallint;
    FResourceGroup: TSysResourceGroup;
  public
    [Column('kod'), MaxLength(50)]
    property Kod: string read FKod write FKod;

    [Column('ad'), MaxLength(128), Required()]
    property Ad: string read Fad write Fad;

    [Column('ust_id')]
    property UstId: Int64 read FUstId write FUstId;

    [Column('sira_no')]
    property SiraNo: Smallint read FSiraNo write FSiraNo;

    // ust_id → sys_kaynak_gruplari.id (parent group)
    [BelongsTo('ust_id', 'id')]
    property ResourceGroup: TSysResourceGroup read FResourceGroup write FResourceGroup;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysResource.Create();
begin
  inherited;
  FResourceGroup := TSysResourceGroup.Create;
end;

destructor TSysResource.Destroy;
begin
  if Assigned(FResourceGroup) then
    FreeAndNil(FResourceGroup);

  inherited;
end;

end.
