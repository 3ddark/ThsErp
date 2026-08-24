unit EmpDriverLicenceType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpDriverLicenceType;

type
  TEmpDriverLicenceTypeRepository = class(TRepository<TEmpDriverLicenseType>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpDriverLicenseType); override;
  end;

implementation

constructor TEmpDriverLicenceTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpDriverLicenceTypeRepository.Delete(AModel: TEmpDriverLicenseType);
begin
  Delete(AModel.Id);
end;

end.
