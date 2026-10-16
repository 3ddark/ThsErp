unit DetailChanges;

// Ana kayıt + detay ekranlarının (TfrmInputDetailedDB) bellekteki satır kümesi ve değişiklik takibi.
// Satırlar ekranda eklenir / değişir / silinir; ana servisin BusinessSaveWithDetails'i tek transaction'da
// ApplyTo ile yazar: önce silinenler, sonra yeni satırlar (insert) ve değişenler (update).

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults,
  Entity, FilterCriterion, Service;

type
  TDetailRowState = (drsUnchanged, drsNew, drsModified);

  TDetailChanges<TD: TEntity, constructor; TDS: TCrudService<TD>> = class(TNoRefCountObject, IDetailChanges)
  private
    FService: TDS;
    FItems: TObjectList<TD>;
    FStates: TDictionary<TD, TDetailRowState>;
    FDeletedIds: TList<Int64>;
    FInsertedNow: TList<TD>;
    FSetMasterId: TProc<TD, Int64>;
    FComparer: IComparer<TD>;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TD;
    function GetState(AIndex: Integer): TDetailRowState;
  public
    // AService sahiplenilir. ASetMasterId: satırın ana kayıt FK'sını yazar (yeni başlıkta id kayıtta belli olur).
    // ACompare: yüklenen satırların sırası (nil = okuma sırası)
    constructor Create(AService: TDS; const ASetMasterId: TProc<TD, Int64>; const ACompare: TComparison<TD> = nil);
    destructor Destroy; override;

    // Ana kaydın satırları (AMasterField = AMasterId) okunur; değişiklikler sıfırlanır
    procedure Load(const AMasterField: string; AMasterId: Int64);
    procedure Clear;
    // Kopya ile yeni kayıt: tüm satırlar yeni (id 0), silinenler boş
    procedure MarkAllNew;

    // Satır nesnesi kümeye geçer (sahiplenilir)
    function Add(AItem: TD): Integer;
    // Eski nesne serbest bırakılır; kayıtlı satır değişti, yeni satır yeni kalır
    procedure Replace(AIndex: Integer; AItem: TD);
    // Kayıtlı satır kayıtta silinir
    procedure Delete(AIndex: Integer);
    function IndexOf(AItem: TD): Integer;
    function HasChanges: Boolean;

    // IDetailChanges
    procedure ApplyTo(AMasterId: Int64; APermissionControl: Boolean);
    procedure RevertApply;
    procedure AcceptApply;

    property Service: TDS read FService;
    property Count: Integer read GetCount;
    property Items[AIndex: Integer]: TD read GetItem; default;
    property States[AIndex: Integer]: TDetailRowState read GetState;
    property DeletedIds: TList<Int64> read FDeletedIds;
  end;

implementation

uses
  System.Rtti;

constructor TDetailChanges<TD, TDS>.Create(AService: TDS; const ASetMasterId: TProc<TD, Int64>; const ACompare: TComparison<TD>);
begin
  inherited Create;
  FService := AService;
  FSetMasterId := ASetMasterId;
  FItems := TObjectList<TD>.Create(True);
  FStates := TDictionary<TD, TDetailRowState>.Create;
  FDeletedIds := TList<Int64>.Create;
  FInsertedNow := TList<TD>.Create;
  if Assigned(ACompare) then
    FComparer := TComparer<TD>.Construct(ACompare);
end;

destructor TDetailChanges<TD, TDS>.Destroy;
begin
  FInsertedNow.Free;
  FDeletedIds.Free;
  FStates.Free;
  FItems.Free;
  FService.Free;
  inherited;
end;

function TDetailChanges<TD, TDS>.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TDetailChanges<TD, TDS>.GetItem(AIndex: Integer): TD;
begin
  Result := FItems[AIndex];
end;

function TDetailChanges<TD, TDS>.GetState(AIndex: Integer): TDetailRowState;
begin
  if not FStates.TryGetValue(FItems[AIndex], Result) then
    Result := drsUnchanged;
end;

procedure TDetailChanges<TD, TDS>.Clear;
begin
  FStates.Clear;
  FItems.Clear;
  FDeletedIds.Clear;
  FInsertedNow.Clear;
end;

procedure TDetailChanges<TD, TDS>.Load(const AMasterField: string; AMasterId: Int64);
var
  LFilter: TFilterCriteria;
  LList: TList<TD>;
  LItem: TD;
