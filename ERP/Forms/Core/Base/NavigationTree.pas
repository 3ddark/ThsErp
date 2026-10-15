unit NavigationTree;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, System.SysUtils, System.Classes, System.Math,
  System.Types, System.Generics.Collections, System.Generics.Defaults, System.Character, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.WinXCtrls, Vcl.Themes, Vcl.Forms, Vcl.Menus,
  SysMenu;

type
  TNavOpenEvent = procedure(const AItem: TSysMenuItem) of object;
  TNavFavoriteEvent = procedure(const AItem: TSysMenuItem; AFavorite: Boolean) of object;

  TNavTreeView = class(TTreeView)
  private
    FHotNode: TTreeNode;
    procedure SetHotNode(ANode: TTreeNode);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDblClk(var Message: TWMMouse); message WM_LBUTTONDBLCLK;
  protected
    procedure CreateWnd; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    property HotNode: TTreeNode read FHotNode write SetHotNode;
  end;

  // Araç çubuğundaki menü (hamburger) düğmesi: ikonu Paint'te çizer (formun font değiştirmesinden etkilenmez)
  TNavToggleButton = class(TGraphicControl)
  private
    FHot: Boolean;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnClick;
  end;

  // Sol menü: arama kutusu + menü ağacı (sys_menu). Yalnız Allowed ekranlar ve onları içeren klasörler görünür.
  // Arama: ad, anahtar kelime, üst klasör adları ve kod; Türkçe / Almanca harfler ayırt edilmez
  // ("cek" -> "Çek"); yalnız rakam yazılırsa kod başlangıcı ("3003" -> Finans > Çek / Senet).
  // Enter ilk sonucu (ya da seçili ekranı) açar, tam kod + Enter doğrudan o ekranı açar.
  // Arama boşken en üstte kısayol klasörleri: Favoriler ve Son Kullanılanlar (en son açılan NAV_RECENT_COUNT ekran);
  // favori: sağ tık menüsü ya da Ctrl+D. Kısayol düğümlerinin Data değeri negatiftir (DATA_FAVORITES / DATA_RECENT).
  TNavMenuPanel = class(TPanel)
  private
    FSearch: TSearchBox;
    FTree: TNavTreeView;
    FEmpty: TLabel;
    FItems: TArray<TSysMenuItem>;
    FHaystack: TArray<string>;
    FPaths: TArray<string>;
    FExpanded: TList<Integer>;
    FFilter: string;
    FOnOpenItem: TNavOpenEvent;
    FOnToggleFavorite: TNavFavoriteEvent;
    FUpdating: Boolean;
    FPopup: TPopupMenu;
    FMniFavorite: TMenuItem;
    FTextFavorites, FTextRecent, FTextAddFavorite, FTextRemoveFavorite: string;
    function ItemIndexOf(ANode: TTreeNode): Integer;
    function NodeKey(ANode: TTreeNode): Integer;
    function IsShortcutFolder(ANode: TTreeNode): Boolean;
    function FindNodeByKey(AKey, ARootKey: Integer): TTreeNode;
    function RootKey(ANode: TTreeNode): Integer;
    procedure RebuildKeepingPosition;
    procedure ToggleFavorite(ANode: TTreeNode);
    procedure PopupShow(Sender: TObject);
    procedure MniFavoriteClick(Sender: TObject);
    function IsVisibleScreen(AIndex: Integer): Boolean;
    function GetExpandedKeys: TArray<Integer>;
    procedure SetExpandedKeys(const AValue: TArray<Integer>);
    function FindItem(ACode: Integer): Integer;
    function Matches(AIndex: Integer; const ATokens: TArray<string>; ADigits: Boolean): Boolean;
    function FirstScreenNode: TTreeNode;
    procedure RememberExpanded;
    procedure Rebuild;
    procedure OpenNode(ANode: TTreeNode);
    procedure SearchChange(Sender: TObject);
    procedure SearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchKeyPress(Sender: TObject; var Key: Char);
    procedure TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeKeyPress(Sender: TObject; var Key: Char);
    procedure TreeClick(Sender: TObject);
    procedure TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
      Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
    procedure TreeExpandedChange(Sender: TObject; Node: TTreeNode);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateControls;
    procedure SetItems(const AItems: TArray<TSysMenuItem>);
    procedure ApplyTexts(const ASearchHint, AEmptyText, AFavorites, ARecent, AAddFavorite, ARemoveFavorite: string);
    // tercih değişti (servis kaydettikten sonra): ağaç konumu korunarak yenilenir
    procedure SetFavorite(AMenuCode: Integer; AValue: Boolean);
    procedure MarkOpened(AMenuCode: Integer);
    // düğüm Favoriler / Son Kullanılanlar altında mı (kısayol kopyası)
    function IsShortcutNode(ANode: TTreeNode): Boolean;
    // komut paleti: görünür ekranlar; sorgu boşsa favoriler + son kullanılanlar, doluysa eşleşenler
    // (favori, açılma sayısı, kod sırasıyla), en çok AMax
    function Search(const AQuery: string; AMax: Integer): TArray<TSysMenuItem>;
    // "Finans > Çek / Senet"
    function PathOf(AMenuCode: Integer): string;
    // açık klasörler (menü kodları + kısayol klasörleri): kullanıcı ayarı olarak saklanır
    property ExpandedKeys: TArray<Integer> read GetExpandedKeys write SetExpandedKeys;
    procedure FocusSearch;
    // Esc: arama doluysa temizler (True = tuş kullanıldı)
    function HandleEscape: Boolean;
    function ContainsFocus: Boolean;
    property OnOpenItem: TNavOpenEvent read FOnOpenItem write FOnOpenItem;
    property OnToggleFavorite: TNavFavoriteEvent read FOnToggleFavorite write FOnToggleFavorite;
    property SearchBox: TSearchBox read FSearch;
    property Tree: TNavTreeView read FTree;
  end;

  // Komut paleti (Ctrl+K, her ekrandan): arama kutusu + sonuç listesi; Enter açar, Esc / odak kaybı kapatır.
  // Modal açılır; seçilen ekran dönüş değeridir (ekranı çağıran açar). Sorgu sol menüyle aynı kurallarla aranır.
  TNavCommandPalette = class(TForm)
  private
    FNav: TNavMenuPanel;
    FSearch: TSearchBox;
    FList: TListBox;
    FEmpty: TLabel;
    FResults: TArray<TSysMenuItem>;
    procedure Refresh;
    procedure SearchChange(Sender: TObject);
    procedure SearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SearchKeyPress(Sender: TObject; var Key: Char);
    procedure ListDblClick(Sender: TObject);
    procedure ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormDeactivate(Sender: TObject);
    procedure Accept;
  public
    constructor CreatePalette(AOwner: TComponent; ANav: TNavMenuPanel; const AHint, AEmptyText: string);
    function Selected(out AItem: TSysMenuItem): Boolean;
    property SearchBox: TSearchBox read FSearch;
    property List: TListBox read FList;
    class function Execute(AOwner: TComponent; ANav: TNavMenuPanel; const AHint, AEmptyText: string;
      out AItem: TSysMenuItem): Boolean;
  end;

  // Arama için sadeleştirme: küçük harf, Türkçe / Almanca / Fransızca harfler ASCII karşılığına
  function NavNormalize(const AText: string): string;

