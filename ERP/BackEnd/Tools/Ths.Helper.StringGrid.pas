unit Ths.Helper.StringGrid;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes,
  System.Generics.Collections, System.Math, Winapi.Messages, Winapi.Windows,
  Vcl.Graphics, Vcl.Controls, Vcl.Grids, Vcl.Dialogs, Vcl.Forms;

const
  COL_OBJ = 0;
  ROW_OBJ = 0;

type
  TSortMode = (smNone, smAsc, smDesc);
  TThsDataType = (ctString, ctInteger, ctDouble, ctDate, ctTime, ctDateTime, ctBcd, ctBoolean);
  TVerticalAlignment = (vaTop, vaCenter, vaBottom);

  //forward declaration
  TStringGrid = class;

  TThsBorder = class(TPersistent)
  private
    FEnable: Boolean;
    FColor: TColor;
    FWidth: Integer;
    function GetColor: TColor;
    function GetEnable: Boolean;
    function GetWidth: Integer;
    procedure SetColor(const Value: TColor);
    procedure SetEnable(const Value: Boolean);
    procedure SetWidth(const Value: Integer);
  published
    property Enable: Boolean read GetEnable write SetEnable;
    property Color: TColor read GetColor write SetColor;
    property Width: Integer read GetWidth write SetWidth;
  end;

  TThsCellBorder = class(TPersistent)
  private
    FLeft: TThsBorder;
    FRight: TThsBorder;
    FTop: TThsBorder;
    FBottom: TThsBorder;
    function GetBottom: TThsBorder;
    function GetLeft: TThsBorder;
    function GetRight: TThsBorder;
    function GetTop: TThsBorder;
    procedure SetBottom(const Value: TThsBorder);
    procedure SetLeft(const Value: TThsBorder);
    procedure SetRight(const Value: TThsBorder);
    procedure SetTop(const Value: TThsBorder);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Left: TThsBorder read GetLeft write SetLeft;
    property Right: TThsBorder read GetRight write SetRight;
    property Top: TThsBorder read GetTop write SetTop;
    property Bottom: TThsBorder read GetBottom write SetBottom;
  end;

  TThsStyle = class(TPersistent)
  private
    FGrid: TStringGrid;
    FFont: TFont;
    FColor: TColor;
    FHAlign: TAlignment;
    FVAlign: TVerticalAlignment;
    FBorder: TThsCellBorder;
    FBorderActive: Boolean;
    FDataType: TThsDataType;
  published
  public
    constructor Create(AGrid: TStringGrid);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Clone: TThsStyle;
  published
    property Font: TFont read FFont write FFont;
    property Color: TColor read FColor write FColor;
    property HAlign: TAlignment read FHAlign write FHAlign;
    property VAlign: TVerticalAlignment read FVAlign write FVAlign;
    property Border: TThsCellBorder read FBorder write FBorder;
    property BorderActive: Boolean read FBorderActive write FBorderActive;
    property DataType: TThsDataType read FDataType write FDataType;
  end;

  TCellLine = array of TThsStyle;

  TOnConditionDrawCell = procedure(Sender: TObject; ARow, ACol: Longint; var Value: string; var AStyle: TThsStyle) of object;

  TStringGrid = class(Vcl.Grids.TStringGrid)
  private
    FSortCol: SmallInt; //s�ralama yap�lan column no
    FSortType: TSortMode; //yap�lan s�ralama bilgisi

    FColResized: Boolean; //Sort i�lemi i�in kullan�l�yor.

    //Sort arrow i�in kullan�lan renk
    FSortArrowBorderColor: TColor;
    FSortArrowBackColor: TColor;

    //checkbox i�in daha sonra kullan�lacak
    FCheck: TBitmap;
    FNoCheck: TBitmap;

    //ko�ullu renklendirme i�in kullan�lan event
    FOnConditionDrawCell: TOnConditionDrawCell;

    FCellStyles: array of TCellLine; //array of array of TThsStyle
    FDefaultFixedCellStyle: TThsStyle;  //fix h�creler i�in �zel stil tan�mlanmam��sa kullan�lacak olan stil
    FDefaultCellStyle: TThsStyle;
    FAutoColSize: Boolean; //normal h�creler i�in �zel stil tan�mlanmam��sa kullan�lacak olan stil

    //varsay�lan h�cre stilleri i�in kullan
    procedure SetDefaultCellStyle(const Value: TThsStyle);
    function  GetDefaultCellStyle: TThsStyle;
    procedure SetDefaultFixedCellStyle(const Value: TThsStyle);
    function  GetDefaultFixedCellStyle: TThsStyle;

    //�zel boyama yap�lan h�creler i�in kullan
    function GetCellStyles(ACol, ARow: Integer): TThsStyle;
    procedure SetCellStyles(ACol, ARow: Integer; const Value: TThsStyle);
    procedure SetCellStyleCol(ACol: Integer; FixRow: Boolean; const Value: TThsStyle);
    procedure SetCellStyleRow(ARow: Integer; FixCol: Boolean; const Value: TThsStyle);
    //ilk tan�mlamalar create an�nda kullan
    procedure Initialize;

    procedure SetColCount(Value: Longint);
    procedure SetRowCount(Value: Longint);
    procedure SetCellCount(OldColCount, NewColCount, OldRowCount, NewRowCount: Integer);

    procedure DrawFixedRowNumber; //fixed row no yazd�rma
    procedure DrawSortArrow(ARect: TRect; ASort: TSortMode; AAlign: TAlignment);
    function GetColCount: integer;
    function GetRowCount: integer;  //sort y�n oku �iz
  protected
    procedure DrawCell(ACol: Integer; ARow: Integer; ARect: TRect; AState: TGridDrawState); override;
    procedure ColumnMoved(FromIndex: Integer; ToIndex: Integer); override;
    procedure RowMoved(FromIndex, ToIndex: Longint); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure FixedCellClick(ACol, ARow: Longint); override;
    procedure ColWidthsChanged; override;
    procedure SizeChanged(OldColCount, OldRowCount: Longint); override;

    procedure DeleteColumn(ACol: LongInt); override;
    procedure DeleteRow(ARow: LongInt); override;

    procedure SortStringGrid(ACol: Integer);
    procedure SortMerge(var ARowNoList: array of Integer; ACol: Integer; ASortMode: TSortMode);

    procedure ConditionDrawCell(Sender: TObject; ARow, ACol: Longint; var Value: string; var AStyle: TThsStyle);
  published
    property ColCount: integer read GetColCount write SetColCount default 5;
    property RowCount: integer read GetRowCount write SetRowCount default 5;

    property OnConditionDrawCell: TOnConditionDrawCell read FOnConditionDrawCell write FOnConditionDrawCell;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  public
    property DefaultCellStyle: TThsStyle read GetDefaultCellStyle write SetDefaultCellStyle;
    property DefaultFixedCellStyle: TThsStyle read GetDefaultFixedCellStyle write SetDefaultFixedCellStyle;

    property CellStyles[ACol, ARow: Integer]: TThsStyle read GetCellStyles write SetCellStyles;
    property CellStyleRow[ARow: Integer; FixCol: Boolean]: TThsStyle write SetCellStyleRow;
    property CellStyleCol[ACol: Integer; FixRow: Boolean]: TThsStyle write SetCellStyleCol;

    property AutoColSize : Boolean read FAutoColSize write FAutoColSize;

    property SortCol: SmallInt read FSortCol write FSortCol;
    property SortType: TSortMode read FSortType write FSortType;

    procedure DrawFixedRowNumbers; //fixed row no yazd�rma

    function SelectCell(ACol, ARow: Longint): Boolean; override;

    procedure ColStyleDouble(ACol: LongInt);
    procedure ColStyleMoney(ACol: LongInt);
  end;

