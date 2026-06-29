unit SetStkBarkodHazirlikDosyaTuru.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  Entity, Repository, Service, FilterCriterion, UnitOfWork, SharedFormTypes,
  SetStkBarkodHazirlikDosyaTuru.Repository, SetStkBarkodHazirlikDosyaTuru;

type
  TSetStkBarkodHazirlikDosyaTuruService = class(TCrudService<TSetStkBarkodHazirlikDosyaTuru>)
  private
    FRepo: IRepository<TSetStkBarkodHazirlikDosyaTuru>;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;
    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSetStkBarkodHazirlikDosyaTuru>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSetStkBarkodHazirlikDosyaTuru; override;
    procedure Add(AEntity: TSetStkBarkodHazirlikDosyaTuru); override;
    procedure Update(AEntity: TSetStkBarkodHazirlikDosyaTuru); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkBarkodHazirlikDosyaTuru; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkBarkodHazirlikDosyaTuru>; override;
    procedure BusinessInsert(AEntity: TSetStkBarkodHazirlikDosyaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSetStkBarkodHazirlikDosyaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSetStkBarkodHazirlikDosyaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

constructor TSetStkBarkodHazirlikDosyaTuruService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSetStkBarkodHazirlikDosyaTuru, TSetStkBarkodHazirlikDosyaTuruRepository>;
end;

destructor TSetStkBarkodHazirlikDosyaTuruService.Destroy;
begin
  inherited;
end;

function TSetStkBarkodHazirlikDosyaTuruService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSetStkBarkodHazirlikDosyaTuru>;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.Find(AFilter, ALock);
end;

function TSetStkBarkodHazirlikDosyaTuruService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSetStkBarkodHazirlikDosyaTuru;
begin
  if APermissionControl then
  begin
    Self.UoW.IsAuthorized(ptRead, APermissionControl);
  end;
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  Result := FRepo.FindById(AId, ALock, [ioIncludeAll]);
end;

procedure TSetStkBarkodHazirlikDosyaTuruService.BusinessInsert(AEntity: TSetStkBarkodHazirlikDosyaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetStkBarkodHazirlikDosyaTuruService.BusinessUpdate(AEntity: TSetStkBarkodHazirlikDosyaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TSetStkBarkodHazirlikDosyaTuruService.BusinessDelete(AEntity: TSetStkBarkodHazirlikDosyaTuru; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TSetStkBarkodHazirlikDosyaTuruService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSetStkBarkodHazirlikDosyaTuruService.Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TList<TSetStkBarkodHazirlikDosyaTuru>;
begin
  if AIncludeNestedEntities then
    Result := FRepo.Find(AFilter, ALock, [ioIncludeAll])
  else
    Result := FRepo.Find(AFilter, ALock);
end;

function TSetStkBarkodHazirlikDosyaTuruService.FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean): TSetStkBarkodHazirlikDosyaTuru;
begin
  if AIncludeNestedEntities then
    Result := FRepo.FindById(AId, ALock, [ioIncludeAll])
  else
    Result := FRepo.FindById(AId, ALock);
end;

procedure TSetStkBarkodHazirlikDosyaTuruService.Add(AEntity: TSetStkBarkodHazirlikDosyaTuru);
begin
  FRepo.Add(AEntity);
end;

procedure TSetStkBarkodHazirlikDosyaTuruService.Update(AEntity: TSetStkBarkodHazirlikDosyaTuru);
begin
  FRepo.Update(AEntity);
end;

procedure TSetStkBarkodHazirlikDosyaTuruService.Delete(AId: Int64);
begin
  FRepo.Delete(AId);
end;

end.