implementation

uses
  DashboardControls;

const
  NAV_ITEM_HEIGHT = 26;
  NAV_INDENT = 16;
  ICON_CHEVRON_RIGHT = #$E76C;
  ICON_CHEVRON_DOWN  = #$E70D;
  ICON_SETTINGS      = #$E713;
  ICON_FACTORY       = #$E90F;
  ICON_MENU          = #$E700;
  ICON_STAR          = #$E735;   // dolu yıldız
  ICON_HISTORY       = #$E81C;
  STAR_COLOR         = $0008B3EA;   // RGB(234, 179, 8)
  NAV_RECENT_COUNT   = 7;
  // kısayol klasörleri: düğüm Data değeri / hatırlanan açık klasör anahtarı
  DATA_FAVORITES = -1;
  DATA_RECENT    = -2;
  KEY_FAVORITES  = 1;
  KEY_RECENT     = 2;

function NavNormalize(const AText: string): string;
var
  C: Char;
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create(Length(AText));
  try
    for C in AText do
      case C of
        'ı', 'I', 'İ', 'i', 'î', 'Î', 'ï', 'Ï', 'í', 'Í': SB.Append('i');
        'ş', 'Ş': SB.Append('s');
        'ğ', 'Ğ': SB.Append('g');
        'ü', 'Ü', 'û', 'Û', 'ú', 'Ú', 'ù', 'Ù': SB.Append('u');
        'ö', 'Ö', 'ô', 'Ô', 'ó', 'Ó': SB.Append('o');
        'ç', 'Ç': SB.Append('c');
        'ä', 'Ä', 'â', 'Â', 'à', 'À', 'á', 'Á': SB.Append('a');
        'é', 'É', 'è', 'È', 'ê', 'Ê', 'ë', 'Ë': SB.Append('e');
        'ß': SB.Append('ss');
        '/', '-', '(', ')', ',', '.': SB.Append(' ');
      else
        SB.Append(C.ToLower);
      end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function IsAllDigits(const AText: string): Boolean;
var
  C: Char;
begin
  Result := AText <> '';
  for C in AText do
    if not CharInSet(C, ['0'..'9']) then
      Exit(False);
end;

function ModuleIcon(ACode: Integer): string;
begin
  case ACode div 10000 of
    10: Result := ICON_SETTINGS;
    20: Result := ICON_PIE;
    30: Result := ICON_BANK;
    40: Result := ICON_BOX;
    50: Result := ICON_CART;
    60: Result := ICON_BAG;
    70: Result := ICON_FACTORY;
    80: Result := ICON_PEOPLE;
  else
    Result := ICON_LIST;
  end;
end;

function ModuleColor(ACode: Integer): TColor;
begin
  case ACode div 10000 of
    10: Result := RGB(100, 116, 139);
    20: Result := RGB(124, 92, 230);
    30: Result := RGB(16, 163, 127);
    40: Result := RGB(234, 128, 40);
    50: Result := RGB(37, 99, 235);
    60: Result := RGB(219, 39, 119);
    70: Result := RGB(202, 138, 4);
    80: Result := RGB(14, 165, 233);
  else
    Result := RGB(100, 116, 139);
  end;
end;

{ TNavToggleButton }

constructor TNavToggleButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 36;
  Height := 30;
  Cursor := crHandPoint;
  ShowHint := True;
end;

procedure TNavToggleButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FHot := True;
  Invalidate;
end;

procedure TNavToggleButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHot := False;
  Invalidate;
end;

procedure TNavToggleButton.Paint;
var
  R: TRect;
  LGlyph: string;
begin
  R := ClientRect;
  if FHot then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := BlendColor(clWhite, StyleServices.GetSystemColor(clBtnFace), 0.35);
    Canvas.FillRect(R);
  end;
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := IconFontName;
  Canvas.Font.Size := 13;
  Canvas.Font.Style := [];
  Canvas.Font.Color := StyleServices.GetSystemColor(clWindowText);
  LGlyph := ICON_MENU;
  DrawText(Canvas.Handle, PChar(LGlyph), Length(LGlyph), R, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX);
end;

{ TNavTreeView }

procedure TNavTreeView.CreateWnd;
begin
  inherited;
  TreeView_SetItemHeight(Handle, NAV_ITEM_HEIGHT);
end;

procedure TNavTreeView.SetHotNode(ANode: TTreeNode);
var
  R: TRect;
begin
  if ANode = FHotNode then
    Exit;
  if Assigned(FHotNode) then
  begin
    R := FHotNode.DisplayRect(False);
    InvalidateRect(Handle, @R, False);
  end;
  FHotNode := ANode;
  if Assigned(FHotNode) then
  begin
    R := FHotNode.DisplayRect(False);
    InvalidateRect(Handle, @R, False);
  end;
end;