implementation

function TThsBorder.GetColor: TColor;
begin
  Result := FColor;
end;

function TThsBorder.GetEnable: Boolean;
begin
  Result := FEnable;
end;

function TThsBorder.GetWidth: Integer;
begin
  Result := FWidth;
end;

procedure TThsBorder.SetColor(const Value: TColor);
begin
  FColor := Value;
end;

procedure TThsBorder.SetEnable(const Value: Boolean);
begin
  FEnable := Value;
end;

procedure TThsBorder.SetWidth(const Value: Integer);
begin
  FWidth := Value;
end;

constructor TThsCellBorder.Create();
begin
  inherited;
  FLeft := TThsBorder.Create;
  FRight := TThsBorder.Create;
  FTop := TThsBorder.Create;
  FBottom := TThsBorder.Create;
end;

destructor TThsCellBorder.Destroy;
begin
  if FLeft <> nil then
    FreeAndNil(FLeft);
  if FRight <> nil then
    FreeAndNil(FRight);
  if FTop <> nil then
    FreeAndNil(FTop);
  if FBottom <> nil then
    FreeAndNil(FBottom);

  inherited;
end;

function TThsCellBorder.GetBottom: TThsBorder;
begin
  Result := FBottom;
end;

function TThsCellBorder.GetLeft: TThsBorder;
begin
  Result := FLeft;
end;

function TThsCellBorder.GetRight: TThsBorder;
begin
  Result := FRight;
end;

function TThsCellBorder.GetTop: TThsBorder;
begin
  Result := FTop;
end;

procedure TThsCellBorder.SetBottom(const Value: TThsBorder);
begin
  FBottom.Assign(Value);
end;

procedure TThsCellBorder.SetLeft(const Value: TThsBorder);
begin
  FLeft.Assign(Value);
end;

procedure TThsCellBorder.SetRight(const Value: TThsBorder);
begin
  FRight.AssignTo(Value);
end;

procedure TThsCellBorder.SetTop(const Value: TThsBorder);
begin
  FTop.Assign(Value);
