unit UiDriver;

{ Ekranların event akışını uygulama açılmadan koddan süren test sürücüsü.
  Modal diyaloglar (mesaj, onay, helper liste) bir timer ile otomatik cevaplanır ve kaydedilir. }

interface

uses
  Core.Exception,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Rtti, System.TypInfo,
  System.StrUtils, System.Generics.Collections, System.Generics.Defaults, System.JSON, System.RegularExpressions, System.Math, System.Variants,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.DBGrids, Vcl.Dialogs, Vcl.ComCtrls,
  Data.DB, FireDAC.Comp.Client,
  Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Entity, Service, SharedFormTypes, EntitySchemaCache, UnitOfWork, LocalizationManager, ufrmGrid;

type
  TUi = class
  public
    class var Dialogs: TStringList;
    class var AnswerNo: Boolean;
    class var Module, FormName: string;
    class var Pass, Fail, Warn: Integer;
    class var FilterModule, FilterForm: string;

    class procedure OpenReport(const AFile: string);
    class procedure CloseReport;
    class procedure R(const AKind, AStep, AMsg: string);
    class function Want(const AModule, AForm: string): Boolean;
    class procedure Install;

    class procedure Pump;
    class function TakeDialogs: string;
    class function HasError(const ADialogs: string): Boolean;
    class function Snapshot: TList<TForm>;
    class function NewForm(ABefore: TList<TForm>): TForm;
    class function Alive(F: TForm): Boolean;
    class procedure CloseForm(F: TForm);
    class procedure CloseNewForms(ABefore: TList<TForm>);

    class function Prop(AObj: TObject; const AName: string): TValue;
    class procedure Call(AObj: TObject; const AName: string; const AArgs: array of TValue);
    class function Btn(F: TForm; const AName: string): TButton;
    class function Mode(F: TForm): string;

    class function Sql(const ASql: string; const AParams: array of Variant): Variant;
    class function MaxId(const ATable: string): Int64;
    class function RowJson(const ATable: string; AId: Int64): TJSONObject;
    class function DiffRows(ASrc, ANew: TJSONObject; AAllowMutated: Boolean): string;

    class function LooksLikeKey(const S: string): Boolean;
    class procedure Walk(AParent: TWinControl; AList: TList<TControl>);
    class function CaptionProblems(F: TForm): string;
    class function GridTitleProblems(AGrid: TDBGrid): string;
    class function LayoutProblems(F: TForm): string;
    class function ReviewProblems(F: TForm): string;
    class function MutateInputs(F: TForm): Integer;
    class function HelperEdits(F: TForm): TList<TEdit>;
    class procedure SetLanguage(const ALang: string; AForms: array of TForm);
    class procedure CollectItems(AParent: TMenuItem; AItems: TList<TMenuItem>);
    class function Accept(AForm: TForm): string;

    // sekme / alan testleri
    class function Snake(const AName: string): string;
    class function Pascal(const ACol: string): string;
    class function ColumnOf(C: TControl): string;
    class function IsRequired(C: TControl): Boolean;
    class function TabOf(C: TControl): TTabSheet;
    class function InFooter(F: TForm; C: TControl): Boolean;
    class function ParseNum(const AText: string; out AValue: Double): Boolean;
    class function FieldValueProblems(F: TForm; ARow: TJSONObject): string;
    class function SwitchTabs(F: TForm): string;
    class function TabOrderProblems(F: TForm): string;
    class procedure RequiredTabCheck(F: TForm);
    class function NotMarkedRequired(F: TForm; const ATable: string): string;
  end;

  TUiTester<TE: TEntity, constructor; TS: TCrudService<TE>> = class
  public
    class procedure Run(const AModule: string; G: TfrmGrid<TE, TS>);
  end;

implementation

type
  TUiHandler = class
    procedure OnTimer(Sender: TObject);
    procedure OnException(Sender: TObject; E: Exception);
  end;

var
  GOut: TStreamWriter;
  GHandler: TUiHandler;
  GTimer: TTimer;
  GInTimer: Boolean;

{ ---------------------------------------------------------------- dialogs }

function EnumNative(H: HWND; L: LPARAM): BOOL; stdcall;
var
  Cls: array[0..63] of Char;
  Txt: array[0..1023] of Char;
begin
  Result := True;
  if not IsWindowVisible(H) then Exit;
  GetClassName(H, Cls, 64);
  if string(Cls) <> '#32770' then Exit;
  Txt[0] := #0;
  GetDlgItemText(H, $FFFF, Txt, 1024);
  TUi.Dialogs.Add('NATIVE: ' + string(Txt));
  if GetDlgItem(H, IDYES) <> 0 then
    PostMessage(H, WM_COMMAND, IfThen(TUi.AnswerNo, IDNO, IDYES), 0)
  else if GetDlgItem(H, IDOK) <> 0 then
    PostMessage(H, WM_COMMAND, IDOK, 0)
  else
    PostMessage(H, WM_CLOSE, 0, 0);
end;

procedure HandleModal(F: TForm);
var
  C: TComponent;
  i: Integer;
  HasYes: Boolean;
  V: TValue;
  Q: TObject;
  T: string;
begin
  if F.ModalResult <> mrNone then Exit;

  if F.ClassName = 'TMessageForm' then
  begin
    C := F.FindComponent('Message');
    if C is TLabel then T := TLabel(C).Caption else T := F.Caption;
    TUi.Dialogs.Add('DLG: ' + T);
    HasYes := False;
    for i := 0 to F.ComponentCount - 1 do
      if (F.Components[i] is TButton) and (TButton(F.Components[i]).ModalResult = mrYes) then
        HasYes := True;
    if HasYes then
      F.ModalResult := IfThen(TUi.AnswerNo, mrNo, mrYes)
    else
      F.ModalResult := mrOk;
    Exit;
  end;

  V := TUi.Prop(F, 'IsHelper');
  if (V.Kind = tkEnumeration) and V.AsBoolean then
  begin
    TUi.Dialogs.Add('HELPER: ' + F.ClassName);
    Q := TUi.Prop(F, 'Qry').AsObject;
    if (Q is TFDQuery) and TFDQuery(Q).Active and (TFDQuery(Q).RecordCount > 0) then
    begin
      TFDQuery(Q).First;
      TUi.Call(F, 'grdDblClick', [TValue.From<TObject>(nil)]);
      if F.ModalResult = mrNone then
        F.ModalResult := mrCancel;
    end
    else
    begin
      TUi.Dialogs.Add('HELPER-EMPTY: ' + F.ClassName);
      F.ModalResult := mrCancel;
    end;
    Exit;
  end;

  TUi.Dialogs.Add('MODAL: ' + F.ClassName + ' "' + F.Caption + '"');
  F.ModalResult := mrCancel;
end;

procedure TUiHandler.OnTimer(Sender: TObject);
var
  i: Integer;
  F: TForm;
