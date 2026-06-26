unit SetPrsDriverLicenceType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsDriverLicenceType;

type
  TSetPrsDriverLicenceTypeRepository = class(TRepository<TSetPrsDriverLicenseType>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsDriverLicenceTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
