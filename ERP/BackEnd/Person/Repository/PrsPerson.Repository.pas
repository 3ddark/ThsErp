unit PrsPerson.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsPersonType, SetPrsUnit, SetPrsTask, SysAddress, PrsPerson;

type
  TPrsPersonRepository = class(TRepository<TPrsPerson>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPrsPersonRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
