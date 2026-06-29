unit EmpPersonType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpPersonType;

type
  TEmpPersonTypeRepository = class(TRepository<TEmpPersonType>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpPersonTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
