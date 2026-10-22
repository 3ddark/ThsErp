unit QcSetting.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  QcSetting.Repository, QcSetting, QcSetting.Exception;

type
  // Kalite kontrol ayarı (firma başına tek kayıt). IsEnabled yetkisiz okunur: diğer modüller yalnız bunu sorar
  TQcSettingService = class(TCrudService<TQcSetting>)
  private
    FRepo: IRepository<TQcSetting>;

    procedure DoAdd(AEntity: TQcSetting);
    procedure DoUpdate(AEntity: TQcSetting);
    procedure DoDelete(AId: Int64);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TQcSetting; AOperation: TCrudOperation); override;
    // Ayar ekranı: firmanın kaydı (yoksa nil)
    function BusinessFindSetting(AWithBegin, ALock, APermissionControl: Boolean): TQcSetting;
    // Modül açık mı (yetki gerektirmez)
    function IsEnabled: Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TQcSetting>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TQcSetting; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TQcSetting; override;

    procedure Add(AEntity: TQcSetting); override;
    procedure Update(AEntity: TQcSetting); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcSetting; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcSetting>; override;
    procedure BusinessInsert(AEntity: TQcSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TQcSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TQcSetting; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service;

constructor TQcSettingService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TQcSetting, TQcSettingRepository>;
  Self.PermissionCode := PERMISSION_QC_SETTING;
end;

destructor TQcSettingService.Destroy;
begin
  inherited;
end;

function TQcSettingService.IsEnabled: Boolean;
begin
  Result := TQcSettingRepository(FRepo).IsEnabled;
end;

function TQcSettingService.BusinessFindSetting(AWithBegin, ALock, APermissionControl: Boolean): TQcSetting;
var
  LFilter: TFilterCriteria;
  LCompanyId: Int64;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    Result := nil;
    LCompanyId := TQcSettingRepository(FRepo).CompanyId;
    if LCompanyId <= 0 then
      Exit;
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('sys_application_setting_id', '=', TValue.From<Int64>(LCompanyId)));
      Result := FRepo.FindOne(LFilter, ALock);
    finally
      LFilter.Free;
    end;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TQcSettingService.ValidateBusinessRules(AEntity: TQcSetting; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TQcSetting;
begin
  if AOperation = coDelete then
    Exit;

  AEntity.Description := Trim(AEntity.Description);
  // firma kaydı servisten (tek firma: sys_application_setting)
  if AEntity.SysApplicationSettingId <= 0 then
    AEntity.SysApplicationSettingId := TQcSettingRepository(FRepo).CompanyId;
  if AEntity.SysApplicationSettingId <= 0 then
    raise EQcSettingExceptionNoCompany.Create;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('sys_application_setting_id', '=', TValue.From<Int64>(AEntity.SysApplicationSettingId)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));
    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise EQcSettingExceptionUnique.Create;
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TQcSettingService.DoAdd(AEntity: TQcSetting);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TQcSettingService.DoUpdate(AEntity: TQcSetting);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TQcSettingService.DoDelete(AId: Int64);
var
  LEntity: TQcSetting;
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

function TQcSettingService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TQcSetting>;
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

function TQcSettingService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TQcSetting;
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

procedure TQcSettingService.BusinessInsert(AEntity: TQcSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcSettingService.BusinessUpdate(AEntity: TQcSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TQcSettingService.BusinessDelete(AEntity: TQcSetting; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TQcSettingService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TQcSettingService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TQcSetting>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TQcSettingService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TQcSetting;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TQcSettingService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TQcSetting;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TQcSettingService.Add(AEntity: TQcSetting);
begin
  DoAdd(AEntity);
end;

procedure TQcSettingService.Update(AEntity: TQcSetting);
begin
  DoUpdate(AEntity);
end;

procedure TQcSettingService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
