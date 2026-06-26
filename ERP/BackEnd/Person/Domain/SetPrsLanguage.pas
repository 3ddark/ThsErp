unit SetPrsLanguage;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('set_prs_languages')]
  TSetPrsLanguage = class(TEntity)
  private
    FLanguageName: string;
  public
    [Column('language_name')]
    Property LanguageName: string read FLanguageName write FLanguageName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSetPrsLanguage.Create;
begin
  inherited;
end;

destructor TSetPrsLanguage.Destroy;
begin

  inherited;
end;

end.
