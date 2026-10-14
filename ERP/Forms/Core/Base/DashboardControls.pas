unit DashboardControls;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  SysDashboard;

const
  DASH_BACKGROUND = $00F8F5F3;   // RGB(243, 245, 248)

  // Segoe Fluent Icons / Segoe MDL2 Assets kod noktaları
  ICON_EXCHANGE  = #$E8AB;
  ICON_CARD      = #$E8C7;
  ICON_BANK      = #$E825;
  ICON_CYCLE     = #$E8EE;
  ICON_DOCUMENT  = #$E8A5;
  ICON_PAGE      = #$E7C3;
  ICON_CART      = #$E7BF;
  ICON_BAG       = #$E719;
  ICON_BOX       = #$E7B8;
  ICON_LIBRARY   = #$E8F1;
  ICON_PEOPLE    = #$E716;
  ICON_PERSON    = #$E77B;
  ICON_WARNING   = #$E7BA;
  ICON_TERMINAL  = #$E1D0;
  ICON_CHART     = #$E9D2;
  ICON_TREND_UP  = #$EAFC;
  ICON_PIE       = #$EB05;
  ICON_KEY       = #$E8D7;
  ICON_HOME      = #$E80F;
  ICON_TAG       = #$E8EC;
  ICON_LIST      = #$E8FD;
  ICON_REPORT    = #$E9F9;
  ICON_INOUT     = #$E8CB;
  ICON_CASH      = #$EC59;
  ICON_CALENDAR  = #$E787;

