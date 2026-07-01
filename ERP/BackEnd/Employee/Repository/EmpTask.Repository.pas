unit EmpTask.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, EmpTask;

type
  TEmpTaskRepository = class(TRepository<TEmpTask>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TEmpTaskRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
