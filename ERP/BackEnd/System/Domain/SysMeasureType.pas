unit SysMeasureType;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_measure_types')]
  TSysMeasureType = class(TEntity)
  private
    FMeasureType: string;
  public
    [Column('measure_type')]
    property MeasureType: string read FMeasureType write FMeasureType;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysMeasureType.Create();
begin
  inherited;
end;

destructor TSysMeasureType.Destroy;
begin
  inherited;
end;

end.