end;

procedure TThsStyle.Assign(Source: TPersistent);
begin
  if Source is TThsStyle then
  begin
    Self.FFont.Color := TThsStyle(Source).Font.Color;
    Self.FFont.Name := TThsStyle(Source).Font.Name;
    Self.FFont.Size := TThsStyle(Source).Font.Size;
    Self.FFont.Style := TThsStyle(Source).Font.Style;

    Self.FColor := TThsStyle(Source).Color;
    Self.FHAlign := TThsStyle(Source).HAlign;
    Self.FVAlign := TThsStyle(Source).VAlign;
    Self.FBorderActive := TThsStyle(Source).BorderActive;

    Self.FBorder.Left.Enable := TThsStyle(Source).Border.Left.Enable;
    Self.FBorder.Left.Color := TThsStyle(Source).Border.Left.Color;
    Self.FBorder.Left.Width := TThsStyle(Source).Border.Left.Width;

    Self.FBorder.Right.Enable := TThsStyle(Source).Border.Right.Enable;
    Self.FBorder.Right.Color := TThsStyle(Source).Border.Right.Color;
    Self.FBorder.Right.Width := TThsStyle(Source).Border.Right.Width;

    Self.FBorder.Top.Enable := TThsStyle(Source).Border.Top.Enable;
    Self.FBorder.Top.Color := TThsStyle(Source).Border.Top.Color;
    Self.FBorder.Top.Width := TThsStyle(Source).Border.Top.Width;

    Self.FBorder.Bottom.Enable := TThsStyle(Source).Border.Bottom.Enable;
    Self.FBorder.Bottom.Color := TThsStyle(Source).Border.Bottom.Color;
    Self.FBorder.Bottom.Width := TThsStyle(Source).Border.Bottom.Width;

    Self.FDataType := TThsStyle(Source).DataType;
  end
  else
    inherited;
end;

function TThsStyle.Clone: TThsStyle;
begin
  Result := TThsStyle.Create(Self.FGrid);

  Result.FFont.Color := Self.FFont.Color;
  Result.FFont.Name := Self.FFont.Name;
  Result.FFont.Size := Self.FFont.Size;
  Result.FFont.Style := Self.FFont.Style;

  Result.HAlign := Self.HAlign;
  Result.VAlign := Self.VAlign;

  Result.FBorder.FLeft.FEnable := Self.FBorder.FLeft.FEnable;
  Result.FBorder.FLeft.FColor := Self.FBorder.FLeft.FColor;
  Result.FBorder.FLeft.FWidth := Self.FBorder.FLeft.FWidth;

  Result.FBorder.FRight.FEnable := Self.FBorder.FRight.FEnable;
  Result.FBorder.FRight.FColor := Self.FBorder.FRight.FColor;
  Result.FBorder.FRight.FWidth := Self.FBorder.FRight.FWidth;

  Result.FBorder.FTop.FEnable := Self.FBorder.FTop.FEnable;
  Result.FBorder.FTop.FColor := Self.FBorder.FTop.FColor;
  Result.FBorder.FTop.FWidth := Self.FBorder.FTop.FWidth;

  Result.FBorder.FBottom.FEnable := Self.FBorder.FBottom.FEnable;
  Result.FBorder.FBottom.FColor := Self.FBorder.FBottom.FColor;
  Result.FBorder.FBottom.FWidth := Self.FBorder.FBottom.FWidth;

  Result.FBorderActive := Self.FBorderActive;
end;

constructor TThsStyle.Create(AGrid: TStringGrid);
begin
  FGrid := AGrid;

  FFont := TFont.Create;
  FColor := clWhite;
  FHAlign := taLeftJustify;
  FVAlign := vaCenter;

  FBorder := TThsCellBorder.Create;
  FBorderActive := False;

  FDataType := ctString;
end;

destructor TThsStyle.Destroy;
begin
  if FFont <> nil then
    FreeAndNil(FFont);
  if FBorder <> nil then
    FreeAndNil(FBorder);
  inherited;
end;

procedure TStringGrid.ColStyleDouble(ACol: LongInt);
var
  AStyle: TThsStyle;
begin
  AStyle := DefaultCellStyle.Clone;
  try
    AStyle.HAlign := taRightJustify;
    AStyle.DataType := ctDouble;
    CellStyleCol[ACol, False] := AStyle;
  finally
    AStyle.Free;
  end;
end;

procedure TStringGrid.ColStyleMoney(ACol: LongInt);
var
  AStyle: TThsStyle;
begin
  AStyle := DefaultCellStyle.Clone;
  try
    AStyle.HAlign := taRightJustify;
    AStyle.DataType := ctBcd;
    CellStyleCol[ACol, False] := AStyle;
  finally
    AStyle.Free;
  end;
end;

procedure TStringGrid.ColumnMoved(FromIndex, ToIndex: Integer);
var
  n1: Integer;
  LStyle: TCellLine;
