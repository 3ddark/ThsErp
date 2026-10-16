unit DetailList;

// Belge kalemleri (başlığın TObjectList<TDetailEntity> listesi) için servis katmanı yardımcıları. İş kuralı içermez:
// doğrulama, hesap ve yan işler belge servisinde (ör. TSlsOfferService). Durum tek listede (bkz. Entity.TDetailEntity):
//   Id > 0            -> update (batch)
//   Id > 0 + Deleted  -> delete (batch)
//   Id < 0            -> insert (tek tek, RETURNING id: gerçek id kalem hook'u ve sonraki kayıt için gerekir)
//   Id < 0 + Deleted  -> DB'ye gitmez (Remove zaten listeden çıkarır)
// Hata olursa TDetailSaveLog.Revert eklenen kalemlerin geçici id'lerini geri yazar (Deleted işaretleri korunur).

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo, System.Generics.Collections,
  Entity, Repository;

type
  // Bir kayıtta DB'ye eklenen kalemler + geçici id'leri (rollback sonrası tekrar denemede yine insert)
  TDetailSaveLog = class
  private
    FItems: TList<TEntity>;
    FTempIds: TList<Int64>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddInserted(AItem: TEntity; ATempId: Int64);
    procedure Revert;
  end;

  TDetailList = class
  public
    // Silinmemiş kalemler (liste sırasıyla)
    class function Active<TD: TDetailEntity>(AList: TObjectList<TD>): TArray<TD>; static;
    class function ActiveCount<TD: TDetailEntity>(AList: TObjectList<TD>): Integer; static;
    // Sıradaki geçici id: -1, -2 … (listedeki en küçük id'nin bir altı, en fazla -1)
    class function NextTempId<TD: TDetailEntity>(AList: TObjectList<TD>): Int64; static;
    // Kalem listeye girer (sahiplenilir): Id >= 0 ise geçici id, başlık referansı, Deleted = False
    class procedure Attach<TD: TDetailEntity>(AList: TObjectList<TD>; AItem: TD; AHeader: TEntity); static;
    // Yeni kalem (Id < 0) listeden silinir ve serbest kalır; kayıtlı kalem Deleted işaretlenir
    class procedure Remove<TD: TDetailEntity>(AList: TObjectList<TD>; AItem: TD); static;
    // Kopya ile yeni belge: silinmişler atılır, kalanlar geçici id alır
    class procedure MarkAllNew<TD: TDetailEntity>(AList: TObjectList<TD>); static;
    // Açık transaction içinde yazar. ASetMasterId yazılacak her kaleme başlık FK'sını verir (yeni başlıkta id kayıtta
    // belli olur). Sıra: silinenler, kayıtlılar, yeniler. AAfterLine (kalem hook'u): eklenen / güncellenen her kalem
    // için, tümü yazıldıktan sonra (gerçek id ile). Silinen kalemin bağlı kayıtları FK cascade ile gider.
    class procedure Save<TD: TDetailEntity>(AList: TObjectList<TD>; ARepo: IRepository<TD>;
      const ASetMasterId: TProc<TD>; ALog: TDetailSaveLog; const AAfterLine: TProc<TD> = nil); static;
    // Kayıt başarılı ve belge yeniden okunmuyorsa: silinmiş kalemler listeden atılır
    class procedure AcceptSaved<TD: TDetailEntity>(AList: TObjectList<TD>); static;
  end;

// Okunabilir + yazılabilir basit tipli tüm özellikleri kopyalar (Id ve Deleted dahil; nesne özellikleri hariç)
procedure CopyEntityValues(ASource, ATarget: TObject);

implementation

procedure CopyEntityValues(ASource, ATarget: TObject);
var
  LCtx: TRttiContext;
  LProp: TRttiProperty;
begin
  LCtx := TRttiContext.Create;
  try
    for LProp in LCtx.GetType(ASource.ClassType).GetProperties do
      if LProp.IsReadable and LProp.IsWritable and
        (LProp.PropertyType.TypeKind in [tkInteger, tkInt64, tkFloat, tkEnumeration, tkUString, tkString, tkLString, tkWString, tkChar, tkWChar]) then
        LProp.SetValue(ATarget, LProp.GetValue(ASource));
  finally
    LCtx.Free;
  end;
end;

{ TDetailSaveLog }

