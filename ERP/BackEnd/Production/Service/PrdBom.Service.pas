unit PrdBom.Service;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, System.Rtti, Entity, Repository, Service, FilterCriterion,
  UnitOfWork, SharedFormTypes, AppContext, LocalizationManager,
  DetailList, DocumentService, PrdBom.Repository, PrdBom, PrdBom.Exception,
  PrdBomRaw, PrdBomRaw.Repository, PrdBomLabour, PrdBomLabour.Repository, PrdBomByProduct, PrdBomByProduct.Repository,
  PrdBomPacketRaw, PrdBomPacketRaw.Repository, PrdBomPacketLabour, PrdBomPacketLabour.Repository;

type
  // Reçete belgesi = başlık + beş kalem listesi: hammaddeler (ana liste, TDocumentService), işçilik / giderler, yan
  // ürünler, hammadde paketleri, işçilik paketleri (ek listeler: LoadExtraLines ile okunur, CheckLines'ta denetlenir,
  // AfterDocumentSaved'de TDetailList.Save ile aynı transaction'da yazılır). Ek liste işlemleri genel metotlarla
  // (CreateItem / AddItem / RemoveItem); tüm kalem sınıflarında PrdBomId + LineNo vardır.
  TPrdBomService = class(TDocumentService<TPrdBom, TPrdBomRaw>)
  private
    FRepo: IRepository<TPrdBom>;
    FLabourRepo: IRepository<TPrdBomLabour>;
    FByProductRepo: IRepository<TPrdBomByProduct>;
    FPacketRawRepo: IRepository<TPrdBomPacketRaw>;
    FPacketLabourRepo: IRepository<TPrdBomPacketLabour>;
    // ek listelerde eklenen kalemler (hata olursa geçici id'ler geri)
    FExtraLog: TDetailSaveLog;

    procedure DoAdd(AEntity: TPrdBom);
    procedure DoUpdate(AEntity: TPrdBom);
    procedure DoDelete(AId: Int64);

    procedure ValidateRequiredReferences(AEntity: TPrdBom);
    procedure ValidateUnique(AEntity: TPrdBom; AOperation: TCrudOperation);
    procedure ValidateDefault(AEntity: TPrdBom; AOperation: TCrudOperation);

    procedure FailRequired(const AKey, ADefault: string);
    procedure FailQuantity(const AKey, ADefault: string);
    // Ek liste kalemlerinin ortak özellikleri (tüm reçete kalem sınıflarında aynı adla, RTTI)
    class function ItemLineNo(AItem: TObject): Integer; static;
    class procedure SetItemLineNo(AItem: TObject; ANo: Integer); static;
    class procedure SetItemBomId(AItem: TObject; AId: Int64); static;
    // Ek liste: boş satır no'lar doldurulur, tekillik denetlenir
    procedure AssignLineNos<TL: TDetailEntity>(AList: TObjectList<TL>);
    procedure SaveExtra<TL: TDetailEntity>(AHeader: TPrdBom; AList: TObjectList<TL>; ARepo: IRepository<TL>);
    procedure MarkExtraNew<TL: TDetailEntity>(AHeader: TPrdBom; AList: TObjectList<TL>);
  protected
    // ---- belge yapısı / kayıt adımları (TDocumentService)
    function GetLines(AHeader: TPrdBom): TObjectList<TPrdBomRaw>; override;
    function FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPrdBomRaw>; override;
    function GetLineHeaderId(ALine: TPrdBomRaw): Int64; override;
    procedure SetLineHeaderId(ALine: TPrdBomRaw; AHeaderId: Int64); override;
    function GetLineNo(ALine: TPrdBomRaw): Integer; override;
    procedure SetLineNo(ALine: TPrdBomRaw; ANo: Integer); override;
    procedure RaiseDuplicateLineNo; override;
    procedure InitLine(AHeader: TPrdBom; ALine: TPrdBomRaw); override;
    procedure CheckLines(AHeader: TPrdBom; const ALines: TArray<TPrdBomRaw>; AOldLines: TObjectList<TPrdBomRaw>); override;
    procedure AfterDocumentSaved(AHeader: TPrdBom; AOldLines: TObjectList<TPrdBomRaw>); override;
    procedure AfterSaveFailed(AHeader: TPrdBom); override;
    procedure PrepareCopyHeader(AHeader: TPrdBom); override;
    procedure LoadExtraLines(const AHeaders: TArray<TPrdBom>); override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure ValidateBusinessRules(AEntity: TPrdBom; AOperation: TCrudOperation); override;

    // Tutar yok (brüt miktar / işçilik tutarı view'da): hesap gerekmez
    procedure RecalculateLine(ALine: TPrdBomRaw); override;
    procedure RecalculateTotals(AHeader: TPrdBom); override;

    // ---- ek listeler (bellekte): yeni kalem (listeye eklenmez; sıradaki satır no, başlık), ekleme, çıkarma
    function CreateItem<TL: TDetailEntity, constructor>(AHeader: TPrdBom; AList: TObjectList<TL>): TL;
    procedure AddItem<TL: TDetailEntity>(AHeader: TPrdBom; AList: TObjectList<TL>; AItem: TL);
    procedure RemoveItem<TL: TDetailEntity>(AList: TObjectList<TL>; AItem: TL);

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; override;

    function Find(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TList<TPrdBom>; override;
    function FindById(AId: Int64; ALock: Boolean; AIncludeNestedEntities: Boolean = False): TPrdBom; override;
    function FindOne(AFilter: TFilterCriteria; ALock: Boolean = False; AIncludeNestedEntities: Boolean = False): TPrdBom; override;

    procedure Add(AEntity: TPrdBom); override;
    procedure Update(AEntity: TPrdBom); override;
    procedure Delete(AId: Int64); override;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBom; override;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBom>; override;
    procedure BusinessInsert(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
  end;

implementation

uses
  SysPermission.Service, PrdBomRaw.Exception, PrdBomLabour.Exception,
  PrdBomByProduct.Exception, PrdBomPacketRaw.Exception, PrdBomPacketLabour.Exception;

class function TPrdBomService.ItemLineNo(AItem: TObject): Integer;
var
  LCtx: TRttiContext;
begin
  Result := LCtx.GetType(AItem.ClassType).GetProperty('LineNo').GetValue(AItem).AsInteger;
end;

class procedure TPrdBomService.SetItemLineNo(AItem: TObject; ANo: Integer);
var
  LCtx: TRttiContext;
begin
  LCtx.GetType(AItem.ClassType).GetProperty('LineNo').SetValue(AItem, TValue.From<SmallInt>(ANo));
end;

class procedure TPrdBomService.SetItemBomId(AItem: TObject; AId: Int64);
var
  LCtx: TRttiContext;
begin
  LCtx.GetType(AItem.ClassType).GetProperty('PrdBomId').SetValue(AItem, TValue.From<Int64>(AId));
end;

constructor TPrdBomService.Create;
begin
  inherited;
  FRepo := Self.UoW.GetRepository<TPrdBom, TPrdBomRepository>;
  FHeaderRepo := FRepo;
  FLineRepo := Self.UoW.GetRepository<TPrdBomRaw, TPrdBomRawRepository>;
  FLabourRepo := Self.UoW.GetRepository<TPrdBomLabour, TPrdBomLabourRepository>;
  FByProductRepo := Self.UoW.GetRepository<TPrdBomByProduct, TPrdBomByProductRepository>;
  FPacketRawRepo := Self.UoW.GetRepository<TPrdBomPacketRaw, TPrdBomPacketRawRepository>;
  FPacketLabourRepo := Self.UoW.GetRepository<TPrdBomPacketLabour, TPrdBomPacketLabourRepository>;
  Self.PermissionCode := PERMISSION_PRD_BOM;
end;

destructor TPrdBomService.Destroy;
begin
  FExtraLog.Free;
  inherited;
end;

procedure TPrdBomService.FailRequired(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
end;

procedure TPrdBomService.FailQuantity(const AKey, ADefault: string);
begin
  raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
    TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
end;

{ Belge (TDocumentService) }

function TPrdBomService.GetLines(AHeader: TPrdBom): TObjectList<TPrdBomRaw>;
begin
  Result := AHeader.Raws;
end;

function TPrdBomService.FindLinesByHeaderIds(const AIds: TArray<Int64>): TObjectList<TPrdBomRaw>;
begin
  Result := TPrdBomRawRepository(FLineRepo).FindByBomIds(AIds);
end;

function TPrdBomService.GetLineHeaderId(ALine: TPrdBomRaw): Int64;
begin
  Result := ALine.PrdBomId;
end;

procedure TPrdBomService.SetLineHeaderId(ALine: TPrdBomRaw; AHeaderId: Int64);
begin
  ALine.PrdBomId := AHeaderId;
end;

function TPrdBomService.GetLineNo(ALine: TPrdBomRaw): Integer;
begin
  Result := ALine.LineNo;
end;

procedure TPrdBomService.SetLineNo(ALine: TPrdBomRaw; ANo: Integer);
begin
  ALine.LineNo := ANo;
end;

procedure TPrdBomService.RaiseDuplicateLineNo;
begin
  raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TDetailForm.LineNoUnique, 'This line number is already used on the document.'));
end;

procedure TPrdBomService.InitLine(AHeader: TPrdBom; ALine: TPrdBomRaw);
begin
  ALine.BomName := AHeader.BomName;
end;

function TPrdBomService.CreateItem<TL>(AHeader: TPrdBom; AList: TObjectList<TL>): TL;
var
  LItem: TL;
  LMax: Integer;
begin
  LMax := 0;
  for LItem in AList do
    if not LItem.Deleted and (ItemLineNo(LItem) > LMax) then
      LMax := ItemLineNo(LItem);
  Result := TL.Create;
  SetItemLineNo(Result, LMax + 1);
  SetItemBomId(Result, AHeader.Id);
  Result.HeaderEntity := AHeader;
end;

procedure TPrdBomService.AddItem<TL>(AHeader: TPrdBom; AList: TObjectList<TL>; AItem: TL);
begin
  TDetailList.Attach<TL>(AList, AItem, AHeader);
end;

procedure TPrdBomService.RemoveItem<TL>(AList: TObjectList<TL>; AItem: TL);
begin
  TDetailList.Remove<TL>(AList, AItem);
end;

procedure TPrdBomService.AssignLineNos<TL>(AList: TObjectList<TL>);
var
  LItem: TL;
  LMax: Integer;
  LNos: TDictionary<Integer, Boolean>;
begin
  LMax := 0;
  for LItem in AList do
    if not LItem.Deleted and (ItemLineNo(LItem) > LMax) then
      LMax := ItemLineNo(LItem);
  LNos := TDictionary<Integer, Boolean>.Create;
  try
    for LItem in AList do
    begin
      if LItem.Deleted then
        Continue;
      if ItemLineNo(LItem) <= 0 then
      begin
        Inc(LMax);
        SetItemLineNo(LItem, LMax);
      end;
      if LNos.ContainsKey(ItemLineNo(LItem)) then
        RaiseDuplicateLineNo;
      LNos.Add(ItemLineNo(LItem), True);
    end;
  finally
    LNos.Free;
  end;
end;

procedure TPrdBomService.SaveExtra<TL>(AHeader: TPrdBom; AList: TObjectList<TL>; ARepo: IRepository<TL>);
var
  LHeader: TPrdBom;
begin
  LHeader := AHeader;
  TDetailList.Save<TL>(AList, ARepo,
    procedure(AItem: TL)
    begin
      SetItemBomId(AItem, LHeader.Id);
    end,
    FExtraLog);
end;

procedure TPrdBomService.MarkExtraNew<TL>(AHeader: TPrdBom; AList: TObjectList<TL>);
var
  LItem: TL;
begin
  TDetailList.MarkAllNew<TL>(AList);
  for LItem in AList do
  begin
    LItem.HeaderEntity := AHeader;
    SetItemBomId(LItem, 0);
  end;
end;

procedure TPrdBomService.LoadExtraLines(const AHeaders: TArray<TPrdBom>);
var
  LIds: TArray<Int64>;
  LById: TDictionary<Int64, TPrdBom>;
  LHeader: TPrdBom;
  LLabours: TObjectList<TPrdBomLabour>;
  LByProducts: TObjectList<TPrdBomByProduct>;
  LPacketRaws: TObjectList<TPrdBomPacketRaw>;
  LPacketLabours: TObjectList<TPrdBomPacketLabour>;
  LLabour: TPrdBomLabour;
  LByProduct: TPrdBomByProduct;
  LPacketRaw: TPrdBomPacketRaw;
  LPacketLabour: TPrdBomPacketLabour;
begin
  LById := TDictionary<Int64, TPrdBom>.Create;
  try
    LIds := [];
    for LHeader in AHeaders do
    begin
      LHeader.Labours.Clear;
      LHeader.ByProducts.Clear;
      LHeader.PacketRaws.Clear;
      LHeader.PacketLabours.Clear;
      if (LHeader.Id > 0) and not LById.ContainsKey(LHeader.Id) then
      begin
        LById.Add(LHeader.Id, LHeader);
        LIds := LIds + [LHeader.Id];
      end;
    end;
    if Length(LIds) = 0 then
      Exit;

    // nesneler başlıkların listelerine geçer
    LLabours := TPrdBomLabourRepository(FLabourRepo).FindByBomIds(LIds);
    try
      LLabours.OwnsObjects := False;
      for LLabour in LLabours do
        if LById.TryGetValue(LLabour.PrdBomId, LHeader) then
        begin
          LLabour.HeaderEntity := LHeader;
          LHeader.Labours.Add(LLabour);
        end
        else
          LLabour.Free;
    finally
      LLabours.Free;
    end;
    LByProducts := TPrdBomByProductRepository(FByProductRepo).FindByBomIds(LIds);
    try
      LByProducts.OwnsObjects := False;
      for LByProduct in LByProducts do
        if LById.TryGetValue(LByProduct.PrdBomId, LHeader) then
        begin
          LByProduct.HeaderEntity := LHeader;
          LHeader.ByProducts.Add(LByProduct);
        end
        else
          LByProduct.Free;
    finally
      LByProducts.Free;
    end;
    LPacketRaws := TPrdBomPacketRawRepository(FPacketRawRepo).FindByBomIds(LIds);
    try
      LPacketRaws.OwnsObjects := False;
      for LPacketRaw in LPacketRaws do
        if LById.TryGetValue(LPacketRaw.PrdBomId, LHeader) then
        begin
          LPacketRaw.HeaderEntity := LHeader;
          LHeader.PacketRaws.Add(LPacketRaw);
        end
        else
          LPacketRaw.Free;
    finally
      LPacketRaws.Free;
    end;
    LPacketLabours := TPrdBomPacketLabourRepository(FPacketLabourRepo).FindByBomIds(LIds);
    try
      LPacketLabours.OwnsObjects := False;
      for LPacketLabour in LPacketLabours do
        if LById.TryGetValue(LPacketLabour.PrdBomId, LHeader) then
        begin
          LPacketLabour.HeaderEntity := LHeader;
          LHeader.PacketLabours.Add(LPacketLabour);
        end
        else
          LPacketLabour.Free;
    finally
      LPacketLabours.Free;
    end;
  finally
    LById.Free;
  end;
end;

// Tüm listelerin kuralları (bellekte): zorunlu alanlar, miktar > 0, fire 0-99.99, alt reçete kendisi olamaz, ürün kendi
// hammaddesi olamaz, listede aynı stok / işçilik / paket bir kez; ek listelerin satır no'ları
procedure TPrdBomService.CheckLines(AHeader: TPrdBom; const ALines: TArray<TPrdBomRaw>; AOldLines: TObjectList<TPrdBomRaw>);
var
  LKeys: TDictionary<Int64, Boolean>;
  LRaw: TPrdBomRaw;
  LLabour: TPrdBomLabour;
  LByProduct: TPrdBomByProduct;
  LPacketRaw: TPrdBomPacketRaw;
  LPacketLabour: TPrdBomPacketLabour;
begin
  FreeAndNil(FExtraLog);
  FExtraLog := TDetailSaveLog.Create;
  LKeys := TDictionary<Int64, Boolean>.Create;
  try
    for LRaw in ALines do
    begin
      if LRaw.StkInventoryId <= 0 then
        FailRequired(TLangKeys.TPrdBomRaw.ColStkInventoryId, 'Raw Material');
      if LRaw.Quantity <= 0 then
        FailQuantity(TLangKeys.TPrdBomRaw.ColQuantity, 'Quantity');
      if (LRaw.ScrapRate < 0) or (LRaw.ScrapRate >= 100) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColScrapRate, 'Scrap Rate (%)') + ': ' +
          Format(TLocalizationManager.Translate(TLangKeys.TValidation.Range, 'Field must be between %s and %s'), ['0', '99.99']));
      if (LRaw.SubPrdBomId > 0) and (LRaw.SubPrdBomId = AHeader.Id) then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.SubBomSelf, 'A BoM cannot use itself as sub BoM.'));
      if LRaw.StkInventoryId = AHeader.StkInventoryId then
        raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.RawIsProduct, 'The product of the BoM cannot be its own raw material.'));
      if LKeys.ContainsKey(LRaw.StkInventoryId) then
        raise EPrdBomRawExceptionInventoryUnique.Create;
      LKeys.Add(LRaw.StkInventoryId, True);
    end;

    LKeys.Clear;
    for LLabour in TDetailList.Active<TPrdBomLabour>(AHeader.Labours) do
    begin
      if LLabour.PrdLabourId <= 0 then
        FailRequired(TLangKeys.TPrdBomLabour.ColPrdLabourId, 'Labour / Cost');
      if LLabour.Quantity <= 0 then
        FailQuantity(TLangKeys.TPrdBomLabour.ColQuantity, 'Quantity');
      if LKeys.ContainsKey(LLabour.PrdLabourId) then
        raise EPrdBomLabourExceptionLabourUnique.Create;
      LKeys.Add(LLabour.PrdLabourId, True);
    end;

    LKeys.Clear;
    for LByProduct in TDetailList.Active<TPrdBomByProduct>(AHeader.ByProducts) do
    begin
      if LByProduct.StkInventoryId <= 0 then
        FailRequired(TLangKeys.TPrdBomByProduct.ColStkInventoryId, 'By-product');
      if LByProduct.Quantity <= 0 then
        FailQuantity(TLangKeys.TPrdBomByProduct.ColQuantity, 'Quantity');
      if LKeys.ContainsKey(LByProduct.StkInventoryId) then
        raise EPrdBomByProductExceptionInventoryUnique.Create;
      LKeys.Add(LByProduct.StkInventoryId, True);
    end;

    LKeys.Clear;
    for LPacketRaw in TDetailList.Active<TPrdBomPacketRaw>(AHeader.PacketRaws) do
    begin
      if LPacketRaw.PrdPacketRawId <= 0 then
        FailRequired(TLangKeys.TPrdBomPacketRaw.ColPrdPacketRawId, 'Raw Material Packet');
      if LPacketRaw.Quantity <= 0 then
        FailQuantity(TLangKeys.TPrdBomPacketRaw.ColQuantity, 'Quantity');
      if LKeys.ContainsKey(LPacketRaw.PrdPacketRawId) then
        raise EPrdBomPacketRawExceptionPacketUnique.Create;
      LKeys.Add(LPacketRaw.PrdPacketRawId, True);
    end;

    LKeys.Clear;
    for LPacketLabour in TDetailList.Active<TPrdBomPacketLabour>(AHeader.PacketLabours) do
    begin
      if LPacketLabour.PrdPacketLabourId <= 0 then
        FailRequired(TLangKeys.TPrdBomPacketLabour.ColPrdPacketLabourId, 'Labour Packet');
      if LPacketLabour.Quantity <= 0 then
        FailQuantity(TLangKeys.TPrdBomPacketLabour.ColQuantity, 'Quantity');
      if LKeys.ContainsKey(LPacketLabour.PrdPacketLabourId) then
        raise EPrdBomPacketLabourExceptionPacketUnique.Create;
      LKeys.Add(LPacketLabour.PrdPacketLabourId, True);
    end;
  finally
    LKeys.Free;
  end;

  AssignLineNos<TPrdBomLabour>(AHeader.Labours);
  AssignLineNos<TPrdBomByProduct>(AHeader.ByProducts);
  AssignLineNos<TPrdBomPacketRaw>(AHeader.PacketRaws);
  AssignLineNos<TPrdBomPacketLabour>(AHeader.PacketLabours);