procedure TNavTreeView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  HotNode := GetNodeAt(X, Y);
end;

// çift tık = iki tek tık: yerel ağaç çift tıkta klasörü kendisi açıp kapatmasın (tek tık zaten açıp kapatıyor)
procedure TNavTreeView.WMLButtonDblClk(var Message: TWMMouse);
begin
  Message.Msg := WM_LBUTTONDOWN;
  Dispatch(Message);
end;

procedure TNavTreeView.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  HotNode := nil;
end;

{ TNavMenuPanel }

constructor TNavMenuPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BevelOuter := bvNone;
  Caption := '';
  ShowCaption := False;
  Width := 290;
  FExpanded := TList<Integer>.Create;
  FExpanded.Add(KEY_FAVORITES);
  FExpanded.Add(KEY_RECENT);
  FTextFavorites := 'Favorites';
  FTextRecent := 'Recently Used';
  FTextAddFavorite := 'Add to Favorites';
  FTextRemoveFavorite := 'Remove from Favorites';
end;

// alt kontroller pencere tutamacı ister: panel bir forma yerleştirildikten sonra çağrılır
procedure TNavMenuPanel.CreateControls;
begin
  if Assigned(FTree) then
    Exit;

  FSearch := TSearchBox.Create(Self);
  FSearch.Parent := Self;
  FSearch.Align := alTop;
  FSearch.AlignWithMargins := True;
  FSearch.Margins.SetBounds(8, 8, 8, 6);
  FSearch.Height := 26;
  FSearch.Font.Name := 'Segoe UI';
  FSearch.Font.Size := 10;
  FSearch.OnChange := SearchChange;
  FSearch.OnKeyDown := SearchKeyDown;
  FSearch.OnKeyPress := SearchKeyPress;

  FEmpty := TLabel.Create(Self);
  FEmpty.Parent := Self;
  FEmpty.Align := alTop;
  FEmpty.AlignWithMargins := True;
  FEmpty.Margins.SetBounds(14, 8, 8, 0);
  FEmpty.Font.Color := clGrayText;
  FEmpty.Visible := False;
  FEmpty.Top := 100;

  FTree := TNavTreeView.Create(Self);
  FTree.Parent := Self;
  FTree.Align := alClient;
  FTree.BorderStyle := bsNone;
  FTree.ReadOnly := True;
  FTree.ShowLines := False;
  FTree.ShowButtons := False;
  FTree.ShowRoot := False;
  FTree.RowSelect := True;
  FTree.HideSelection := False;
  FTree.ToolTips := False;
  FTree.Indent := NAV_INDENT;
  FTree.DoubleBuffered := True;
  FTree.Font.Name := 'Segoe UI';
  FTree.Font.Size := 9;
  FTree.OnAdvancedCustomDrawItem := TreeCustomDrawItem;
  FTree.OnClick := TreeClick;
  FTree.OnKeyDown := TreeKeyDown;
  FTree.OnKeyPress := TreeKeyPress;
  FTree.OnExpanded := TreeExpandedChange;
  FTree.OnCollapsed := TreeExpandedChange;
  FTree.RightClickSelect := True;

  FPopup := TPopupMenu.Create(Self);
  FPopup.OnPopup := PopupShow;
  FMniFavorite := TMenuItem.Create(FPopup);
  FMniFavorite.ShortCut := TextToShortCut('Ctrl+D');
  FMniFavorite.OnClick := MniFavoriteClick;
  FPopup.Items.Add(FMniFavorite);
  FTree.PopupMenu := FPopup;
end;

destructor TNavMenuPanel.Destroy;
begin
  FExpanded.Free;
  inherited;
end;

procedure TNavMenuPanel.ApplyTexts(const ASearchHint, AEmptyText, AFavorites, ARecent, AAddFavorite,
  ARemoveFavorite: string);
var
  LNode: TTreeNode;
begin
  FSearch.TextHint := ASearchHint;
  FEmpty.Caption := AEmptyText;
  FTextFavorites := AFavorites;
  FTextRecent := ARecent;
  FTextAddFavorite := AAddFavorite;
  FTextRemoveFavorite := ARemoveFavorite;
  LNode := FTree.Items.GetFirstNode;
  while Assigned(LNode) do
  begin
    if NativeInt(LNode.Data) = DATA_FAVORITES then
      LNode.Text := FTextFavorites
    else if NativeInt(LNode.Data) = DATA_RECENT then
      LNode.Text := FTextRecent;
    LNode := LNode.getNextSibling;
  end;
end;

procedure TNavMenuPanel.SetItems(const AItems: TArray<TSysMenuItem>);
var
  I, LParent: Integer;
begin
  RememberExpanded;
  FItems := AItems;
  // aranan metin: kod + ad + anahtar kelimeler + üst klasör adları (klasör adıyla aranınca içi gelir);
  // IsActive servisten etkin değer olarak gelir (pasif klasörün altındakiler de pasif)
  SetLength(FHaystack, Length(FItems));
  SetLength(FPaths, Length(FItems));
  for I := 0 to High(FItems) do
  begin
    FHaystack[I] := FItems[I].CodeText + ' ' + FItems[I].MenuName + ' ' + FItems[I].Keywords;
    FPaths[I] := '';
    LParent := FindItem(FItems[I].ParentCode);
    while LParent >= 0 do
    begin
      FHaystack[I] := FHaystack[I] + ' ' + FItems[LParent].MenuName;
      if FPaths[I] = '' then
        FPaths[I] := FItems[LParent].MenuName
      else
        FPaths[I] := FItems[LParent].MenuName + ' > ' + FPaths[I];
      LParent := FindItem(FItems[LParent].ParentCode);
    end;
    FHaystack[I] := ' ' + NavNormalize(FHaystack[I]);
  end;
  Rebuild;
end;

function TNavMenuPanel.IsVisibleScreen(AIndex: Integer): Boolean;
begin
  Result := not FItems[AIndex].IsFolder and FItems[AIndex].Allowed and FItems[AIndex].IsActive;
end;

function TNavMenuPanel.PathOf(AMenuCode: Integer): string;
var
  I: Integer;
