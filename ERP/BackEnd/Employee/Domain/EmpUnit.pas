unit EmpUnit;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes, EmpSection;

type
  [Table('emp_unit')]
  TEmpUnit = class(TEntity)
  private
    FSectionId: Int64;
    FUnitName: string;
    FSection: TEmpSection;
  public
    [Column('section_id')]
    Property SectionId: Int64 read FSectionId write FSectionId;

    [Column('unit_name')]
    Property UnitName_: string read FUnitName write FUnitName;

    [BelongsTo('SectionId')]
    Property Section: TEmpSection read FSection write FSection;

    destructor Destroy; override;
    constructor Create(); override;

    function Clone: TEmpUnit;
  end;

implementation

constructor TEmpUnit.Create();
begin
  inherited;
end;

destructor TEmpUnit.Destroy;
begin
  inherited;
end;

function TEmpUnit.Clone: TEmpUnit;
begin
  Result := TEmpUnit.Create;
  Result.SectionId := Self.SectionId;
  Result.UnitName_ := Self.UnitName_;

  if Assigned(Self.Section) then
    Result.Section := Self.Section.Clone;
end;

end.