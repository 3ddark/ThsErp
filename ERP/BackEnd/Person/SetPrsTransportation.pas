unit SetPrsTransportation;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, SetPrsSection;

type
  [Table('set_prs_transportation')]
  TSetPrsTransportation = class(TEntity)
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

constructor TSetPrsTransportation.Create;
begin
  inherited;

end;

destructor TSetPrsTransportation.Destroy;
begin

  inherited;
end;

end.
