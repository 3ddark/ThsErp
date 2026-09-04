unit SysAccessRight.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  SharedFormTypes, AppContext, LocalizationManager,
  SysAccessRight.Repository, SysAccessRight, SysAccessRight.Exception;

type
  TSysAccessRightService = class(TCrudService<TSysAccessRight>)
  private
    FRepo: IRepository<TSysAccessRight>;

    procedure DoAdd(AEntity: TSysAccessRight);
    procedure DoUpdate(AEntity: TSysAccessRight);
    procedure DoDelete(AId: Int64);

    procedure ValidateInsert(AEntity: TSysAccessRight);
    procedure ValidateUpdate(AEntity: TSysAccessRight);
    procedure ValidateDelete(AEntity: TSysAccessRight);
    procedure ValidateUniqueUserPermission(AEntity: TSysAccessRight; AOperation: TCrudOperation);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TSysAccessRight; AOperation: TCrudOperation); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TSysAccessRight>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TSysAccessRight; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TSysAccessRight; override;

    procedure Add(AEntity: TSysAccessRight); override;
    procedure Update(AEntity: TSysAccessRight); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysAccessRight; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysAccessRight>; override;
    procedure BusinessInsert(AEntity: TSysAccessRight; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysAccessRight; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysAccessRight; AWithBegin, AWithCommit, APermissionControl: Boolean); override;

    procedure CopyUserAccessRights(ASourceUserId, ATargetUserId: Int64);
    procedure AddPermissionToAllUser(APermissionId: Int64; AWithBegin, AWithCommit: Boolean);

    /// <summary>
    /// Belirtilen yetki kodu ve erişim türü için kullanıcının yetkili olup
    /// olmadığını kontrol eder.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Bu metot yetki kontrolünün temel uygulamasıdır. Kontrol sonucunda
    /// herhangi bir authorization exception fırlatılmaz; sonuç Boolean
    /// değer olarak döndürülür.
    /// </para>
    /// <para>
    /// Kullanıcının belirtilen yetkiye sahip olması durumunda <c>True</c>,
    /// yetkiye sahip olmaması durumunda <c>False</c> döndürülür.
    /// </para>
    /// <para>
    /// <c>APermissionType</c> parametresi ile aşağıdaki erişim türleri kontrol edilir:
    /// </para>
    /// <list type="bullet">
    ///   <item>
    ///     <description><c>ptRead</c>: Kayıt okuma hakkı.</description>
    ///   </item>
    ///   <item>
    ///     <description><c>ptAddRecord</c>: Yeni kayıt ekleme hakkı.</description>
    ///   </item>
    ///   <item>
    ///     <description><c>ptUpdate</c>: Kayıt güncelleme hakkı.</description>
    ///   </item>
    ///   <item>
    ///     <description><c>ptDelete</c>: Kayıt silme hakkı.</description>
    ///   </item>
    ///   <item>
    ///     <description><c>ptSpecial</c>: Özel işlem yapma hakkı.</description>
    ///   </item>
    /// </list>
    /// <para>
    /// <c>EnsureAuthorized</c> metodu, bu metodun sonucunu kullanarak
    /// yetki bulunmaması durumunda ilgili authorization exception'ı fırlatır.
    /// </para>
    /// </remarks>
    /// <param name="APermissionCode">
    /// Kontrol edilecek yetkinin benzersiz yetki kodu.
    /// </param>
    /// <param name="APermissionType">
    /// Kontrol edilecek erişim hakkının türü.
    /// </param>
    /// <param name="APermissionControl">
    /// Yetki kontrolünün etkin olup olmadığını belirler.
    /// <c>True</c> ise yetki kontrolü gerçekleştirilir.
    /// <c>False</c> ise yetki kontrolü uygulanmaz.
    /// </param>
    /// <returns>
    /// Kullanıcının belirtilen yetkiye sahip olması durumunda <c>True</c>;
    /// yetkiye sahip olmaması durumunda <c>False</c>.
    /// </returns>
    function IsAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean): Boolean;

    /// <summary>
    /// Belirtilen yetki kodu ve erişim türü için kullanıcının yetkili olup
    /// olmadığını kontrol eder.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Yetki kontrolü <c>IsAuthorized</c> metodu üzerinden gerçekleştirilir.
    /// </para>
    /// <para>
    /// <c>IsAuthorized</c> sonucu <c>True</c> ise metot normal şekilde tamamlanır.
    /// Sonuç <c>False</c> ise erişim türüne uygun
    /// <c>EAuthorizationException</c> türevi fırlatılır.
    /// </para>
    /// </remarks>
    /// <param name="APermissionCode">
    /// Kontrol edilecek yetkinin benzersiz yetki kodu.
    /// </param>
    /// <param name="APermissionType">
    /// Kontrol edilecek erişim hakkının türü.
    /// </param>
    /// <param name="APermissionControl">
    /// Yetki kontrolünün etkin olup olmadığını belirler.
    /// <c>True</c> ise yetki kontrolü gerçekleştirilir.
    /// <c>False</c> ise yetki kontrolü uygulanmaz.
    /// </param>
    /// <exception cref="EAuthorizationExceptionRead">
    /// Okuma yetkisi bulunmadığında fırlatılır.
    /// </exception>
    /// <exception cref="EAuthorizationExceptionAdd">
    /// Yeni kayıt ekleme yetkisi bulunmadığında fırlatılır.
    /// </exception>
    /// <exception cref="EAuthorizationExceptionUpdate">
    /// Kayıt güncelleme yetkisi bulunmadığında fırlatılır.
    /// </exception>
    /// <exception cref="EAuthorizationExceptionDelete">
    /// Kayıt silme yetkisi bulunmadığında fırlatılır.
    /// </exception>
    /// <exception cref="EAuthorizationExceptionSpecial">
    /// Özel işlem yetkisi bulunmadığında fırlatılır.
    /// </exception>
    procedure EnsureAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean);
  end;

