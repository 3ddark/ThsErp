unit QcReceiptLine.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  QcReceiptLine.Repository, QcReceiptLine, QcReceiptLine.Exception;

type
  // Kontrol bekleyen mal kabul kalemleri (salt okunur, kalite kontrol kaydı yetkisi)
  TQcReceiptLineService = class(TCrudService<TQcReceiptLine>)
  private
    FRepo: IRepository<TQcReceiptLine>;

    procedure DoAdd(AEntity: TQcReceiptLine);
    procedure DoUpdate(AEntity: TQcReceiptLine);
    procedure DoDelete(AId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TQcReceiptLine; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TQcReceiptLine>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TQcReceiptLine; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TQcReceiptLine; override;

    procedure Add(AEntity: TQcReceiptLine); override;
    procedure Update(AEntity: TQcReceiptLine); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcReceiptLine; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcReceiptLine>; override;
    procedure BusinessInsert(AEntity: TQcReceiptLine; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TQcReceiptLine; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TQcReceiptLine; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TQcReceiptLineService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TQcReceiptLine, TQcReceiptLineRepository>;
  Self.PermissionCode := PERMISSION_QC_INSPECTION;
end;

destructor TQcReceiptLineService.Destroy;
begin
  inherited;
end;

procedure TQcReceiptLineService.ValidateBusinessRules(AEntity: TQcReceiptLine; AOperation: TCrudOperation);
begin
  raise EQcReceiptLineExceptionReadOnly.Create;
end;

procedure TQcReceiptLineService.DoAdd(AEntity: TQcReceiptLine);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TQcReceiptLineService.DoUpdate(AEntity: TQcReceiptLine);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TQcReceiptLineService.DoDelete(AId: Int64);
var
  LEntity: TQcReceiptLine;
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

function TQcReceiptLineService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcReceiptLine>;
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

function TQcReceiptLineService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcReceiptLine;
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

procedure TQcReceiptLineService.BusinessInsert(AEntity: TQcReceiptLine; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcReceiptLineService.BusinessUpdate(AEntity: TQcReceiptLine; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcReceiptLineService.BusinessDelete(AEntity: TQcReceiptLine; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TQcReceiptLineService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TQcReceiptLineService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TQcReceiptLine>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TQcReceiptLineService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TQcReceiptLine;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TQcReceiptLineService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TQcReceiptLine;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TQcReceiptLineService.Add(AEntity: TQcReceiptLine);
begin
  DoAdd(AEntity);
end;

procedure TQcReceiptLineService.Update(AEntity: TQcReceiptLine);
begin
  DoUpdate(AEntity);
end;

procedure TQcReceiptLineService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
