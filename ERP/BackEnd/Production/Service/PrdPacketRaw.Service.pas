unit PrdPacketRaw.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  PrdPacketRaw.Repository, PrdPacketRaw, PrdPacketRaw.Exception,
  DocumentService, PrdPacketRawDetail, PrdPacketRawDetail.Repository;

type
  // Hammadde paketi belgesi = başlık + Lines (TDocumentService: kalemler bellekte, başlıkla tek transaction).
  TPrdPacketRawService = class(TDocumentService<TPrdPacketRaw, TPrdPacketRawDetail>)
  private
    FRepo: IRepository<TPrdPacketRaw>;

    procedure DoAdd(AEntity: TPrdPacketRaw);
    procedure DoUpdate(AEntity: TPrdPacketRaw);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdPacketRaw);
    procedure ValidateUnique(AEntity: TPrdPacketRaw; AOperation: TCrudOperation);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPrdPacketRaw): TObjectList<TPrdPacketRawDetail>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPrdPacketRawDetail>; override;
    function GetLineHeaderId(ALine: TPrdPacketRawDetail): Int64; override;
    procedure SetLineHeaderId(ALine: TPrdPacketRawDetail; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPrdPacketRawDetail): Integer; override;
    procedure SetLineNo(ALine: TPrdPacketRawDetail; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPrdPacketRaw; ALine: TPrdPacketRawDetail); override;
    procedure CheckLines(AHeader: TPrdPacketRaw; const ALines: TArray<TPrdPacketRawDetail>; AOldLines: TObjectList<TPrdPacketRawDetail>); override;
    procedure PrepareCopyHeader(AHeader: TPrdPacketRaw); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdPacketRaw; AOperation: TCrudOperation); override;
    // Tutar yok: hesap gerekmez
    procedure RecalculateLine(ALine: TPrdPacketRawDetail); override;
    procedure RecalculateTotals(AHeader: TPrdPacketRaw); override;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdPacketRaw>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdPacketRaw; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdPacketRaw; override;

    procedure Add(AEntity: TPrdPacketRaw); override;
    procedure Update(AEntity: TPrdPacketRaw); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRaw; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRaw>; override;
    procedure BusinessInsert(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PrdPacketRawDetail.Exception;

constructor TPrdPacketRawService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdPacketRaw, TPrdPacketRawRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TPrdPacketRawDetail, TPrdPacketRawDetailRepository>;
  Self.PermissionCode := PERMISSION_PRD_PACKET_RAW;
end;

{ Belge (TDocumentService) }

function TPrdPacketRawService.GetLines(AHeader: TPrdPacketRaw): TObjectList<TPrdPacketRawDetail>;
begin
  Result := AHeader.Lines;
end;

function TPrdPacketRawService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPrdPacketRawDetail>;
begin
  Result := TPrdPacketRawDetailRepository(FLineRepo).FindByPacketIds(AIds);
end;

function TPrdPacketRawService.GetLineHeaderId(ALine: TPrdPacketRawDetail): Int64;
begin
  Result := ALine.PrdPacketRawId;
end;

procedure TPrdPacketRawService.SetLineHeaderId(ALine: TPrdPacketRawDetail; AHeaderId: Int64);
begin
  ALine.PrdPacketRawId := AHeaderId;
end;

function TPrdPacketRawService.GetLineNo(ALine: TPrdPacketRawDetail): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPrdPacketRawService.SetLineNo(ALine: TPrdPacketRawDetail; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPrdPacketRawService.RaiseDuplicateLineNo;
begin
  raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TDetailForm.LineNoUnique, 'This line number is already used on the document.'));
end;

procedure TPrdPacketRawService.InitLine(AHeader: TPrdPacketRaw; ALine: TPrdPacketRawDetail);
begin
  ALine.PacketName := AHeader.PacketName;
end;

// Stok zorunlu, miktar > 0, alt reçete seçilebilir; paket içinde aynı stok bir kez
procedure TPrdPacketRawService.CheckLines(AHeader: TPrdPacketRaw; const ALines: TArray<TPrdPacketRawDetail>; AOldLines: TObjectList<TPrdPacketRawDetail>);
var
  LLine: TPrdPacketRawDetail;
  LKeys: TDictionary<Int64, Boolean>;
begin
  LKeys := TDictionary<Int64, Boolean>.Create;
  try
    for LLine in ALines do
    begin
      if LLine.StkInventoryId <= 0 then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColStkInventoryId, 'Raw Material') + ': ' +
          TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
      if LLine.Quantity <= 0 then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdPacketRawDetail.ColQuantity, 'Quantity') + ': ' +
          TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
      if LKeys.ContainsKey(LLine.StkInventoryId) then
        raise EPrdPacketRawDetailExceptionInventoryUnique.Create;
      LKeys.Add(LLine.StkInventoryId, True);
    end;
  finally
    LKeys.Free;
  end;
end;

procedure TPrdPacketRawService.PrepareCopyHeader(AHeader: TPrdPacketRaw);
begin
  // paket adı tekil: kopyada yeniden girilir
  AHeader.PacketName := '';
end;

procedure TPrdPacketRawService.RecalculateLine(ALine: TPrdPacketRawDetail);
begin
//
end;

procedure TPrdPacketRawService.RecalculateTotals(AHeader: TPrdPacketRaw);
begin
//
end;

destructor TPrdPacketRawService.Destroy;
begin
  inherited;
end;

procedure TPrdPacketRawService.ValidateRequiredReferences(AEntity: TPrdPacketRaw);
begin
  // zorunlu referans yok
end;

procedure TPrdPacketRawService.ValidateUnique(AEntity: TPrdPacketRaw; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdPacketRaw;
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
          raise EPrdPacketRawExceptionPacketNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

procedure TPrdPacketRawService.ValidateBusinessRules(AEntity: TPrdPacketRaw; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.PacketName := Trim(AEntity.PacketName);
    ValidateRequiredReferences(AEntity);
  end;

  ValidateUnique(AEntity, AOperation);
end;

procedure TPrdPacketRawService.DoAdd(AEntity: TPrdPacketRaw);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdPacketRawService.DoUpdate(AEntity: TPrdPacketRaw);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdPacketRawService.DoDelete(AId: Int64);
var
  LEntity: TPrdPacketRaw;
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

function TPrdPacketRawService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdPacketRaw>;
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

function TPrdPacketRawService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdPacketRaw;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    // belge: başlık + kalemler
    Result := FRepo.FindById(AId, ALock);
    if Assigned(Result) then
      LoadLines([Result]);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPrdPacketRawService.BusinessInsert(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketRawService.BusinessUpdate(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdPacketRawService.BusinessDelete(AEntity: TPrdPacketRaw; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdPacketRawService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

function TPrdPacketRawService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdPacketRaw>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPrdPacketRawService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdPacketRaw;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPrdPacketRawService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdPacketRaw;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdPacketRawService.Add(AEntity: TPrdPacketRaw);
begin
  DoAdd(AEntity);
end;

procedure TPrdPacketRawService.Update(AEntity: TPrdPacketRaw);
begin
  DoUpdate(AEntity);
end;

procedure TPrdPacketRawService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
