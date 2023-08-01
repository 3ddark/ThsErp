unit Ths.Helper.Edit;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Winapi.Messages,
  Winapi.Windows,
  System.StrUtils,
  System.DateUtils,
  Vcl.Themes,
  Vcl.Mask,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  ClipBrd,
  System.UITypes,
  Ths.Constants,
  Ths.Helper.BaseTypes;

{$M+}

type
  TEditStyleHookColor = class(TEditStyleHook)
  private
    procedure UpdateColors;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  published
    property OverridePaint;
  end;

type
  TEdit = class(Vcl.StdCtrls.TEdit)
  private
    FOnHelperProcess      : TNotifyEvent;
    FHelperValue          : Variant;
    FOnCalculatorProcess  : TNotifyEvent;
    FOldBackColor         : TColor;
    FColorDefault         : TColor;
    FColorActive          : TColor;
    FColorRequiredInput   : TColor;
    {$IFDEF VER150}
    FAlignment            : TAlignment;
    {$ENDIF}
    FEnterAsTabKey        : Boolean;
    FInputDataType        : TInputType;
    FDecimalDigitCount    : Integer;
    FRequiredData         : Boolean;
    FDoTrim               : Boolean;
    FActiveYear4Digit     : Integer;
    FDBFieldName          : string;
    FInfo                 : string;
    FWrongDateMessage     : string;
    FOldValue             : string;

    DatePicker: TDateTimePicker;

    FAllSelected: Boolean;

    {$IFDEF VER150}
    procedure SetAlignment(const pValue: TAlignment);
    {$ENDIF}

    function IntegerKeyControl(AKey: Char): Char;
    function FloatKeyControl(AKey: Char; ADecimalDigits: Integer): Char;
    function MoneyKeyControl(AKey: Char; ADecimalDigits: Integer): Char;
    function DateKeyControl(AKey: Char): Char;

    function ValidateDate():boolean;
    procedure SetHelperProcess(const Value: TNotifyEvent);
    procedure SetInputDataType(const Value: TInputType);
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyPress(var Key: Char); override;
    procedure MyOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HelperProcess();virtual;
    procedure CalculatorProcess();virtual;
    procedure Change; override;

    procedure CreateParams(var pParams: TCreateParams); override;
  public
    destructor Destroy; override;
    property OnHelperProcess: TNotifyEvent read FOnHelperProcess write SetHelperProcess;
    property HelperValue: Variant read FHelperValue write FHelperValue;

    property OnCalculatorProcess: TNotifyEvent read FOnCalculatorProcess write FOnCalculatorProcess;

    constructor Create(AOwner: TComponent); override;
    procedure Repaint();override;

    procedure WndProc(var Message: TMessage); override;

    procedure DoubleToMoney();
    procedure DatePickerCloseUp(Sender: TObject);
    procedure DblClick; override;
  published
    {$IFDEF VER150}
    property thsAlignment            : TAlignment      read FAlignment             write SetAlignment;
    {$ENDIF}
    property thsColorActive          : TColor          read FColorActive           write FColorActive;
    property thsColorRequiredInput   : TColor          read FColorRequiredInput    write FColorRequiredInput;
    property thsTabEnterKeyJump      : Boolean         read FEnterAsTabKey         write FEnterAsTabKey;
    property thsInputDataType        : TInputType      read FInputDataType         write SetInputDataType;
    property thsDecimalDigitCount    : Integer         read FDecimalDigitCount     write FDecimalDigitCount;
    property thsRequiredData         : Boolean         read FRequiredData          write FRequiredData;
    property thsDoTrim               : Boolean         read FDoTrim                write FDoTrim;
    property thsActiveYear4Digit     : Integer         read FActiveYear4Digit      write FActiveYear4Digit;
    property thsDBFieldName          : string          read FDBFieldName           write FDBFieldName;
    property thsInfo                 : string          read FInfo;
    property thsWrongDateMessage     : string          read FWrongDateMessage      write FWrongDateMessage;
    property thsOldValue             : string          read FOldValue              write FOldValue;

    function moneyToDouble: Double;
  end;

  procedure DrawHelperSing(Sender: TEdit);

implementation

uses
  Vcl.Styles
  {$IFDEF THSERP}, ufrmBaseInputDB{$ENDIF}
  ;

