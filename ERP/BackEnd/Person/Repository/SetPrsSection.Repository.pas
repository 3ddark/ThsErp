unit SetPrsSection.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsSection;

type
  TSetPrsSectionRepository = class(TRepository<TSetPrsSection>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsSectionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
