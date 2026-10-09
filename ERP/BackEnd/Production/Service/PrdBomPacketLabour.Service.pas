unit PrdBomPacketLabour.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdBomPacketLabour.Repository, PrdBomPacketLabour, PrdBomPacketLabour.Exception;

type
  TPrdBomPacketLabourService = class(TCrudService<TPrdBomPacketLabour>)
  private
    FRepo: IRepository<TPrdBomPacketLabour>;

    procedure DoAdd(AEntity: TPrdBomPacketLabour);
    procedure DoUpdate(AEntity: TPrdBomPacketLabour);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdBomPacketLabour);
    procedure ValidateUnique(AEntity: TPrdBomPacketLabour; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdBomPacketLabour; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBomPacketLabour>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBomPacketLabour; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdBomPacketLabour; override;

    procedure Add(AEntity: TPrdBomPacketLabour); override;
    procedure Update(AEntity: TPrdBomPacketLabour); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketLabour; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketLabour>; override;
    procedure BusinessInsert(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPrdBomPacketLabourService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdBomPacketLabour, TPrdBomPacketLabourRepository>;
  Self.PermissionCode := PERMISSION_PRD_BOM;
end;

destructor TPrdBomPacketLabourService.Destroy;
begin
  inherited;
end;

procedure TPrdBomPacketLabourService.ValidateRequiredReferences(AEntity: TPrdBomPacketLabour);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.PrdBomId, TLangKeys.TPrdBomPacketLabour.ColPrdBomId, 'BoM');
  CheckId(AEntity.PrdPacketLabourId, TLangKeys.TPrdBomPacketLabour.ColPrdPacketLabourId, 'Labour Packet');
end;

procedure TPrdBomPacketLabourService.ValidateUnique(AEntity: TPrdBomPacketLabour; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBomPacketLabour;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('prd_bom_id', '=', TValue.From<Int64>(AEntity.PrdBomId)));
      LFilter.Add(TFilterCriterion.New('prd_packet_labour_id', '=', TValue.From<Int64>(AEntity.PrdPacketLabourId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdBomPacketLabourExceptionPacketUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdBomPacketLabourService.ValidateBusinessRules(AEntity: TPrdBomPacketLabour; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    ValidateRequiredReferences(AEntity);
    if AEntity.Quantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColQuantity, 'Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdBomPacketLabourService.DoAdd(AEntity: TPrdBomPacketLabour);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdBomPacketLabourService.DoUpdate(AEntity: TPrdBomPacketLabour);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdBomPacketLabourService.DoDelete(AId: Int64);
var
  LEntity: TPrdBomPacketLabour;
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

function TPrdBomPacketLabourService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBomPacketLabour>;
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

function TPrdBomPacketLabourService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBomPacketLabour;
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

procedure TPrdBomPacketLabourService.BusinessInsert(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomPacketLabourService.BusinessUpdate(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomPacketLabourService.BusinessDelete(AEntity: TPrdBomPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdBomPacketLabourService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdBomPacketLabourService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdBomPacketLabour>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdBomPacketLabourService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdBomPacketLabour;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdBomPacketLabourService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBomPacketLabour;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdBomPacketLabourService.Add(AEntity: TPrdBomPacketLabour);
begin
  DoAdd(AEntity);
end;

procedure TPrdBomPacketLabourService.Update(AEntity: TPrdBomPacketLabour);
begin
  DoUpdate(AEntity);
end;

procedure TPrdBomPacketLabourService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
