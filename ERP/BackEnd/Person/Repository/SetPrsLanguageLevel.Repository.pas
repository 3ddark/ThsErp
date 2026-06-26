unit SetPrsLanguageLevel.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsLanguageLevel;

type
  TSetPrsLanguageLevelRepository = class(TRepository<TSetPrsLanguageLevel>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsLanguageLevelRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
