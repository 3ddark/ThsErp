unit EmpLanguageAbility;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes,
  EmpLanguage, EmpLanguageLevel, EmpPerson;

type
  [Table('emp_person_language_ability')]
  TEmpLanguageAbility = class(TEntity)
  private
    FLisanID: Int64;
    FLisan: TEmpLanguage;
    FOkumaID: Int64;
    FOkuma: TEmpLanguageLevel;
    FYazmaID: Int64;
    FYazma: TEmpLanguageLevel;
    FKonusmaID: Int64;
    FKonusma: TEmpLanguageLevel;
    FPersonelID: Int64;
    FPerson: TEmpPerson;
  public
    Property LisanID: Int64 read FLisanID write FLisanID;
    Property Lisan: TEmpLanguage read FLisan write FLisan;
    Property OkumaID: Int64 read FOkumaID write FOkumaID;
    Property Okuma: TEmpLanguageLevel read FOkuma write FOkuma;
    Property YazmaID: Int64 read FYazmaID write FYazmaID;
    Property Yazma: TEmpLanguageLevel read FYazma write FYazma;
    Property KonusmaID: Int64 read FKonusmaID write FKonusmaID;
    Property Konusma: TEmpLanguageLevel read FKonusma write FKonusma;
    Property PersonelID: Int64 read FPersonelID write FPersonelID;
    Property Personel: TEmpPerson read FPerson write FPerson;

    destructor Destroy; override;
    constructor Create; override;

    function Clone: TEmpLanguageAbility;
  end;

implementation

constructor TEmpLanguageAbility.Create();
begin
  inherited;
end;

destructor TEmpLanguageAbility.Destroy;
begin
  inherited;
end;

function TEmpLanguageAbility.Clone: TEmpLanguageAbility;
begin
  Result := TEmpLanguageAbility.Create;
  Result.LisanID := Self.LisanID;
  Result.OkumaID := Self.OkumaID;
  Result.YazmaID := Self.YazmaID;
  Result.KonusmaID := Self.KonusmaID;
  Result.PersonelID := Self.PersonelID;
end;

end.
