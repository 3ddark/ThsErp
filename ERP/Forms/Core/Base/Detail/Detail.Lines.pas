unit Detail.Lines;

// Belgenin bir kalem listesinin ekranı: belge nesnesindeki liste (ör. TSlsOffer.Lines, TDetailEntity) + grid
// (TDetailGrid) + satır formu. Kalem ekleme / çıkarma ve hesaplar belge servisinde (ACreateLine / AAddLine /
// ARemoveLine geri çağrıları); bu birim yalnız ekran: satır formunu modal açar, grid'i listeden doldurur
// (silinmişler gösterilmez), boyama için ekranda değiştirilen kalemleri tutar. DB'ye yazma belge servisinin
// BusinessSaveWithDetails'inde olur.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs,
  Entity, SharedFormTypes, Detail.Grid;

type
  TLineFormResult = (lfrNone, lfrAccept, lfrDelete);

  // Satır formu sözleşmesi (TfrmInputLineDB uygular)
  ILineForm = interface
    ['{4B8E0C51-2F6A-4D3B-8A7E-9C1D5F2E6B30}']
    function LineResult: TLineFormResult;
    // Formun düzenlediği satır nesnesi forma ait olmaktan çıkar (çağıran sahiplenir)
    function ExtractLine: TObject;
  end;

  // Tipten bağımsız kalem ekranı (ana form bu arayüzle çalışır)
  IDetailSet = interface
    ['{A13F7D2C-6B95-4E08-B4C1-0E7A9D3F5C26}']
    function GetGrid: TDetailGrid;
    // Belge yüklendi / değişti (Table yeni nesne olabilir): ekrandaki değişiklik işaretleri temizlenir, grid dolar
    procedure Reset;
    procedure SetEditable(AValue: Boolean);
    procedure AddLine;
    procedure OpenLine(ARow: Integer);
    procedure DeleteLine(ARow: Integer);
    property Grid: TDetailGrid read GetGrid;
  end;

  TDetailLineFormFactory<TD> = reference to function(ALine: TD; AMode: TInputFormMode): TForm;

  TDetailSet<TD: TDetailEntity, constructor> = class(TNoRefCountObject, IDetailSet)
  private
    FGrid: TDetailGrid;
    FGetList: TFunc<TObjectList<TD>>;
    FCreateLine: TFunc<TD>;
    FAddLine: TProc<TD>;
    FRemoveLine: TProc<TD>;
    FLineForm: TDetailLineFormFactory<TD>;
    FEditable: Boolean;
    FVisible: TList<TD>;      // grid satırı -> kalem (silinmemişler, liste sırasıyla)
    FModified: TList<TD>;     // bu ekranda değiştirilen kayıtlı kalemler (yalnız boyama)
    FOnChanged: TNotifyEvent;
    function List: TObjectList<TD>;
    procedure Refill(AFocusRow: Integer);
    procedure Changed;
    function ShowLine(ALine: TD; AMode: TInputFormMode; out AResult: TLineFormResult): TD;
    procedure GridAdd(AGrid: TDetailGrid; ARow: Integer);
    procedure GridEdit(AGrid: TDetailGrid; ARow: Integer);
    procedure GridDelete(AGrid: TDetailGrid; ARow: Integer);
  public
    // AGrid ana formun bileşenidir (form serbest bırakır). AGetList: belgenin güncel listesi (Table değişebilir);
    // ACreateLine: yeni kalem (listeye eklenmemiş, ön değerli); AAddLine / ARemoveLine: belge servisinin kalem işlemleri;
    // ALineForm: satır formu (modal, satırı sahiplenir)
    constructor Create(AGrid: TDetailGrid; const AGetList: TFunc<TObjectList<TD>>; const ACreateLine: TFunc<TD>;
      const AAddLine, ARemoveLine: TProc<TD>; const ALineForm: TDetailLineFormFactory<TD>);
    destructor Destroy; override;

    // IDetailSet
    function GetGrid: TDetailGrid;
    procedure Reset;
    procedure SetEditable(AValue: Boolean);
    procedure AddLine;
    procedure OpenLine(ARow: Integer);
    procedure DeleteLine(ARow: Integer);

    // Grid satırındaki kalem (yoksa nil)
    function Item(ARow: Integer): TD;
    property Grid: TDetailGrid read FGrid;
    property Editable: Boolean read FEditable;
    // Kalem eklendi / değişti / silindi (ana formda toplamlar)
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

uses
  LocalizationManager, Ths.DialogHelper, DetailList;

{ TDetailSet<TD> }

constructor TDetailSet<TD>.Create(AGrid: TDetailGrid; const AGetList: TFunc<TObjectList<TD>>; const ACreateLine: TFunc<TD>;
  const AAddLine, ARemoveLine: TProc<TD>; const ALineForm: TDetailLineFormFactory<TD>);
begin
  inherited Create;
  FGrid := AGrid;
  FGetList := AGetList;
  FCreateLine := ACreateLine;
  FAddLine := AAddLine;
  FRemoveLine := ARemoveLine;
  FLineForm := ALineForm;
  FEditable := True;
  FVisible := TList<TD>.Create;
  FModified := TList<TD>.Create;

  FGrid.DefineFields(TD);
  FGrid.OnAdd := GridAdd;
  FGrid.OnEdit := GridEdit;
  FGrid.OnDelete := GridDelete;
end;

