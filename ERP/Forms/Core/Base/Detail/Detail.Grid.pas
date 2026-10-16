unit Detail.Grid;

// Ana kayıt + detay ekranlarında bir detay tablosunun grid'i (tipten bağımsız):
// entity özellikleri RTTI ile FDMemTable alanlarına (görünüm kolon adlarıyla: [Column] adı / [NotMapped] snake_case),
// satır durumu boyaması (yeni / değişmiş), hücre stili API'si (OnCellStyle) ve tam özel çizim (OnCustomDraw),
// popup (Ekle F7 / Değiştir Enter / Sil Ctrl+Del / CSV), alt toplamlar (TGridFooter), kolon düzeni (sys_grid_column).

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Rtti, System.TypInfo,
  Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.Grids, Vcl.DBGrids, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  UnitOfWork, DetailChanges, Grid.Types, Grid.Footer;

const
  DETAIL_FIELD_ROW = 'dtl_row';        // satırın küme içindeki sırası (gizli)
  DETAIL_FIELD_STATE = 'dtl_state';    // TDetailRowState (gizli)

  DETAIL_COLOR_NEW = $00FFE9D2;        // kaydedilmemiş yeni satır (açık mavi)
  DETAIL_COLOR_MODIFIED = $00D2ECFF;   // değiştirilmiş satır (açık turuncu)
  DETAIL_COLOR_ACTIVE = 9539955;
  DETAIL_COLOR_EVEN = 12189695;
  DETAIL_COLOR_ODD = 13158655;

type
  // Bir hücrenin çizimi; OnCellStyle içinde değiştirilir. Varsayılanlar: satır rengi, alanın metni / hizası
  TDetailCellStyle = record
    BackColor: TColor;
    FontColor: TColor;
    FontStyle: TFontStyles;
    Alignment: TAlignment;
    Text: string;                // DisplayText; değiştirilirse bu metin çizilir
    ProgressPercent: Integer;    // 0..100: hücre zemininde ilerleme çubuğu (-1 yok)
    ProgressColor: TColor;
    ImageIndex: Integer;         // dm.il16 resmi (metnin solunda), -1 yok
  end;

  TDetailGrid = class;

  TDetailCellStyleEvent = procedure(AGrid: TDetailGrid; ARow: Integer; AState: TDetailRowState; AField: TField;
    var AStyle: TDetailCellStyle) of object;
  // AHandled = True: hücre tamamen olay tarafından çizildi
  TDetailCustomDrawEvent = procedure(AGrid: TDetailGrid; ARow: Integer; AColumn: TColumn; ACanvas: TCanvas;
    const ARect: TRect; AState: TGridDrawState; var AHandled: Boolean) of object;
  TDetailRowEvent = procedure(AGrid: TDetailGrid; ARow: Integer) of object;

  TDetailGrid = class(TComponent)
  private
    FContainer: TPanel;
    FCaptionLabel: TLabel;
    FGrid: THackDBGrid;
    FData: TFDMemTable;
    FSource: TDataSource;
    FFooter: TGridFooter;
    FPopup: TPopupMenu;
    FmniAdd, FmniEdit, FmniDelete, FmniExport: TMenuItem;
    FViewName: string;
    FEditable: Boolean;
    FFilling: Boolean;
    FCtx: TRttiContext;
    FRowField: TField;
    FStateField: TField;
    FOnAdd: TDetailRowEvent;
    FOnEdit: TDetailRowEvent;
    FOnDelete: TDetailRowEvent;
    FOnCellStyle: TDetailCellStyleEvent;
    FOnCustomDraw: TDetailCustomDrawEvent;
    procedure GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure GridDblClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridTitleClick(Column: TColumn);
    procedure GridColWidthsChanged(Sender: TObject);
    procedure PopupPopup(Sender: TObject);
    procedure MniAddClick(Sender: TObject);
    procedure MniEditClick(Sender: TObject);
    procedure MniDeleteClick(Sender: TObject);
    procedure MniExportClick(Sender: TObject);
    function NewMenu(const AName: string; AOnClick: TNotifyEvent): TMenuItem;
    procedure SetEditable(AValue: Boolean);
    function GetCaption: string;
    procedure SetCaption(const AValue: string);
    procedure DrawCell(const ARect: TRect; AColumn: TColumn; AState: TGridDrawState);
  public
    constructor Create(AOwner: TComponent; AParent: TWinControl; const AViewName: string); reintroduce;
    destructor Destroy; override;

    // Alanlar entity sınıfının [Column] / [NotMapped] özelliklerinden; sonra alt toplamlar eklenip BuildData
    procedure DefineFields(AEntityClass: TClass);
    procedure AddFooterColumn(const AFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string = '');
    // Alanlar ve alt toplamlarla bellek tablosu oluşur (DefineFields + AddFooterColumn sonrası bir kez)
    procedure BuildData;

    // Satırlar baştan yazılır; AFocusRow (>= 0) satırına konumlanılır
    procedure Fill(ACount: Integer; const AGetItem: TFunc<Integer, TObject>; const AGetState: TFunc<Integer, TDetailRowState>;
      AFocusRow: Integer = -1);
    function CurrentRow: Integer;
    function RowCount: Integer;

    procedure SetColumnProperty(const AFieldName: string; AWidth: Integer; const ATitle: string = '');
    procedure SetColumnTitle(const AFieldName, ATitle: string);
    procedure SetFieldFormat(const AFieldName, ADisplayFormat: string);
    procedure LoadLayout(AUoW: TUnitOfWork);
    procedure SaveLayout(AUoW: TUnitOfWork);
    procedure UpdateFooter;
    procedure ApplyLocalization;

    property Container: TPanel read FContainer;
    property Grid: THackDBGrid read FGrid;
    property Data: TFDMemTable read FData;
    property Footer: TGridFooter read FFooter;
    property Popup: TPopupMenu read FPopup;
    property ViewName: string read FViewName;
    property Caption: string read GetCaption write SetCaption;
    // False: yalnız görüntüleme (çift tık / Enter satırı salt okunur açar), ekle / sil kapalı
    property Editable: Boolean read FEditable write SetEditable;

    property OnAdd: TDetailRowEvent read FOnAdd write FOnAdd;
    property OnEdit: TDetailRowEvent read FOnEdit write FOnEdit;
    property OnDelete: TDetailRowEvent read FOnDelete write FOnDelete;
    property OnCellStyle: TDetailCellStyleEvent read FOnCellStyle write FOnCellStyle;
    property OnCustomDraw: TDetailCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
  end;