begin
  I := FindItem(AMenuCode);
  if I >= 0 then
    Result := FPaths[I]
  else
    Result := '';
end;

function TNavMenuPanel.Search(const AQuery: string; AMax: Integer): TArray<TSysMenuItem>;
var
  LTokens: TArray<string>;
  LDigits: Boolean;
  LList: TList<Integer>;
  I: Integer;
begin
  Result := [];
  LTokens := NavNormalize(Trim(AQuery)).Split([' '], TStringSplitOptions.ExcludeEmpty);
  LDigits := IsAllDigits(Trim(AQuery));
  LList := TList<Integer>.Create;
  try
    for I := 0 to High(FItems) do
      if IsVisibleScreen(I) then
        if (Length(LTokens) > 0) and Matches(I, LTokens, LDigits) then
          LList.Add(I)
        else if (Length(LTokens) = 0) and (FItems[I].IsFavorite or (FItems[I].LastOpenedAt > 0)) then
          LList.Add(I);
    LList.Sort(TComparer<Integer>.Construct(
      function(const A, B: Integer): Integer
      begin
        Result := Ord(FItems[B].IsFavorite) - Ord(FItems[A].IsFavorite);
        if (Result = 0) and (Length(LTokens) = 0) then
          Result := CompareValue(FItems[B].LastOpenedAt, FItems[A].LastOpenedAt);
        if Result = 0 then
          Result := FItems[B].OpenCount - FItems[A].OpenCount;
        if Result = 0 then
          Result := FItems[A].MenuCode - FItems[B].MenuCode;
      end));
    for I := 0 to Min(LList.Count, AMax) - 1 do
      Result := Result + [FItems[LList[I]]];
  finally
    LList.Free;
  end;
end;

function TNavMenuPanel.GetExpandedKeys: TArray<Integer>;
begin
  RememberExpanded;
  Result := FExpanded.ToArray;
end;

procedure TNavMenuPanel.SetExpandedKeys(const AValue: TArray<Integer>);
begin
  FExpanded.Clear;
  FExpanded.AddRange(AValue);
  if Length(FItems) > 0 then
    Rebuild;
end;

function TNavMenuPanel.FindItem(ACode: Integer): Integer;
var
  I: Integer;
begin
  if ACode > 0 then
    for I := 0 to High(FItems) do
      if FItems[I].MenuCode = ACode then
        Exit(I);
  Result := -1;
end;

function TNavMenuPanel.ItemIndexOf(ANode: TTreeNode): Integer;
begin
  if Assigned(ANode) and (NativeInt(ANode.Data) > 0) then
    Result := NativeInt(ANode.Data) - 1
  else
    Result := -1;
end;

function TNavMenuPanel.IsShortcutFolder(ANode: TTreeNode): Boolean;
begin
  Result := Assigned(ANode) and (NativeInt(ANode.Data) < 0);
end;

function TNavMenuPanel.IsShortcutNode(ANode: TTreeNode): Boolean;
begin
  Result := Assigned(ANode) and Assigned(ANode.Parent) and IsShortcutFolder(ANode.Parent);
end;

// ekran / klasör: menü kodu; kısayol klasörü: KEY_FAVORITES / KEY_RECENT
function TNavMenuPanel.NodeKey(ANode: TTreeNode): Integer;
begin
  Result := 0;
  if not Assigned(ANode) then
    Exit;
  case NativeInt(ANode.Data) of
    DATA_FAVORITES: Result := KEY_FAVORITES;
    DATA_RECENT:    Result := KEY_RECENT;
  else
    if ItemIndexOf(ANode) >= 0 then
      Result := FItems[ItemIndexOf(ANode)].MenuCode;
  end;
end;

function TNavMenuPanel.RootKey(ANode: TTreeNode): Integer;
begin
  Result := 0;
  if not Assigned(ANode) then
    Exit;
  while Assigned(ANode.Parent) do
    ANode := ANode.Parent;
  Result := NodeKey(ANode);
end;

// aynı ekran hem modül altında hem kısayol klasöründe olabilir: kök anahtarı ile ayırt edilir (-1 = herhangi)
function TNavMenuPanel.FindNodeByKey(AKey, ARootKey: Integer): TTreeNode;
begin
  Result := FTree.Items.GetFirstNode;
  while Assigned(Result) do
  begin
    if (NodeKey(Result) = AKey) and ((ARootKey < 0) or (RootKey(Result) = ARootKey)) then
      Exit;
    Result := Result.GetNext;
  end;
end;

function TNavMenuPanel.Matches(AIndex: Integer; const ATokens: TArray<string>; ADigits: Boolean): Boolean;
var
  LToken: string;
begin
  if Length(ATokens) = 0 then
    Exit(True);
  if ADigits then
    Exit(FItems[AIndex].CodeText.StartsWith(ATokens[0]));
  for LToken in ATokens do
    if Pos(LToken, FHaystack[AIndex]) = 0 then
      Exit(False);
  Result := True;
end;

procedure TNavMenuPanel.RememberExpanded;
var
  LNode: TTreeNode;
begin
  // arama sırasında açılan klasörler kalıcı durumu bozmasın
  if (FFilter <> '') or (FTree.Items.Count = 0) then
    Exit;
  FExpanded.Clear;
  LNode := FTree.Items.GetFirstNode;
  while Assigned(LNode) do
  begin
    if LNode.Expanded and (NodeKey(LNode) <> 0) then
      FExpanded.Add(NodeKey(LNode));
    LNode := LNode.GetNext;
  end;
  // kısayol klasörü o an yoksa (favori yok) açık / kapalı tercihi korunur
  if not Assigned(FindNodeByKey(KEY_FAVORITES, KEY_FAVORITES)) and not FExpanded.Contains(KEY_FAVORITES) then
    FExpanded.Add(KEY_FAVORITES);
  if not Assigned(FindNodeByKey(KEY_RECENT, KEY_RECENT)) and not FExpanded.Contains(KEY_RECENT) then
    FExpanded.Add(KEY_RECENT);
end;