begin
  LStyle := FCellStyles[FromIndex];
  if (FromIndex > ToIndex) then
    for n1 := FromIndex-1 downto ToIndex do
      FCellStyles[n1+1] := FCellStyles[n1]
  else
    for n1 := FromIndex to ToIndex-1 do
      FCellStyles[n1] := FCellStyles[n1+1];
  FCellStyles[ToIndex] := LStyle;
  Invalidate;

  inherited;
end;

constructor TStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Self.DoubleBuffered := True;

  Initialize;
end;

procedure TStringGrid.DeleteColumn(ACol: LongInt);
begin
  if (ACOl > ColCount - 1) or (ACol < 0) then
    Exit;

  ColumnMoved(ACol, ColCount - 1);
  ColCount := ColCount - 1;
end;

procedure TStringGrid.DeleteRow(ARow: LongInt);
begin
  if (ARow > RowCount - 1) or (ARow < 0) then
    Exit;

  RowMoved(ARow, RowCount - 1);
  RowCount := RowCount - 1;
end;

destructor TStringGrid.Destroy;
var
  nC, nR: Integer;
begin
  FCheck.Free;
  FNoCheck.Free;

  FDefaultFixedCellStyle.Free;
  FDefaultCellStyle.Free;

  for nC :=0 to ColCount - 1 do
  begin
    for nR := 0 to self.RowCount - 1 do
      FCellStyles[nC][nR].Free;
    SetLength(FCellStyles[nC], 0);
  end;

  inherited;
end;

procedure TStringGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  vTextWidth, vTextHeight, vTop, vLeft: Integer;
  vValue: string;
  LLineL, LLineR, LLineT, LLineB: Integer;
  LStyle: TThsStyle;

  function HorizontalAlignment(Stil: TThsStyle): Integer;
  begin
    Result := ARect.Left;
    if Stil.HAlign = taLeftJustify then
      Result := ARect.Left + 2
    else if Stil.HAlign = taRightJustify then
      Result := ARect.Right - vTextWidth - 2
    else if Stil.HAlign = taCenter then
      Result := ARect.Left + (ARect.Width - vTextWidth) div 2;
  end;

  function VerticalAlignment(Stil: TThsStyle): Integer;
  begin
    Result := ARect.Top;
    if Stil.VAlign = vaTop then
      Result := ARect.Top + 2
    else if Stil.VAlign = vaBottom then
      Result := ARect.Bottom - vTextHeight - 2
    else if Stil.VAlign = vaCenter then
      Result := ARect.Top + (ARect.Height - vTextHeight) div 2;
  end;

  procedure DrawBorders(Stil: TThsStyle);
  begin
    if Stil.BorderActive and not(gdSelected in AState) then
    begin
      if Stil.Border.Left.Enable then
      begin
        Canvas.Pen.Width := Stil.Border.FLeft.Width;
        Canvas.Pen.Color := Stil.Border.FLeft.Color;
        Canvas.MoveTo(ARect.Left, ARect.Top);
        Canvas.LineTo(ARect.Left, ARect.Bottom);
      end;

      if Stil.Border.Right.Enable then
      begin
        Canvas.Pen.Width := Stil.Border.Right.Width;
        Canvas.Pen.Color := Stil.Border.Right.Color;
        Canvas.MoveTo(ARect.Right, ARect.Top);
        Canvas.LineTo(ARect.Right, ARect.Bottom);
      end;

      if Stil.Border.Top.Enable then
      begin
        Canvas.Pen.Width := Stil.Border.Top.Width;
        Canvas.Pen.Color := Stil.Border.Top.Color;
        Canvas.MoveTo(ARect.Left, ARect.Top);
        Canvas.LineTo(ARect.Right, ARect.Top);
      end;

      if Stil.Border.Bottom.Enable then
      begin
        Canvas.Pen.Width := Stil.Border.Bottom.Width;
        Canvas.Pen.Color := Stil.Border.Bottom.Color;
        Canvas.MoveTo(ARect.Left, ARect.Bottom);
        Canvas.LineTo(ARect.Right, ARect.Bottom);
      end;
    end;
  end;

  procedure PrepareBorderRect(Stil: TThsStyle);
  begin
    if Stil.BorderActive then
    begin
      if Stil.Border.Left.Enable then
        LLineL := Stil.FBorder.FLeft.Width;
      if Stil.Border.Right.Enable then
        LLineR := Stil.Border.Right.Width;
      if Stil.Border.Top.Enable then
        LLineT := Stil.Border.Top.Width;
      if Stil.Border.Bottom.Enable then
        LLineB := Stil.Border.Bottom.Width;
    end;

    Canvas.Brush.Color := Stil.Color;
    Canvas.Font.Name := Stil.Font.Name;
    Canvas.Font.Size := Stil.Font.Size;
    Canvas.Font.Color := Stil.Font.Color;
    Canvas.Font.Style := Stil.Font.Style;


    ARect.Left := ARect.Left + LLineL;
    ARect.Right := ARect.Right - LLineR;
    ARect.Top := ARect.Top + LLineT;
    ARect.Bottom := ARect.Bottom - LLineB;

    Canvas.FillRect(ARect);
  end;