// Görünüm kolon adı: [Column] adı, yoksa özellik adının snake_case hâli (InventoryName -> inventory_name)
function DetailFieldName(AProp: TRttiProperty): string;

implementation

uses
  Vcl.Forms, Vcl.Dialogs, System.Math, System.Variants, udm, EntityAttributes, LocalizationManager, Ths.Globals,
  Grid.Sql, Grid.Columns, Grid.Export;

function SnakeCase(const AName: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AName) do
    if CharInSet(AName[i], ['A'..'Z']) then
    begin
      if i > 1 then
        Result := Result + '_';
      Result := Result + LowerCase(AName[i]);
    end
    else
      Result := Result + AName[i];
end;

function DetailFieldName(AProp: TRttiProperty): string;
var
  LAttr: TCustomAttribute;
begin
  for LAttr in AProp.GetAttributes do
    if LAttr is Column then
      Exit(Column(LAttr).Name);
  Result := SnakeCase(AProp.Name);
end;

function IsDetailProperty(AProp: TRttiProperty): Boolean;
var
  LAttr: TCustomAttribute;
begin
  Result := False;
  if not AProp.IsReadable then
    Exit;
  for LAttr in AProp.GetAttributes do
    if (LAttr is Column) or (LAttr is NotMapped) then
      Exit(True);
end;

{ TDetailGrid }

