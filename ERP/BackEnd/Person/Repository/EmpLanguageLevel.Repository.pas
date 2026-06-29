unit EmpLanguageLevel.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpLanguageLevel;

type
  TEmpLanguageLevelRepository = class(TRepository<TEmpLanguageLevel>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpLanguageLevelRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