destructor TDetailSet<TD>.Destroy;
begin
  if Assigned(FGrid) then
  begin
    FGrid.OnAdd := nil;
    FGrid.OnEdit := nil;
    FGrid.OnDelete := nil;
  end;
  FModified.Free;
  FVisible.Free;
  inherited;
end;

function TDetailSet<TD>.GetGrid: TDetailGrid;
begin
  Result := FGrid;
end;

function TDetailSet<TD>.List: TObjectList<TD>;
begin
  Result := FGetList();
end;

function TDetailSet<TD>.Item(ARow: Integer): TD;
begin
  if (ARow >= 0) and (ARow < FVisible.Count) then
    Result := FVisible[ARow]
  else
    Result := nil;
end;

procedure TDetailSet<TD>.Refill(AFocusRow: Integer);
var
  LList: TObjectList<TD>;
  LItem: TD;
begin
  FVisible.Clear;
  LList := List;
  if Assigned(LList) then
    for LItem in LList do
      if not LItem.Deleted then
        FVisible.Add(LItem);

  FGrid.Fill(FVisible.Count,
    function(i: Integer): TObject
    begin
      Result := FVisible[i];
    end,
    function(i: Integer): TDetailRowState
    begin
      if FVisible[i].Id < 0 then
        Result := drsNew
      else if FModified.Contains(FVisible[i]) then
        Result := drsModified
      else
        Result := drsUnchanged;
    end,
    AFocusRow);
end;

procedure TDetailSet<TD>.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TDetailSet<TD>.Reset;
begin
  FModified.Clear;
  Refill(-1);
end;

procedure TDetailSet<TD>.SetEditable(AValue: Boolean);
begin
  FEditable := AValue;
  FGrid.Editable := AValue;
end;

// Satır formu modal; kabul edilirse düzenlenen nesne döner (çağıran sahiplenir), değilse nil (nesne formla gider)
function TDetailSet<TD>.ShowLine(ALine: TD; AMode: TInputFormMode; out AResult: TLineFormResult): TD;
var
  LForm: TForm;
  LLineForm: ILineForm;
begin
  Result := nil;
  AResult := lfrNone;
  if not Assigned(FLineForm) then
  begin
    ALine.Free;
    Exit;
  end;

  // satır form tarafından sahiplenilir (form serbest kalınca birlikte gider)
  LForm := FLineForm(ALine, AMode);
  try
    LForm.ShowModal;
    if Supports(LForm, ILineForm, LLineForm) then
    begin
      AResult := LLineForm.LineResult;
      if AResult = lfrAccept then
        Result := TD(LLineForm.ExtractLine);
    end;
    LLineForm := nil;
  finally
    LForm.Free;
  end;
end;

procedure TDetailSet<TD>.AddLine;
var
  LResult: TD;
  LFormResult: TLineFormResult;
begin
  if not FEditable then
    Exit;
  LResult := ShowLine(FCreateLine(), ifmNewRecord, LFormResult);
  if LResult = nil then
    Exit;
  FAddLine(LResult);
  Refill(FVisible.Count);   // yeni kalem sonda
  Changed;
end;

procedure TDetailSet<TD>.OpenLine(ARow: Integer);
var
  LItem, LCopy, LResult: TD;
  LFormResult: TLineFormResult;
begin
  LItem := Item(ARow);
  if LItem = nil then
    Exit;

  // kopya üzerinde çalışılır: vazgeçilirse belgedeki kalem değişmez
  LCopy := TD.Create;
  CopyEntityValues(LItem, LCopy);
  LCopy.HeaderEntity := LItem.HeaderEntity;

  if not FEditable then
  begin
    ShowLine(LCopy, ifmReadOnly, LFormResult);
    Exit;
  end;

  LResult := ShowLine(LCopy, ifmUpdate, LFormResult);
  if LFormResult = lfrDelete then
  begin
    FModified.Remove(LItem);
    FRemoveLine(LItem);
    Refill(ARow - 1);
    Changed;
  end
  else if LResult <> nil then
  begin
    // değerler belgedeki kaleme geri yazılır (nesne kimliği, başlık referansı ve liste sırası korunur)
    try
      CopyEntityValues(LResult, LItem);
    finally
      LResult.Free;
    end;
    if (LItem.Id > 0) and not FModified.Contains(LItem) then
      FModified.Add(LItem);
    Refill(ARow);
    Changed;
  end;
end;

procedure TDetailSet<TD>.DeleteLine(ARow: Integer);
var
  LItem: TD;
begin
  LItem := Item(ARow);
  if not FEditable or (LItem = nil) then
    Exit;
  if TThsDialogHelper.CustomMsgDlg(
    TLocalizationManager.Translate(TLangKeys.TDetailForm.MsgDeleteLine, 'Delete the selected line?'),
    mtConfirmation, [mbYes, mbNo],
    [TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'), TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')) <> mrYes then
    Exit;
  FModified.Remove(LItem);
  FRemoveLine(LItem);   // yeni kalem serbest kalır, kayıtlı kalem Deleted
  Refill(ARow - 1);
  Changed;
end;

procedure TDetailSet<TD>.GridAdd(AGrid: TDetailGrid; ARow: Integer);
begin
  AddLine;
end;

procedure TDetailSet<TD>.GridEdit(AGrid: TDetailGrid; ARow: Integer);
begin
  OpenLine(ARow);
end;

procedure TDetailSet<TD>.GridDelete(AGrid: TDetailGrid; ARow: Integer);
begin
  DeleteLine(ARow);
end;

end.
