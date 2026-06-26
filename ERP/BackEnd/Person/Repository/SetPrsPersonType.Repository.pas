unit SetPrsPersonType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsPersonType;

type
  TSetPrsPersonTypeRepository = class(TRepository<TSetPrsPersonType>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsPersonTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
