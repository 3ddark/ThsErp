unit StkKindProperty.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, StkKindProperty;

type
  TStkKindPropertyRepository = class(TRepository<TStkKindProperty>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TStkKindPropertyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