constructor TDetailGrid.Create(AOwner: TComponent; AParent: TWinControl; const AViewName: string);
begin
  inherited Create(AOwner);
  FViewName := AViewName;
  FEditable := True;
  FCtx := TRttiContext.Create;

  FContainer := TPanel.Create(Self);
  FContainer.Parent := AParent;
  FContainer.Align := alClient;
  FContainer.BevelOuter := bvNone;
  FContainer.ParentColor := True;

  FCaptionLabel := TLabel.Create(Self);
  FCaptionLabel.Parent := FContainer;
  FCaptionLabel.Align := alTop;
  FCaptionLabel.AlignWithMargins := True;
  FCaptionLabel.Font.Style := [fsBold];
  FCaptionLabel.Visible := False;

  FData := TFDMemTable.Create(Self);
  FSource := TDataSource.Create(Self);
  FSource.DataSet := FData;

  FPopup := TPopupMenu.Create(Self);
  FPopup.OnPopup := PopupPopup;
  // kısayollar formda (F7) / grid'de (Enter, Ctrl+Del) işlenir; menüde yalnız metin olarak görünür
  FmniAdd := NewMenu('mniDetailAdd', MniAddClick);
  FmniEdit := NewMenu('mniDetailEdit', MniEditClick);
  FmniDelete := NewMenu('mniDetailDelete', MniDeleteClick);
  NewMenu('', nil).Caption := '-';
  FmniExport := NewMenu('mniDetailExport', MniExportClick);

  FGrid := THackDBGrid.Create(Self);
  FGrid.Parent := FContainer;
  FGrid.Align := alClient;
  FGrid.DataSource := FSource;
  FGrid.Options := FGrid.Options - [dgEditing, dgConfirmDelete] + [dgRowSelect, dgAlwaysShowSelection];
  FGrid.ReadOnly := True;
  FGrid.PopupMenu := FPopup;
  FGrid.DefaultDrawing := False;
  FGrid.OnDrawColumnCell := GridDrawColumnCell;
  FGrid.OnDblClick := GridDblClick;
  FGrid.OnKeyDown := GridKeyDown;
  FGrid.OnTitleClick := GridTitleClick;
  FGrid.OnColWidthsChanged := GridColWidthsChanged;

  FFooter := TGridFooter.Create;
  FFooter.CreatePanel(FContainer);
  FFooter.Panel.Align := alBottom;

  ApplyLocalization;
end;

destructor TDetailGrid.Destroy;
begin
  FSource.DataSet := nil;
  FFooter.Free;
  FCtx.Free;
  inherited;
end;

function TDetailGrid.NewMenu(const AName: string; AOnClick: TNotifyEvent): TMenuItem;
begin
  Result := TMenuItem.Create(FPopup);
  Result.Name := AName;
  Result.OnClick := AOnClick;
  FPopup.Items.Add(Result);
end;

function TDetailGrid.GetCaption: string;
begin
  Result := FCaptionLabel.Caption;
end;

procedure TDetailGrid.SetCaption(const AValue: string);
begin
  FCaptionLabel.Caption := AValue;
  FCaptionLabel.Visible := AValue <> '';
end;

procedure TDetailGrid.SetEditable(AValue: Boolean);
begin
  FEditable := AValue;
  FGrid.Invalidate;
end;

procedure TDetailGrid.ApplyLocalization;
begin
  FmniAdd.Caption := TLocalizationManager.Translate(TLangKeys.TDetailForm.LineAdd, 'Add Line') + #9'F7';
  FmniEdit.Caption := TLocalizationManager.Translate(TLangKeys.TDetailForm.LineEdit, 'Open Line') + #9'Enter';
  FmniDelete.Caption := TLocalizationManager.Translate(TLangKeys.TDetailForm.LineDelete, 'Delete Line') + #9'Ctrl+Del';
  FmniExport.Caption := TLocalizationManager.Translate(TLangKeys.TPopupMenu.ExportCsv, 'Export to CSV');
end;

procedure TDetailGrid.DefineFields(AEntityClass: TClass);
var
  LProp: TRttiProperty;
  LDef: TFieldDef;
  LName, LTypeName: string;
  LAttr: TCustomAttribute;
  LSize: Integer;
