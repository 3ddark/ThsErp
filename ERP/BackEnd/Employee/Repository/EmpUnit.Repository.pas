unit EmpUnit.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpSection, EmpUnit;

type
  TEmpUnitRepository = class(TRepository<TEmpUnit>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpUnit); override;
  end;

implementation

constructor TEmpUnitRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpUnitRepository.Delete(AModel: TEmpUnit);
begin
  Delete(AModel.Id);
end;

end.