begin
  inherited;
  if not(csDesigning in Self.ComponentState) then
  begin
    LStyle := nil;

    Rows[ARow].BeginUpdate;
    Cols[ACol].BeginUpdate;
    try
      vValue := Cells[ACol, ARow];

      LLineL := 0;
      LLineR := 0;
      LLineT := 0;
      LLineB := 0;

      // Draw fixed cell
      if (ACol + 1 <= FixedCols) or (ARow + 1 <= FixedRows) then
      begin
        PrepareBorderRect(FDefaultFixedCellStyle);

        vTextWidth := Canvas.TextWidth(vValue);
        vTextHeight := Canvas.TextHeight(vValue);

        RowHeights[ARow] := Max(vTextHeight + 3 * 2, RowHeights[ARow]);

        vTop := VerticalAlignment(FDefaultFixedCellStyle);
        vLeft := HorizontalAlignment(FDefaultFixedCellStyle);

        Canvas.TextRect(ARect, vLeft, vTop, vValue);

        DrawBorders(FDefaultFixedCellStyle);
      end
      else if (ACol + 1 > FixedCols) and (ARow + 1 > FixedRows) then
      begin
        LStyle := CellStyles[ACol, ARow];
        if LStyle <> nil then
        begin
          ConditionDrawCell(Self, ARow, ACol, vValue, LStyle);

          PrepareBorderRect(LStyle);

          vTextWidth := Canvas.TextWidth(vValue);
          vTextHeight := Canvas.TextHeight(vValue);

          vTop := VerticalAlignment(LStyle);
          vLeft := HorizontalAlignment(LStyle);

          Canvas.TextRect(ARect, vLeft, vTop, vValue);

          DrawBorders(LStyle);

          if FAutoColSize then
          begin
            if ColWidths[ACol] < vTextWidth then
              ColWidths[ACol] := vTextWidth + LLineL + LLineR;
          end;
        end;
      end;

      if (ARow + 1 <= FixedRows) and (FSortType <> TSortMode.smNone) and (FSortCol = ACol) then
        DrawSortArrow(ARect, FSortType, taRightJustify);

    finally
      Rows[ARow].EndUpdate;
      Cols[ACol].EndUpdate;
    end;
  end;

  // Draw Checkbox
  // Daha sonra aktif edilecek �u anda veri tipi boolean ise ve h�cre bilgisi true='TRUE' false='FALSE' bilgisi tan�ml� de�il
//  if FColDataTypes[ACol] = ctBoolean then
//  begin
//    if (ARow + 1 > FixedRows) and ((Cells[ACol, ARow] = 'TRUE') or (Cells[ACol, ARow] = 'FALSE')) then
//      with Canvas do
//      Begin
//        FillRect(ARect);
//        if Cells[ACol, ARow] = 'TRUE' then  // use for my global function true = 'TRUE' false = 'FALSE'
//          Draw((ARect.Right + ARect.Left - FCheck.Width) div 2, (ARect.Bottom + ARect.Top - FCheck.Height) div 2, FCheck)
//        else if Cells[ACol, ARow] = 'FALSE' then
//          Draw((ARect.Right + ARect.Left - FNoCheck.Width) div 2, (ARect.Bottom + ARect.Top - FNoCheck.Height) div 2, FNoCheck)
//      end;
//  end;
end;

procedure TStringGrid.DrawFixedRowNumber;
var
  nR, RowNo: Integer;
begin
  Perform(WM_SETREDRAW, 0, 0);
  try
    if FixedCols > 0 then
    begin
      RowNo := 1;
      for nR := FixedRows to RowCount - 1 do
      begin
        Rows[nR].BeginUpdate;
        try
          if RowHeights[nR] > 0 then
          begin
            Cells[0, nR] := RowNo.ToString;
            Inc(RowNo);
          end;
        finally
          Rows[nR].EndUpdate;
        end;
      end;
    end;
  finally
    Perform(WM_SETREDRAW, 1, 0);
    Invalidate;
  end;
end;

procedure TStringGrid.DrawFixedRowNumbers;
begin
  DrawFixedRowNumber;
end;

procedure TStringGrid.DrawSortArrow(ARect: TRect; ASort: TSortMode; AAlign: TAlignment);
const
  OFFSET = 2;
var
  goLeft: Integer;
