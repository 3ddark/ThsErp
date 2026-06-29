unit EmpDriverLicenceType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpDriverLicenceType;

type
  TEmpDriverLicenceTypeRepository = class(TRepository<TEmpDriverLicenseType>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpDriverLicenceTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
