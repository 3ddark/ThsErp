unit EmpTransportation;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('emp_transportation')]
  TEmpTransportation = class(TEntity)
  private
    FCarNo: SmallInt;
    FCarName: string;
  public
    [Column('car_no')]
    property CarNo: SmallInt read FCarNo write FCarNo;

    [Column('car_name')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property CarName: string read FCarName write FCarName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpTransportation;
  end;

implementation

constructor TEmpTransportation.Create;
begin
  inherited;
end;

destructor TEmpTransportation.Destroy;
begin
  inherited;
end;

function TEmpTransportation.Clone: TEmpTransportation;
begin
  Result := TEmpTransportation.Create;
  Result.Id := Self.Id;
  Result.CarNo := Self.CarNo;
  Result.CarName := Self.CarName;
end;

end.
