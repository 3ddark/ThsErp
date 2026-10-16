unit Detail.Lines;

// Bir detay tablosunun ekrandaki kümesi: bellekteki satırlar (TDetailChanges) + grid (TDetailGrid) + satır formu.
// Ekle / aç / sil işlemleri satır formunu modal açar; sonuç bellekteki kümeye yazılır, grid yenilenir.
// Veritabanına yazma ana servisin BusinessSaveWithDetails'inde (Changes) olur.

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo, System.Generics.Defaults,
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs,
  Entity, Service, SharedFormTypes, DetailChanges, Detail.Grid;

type
  TLineFormResult = (lfrNone, lfrAccept, lfrDelete);

  // Satır formu sözleşmesi (TfrmInputLineDB uygular)
  ILineForm = interface
    ['{4B8E0C51-2F6A-4D3B-8A7E-9C1D5F2E6B30}']
    function LineResult: TLineFormResult;
    // Formun düzenlediği satır nesnesi forma ait olmaktan çıkar (çağıran sahiplenir)
    function ExtractLine: TObject;
  end;

  // Tipten bağımsız detay kümesi (ana form bu arayüzle çalışır)
  IDetailSet = interface
    ['{A13F7D2C-6B95-4E08-B4C1-0E7A9D3F5C26}']
    function GetGrid: TDetailGrid;
    function GetChanges: IDetailChanges;
    procedure Load(AMasterId: Int64);
    procedure MarkAllNew;
    procedure SetEditable(AValue: Boolean);
    function HasChanges: Boolean;
    procedure AddLine;
    procedure OpenLine(ARow: Integer);
    procedure DeleteLine(ARow: Integer);
    property Grid: TDetailGrid read GetGrid;
  end;

  TDetailLineFormFactory<TD> = reference to function(ALine: TD; AMode: TInputFormMode): TForm;

  TDetailSet<TD: TEntity, constructor; TDS: TCrudService<TD>> = class(TNoRefCountObject, IDetailSet)
  private
    FChanges: TDetailChanges<TD, TDS>;
    FGrid: TDetailGrid;
    FMasterField: string;
    FEditable: Boolean;
    FLineForm: TDetailLineFormFactory<TD>;
    FOnNewLine: TProc<TD>;
    FOnChanged: TNotifyEvent;
    procedure Refill(AFocusRow: Integer);
    procedure Changed;
    function ShowLine(ALine: TD; AMode: TInputFormMode; out AResult: TLineFormResult): TD;
    procedure GridAdd(AGrid: TDetailGrid; ARow: Integer);
    procedure GridEdit(AGrid: TDetailGrid; ARow: Integer);
    procedure GridDelete(AGrid: TDetailGrid; ARow: Integer);
  public
    // AService sahiplenilir; AGrid ana formun bileşenidir (form serbest bırakır)
    constructor Create(AService: TDS; AGrid: TDetailGrid; const AMasterField: string;
      const ASetMasterId: TProc<TD, Int64>; const ALineForm: TDetailLineFormFactory<TD>; const ACompare: TComparison<TD>);
    destructor Destroy; override;

    // IDetailSet
    function GetGrid: TDetailGrid;
    function GetChanges: IDetailChanges;
    procedure Load(AMasterId: Int64);
    procedure MarkAllNew;
    procedure SetEditable(AValue: Boolean);
    function HasChanges: Boolean;
    procedure AddLine;
    procedure OpenLine(ARow: Integer);
    procedure DeleteLine(ARow: Integer);

    property Changes: TDetailChanges<TD, TDS> read FChanges;
    property Grid: TDetailGrid read FGrid;
    property Editable: Boolean read FEditable;
    // Yeni satır nesnesi formdan önce: ana kayıttan gelen değerler (ana id, para birimi, belge no …)
    property OnNewLine: TProc<TD> read FOnNewLine write FOnNewLine;
    // Satır eklendi / değişti / silindi (ana formda toplamlar)
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

// Okunabilir + yazılabilir basit tipli tüm özellikler kopyalanır ([Column] ve [NotMapped]; nesne özellikleri hariç)
procedure CopyEntityValues(ASource, ATarget: TObject);

implementation

uses
  LocalizationManager, Ths.DialogHelper;

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

{ TDetailSet<TD, TDS> }

constructor TDetailSet<TD, TDS>.Create(AService: TDS; AGrid: TDetailGrid; const AMasterField: string;
  const ASetMasterId: TProc<TD, Int64>; const ALineForm: TDetailLineFormFactory<TD>; const ACompare: TComparison<TD>);
