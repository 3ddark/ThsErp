unit EmpLanguage;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('emp_language')]
  TEmpLanguage = class(TEntity)
  private
    FLanguageName: string;
  public
    [Column('language_name')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property LanguageName: string read FLanguageName write FLanguageName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEmpLanguage;
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

function TEmpLanguage.Clone: TEmpLanguage;
begin
  Result := TEmpLanguage.Create;
  Result.Id := Self.Id;
  Result.LanguageName := Self.LanguageName;
end;

end.