implementation

uses
  UnitOfWork, SysPermission.Service;

constructor TSysAccessRightService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TSysAccessRight, TSysAccessRightRepository>;
  Self.PermissionCode := PERMISSION_TEMPLATE;
end;

destructor TSysAccessRightService.Destroy;
begin
  inherited;
end;

procedure TSysAccessRightService.ValidateInsert(AEntity: TSysAccessRight);
begin
  ValidateUniqueUserPermission(AEntity, coInsert);
end;

procedure TSysAccessRightService.ValidateUpdate(AEntity: TSysAccessRight);
begin
  ValidateUniqueUserPermission(AEntity, coUpdate);
end;

procedure TSysAccessRightService.ValidateDelete(AEntity: TSysAccessRight);
begin

end;

procedure TSysAccessRightService.DoAdd(AEntity: TSysAccessRight);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TSysAccessRightService.DoUpdate(AEntity: TSysAccessRight);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TSysAccessRightService.DoDelete(AId: Int64);
var
  LEntity: TSysAccessRight;
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

function TSysAccessRightService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TSysAccessRight>;
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

function TSysAccessRightService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TSysAccessRight;
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

procedure TSysAccessRightService.BusinessInsert(AEntity: TSysAccessRight; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptAddRecord, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoAdd(AEntity);

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

procedure TSysAccessRightService.BusinessUpdate(AEntity: TSysAccessRight; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptUpdate, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoUpdate(AEntity);

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

procedure TSysAccessRightService.BusinessDelete(AEntity: TSysAccessRight; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    Self.UoW.EnsureAuthorized(Self.PermissionCode, ptDelete, APermissionControl);

    if AWithBegin and not Self.UoW.InTransaction then
      Self.UoW.BeginTransaction;

    DoDelete(AEntity.Id);

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

function TSysAccessRightService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TSysAccessRightService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TSysAccessRight>;
begin
  Result := FRepo.Find(AFilter, ALock);
end;

function TSysAccessRightService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TSysAccessRight;
begin
  Result := FRepo.FindById(AId, ALock);
end;

function TSysAccessRightService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TSysAccessRight;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TSysAccessRightService.Add(AEntity: TSysAccessRight);
begin
  DoAdd(AEntity)
end;

procedure TSysAccessRightService.Update(AEntity: TSysAccessRight);
begin
  DoUpdate(AEntity);
end;

procedure TSysAccessRightService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

procedure TSysAccessRightService.ValidateBusinessRules(AEntity: TSysAccessRight; AOperation: TCrudOperation);
begin
  case AOperation of
    coInsert: ValidateInsert(AEntity);
    coUpdate: ValidateUpdate(AEntity);
    coDelete: ValidateDelete(AEntity);
  end;
end;

procedure TSysAccessRightService.ValidateUniqueUserPermission(AEntity: TSysAccessRight; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TSysAccessRight;
begin
  //check unique
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('permission_id', '=', TValue.From<Int64>(AEntity.PermissionId)));
      LFilter.Add(TFilterCriterion.New('user_id', '=', TValue.From<Int64>(TAppContext.Instance.CurrentUser.GetUserId)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EAuthorizationExceptionPermissionUserUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TSysAccessRightService.CopyUserAccessRights(ASourceUserId, ATargetUserId: Int64);
begin
  if not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    TSysAccessRightRepository(FRepo).CopyUserAccessRights(ASourceUserId, ATargetUserId);
    Self.UoW.Commit;
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TSysAccessRightService.AddPermissionToAllUser(APermissionId: Int64; AWithBegin, AWithCommit: Boolean);
begin
  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;
  try
    TSysAccessRightRepository(FRepo).AddPermissionToAllUser(APermissionId);

    if AWithCommit then
      Self.UoW.Commit;
  except
    if AWithCommit and Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

function TSysAccessRightService.IsAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean): Boolean;
var
  LFilter: TFilterCriteria;
  LAccess: TSysAccessRight;
begin
  if not APermissionControl then
    Exit(True);

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('permission_code', '=', TValue.From<Integer>(APermissionCode)));
    LFilter.Add(TFilterCriterion.New('user_id', '=', TValue.From<Int64>(TAppContext.Instance.CurrentUser.User.Id)));

    LAccess := FRepo.FindOne(LFilter, False);
    if not Assigned(LAccess) then
      Exit(False);

    case APermissionType of
      ptRead:       Exit(LAccess.IsRead);
      ptAddRecord:  Exit(LAccess.IsAdd);
      ptUpdate:     Exit(LAccess.IsUpdate);
      ptDelete:     Exit(LAccess.IsDelete);
      ptSpecial:    Exit(LAccess.IsSpecial);
    else
      raise EArgumentOutOfRangeException.Create(TLocalizationManager.Translate(TLangKeys.TMessage.UnknownPermissionType, [Ord(APermissionType)]));
    end;
  finally
    LFilter.Free;
    if Assigned(LAccess) then
      FreeAndNil(LAccess);
  end;
end;

procedure TSysAccessRightService.EnsureAuthorized(APermissionCode: Integer; APermissionType: TPermissionType; APermissionControl: Boolean);
begin
  if Self.IsAuthorized(APermissionCode, APermissionType, APermissionControl) then
    Exit;

  case APermissionType of
      ptRead:       raise EAuthorizationExceptionRead.Create;
      ptAddRecord:  raise EAuthorizationExceptionAdd.Create;
      ptUpdate:     raise EAuthorizationExceptionUpdate.Create;
      ptDelete:     raise EAuthorizationExceptionDelete.Create;
      ptSpecial:    raise EAuthorizationExceptionSpecial.Create;
  else
    raise EArgumentOutOfRangeException.Create(TLocalizationManager.Translate(TLangKeys.TMessage.UnknownPermissionType, [Ord(APermissionType)]));
  end;
end;

end.