begin
  Clear;
  if AMasterId <= 0 then
    Exit;

  LFilter := TFilterCriteria.Create;
  try
    LFilter.Add(TFilterCriterion.New(AMasterField, '=', TValue.From<Int64>(AMasterId)));
    LList := FService.BusinessFind(LFilter, False, False, True);
    try
      // repository TObjectList (sahiplenen) döner: nesneler FItems'a geçer
      if LList is TObjectList<TD> then
        TObjectList<TD>(LList).OwnsObjects := False;
      for LItem in LList do
        FItems.Add(LItem);
    finally
      LList.Free;
    end;
  finally
    LFilter.Free;
  end;

  if Assigned(FComparer) then
    FItems.Sort(FComparer);
end;

procedure TDetailChanges<TD, TDS>.MarkAllNew;
var
  LItem: TD;
begin
  FDeletedIds.Clear;
  FStates.Clear;
  for LItem in FItems do
  begin
    LItem.Id := 0;
    FStates.Add(LItem, drsNew);
  end;
end;

function TDetailChanges<TD, TDS>.Add(AItem: TD): Integer;
begin
  Result := FItems.Add(AItem);
  FStates.AddOrSetValue(AItem, drsNew);
end;

procedure TDetailChanges<TD, TDS>.Replace(AIndex: Integer; AItem: TD);
var
  LOld: TD;
  LState: TDetailRowState;
begin
  LOld := FItems[AIndex];
  if LOld = AItem then
    Exit;
  if (LOld.Id <= 0) or (FStates.TryGetValue(LOld, LState) and (LState = drsNew)) then
    LState := drsNew
  else
    LState := drsModified;
  FStates.Remove(LOld);
  AItem.Id := LOld.Id;
  FItems[AIndex] := AItem;   // OwnsObjects: eski nesne serbest bırakılır
  FStates.AddOrSetValue(AItem, LState);
end;

procedure TDetailChanges<TD, TDS>.Delete(AIndex: Integer);
var
  LItem: TD;
begin
  LItem := FItems[AIndex];
  if LItem.Id > 0 then
    FDeletedIds.Add(LItem.Id);
  FStates.Remove(LItem);
  FItems.Delete(AIndex);
end;

function TDetailChanges<TD, TDS>.IndexOf(AItem: TD): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

function TDetailChanges<TD, TDS>.HasChanges: Boolean;
var
  LState: TDetailRowState;
begin
  Result := FDeletedIds.Count > 0;
  if not Result then
    for LState in FStates.Values do
      if LState <> drsUnchanged then
        Exit(True);
end;

procedure TDetailChanges<TD, TDS>.ApplyTo(AMasterId: Int64; APermissionControl: Boolean);
var
  LId: Int64;
  LDeleted: TD;
  LItem: TD;
  LState: TDetailRowState;
begin
  FInsertedNow.Clear;

  // önce silinenler (satır no gibi tekil alanlar yeni satırlara boşalsın)
  for LId in FDeletedIds do
  begin
    LDeleted := TD.Create;
    try
      LDeleted.Id := LId;
      FService.BusinessDelete(LDeleted, False, False, APermissionControl);
    finally
      LDeleted.Free;
    end;
  end;

  for LItem in FItems do
  begin
    if not FStates.TryGetValue(LItem, LState) then
      LState := drsUnchanged;
    if Assigned(FSetMasterId) then
      FSetMasterId(LItem, AMasterId);
    if LItem.Id <= 0 then
    begin
      FService.BusinessInsert(LItem, False, False, APermissionControl);
      FInsertedNow.Add(LItem);
    end
    else if LState = drsModified then
      FService.BusinessUpdate(LItem, False, False, APermissionControl);
  end;
end;

procedure TDetailChanges<TD, TDS>.AcceptApply;
var
  LItem: TD;
begin
  FInsertedNow.Clear;
  FDeletedIds.Clear;
  FStates.Clear;
  for LItem in FItems do
    FStates.Add(LItem, drsUnchanged);
end;

procedure TDetailChanges<TD, TDS>.RevertApply;
var
  LItem: TD;
begin
  for LItem in FInsertedNow do
    if FItems.Contains(LItem) then
      LItem.Id := 0;
  FInsertedNow.Clear;
end;

end.