procedure TNavMenuPanel.Rebuild;
var
  LTokens: TArray<string>;
  LDigits: Boolean;
  LNodes: TDictionary<Integer, TTreeNode>;
  I: Integer;
  LNode, LSelected, LFolder: TTreeNode;
  LRecent: TList<Integer>;

  function EnsureNode(AIndex: Integer): TTreeNode;
  var
    LParent: TTreeNode;
    LParentIndex: Integer;
  begin
    if LNodes.TryGetValue(FItems[AIndex].MenuCode, Result) then
      Exit;
    LParent := nil;
    LParentIndex := FindItem(FItems[AIndex].ParentCode);
    if LParentIndex >= 0 then
      LParent := EnsureNode(LParentIndex);
    Result := FTree.Items.AddChildObject(LParent, FItems[AIndex].MenuName, Pointer(NativeInt(AIndex + 1)));
    LNodes.Add(FItems[AIndex].MenuCode, Result);
  end;

begin
  LTokens := NavNormalize(Trim(FFilter)).Split([' '], TStringSplitOptions.ExcludeEmpty);
  LDigits := IsAllDigits(Trim(FFilter));

  FUpdating := True;
  LNodes := TDictionary<Integer, TTreeNode>.Create;
  FTree.Items.BeginUpdate;
  try
    FTree.HotNode := nil;
    FTree.Items.Clear;

    // kısayol klasörleri yalnız arama boşken
    if FFilter = '' then
    begin
      LFolder := nil;
      for I := 0 to High(FItems) do
        if FItems[I].IsFavorite and IsVisibleScreen(I) then
        begin
          if LFolder = nil then
            LFolder := FTree.Items.AddChildObject(nil, FTextFavorites, Pointer(NativeInt(DATA_FAVORITES)));
          FTree.Items.AddChildObject(LFolder, FItems[I].MenuName, Pointer(NativeInt(I + 1)));
        end;

      LRecent := TList<Integer>.Create;
      try
        for I := 0 to High(FItems) do
          if (FItems[I].LastOpenedAt > 0) and IsVisibleScreen(I) then
            LRecent.Add(I);
        LRecent.Sort(TComparer<Integer>.Construct(
          function(const A, B: Integer): Integer
          begin
            Result := CompareValue(FItems[B].LastOpenedAt, FItems[A].LastOpenedAt);
            if Result = 0 then
              Result := FItems[B].OpenCount - FItems[A].OpenCount;
          end));
        if LRecent.Count > 0 then
        begin
          LFolder := FTree.Items.AddChildObject(nil, FTextRecent, Pointer(NativeInt(DATA_RECENT)));
          for I := 0 to Min(LRecent.Count, NAV_RECENT_COUNT) - 1 do
            FTree.Items.AddChildObject(LFolder, FItems[LRecent[I]].MenuName, Pointer(NativeInt(LRecent[I] + 1)));
        end;
      finally
        LRecent.Free;
      end;
    end;

    for I := 0 to High(FItems) do
      if IsVisibleScreen(I) and Matches(I, LTokens, LDigits) then
        EnsureNode(I);

    LNode := FTree.Items.GetFirstNode;
    while Assigned(LNode) do
    begin
      if LNode.HasChildren then
        LNode.Expanded := (FFilter <> '') or FExpanded.Contains(NodeKey(LNode));
      LNode := LNode.GetNext;
    end;

    LSelected := nil;
    if FFilter <> '' then
      LSelected := FirstScreenNode;
    FTree.Selected := LSelected;
  finally
    FTree.Items.EndUpdate;
    LNodes.Free;
    FUpdating := False;
  end;

  FEmpty.Visible := (FTree.Items.Count = 0) and (FFilter <> '');
  if Assigned(FTree.Selected) then
    FTree.Selected.MakeVisible
  else if FTree.Items.Count > 0 then
    FTree.TopItem := FTree.Items.GetFirstNode;
end;

procedure TNavMenuPanel.RebuildKeepingPosition;
var
  LSelKey, LSelRoot, LTopKey, LTopRoot: Integer;
  LNode: TTreeNode;
begin
  RememberExpanded;
  LSelKey := NodeKey(FTree.Selected);
  LSelRoot := RootKey(FTree.Selected);
  LTopKey := NodeKey(FTree.TopItem);
  LTopRoot := RootKey(FTree.TopItem);
  Rebuild;
  if LTopKey <> 0 then
  begin
    LNode := FindNodeByKey(LTopKey, LTopRoot);
    if Assigned(LNode) then
      FTree.TopItem := LNode;
  end;
  if LSelKey <> 0 then
  begin
    LNode := FindNodeByKey(LSelKey, LSelRoot);
    if not Assigned(LNode) then
      LNode := FindNodeByKey(LSelKey, -1);
    if Assigned(LNode) then
      FTree.Selected := LNode;
  end;
end;

procedure TNavMenuPanel.SetFavorite(AMenuCode: Integer; AValue: Boolean);
var
  I: Integer;
begin
  I := FindItem(AMenuCode);
  if I < 0 then
    Exit;
  FItems[I].IsFavorite := AValue;
  RebuildKeepingPosition;
end;

procedure TNavMenuPanel.MarkOpened(AMenuCode: Integer);
var
  I: Integer;
begin
  I := FindItem(AMenuCode);
  if I < 0 then
    Exit;
  FItems[I].LastOpenedAt := Now;
  FItems[I].OpenCount := FItems[I].OpenCount + 1;
  RebuildKeepingPosition;
end;

procedure TNavMenuPanel.ToggleFavorite(ANode: TTreeNode);
var
  LIndex: Integer;
begin
  LIndex := ItemIndexOf(ANode);
  if (LIndex < 0) or FItems[LIndex].IsFolder or not Assigned(FOnToggleFavorite) then
    Exit;
  FOnToggleFavorite(FItems[LIndex], not FItems[LIndex].IsFavorite);
end;

procedure TNavMenuPanel.PopupShow(Sender: TObject);
var
  LIndex: Integer;
