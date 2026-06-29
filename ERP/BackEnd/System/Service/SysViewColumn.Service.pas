unit SysViewColumn.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
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
