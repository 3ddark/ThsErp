unit SysViewTable.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysViewTable.Repository, SysViewTable;

type
  TSysViewTableService = class(TCrudService<TSysViewTable>)
  private
    FRepo: IRepository<TSysViewTable>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysViewTable>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysViewTable; override;
    procedure Add(AEntity: TSysViewTable); override;
    procedure Update(AEntity: TSysViewTable); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysViewTable; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysViewTable>; override;
    procedure BusinessInsert(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysViewTableService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysViewTable, TSysViewTableRepository>;
end;

destructor TSysViewTableService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSysViewTableService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysViewTable>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSysViewTableService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysViewTable;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysViewTableService.BusinessInsert(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise Exception.Create('SysViewTable is a read-only view. Insert is not supported.');
end;

procedure TSysViewTableService.BusinessUpdate(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise Exception.Create('SysViewTable is a read-only view. Update is not supported.');
end;

procedure TSysViewTableService.BusinessDelete(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise Exception.Create('SysViewTable is a read-only view. Delete is not supported.');
end;

function TSysViewTableService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysViewTableService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSysViewTable>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSysViewTableService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysViewTable;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSysViewTableService.Add(AEntity: TSysViewTable);
begin
  raise Exception.Create('SysViewTable is a read-only view. Add is not supported.');
end;

procedure TSysViewTableService.Update(AEntity: TSysViewTable);
begin
  raise Exception.Create('SysViewTable is a read-only view. Update is not supported.');
end;

procedure TSysViewTableService.Delete(AId: Int64);
begin
  raise Exception.Create('SysViewTable is a read-only view. Delete is not supported.');
end;

end.
