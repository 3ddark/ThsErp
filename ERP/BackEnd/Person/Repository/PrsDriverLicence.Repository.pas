unit PrsDriverLicence.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsDriverLicenceType, PrsDriverLicence;

type
  TPrsDriverLicenceRepository = class(TRepository<TPrsDriverLicence>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TPrsDriverLicenceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
