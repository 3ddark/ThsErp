unit Detail.Totals;

// Hesaplanan (elle girilmeyen) tutarların gösterimi: formdaki bir TPanel'e "Başlık   1.234,56 USD" satırları dizer.
// Satırlar kodla eklenir (AddRow), başlıklar ApplyLocalization'da (SetCaption), değerler her hesapta (SetValue).
// Belge / kalem formlarında edit yerine kullanılır (ör. teklif kalemi: brüt, iskonto, net, KDV, toplam).

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls;

const
  TOTALS_ROW_HEIGHT = 20;
  // SetValue ADecimals: tutar / miktar hanesi sys_decimal_place'ten
  TOTALS_DIGITS_AMOUNT = -2;
  TOTALS_DIGITS_QUANTITY = -1;

type
  TTotalsPanel = class
  private
    FPanel: TPanel;
    FCaptions: TDictionary<string, TLabel>;
    FValues: TDictionary<string, TLabel>;
    FRowCount: Integer;
    function NewLabel(ALeft, AWidth: Integer; ABold: Boolean): TLabel;
  public
    // APanel formun bileşenidir; etiketler panele aittir (form serbest bırakır)
    constructor Create(APanel: TPanel);
    destructor Destroy; override;

    // Yeni satır (alt alta); AKey satırın adı (SetCaption / SetValue)
    procedure AddRow(const AKey: string; ABold: Boolean = False);
    procedure SetCaption(const AKey, ACaption: string);
    // Değer biçimli yazılır: '#,##0.00' + ' ' + ASuffix (para birimi / ölçü birimi); ADecimals: hane ya da
    // TOTALS_DIGITS_AMOUNT (tutar hanesi; para birimi kodu simgeyle: USD -> $) / TOTALS_DIGITS_QUANTITY (miktar hanesi)
    procedure SetValue(const AKey: string; AValue: Double; const ASuffix: string = ''; ADecimals: Integer = TOTALS_DIGITS_AMOUNT);
    procedure SetText(const AKey, AText: string);
    // Panel yüksekliği satır sayısına göre
    function RequiredHeight: Integer;
    property Panel: TPanel read FPanel;
  end;

implementation

uses
  SysDecimalPlace.Cache, SysCurrency.Cache;

constructor TTotalsPanel.Create(APanel: TPanel);
begin
  inherited Create;
  FPanel := APanel;
  FCaptions := TDictionary<string, TLabel>.Create;
  FValues := TDictionary<string, TLabel>.Create;
  FPanel.Caption := '';
  FPanel.BevelOuter := bvLowered;
  // renkler temadan (VCL style)
  FPanel.ParentBackground := True;
  FPanel.ParentColor := True;
end;

destructor TTotalsPanel.Destroy;
begin
  FValues.Free;
  FCaptions.Free;
  inherited;
end;

function TTotalsPanel.NewLabel(ALeft, AWidth: Integer; ABold: Boolean): TLabel;
begin
  Result := TLabel.Create(FPanel);
  Result.Parent := FPanel;
  Result.AutoSize := False;
  Result.Alignment := taRightJustify;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := TOTALS_ROW_HEIGHT - 4;
  Result.Top := 6 + FRowCount * TOTALS_ROW_HEIGHT;
  Result.Transparent := True;
  if ABold then
    Result.Font.Style := [fsBold];
end;

procedure TTotalsPanel.AddRow(const AKey: string; ABold: Boolean);
var
  LHalf: Integer;
  LCaption, LValue: TLabel;
begin
  LHalf := (FPanel.ClientWidth - 24) div 2;
  LCaption := NewLabel(8, LHalf, True);
  LCaption.Anchors := [akLeft, akTop];
  LValue := NewLabel(16 + LHalf, LHalf, ABold);
  LValue.Anchors := [akLeft, akTop, akRight];
  FCaptions.AddOrSetValue(AKey, LCaption);
  FValues.AddOrSetValue(AKey, LValue);
  Inc(FRowCount);
end;

procedure TTotalsPanel.SetCaption(const AKey, ACaption: string);
var
  LLabel: TLabel;
begin
  if FCaptions.TryGetValue(AKey, LLabel) then
    LLabel.Caption := ACaption;
end;

procedure TTotalsPanel.SetText(const AKey, AText: string);
var
  LLabel: TLabel;
begin
  if FValues.TryGetValue(AKey, LLabel) then
    LLabel.Caption := AText;
end;

procedure TTotalsPanel.SetValue(const AKey: string; AValue: Double; const ASuffix: string; ADecimals: Integer);
var
  LText, LSuffix: string;
begin
  LSuffix := ASuffix;
  if ADecimals = TOTALS_DIGITS_AMOUNT then
  begin
    ADecimals := TDecimalPlaces.Total;
    LSuffix := TCurrencySymbols.Symbol(ASuffix);
  end
  else if ADecimals = TOTALS_DIGITS_QUANTITY then
    ADecimals := TDecimalPlaces.Quantity;
  LText := FormatFloat(TDecimalPlaces.DisplayFormat(ADecimals), AValue);
  if LSuffix <> '' then
    LText := LText + ' ' + LSuffix;
  SetText(AKey, LText);
end;

function TTotalsPanel.RequiredHeight: Integer;
begin
  Result := 12 + FRowCount * TOTALS_ROW_HEIGHT;
end;

end.
