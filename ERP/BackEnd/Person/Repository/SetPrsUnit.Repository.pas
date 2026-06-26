unit SetPrsUnit.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsSection, SetPrsUnit;

type
  TSetPrsUnitRepository = class(TRepository<TSetPrsUnit>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsUnitRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