type
  // Ortak temel: çift tamponlu GDI+ çizim, fareyle üzerine gelme, tıklanabilirlik
  TDashPaintControl = class(TGraphicControl)
  private
    FHover: Boolean;
    FClickable: Boolean;
    procedure SetClickable(const Value: Boolean);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure DoPaint(G: TGPGraphics; W, H: Single); virtual; abstract;
    procedure DrawCard(G: TGPGraphics; W, H: Single; ABorder: TColor);
    procedure MouseLeft; virtual;
    property Hover: Boolean read FHover;
  public
    constructor Create(AOwner: TComponent); override;
    property Clickable: Boolean read FClickable write SetClickable;
  published
    property OnClick;
  end;

  // Üst karşılama bandı: selam + tarih + durum etiketleri
  TDashChip = record
    Text: string;
    Color: TColor;
  end;

  TDashWelcome = class(TDashPaintControl)
  private
    FGreeting: string;
    FDateText: string;
    FChips: TArray<TDashChip>;
  protected
    procedure DoPaint(G: TGPGraphics; W, H: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetData(const AGreeting, ADateText: string; const AChips: TArray<TDashChip>);
  end;

  // Bölüm başlığı: ikon + başlık + ince çizgi
  TDashSection = class(TDashPaintControl)
  private
    FTitle: string;
    FIcon: string;
    FAccent: TColor;
  protected
    procedure DoPaint(G: TGPGraphics; W, H: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetData(const ATitle, AIcon: string; AAccent: TColor);
  end;

  TDashTileData = record
    Title: string;
    ValueText: string;     // çok satırlı olabilir (sLineBreak)
    Detail: string;
    Icon: string;
    Accent: TColor;        // bölüm rengi (ikon, grafik)
    Badge: string;         // boş = etiket yok
    BadgeColor: TColor;
    ValueColor: TColor;
    Ratio: Double;         // < 0 = çubuk yok
    RatioText: string;
    Trend: TArray<TDashboardPoint>;
  end;

  // Gösterge kartı
  TDashTile = class(TDashPaintControl)
  private
    FData: TDashTileData;
  protected
    procedure DoPaint(G: TGPGraphics; W, H: Single); override;
  public
    procedure SetData(const AData: TDashTileData);
    property Data: TDashTileData read FData;
  end;

  TDashChartKind = (dckColumns, dckLines);

  TDashChartData = record
    Title: string;
    Subtitle: string;
    Kind: TDashChartKind;
    Series1: string;
    Series2: string;       // boş = tek seri
    Color1: TColor;
    Color2: TColor;
    DateFormat: string;    // x ekseni etiketi
    ValueFormat: string;   // ipucu değeri
    EmptyText: string;
    Points: TArray<TDashboardPoint>;
  end;

  // Genel bakış grafiği (sütun / çizgi); fareyle üzerine gelince değer balonu
  TDashChart = class(TDashPaintControl)
  private
    FData: TDashChartData;
    FHoverIndex: Integer;
    FPlot: TRectF;
    function HasData: Boolean;
    function IndexAt(X: Integer): Integer;
  protected
    procedure DoPaint(G: TGPGraphics; W, H: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeft; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetData(const AData: TDashChartData);
    property Data: TDashChartData read FData;
  end;

function IconFontName: string;
function BlendColor(AColor1, AColor2: TColor; AWeight1: Double): TColor;

implementation

const
  TEXT_FONT = 'Segoe UI';
  CLR_CARD = clWhite;
  CLR_BORDER = $00EBE6E2;      // RGB(226, 230, 235)
  CLR_TEXT = $00372A1F;        // RGB(31, 42, 55)
  CLR_TEXT_MUTED = $00807266;  // RGB(102, 114, 128)
  CLR_GRID = $00F3F0EE;        // RGB(238, 240, 243)
  CLR_TRACK = $00F2EDE9;       // RGB(233, 237, 242)
  CARD_RADIUS = 10;
  PAD = 16;

var
  GIconFont: string;

function IconFontName: string;
begin
  if GIconFont = '' then
  begin
    if Screen.Fonts.IndexOf('Segoe Fluent Icons') >= 0 then
      GIconFont := 'Segoe Fluent Icons'
    else
      GIconFont := 'Segoe MDL2 Assets';
  end;
  Result := GIconFont;
end;

function GpColor(AColor: TColor; AAlpha: Byte = 255): ARGB;
var
  C: Longint;
begin
  C := ColorToRGB(AColor);
  Result := MakeColor(AAlpha, GetRValue(C), GetGValue(C), GetBValue(C));
end;

function BlendColor(AColor1, AColor2: TColor; AWeight1: Double): TColor;
var
  C1, C2: Longint;
begin
  C1 := ColorToRGB(AColor1);
  C2 := ColorToRGB(AColor2);
  Result := RGB(Round(GetRValue(C1) * AWeight1 + GetRValue(C2) * (1 - AWeight1)),
                Round(GetGValue(C1) * AWeight1 + GetGValue(C2) * (1 - AWeight1)),
                Round(GetBValue(C1) * AWeight1 + GetBValue(C2) * (1 - AWeight1)));
end;

function RoundRectPath(X, Y, W, H, R: Single): TGPGraphicsPath;
var
  D: Single;
begin
  Result := TGPGraphicsPath.Create;
  R := Min(R, Min(W, H) / 2);
  if R <= 0.5 then
  begin
    Result.AddRectangle(MakeRect(X, Y, W, H));
    Exit;
  end;
  D := R * 2;
  Result.AddArc(X, Y, D, D, 180, 90);
  Result.AddArc(X + W - D, Y, D, D, 270, 90);
  Result.AddArc(X + W - D, Y + H - D, D, D, 0, 90);
  Result.AddArc(X, Y + H - D, D, D, 90, 90);
  Result.CloseFigure;
end;

procedure FillRoundRect(G: TGPGraphics; X, Y, W, H, R: Single; AColor: ARGB);
var
  LPath: TGPGraphicsPath;
  LBrush: TGPSolidBrush;
begin
  if (W <= 0) or (H <= 0) then
    Exit;
  LPath := RoundRectPath(X, Y, W, H, R);
  LBrush := TGPSolidBrush.Create(AColor);
  try
    G.FillPath(LBrush, LPath);
  finally
    LBrush.Free;
    LPath.Free;
  end;
end;

procedure DrawRoundRect(G: TGPGraphics; X, Y, W, H, R: Single; AColor: ARGB; AWidth: Single);
var
  LPath: TGPGraphicsPath;
  LPen: TGPPen;
begin
  LPath := RoundRectPath(X, Y, W, H, R);
  LPen := TGPPen.Create(AColor, AWidth);
  try
    G.DrawPath(LPen, LPath);
  finally
    LPen.Free;
    LPath.Free;
  end;
end;

procedure DrawStr(G: TGPGraphics; const S, AFamily: string; ASize: Single; AStyle: Integer; AColor: ARGB;
  const R: TGPRectF; AHAlign: TStringAlignment = StringAlignmentNear;
  AVAlign: TStringAlignment = StringAlignmentNear; AWrap: Boolean = False);
var
  LFont: TGPFont;
  LBrush: TGPSolidBrush;
  LFormat: TGPStringFormat;
begin
  if (S = '') or (R.Width <= 0) or (R.Height <= 0) then
    Exit;
  LFont := TGPFont.Create(AFamily, ASize, AStyle, UnitPixel);
  LBrush := TGPSolidBrush.Create(AColor);
  LFormat := TGPStringFormat.Create;
  try
    LFormat.SetAlignment(AHAlign);
    LFormat.SetLineAlignment(AVAlign);
    LFormat.SetTrimming(StringTrimmingEllipsisCharacter);
    if not AWrap then
      LFormat.SetFormatFlags(StringFormatFlagsNoWrap);
    G.DrawString(S, Length(S), LFont, R, LFormat, LBrush);
  finally
    LFormat.Free;
    LBrush.Free;
    LFont.Free;
  end;
end;

function StrWidth(G: TGPGraphics; const S, AFamily: string; ASize: Single; AStyle: Integer): Single;
var
  LFont: TGPFont;
  LBox: TGPRectF;
begin
  Result := 0;
  if S = '' then
    Exit;
  LFont := TGPFont.Create(AFamily, ASize, AStyle, UnitPixel);
  try
    G.MeasureString(S, Length(S), LFont, MakePoint(0.0, 0.0), LBox);
    Result := LBox.Width;
  finally
    LFont.Free;
  end;
end;

procedure DrawIconCircle(G: TGPGraphics; X, Y, ASize: Single; const AIcon: string; AColor: TColor);
var
  LBrush: TGPSolidBrush;
begin
  LBrush := TGPSolidBrush.Create(GpColor(AColor, 30));
  try
    G.FillEllipse(LBrush, X, Y, ASize, ASize);
  finally
    LBrush.Free;
  end;
  DrawStr(G, AIcon, IconFontName, ASize * 0.45, FontStyleRegular, GpColor(AColor),
    MakeRect(X, Y + 1, ASize, ASize), StringAlignmentCenter, StringAlignmentCenter);
end;

// Eksen etiketi: 1.250 / 12,5K / 3,4M
function CompactNumber(AValue: Double): string;
var
  A: Double;
begin
  A := Abs(AValue);
  if A >= 1000000 then
    Result := FormatFloat('0.#', AValue / 1000000) + 'M'
  else if A >= 10000 then
    Result := FormatFloat('0.#', AValue / 1000) + 'K'
  else if (A > 0) and (A < 100) and (Frac(AValue) <> 0) then
    Result := FormatFloat('0.##', AValue)
  else
    Result := FormatFloat('#,##0', AValue);
end;

// Eksen için "yuvarlak" üst sınır (1 / 2 / 2,5 / 5 x 10^n)
function NiceCeil(AValue: Double): Double;
var
  LExp, LBase: Double;
begin
  if AValue <= 0 then
    Exit(1);
  LExp := Power(10, Floor(Log10(AValue)));
  LBase := AValue / LExp;
  if LBase <= 1 then LBase := 1
  else if LBase <= 2 then LBase := 2
  else if LBase <= 2.5 then LBase := 2.5
  else if LBase <= 5 then LBase := 5
  else LBase := 10;
  Result := LBase * LExp;
end;

{ TDashPaintControl }

constructor TDashPaintControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
end;

procedure TDashPaintControl.SetClickable(const Value: Boolean);
begin
  FClickable := Value;
  if Value then
    Cursor := crHandPoint
  else
    Cursor := crDefault;
end;

procedure TDashPaintControl.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FHover := True;
  if FClickable then
    Invalidate;
end;

procedure TDashPaintControl.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FHover := False;
  MouseLeft;
  if FClickable then
    Invalidate;
end;

procedure TDashPaintControl.MouseLeft;
begin
end;

// Çift tampon: önce bitmap'e, sonra tek seferde ekrana (titreme olmaz)
procedure TDashPaintControl.Paint;
var
  LBmp: TBitmap;
  G: TGPGraphics;
begin
  if (Width <= 0) or (Height <= 0) then
    Exit;
  LBmp := TBitmap.Create;
  try
    LBmp.PixelFormat := pf24bit;
    LBmp.SetSize(Width, Height);
    LBmp.Canvas.Brush.Color := DASH_BACKGROUND;
    LBmp.Canvas.FillRect(Rect(0, 0, Width, Height));
    G := TGPGraphics.Create(LBmp.Canvas.Handle);
    try
      G.SetSmoothingMode(SmoothingModeAntiAlias);
      G.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      DoPaint(G, Width, Height);
    finally
      G.Free;
    end;
    Canvas.Draw(0, 0, LBmp);
  finally
    LBmp.Free;
  end;
end;

procedure TDashPaintControl.DrawCard(G: TGPGraphics; W, H: Single; ABorder: TColor);
begin
  // yumuşak gölge + beyaz kart
  FillRoundRect(G, 1, 3, W - 2, H - 4, CARD_RADIUS, MakeColor(14, 15, 23, 42));
  FillRoundRect(G, 1, 1, W - 2, H - 4, CARD_RADIUS, GpColor(CLR_CARD));
  if FHover and FClickable then
    DrawRoundRect(G, 1.5, 1.5, W - 3, H - 5, CARD_RADIUS, GpColor(ABorder), 1.6)
  else
    DrawRoundRect(G, 1.5, 1.5, W - 3, H - 5, CARD_RADIUS, GpColor(CLR_BORDER), 1);
end;

{ TDashWelcome }

constructor TDashWelcome.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 96;
end;

procedure TDashWelcome.SetData(const AGreeting, ADateText: string; const AChips: TArray<TDashChip>);
begin
  FGreeting := AGreeting;
  FDateText := ADateText;
  FChips := AChips;
  Invalidate;
end;

procedure TDashWelcome.DoPaint(G: TGPGraphics; W, H: Single);
var
  LPath: TGPGraphicsPath;
  LBrush: TGPLinearGradientBrush;
  LDeco: TGPSolidBrush;
  I: Integer;
  X, LChipW: Single;
begin
  LPath := RoundRectPath(0, 0, W, H - 2, 12);
  LBrush := TGPLinearGradientBrush.Create(MakeRect(0.0, 0.0, W, H), MakeColor(255, 30, 58, 138),
    MakeColor(255, 37, 99, 235), LinearGradientModeHorizontal);
  LDeco := TGPSolidBrush.Create(MakeColor(22, 255, 255, 255));
  try
    G.FillPath(LBrush, LPath);
    G.SetClip(LPath);
    G.FillEllipse(LDeco, W - 260, -70, 220, 220);
    G.FillEllipse(LDeco, W - 120, 20, 180, 180);
    G.ResetClip;
  finally
    LDeco.Free;
    LBrush.Free;
    LPath.Free;
  end;

  DrawStr(G, FGreeting, TEXT_FONT, 22, FontStyleBold, MakeColor(255, 255, 255, 255), MakeRect(24.0, 18.0, W * 0.6, 32.0));
  DrawStr(G, FDateText, TEXT_FONT, 13.5, FontStyleRegular, MakeColor(215, 255, 255, 255), MakeRect(24.0, 54.0, W * 0.6, 22.0));

  // durum etiketleri sağdan sola
  X := W - 24;
  for I := High(FChips) downto 0 do
  begin
    LChipW := StrWidth(G, FChips[I].Text, TEXT_FONT, 13, FontStyleBold) + 40;
    X := X - LChipW;
    FillRoundRect(G, X, (H - 34) / 2, LChipW, 32, 16, MakeColor(240, 255, 255, 255));
    LDeco := TGPSolidBrush.Create(GpColor(FChips[I].Color));
    try
      G.FillEllipse(LDeco, X + 14, (H - 34) / 2 + 12, 9, 9);
    finally
      LDeco.Free;
    end;
    DrawStr(G, FChips[I].Text, TEXT_FONT, 13, FontStyleBold, GpColor(CLR_TEXT),
      MakeRect(X + 28, (H - 34) / 2, LChipW - 32, 32), StringAlignmentNear, StringAlignmentCenter);
    X := X - 10;
  end;
end;

{ TDashSection }

constructor TDashSection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 36;
end;

procedure TDashSection.SetData(const ATitle, AIcon: string; AAccent: TColor);
begin
  FTitle := ATitle;
  FIcon := AIcon;
  FAccent := AAccent;
  Invalidate;
end;

procedure TDashSection.DoPaint(G: TGPGraphics; W, H: Single);
var
  LTextW: Single;
  LPen: TGPPen;
begin
  FillRoundRect(G, 6, H - 30, 26, 26, 7, GpColor(FAccent));
  DrawStr(G, FIcon, IconFontName, 13, FontStyleRegular, MakeColor(255, 255, 255, 255),
    MakeRect(6.0, H - 30 + 1, 26.0, 26.0), StringAlignmentCenter, StringAlignmentCenter);
  DrawStr(G, FTitle, TEXT_FONT, 16, FontStyleBold, GpColor(CLR_TEXT), MakeRect(40.0, H - 32, W - 48, 30.0),
    StringAlignmentNear, StringAlignmentCenter);
  LTextW := StrWidth(G, FTitle, TEXT_FONT, 16, FontStyleBold);
  LPen := TGPPen.Create(GpColor(CLR_BORDER), 1);
  try
    if 52 + LTextW < W - 8 then
      G.DrawLine(LPen, 52 + LTextW, H - 17, W - 8, H - 17);
  finally
    LPen.Free;
  end;
end;

{ TDashTile }

procedure TDashTile.SetData(const AData: TDashTileData);
begin
  FData := AData;
  Invalidate;
end;

procedure TDashTile.DoPaint(G: TGPGraphics; W, H: Single);
var
  LLines: TArray<string>;
  I, N: Integer;
  LBadgeW, LValueSize, LLineH, LValueW, Y0, X, TX, TW, TY, TH, LMin, LMax, LBarY, LBarW: Single;
  LPts: array of TGPPointF;
  LPen: TGPPen;
  LBrush: TGPSolidBrush;
  LArea: TGPGraphicsPath;
  LGrad: TGPLinearGradientBrush;
  LBarColor: TColor;
begin
  DrawCard(G, W, H, FData.Accent);
  DrawIconCircle(G, PAD, PAD, 40, FData.Icon, FData.Accent);

  // durum etiketi (Dikkat / Kritik / Bilgi)
  LBadgeW := 0;
  if FData.Badge <> '' then
  begin
    LBadgeW := StrWidth(G, FData.Badge, TEXT_FONT, 11.5, FontStyleBold) + 18;
    FillRoundRect(G, W - PAD - LBadgeW, PAD + 9, LBadgeW, 22, 11, GpColor(FData.BadgeColor, 34));
    DrawStr(G, FData.Badge, TEXT_FONT, 11.5, FontStyleBold, GpColor(FData.BadgeColor),
      MakeRect(W - PAD - LBadgeW, PAD + 9, LBadgeW, 22.0), StringAlignmentCenter, StringAlignmentCenter);
    LBadgeW := LBadgeW + 6;
  end;
  DrawStr(G, FData.Title, TEXT_FONT, 13.5, FontStyleBold, GpColor(CLR_TEXT_MUTED),
    MakeRect(PAD + 50, PAD, W - PAD * 2 - 50 - LBadgeW, 40.0), StringAlignmentNear, StringAlignmentCenter, True);

  // değer: tek satır büyük, çok satır (para birimleri) daha küçük
  LLines := FData.ValueText.Split([sLineBreak]);
  if Length(LLines) > 1 then
  begin
    LValueSize := 16;
    LLineH := 22;
  end
  else
  begin
    LValueSize := 26;
    LLineH := 36;
  end;
  Y0 := PAD + 50;
  LValueW := 0;
  for I := 0 to Min(High(LLines), 2) do
  begin
    DrawStr(G, LLines[I], TEXT_FONT, LValueSize, FontStyleBold, GpColor(FData.ValueColor),
      MakeRect(PAD, Y0 + I * LLineH, W - PAD * 2, LLineH));
    LValueW := Max(LValueW, StrWidth(G, LLines[I], TEXT_FONT, LValueSize, FontStyleBold));
  end;

  // kart içi küçük grafik: değerin sağındaki boşlukta
  N := Length(FData.Trend);
  TX := Max(PAD + LValueW + 14, W - PAD - 120);
  TW := W - PAD - TX;
  if (N >= 2) and (TW >= 56) then
  begin
    TY := Y0 + 4;
    TH := 40;
    LMin := MaxDouble;
    LMax := -MaxDouble;
    for I := 0 to N - 1 do
    begin
      LMin := Min(LMin, FData.Trend[I].Value);
      LMax := Max(LMax, FData.Trend[I].Value);
    end;
    // sayılarda taban 0; kurlarda dar aralık daha anlamlı
    if LMin >= 0 then
      if (FData.Trend[0].Value >= 1) and (LMin > LMax * 0.5) then
        LMin := LMin - (LMax - LMin) * 0.2
      else
        LMin := 0;
    if LMax - LMin < 1E-9 then
      LMax := LMin + 1;
    SetLength(LPts, N);
    for I := 0 to N - 1 do
    begin
      LPts[I].X := TX + TW * I / (N - 1);
      LPts[I].Y := TY + TH - TH * (FData.Trend[I].Value - LMin) / (LMax - LMin);
    end;
    LArea := TGPGraphicsPath.Create;
    LGrad := TGPLinearGradientBrush.Create(MakeRect(TX, TY - 1, TW, TH + 2), GpColor(FData.Accent, 70),
      GpColor(FData.Accent, 0), LinearGradientModeVertical);
    LPen := TGPPen.Create(GpColor(FData.Accent), 2);
    LBrush := TGPSolidBrush.Create(GpColor(FData.Accent));
    try
      LArea.AddLines(PGPPointF(@LPts[0]), N);
      LArea.AddLine(LPts[N - 1].X, LPts[N - 1].Y, LPts[N - 1].X, TY + TH);
      LArea.AddLine(LPts[N - 1].X, TY + TH, LPts[0].X, TY + TH);
      LArea.CloseFigure;
      G.FillPath(LGrad, LArea);
      LPen.SetLineJoin(LineJoinRound);
      G.DrawLines(LPen, PGPPointF(@LPts[0]), N);
      G.FillEllipse(LBrush, LPts[N - 1].X - 3.5, LPts[N - 1].Y - 3.5, 7, 7);
    finally
      LBrush.Free;
      LPen.Free;
      LGrad.Free;
      LArea.Free;
    end;
  end;

  // oran çubuğu + yüzde
  if FData.Ratio >= 0 then
  begin
    LBarY := H - PAD - 4 - 22 - 8;
    LBarW := W - PAD * 2 - 48;
    if FData.Badge <> '' then
      LBarColor := FData.BadgeColor
    else
      LBarColor := FData.Accent;
    FillRoundRect(G, PAD, LBarY, LBarW, 7, 3.5, GpColor(CLR_TRACK));
    FillRoundRect(G, PAD, LBarY, Max(7, LBarW * FData.Ratio), 7, 3.5, GpColor(LBarColor));
    DrawStr(G, FData.RatioText, TEXT_FONT, 12, FontStyleBold, GpColor(CLR_TEXT_MUTED),
      MakeRect(PAD + LBarW, LBarY - 7, 48.0, 20.0), StringAlignmentFar, StringAlignmentCenter);
  end;

  X := PAD;
  DrawStr(G, FData.Detail, TEXT_FONT, 12.5, FontStyleRegular, GpColor(CLR_TEXT_MUTED),
    MakeRect(X, H - PAD - 4 - 20, W - PAD * 2, 20.0), StringAlignmentNear, StringAlignmentCenter);
end;

{ TDashChart }

constructor TDashChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHoverIndex := -1;
  Height := 260;
end;

procedure TDashChart.SetData(const AData: TDashChartData);
begin
  FData := AData;
  FHoverIndex := -1;
  Invalidate;
end;

function TDashChart.HasData: Boolean;
var
  P: TDashboardPoint;
begin
  for P in FData.Points do
    if (P.Value <> 0) or (P.Value2 <> 0) then
      Exit(True);
  Result := False;
end;

function TDashChart.IndexAt(X: Integer): Integer;
var
  N: Integer;
begin
  N := Length(FData.Points);
  if (N = 0) or (FPlot.Width <= 0) or (X < FPlot.Left) or (X > FPlot.Right) then
    Exit(-1);
  Result := EnsureRange(Trunc((X - FPlot.Left) / (FPlot.Width / N)), 0, N - 1);
end;

procedure TDashChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited;
  if HasData and (Y >= FPlot.Top - 8) and (Y <= FPlot.Bottom + 8) then
    LIndex := IndexAt(X)
  else
    LIndex := -1;
  if LIndex <> FHoverIndex then
  begin
    FHoverIndex := LIndex;
    Invalidate;
  end;
end;

procedure TDashChart.MouseLeft;
begin
  if FHoverIndex <> -1 then
  begin
    FHoverIndex := -1;
    Invalidate;
  end;
end;

procedure TDashChart.DoPaint(G: TGPGraphics; W, H: Single);
const
  TICKS = 4;
var
  N, I, S, LStep, LSeriesCount: Integer;
  LMin, LMax, V, LSlot, LBarW, LGroupW, X, Y, LLabelW, LLegendX, LYLabelW, LTipW, LTipH, LTipX, LTipY: Single;
  LPen: TGPPen;
  LBrush: TGPSolidBrush;
  LPts: array of TGPPointF;
  LColors: array[0..1] of TColor;
  LNames: array[0..1] of string;
  LTip: string;

  function Val(AIndex, ASeries: Integer): Double;
  begin
    if ASeries = 0 then
      Result := FData.Points[AIndex].Value
    else
      Result := FData.Points[AIndex].Value2;
  end;

  function YOf(AValue: Double): Single;
  begin
    Result := FPlot.Bottom - FPlot.Height * (AValue - LMin) / (LMax - LMin);
  end;

begin
  DrawCard(G, W, H, FData.Color1);
  DrawStr(G, FData.Title, TEXT_FONT, 15, FontStyleBold, GpColor(CLR_TEXT), MakeRect(PAD + 2, 14.0, W * 0.6, 24.0));
  DrawStr(G, FData.Subtitle, TEXT_FONT, 12.5, FontStyleRegular, GpColor(CLR_TEXT_MUTED), MakeRect(PAD + 2, 38.0, W * 0.6, 20.0));

  LSeriesCount := IfThen(FData.Series2 <> '', 2, 1);
  LColors[0] := FData.Color1;
  LColors[1] := FData.Color2;
  LNames[0] := FData.Series1;
  LNames[1] := FData.Series2;

  // lejant sağ üstte
  LLegendX := W - PAD;
  for S := LSeriesCount - 1 downto 0 do
  begin
    LLabelW := StrWidth(G, LNames[S], TEXT_FONT, 12.5, FontStyleRegular);
    LLegendX := LLegendX - LLabelW;
    DrawStr(G, LNames[S], TEXT_FONT, 12.5, FontStyleRegular, GpColor(CLR_TEXT_MUTED),
      MakeRect(LLegendX, 16.0, LLabelW + 4, 20.0), StringAlignmentNear, StringAlignmentCenter);
    FillRoundRect(G, LLegendX - 16, 21, 11, 11, 3, GpColor(LColors[S]));
    LLegendX := LLegendX - 30;
  end;

  N := Length(FData.Points);
  if not HasData then
  begin
    FPlot := TRectF.Empty;
    DrawStr(G, ICON_CHART, IconFontName, 34, FontStyleRegular, GpColor(CLR_BORDER),
      MakeRect(0.0, H / 2 - 34, W, 44.0), StringAlignmentCenter, StringAlignmentCenter);
    DrawStr(G, FData.EmptyText, TEXT_FONT, 13, FontStyleRegular, GpColor(CLR_TEXT_MUTED),
      MakeRect(0.0, H / 2 + 14, W, 22.0), StringAlignmentCenter, StringAlignmentCenter);
    Exit;
  end;

  // ölçek: sütunlarda 0 tabanlı; çizgide (kur) veri aralığı
  LMin := MaxDouble;
  LMax := 0;
  for I := 0 to N - 1 do
    for S := 0 to LSeriesCount - 1 do
    begin
      V := Val(I, S);
      LMax := Max(LMax, V);
      if V > 0 then
        LMin := Min(LMin, V);
    end;
  if (FData.Kind = dckLines) and (LMin < MaxDouble) and (LMax > LMin) then
  begin
    // veri aralığı + yuvarlak adım: alt sınır adımın katı, üst sınır = alt + 4 adım (maksimumu kapsar)
    V := NiceCeil((LMax - LMin) * 1.3 / TICKS);
    LMin := Max(0, Floor((LMin - (LMax - LMin) * 0.15) / V) * V);
    while LMin + V * TICKS < LMax do
      V := NiceCeil(V * 1.01);
    LMax := LMin + V * TICKS;
  end
  else
  begin
    LMin := 0;
    LMax := NiceCeil(LMax);
    // adet grafikleri: eksen etiketleri tam sayı
    if (Pos('.', FData.ValueFormat) = 0) and (Frac(LMax / TICKS) <> 0) then
      LMax := Ceil(LMax / TICKS) * TICKS;
  end;
  if LMax - LMin < 1E-9 then
    LMax := LMin + 1;

  LYLabelW := 0;
  for I := 0 to TICKS do
    LYLabelW := Max(LYLabelW, StrWidth(G, CompactNumber(LMin + (LMax - LMin) * I / TICKS), TEXT_FONT, 11.5, FontStyleRegular));
  LYLabelW := LYLabelW + 8;
  FPlot := TRectF.Create(PAD + LYLabelW, 70, W - PAD - 4, H - PAD - 26);

  // yatay ızgara + y etiketleri
  LPen := TGPPen.Create(GpColor(CLR_GRID), 1);
  try
    for I := 0 to TICKS do
    begin
      V := LMin + (LMax - LMin) * I / TICKS;
      Y := YOf(V);
      G.DrawLine(LPen, FPlot.Left, Y, FPlot.Right, Y);
      DrawStr(G, CompactNumber(V), TEXT_FONT, 11.5, FontStyleRegular, GpColor(CLR_TEXT_MUTED),
        MakeRect(PAD - 4.0, Y - 9, LYLabelW, 18.0), StringAlignmentFar, StringAlignmentCenter);
    end;
  finally
    LPen.Free;
  end;

  LSlot := FPlot.Width / N;
  if FHoverIndex >= 0 then
    FillRoundRect(G, FPlot.Left + LSlot * FHoverIndex + 1, FPlot.Top - 6, LSlot - 2, FPlot.Height + 6, 6,
      GpColor(CLR_TRACK, 160));

  if FData.Kind = dckColumns then
  begin
    LGroupW := Min(LSlot * 0.7, 44);
    LBarW := LGroupW / LSeriesCount;
    for I := 0 to N - 1 do
      for S := 0 to LSeriesCount - 1 do
      begin
        V := Val(I, S);
        if V <= 0 then
          Continue;
        X := FPlot.Left + LSlot * I + (LSlot - LGroupW) / 2 + LBarW * S;
        Y := YOf(V);
        FillRoundRect(G, X + 1, Y, LBarW - 2, FPlot.Bottom - Y, Min(4, (LBarW - 2) / 2), GpColor(LColors[S]));
        // alt köşeler düz
        if FPlot.Bottom - Y > 4 then
        begin
          LBrush := TGPSolidBrush.Create(GpColor(LColors[S]));
          try
            G.FillRectangle(LBrush, X + 1, FPlot.Bottom - 4, LBarW - 2, 4);
          finally
            LBrush.Free;
          end;
        end;
      end;
  end
  else
  begin
    for S := 0 to LSeriesCount - 1 do
    begin
      SetLength(LPts, 0);
      for I := 0 to N - 1 do
        if Val(I, S) > 0 then
        begin
          SetLength(LPts, Length(LPts) + 1);
          LPts[High(LPts)] := MakePoint(FPlot.Left + LSlot * I + LSlot / 2, YOf(Val(I, S)));
        end;
      if Length(LPts) = 0 then
        Continue;
      LPen := TGPPen.Create(GpColor(LColors[S]), 2.4);
      LBrush := TGPSolidBrush.Create(GpColor(LColors[S]));
      try
        LPen.SetLineJoin(LineJoinRound);
        if Length(LPts) > 1 then
          G.DrawLines(LPen, PGPPointF(@LPts[0]), Length(LPts));
        X := LPts[High(LPts)].X;
        Y := LPts[High(LPts)].Y;
        G.FillEllipse(LBrush, X - 4, Y - 4, 8, 8);
        if (FHoverIndex >= 0) and (Val(FHoverIndex, S) > 0) then
          G.FillEllipse(LBrush, FPlot.Left + LSlot * FHoverIndex + LSlot / 2 - 4.5, YOf(Val(FHoverIndex, S)) - 4.5, 9, 9);
      finally
        LBrush.Free;
        LPen.Free;
      end;
    end;
  end;

  // x etiketleri: sığdığı kadar seyrek
  LLabelW := StrWidth(G, FormatDateTime(FData.DateFormat, Date), TEXT_FONT, 11.5, FontStyleRegular) + 10;
  LStep := Max(1, Ceil(LLabelW / LSlot));
  for I := 0 to N - 1 do
    if ((N - 1 - I) mod LStep = 0) then
      DrawStr(G, FormatDateTime(FData.DateFormat, FData.Points[I].Day), TEXT_FONT, 11.5, FontStyleRegular,
        GpColor(CLR_TEXT_MUTED), MakeRect(FPlot.Left + LSlot * I + LSlot / 2 - LLabelW / 2, FPlot.Bottom + 6, LLabelW, 18.0),
        StringAlignmentCenter, StringAlignmentNear);

  // değer balonu
  if FHoverIndex >= 0 then
  begin
    LTip := FormatDateTime(FData.DateFormat, FData.Points[FHoverIndex].Day);
    for S := 0 to LSeriesCount - 1 do
      LTip := LTip + sLineBreak + LNames[S] + ': ' + FormatFloat(FData.ValueFormat, Val(FHoverIndex, S));
    LTipW := 0;
    for var LLine in LTip.Split([sLineBreak]) do
      LTipW := Max(LTipW, StrWidth(G, LLine, TEXT_FONT, 12.5, FontStyleBold));
    LTipW := LTipW + 20;
    LTipH := 12 + 19 * (LSeriesCount + 1);
    LTipX := FPlot.Left + LSlot * FHoverIndex + LSlot / 2 + 10;
    if LTipX + LTipW > W - 6 then
      LTipX := FPlot.Left + LSlot * FHoverIndex + LSlot / 2 - 10 - LTipW;
    LTipY := FPlot.Top;
    FillRoundRect(G, LTipX, LTipY, LTipW, LTipH, 8, MakeColor(235, 31, 41, 55));
    DrawStr(G, LTip, TEXT_FONT, 12.5, FontStyleBold, MakeColor(255, 255, 255, 255),
      MakeRect(LTipX + 10, LTipY + 6, LTipW - 12, LTipH - 8), StringAlignmentNear, StringAlignmentNear, True);
  end;
end;

end.
