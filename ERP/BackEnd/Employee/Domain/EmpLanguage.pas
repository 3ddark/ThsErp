unit EmpLanguage;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('emp_language')]
  TEmpLanguage = class(TEntity)
  private
    FLanguageName: string;
  public
    [Column('language_name')]
    Property LanguageName: string read FLanguageName write FLanguageName;

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
  Result.LanguageName := Self.LanguageName;
end;

end.