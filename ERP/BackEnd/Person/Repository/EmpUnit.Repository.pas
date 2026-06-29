unit EmpUnit.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpSection, EmpUnit;

type
  TEmpUnitRepository = class(TRepository<TEmpUnit>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpUnitRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