begin
  inherited Create;
  FChanges := TDetailChanges<TD, TDS>.Create(AService, ASetMasterId, ACompare);
  FGrid := AGrid;
  FMasterField := AMasterField;
  FLineForm := ALineForm;
  FEditable := True;

  FGrid.DefineFields(TD);
  FGrid.OnAdd := GridAdd;
  FGrid.OnEdit := GridEdit;
  FGrid.OnDelete := GridDelete;
end;

destructor TDetailSet<TD, TDS>.Destroy;
begin
  if Assigned(FGrid) then
  begin
    FGrid.OnAdd := nil;
    FGrid.OnEdit := nil;
    FGrid.OnDelete := nil;
  end;
  FChanges.Free;
  inherited;
end;

function TDetailSet<TD, TDS>.GetGrid: TDetailGrid;
begin
  Result := FGrid;
end;

function TDetailSet<TD, TDS>.GetChanges: IDetailChanges;
begin
  Result := FChanges;
end;

procedure TDetailSet<TD, TDS>.Refill(AFocusRow: Integer);
begin
  FGrid.Fill(FChanges.Count,
    function(i: Integer): TObject
    begin
      Result := FChanges[i];
    end,
    function(i: Integer): TDetailRowState
    begin
      Result := FChanges.States[i];
    end,
    AFocusRow);
end;

procedure TDetailSet<TD, TDS>.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TDetailSet<TD, TDS>.Load(AMasterId: Int64);
begin
  FChanges.Load(FMasterField, AMasterId);
  Refill(-1);
  Changed;
end;

procedure TDetailSet<TD, TDS>.MarkAllNew;
begin
  FChanges.MarkAllNew;
  Refill(FGrid.CurrentRow);
  Changed;
end;

procedure TDetailSet<TD, TDS>.SetEditable(AValue: Boolean);
begin
  FEditable := AValue;
  FGrid.Editable := AValue;
end;

function TDetailSet<TD, TDS>.HasChanges: Boolean;
begin
  Result := FChanges.HasChanges;
end;

// Satır formu modal; kabul edilirse düzenlenen nesne döner (çağıran sahiplenir), değilse nil
function TDetailSet<TD, TDS>.ShowLine(ALine: TD; AMode: TInputFormMode; out AResult: TLineFormResult): TD;
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

procedure TDetailSet<TD, TDS>.AddLine;
var
  LLine, LResult: TD;
  LFormResult: TLineFormResult;
begin
  if not FEditable then
    Exit;
  LLine := TD.Create;
  if Assigned(FOnNewLine) then
    FOnNewLine(LLine);
  LResult := ShowLine(LLine, ifmNewRecord, LFormResult);
  if LResult = nil then
    Exit;
  Refill(FChanges.Add(LResult));
  Changed;
end;

procedure TDetailSet<TD, TDS>.OpenLine(ARow: Integer);
var
  LCopy, LResult: TD;
  LFormResult: TLineFormResult;
begin
  if (ARow < 0) or (ARow >= FChanges.Count) then
    Exit;

  // kopya üzerinde çalışılır: vazgeçilirse kümedeki satır değişmez
  LCopy := TD.Create;
  CopyEntityValues(FChanges[ARow], LCopy);

  if not FEditable then
  begin
    ShowLine(LCopy, ifmReadOnly, LFormResult);
    Exit;
  end;

  LResult := ShowLine(LCopy, ifmUpdate, LFormResult);
  if LFormResult = lfrDelete then
  begin
    FChanges.Delete(ARow);
    Refill(ARow - 1);
    Changed;
  end
  else if LResult <> nil then
  begin
    FChanges.Replace(ARow, LResult);
    Refill(ARow);
    Changed;
  end;
end;

procedure TDetailSet<TD, TDS>.DeleteLine(ARow: Integer);
begin
  if not FEditable or (ARow < 0) or (ARow >= FChanges.Count) then
    Exit;
  if TThsDialogHelper.CustomMsgDlg(
    TLocalizationManager.Translate(TLangKeys.TDetailForm.MsgDeleteLine, 'Delete the selected line?'),
    mtConfirmation, [mbYes, mbNo],
    [TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'), TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')) <> mrYes then
    Exit;
  FChanges.Delete(ARow);
  Refill(ARow - 1);
  Changed;
end;

procedure TDetailSet<TD, TDS>.GridAdd(AGrid: TDetailGrid; ARow: Integer);
begin
  AddLine;
end;

procedure TDetailSet<TD, TDS>.GridEdit(AGrid: TDetailGrid; ARow: Integer);
begin
  OpenLine(ARow);
end;

procedure TDetailSet<TD, TDS>.GridDelete(AGrid: TDetailGrid; ARow: Integer);
begin
  DeleteLine(ARow);
end;

end.
