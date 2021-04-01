unit ThsStringGrid;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Grids, Vcl.Graphics;

//  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
//  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
//  Vcl.ExtCtrls, Vcl.AppEvnts, Vcl.Menus,
//  Vcl.Grids,
//  Data.DB

type
  TThsCellDataType = (ctString, ctInteger, ctDouble, ctDate, ctTime, ctDateTime, ctBcd);

  TThsBorderStyle = record
    Enable: Boolean;
    Color: TColor;
    Width: Byte;
  end;

  TSumTotalRows = class
  private
    FSummedColNo: Integer;
    FSummedStartRowNo: Integer;
    FSummedEndRowNo: Integer;
    FRowNo: Integer;
    FColNo: Integer;
  public
    property SummedColNo: Integer read FSummedColNo write FSummedColNo;
    property SummedStartRowNo: Integer read FSummedStartRowNo write FSummedStartRowNo;
    property SummedEndRowNo: Integer read FSummedEndRowNo write FSummedEndRowNo;
    property RowNo: Integer read FRowNo write FRowNo;
    property ColNo: Integer read FColNo write FColNo;
  end;

  TThsCellBorder = record
    FLeft: TThsBorderStyle;
    FRight: TThsBorderStyle;
    FTop: TThsBorderStyle;
    FBottom: TThsBorderStyle;
  public
    property Left: TThsBorderStyle read FLeft write FLeft;
    property Right: TThsBorderStyle read FRight write FRight;
    property Top: TThsBorderStyle read FTop write FTop;
    property Bottom: TThsBorderStyle read FBottom write FBottom;
  end;

  TThsCellStyle = class
  private
    FDataType: TThsCellDataType;
    FFont: TFont;
    FColor: TColor;
    FTextAlign: TAlignment;
    FBorder: TThsCellBorder;
  public
    property DataType: TThsCellDataType read FDataType write FDataType;
    property Font: TFont read FFont write FFont;
    property Color: TColor read FColor write FColor;
    property TextAlign: TAlignment read FTextAlign write FTextAlign;
    property Border: TThsCellBorder read FBorder write FBorder;

    constructor Create(AGrid: TStringGrid);
    destructor Destroy; override;
  end;

  TThsStyledCells = class
  private
    FRowNo: Integer;
    FColNo: Integer;
    FStyle: TThsCellStyle;
  public
    constructor Create(AGrid: TStringGrid);
    destructor Destroy; override;

    property RowNo: Integer read FRowNo write FRowNo;
    property ColNo: Integer read FColNo write FColNo;
    property Style: TThsCellStyle read FStyle write FStyle;
  end;

  TThsStyledCols = class
  private
    FColNo: Integer;
    FStyle: TThsCellStyle;
  public
    constructor Create(AGrid: TStringGrid);
    destructor Destroy; override;

    property ColNo: Integer read FColNo write FColNo;
    property Style: TThsCellStyle read FStyle write FStyle;
  end;

  TThsStringGrid = class(TStringGrid)
  private
    FStyledColList: TList;
    FStyledCellList: TList;
    FSumCellList: TList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareGrid();

    function ExistsStyledCol(ACol: Integer): Boolean;
    function GetStyledCol(ACol: Integer): TThsCellStyle;
    function AddStyledCol(AStyle: TThsStyledCols): Integer;

    function ExistsStyledCell(ARow, ACol: Integer): Boolean;
    function GetStyledCell(ARow, ACol: Integer): TThsCellStyle;
    function AddStyledCell(AStyle: TThsStyledCells): Integer;
  published
    property StyledCellList: TList read FStyledCellList write FStyledCellList;
    property SumCellList: TList read FSumCellList write FSumCellList;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TThsStringGrid]);
end;