end;

// Ek listeler başlık ve hammaddelerle aynı transaction'da yazılır (sil / güncelle / ekle)
procedure TPrdBomService.AfterDocumentSaved(AHeader: TPrdBom; AOldLines: TObjectList<TPrdBomRaw>);
begin
  SaveExtra<TPrdBomLabour>(AHeader, AHeader.Labours, FLabourRepo);
  SaveExtra<TPrdBomByProduct>(AHeader, AHeader.ByProducts, FByProductRepo);
  SaveExtra<TPrdBomPacketRaw>(AHeader, AHeader.PacketRaws, FPacketRawRepo);
  SaveExtra<TPrdBomPacketLabour>(AHeader, AHeader.PacketLabours, FPacketLabourRepo);
end;

procedure TPrdBomService.AfterSaveFailed(AHeader: TPrdBom);
begin
  if Assigned(FExtraLog) then
    FExtraLog.Revert;
end;

// Kopya: yeni ad girilir (ürün + ad tekil), varsayılan değil; ek listelerin kalemleri de yeni
procedure TPrdBomService.PrepareCopyHeader(AHeader: TPrdBom);
begin
  AHeader.BomName := '';
  AHeader.IsDefault := False;
  MarkExtraNew<TPrdBomLabour>(AHeader, AHeader.Labours);
  MarkExtraNew<TPrdBomByProduct>(AHeader, AHeader.ByProducts);
  MarkExtraNew<TPrdBomPacketRaw>(AHeader, AHeader.PacketRaws);
  MarkExtraNew<TPrdBomPacketLabour>(AHeader, AHeader.PacketLabours);