begin
  FData.Close;
  FData.FieldDefs.Clear;

  FData.FieldDefs.Add(DETAIL_FIELD_ROW, ftInteger);
  FData.FieldDefs.Add(DETAIL_FIELD_STATE, ftSmallint);

  for LProp in FCtx.GetType(AEntityClass).GetProperties do
  begin
    if not IsDetailProperty(LProp) then
      Continue;
    LName := DetailFieldName(LProp);
    if FData.FieldDefs.IndexOf(LName) >= 0 then
      Continue;
    LTypeName := LProp.PropertyType.Name;
    case LProp.PropertyType.TypeKind of
      tkInteger:
        if SameText(LTypeName, 'SmallInt') then
          FData.FieldDefs.Add(LName, ftSmallint)
        else
          FData.FieldDefs.Add(LName, ftInteger);
      tkInt64:
        FData.FieldDefs.Add(LName, ftLargeint);
      tkFloat:
        if SameText(LTypeName, 'TDate') then
          FData.FieldDefs.Add(LName, ftDate)
        else if SameText(LTypeName, 'TTime') then
          FData.FieldDefs.Add(LName, ftTime)
        else if SameText(LTypeName, 'TDateTime') then
          FData.FieldDefs.Add(LName, ftDateTime)
        else if SameText(LTypeName, 'Currency') then
          FData.FieldDefs.Add(LName, ftCurrency)
        else
          FData.FieldDefs.Add(LName, ftFloat);
      tkEnumeration:
        if SameText(LTypeName, 'Boolean') then
          FData.FieldDefs.Add(LName, ftBoolean)
        else
          Continue;
      tkUString, tkString, tkLString, tkWString:
        begin
          LSize := 255;
          for LAttr in LProp.GetAttributes do
            if (LAttr is MaxLength) and (MaxLength(LAttr).MaxLength > 0) then
              LSize := MaxLength(LAttr).MaxLength;
          LDef := FData.FieldDefs.AddFieldDef;
          LDef.Name := LName;
          LDef.DataType := ftWideString;
          LDef.Size := LSize;
        end;
    else
      Continue;
    end;
  end;
end;

procedure TDetailGrid.AddFooterColumn(const AFieldName: string; AAggregateType: TAggregateType; const ADisplayFormat: string);
begin
  FFooter.Add(AFieldName, AAggregateType, ADisplayFormat);
end;

procedure TDetailGrid.BuildData;
var
  i: Integer;
begin
  FData.Close;
  FFooter.Build(FData, False);
  FData.CreateDataSet;

  FRowField := FData.FieldByName(DETAIL_FIELD_ROW);
  FStateField := FData.FieldByName(DETAIL_FIELD_STATE);
  FRowField.Visible := False;
  FStateField.Visible := False;
  for i := 0 to FData.Fields.Count - 1 do
    if FData.Fields[i] is TCurrencyField then
      TCurrencyField(FData.Fields[i]).Currency := False;
end;

procedure TDetailGrid.Fill(ACount: Integer; const AGetItem: TFunc<Integer, TObject>;
  const AGetState: TFunc<Integer, TDetailRowState>; AFocusRow: Integer);
var
  i: Integer;
  LItem: TObject;
  LProp: TRttiProperty;
  LField: TField;
  LValue: TValue;
begin
  FFilling := True;
  FData.DisableControls;
  try
    FData.EmptyDataSet;
    for i := 0 to ACount - 1 do
    begin
      LItem := AGetItem(i);
      FData.Append;
      FRowField.AsInteger := i;
      FStateField.AsInteger := Ord(AGetState(i));
      for LProp in FCtx.GetType(LItem.ClassType).GetProperties do
      begin
        if not IsDetailProperty(LProp) then
          Continue;
        LField := FData.FindField(DetailFieldName(LProp));
        if (LField = nil) or (LField = FRowField) or (LField = FStateField) then
          Continue;
        LValue := LProp.GetValue(LItem);
        case LField.DataType of
          ftDate, ftTime, ftDateTime:
            if LValue.AsExtended = 0 then
              LField.Clear
            else
              LField.AsDateTime := LValue.AsExtended;
          ftCurrency:
            LField.AsCurrency := LValue.AsCurrency;
          ftFloat:
            LField.AsFloat := LValue.AsExtended;
          ftSmallint, ftInteger:
            LField.AsInteger := LValue.AsInteger;
          ftLargeint:
            LField.AsLargeInt := LValue.AsInt64;
          ftBoolean:
            LField.AsBoolean := LValue.AsBoolean;
          ftWideString:
            LField.AsWideString := LValue.AsString;
        end;
      end;
      FData.Post;
    end;

    if (AFocusRow >= 0) and (AFocusRow < ACount) then
      FData.Locate(DETAIL_FIELD_ROW, AFocusRow, [])
    else
      FData.First;
  finally
    FData.EnableControls;
    FFilling := False;
  end;
  UpdateFooter;
end;

function TDetailGrid.CurrentRow: Integer;
begin
  if not FData.Active or FData.IsEmpty then
    Exit(-1);
  Result := FRowField.AsInteger;