begin
  if GInTimer then Exit;
  GInTimer := True;
  try
    for i := Screen.FormCount - 1 downto 0 do
    begin
      F := Screen.Forms[i];
      if F.Visible and (fsModal in F.FormState) then
      begin
        try
          HandleModal(F);
        except
          on E: Exception do
          begin
            TUi.Dialogs.Add('EXC(handler): ' + E.ClassName + ': ' + E.Message);
            F.ModalResult := mrCancel;
          end;
        end;
        Break;  // en üstteki modal; diğerleri sonraki tick
      end;
    end;
    EnumThreadWindows(GetCurrentThreadId, @EnumNative, 0);
  finally
    GInTimer := False;
  end;
end;

procedure TUiHandler.OnException(Sender: TObject; E: Exception);
begin
  TUi.Dialogs.Add('EXC: ' + E.ClassName + ': ' + E.Message);
end;

{ ---------------------------------------------------------------- TUi }

class procedure TUi.OpenReport(const AFile: string);
begin
  GOut := TStreamWriter.Create(AFile, False, TEncoding.UTF8);
  Dialogs := TStringList.Create;
end;

class procedure TUi.CloseReport;
begin
  FreeAndNil(GOut);
end;

class procedure TUi.R(const AKind, AStep, AMsg: string);
var
  L: string;
