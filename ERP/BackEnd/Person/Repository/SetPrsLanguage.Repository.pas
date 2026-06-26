unit SetPrsLanguage.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsLanguage;

type
  TSetPrsLanguageRepository = class(TRepository<TSetPrsLanguage>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsLanguageRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