end;

function TDetailGrid.RowCount: Integer;
begin
  if FData.Active then
    Result := FData.RecordCount
  else
    Result := 0;
end;

procedure TDetailGrid.SetColumnProperty(const AFieldName: string; AWidth: Integer; const ATitle: string);
begin
  TGridColumns.SetColumnProperty(FGrid, AFieldName, AWidth, ATitle);
end;

procedure TDetailGrid.SetColumnTitle(const AFieldName, ATitle: string);
begin
  TGridColumns.SetColumnTitle(FGrid, AFieldName, ATitle);
end;

procedure TDetailGrid.SetFieldFormat(const AFieldName, ADisplayFormat: string);
var
  LField: TField;
begin
  LField := FData.FindField(AFieldName);
  if LField is TNumericField then
    TNumericField(LField).DisplayFormat := ADisplayFormat
  else if LField is TDateTimeField then
    TDateTimeField(LField).DisplayFormat := ADisplayFormat;
end;

procedure TDetailGrid.LoadLayout(AUoW: TUnitOfWork);
begin
  TGridColumns.SetTitleStyle(FGrid);
  TGridColumns.LoadLayout(AUoW, FViewName, FGrid);
  UpdateFooter;
end;

procedure TDetailGrid.SaveLayout(AUoW: TUnitOfWork);
begin
  TGridColumns.SaveUserLayout(AUoW, FViewName, FGrid);
end;

procedure TDetailGrid.UpdateFooter;
begin
  FFooter.UpdateLayout(FGrid, False);
end;

procedure TDetailGrid.GridColWidthsChanged(Sender: TObject);
begin
  UpdateFooter;
end;

procedure TDetailGrid.GridTitleClick(Column: TColumn);
begin
  // bellek tablosunda sıralama (satır numaraları değişmez)
  if not Assigned(Column.Field) then
    Exit;
  FData.IndexFieldNames := ToggleSortFields(FData.IndexFieldNames, Column.FieldName, isCtrlDown);
  FGrid.InvalidateTitleRow;
end;

procedure TDetailGrid.GridDblClick(Sender: TObject);
begin
  MniEditClick(Sender);
end;

procedure TDetailGrid.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    Key := 0;
    MniEditClick(Sender);
  end
  else if (Key = VK_DELETE) and (Shift = [ssCtrl]) then
  begin
    Key := 0;
    MniDeleteClick(Sender);
  end;
end;

procedure TDetailGrid.PopupPopup(Sender: TObject);
begin
  FmniAdd.Enabled := FEditable and Assigned(FOnAdd);
  FmniEdit.Enabled := (CurrentRow >= 0) and Assigned(FOnEdit);
  FmniDelete.Enabled := FEditable and (CurrentRow >= 0) and Assigned(FOnDelete);
  FmniExport.Enabled := RowCount > 0;
end;

procedure TDetailGrid.MniAddClick(Sender: TObject);
begin
  if FEditable and Assigned(FOnAdd) then
    FOnAdd(Self, -1);
end;

procedure TDetailGrid.MniEditClick(Sender: TObject);
begin
  if (CurrentRow >= 0) and Assigned(FOnEdit) then
    FOnEdit(Self, CurrentRow);
end;

procedure TDetailGrid.MniDeleteClick(Sender: TObject);
begin
  if FEditable and (CurrentRow >= 0) and Assigned(FOnDelete) then
    FOnDelete(Self, CurrentRow);
end;

procedure TDetailGrid.MniExportClick(Sender: TObject);
var
  LPath: string;
  LBookmark: TBookmark;
begin
  if RowCount = 0 then
    Exit;
  LPath := GetDialogSave(FViewName + '.csv', TLocalizationManager.Translate(TLangKeys.TDetailForm.CsvFilter, 'CSV Files (*.csv)|*.csv'));
  if LPath = '' then
    Exit;
  LBookmark := FData.GetBookmark;
  try
    TGridExport.ToCsv(FGrid, FData, LPath);
  finally
    if FData.BookmarkValid(LBookmark) then
      FData.GotoBookmark(LBookmark);
    FData.FreeBookmark(LBookmark);
  end;
  ShowMessage(TLocalizationManager.Translate('msg.csv_export_completed', 'CSV export completed!'));
end;