begin
  LIndex := ItemIndexOf(FTree.Selected);
  FMniFavorite.Enabled := (LIndex >= 0) and not FItems[LIndex].IsFolder;
  if FMniFavorite.Enabled and FItems[LIndex].IsFavorite then
    FMniFavorite.Caption := FTextRemoveFavorite
  else
    FMniFavorite.Caption := FTextAddFavorite;
end;

procedure TNavMenuPanel.MniFavoriteClick(Sender: TObject);
begin
  ToggleFavorite(FTree.Selected);
end;

function TNavMenuPanel.FirstScreenNode: TTreeNode;
begin
  Result := FTree.Items.GetFirstNode;
  while Assigned(Result) and Result.HasChildren do
    Result := Result.GetNext;
end;

procedure TNavMenuPanel.OpenNode(ANode: TTreeNode);
var
  LIndex: Integer;
begin
  if IsShortcutFolder(ANode) then
  begin
    ANode.Expanded := not ANode.Expanded;
    Exit;
  end;
  LIndex := ItemIndexOf(ANode);
  if LIndex < 0 then
    Exit;
  if FItems[LIndex].IsFolder then
  begin
    ANode.Expanded := not ANode.Expanded;
    Exit;
  end;
  if Assigned(FOnOpenItem) then
    FOnOpenItem(FItems[LIndex]);
end;

procedure TNavMenuPanel.TreeExpandedChange(Sender: TObject; Node: TTreeNode);
begin
  if FUpdating or (FFilter <> '') then
    Exit;
  RememberExpanded;
end;

procedure TNavMenuPanel.SearchChange(Sender: TObject);
begin
  if FFilter = FSearch.Text then
    Exit;
  if FFilter = '' then
    RememberExpanded;
  FFilter := FSearch.Text;
  Rebuild;
end;

procedure TNavMenuPanel.SearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LNode: TTreeNode;
begin
  if Key = VK_DOWN then
  begin
    Key := 0;
    LNode := FTree.Selected;
    if not Assigned(LNode) then
      LNode := FTree.Items.GetFirstNode;
    if Assigned(LNode) then
    begin
      FTree.Selected := LNode;
      FTree.SetFocus;
    end;
  end;
end;

procedure TNavMenuPanel.SearchKeyPress(Sender: TObject; var Key: Char);
var
  LNode: TTreeNode;
begin
  if Key <> #13 then
    Exit;
  Key := #0;
  LNode := FTree.Selected;
  if not Assigned(LNode) or LNode.HasChildren then
    LNode := FirstScreenNode;
  if Assigned(LNode) then
    OpenNode(LNode);
end;

procedure TNavMenuPanel.TreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    OpenNode(FTree.Selected);
  end
  else if (Key = Ord('D')) and (Shift = [ssCtrl]) then
  begin
    Key := 0;
    ToggleFavorite(FTree.Selected);
  end
  else if (Key = VK_UP) and (FTree.Selected = FTree.Items.GetFirstNode) then
  begin
    Key := 0;
    FSearch.SetFocus;
  end;
end;

procedure TNavMenuPanel.TreeKeyPress(Sender: TObject; var Key: Char);
begin
  // Enter KeyDown'da işlendi; harf yazılırsa aramaya geç
  if Key = #13 then
    Key := #0
  else if (Key >= ' ') then
  begin
    FSearch.SetFocus;
    FSearch.Text := FSearch.Text + Key;
    FSearch.SelStart := Length(FSearch.Text);
    Key := #0;
  end;
end;

procedure TNavMenuPanel.TreeClick(Sender: TObject);
var
  P: TPoint;
  LNode: TTreeNode;
begin
  P := FTree.ScreenToClient(Mouse.CursorPos);
  LNode := FTree.GetNodeAt(P.X, P.Y);
  if Assigned(LNode) then
  begin
    FTree.Selected := LNode;
    OpenNode(LNode);
  end;
end;

procedure TNavMenuPanel.TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  C: TCanvas;
  R, TR: TRect;
  LIndex, X: Integer;
  LItem: TSysMenuItem;
  LBack, LText, LGray, LSel: TColor;
  LSelected, LShortcut, LFolder: Boolean;
  LCode, LIcon: string;
