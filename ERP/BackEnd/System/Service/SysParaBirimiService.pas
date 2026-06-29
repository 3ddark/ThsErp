unit SysParaBirimiService;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysParaBirimiRepository, SysCurrency;

type
  TSysParaBirimiService = class(TCrudService<TSysCurrency>)
  protected
    FRepository: TSysParaBirimiRepository;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TSysParaBirimiService.Create;
begin
  inherited Create;
end;

destructor TSysParaBirimiService.Destroy;
begin
  inherited;
end;

end.

