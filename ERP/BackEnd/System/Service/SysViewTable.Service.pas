unit SysViewTable.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
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
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysViewTable; override;

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
  Self.PermissionCode := 1;
end;

destructor TSysViewTableService.Destroy;
begin
  inherited;
end;

function TSysViewTableService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysViewTableService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysViewTable>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysViewTableService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysViewTable;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysViewTableService.FindOne(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TSysViewTable;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysViewTableService.Add(AEntity: TSysViewTable);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableService.Update(AEntity: TSysViewTable);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableService.Delete(AId: Int64);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

function TSysViewTableService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysViewTable>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysViewTableService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysViewTable;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysViewTableService.BusinessInsert(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableService.BusinessUpdate(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

procedure TSysViewTableService.BusinessDelete(AEntity: TSysViewTable; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  raise ENotSupportedException.Create('sys_view_tables is a read-only view');
end;

end.
