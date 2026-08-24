unit EmpTask.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpTask;

type
  TEmpTaskRepository = class(TRepository<TEmpTask>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TEmpTask); override;
  end;

implementation

constructor TEmpTaskRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TEmpTaskRepository.Delete(AModel: TEmpTask);
begin
  Delete(AModel.Id);
end;

end.
