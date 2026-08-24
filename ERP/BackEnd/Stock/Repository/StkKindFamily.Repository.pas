unit StkKindFamily.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkKindFamily;

type
  TStkKindFamilyRepository = class(TRepository<TStkKindFamily>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkKindFamily); override;
  end;

implementation

constructor TStkKindFamilyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkKindFamilyRepository.Delete(AModel: TStkKindFamily);
begin
  Delete(AModel.Id);
end;

end.
