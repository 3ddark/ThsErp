unit StkGroup.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkGroup;

type
  TStkGroupRepository = class(TRepository<TStkGroup>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkGroup); override;
  end;

implementation

constructor TStkGroupRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkGroupRepository.Delete(AModel: TStkGroup);
begin
  Delete(AModel.Id);
end;

end.
