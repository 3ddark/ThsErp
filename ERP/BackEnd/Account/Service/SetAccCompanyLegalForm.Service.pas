unit SetAccCompanyLegalForm.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetAccCompanyLegalForm.Repository, SetAccCompanyLegalForm;

type
  TSetAccCompanyLegalFormService = class(TCrudService<TSetAccCompanyLegalForm>)
  private
    FRepo: IRepository<TSetAccCompanyLegalForm>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetAccCompanyLegalForm>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetAccCompanyLegalForm; override;
    procedure Add(AEntity: TSetAccCompanyLegalForm); override;
    procedure Update(AEntity: TSetAccCompanyLegalForm); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetAccCompanyLegalForm; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetAccCompanyLegalForm>; override;
    procedure BusinessInsert(AEntity: TSetAccCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetAccCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetAccCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetAccCompanyLegalFormService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetAccCompanyLegalForm, TSetAccCompanyLegalFormRepository>;
end;

destructor TSetAccCompanyLegalFormService.Destroy;
begin
  FRepo := nil;
  inherited;
end;

function TSetAccCompanyLegalFormService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetAccCompanyLegalForm>;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetAccCompanyLegalFormService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetAccCompanyLegalForm;
begin
  if APermissionControl then
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetAccCompanyLegalFormService.BusinessInsert(AEntity: TSetAccCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptAddRecord, APermissionControl);

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

procedure TSetAccCompanyLegalFormService.BusinessUpdate(AEntity: TSetAccCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptUpdate, APermissionControl);

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

procedure TSetAccCompanyLegalFormService.BusinessDelete(AEntity: TSetAccCompanyLegalForm; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
      Self.UoW.IsAuthorized(ptDelete, APermissionControl);

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

function TSetAccCompanyLegalFormService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetAccCompanyLegalFormService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetAccCompanyLegalForm>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetAccCompanyLegalFormService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetAccCompanyLegalForm;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetAccCompanyLegalFormService.Add(AEntity: TSetAccCompanyLegalForm);
begin
  FRepo.Add(AEntity);
end;

procedure TSetAccCompanyLegalFormService.Update(AEntity: TSetAccCompanyLegalForm);
begin
  FRepo.Update(AEntity);
end;

procedure TSetAccCompanyLegalFormService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
