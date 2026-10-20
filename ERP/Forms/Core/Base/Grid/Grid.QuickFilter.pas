unit Grid.QuickFilter;

// Liste altındaki (Kayıt Ekle düğmesi hizasında, sağda) hızlı filtre radyo düğmeleri (Tümü / Taslak / Bekleyenler …)

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Grid.Types;

const
  QUICK_FILTER_HEIGHT = 29;

type
  TGridQuickFilterEvent = procedure(AIndex: Integer) of object;

  TGridQuickFilterBar = class
  private
    FParent: TWinControl;
    FPanel: TPanel;
    FItems: TObjectList<TQuickFilter>;
    FItemIndex: Integer;
    FUpdating: Boolean;
    FOnSelect: TGridQuickFilterEvent;
    procedure ButtonClick(Sender: TObject);
    procedure Layout;
    function GetCount: Integer;
    function GetItem(AIndex: Integer): TQuickFilter;
  public
    constructor Create(AParent: TWinControl);
    destructor Destroy; override;
    // Panel ilk eklemede oluşur; ilk seçenek seçili gelir (OnSelect çağrılmaz). Sonuç: seçenek no
    function Add(const ACaption, ASql: string; const AParams: array of Variant): Integer;
    procedure SetCaption(AIndex: Integer; const ACaption: string);
    // Düğmeyi işaretler (OnSelect çağrılmaz); geçersiz / zaten seçili ise False
    function Check(AIndex: Integer): Boolean;

    property Count: Integer read GetCount;
    property ItemIndex: Integer read FItemIndex;
    property Items[AIndex: Integer]: TQuickFilter read GetItem; default;
    // Kullanıcı düğmeye tıkladığında
    property OnSelect: TGridQuickFilterEvent read FOnSelect write FOnSelect;
  end;

implementation

constructor TGridQuickFilterBar.Create(AParent: TWinControl);
begin
  inherited Create;
  FParent := AParent;
  FItems := TObjectList<TQuickFilter>.Create(True);
  FItemIndex := -1;
end;

destructor TGridQuickFilterBar.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TGridQuickFilterBar.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TGridQuickFilterBar.GetItem(AIndex: Integer): TQuickFilter;
begin
  Result := FItems[AIndex];
end;

function TGridQuickFilterBar.Add(const ACaption, ASql: string; const AParams: array of Variant): Integer;
var
  LItem: TQuickFilter;
  i: Integer;
begin
  if FPanel = nil then
  begin
    // üst satırda sağa yaslı (alt satır özet vb. için boş kalır)
    FPanel := TPanel.Create(FParent);
    FPanel.Parent := FParent;
    FPanel.Align := alNone;
    FPanel.Anchors := [akTop, akRight];
    FPanel.SetBounds(FParent.ClientWidth - 10, 0, 10, QUICK_FILTER_HEIGHT);
    FPanel.BevelOuter := bvNone;
    FPanel.ParentColor := True;
  end;

  LItem := TQuickFilter.Create;
  LItem.Sql := Trim(ASql);
  SetLength(LItem.Params, Length(AParams));
  for i := 0 to High(AParams) do
    LItem.Params[i] := AParams[i];
  Result := FItems.Add(LItem);

  LItem.Button := TRadioButton.Create(FPanel);
  LItem.Button.Parent := FPanel;
  LItem.Button.Left := 10000 + Result * 10;   // alLeft sırası eklenme sırası
  LItem.Button.Align := alLeft;
  LItem.Button.AlignWithMargins := True;
  LItem.Button.Margins.SetBounds(6, 3, 2, 3);
  LItem.Button.Caption := ACaption;
  LItem.Button.Tag := Result;
  LItem.Button.TabStop := False;
  if Result = 0 then
  begin
    // OnClick henüz bağlı değil: Checked ataması olay tetiklemez
    LItem.Button.Checked := True;
    FItemIndex := 0;
  end;
  LItem.Button.OnClick := ButtonClick;
  Layout;
end;

procedure TGridQuickFilterBar.SetCaption(AIndex: Integer; const ACaption: string);
begin
  if (AIndex < 0) or (AIndex >= FItems.Count) then
    Exit;
  FItems[AIndex].Button.Caption := ACaption;
  Layout;
end;

function TGridQuickFilterBar.Check(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count) and (AIndex <> FItemIndex);
  if not Result then
    Exit;
  FItemIndex := AIndex;
  FUpdating := True;
  try
    FItems[AIndex].Button.Checked := True;
  finally
    FUpdating := False;
  end;
end;

procedure TGridQuickFilterBar.ButtonClick(Sender: TObject);
begin
  if FUpdating or not (Sender is TRadioButton) or not TRadioButton(Sender).Checked then
    Exit;
  if Assigned(FOnSelect) then
    FOnSelect(TRadioButton(Sender).Tag);
end;

// Düğme genişliği metne göre (dil değişince de); panel düğmelerin toplamı kadar
procedure TGridQuickFilterBar.Layout;
var
  LItem: TQuickFilter;
  LForm: TCustomForm;
  LWidth: Integer;
begin
  if FPanel = nil then
    Exit;
  LForm := GetParentForm(FPanel);
  if LForm = nil then
    Exit;
  LForm.Canvas.Font.Assign(FPanel.Font);
  LWidth := 6;
  for LItem in FItems do
  begin
    LItem.Button.Width := LForm.Canvas.TextWidth(LItem.Button.Caption) + 24;
    Inc(LWidth, LItem.Button.Width + LItem.Button.Margins.Left + LItem.Button.Margins.Right);
  end;
  FPanel.SetBounds(FParent.ClientWidth - LWidth - 4, 0, LWidth, QUICK_FILTER_HEIGHT);
end;

end.
