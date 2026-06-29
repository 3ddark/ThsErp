unit EmpLanguage;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_languages')]
  TEmpLanguage = class(TEntity)
  private
    FLanguageName: string;
  public
    [Column('language_name')]
    Property LanguageName: string read FLanguageName write FLanguageName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TEmpLanguage.Create;
begin
  inherited;
end;

destructor TEmpLanguage.Destroy;
begin

  inherited;
end;

end.