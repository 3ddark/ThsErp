unit EmpLanguageLevel;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_language_level')]
  TEmpLanguageLevel = class(TEntity)
  private
    FLanguageLevel: string;
  public
    [Column('language_level')]
    Property LanguageLevel: string read FLanguageLevel write FLanguageLevel;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpLanguageLevel;
  end;

implementation

constructor TEmpLanguageLevel.Create;
begin
  inherited;
end;

destructor TEmpLanguageLevel.Destroy;
begin

  inherited;
end;

function TEmpLanguageLevel.Clone: TEmpLanguageLevel;
begin
  Result := TEmpLanguageLevel.Create;
  Result.LanguageLevel := Self.LanguageLevel;
end;

end.