constructor TDetailSaveLog.Create;
begin
  inherited Create;
  FItems := TList<TEntity>.Create;
  FTempIds := TList<Int64>.Create;
end;

destructor TDetailSaveLog.Destroy;
begin
  FTempIds.Free;
  FItems.Free;
  inherited;
end;

procedure TDetailSaveLog.AddInserted(AItem: TEntity; ATempId: Int64);
begin
  FItems.Add(AItem);
  FTempIds.Add(ATempId);
end;

procedure TDetailSaveLog.Revert;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems[i].Id := FTempIds[i];
  FItems.Clear;
  FTempIds.Clear;
end;

{ TDetailList }

class function TDetailList.Active<TD>(AList: TObjectList<TD>): TArray<TD>;
var
  LItem: TD;
  n: Integer;
begin
  SetLength(Result, AList.Count);
  n := 0;
  for LItem in AList do
    if not LItem.Deleted then
    begin
      Result[n] := LItem;
      Inc(n);
    end;
  SetLength(Result, n);
end;

class function TDetailList.ActiveCount<TD>(AList: TObjectList<TD>): Integer;
var
  LItem: TD;
begin
  Result := 0;
  for LItem in AList do
    if not LItem.Deleted then
      Inc(Result);
end;

class function TDetailList.NextTempId<TD>(AList: TObjectList<TD>): Int64;
var
  LItem: TD;
begin
  Result := -1;
  for LItem in AList do
    if LItem.Id <= Result then
      Result := LItem.Id - 1;
end;

class procedure TDetailList.Attach<TD>(AList: TObjectList<TD>; AItem: TD; AHeader: TEntity);
begin
  if AItem.Id >= 0 then
    AItem.Id := NextTempId<TD>(AList);
  AItem.Deleted := False;
  AItem.HeaderEntity := AHeader;
  if not AList.Contains(AItem) then
    AList.Add(AItem);
end;

class procedure TDetailList.Remove<TD>(AList: TObjectList<TD>; AItem: TD);
begin
  if AItem.Id < 0 then
    AList.Remove(AItem)   // OwnsObjects: serbest kalır
  else
    AItem.Deleted := True;
end;

class procedure TDetailList.MarkAllNew<TD>(AList: TObjectList<TD>);
var
  i: Integer;
begin
  for i := AList.Count - 1 downto 0 do
    if AList[i].Deleted then
      AList.Delete(i);
  for i := 0 to AList.Count - 1 do
    AList[i].Id := -(i + 1);
end;

class procedure TDetailList.Save<TD>(AList: TObjectList<TD>; ARepo: IRepository<TD>;
  const ASetMasterId: TProc<TD>; ALog: TDetailSaveLog; const AAfterLine: TProc<TD>);
var
  LItem: TD;
  LDeleted: TList<TValue>;
  LUpdated, LInserted: TList<TD>;
  LTempId: Int64;
begin
  LDeleted := TList<TValue>.Create;
  LUpdated := TList<TD>.Create;
  LInserted := TList<TD>.Create;
  try
    for LItem in AList do
      if LItem.Deleted then
      begin
        if LItem.Id > 0 then
          LDeleted.Add(TValue.From<Int64>(LItem.Id));
      end
      else
      begin
        if Assigned(ASetMasterId) then
          ASetMasterId(LItem);
        if LItem.Id > 0 then
          LUpdated.Add(LItem)
        else
          LInserted.Add(LItem);
      end;

    // önce silinenler (satır no gibi tekil değerler boşalsın)
    if LDeleted.Count > 0 then
      ARepo.DeleteBatch(LDeleted.ToArray);
    if LUpdated.Count > 0 then
      ARepo.UpdateBatch(LUpdated.ToArray);
    for LItem in LInserted do
    begin
      LTempId := LItem.Id;
      ARepo.Add(LItem);   // INSERT … RETURNING id
      ALog.AddInserted(LItem, LTempId);
    end;

    if Assigned(AAfterLine) then
    begin
      for LItem in LUpdated do
        AAfterLine(LItem);
      for LItem in LInserted do
        AAfterLine(LItem);
    end;
  finally
    LInserted.Free;
    LUpdated.Free;
    LDeleted.Free;
  end;
end;

class procedure TDetailList.AcceptSaved<TD>(AList: TObjectList<TD>);
var
  i: Integer;
begin
  for i := AList.Count - 1 downto 0 do
    if AList[i].Deleted then
      AList.Delete(i);
end;

end.