begin
  // if AAlign = taLeftJustify then
  goLeft := 0;
  // else
  // goLeft := ARect.Right - ARect.Left - 10;

  // draw triangle
  Canvas.Brush.Color := FSortArrowBackColor;
  Canvas.Pen.Color := FSortArrowBorderColor;
  if ASort = smAsc then
    Canvas.Polygon([Point(OFFSET + ARect.Left + goLeft + 5,
      OFFSET + ARect.Top + 5), Point(OFFSET + ARect.Left + goLeft + 2,
      OFFSET + ARect.Top + 10), Point(OFFSET + ARect.Left + goLeft + 8,
      OFFSET + ARect.Top + 10)])
  else if ASort = smDesc then
    Canvas.Polygon([Point(OFFSET + ARect.Left + goLeft + 2,
      OFFSET + ARect.Top + 5), Point(OFFSET + ARect.Left + goLeft + 8,
      OFFSET + ARect.Top + 5), Point(OFFSET + ARect.Left + goLeft + 5,
      OFFSET + ARect.Top + 10)]);
end;

function TStringGrid.GetCellStyles(ACol, ARow: Integer): TThsStyle;
begin
  if (ACol > ColCount-1) or (ARow > RowCount-1) or (ACOl < 0) or (ARow < 0) then
  begin
    Result := FDefaultCellStyle;
    Exit;
  end;

  if FCellStyles[ACol][ARow] = nil then
  begin
    FCellStyles[ACol][ARow] := TThsStyle.Create(Self);
    if (ACol+1 < FixedCols) or (ARow+1 < FixedRows) then
      FCellStyles[ACol][ARow].Assign(DefaultFixedCellStyle)
    else
      FCellStyles[ACol][ARow].Assign(DefaultCellStyle);
  end;
  Result := FCellStyles[ACol][ARow];
end;

function TStringGrid.GetColCount: integer;
begin
  Result := inherited ColCount;
end;

function TStringGrid.GetDefaultCellStyle: TThsStyle;
begin
  Result := FDefaultCellStyle;
end;

function TStringGrid.GetDefaultFixedCellStyle: TThsStyle;
begin
  Result := FDefaultFixedCellStyle;
end;

function TStringGrid.GetRowCount: integer;
begin
  Result := inherited RowCount;
end;

function TStringGrid.SelectCell(ACol, ARow: Longint): Boolean;
begin
  Result := inherited SelectCell(ACol, ARow);
  if Result then
    Invalidate;
end;

procedure TStringGrid.SetCellCount(OldColCount, NewColCount, OldRowCount, NewRowCount: Integer);
var
  nC, nR: integer;
begin
  if OldColCount > NewColCount then
  begin
    for nC := OldColCount - 1 to NewColCount - 1 do
    begin
      for nR := 0 to NewRowCount do
        FCellStyles[nC][nR].Free;
      Setlength(FCellStyles[nC], 0);
    end;
    SetLength(FCellStyles, NewColCount);
  end
  else if OldColCount < newColCount then
  begin
    SetLength(FCellStyles, NewColCount);
    for nC := OldColCount - 1 to NewColCount - 1 do
      Setlength(FCellStyles[nC], newRowCount);
  end;

  if OldRowCount > NewRowCount then
  begin
    for nC := 0 to NewColCount - 1 do
    begin
      for nR := NewRowCount to OldRowCount - 1 do
      begin
        if FCellStyles[nC][nR] <> nil then
          FCellStyles[nC][nR].Free;
      end;
      Setlength(FCellStyles[nC], NewRowCount);
    end;
  end
  else if OldRowCount < NewRowCount then
  begin
    for nC := 0 to NewColCount - 1 do
      Setlength(FCellStyles[nC], NewRowCount);
  end;
end;

procedure TStringGrid.SetCellStyleCol(ACol: Integer; FixRow: boolean; const Value: TThsStyle);
var
  nR, t: Integer;
begin
  if (ACol > ColCount-1) or (ACol < 0) then
    Exit;

  if FixRow then
    t := 0
  else
    t := FixedRows;

  for nR := t to RowCount - 1 do
  begin
    if FCellStyles[ACol][nR] = nil then
      FCellStyles[ACol][nR] := TThsStyle.Create(Self);
    FCellStyles[ACol][nR].Assign(Value);
  end;

  Invalidate;
end;

procedure TStringGrid.SetCellStyleRow(ARow: Integer; FixCol: Boolean; const Value: TThsStyle);
var
  nC, t: Integer;
begin
  if (ARow > RowCount-1) or (ARow < 0) then
    Exit;

  if FixCol then
    t := 0
  else
    t := FixedCols;

  for nC := t to ColCount - 1 do
  begin
    if FCellStyles[nC][ARow] = nil then
      FCellStyles[nC][ARow] := TThsStyle.Create(Self);
    FCellStyles[nC][ARow].Assign(Value);
  end;

  Invalidate;
end;

procedure TStringGrid.SetCellStyles(ACol, ARow: Integer; const Value: TThsStyle);
begin
  if (ACol > ColCount-1) or (ARow > RowCount-1) or (ACOl < 0) or (ARow < 0) then
    exit;

  if FCellStyles[ACol][ARow] = nil then
    FCellStyles[ACol][ARow] := TThsStyle.Create(Self);
  FCellStyles[ACol][ARow].Assign(Value);