end;

procedure TPrdBomService.RecalculateLine(ALine: TPrdBomRaw);
begin
//
end;

procedure TPrdBomService.RecalculateTotals(AHeader: TPrdBom);
begin
//
end;

procedure TPrdBomService.ValidateRequiredReferences(AEntity: TPrdBom);

  procedure CheckId(AValue: Int64; const AKey, ADefault: string);
  begin
    if AValue <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(AKey, ADefault) + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.Required, 'This field is required.'));
  end;

begin
  CheckId(AEntity.StkInventoryId, TLangKeys.TPrdBom.ColStkInventoryId, 'Product');
end;

procedure TPrdBomService.ValidateUnique(AEntity: TPrdBom; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBom;
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    LFilter := TFilterCriteria.Create;
    try
      LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
      LFilter.Add(TFilterCriterion.New('bom_name', '=', TValue.From<string>(AEntity.BomName)));
      if AOperation = coUpdate then
        LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

      LModel := FRepo.FindOne(LFilter, False);
      try
        if Assigned(LModel) then
          raise EPrdBomExceptionBomNameUnique.Create;
      finally
        LModel.Free;
      end;
    finally
      LFilter.Free;
    end;
  end;
end;

// Ürün başına tek varsayılan reçete (DB: prd_bom_default_uidx)
procedure TPrdBomService.ValidateDefault(AEntity: TPrdBom; AOperation: TCrudOperation);
var
  LFilter: TFilterCriteria;
  LModel: TPrdBom;
begin
  if not (AOperation in [coInsert, coUpdate]) or not AEntity.IsDefault then
    Exit;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New('stk_inventory_id', '=', TValue.From<Int64>(AEntity.StkInventoryId)));
    LFilter.Add(TFilterCriterion.New('is_default', '=', TValue.From<Boolean>(True)));
    if AOperation = coUpdate then
      LFilter.Add(TFilterCriterion.New('id', '<>', TValue.From<Int64>(AEntity.Id)));

    LModel := FRepo.FindOne(LFilter, False);
    try
      if Assigned(LModel) then
        raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TPrdBom.DefaultExists, 'This product already has a default BoM: %s'), [LModel.BomName]));
    finally
      LModel.Free;
    end;
  finally
    LFilter.Free;
  end;