var
  FPickerReturn : Boolean = false;

type
  TWinControlH = class(TWinControl);

procedure DrawHelperSing(Sender: TEdit);
var
  vControlCanvas: TControlCanvas;
begin
  if Assigned(Sender.FOnHelperProcess) then
  begin
    vControlCanvas := TControlCanvas.Create;
    try
      vControlCanvas.Control := Sender;
      vControlCanvas.Brush.Color := clBlue;
      vControlCanvas.Pen.Style := psSolid;
      vControlCanvas.Rectangle(Sender.Width-8, 1, Sender.Width-2, 6);
      vControlCanvas.Pen.Style := psClear;
    finally
      FreeAndNil(vControlCanvas);
    end;
  end;
end;

constructor TEditStyleHookColor.Create(AControl: TWinControl);
begin
  inherited;
  UpdateColors;
end;

procedure TEditStyleHookColor.UpdateColors;
var
  vStyle: TCustomStyleServices;
begin
  if Control.ClassType = TEdit then
  begin
    if Control.Enabled then
    begin
      Brush.Color := TWinControlH(Control).Color;
      FontColor := TWinControlH(Control).Font.Color;

      Brush.Color := TEdit(Control).FColorDefault;
      if TEdit(Control).thsRequiredData then
        if TEdit(Control).Showing and (TEdit(Control).Text = '') then
          Brush.Color := TEdit(Control).FColorRequiredInput;
      if TEdit(Control).Focused then
        Brush.Color := TEdit(Control).FColorActive;
    end
    else
    begin
      vStyle := StyleServices;
      Brush.Color := vStyle.GetStyleColor(scEditDisabled);
      FontColor := vStyle.GetStyleFontColor(sfEditBoxTextDisabled);

      Brush.Color := TEdit(Control).FColorDefault;
      if TEdit(Control).thsRequiredData then
        if TEdit(Control).Showing and (TEdit(Control).Text = '') then
          Brush.Color := TEdit(Control).FColorRequiredInput;
      if TEdit(Control).Focused then
        Brush.Color := TEdit(Control).FColorActive;
    end;
  end
  else
    inherited;
end;

procedure TEditStyleHookColor.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CN_CTLCOLORMSGBOX..CN_CTLCOLORSTATIC:
      begin
        UpdateColors;
        SetTextColor(Message.WParam, ColorToRGB(FontColor));
        SetBkColor(Message.WParam, ColorToRGB(Brush.Color));
        Message.Result := LRESULT(Brush.Handle);
        Handled := True;
      end;
    CM_ENABLEDCHANGED:
      begin
        UpdateColors;
        Handled := False;
      end
  else
    inherited WndProc(Message);
  end;
end;

procedure TEdit.CreateParams(var pParams: TCreateParams);
const
  Alignments: array[TAlignment] of DWORD = (ES_LEFT, ES_RIGHT, ES_CENTER);
var
  vYear, vMonth, vDay: Word;
begin
  inherited CreateParams(pParams);

{$IFDEF VER150}
  with pParams do
    Style := Style or Alignments[FAlignment];
{$ENDIF}

  DecodeDate(Now, vYear, vMonth, vDay);
  if FActiveYear4Digit = 0 then
    FActiveYear4Digit := vYear;
end;

procedure TEdit.Change;
begin
//  if thsInputDataType = itMoney then
//    Self.Repaint;
//  if thsInputDataType = itFloat then
//    Self.Repaint;
  inherited;
end;

constructor TEdit.Create(AOwner: TComponent);
var
  vDay, vMonth, vYear: Word;
  vDate: TDateTime;
begin
  inherited;
  Font.Name := DefaultFontName;

  vDate := Now;
  DecodeDate(vDate, vYear, vMonth, vDay);

  FColorDefault         := Color;
  FColorActive          := clSkyBlue;
  FColorRequiredInput   := $00706CEC;
  {$IFDEF VER150}
  FAlignment            := taLeftJustify;
  {$ELSE}
  Alignment             := taLeftJustify;
  {$ENDIF}
  FInputDataType        := itString;
  FEnterAsTabKey        := True;
  FDecimalDigitCount    := 2;
  FRequiredData         := False;
  FDoTrim               := True;
  FActiveYear4Digit     := vYear;
  FDBFieldName          := '';
  FInfo                 := 'Thundersoft Edit Component(3ddark) v0.2';
  FWrongDateMessage     := 'Hatalý tarih giriþi!';
  OnKeyDown             := MyOnKeyDown;
  FHelperValue          := vaNull;

  Self.DoubleBuffered := True;
