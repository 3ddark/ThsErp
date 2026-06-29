unit EmpPerson.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpPersonType, EmpUnit, EmpTask, SysAddress, EmpPerson;

type
  TEmpPersonRepository = class(TRepository<TEmpPerson>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpPersonRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