end;

procedure TPrdBomService.ValidateBusinessRules(AEntity: TPrdBom; AOperation: TCrudOperation);
begin
  if AOperation in [coInsert, coUpdate] then
  begin
    AEntity.BomName := Trim(AEntity.BomName);
    AEntity.Description := Trim(AEntity.Description);
    ValidateRequiredReferences(AEntity);
    if AEntity.BaseQuantity <= 0 then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBaseQuantity, 'Base Quantity') + ': ' +
        TLocalizationManager.Translate(TLangKeys.TValidation.MustBePositive, 'Value must be greater than zero'));
  end;

  ValidateUnique(AEntity, AOperation);
  ValidateDefault(AEntity, AOperation);
end;

procedure TPrdBomService.DoAdd(AEntity: TPrdBom);
begin
  ValidateAll(AEntity, coInsert);
  FRepo.Add(AEntity);
end;

procedure TPrdBomService.DoUpdate(AEntity: TPrdBom);
begin
  ValidateAll(AEntity, coUpdate);
  FRepo.Update(AEntity);
end;

procedure TPrdBomService.DoDelete(AId: Int64);
var
  LEntity: TPrdBom;
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

function TPrdBomService.BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<TPrdBom>;
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

function TPrdBomService.BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): TPrdBom;
begin
  Self.UoW.EnsureAuthorized(Self.PermissionCode, ptRead, APermissionControl);

  if AWithBegin and not Self.UoW.InTransaction then
    Self.UoW.BeginTransaction;

  try
    // belge: başlık + tüm kalem listeleri
    Result := FRepo.FindById(AId, ALock);
    if Assigned(Result) then
      LoadLines([Result]);
  except
    if Self.UoW.InTransaction then
      Self.UoW.Rollback;
    raise;
  end;
