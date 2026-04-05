unit SysViewColumn.Service;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections,
  Entity, Service, UnitOfWork,
  SysViewColumn.Repository, SysViewColumn;

type
  TSysViewColumnService = class(TCrudService<TSysViewColumn>)
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TSysViewColumnService.Create;
begin
  inherited;
end;

destructor TSysViewColumnService.Destroy;
begin
  inherited;
end;

end.
