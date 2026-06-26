unit SetPrsLanguageLevel;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_prs_language_levels')]
  TSetPrsLanguageLevel = class(TEntity)
  private
    FLanguageLevel: string;
  public
    [Column('language_level')]
    Property LanguageLevel: string read FLanguageLevel write FLanguageLevel;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetPrsLanguageLevel.Create;
begin
  inherited;
end;

destructor TSetPrsLanguageLevel.Destroy;
begin

  inherited;
end;

end.