begin
  if AKind = 'PASS' then Inc(Pass)
  else if AKind = 'FAIL' then Inc(Fail)
  else if AKind = 'WARN' then Inc(Warn);
  L := Format('%s|%s|%s|%s|%s', [AKind, Module, FormName, AStep,
    StringReplace(StringReplace(AMsg, #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll])]);
  Writeln(L);
  if Assigned(GOut) then
  begin
    GOut.WriteLine(L);
    GOut.Flush;
  end;
end;

class function TUi.Want(const AModule, AForm: string): Boolean;
begin
  Result := ((FilterModule = '') or (FilterModule = '*') or SameText(FilterModule, AModule)) and
            ((FilterForm = '') or (FilterForm = '*') or SameText(FilterForm, AForm));
end;

class procedure TUi.Install;
begin
  GHandler := TUiHandler.Create;
  GTimer := TTimer.Create(Application);
  GTimer.Interval := 40;
  GTimer.OnTimer := GHandler.OnTimer;
  GTimer.Enabled := True;
  Application.OnException := GHandler.OnException;
end;

class procedure TUi.Pump;
var
  i: Integer;
begin
  for i := 1 to 8 do
  begin
    Application.ProcessMessages;
    CheckSynchronize;
  end;
end;

class function TUi.TakeDialogs: string;
begin
  Result := Dialogs.DelimitedText;
  Result := '';
  if Dialogs.Count > 0 then
    Result := String.Join(' || ', Dialogs.ToStringArray);
  Dialogs.Clear;
end;

class function TUi.HasError(const ADialogs: string): Boolean;
begin
  Result := ContainsText(ADialogs, 'EXC') or ContainsText(ADialogs, 'NATIVE:');
end;

class function TUi.Snapshot: TList<TForm>;
var
  i: Integer;
begin
  Result := TList<TForm>.Create;
  for i := 0 to Screen.FormCount - 1 do
    Result.Add(Screen.Forms[i]);
end;

class function TUi.NewForm(ABefore: TList<TForm>): TForm;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Screen.FormCount - 1 do
    if not ABefore.Contains(Screen.Forms[i]) and (Screen.Forms[i].ClassName <> 'TMessageForm') then
      Exit(Screen.Forms[i]);
end;

class function TUi.Alive(F: TForm): Boolean;
var
  i: Integer;
begin
  Result := False;
  if F = nil then Exit;
  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i] = F then
      Exit(F.Visible);
end;

class procedure TUi.CloseForm(F: TForm);
begin
  if Alive(F) then
  begin
    try
      F.Close;
    except
      on E: Exception do Dialogs.Add('EXC(close): ' + E.Message);
    end;
    Pump;
  end;
end;

class procedure TUi.CloseNewForms(ABefore: TList<TForm>);
var
  F: TForm;
  n: Integer;
begin
  n := 0;
  repeat
    F := NewForm(ABefore);
    if (F = nil) or not F.Visible then Break;
    CloseForm(F);
    Inc(n);
  until n > 20;
end;

class function TUi.Prop(AObj: TObject; const AName: string): TValue;
var
  Ctx: TRttiContext;
  P: TRttiProperty;
begin
  Result := TValue.Empty;
  if AObj = nil then Exit;
  P := Ctx.GetType(AObj.ClassType).GetProperty(AName);
  if Assigned(P) and P.IsReadable then
    Result := P.GetValue(AObj);
end;

class procedure TUi.Call(AObj: TObject; const AName: string; const AArgs: array of TValue);
var
  Ctx: TRttiContext;
  M: TRttiMethod;
begin
  M := Ctx.GetType(AObj.ClassType).GetMethod(AName);
  if M = nil then
    raise Exception.CreateFmt('%s.%s not found', [AObj.ClassName, AName]);
  M.Invoke(AObj, AArgs);
end;

class function TUi.Btn(F: TForm; const AName: string): TButton;
var
  V: TValue;
begin
  V := Prop(F, AName);
  if V.IsObject and (V.AsObject is TButton) then
    Result := TButton(V.AsObject)
  else
    Result := nil;
end;

class function TUi.Mode(F: TForm): string;
begin
  Result := Prop(F, 'FormMode').ToString;
end;

class function TUi.Sql(const ASql: string; const AParams: array of Variant): Variant;
begin
  Result := TUnitOfWork.Instance.Connection.ExecSQLScalar(ASql, AParams);
end;

class function TUi.MaxId(const ATable: string): Int64;
var
  V: Variant;
begin
  V := Sql('SELECT COALESCE(max(id), 0) FROM public.' + ATable, []);
  Result := V;
end;

class function TUi.RowJson(const ATable: string; AId: Int64): TJSONObject;
var
  V: Variant;
begin
  Result := nil;
  V := Sql('SELECT row_to_json(t)::text FROM public.' + ATable + ' t WHERE id = :id', [AId]);
  if not VarIsNull(V) and not VarIsEmpty(V) then
    Result := TJSONObject.ParseJSONValue(string(V)) as TJSONObject;
end;

class function TUi.DiffRows(ASrc, ANew: TJSONObject; AAllowMutated: Boolean): string;
var
  P: TJSONPair;
  VS, VN, Rest: string;
  NV: TJSONValue;
  Ok: Boolean;
begin
  Result := '';
  for P in ASrc do
  begin
    if P.JsonString.Value = 'id' then Continue;
    // serviste türetilen alanlar (ad+soyad, hesap kodundan kök/ara kod, belge / sıra numaraları, kalemlerden toplamlar)
    // ve kopyada bilerek taşınmayan kaynak belge bağlantıları
    if AAllowMutated and MatchText(P.JsonString.Value, ['full_name', 'root_code', 'sub_code', 'portfolio_no',
      'request_no', 'order_no', 'receipt_no', 'line_no', 'gross_amount', 'discount_amount', 'net_amount', 'vat_amount', 'total_amount',
      'pur_request_detail_id', 'pur_order_id', 'pur_order_detail_id', 'pur_receipt_detail_id']) then Continue;
    VS := P.JsonValue.Value;
    if P.JsonValue is TJSONNull then VS := '<null>';
    NV := ANew.GetValue(P.JsonString.Value);
    if NV = nil then VN := '<missing>'
    else if NV is TJSONNull then VN := '<null>'
    else VN := NV.Value;
    Ok := VS = VN;
    if not Ok and AAllowMutated and StartsText('U', VN) then
    begin
      Rest := Copy(VN, 2, MaxInt);
      Ok := SameText(Rest, VS) or ((Rest <> '') and StartsText(Rest, VS));
    end;
    if not Ok and (VS = '<null>') and MatchStr(VN, ['', '0', '0.00', '0.0000', 'false']) then
      Result := Result + Format('~%s: null -> [%s]; ', [P.JsonString.Value, VN])
    else if not Ok then
      Result := Result + Format('%s: [%s] -> [%s]; ', [P.JsonString.Value, Copy(VS, 1, 40), Copy(VN, 1, 40)]);
  end;
end;

class function TUi.LooksLikeKey(const S: string): Boolean;
begin
  Result := TRegEx.IsMatch(S, '^[a-z0-9_]+(\.[a-z0-9_]+)+$');
end;

class procedure TUi.Walk(AParent: TWinControl; AList: TList<TControl>);
var
  i: Integer;
begin
  for i := 0 to AParent.ControlCount - 1 do
  begin
    AList.Add(AParent.Controls[i]);
    if AParent.Controls[i] is TWinControl then
      Walk(TWinControl(AParent.Controls[i]), AList);
  end;
end;

function IsShown(C: TControl): Boolean;
begin
  if C is TWinControl then
    Result := TWinControl(C).Showing
  else
    Result := C.Visible and Assigned(C.Parent) and C.Parent.Showing;
end;

class function TUi.CaptionProblems(F: TForm): string;
var
  L: TList<TControl>;
  C: TControl;
  S: string;
begin
  Result := '';
  if LooksLikeKey(F.Caption) or (F.Caption = '') or (F.Caption = 'Base Title') then
    Result := Result + 'form caption [' + F.Caption + ']; ';
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
    begin
      if not IsShown(C) then Continue;
      S := '';
      if C is TLabel then S := TLabel(C).Caption
      else if C is TCheckBox then S := TCheckBox(C).Caption
      else if C is TButton then S := TButton(C).Caption
      else if C is TTabSheet then S := TTabSheet(C).Caption
      else if C is TGroupBox then S := TGroupBox(C).Caption
      else Continue;
      if LooksLikeKey(S) then
        Result := Result + C.Name + ' [' + S + ']; '
      else if (S = '') and (C is TCheckBox) and (F.FindComponent('lbl' + Copy(C.Name, 4, MaxInt)) is TLabel) then
        Continue
      else if (S = '') and ((C is TLabel) or (C is TCheckBox) or (C is TTabSheet)) and (C.Name <> '') then
        Result := Result + C.Name + ' [empty]; '
      else if (C.Name <> '') and SameText(S, C.Name) then
        Result := Result + C.Name + ' [=name]; ';
    end;
  finally
    L.Free;
  end;
end;

class function TUi.GridTitleProblems(AGrid: TDBGrid): string;
var
  i: Integer;
  C: TColumn;
begin
  Result := '';
  for i := 0 to AGrid.Columns.Count - 1 do
  begin
    C := AGrid.Columns[i];
    if not C.Visible or (C.Width <= 0) then Continue;
    if LooksLikeKey(C.Title.Caption) or (C.Title.Caption = '') or (Pos('_', C.Title.Caption) > 0) or
       SameText(C.FieldName, 'id') or EndsText('_id', C.FieldName) or
       (SameText(C.FieldName, 'locale') and SameText(C.Title.Caption, 'locale')) then
      Result := Result + C.FieldName + ' [' + C.Title.Caption + ']; ';
  end;
end;

class function TUi.LayoutProblems(F: TForm): string;
var
  L: TList<TControl>;
  C: TControl;
  Footer, Status: TControl;
  FooterTop, Bottom, Right, ClientRight: Integer;
  P: TPoint;

  function Inside(AC, AParent: TControl): Boolean;
  begin
    Result := False;
    while AC <> nil do
    begin
      if AC = AParent then Exit(True);
      AC := AC.Parent;
    end;
  end;

begin
  Result := '';
  Footer := TControl(Prop(F, 'PanelFooter').AsObject);
  Status := TControl(Prop(F, 'StatusBase').AsObject);
  if Footer = nil then Exit;
  FooterTop := Footer.ClientToScreen(Point(0, 0)).Y;
  ClientRight := F.ClientToScreen(Point(F.ClientWidth, 0)).X;
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
    begin
      if Inside(C, Footer) or Inside(C, Status) then Continue;
      if not IsShown(C) then Continue;
      if (C is TPanel) or (C is TPageControl) or (C is TTabSheet) or (C is TScrollBox) or (C is TGroupBox) then Continue;
      if C.Name = '' then Continue;
      P := C.ClientToScreen(Point(0, 0));
      Bottom := P.Y + C.Height;
      Right := P.X + C.Width;
      if Bottom > FooterTop + 1 then
        Result := Result + Format('%s bottom %d > footer %d; ', [C.Name, Bottom - F.ClientOrigin.Y, FooterTop - F.ClientOrigin.Y])
      else if Right > ClientRight + 1 then
        Result := Result + Format('%s right %d > width %d; ', [C.Name, Right - F.ClientOrigin.X, F.ClientWidth]);
    end;
  finally
    L.Free;
  end;
end;

class function TUi.ReviewProblems(F: TForm): string;
var
  L: TList<TControl>;
  C: TControl;
  Footer: TControl;

  function Inside(AC, AParent: TControl): Boolean;
  begin
    Result := False;
    while AC <> nil do
    begin
      if AC = AParent then Exit(True);
      AC := AC.Parent;
    end;
  end;

begin
  Result := '';
  Footer := TControl(Prop(F, 'PanelFooter').AsObject);
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
    begin
      if Inside(C, Footer) or not IsShown(C) or (C.Name = '') then Continue;
      if C is TEdit then
      begin
        if Assigned(TEdit(C).OnHelperProcess) then
        begin
          if not TEdit(C).thsHelperLocked then Result := Result + C.Name + ' helper open; ';
        end
        else if not TEdit(C).ReadOnly then
          Result := Result + C.Name + ' editable; ';
      end
      else if (C is TComboBox) and TComboBox(C).Enabled then
        Result := Result + C.Name + ' enabled; '
      else if (C is TCheckBox) and TCheckBox(C).Enabled then
        Result := Result + C.Name + ' enabled; '
      else if (C is TMemo) and not TMemo(C).ReadOnly then
        Result := Result + C.Name + ' editable; ';
    end;
  finally
    L.Free;
  end;
end;

class function TUi.MutateInputs(F: TForm): Integer;
var
  L: TList<TControl>;
  C: TControl;
  E: TEdit;
  S: string;
begin
  Result := 0;
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
    begin
      if not (C is TEdit) or not IsShown(C) then Continue;
      E := TEdit(C);
      if E.ReadOnly or Assigned(E.OnHelperProcess) or (E.thsInputDataType <> itString) or (E.Text = '') then Continue;
      if E.PasswordChar <> #0 then Continue;
      S := 'U' + E.Text;
      if (E.MaxLength > 0) and (Length(S) > E.MaxLength) then
        S := Copy(S, 1, E.MaxLength);
      E.Text := S;
      Inc(Result);
    end;
  finally
    L.Free;
  end;
end;

class function TUi.HelperEdits(F: TForm): TList<TEdit>;
var
  L: TList<TControl>;
  C: TControl;
begin
  Result := TList<TEdit>.Create;
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
      if (C is TEdit) and Assigned(TEdit(C).OnHelperProcess) and IsShown(C) then
        Result.Add(TEdit(C));
  finally
    L.Free;
  end;
end;

class procedure TUi.SetLanguage(const ALang: string; AForms: array of TForm);
var
  F: TForm;
begin
  TLocalizationManager.SetLanguage(ALang);
  for F in AForms do
    if Alive(F) then
      Call(F, 'ApplyLocalization', []);
end;

class procedure TUi.CollectItems(AParent: TMenuItem; AItems: TList<TMenuItem>);
var
  i: Integer;
begin
  for i := 0 to AParent.Count - 1 do
  begin
    if Assigned(AParent.Items[i].OnClick) and (AParent.Items[i].Caption <> '-') and AParent.Items[i].Visible then
      AItems.Add(AParent.Items[i]);
    CollectItems(AParent.Items[i], AItems);
  end;
end;

class function TUi.Accept(AForm: TForm): string;
var
  B: TButton;
begin
  Result := '';
  B := Btn(AForm, 'BtnAccept');
  try
    B.Click;
  except
    on E: Exception do Result := E.ClassName + ': ' + E.Message;
  end;
  Pump;
end;

class function TUi.InFooter(F: TForm; C: TControl): Boolean;
var
  Footer: TObject;
begin
  Result := False;
  Footer := Prop(F, 'PanelFooter').AsObject;
  while C <> nil do
  begin
    if C = Footer then Exit(True);
    C := C.Parent;
  end;
end;

class function TUi.Snake(const AName: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AName) do
    if CharInSet(AName[i], ['A'..'Z']) then
    begin
      if i > 1 then Result := Result + '_';
      Result := Result + LowerCase(AName[i]);
    end
    else
      Result := Result + AName[i];
end;

class function TUi.Pascal(const ACol: string): string;
var
  P: string;
begin
  Result := '';
  for P in ACol.Split(['_']) do
    if P <> '' then
      Result := Result + UpperCase(P[1]) + Copy(P, 2, MaxInt);
end;

class function TUi.ColumnOf(C: TControl): string;
begin
  Result := '';
  if (Length(C.Name) > 3) and MatchStr(Copy(C.Name, 1, 3), ['edt', 'cbb', 'chk', 'mmo']) then
    Result := Snake(Copy(C.Name, 4, MaxInt));
end;

class function TUi.IsRequired(C: TControl): Boolean;
var
  V: TValue;
begin
  V := Prop(C, 'thsRequiredData');
  Result := (V.Kind = tkEnumeration) and V.AsBoolean;
end;

class function TUi.TabOf(C: TControl): TTabSheet;
begin
  Result := nil;
  while C <> nil do
  begin
    if C is TTabSheet then Exit(TTabSheet(C));
    C := C.Parent;
  end;
end;

class function TUi.ParseNum(const AText: string; out AValue: Double): Boolean;
var
  T: string;
begin
  T := Trim(AText);
  if FormatSettings.ThousandSeparator <> FormatSettings.DecimalSeparator then
    T := StringReplace(T, FormatSettings.ThousandSeparator, '', [rfReplaceAll]);
  T := StringReplace(T, FormatSettings.DecimalSeparator, '.', [rfReplaceAll]);
  Result := TryStrToFloat(T, AValue, TFormatSettings.Invariant);
end;

class function TUi.FieldValueProblems(F: TForm; ARow: TJSONObject): string;
var
  L: TList<TControl>;
  C: TControl;
  Col, T, DBS, Msg: string;
  JV: TJSONValue;
  DBNull: Boolean;
  N1, N2: Double;
  D1, D2: TDateTime;
  E: TEdit;
begin
  Result := '';
  if ARow = nil then Exit;
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
    begin
      if (C.Name = '') or not C.Visible or InFooter(F, C) then Continue;
      Col := ColumnOf(C);
      if Col = '' then Continue;
      JV := ARow.GetValue(Col);
      if JV = nil then Continue;
      DBNull := JV is TJSONNull;
      DBS := JV.Value;
      Msg := '';

      if C is TEdit then
      begin
        E := TEdit(C);
        T := Trim(E.Text);
        if Assigned(E.OnHelperProcess) then
        begin
          if not DBNull and (T = '') then Msg := 'FK set in DB but edit empty'
          else if DBNull and (T <> '') then Msg := 'FK null in DB but edit [' + T + ']';
        end
        else if DBNull then
        begin
          if (T <> '') and not (ParseNum(T, N1) and (N1 = 0)) then
            Msg := 'DB null, edit [' + T + ']';
        end
        else if JV is TJSONNumber then
        begin
          N2 := StrToFloat(DBS, TFormatSettings.Invariant);
          if not ParseNum(T, N1) then
            Msg := Format('edit [%s] <> DB %s', [T, DBS])
          else if Abs(N1 - N2) > 0.00005 then
            Msg := Format('edit [%s] <> DB %s%s', [T, DBS, IfThen(Abs(N1 - N2) < 0.01, ' (display rounded)', '')]);
        end
        else if E.thsInputDataType = itDate then
        begin
          D2 := EncodeDate(StrToIntDef(Copy(DBS, 1, 4), 1900), StrToIntDef(Copy(DBS, 6, 2), 1), StrToIntDef(Copy(DBS, 9, 2), 1));
          D1 := StrToDateDef(T, 0);
          if Trunc(D1) <> Trunc(D2) then Msg := Format('edit [%s] <> DB %s', [T, DBS]);
        end
        else if not SameText(T, Trim(DBS)) then
          Msg := Format('edit [%s] <> DB [%s]', [Copy(T, 1, 30), Copy(DBS, 1, 30)]);
      end
      else if C is TCheckBox then
      begin
        if (JV is TJSONBool) and (TCheckBox(C).Checked <> TJSONBool(JV).AsBoolean) then
          Msg := Format('checked %s <> DB %s', [BoolToStr(TCheckBox(C).Checked, True), DBS]);
      end
      else if C is TCustomComboBox then
      begin
        if not DBNull and (TCustomComboBox(C).ItemIndex < 0) and (Trim(TComboBox(C).Text) = '') then
          Msg := 'combo empty, DB [' + DBS + ']';
      end
      else if C is TMemo then
      begin
        T := Trim(StringReplace(TMemo(C).Lines.Text, #13#10, #10, [rfReplaceAll]));
        if DBNull then DBS := '';
        DBS := Trim(StringReplace(DBS, #13#10, #10, [rfReplaceAll]));
        if T <> DBS then Msg := Format('memo [%s] <> DB [%s]', [Copy(T, 1, 30), Copy(DBS, 1, 30)]);
      end;

      if Msg <> '' then
        Result := Result + C.Name + IfThen(TabOf(C) <> nil, ' (tab ' + TabOf(C).Caption + ')', '') + ': ' + Msg + '; ';
    end;
  finally
    L.Free;
  end;
end;

// Klavye Tab sırası ekrandaki yerleşime uymalı: aynı satırda sağa, aşağı ya da sağdaki yeni sütunun başına
// (iki sütunlu formlarda önce sol sütun yukarıdan aşağı). Geri sıçrama (aynı sütunda yukarı / aynı satırda sola)
// ve Tab ile ulaşılamayan düzenlenebilir alan sorun sayılır. Her kap (panel, sekme) kendi içinde denetlenir.
class function TUi.TabOrderProblems(F: TForm): string;
const
  TOL = 6;
var
  Res: TStringList;

  function HasFocusable(P: TWinControl): Boolean; forward;

  function Participates(C: TWinControl): Boolean;
  begin
    Result := C.Visible and not (C is TTabSheet) and not InFooter(F, C) and (C.TabStop or HasFocusable(C));
  end;

  function HasFocusable(P: TWinControl): Boolean;
  var
    I: Integer;
  begin
    for I := 0 to P.ControlCount - 1 do
      if (P.Controls[I] is TWinControl) and Participates(TWinControl(P.Controls[I])) then
        Exit(True);
    Result := False;
  end;

  function Editable(C: TWinControl): Boolean;
  begin
    Result := ((C is TEdit) and not TEdit(C).ReadOnly) or ((C is TMemo) and not TMemo(C).ReadOnly) or
      (C is TComboBox) or (C is TCheckBox);
  end;

  procedure CheckParent(P: TWinControl);
  var
    I: Integer;
    L: TList<TWinControl>;
    A, B: TWinControl;
    C: TWinControl;
  begin
    L := TList<TWinControl>.Create;
    try
      for I := 0 to P.ControlCount - 1 do
        if P.Controls[I] is TWinControl then
        begin
          C := TWinControl(P.Controls[I]);
          if C.Visible and C.Enabled and not C.TabStop and Editable(C) and not InFooter(F, C) then
            Res.Add(C.Name + ' not reachable (TabStop = False)');
          if Participates(C) then
            L.Add(C);
        end;
      L.Sort(TComparer<TWinControl>.Construct(
        function(const X, Y: TWinControl): Integer
        begin
          Result := X.TabOrder - Y.TabOrder;
        end));
      for I := 1 to L.Count - 1 do
      begin
        A := L[I - 1];
        B := L[I];
        if (Abs(B.Top - A.Top) <= TOL) and (B.Left > A.Left) then Continue;   // aynı satırda sağa
        if B.Top > A.Top + TOL then Continue;                                  // aşağı
        if (B.Top < A.Top - TOL) and (B.Left >= A.Left + A.Width - TOL) then Continue;  // sağdaki sütunun başı
        Res.Add(Format('%s -> %s', [A.Name, B.Name]));
      end;
      for I := 0 to P.ControlCount - 1 do
        if (P.Controls[I] is TWinControl) and TWinControl(P.Controls[I]).Visible then
          if P.Controls[I] is TPageControl then
          begin
            for var J := 0 to TPageControl(P.Controls[I]).PageCount - 1 do
              if TPageControl(P.Controls[I]).Pages[J].TabVisible then
                CheckParent(TPageControl(P.Controls[I]).Pages[J]);
          end
          else if not InFooter(F, P.Controls[I]) then
            CheckParent(TWinControl(P.Controls[I]));
    finally
      L.Free;
    end;
  end;

begin
  Res := TStringList.Create;
  try
    CheckParent(F);
    Res.Delimiter := ';';
    Res.StrictDelimiter := True;
    Result := StringReplace(Res.DelimitedText, ';', '; ', [rfReplaceAll]);
  finally
    Res.Free;
  end;
end;

class function TUi.SwitchTabs(F: TForm): string;
var
  L: TList<TControl>;
  C: TControl;
  PC: TPageControl;
  i: Integer;
  D: string;
begin
  Result := '';
  L := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
    begin
      if not (C is TPageControl) or not TPageControl(C).Showing then Continue;
      PC := TPageControl(C);
      for i := 0 to PC.PageCount - 1 do
      begin
        if not PC.Pages[i].TabVisible then Continue;
        Dialogs.Clear;
        try
          PC.ActivePageIndex := i;
          if Assigned(PC.OnChange) then PC.OnChange(PC);
          Pump;
        except
          on E: Exception do Result := Result + PC.Pages[i].Name + ': ' + E.Message + '; ';
        end;
        D := TakeDialogs;
        if D <> '' then Result := Result + PC.Pages[i].Name + ': ' + D + '; ';
      end;
      PC.ActivePageIndex := 0;
      if Assigned(PC.OnChange) then PC.OnChange(PC);
    end;
  finally
    L.Free;
  end;
end;

class procedure TUi.RequiredTabCheck(F: TForm);
var
  L, Req: TList<TControl>;
  C, X: TControl;
  Tab: TTabSheet;
  OldText, S, Where: string;
  OldIdx, i: Integer;
begin
  L := TList<TControl>.Create;
  Req := TList<TControl>.Create;
  try
    Walk(F, L);
    for C in L do
      if (C.Name <> '') and C.Visible and IsRequired(C) and not InFooter(F, C) then
        Req.Add(C);
    if Req.Count = 0 then
    begin
      R('INFO', 'required fields', 'no control marked required');
      Exit;
    end;
    for C in Req do
    begin
      if not Alive(F) then Break;
      OldIdx := -1;
      if C is TCustomComboBox then
      begin
        OldIdx := TCustomComboBox(C).ItemIndex;
        OldText := TComboBox(C).Text;
        TCustomComboBox(C).ItemIndex := -1;
        TComboBox(C).Text := '';
      end
      else if C is TCustomEdit then
      begin
        OldText := TCustomEdit(C).Text;
        TCustomEdit(C).Text := '';
      end
      else
        Continue;

      // alanın kendi sekmesinden başka bir sekmeye geç (sekme yoksa yalnız doğrulama)
      Tab := TabOf(C);
      Where := '';
      if Tab <> nil then
      begin
        Where := ' (tab ' + Tab.Caption + ')';
        for i := 0 to Tab.PageControl.PageCount - 1 do
          if (Tab.PageControl.Pages[i] <> Tab) and Tab.PageControl.Pages[i].TabVisible then
          begin
            Tab.PageControl.ActivePageIndex := i;
            Break;
          end;
      end;

      Dialogs.Clear;
      S := Accept(F);
      TakeDialogs;
      if not Alive(F) then
      begin
        R('FAIL', 'required ' + C.Name, 'empty required field was saved' + Where);
        Break;
      end;
      if S = '' then
        R('FAIL', 'required ' + C.Name, 'no error for empty required field' + Where)
      else if (Tab <> nil) and (Tab.PageControl.ActivePage <> Tab) then
        R('FAIL', 'required ' + C.Name, 'error shown but tab not activated' + Where + ': ' + S)
      else
      begin
        X := F.ActiveControl;
        if (X <> C) and (C is TWinControl) and TWinControl(C).CanFocus then
          R('WARN', 'required ' + C.Name, 'error ok' + Where + ', focus on ' + IfThen(X <> nil, X.Name, 'nil'))
        else
          R('PASS', 'required ' + C.Name, 'rejected' + Where);
      end;

      // geri yükle
      if C is TCustomComboBox then
      begin
        TCustomComboBox(C).ItemIndex := OldIdx;
        if OldIdx < 0 then TComboBox(C).Text := OldText;
      end
      else
        TCustomEdit(C).Text := OldText;
    end;
  finally
    Req.Free;
    L.Free;
  end;
end;

class function TUi.NotMarkedRequired(F: TForm; const ATable: string): string;
var
  V: Variant;
  Col, P: string;
  C: TComponent;
begin
  Result := '';
  V := Sql('SELECT string_agg(column_name, '','') FROM information_schema.columns WHERE table_schema = ''public'' ' +
    'AND table_name = :t AND is_nullable = ''NO'' AND column_default IS NULL AND (data_type IN (''character varying'', ''text'') OR (data_type = ''bigint'' AND column_name LIKE ''%\_id''))', [ATable]);
  if VarIsNull(V) or VarIsEmpty(V) then Exit;
  for Col in string(V).Split([',']) do
  begin
    // boşsa serviste üretilen alanlar (çek/senet portföy no, satın alma belge numaraları)
    if MatchText(Col, ['portfolio_no', 'request_no', 'order_no', 'receipt_no']) then
      Continue;
    for P in ['edt', 'cbb', 'mmo'] do
    begin
      C := F.FindComponent(P + Pascal(Col));
      if (C is TControl) and TControl(C).Visible then
      begin
        if not IsRequired(TControl(C)) and not ((C is TEdit) and TEdit(C).ReadOnly and not Assigned(TEdit(C).OnHelperProcess)) then
          Result := Result + C.Name + ' (' + Col + '); ';
        Break;
      end;
    end;
  end;
end;

{ ---------------------------------------------------------- TUiTester<> }

class procedure TUiTester<TE, TS>.Run(const AModule: string; G: TfrmGrid<TE, TS>);
const
  Langs: array[0..2] of string = ('en-US', 'de-DE', 'tr-TR');
var
  Before: TList<TForm>;
  F: TForm;
  Tbl, D, S, Lang: string;
  Rows, Mutated: Integer;
  SrcId, NewId, Id0, FirstId, TargetId: Int64;
  JS, JN: TJSONObject;
  Helpers: TList<TEdit>;
  H: TEdit;
  Item: TMenuItem;
  Std: TList<TMenuItem>;
  Items: TList<TMenuItem>;

begin
  TUi.Module := AModule;
  TUi.FormName := G.ClassName;
  Tbl := TEntitySchemaCache.GetSchema(TE).TableName;
  // tablosu olmayan salt okunur listeler (ör. ekstre) doğrudan view'dan okunur
  if VarIsNull(TUi.Sql('SELECT to_regclass(:t)::text', ['public.' + Tbl])) then
    Tbl := 'vw_' + Tbl;
  NewId := 0;
  Before := TUi.Snapshot;
  try
    try
      // 1) liste
      TUi.Dialogs.Clear;
      G.Show;
      TUi.Pump;
      D := TUi.TakeDialogs;
      if not TUi.Alive(G) then
      begin
        TUi.R('FAIL', 'open list', 'form closed itself: ' + D);
        Exit;
      end;
      if not G.Qry.Active then
      begin
        TUi.R('FAIL', 'open list', 'query not active: ' + D);
        Exit;
      end;
      Rows := G.Qry.RecordCount;
      if D <> '' then TUi.R('FAIL', 'open list', Format('%d rows, dialogs: %s', [Rows, D]))
      else TUi.R('PASS', 'open list', Format('%d rows', [Rows]));
      S := TUi.GridTitleProblems(G.Grd);
      if S <> '' then TUi.R('WARN', 'grid titles tr-TR', S);
      Mutated := 0;
      for Rows := 0 to G.Grd.Columns.Count - 1 do
        if G.Grd.Columns[Rows].Visible and (G.Grd.Columns[Rows].Width > 0) then
          Inc(Mutated);
      Rows := G.Qry.RecordCount;
      if Mutated = 0 then
        TUi.R('FAIL', 'visible columns', 'list has no visible column');

      // 2) dil değiştirme (liste)
      for Lang in Langs do
      begin
        TUi.SetLanguage(Lang, [G]);
        S := TUi.GridTitleProblems(G.Grd);
        D := TUi.TakeDialogs;
        if TUi.LooksLikeKey(G.Caption) or (D <> '') then
          TUi.R('FAIL', 'language ' + Lang, 'caption [' + G.Caption + '] ' + D)
        else if (S <> '') and (Lang <> 'tr-TR') then
          TUi.R('WARN', 'grid titles ' + Lang, S)
        else
          TUi.R('PASS', 'language ' + Lang, G.Caption);
      end;

      // 3) boş yeni kayıt
      if G.BtnAdd.Visible and G.BtnAdd.Enabled then
      begin
        TUi.Dialogs.Clear;
        G.BtnAddClick(G.BtnAdd);
        TUi.Pump;
        F := TUi.NewForm(Before);
        D := TUi.TakeDialogs;
        if F = nil then
          TUi.R('FAIL', 'new form', 'not opened: ' + D)
        else
        begin
          TUi.R(IfThen(TUi.HasError(D), 'FAIL', 'PASS'), 'new form', F.ClassName + ' ' + D);
          S := TUi.LayoutProblems(F);
          if S <> '' then TUi.R('FAIL', 'layout', S) else TUi.R('PASS', 'layout', '');
          S := TUi.TabOrderProblems(F);
          if S <> '' then TUi.R('FAIL', 'tab order', S) else TUi.R('PASS', 'tab order', '');
          S := TUi.CaptionProblems(F);
          if S <> '' then TUi.R('WARN', 'captions tr-TR', S);
          for Lang in Langs do
          begin
            TUi.SetLanguage(Lang, [F]);
            S := TUi.CaptionProblems(F);
            D := TUi.TakeDialogs;
            if (S <> '') or (D <> '') then TUi.R('WARN', 'input captions ' + Lang, S + D);
          end;
          S := TUi.Accept(F);
          D := TUi.TakeDialogs;
          if S <> '' then
            TUi.R('PASS', 'blank save rejected', S)
          else if TUi.Alive(F) then
            TUi.R('PASS', 'blank save rejected', D)
          else
          begin
            TUi.R('WARN', 'blank save accepted', 'empty form saved: ' + D);
            if TUi.MaxId(Tbl) > 0 then
              TUnitOfWork.Instance.Connection.ExecSQL('DELETE FROM public.' + Tbl + ' WHERE id = ' + TUi.MaxId(Tbl).ToString);
          end;
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        end;
      end
      else
        TUi.R('INFO', 'new form', 'add button hidden/disabled');

      if Rows = 0 then
      begin
        TUi.R('WARN', 'data', 'no rows - record tests skipped');
        Exit;
      end;

      // 4) inceleme -> güncelle -> onayla (aynı değerler): DB satırı değişmemeli
      G.Qry.First;
      FirstId := G.Qry.FieldByName('id').AsLargeInt;
      JS := TUi.RowJson(Tbl, FirstId);
      try
        TUi.Dialogs.Clear;
        G.mniPreviewClick(G.mniPreview);
        TUi.Pump;
        F := TUi.NewForm(Before);
        D := TUi.TakeDialogs;
        if (F = nil) and not G.BtnAdd.Visible then
          TUi.R('INFO', 'review', 'read-only list (no input form) ' + D)
        else if F = nil then
          TUi.R('FAIL', 'review', 'input not opened: ' + D)
        else
        begin
          S := TUi.ReviewProblems(F);
          if S <> '' then TUi.R('FAIL', 'review read-only', S) else TUi.R('PASS', 'review read-only', '');
          S := TUi.SwitchTabs(F);
          if S <> '' then TUi.R('FAIL', 'tab switch', S);
          S := TUi.FieldValueProblems(F, JS);
          if S <> '' then TUi.R('FAIL', 'fields filled', S) else TUi.R('PASS', 'fields filled', 'all controls match DB row');
          S := TUi.LayoutProblems(F);
          if S <> '' then TUi.R('FAIL', 'layout (review)', S);
          if TUi.Btn(F, 'BtnAccept').Visible and TUi.Btn(F, 'BtnAccept').Enabled then
          begin
            S := TUi.Accept(F);
            D := TUi.TakeDialogs;
            if (S <> '') or (TUi.Mode(F) <> 'ifmUpdate') then
              TUi.R('FAIL', 'review -> update', Format('mode %s %s %s', [TUi.Mode(F), S, D]))
            else
            begin
              TUi.R('PASS', 'review -> update', '');
              S := TUi.Accept(F);
              D := TUi.TakeDialogs;
              JN := TUi.RowJson(Tbl, FirstId);
              try
                if S <> '' then
                  TUi.R('FAIL', 'update same values', S + ' ' + D)
                else if TUi.Alive(F) then
                  TUi.R('FAIL', 'update same values', 'form still open: ' + D)
                else if (JS <> nil) and (JN <> nil) then
                begin
                  S := TUi.DiffRows(JS, JN, False);
                  if (S <> '') and not TRegEx.IsMatch(S, '(^|; )[^~ ]') then
                    TUi.R('WARN', 'update same values', 'NULL normalized: ' + S)
                  else if S <> '' then TUi.R('FAIL', 'update same values', 'row changed: ' + S)
                  else TUi.R('PASS', 'update same values', 'row unchanged');
                end;
              finally
                JN.Free;
              end;
            end;
          end
          else
            TUi.R('INFO', 'review -> update', 'accept button hidden/disabled');
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        end;
      finally
        JS.Free;
      end;

      // 5a) zorunlu alanlar: boşalt -> başka sekmedeyken kaydet -> hata + doğru sekme + odak
      if G.mniDuplicate.Visible and G.BtnAdd.Enabled then
      begin
        G.Qry.First;
        TUi.Dialogs.Clear;
        G.mniDuplicateClick(G.mniDuplicate);
        TUi.Pump;
        F := TUi.NewForm(Before);
        TUi.TakeDialogs;
        if F <> nil then
        begin
          S := TUi.SwitchTabs(F);
          if S <> '' then TUi.R('FAIL', 'tab switch (edit)', S);
          S := TUi.NotMarkedRequired(F, Tbl);
          if S <> '' then TUi.R('WARN', 'not marked required', 'NOT NULL column without required mark: ' + S);
          TUi.RequiredTabCheck(F);
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        end;
      end;

      // 5) kopyala -> değiştir -> kaydet: yeni satır kaynakla aynı olmalı (değiştirilen metinler hariç)
      if G.mniDuplicate.Visible and G.BtnAdd.Enabled then
      begin
        G.Qry.First;
        SrcId := G.Qry.FieldByName('id').AsLargeInt;
        Id0 := TUi.MaxId(Tbl);
        JS := TUi.RowJson(Tbl, SrcId);
        try
          TUi.Dialogs.Clear;
          G.mniDuplicateClick(G.mniDuplicate);
          TUi.Pump;
          F := TUi.NewForm(Before);
          D := TUi.TakeDialogs;
          if F = nil then
            TUi.R('FAIL', 'copy', 'input not opened: ' + D)
          else
          begin
            Mutated := TUi.MutateInputs(F);
            S := TUi.Accept(F);
            D := TUi.TakeDialogs;
            NewId := TUi.MaxId(Tbl);
            if NewId <= Id0 then
            begin
              NewId := 0;
              if (S <> '') and (ContainsText(S, 'EPg') or ContainsText(S, 'EFD') or ContainsText(S, 'Access violation')) then
                TUi.R('FAIL', 'copy save', S + ' ' + D)
              else
                TUi.R('INFO', 'copy save', Format('not saved (%d fields mutated): %s %s', [Mutated, S, D]));
            end
            else
            begin
              JN := TUi.RowJson(Tbl, NewId);
              try
                S := TUi.DiffRows(JS, JN, True);
                if (S <> '') and not TRegEx.IsMatch(S, '(^|; )[^~ ]') then
                  TUi.R('WARN', 'copy save', Format('new id %d, NULL normalized: %s', [NewId, S]))
                else if S <> '' then TUi.R('FAIL', 'copy save', Format('new id %d differs: %s', [NewId, S]))
                else TUi.R('PASS', 'copy save', Format('new id %d, %d fields mutated', [NewId, Mutated]));
              finally
                JN.Free;
              end;
            end;
            TUi.CloseNewForms(Before);
            TUi.TakeDialogs;
          end;
        finally
          JS.Free;
        end;
      end;

      // 6) yeni satırda (yoksa ilk satırda): inceleme -> güncelle -> helper seçimleri -> sil (ilk satırda: kapat + rollback)
      if NewId > 0 then TargetId := NewId else TargetId := FirstId;
      JS := TUi.RowJson(Tbl, TargetId);
      if (TargetId > 0) and G.mniPreview.Visible and G.BtnAdd.Visible then
      try
        G.Table.Id := TargetId;
        TUi.Dialogs.Clear;
        G.ShowInputForm(nil, ifmRewiev);
        TUi.Pump;
        F := TUi.NewForm(Before);
        if F <> nil then
        begin
          S := TUi.Accept(F);
          TUi.TakeDialogs;
          if TUi.Mode(F) = 'ifmUpdate' then
          begin
            Helpers := TUi.HelperEdits(F);
            try
              for H in Helpers do
              begin
                TUi.Dialogs.Clear;
                try
                  H.OnHelperProcess(H);
                  TUi.Pump;
                  D := TUi.TakeDialogs;
                  if TUi.HasError(D) then
                    TUi.R('FAIL', 'helper ' + H.Name, D)
                  else if ContainsText(D, 'HELPER-EMPTY') then
                    TUi.R('WARN', 'helper ' + H.Name, 'helper list empty: ' + D)
                  else if not ContainsText(D, 'HELPER:') then
                    TUi.R('FAIL', 'helper ' + H.Name, 'no helper list shown: ' + D)
                  else if H.Text = '' then
                    TUi.R('FAIL', 'helper ' + H.Name, 'selected but edit empty: ' + D)
                  else
                    TUi.R('PASS', 'helper ' + H.Name, H.Text);
                except
                  on E: Exception do TUi.R('FAIL', 'helper ' + H.Name, E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
                end;
              end;
            finally
              Helpers.Free;
            end;

            if NewId = 0 then
            begin
              TUi.CloseForm(F);
              D := TUi.TakeDialogs;
              JN := TUi.RowJson(Tbl, TargetId);
              try
                S := '';
                if (JS <> nil) and (JN <> nil) then
                  S := TUi.DiffRows(JS, JN, False);
                if TUnitOfWork.Instance.InTransaction then
                  TUi.R('FAIL', 'close after helpers', 'transaction still open ' + D)
                else if S <> '' then
                  TUi.R('FAIL', 'close after helpers', 'row changed without confirm: ' + S)
                else
                  TUi.R('PASS', 'close after helpers', 'rolled back');
              finally
                JN.Free;
              end;
            end
            else
            begin
            TUi.Dialogs.Clear;
            try
              TUi.Btn(F, 'BtnDelete').Click;
              S := '';
            except
              on E: Exception do S := E.ClassName + ': ' + E.Message;
            end;
            TUi.Pump;
            D := TUi.TakeDialogs;
            if VarToStr(TUi.Sql('SELECT count(*) FROM public.' + Tbl + ' WHERE id = :id', [NewId])) = '0' then
              TUi.R('PASS', 'delete', Format('id %d', [NewId]))
            else if ContainsText(S, 'EPg') or ContainsText(S, 'Access violation') then
              TUi.R('FAIL', 'delete', S + ' ' + D)
            else
              TUi.R('INFO', 'delete', 'not deleted: ' + S + ' ' + D);
            end;
          end
          else
            TUi.R('FAIL', 'reopen new row', 'mode ' + TUi.Mode(F) + ' ' + S);
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        end
        else
          TUi.R('FAIL', 'reopen new row', 'input not opened');
      finally
        FreeAndNil(JS);
      end;

      // 7) popup'taki özel menüler (detay listeleri, toplu işlemler)
      Std := TList<TMenuItem>.Create;
      Items := TList<TMenuItem>.Create;
      try
        Std.AddRange([G.mniPreview, G.mniDuplicate, G.mniFilter, G.mniFilterExclude, G.mniFilterBack,
          G.mniFilterRemove, G.mniExportExcel, G.mniExportCsv, G.mniPrint, G.mniRemoveGridSort]);
        TUi.CollectItems(G.GridPopMenu.Items, Items);
        for Item in Items do
        begin
          if Std.Contains(Item) or StartsText('mniColumn', Item.Name) then Continue;
          if G.Qry.RecordCount = 0 then Continue;
          G.Qry.First;
          G.SetSelectedItem;
          TUi.Dialogs.Clear;
          try
            Item.Click;
            TUi.Pump;
            F := TUi.NewForm(Before);
            D := TUi.TakeDialogs;
            if TUi.HasError(D) then
              TUi.R('FAIL', 'popup ' + Item.Name, D)
            else if F <> nil then
            begin
              S := '';
              if TUi.Prop(F, 'Qry').IsObject and (TUi.Prop(F, 'Qry').AsObject is TFDQuery) then
                S := Format(' (%d rows)', [TFDQuery(TUi.Prop(F, 'Qry').AsObject).RecordCount]);
              TUi.R('PASS', 'popup ' + Item.Name, F.ClassName + ' "' + F.Caption + '"' + S + ' ' + D);
            end
            else
              TUi.R('PASS', 'popup ' + Item.Name, 'no window: ' + D);
          except
            // iş kuralı reddi (ör. durum uygun değil) beklenen davranıştır; AV / DB hataları FAIL
            on E: Exception do
              if (E.ClassType = Exception) or (E is EAppException) then
                TUi.R('INFO', 'popup ' + Item.Name, 'rejected by business rule: ' + E.Message + ' ' + TUi.TakeDialogs)
              else
                TUi.R('FAIL', 'popup ' + Item.Name, E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
          end;
          TUi.CloseNewForms(Before);
          TUi.TakeDialogs;
        end;
      finally
        Items.Free;
        Std.Free;
      end;
    except
      on E: Exception do TUi.R('FAIL', 'flow', E.ClassName + ': ' + E.Message + ' ' + TUi.TakeDialogs);
    end;
  finally
    TLocalizationManager.SetLanguage('tr-TR');
    TUi.CloseNewForms(Before);
    TUi.CloseForm(G);
    if TUnitOfWork.Instance.InTransaction then
    begin
      TUi.R('FAIL', 'transaction', 'transaction left open after form closed');
      TUnitOfWork.Instance.Rollback;
    end;
    TUi.TakeDialogs;
    Before.Free;
  end;
end;

end.
