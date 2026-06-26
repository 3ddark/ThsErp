unit SetPrsTask.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  Entity, Repository, SetPrsTask;

type
  TSetPrsTaskRepository = class(TRepository<TSetPrsTask>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSetPrsTaskRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.