procedure TDetailGrid.GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  LHandled: Boolean;
begin
  LHandled := False;
  if Assigned(FOnCustomDraw) and not FData.IsEmpty then
    FOnCustomDraw(Self, CurrentRow, Column, FGrid.Canvas, Rect, State, LHandled);
  if not LHandled then
    DrawCell(Rect, Column, State);
end;

procedure TDetailGrid.DrawCell(const ARect: TRect; AColumn: TColumn; AState: TGridDrawState);
const
  CHECK_STATE: array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  LStyle: TDetailCellStyle;
  LRowState: TDetailRowState;
  LCanvas: TCanvas;
  LRect, LBar: TRect;
  LField: TField;
  LLeft, LTextWidth: Integer;
  LActive: Boolean;
begin
  LCanvas := FGrid.Canvas;
  LField := AColumn.Field;
  LActive := FGrid.ActiveRecord = FGrid.Row - 1;

  if FData.IsEmpty or (LField = nil) then
  begin
    LCanvas.Brush.Color := FGrid.Color;
    LCanvas.FillRect(ARect);
    Exit;
  end;

  LRowState := TDetailRowState(FStateField.AsInteger);

  // varsayılan: aktif / çift-tek satır, kayıt durumu, alanın metni ve hizası
  LStyle.FontColor := clWindowText;
  LStyle.FontStyle := [];
  LStyle.Alignment := AColumn.Alignment;
  LStyle.Text := LField.DisplayText;
  LStyle.ProgressPercent := -1;
  LStyle.ProgressColor := $0080D080;
  LStyle.ImageIndex := -1;
  if LActive then
    LStyle.BackColor := DETAIL_COLOR_ACTIVE
  else if LRowState = drsNew then
    LStyle.BackColor := DETAIL_COLOR_NEW
  else if LRowState = drsModified then
    LStyle.BackColor := DETAIL_COLOR_MODIFIED
  else if FData.RecNo mod 2 = 0 then
    LStyle.BackColor := DETAIL_COLOR_EVEN
  else
    LStyle.BackColor := DETAIL_COLOR_ODD;

  if Assigned(FOnCellStyle) then
    FOnCellStyle(Self, FRowField.AsInteger, LRowState, LField, LStyle);

  LCanvas.Brush.Color := LStyle.BackColor;
  LCanvas.FillRect(ARect);

  if (LStyle.ProgressPercent >= 0) then
  begin
    LBar := ARect;
    InflateRect(LBar, -1, -2);
    LBar.Right := LBar.Left + MulDiv(LBar.Right - LBar.Left, Min(LStyle.ProgressPercent, 100), 100);
    LCanvas.Brush.Color := LStyle.ProgressColor;
    LCanvas.FillRect(LBar);
  end;

  if LField.DataType = ftBoolean then
  begin
    LRect := ARect;
    InflateRect(LRect, -2, -2);
    if LField.IsNull then
      DrawFrameControl(LCanvas.Handle, LRect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_INACTIVE)
    else
      DrawFrameControl(LCanvas.Handle, LRect, DFC_BUTTON, CHECK_STATE[LField.AsBoolean]);
    Exit;
  end;

  LRect := ARect;
  InflateRect(LRect, -2, 0);
  if LStyle.ImageIndex >= 0 then
  begin
    dm.il16.Draw(LCanvas, LRect.Left, LRect.Top + (LRect.Height - dm.il16.Height) div 2, LStyle.ImageIndex);
    Inc(LRect.Left, dm.il16.Width + 2);
  end;

  LCanvas.Brush.Style := bsClear;
  LCanvas.Font.Color := LStyle.FontColor;
  LCanvas.Font.Style := LStyle.FontStyle;
  LTextWidth := LCanvas.TextWidth(LStyle.Text);
  case LStyle.Alignment of
    taRightJustify: LLeft := LRect.Right - LTextWidth;
    taCenter: LLeft := LRect.Left + (LRect.Width - LTextWidth) div 2;
  else
    LLeft := LRect.Left;
  end;
  LCanvas.TextRect(LRect, LLeft, LRect.Top + (LRect.Height - LCanvas.TextHeight('Wg')) div 2, LStyle.Text);
  LCanvas.Brush.Style := bsSolid;

  if gdFocused in AState then
    LCanvas.DrawFocusRect(ARect);
end;

end.