end;

procedure TStringGrid.SetColCount(Value: Longint);
begin
  SetCellCount(inherited ColCount, value, RowCount, RowCount);
  inherited ColCount := Value;
end;

procedure TStringGrid.SetDefaultCellStyle(const Value: TThsStyle);
begin
  FDefaultCellStyle.Assign(Value);
  Self.Color := value.FColor;
  Invalidate;
end;

procedure TStringGrid.SetDefaultFixedCellStyle(const Value: TThsStyle);
begin
  FDefaultFixedCellStyle.Assign(Value);
  FixedColor := Value.FColor;
  Invalidate;
end;

procedure TStringGrid.SetRowCount(Value: Longint);
begin
  SetCellCount(ColCount, ColCount, inherited RowCount, Value);
  inherited RowCount := Value;
end;

procedure TStringGrid.Initialize;
var
  n1: Integer;
  LBmp: TBitmap;
begin
  FSortCol := -1;
  FSortType := smNone;

  FDefaultFixedCellStyle := TThsStyle.Create(Self);
  FDefaultFixedCellStyle.FFont.Color := clWhite;
  FDefaultFixedCellStyle.FFont.Style := [fsBold];
  FDefaultFixedCellStyle.Color := clRed;
  FDefaultFixedCellStyle.FHAlign := taCenter;
  FDefaultFixedCellStyle.FVAlign := vaCenter;
  FDefaultFixedCellStyle.FBorderActive := False;
  FDefaultFixedCellStyle.FDataType := ctString;

  FDefaultCellStyle := TThsStyle.Create(Self);
  FDefaultCellStyle.FHAlign := taLeftJustify;
  FDefaultCellStyle.FVAlign := vaCenter;
  FDefaultCellStyle.FBorderActive := False;

  FAutoColSize := False;

  SetLength(FCellStyles, ColCount);
  for n1 := 0 to ColCount - 1 do
    Setlength(FCellStyles[n1], RowCount);

  FSortArrowBorderColor := clBlack;
  FSortArrowBackColor := clBlack;

  // use for draw checkbox
  FCheck := TBitmap.Create;
  FNoCheck := TBitmap.Create;
  LBmp := TBitmap.Create;
  try
    LBmp.Handle := LoadBitmap(0, PChar(OBM_CHECKBOXES));

    with FNoCheck do
    begin
      Width := LBmp.Width div 4;
      Height := LBmp.Height div 3;
      Canvas.CopyRect(Canvas.ClipRect, LBmp.Canvas, Canvas.ClipRect);
    end;

    with FCheck do
    begin
      Width := LBmp.Width div 4;
      Height := LBmp.Height div 3;
      Canvas.CopyRect(Canvas.ClipRect, LBmp.Canvas, Rect(Width, 0, 2 * Width, Height));
    end;
  finally
    LBmp.Free;
  end;
end;

procedure TStringGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  ACol, ARow: Integer;
begin
  FColResized := False;
  inherited;

  if (Button = mbLeft) and not FColResized then
  begin
    MouseToCell(X, Y, ACol, ARow);
    if FixedCols - 1 < ACol then
      if ARow > -1 then // s�n�r d���nda t�klama olursa
        if ARow <= FixedRows - 1 then
          SortStringGrid(ACol);
  end;
end;

procedure TStringGrid.RowMoved(FromIndex, ToIndex: Longint);
var
  nC, nR: integer;
  LTemp: TThsStyle;
begin
  if FromIndex>ToIndex then
  begin
    for nC := 0 to ColCount - 1 do
    begin
      LTemp := FCellStyles[nC][FromIndex];
      for nR:=FromIndex-1 downto ToIndex do
        FCellStyles[nC][nR+1] := FCellStyles[nC][nR];
      FCellStyles[nC][ToIndex] := LTemp;
    end;
  end else
  begin
    for nC := 0 to ColCount - 1 do
    begin
      LTemp := FCellStyles[nC][FromIndex];
      for nR:=FromIndex to ToIndex-1 do
        FCellStyles[nC][nR] := FCellStyles[nC][nR+1];
      FCellStyles[nC][ToIndex] := LTemp;
    end;
  end;
  inherited RowMoved(FromIndex, ToIndex);

  DrawFixedRowNumber;
end;

procedure TStringGrid.FixedCellClick(ACol, ARow: Longint);
begin
  inherited;
  //
end;

procedure TStringGrid.ColWidthsChanged;
begin
  inherited;
  FColResized := True;
end;

procedure TStringGrid.ConditionDrawCell(Sender: TObject; ARow, ACol: Longint; var Value: string; var AStyle: TThsStyle);
begin
  if Assigned(FOnConditionDrawCell) then
    FOnConditionDrawCell(Sender, ARow, ACol, Value, AStyle);
end;

procedure TStringGrid.SizeChanged(OldColCount, OldRowCount: Longint);
begin
  DrawFixedRowNumber;
