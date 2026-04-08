unit SysUom.Service;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SysUom.Repository, SysUom;

type
  TSysUomService = class(TCrudService<TSysUom>)
  private
    FRepo: IRepository<TSysUom>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUom>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysUom; override;
    procedure Add(AEntity: TSysUom); override;
    procedure Update(AEntity: TSysUom); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUom; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUom>; override;
    procedure BusinessInsert(AEntity: TSysUom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysUom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysUom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysUomService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysUom, TSysUomRepository>;
end;

destructor TSysUomService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSysUomService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysUom>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSysUomService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysUom;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
    //CheckPermission if not throw exception
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysUomService.BusinessInsert(AEntity: TSysUom; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TSysUomService.BusinessUpdate(AEntity: TSysUom; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSysUomService.BusinessDelete(AEntity: TSysUom; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);
      //CheckPermission if not throw exception
    end;

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
        Self.UoW.Rollback;
      raise;
    end;
  end;
end;

function TSysUomService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysUomService.Find(AFilter: TFilterCriteria; ALock: Boolean): TList<TSysUom>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysUomService.FindById(AId: Int64; ALock: Boolean): TSysUom;
begin
  Result := FRepo.FindById(AId, ALock);
end;

procedure TSysUomService.Add(AEntity: TSysUom);
begin
  FRepo.Add(AEntity);
end;

procedure TSysUomService.Update(AEntity: TSysUom);
begin
  FRepo.Update(AEntity);
end;

procedure TSysUomService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.

