unit PrdPacketLabour.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdPacketLabour.Repository, PrdPacketLabour, PrdPacketLabour.Exception;

type
  TPrdPacketLabourService = class(TCrudService<TPrdPacketLabour>)
  private
    FRepo: IRepository<TPrdPacketLabour>;

    procedure DoAdd(AEntity: TPrdPacketLabour);
    procedure DoUpdate(AEntity: TPrdPacketLabour);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdPacketLabour);
    procedure ValidateUnique(AEntity: TPrdPacketLabour; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdPacketLabour; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketLabour>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketLabour; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdPacketLabour; override;

    procedure Add(AEntity: TPrdPacketLabour); override;
    procedure Update(AEntity: TPrdPacketLabour); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketLabour; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketLabour>; override;
    procedure BusinessInsert(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TPrdPacketLabourService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdPacketLabour, TPrdPacketLabourRepository>;
  Self.PermissionCode := PERMISSION_PRD_PACKET_LABOUR;
end;

destructor TPrdPacketLabourService.Destroy;
begin
  inherited;
end;

procedure TPrdPacketLabourService.ValidateRequiredReferences(AEntity: TPrdPacketLabour);
begin
  // zorunlu referans yok
end;

procedure TPrdPacketLabourService.ValidateUnique(AEntity: TPrdPacketLabour; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdPacketLabour;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('packet_name', '=', TValue.From<string>(AEntity.PacketName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdPacketLabourExceptionPacketNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdPacketLabourService.ValidateBusinessRules(AEntity: TPrdPacketLabour; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.PacketName := Trim(AEntity.PacketName);
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdPacketLabourService.DoAdd(AEntity: TPrdPacketLabour);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdPacketLabourService.DoUpdate(AEntity: TPrdPacketLabour);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdPacketLabourService.DoDelete(AId: Int64);
var
  LEntity: TPrdPacketLabour;
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

function TPrdPacketLabourService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketLabour>;
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

function TPrdPacketLabourService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketLabour;
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

procedure TPrdPacketLabourService.BusinessInsert(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketLabourService.BusinessUpdate(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketLabourService.BusinessDelete(AEntity: TPrdPacketLabour; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdPacketLabourService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdPacketLabourService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdPacketLabour>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TPrdPacketLabourService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdPacketLabour;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TPrdPacketLabourService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketLabour;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdPacketLabourService.Add(AEntity: TPrdPacketLabour);
begin
  DoAdd(AEntity);
end;

procedure TPrdPacketLabourService.Update(AEntity: TPrdPacketLabour);
begin
  DoUpdate(AEntity);
end;

procedure TPrdPacketLabourService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
