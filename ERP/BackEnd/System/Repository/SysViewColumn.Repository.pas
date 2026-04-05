unit SysViewColumn.Repository;

interface

uses
  SysUtils, Classes, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, SysViewColumn;

type
  TSysViewColumnRepository = class(TRepository<TSysViewColumn>)
  public
    constructor Create(AConnection: TFDConnection);
  end;

implementation

constructor TSysViewColumnRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

end.

