unit EmpLanguage.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpLanguage;

type
  TEmpLanguageRepository = class(TRepository<TEmpLanguage>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpLanguageRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