begin
  if Stage <> cdPrePaint then
    Exit;
  LShortcut := IsShortcutFolder(Node);
  LIndex := ItemIndexOf(Node);
  if (LIndex < 0) and not LShortcut then
    Exit;
  DefaultDraw := False;
  PaintImages := False;
  if LShortcut then
  begin
    // kısayol klasörü modül gibi çizilir
    LItem := Default(TSysMenuItem);
    LItem.MenuCode := 0;
    if NativeInt(Node.Data) = DATA_FAVORITES then
      LItem.MenuName := FTextFavorites
    else
      LItem.MenuName := FTextRecent;
  end
  else
    LItem := FItems[LIndex];

  C := Sender.Canvas;
  R := Node.DisplayRect(False);
  LBack := StyleServices.GetSystemColor(clWindow);
  LText := StyleServices.GetSystemColor(clWindowText);
  LSel := StyleServices.GetSystemColor(clHighlight);
  LGray := BlendColor(LText, LBack, 0.55);
  LSelected := Node.Selected;
  LFolder := LShortcut or LItem.IsFolder;

  C.Brush.Style := bsSolid;
  C.Brush.Color := LBack;
  C.FillRect(R);
  if LSelected or (Node = FTree.HotNode) then
  begin
    if LSelected then
      C.Brush.Color := BlendColor(LSel, LBack, 0.22)
    else
      C.Brush.Color := BlendColor(LSel, LBack, 0.10);
    TR := R;
    InflateRect(TR, -4, -1);
    C.FillRect(TR);
    if LSelected and not LFolder then
    begin
      C.Brush.Color := LSel;
      C.FillRect(Rect(TR.Left, TR.Top + 4, TR.Left + 3, TR.Bottom - 4));
    end;
  end;
  C.Brush.Style := bsClear;

  X := R.Left + 10 + Node.Level * NAV_INDENT;
  if LShortcut then
  begin
    C.Font.Name := IconFontName;
    C.Font.Size := 11;
    C.Font.Style := [];
    if NativeInt(Node.Data) = DATA_FAVORITES then
    begin
      C.Font.Color := STAR_COLOR;
      LIcon := ICON_STAR;
    end
    else
    begin
      C.Font.Color := RGB(100, 116, 139);
      LIcon := ICON_HISTORY;
    end;
    TR := Rect(X, R.Top, X + 22, R.Bottom);
    DrawText(C.Handle, PChar(LIcon), 1, TR, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX);
    Inc(X, 28);
    C.Font.Name := 'Segoe UI';
    C.Font.Size := 10;
    C.Font.Style := [fsBold];
    C.Font.Color := LText;
  end
  else
  case LItem.Level of
    smlModule:
      begin
        C.Font.Name := IconFontName;
        C.Font.Size := 11;
        C.Font.Style := [];
        C.Font.Color := ModuleColor(LItem.MenuCode);
        TR := Rect(X, R.Top, X + 22, R.Bottom);
        DrawText(C.Handle, PChar(ModuleIcon(LItem.MenuCode)), 1, TR, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX);
        Inc(X, 28);
        C.Font.Name := 'Segoe UI';
        C.Font.Size := 10;
        C.Font.Style := [fsBold];
        C.Font.Color := LText;
      end;
    smlGroup:
      begin
        C.Font.Name := 'Segoe UI';
        C.Font.Size := 9;
        C.Font.Style := [fsBold];
        C.Font.Color := LGray;
      end;
  else
    begin
      C.Font.Name := 'Consolas';
      C.Font.Size := 9;
      C.Font.Style := [];
      C.Font.Color := LGray;
      LCode := LItem.CodeText;
      TR := Rect(X, R.Top, X + 56, R.Bottom);
      DrawText(C.Handle, PChar(LCode), Length(LCode), TR, DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_NOPREFIX);
      Inc(X, 56);
      C.Font.Name := 'Segoe UI';
      C.Font.Size := 9;
      if LSelected then
        C.Font.Style := [fsBold]
      else
        C.Font.Style := [];
      C.Font.Color := LText;
    end;
  end;

  // klasörde sağda açık / kapalı oku, favori ekranda yıldız
  if LFolder or LItem.IsFavorite then
    TR := Rect(X, R.Top, R.Right - 26, R.Bottom)
  else
    TR := Rect(X, R.Top, R.Right - 6, R.Bottom);
  DrawText(C.Handle, PChar(LItem.MenuName), Length(LItem.MenuName), TR,
    DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_NOPREFIX or DT_END_ELLIPSIS);

  if not LFolder and LItem.IsFavorite then
  begin
    C.Font.Name := IconFontName;
    C.Font.Size := 8;
    C.Font.Style := [];
    C.Font.Color := STAR_COLOR;
    TR := Rect(R.Right - 26, R.Top, R.Right - 8, R.Bottom);
    LIcon := ICON_STAR;
    DrawText(C.Handle, PChar(LIcon), 1, TR, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX);
  end;

  if LFolder then
  begin
    C.Font.Name := IconFontName;
    C.Font.Size := 8;
    C.Font.Style := [];
    C.Font.Color := LGray;
    TR := Rect(R.Right - 26, R.Top, R.Right - 8, R.Bottom);
    if Node.Expanded then
      DrawText(C.Handle, PChar(string(ICON_CHEVRON_DOWN)), 1, TR, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX)
    else
      DrawText(C.Handle, PChar(string(ICON_CHEVRON_RIGHT)), 1, TR, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX);
  end;
end;

procedure TNavMenuPanel.FocusSearch;
begin
  if FSearch.CanFocus then
  begin
    FSearch.SetFocus;
    FSearch.SelectAll;
  end;
end;

function TNavMenuPanel.HandleEscape: Boolean;
begin
  Result := ContainsFocus;
  if Result and (FSearch.Text <> '') then
    FSearch.Text := '';
end;

function TNavMenuPanel.ContainsFocus: Boolean;
begin
  Result := FSearch.Focused or FTree.Focused;
end;

{ TNavCommandPalette }

const
  PALETTE_MAX = 60;

constructor TNavCommandPalette.CreatePalette(AOwner: TComponent; ANav: TNavMenuPanel; const AHint, AEmptyText: string);
var
  LFrame: TPanel;
begin
  inherited CreateNew(AOwner);
  FNav := ANav;
  BorderStyle := bsNone;
  Position := poDesigned;
  Width := 660;
  Height := 430;
  KeyPreview := True;
  OnDeactivate := FormDeactivate;

  // 1 px çerçeve
  LFrame := TPanel.Create(Self);
  LFrame.Parent := Self;
  LFrame.Align := alClient;
  LFrame.BevelOuter := bvNone;
  LFrame.BorderWidth := 1;
  LFrame.ParentBackground := False;
  LFrame.Color := StyleServices.GetSystemColor(clHighlight);

  FSearch := TSearchBox.Create(Self);
  FSearch.Parent := LFrame;
  FSearch.Align := alTop;
  FSearch.AlignWithMargins := True;
  FSearch.Margins.SetBounds(10, 10, 10, 8);
  FSearch.Font.Name := 'Segoe UI';
  FSearch.Font.Size := 12;
  FSearch.TextHint := AHint;
  FSearch.OnChange := SearchChange;
  FSearch.OnKeyDown := SearchKeyDown;
  FSearch.OnKeyPress := SearchKeyPress;

  FEmpty := TLabel.Create(Self);
  FEmpty.Parent := LFrame;
  FEmpty.Align := alTop;
  FEmpty.AlignWithMargins := True;
  FEmpty.Margins.SetBounds(14, 6, 10, 0);
  FEmpty.Font.Color := clGrayText;
  FEmpty.Caption := AEmptyText;
  FEmpty.Visible := False;
  FEmpty.Top := 200;

  FList := TListBox.Create(Self);
  FList.Parent := LFrame;
  FList.Align := alClient;
  FList.BorderStyle := bsNone;
  FList.Style := lbOwnerDrawFixed;
  FList.ItemHeight := 34;
  FList.OnDrawItem := ListDrawItem;
  FList.OnDblClick := ListDblClick;
  FList.TabStop := False;

  // sahip formun üst ortası
  if (AOwner is TCustomForm) and TCustomForm(AOwner).Visible then
  begin
    Left := TCustomForm(AOwner).Left + (TCustomForm(AOwner).Width - Width) div 2;
    Top := TCustomForm(AOwner).Top + 60;
  end
  else
  begin
    Left := (Screen.WorkAreaWidth - Width) div 2;
    Top := Screen.WorkAreaHeight div 6;
  end;
  ActiveControl := FSearch;
  Refresh;
