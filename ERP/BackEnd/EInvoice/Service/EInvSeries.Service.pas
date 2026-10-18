unit EInvSeries.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvSeries.Repository, EInvSeries, EInvSeries.Exception;

type
  TEInvSeriesService = class(TCrudService<TEInvSeries>)
  private
    FRepo: IRepository<TEInvSeries>;

    procedure DoAdd(AEntity: TEInvSeries);
    procedure DoUpdate(AEntity: TEInvSeries);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvSeries; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvSeries>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvSeries; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvSeries; override;

    procedure Add(AEntity: TEInvSeries); override;
    procedure Update(AEntity: TEInvSeries); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvSeries; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvSeries>; override;
    procedure BusinessInsert(AEntity: TEInvSeries; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvSeries; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvSeries; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvSeriesService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvSeries, TEInvSeriesRepository>;
  Self.PermissionCode := PERMISSION_EINV_SERIES;
end;

destructor TEInvSeriesService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvSeriesService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvSeriesService.ValidateBusinessRules(AEntity: TEInvSeries; AOperation: TCrudOperation);
var
  LRepo: TEInvSeriesRepository;
begin
  LRepo := TEInvSeriesRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvSeriesExceptionInUse.Create;
    Exit;
  end;

  AEntity.Code := AnsiUpperCase(Trim(AEntity.Code));
  AEntity.Name := Trim(AEntity.Name);
  if AEntity.Code = '' then
    FailRequired(TLangKeys.TEInvSeries.ColCode, 'Code');
  if AEntity.Name = '' then
    FailRequired(TLangKeys.TEInvSeries.ColName, 'Name');
  if not TEInvLookup.IsValidSeriesCode(AEntity.Code) then
    raise EEInvSeriesExceptionCodeFormat.Create;
  if not TEInvLookup.IsValid(elkSeriesScope, AEntity.SeriesScope) then
    FailRequired(TLangKeys.TEInvSeries.ColSeriesScope, 'Used For');
  if LRepo.CodeExists(AEntity.Code, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvSeriesExceptionCodeUnique.Create;
end;

procedure TEInvSeriesService.DoAdd(AEntity: TEInvSeries);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvSeriesService.DoUpdate(AEntity: TEInvSeries);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvSeriesService.DoDelete(AId: Int64);
var
  LEntity: TEInvSeries;
begin
  LEntity := FRepo.FindById(AId, False);
  try
    if not Assigned(LEntity) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordNotFoundD, [AId]));

    ValidateAll(LEntity, coDelete);
    FRepo.Delete(LEntity);
  finally
    LEntity.Free;
  end;
end;

function TEInvSeriesService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvSeries>;
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

function TEInvSeriesService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvSeries;
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

procedure TEInvSeriesService.BusinessInsert(AEntity: TEInvSeries; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEInvSeriesService.BusinessUpdate(AEntity: TEInvSeries; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TEInvSeriesService.BusinessDelete(AEntity: TEInvSeries; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TEInvSeriesService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvSeriesService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvSeries>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvSeriesService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvSeries;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvSeriesService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvSeries;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvSeriesService.Add(AEntity: TEInvSeries);
begin
  DoAdd(AEntity);
end;

procedure TEInvSeriesService.Update(AEntity: TEInvSeries);
begin
  DoUpdate(AEntity);
end;

procedure TEInvSeriesService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