constructor TThsCellStyle.Create(AGrid: TStringGrid);
begin
  FDataType := ctString;

  FFont := TFont.Create;
  FFont.Name := AGrid.Font.Name;
  FFont.Size := AGrid.Font.Size;
  FFont.Style := AGrid.Font.Style;
  FFont.Color := AGrid.Font.Color;

  FColor := clWhite;
  FTextAlign := taLeftJustify;

  FBorder.FLeft.Enable := True;
  FBorder.FLeft.Color := clBlack;
  FBorder.FLeft.Width := 1;
  FBorder.FRight.Enable := True;
  FBorder.FRight.Color := clBlack;
  FBorder.FRight.Width := 1;
  FBorder.FTop.Enable := True;
  FBorder.FTop.Color := clBlack;
  FBorder.FTop.Width := 1;
  FBorder.FBottom.Enable := True;
  FBorder.FBottom.Color := clBlack;
  FBorder.FBottom.Width := 1;
end;

destructor TThsCellStyle.Destroy;
begin
  FFont.Free;

  inherited;
end;

function TThsStringGrid.AddStyledCell(AStyle: TThsStyledCells): Integer;
begin
  Result := FStyledCellList.Add(AStyle);
end;

function TThsStringGrid.AddStyledCol(AStyle: TThsStyledCols): Integer;
begin
  Result := FStyledColList.Add(AStyle);
end;

constructor TThsStringGrid.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TThsStringGrid.Destroy;
begin
  if Assigned(FSumCellList) then
    FSumCellList.Free;
  if Assigned(FStyledCellList) then
    FStyledCellList.Free;
  if Assigned(FStyledColList) then
    FStyledColList.Free;
  inherited;
end;

function TThsStringGrid.ExistsStyledCell(ARow, ACol: Integer): Boolean;
var
  n1: Integer;
  LLen: Integer;
begin
  Result := False;
  LLen := FStyledCellList.Count;
  for n1 := 0 to LLen-1 do
  begin
    if  (TThsStyledCells(FStyledCellList[n1]).FRowNo = ARow)
    and (TThsStyledCells(FStyledCellList[n1]).FColNo = ACol)
    then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TThsStringGrid.ExistsStyledCol(ACol: Integer): Boolean;
var
  n1: Integer;
  LLen: Integer;
begin
  Result := False;
  LLen := FStyledColList.Count;
  for n1 := 0 to LLen-1 do
  begin
    if (TThsStyledCols(FStyledColList[n1]).FColNo = ACol) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TThsStringGrid.GetStyledCell(ARow, ACol: Integer): TThsCellStyle;
var
  n1: Integer;
  LLen: Integer;
begin
  Result := nil;
  LLen := FStyledCellList.Count;
  for n1 := 0 to LLen-1 do
  begin
    if  (TThsStyledCells(FStyledCellList[n1]).FRowNo = ARow)
    and (TThsStyledCells(FStyledCellList[n1]).FColNo = ACol)
    then
    begin
      Result := TThsStyledCells(FStyledCellList[n1]).FStyle;
      Exit;
    end;
  end;
end;

function TThsStringGrid.GetStyledCol(ACol: Integer): TThsCellStyle;
var
  n1: Integer;
  LLen: Integer;
begin
  Result := nil;
  LLen := FStyledColList.Count;
  for n1 := 0 to LLen-1 do
  begin
    if (TThsStyledCols(FStyledColList[n1]).FColNo = ACol) then
    begin
      Result := TThsStyledCols(FStyledColList[n1]).FStyle;
      Exit;
    end;
  end;
end;

procedure TThsStringGrid.PrepareGrid;
begin
  FSumCellList := TList.Create;
  FStyledCellList := TList.Create;
  FStyledColList := TList.Create;
end;

constructor TThsStyledCells.Create(AGrid: TStringGrid);
begin
  inherited Create;
  FStyle := TThsCellStyle.Create(AGrid);
end;

destructor TThsStyledCells.Destroy;
begin
  FStyle.Free;
  inherited;
end;

constructor TThsStyledCols.Create(AGrid: TStringGrid);
begin
  inherited Create;
  FStyle := TThsCellStyle.Create(AGrid);
end;

destructor TThsStyledCols.Destroy;
begin
  FStyle.Free;
  inherited;
end;

end.