end;

procedure TStringGrid.SortStringGrid(ACol: Integer);
var
  n1: Integer;
  LSortType: TSortMode;
  LTempGrid: TStringGrid;
  LRowNoList: array of Integer;
begin
  Screen.Cursor := crHourGlass;
  Perform(WM_SETREDRAW, 0, 0);
  Cols[ACol].BeginUpdate;
  LTempGrid := TStringGrid.Create(Self);
  try
    LSortType := smNone;

    LTempGrid.RowCount := Self.RowCount;
    LTempGrid.ColCount := Self.ColCount;
    LTempGrid.FixedRows := Self.FixedRows;

    SetLength(LRowNoList, RowCount - FixedRows);

    // fill sorted grid row numbers and fill grid rows to tempgrid rows
    for n1 := FixedRows to RowCount - 1 do
    begin
      LRowNoList[n1 - FixedRows] := n1;
      LTempGrid.Rows[n1].Assign(Rows[n1]);
    end;


    if (FSortType = smNone) // first sort
    or (FSortCol <> ACol) // sort col is different from last sort col
    or ((FSortType = smDesc) and (FSortCol = ACol))  // sort col same as last sort col and last sort is desc
    then
      LSortType := smAsc
    else if (FSortType = smAsc) and (FSortCol = ACol) then  // sort col same as last sort col and last sort is asc
      LSortType := smDesc;

    SortMerge(LRowNoList, ACol, LSortType);

    for n1 := 0 to RowCount - FixedRows - 1 do
      Rows[n1 + FixedRows].Assign(LTempGrid.Rows[LRowNoList[n1]]);

    Row := FixedRows;

    FSortType := LSortType;
    FSortCol := ACol;
  finally
    Cols[ACol].EndUpdate;
    LTempGrid.Free;
    SetLength(LRowNoList, 0);
    Screen.Cursor := crDefault;

    Perform(WM_SETREDRAW, 1, 0);

    DrawFixedRowNumber;

    Invalidate;
  end;
end;

procedure TStringGrid.SortMerge(var ARowNoList: array of Integer; ACol: Integer; ASortMode: TSortMode);
var
  AVals: array of Integer;

  function Compare(Value1, Value2: string; ACellDataType: TThsDataType): Integer;
  begin
    Result := EqualsValue;
    case ACellDataType of
      ctString:     Result := AnsiCompareText(Value1, Value2);
      ctInteger:    Result := CompareValue(StrToIntDef(Value1,0), StrToIntDef(Value2,0));
      ctDouble:     Result := CompareValue(StrToFloatDef(Value1,0), StrToFloatDef(Value2,0));
      ctDate:       Result := CompareValue(StrToDateDef(Value1,0), StrToDateDef(Value2,0));
      ctTime:       Result := CompareValue(StrToTimeDef(Value1,0), StrToTimeDef(Value2,0));
      ctDateTime:   Result := CompareValue(StrToDateTimeDef(Value1,0), StrToDateTimeDef(Value2,0));
      ctBcd:        Result := CompareValue(StrToFloatDef(Value1,0), StrToFloatDef(Value2,0));
      ctBoolean:    Result := AnsiCompareText(Value1, Value2);
    end;
  end;

  procedure Merge(ALow, AMiddle, AHigh: Integer);
  var
    i, j, k, m: Integer;
    LCompareResult: Integer;
  begin
    i := 0;
    SetLength(AVals, AMiddle - ALow + 1);
    for j := ALow to AMiddle do
    begin
      AVals[i] := ARowNoList[j];
      Inc(i);
    end;

    i := 0;
    j := AMiddle + 1;
    k := ALow;
    while (k < j) and (j <= AHigh) do
    begin
      LCompareResult := Compare(Cells[ACol, ARowNoList[j]], Cells[ACol, AVals[i]], CellStyles[ACol, ARowNoList[j]].FDataType);
      if ((ASortMode = smAsc) and (LCompareResult <> LessThanValue)) or
        ((ASortMode = smDesc) and (LCompareResult <> GreaterThanValue))
      then
      begin
        ARowNoList[k] := AVals[i];
        Inc(i);
        Inc(k);
      end
      else
      begin
        ARowNoList[k] := ARowNoList[j];
        Inc(k);
        Inc(j);
      end;
    end;

    for m := k to j - 1 do
    begin
      ARowNoList[m] := AVals[i];
      Inc(i);
    end;
  end;

  procedure PerformSortMerge(ALow, AHigh: Integer);
  var
    AMiddle: Integer;
  begin
    if (ALow < AHigh) then
    begin
      AMiddle := (ALow + AHigh) shr 1;
      PerformSortMerge(ALow, AMiddle);
      PerformSortMerge(AMiddle + 1, AHigh);
      Merge(ALow, AMiddle, AHigh);
    end;
  end;

begin
  if (ASortMode <> smNone) then
    PerformSortMerge(0, High(ARowNoList));
end;

end.
