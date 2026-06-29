unit EmpTransportation;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, Emp.Section;

type
  [Table('emp_transportation')]
  TEmpTransportation = class(TEntity)
  private
    FCarNo: SmallInt;
    FCarName: string;
    FRoute: TArray<Double>;
  public
    [Column('car_no')]
    Property CarNo: SmallInt read FCarNo write FCarNo;

    [Column('car_name')]
    Property CarName: string read FCarName write FCarName;

    [Column('route')]
    property Route: TArray<Double> read FRoute write FRoute;

    destructor Destroy; override;
    constructor Create(); override;
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

end.