unit EmpLanguageAbility.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpLanguage, EmpLanguageLevel, EmpPerson, EmpLanguageAbility;

type
  TEmpLanguageAbilityRepository = class(TRepository<TEmpLanguageAbility>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpLanguageAbilityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
