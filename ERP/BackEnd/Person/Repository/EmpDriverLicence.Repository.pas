unit EmpDriverLicence.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpDriverLicenceType, EmpDriverLicence;

type
  TEmpDriverLicenceRepository = class(TRepository<TEmpDriverLicence>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpDriverLicenceRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
