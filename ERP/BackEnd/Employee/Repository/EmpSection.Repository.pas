unit EmpSection.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpSection;

type
  TEmpSectionRepository = class(TRepository<TEmpSection>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpSection); override;
  end;

implementation

constructor TEmpSectionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpSectionRepository.Delete(AModel: TEmpSection);
begin
  Delete(AModel.Id);
end;

end.
