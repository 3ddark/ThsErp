unit PrsLanguageAbility.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsLanguage, SetPrsLanguageLevel, PrsPerson, PrsLanguageAbility;

type
  TPrsLanguageAbilityRepository = class(TRepository<TPrsLisanBilgisi>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPrsLanguageAbilityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