end;

procedure TEdit.DoEnter;
begin
  FOldBackColor := Color;
  Color := thsColorActive;

  if thsInputDataType = itMoney then
  begin
    if (Trim(Self.Text) <> '') and (not Self.ReadOnly) then
    begin
      Self.Text := StringReplace(Self.Text, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
      Self.SelStart := Length(Self.Text);
      Self.SelectAll;
    end;
  end;

  inherited;
end;

procedure TEdit.DoExit;
begin
  if Self.Text = '0' then
  begin
    case thsInputDataType of
      itString : Self.Clear;
      itDate   : Self.Clear;
      itTime   : Self.Clear;
    end;
  end;

  if Self.Text = '0,' then
  begin
    case thsInputDataType of
      itFloat   : Self.Text := '0';
      itMoney   : Self.Text := '0';
    end;
  end;

  if (FRequiredData) and (Trim(Self.Text) = '') then
    Color := FColorRequiredInput
  else
  begin
    if FOldBackColor = FColorRequiredInput then
      Color := FColorDefault
    else
    begin
      if FOldBackColor = 0 then
        FOldBackColor := Color;
      Color := FOldBackColor;
    end;
  end;

  case thsInputDataType of
    itInteger : ;
    itMoney   : DoubleToMoney;
    itDate    : ValidateDate;
    itFloat   :
    begin
      if (RightStr(Text, 1) = FormatSettings.DecimalSeparator) then
        Text := Text + StringOfChar('0', thsDecimalDigitCount)
      else if (Pos(FormatSettings.DecimalSeparator, Text) = 0) then
        Text := Text + FormatSettings.DecimalSeparator + StringOfChar('0', thsDecimalDigitCount)
      else if (Length(Text) - Pos(FormatSettings.DecimalSeparator, Text) < thsDecimalDigitCount) then
        Text := Text + StringOfChar('0', thsDecimalDigitCount - (Length(Text) - Pos(FormatSettings.DecimalSeparator, Text)));
    end;
  end;

  if FDoTrim then
    Self.Text := Trim(Self.Text);

  inherited;
end;

procedure TEdit.DoubleToMoney;
var
  LOldPos, LOldLen: Integer;
begin
  if (Trim(Self.Text) <> '') then
  begin
    LOldPos := Self.SelStart;
    LOldLen := Self.GetTextLen;
    Self.Text := FormatFloat('0' + FormatSettings.ThousandSeparator +
                             FormatSettings.DecimalSeparator +
                             StringOfChar('0', Self.FDecimalDigitCount),
                             moneyToDouble);
    if FAllSelected then
      Self.SelStart := LOldPos
    else
      Self.SelStart := LOldPos + Self.GetTextLen - LOldLen;
  end;
end;

procedure TEdit.KeyPress(var Key: Char);
begin
  if Assigned(FOnHelperProcess) then
    Self.ReadOnly := True;

  if not Self.ReadOnly then
  begin
    if FInputDataType = itString then
    begin
      if Self.CharCase = ecUpperCase then
        Key := Ths.Helper.BaseTypes.UpCaseTr(Key)
      else if Self.CharCase = ecLowerCase then
        Key := Ths.Helper.BaseTypes.LowCaseTr(Key);
    end;

    case FInputDataType of
      itInteger : Key := IntegerKeyControl(Key);
      itFloat   : Key := FloatKeyControl(Key, FDecimalDigitCount);
      itMoney   : Key := MoneyKeyControl(Key, FDecimalDigitCount);
      itDate    : Key := DateKeyControl(Key);
    else
      inherited KeyPress(Key);
    end;

    if FEnterAsTabKey AND (Owner is TWinControl) then
    begin
      if Key = Char(VK_RETURN) then
      begin
        Key := #0;
        if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
          PostMessage((Owner as TWinControl).Handle, WM_NEXTDLGCTL, 1, 0)
        else
          PostMessage((Owner as TWinControl).Handle, WM_NEXTDLGCTL, 0, 0);
      end;
    end;
  end;
end;

procedure TEdit.MyOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LVal: Double;
begin
  if (Key = VK_F1) then
  begin
    if thsInputDataType = itDate then
    begin
      if Self.Enabled and not Self.ReadOnly then
      begin
        if FPickerReturn then begin
          FPickerReturn := False;
          Exit;
        end;

        DatePicker := TDateTimePicker.Create(Self);
        DatePicker.Visible := False;
        DatePicker.OnCloseUp := DatePickerCloseUp;
        DatePicker.Parent := Self.Parent;
        DatePicker.SendToBack;

        if (Self.Text <> '') then
          DatePicker.DateTime := StrTodateTime( Self.Text )
        else
          DatePicker.DateTime := Int(Now);

        DatePicker.Left  := Self.Left;
        DatePicker.Top   := Self.Top;
        DatePicker.Width := Self.Width;

        DatePicker.Visible := True;
        DatePicker.Perform(WM_KEYDOWN, VK_F4, 0);
//        DatePicker.Perform( WM_KEYUP, VK_F4, 0);

        DatePicker.Visible := True;
        DatePicker.BringToFront;

      end;
    end
    else
    begin
      if Assigned(FOnHelperProcess) then
        FOnHelperProcess(Self);
    end;
  end
  else
  if (Key = VK_F9) then
  begin
    if not ReadOnly and Enabled and Visible then
    begin
      if thsInputDataType = itDate then
        Text := DateToStr(EncodeDate(thsActiveYear4Digit, MonthOfTheYear(Now), DayOfTheMonth(Now)))
      else if thsInputDataType = itTime then
        Text := TimeToStr(Now);
    end;
  end
  else
  if (Key = VK_F12) then
  begin
    if Assigned(FOnCalculatorProcess) then
      FOnCalculatorProcess(Self);
  end
  else
  begin
    if ssCtrl in Shift then
    begin
      if (Key = Ord('v')) or (Key = Ord('V')) then
      begin
        Key := 0;
        Shift := [];
        if TryStrToFloat(Clipboard.AsText, LVal) then
          Self.Text := Clipboard.AsText;
      end
      else if (Key = Ord('x')) or (Key = Ord('X')) then
      begin
        Key := 0;
        Shift := [];
        Clipboard.Clear;
        Clipboard.AsText := Self.Text;
      end
      else if (Key = Ord('a')) or (Key = Ord('A')) then
      begin
        Key := 0;
        Self.SelectAll;
      end;
    end;
  end;
end;

function TEdit.IntegerKeyControl(AKey: Char): Char;
begin
  if not CharInSet(AKey, [#13{Enter}, #8{Backspace}, '0'..'9']) then
    AKey := #0;
  Result := AKey;
end;

function TEdit.DateKeyControl(AKey: Char): Char;
begin
  if (CharInSet(AKey, ['-', '/', '.', ',', FormatSettings.DateSeparator])) then
    AKey := FormatSettings.DateSeparator;

  if  (Length(Self.Text) = Self.SelLength) and (not Self.ReadOnly)
  and (CharInSet(AKey, ['0'..'9', #8{Backspace}, FormatSettings.DateSeparator]))
  then
    Self.Clear;

  if not CharInSet(AKey, [#13{Return}, #8{Backspace}, '0'..'9', FormatSettings.DateSeparator])
  or ((Length(Self.Text) = 0) and ((AKey = FormatSettings.DateSeparator)))
  then
    AKey := #0;

  Result := AKey;
end;

procedure TEdit.DatePickerCloseUp(Sender: TObject);
begin
  Self.Text := FormatDateTime(FormatSettings.ShortDateFormat, DatePicker.DateTime);
  TDateTimePicker(Sender).Visible := False;
  FPickerReturn := False;
  if Assigned(DatePicker) then
    DatePicker.Free;
  Self.SetFocus;
end;

procedure TEdit.DblClick;
begin
  inherited;
  if thsInputDataType = itDate then
  begin
    if Self.Enabled and not Self.ReadOnly then
    begin
      if FPickerReturn then
      begin
        FPickerReturn := False;
        Exit;
      end;

      DatePicker := TDateTimePicker.Create(Self);
      DatePicker.Visible := False;
      DatePicker.OnCloseUp := DatePickerCloseUp;
      DatePicker.Parent := Self.Parent;
      DatePicker.SendToBack;

      if (Self.Text <> '') then
        DatePicker.DateTime := StrTodateTime( Self.Text )
      else
        DatePicker.DateTime := Int(Now);

      DatePicker.Left  := Self.Left;
      DatePicker.Top   := Self.Top;
      DatePicker.Width := Self.Width;

      DatePicker.Visible := True;
      DatePicker.Perform(WM_KEYDOWN, VK_F4, 0);
//        DatePicker.Perform( WM_KEYUP, VK_F4, 0);

      DatePicker.Visible := True;
    end;
  end
  else
  begin
    if Assigned(FOnHelperProcess) then
      FOnHelperProcess(Self);
  end;
end;

destructor TEdit.Destroy;
begin
  inherited;
end;

procedure TEdit.Repaint;
begin
  if (FRequiredData) and (Trim(Self.Text) = '') then
    Color := FColorRequiredInput
  else
  begin
    if FOldBackColor = FColorRequiredInput then
      Color := FColorDefault
    else
    begin
      if FOldBackColor = 0 then
        FOldBackColor := Color;
      Color := FOldBackColor;
    end;
  end;

  inherited;

  if thsInputDataType = itMoney then
    DoubleToMoney;

  if thsInputDataType = itFloat then
  begin
    if (RightStr(Text, 1) = FormatSettings.DecimalSeparator) then
      Text := Text + StringOfChar('0', thsDecimalDigitCount)
    else if (Pos(FormatSettings.DecimalSeparator, Text) = 0) then
      Text := Text + FormatSettings.DecimalSeparator + StringOfChar('0', thsDecimalDigitCount)
    else if (Length(Text) - Pos(FormatSettings.DecimalSeparator, Text) < thsDecimalDigitCount) then
      Text := Text + StringOfChar('0', thsDecimalDigitCount - (Length(Text) - Pos(FormatSettings.DecimalSeparator, Text)));
  end;

  DrawHelperSing(Self);
end;

{$IFDEF VER150}
procedure TEdit.SetAlignment(const pValue: TAlignment);
begin
  FAlignment := pValue;
end;
{$ENDIF}

procedure TEdit.SetHelperProcess(const Value: TNotifyEvent);
begin
  FOnHelperProcess := Value;
  Self.thsInputDataType := itString;
  Self.ReadOnly := True;
end;

procedure TEdit.SetInputDataType(const Value: TInputType);
begin
  Self.Clear;
  FInputDataType := Value;
end;

function TEdit.moneyToDouble: Double;
begin
  Result := 0.0;
  if Trim(Text) <> '' then
    Result := Ths.Helper.BaseTypes.moneyToDouble(Text, thsInputDataType);
end;

function TEdit.FloatKeyControl(AKey: Char; ADecimalDigits: Integer): Char;
var
  LDividedStr: TStringList;
  LPrev, LIntPart, LDecimalPart: String;
begin
  Result := #0;

  if (CharInSet(AKey, ['.', ',', FormatSettings.DecimalSeparator])) then
    AKey := FormatSettings.DecimalSeparator;

  if CharInSet(AKey, [#8, '0'..'9', FormatSettings.DecimalSeparator]) then
    Self.Modified := True;

  //Tümünü seçip yazarsa eski bilgiyi temizle
  if (Length(Self.Text) = Self.SelLength) and (CharInSet(AKey, [#8, '0'..'9', FormatSettings.DecimalSeparator])) then
    Self.Clear;

  //Aradan bilgi girilemez
//  if (Length(Self.Text) > Self.SelStart) and (AKey <> #13) then
//  begin
//    if ContainsStr(Self.Text, FormatSettings.DecimalSeparator) then
//      AKey := #0;
//  end;

  //tanýmlý tuþlar harici tuþlar girilmez veya seperator sadece bir kere girilebilir
  if not CharInSet(AKey, [#13, #8, '0'..'9', FormatSettings.DecimalSeparator]) then
    AKey := #0;
  if (AKey = FormatSettings.DecimalSeparator) and (Pos(AKey, Self.Text) > 0) then
    AKey := #0;

  if (Self.MaxLength <> 0) and (Length(Self.Text) = Self.MaxLength) and (not CharInSet(AKey, [#13, #8])) then
    AKey := #0;

  if AKey <> #0 then
  begin
    LPrev := Self.Text;

    if (Length(LPrev) = 0) then
    begin
      if AKey = #13 then
        Result := AKey
      else if AKey = '0' then
      begin
        Result := AKey
      end
      else if AKey = FormatSettings.DecimalSeparator then
      begin
        Result := AKey;
        Self.Text := '0';
        Self.SelStart := 1;
      end
      else if CharInSet(AKey, ['1'..'9']) then
        Result := AKey;
    end
    else if (Length(LPrev) > 0) then
    begin
      if (Pos(FormatSettings.DecimalSeparator, Self.Text) > 0) then
      begin
        LDividedStr := TStringList.Create;
        try
          Assert(Assigned(LDividedStr)) ;
          LDividedStr.Clear;
          LDividedStr.Delimiter := FormatSettings.DecimalSeparator;
          LDividedStr.DelimitedText := LPrev;

          LIntPart := LDividedStr[0];
          LDecimalPart := LDividedStr[1];

          if (Length(LDecimalPart) < ADecimalDigits) then
          begin
            if (AKey = #13) then
              Self.Text := Self.Text + StringOfChar('0', ADecimalDigits-Length(LDecimalPart));
            Result := AKey;
          end
          else
          begin
            if (AKey = #13) or (AKey = #8) then
              Result := AKey;
          end;
        finally
          LDividedStr.Destroy;
        end;
      end
      else
      begin
        if (AKey = #13) then
          Self.Text := Self.Text + FormatSettings.DecimalSeparator + StringOfChar('0', ADecimalDigits-Length(LDecimalPart));
        Result := AKey;
      end;

    end;
    //Self.SelStart := Length(Self.Text);
  end;
end;

procedure TEdit.HelperProcess;
begin
  if Assigned(FOnHelperProcess) then
    FOnHelperProcess(Self);
end;

procedure TEdit.CalculatorProcess;
begin
  if Assigned(FOnCalculatorProcess) then
    FOnCalculatorProcess(Self);
end;

function TEdit.ValidateDate(): Boolean;
var
  vDay, vMonth, vYear, vDate: string;
begin
  Result := True;
  try
    vDate := Self.Text;
    if Length(vDate) < 4 then
    begin
      if Length(vDate) = 1 then
        vDay := LeftStr(vDate, 1);

      if Length(vDate) = 2 then
        vDay := LeftStr(vDate, 2);

      if Length(vDate) = 3 then
        vMonth  := vDate[3];
    end
    else if Length(vDate) = 4 then
    begin
      if Pos(FormatSettings.DateSeparator, vDate) = 0 then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := RightStr(vDate, 2);
        vYear := IntToStr(FActiveYear4Digit);
      end;
    end
    else if Length(vDate) = 5 then
    begin
      if Pos(FormatSettings.DateSeparator, vDate) > 0 then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := RightStr(vDate, 2);
        vYear := IntToStr(FActiveYear4Digit);
      end;
    end
    else if Length(vDate) = 6 then
    begin
      if Pos(FormatSettings.DateSeparator, vDate) = 0 then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := vDate[3] + vDate[4];
        vYear := LeftStr(IntToStr(FActiveYear4Digit), 2) + RightStr(vDate, 2);
      end
      else
      if  (vDate[6] = FormatSettings.DateSeparator)
      and (vDate[3] = FormatSettings.DateSeparator)
      then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := vDate[4] + vDate[5];
        vYear := IntToStr(FActiveYear4Digit);
      end;
    end
    else if Length(vDate) = 8 then
    begin
      if Pos(FormatSettings.DateSeparator, vDate) = 0 then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := vDate[3] + vDate[4];
        vYear := RightStr(vDate, 4);
      end
      else if Pos(FormatSettings.DateSeparator, vDate) > 0 then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := vDate[4] + vDate[5];
        vYear := LeftStr(IntToStr(FActiveYear4Digit), 2) + RightStr(vDate, 2);
      end
    end
    else if Length(vDate) = 10 then
    begin
      if Pos(FormatSettings.DateSeparator, vDate) > 0 then
      begin
        vDay := LeftStr(vDate, 2);
        vMonth  := vDate[4] + vDate[5];
        vYear := RightStr(vDate, 4);
      end
    end;

    if (Length(vDay)>0) or (Length(vMonth)>0) then
    begin
      vDate := vDay + FormatSettings.DateSeparator + vMonth + FormatSettings.DateSeparator + vYear;
      EncodeDate(StrToInt(vYear), strtoint(vMonth), strtoint(vDay));
      Self.Text := vDate;
    end;

  except
    Self.SelStart := Length(Self.Text);
    Self.SetFocus;

    if FWrongDateMessage = '' then
      FWrongDateMessage := 'Hatalý tarih giriþi!';
    raise Exception.Create(FWrongDateMessage);
  end;
end;

procedure TEdit.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  with Message do
    case Msg of
      WM_ENABLE, WM_PAINT: DrawHelperSing(Self);
    end;
end;

function TEdit.MoneyKeyControl(AKey: Char; ADecimalDigits: Integer): Char;
var
  vDividedString: TStringList;
  vPrevious, vIntegerPart, vDecimalPart: string;
  vPosCursor, vPosDecimalSeparator: Integer;
begin
  Result := #0;

  FAllSelected := (Length(Self.Text) = Self.SelLength);

  if (CharInSet(AKey, ['.', ',', FormatSettings.DecimalSeparator])) then
    AKey := FormatSettings.DecimalSeparator;

  if CharInSet(AKey, [#8, '0'..'9', FormatSettings.DecimalSeparator]) then
    Self.Modified := true;

  //Already SelectAll clear
  if FAllSelected and (AKey <> #13) then
    Self.Clear;

  //tanýmlý tuþlar harici tuþlar girilmez veya seperator sadece bir kere girilebilir
  if (AKey = FormatSettings.DecimalSeparator) and (Pos(AKey, Self.Text) > 0) then
    AKey := #0
  else if not CharInSet(AKey, [#13, #8, '0'..'9', FormatSettings.DecimalSeparator]) then
    AKey := #0;

  if AKey <> #0 then
  begin
    vPrevious := Self.Text;
    if (Length(vPrevious) = 0) then
    begin
      if AKey = #13 then
        Result := AKey
      else if AKey = '0' then
      begin
        Result := AKey
      end
      else if AKey = FormatSettings.DecimalSeparator then
      begin
        Result := AKey;
        Self.Text := '0';
        Self.SelStart := 1;
      end
      else if CharInSet(AKey, ['1'..'9']) then
        Result := AKey;
    end
    else if (Length(vPrevious) > 0) then
    begin
      if (Pos(FormatSettings.DecimalSeparator, Self.Text) > 0) then
      begin
        vPosDecimalSeparator := Pos(FormatSettings.DecimalSeparator, Self.Text);
        vPosCursor := Self.SelStart;

        vDividedString := TStringList.Create;
        try
          Assert(Assigned(vDividedString));
          vDividedString.Clear;
          vDividedString.Delimiter := FormatSettings.DecimalSeparator;
          vDividedString.DelimitedText := vPrevious;

          vIntegerPart := vDividedString[0];
          vDecimalPart := vDividedString[1];

          if (Length(VDecimalPart) < ADecimalDigits) then
          begin
            if (AKey = #13) then
              Self.Text := Self.Text + StringOfChar('0', FDecimalDigitCount-Length(vDecimalPart));

            Result := AKey;
          end
          else
          begin
            if (vPosCursor <= vPosDecimalSeparator) then
              Result := AKey
            else
            begin
              //if (pKey = #13) or (pKey = #8) then
                Result := AKey;
            end;
          end;

        finally
          vDividedString.Free;
        end;

      end
      else
      begin
        if (AKey = #13) then
          Self.Text := Self.Text + FormatSettings.DecimalSeparator + '00';
        Result := AKey;
      end;

    end;
  end;
end;

initialization
  TStyleManager.Engine.RegisterStyleHook(TEdit, TEditStyleHookColor);

end.