end;

class function TNavCommandPalette.Execute(AOwner: TComponent; ANav: TNavMenuPanel; const AHint, AEmptyText: string;
  out AItem: TSysMenuItem): Boolean;
var
  LForm: TNavCommandPalette;
begin
  LForm := TNavCommandPalette.CreatePalette(AOwner, ANav, AHint, AEmptyText);
  try
    Result := (LForm.ShowModal = mrOk) and LForm.Selected(AItem);
  finally
    LForm.Free;
  end;
end;

function TNavCommandPalette.Selected(out AItem: TSysMenuItem): Boolean;
begin
  Result := (FList.ItemIndex >= 0) and (FList.ItemIndex <= High(FResults));
  if Result then
    AItem := FResults[FList.ItemIndex];
end;

procedure TNavCommandPalette.Refresh;
var
  I: Integer;
begin
  FResults := FNav.Search(FSearch.Text, PALETTE_MAX);
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for I := 0 to High(FResults) do
      FList.Items.Add(FResults[I].MenuName);
  finally
    FList.Items.EndUpdate;
  end;
  if FList.Count > 0 then
    FList.ItemIndex := 0;
  FEmpty.Visible := (FList.Count = 0) and (Trim(FSearch.Text) <> '');
end;

procedure TNavCommandPalette.SearchChange(Sender: TObject);
begin
  Refresh;
end;

procedure TNavCommandPalette.SearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_DOWN:
      begin
        if FList.ItemIndex < FList.Count - 1 then
          FList.ItemIndex := FList.ItemIndex + 1;
        Key := 0;
      end;
    VK_UP:
      begin
        if FList.ItemIndex > 0 then
          FList.ItemIndex := FList.ItemIndex - 1;
        Key := 0;
      end;
    VK_NEXT:
      begin
        FList.ItemIndex := Min(FList.Count - 1, FList.ItemIndex + 8);
        Key := 0;
      end;
    VK_PRIOR:
      begin
        FList.ItemIndex := Max(0, FList.ItemIndex - 8);
        Key := 0;
      end;
  end;
end;

procedure TNavCommandPalette.SearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Accept;
  end
  else if Key = #27 then
  begin
    Key := #0;
    ModalResult := mrCancel;
  end;
end;

procedure TNavCommandPalette.Accept;
begin
  if (FList.ItemIndex >= 0) and (FList.ItemIndex <= High(FResults)) then
    ModalResult := mrOk;
end;

procedure TNavCommandPalette.ListDblClick(Sender: TObject);
begin
  Accept;
end;

procedure TNavCommandPalette.FormDeactivate(Sender: TObject);
begin
  if ModalResult = mrNone then
    ModalResult := mrCancel;
end;

procedure TNavCommandPalette.ListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  C: TCanvas;
  LItem: TSysMenuItem;
  LBack, LText, LGray, LSel: TColor;
  R: TRect;
  S: string;
  X: Integer;
begin
  if (Index < 0) or (Index > High(FResults)) then
    Exit;
  LItem := FResults[Index];
  C := FList.Canvas;
  LBack := StyleServices.GetSystemColor(clWindow);
  LText := StyleServices.GetSystemColor(clWindowText);
  LSel := StyleServices.GetSystemColor(clHighlight);
  LGray := BlendColor(LText, LBack, 0.55);

  C.Brush.Style := bsSolid;
  C.Brush.Color := LBack;
  C.FillRect(Rect);
  if odSelected in State then
  begin
    C.Brush.Color := BlendColor(LSel, LBack, 0.22);
    R := Rect;
    InflateRect(R, -6, -2);
    C.FillRect(R);
    C.Brush.Color := LSel;
    C.FillRect(System.Types.Rect(R.Left, R.Top + 6, R.Left + 3, R.Bottom - 6));
  end;
  C.Brush.Style := bsClear;

  X := Rect.Left + 18;
  C.Font.Name := 'Consolas';
  C.Font.Size := 10;
  C.Font.Style := [];
  C.Font.Color := LGray;
  S := LItem.CodeText;
  R := System.Types.Rect(X, Rect.Top, X + 70, Rect.Bottom);
  DrawText(C.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_NOPREFIX);
  Inc(X, 70);

  // sağda yol (Finans > Çek / Senet) + favori yıldızı
  S := FNav.PathOf(LItem.MenuCode);
  C.Font.Name := 'Segoe UI';
  C.Font.Size := 9;
  C.Font.Color := LGray;
  R := System.Types.Rect(Rect.Right - 250, Rect.Top, Rect.Right - 34, Rect.Bottom);
  DrawText(C.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_VCENTER or DT_RIGHT or DT_NOPREFIX or DT_END_ELLIPSIS);
  if LItem.IsFavorite then
  begin
    C.Font.Name := IconFontName;
    C.Font.Size := 9;
    C.Font.Color := STAR_COLOR;
    S := ICON_STAR;
    R := System.Types.Rect(Rect.Right - 30, Rect.Top, Rect.Right - 10, Rect.Bottom);
    DrawText(C.Handle, PChar(S), 1, R, DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX);
  end;

  C.Font.Name := 'Segoe UI';
  C.Font.Size := 11;
  C.Font.Style := [fsBold];
  C.Font.Color := LText;
  S := LItem.MenuName;
  R := System.Types.Rect(X, Rect.Top, Rect.Right - 256, Rect.Bottom);
  DrawText(C.Handle, PChar(S), Length(S), R, DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_NOPREFIX or DT_END_ELLIPSIS);
end;

end.
