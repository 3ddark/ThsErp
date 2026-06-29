unit EmpSection.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, EmpSection;

type
  TEmpSectionRepository = class(TRepository<TEmpSection>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpSectionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
