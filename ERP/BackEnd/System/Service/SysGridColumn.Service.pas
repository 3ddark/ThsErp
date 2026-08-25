unit SysGridColumn.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext,
  SysGridColumn.Repository, SysGridColumn, SysGridColumn.Exception;

type
  TSysGridColumnService = class(TCrudService<TSysGridColumn>)
  private
    FRepo: IRepository<TSysGridColumn>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysGridColumn; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysGridColumn>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysGridColumn; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysGridColumn; override;

    procedure Add(AEntity: TSysGridColumn); override;
    procedure Update(AEntity: TSysGridColumn); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridColumn; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridColumn>; override;
    procedure BusinessInsert(AEntity: TSysGridColumn; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysGridColumn; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysGridColumn; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSysGridColumnService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysGridColumn, TSysGridColumnRepository>;
  Self.PermissionCode := 1;
end;

destructor TSysGridColumnService.Destroy;
begin
  inherited;
end;

function TSysGridColumnService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysGridColumn>;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.Find(AFilter, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

function TSysGridColumnService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysGridColumn;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    Result := FRepo.FindById(AId, ALock);
  except
    if Self.UoW.InTransaction then
    begin
      Self.UoW.Rollback;
    end;
    raise;
  end;
end;

procedure TSysGridColumnService.BusinessInsert(AEntity: TSysGridColumn; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    ValidateAll(AEntity, coInsert);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Add(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysGridColumnService.BusinessUpdate(AEntity: TSysGridColumn; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    ValidateAll(AEntity, coUpdate);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Update(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

procedure TSysGridColumnService.BusinessDelete(AEntity: TSysGridColumn; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    ValidateAll(AEntity, coDelete);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    FRepo.Delete(AEntity);

    if AWithCommit and Uow.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Self.UoW.InTransaction then
      begin
        Self.UoW.Rollback;
      end;
      raise;
    end;
  end;
end;

function TSysGridColumnService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysGridColumnService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysGridColumn>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysGridColumnService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysGridColumn;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysGridColumnService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysGridColumn;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysGridColumnService.Add(AEntity: TSysGridColumn);
begin
  FRepo.Add(AEntity);
end;

procedure TSysGridColumnService.Update(AEntity: TSysGridColumn);
begin
  FRepo.Update(AEntity);
end;

procedure TSysGridColumnService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

procedure TSysGridColumnService.ValidateBusinessRules(AEntity: TSysGridColumn; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysGridColumn;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('table_name', '=', TValue.From<string>(AEntity.TableName)));
      LFilter.Add(TFilterCriterion.New('column_name', '=', TValue.From<string>(AEntity.ColumnName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      if Assigned(LModel) then
        raise ESysGridColumnExceptionTableNameColumnNameUnique.Create;
    finally
      LFilter.Free;
      if Assigned(LModel) then
        LModel.Free;
    end;
  end;
end;

end.