end;

procedure TPrdBomService.BusinessInsert(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomService.BusinessUpdate(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TPrdBomService.BusinessDelete(AEntity: TPrdBom; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

function TPrdBomService.CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := FRepo.FindAllGridQuery(AFilter);
end;

// AIncludeNestedEntities: kalem listeleri de
function TPrdBomService.Find(AFilter: TFilterCriteria; ALock, AIncludeNestedEntities: Boolean): TList<TPrdBom>;
begin
  Result := FRepo.Find(AFilter, ALock);
  if AIncludeNestedEntities and (Result.Count > 0) then
    LoadLines(Result.ToArray);
end;

function TPrdBomService.FindById(AId: Int64; ALock, AIncludeNestedEntities: Boolean): TPrdBom;
begin
  Result := FRepo.FindById(AId, ALock);
  if AIncludeNestedEntities and Assigned(Result) then
    LoadLines([Result]);
end;

function TPrdBomService.FindOne(AFilter: TFilterCriteria; ALock: Boolean; AIncludeNestedEntities: Boolean): TPrdBom;
begin
  Result := FRepo.FindOne(AFilter, ALock);
end;

procedure TPrdBomService.Add(AEntity: TPrdBom);
begin
  DoAdd(AEntity);
end;

procedure TPrdBomService.Update(AEntity: TPrdBom);
begin
  DoUpdate(AEntity);
end;

procedure TPrdBomService.Delete(AId: Int64);
begin
  DoDelete(AId);
end;

end.
