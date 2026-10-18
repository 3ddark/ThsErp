unit EInvVehicle.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  EInvVehicle.Repository, EInvVehicle, EInvVehicle.Exception;

type
  TEInvVehicleService = class(TCrudService<TEInvVehicle>)
  private
    FRepo: IRepository<TEInvVehicle>;

    procedure DoAdd(AEntity: TEInvVehicle);
    procedure DoUpdate(AEntity: TEInvVehicle);
    procedure DoDelete(AId: Int64);

    procedure FailRequired(const AKey, ADefault: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TEInvVehicle; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TEInvVehicle>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TEInvVehicle; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TEInvVehicle; override;

    procedure Add(AEntity: TEInvVehicle); override;
    procedure Update(AEntity: TEInvVehicle); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvVehicle; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvVehicle>; override;
    procedure BusinessInsert(AEntity: TEInvVehicle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TEInvVehicle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TEInvVehicle; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, EInvLookup;

constructor TEInvVehicleService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TEInvVehicle, TEInvVehicleRepository>;
  Self.PermissionCode := PERMISSION_EINV_VEHICLE;
end;

destructor TEInvVehicleService.Destroy;
begin
  inherited;
end;

// Alan adı + "zorunludur" mesajı
procedure TEInvVehicleService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;


procedure TEInvVehicleService.ValidateBusinessRules(AEntity: TEInvVehicle; AOperation: TCrudOperation);
var
  LRepo: TEInvVehicleRepository;
begin
  LRepo := TEInvVehicleRepository(FRepo);
  if AOperation = coDelete then
  begin
    if LRepo.UsageCount(AEntity.Id) > 0 then
      raise EEInvVehicleExceptionInUse.Create;
    Exit;
  end;

  // plaka boşluk / tire olmadan büyük harf saklanır (34 ABC 123 -> 34ABC123)
  AEntity.PlateNo := TEInvLookup.NormalizePlate(AEntity.PlateNo);
  AEntity.Description := Trim(AEntity.Description);
  if AEntity.PlateNo = '' then
    FailRequired(TLangKeys.TEInvVehicle.ColPlateNo, 'Plate No');
  if not TEInvLookup.IsValidPlate(AEntity.PlateNo) then
    raise EEInvVehicleExceptionPlateInvalid.Create;
  if LRepo.PlateExists(AEntity.PlateNo, TEInvLookup.ExcludeId(AEntity.Id, AOperation = coUpdate)) then
    raise EEInvVehicleExceptionPlateUnique.Create;
end;

procedure TEInvVehicleService.DoAdd(AEntity: TEInvVehicle);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TEInvVehicleService.DoUpdate(AEntity: TEInvVehicle);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TEInvVehicleService.DoDelete(AId: Int64);
var
  LEntity: TEInvVehicle;
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

function TEInvVehicleService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TEInvVehicle>;
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

function TEInvVehicleService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TEInvVehicle;
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

procedure TEInvVehicleService.BusinessInsert(AEntity: TEInvVehicle; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvVehicleService.BusinessUpdate(AEntity: TEInvVehicle; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TEInvVehicleService.BusinessDelete(AEntity: TEInvVehicle; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TEInvVehicleService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TEInvVehicleService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TEInvVehicle>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TEInvVehicleService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TEInvVehicle;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TEInvVehicleService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TEInvVehicle;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TEInvVehicleService.Add(AEntity: TEInvVehicle);
begin
  DoAdd(AEntity);
end;

procedure TEInvVehicleService.Update(AEntity: TEInvVehicle);
begin
  DoUpdate(AEntity);
end;

procedure TEInvVehicleService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
