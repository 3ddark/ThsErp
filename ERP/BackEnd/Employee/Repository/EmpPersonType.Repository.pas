unit EmpPersonType.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpPersonType;

type
  TEmpPersonTypeRepository = class(TRepository<TEmpPersonType>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpPersonType); override;
  end;

implementation

constructor TEmpPersonTypeRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpPersonTypeRepository.Delete(AModel: TEmpPersonType);
begin
  Delete(AModel.Id);
end;

end.
