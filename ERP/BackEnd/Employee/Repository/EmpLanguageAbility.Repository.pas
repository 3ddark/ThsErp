unit EmpLanguageAbility.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpLanguageAbility;

type
  TEmpLanguageAbilityRepository = class(TRepository<TEmpLanguageAbility>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpLanguageAbility); override;
  end;

implementation

constructor TEmpLanguageAbilityRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpLanguageAbilityRepository.Delete(AModel: TEmpLanguageAbility);
begin
  Delete(AModel.Id);
end;

end.
