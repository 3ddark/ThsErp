unit EmpLanguageLevel.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpLanguageLevel;

type
  TEmpLanguageLevelRepository = class(TRepository<TEmpLanguageLevel>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpLanguageLevel); override;
  end;

implementation

constructor TEmpLanguageLevelRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpLanguageLevelRepository.Delete(AModel: TEmpLanguageLevel);
begin
  Delete(AModel.Id);
end;

end.
