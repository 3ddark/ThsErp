unit ScreenCode;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms;

type
  // Ekran kodunu (sys_menu.menu_code) pencere başlığının sonunda tutar: "Müşteri Çekleri [300301]".
  //  - Menüden / action'dan açılan form RunWithCode içinde oluşur ve kodu alır (modal açılan diyalog da).
  //  - O ekrandan açılan, modal olmayan formlar (kayıt formu, popup alt listesi) sahibinin kodunu devralır;
  //    modal seçim listeleri (helper) ve mesaj kutuları devralmaz.
  //  - Form başlığını sonradan değiştirse de (dil değişimi, sabit filtre adı) kod sonda kalır: WM_SETTEXT kancası.
  TScreenCodes = class
  private
    class var FPending: Integer;
    class var FInstalled: Boolean;
    class var FPrevActiveFormChange: TNotifyEvent;
    class var FHandler: TScreenCodes;
    procedure ActiveFormChange(Sender: TObject);
    class procedure Install;
    class procedure Attach(AForm: TCustomForm; ACode: Integer);
    class function InheritedCode(AForm: TCustomForm): Integer;
  public
    class destructor Destroy;
    // AProc içinde oluşturulan / etkinleşen ilk form ACode'u alır
    class procedure RunWithCode(ACode: Integer; const AProc: TProc);
    class function CodeOf(AForm: TCustomForm): Integer;
    class function Decorate(const ACaption: string; ACode: Integer): string;
  end;

implementation

uses
  SysMenu;

type
  TScreenCodeHook = class(TComponent)
  private
    FForm: TCustomForm;
    FCode: Integer;
    FOldWndProc: TWndMethod;
    procedure HookWndProc(var Msg: TMessage);
  public
    constructor CreateHook(AForm: TCustomForm; ACode: Integer);
    destructor Destroy; override;
  end;

function FindHook(AForm: TCustomForm): TScreenCodeHook;
var
  I: Integer;
begin
  Result := nil;
  if AForm = nil then
    Exit;
  for I := 0 to AForm.ComponentCount - 1 do
    if AForm.Components[I] is TScreenCodeHook then
      Exit(TScreenCodeHook(AForm.Components[I]));
end;

{ TScreenCodeHook }

constructor TScreenCodeHook.CreateHook(AForm: TCustomForm; ACode: Integer);
begin
  inherited Create(AForm);
  FForm := AForm;
  FCode := ACode;
  FOldWndProc := AForm.WindowProc;
  AForm.WindowProc := HookWndProc;
end;

destructor TScreenCodeHook.Destroy;
var
  LCurrent: TWndMethod;
begin
  // form yok edilirken bileşenleriyle birlikte serbest kalır: kanca bizimse eski pencere işleyicisi geri konur
  LCurrent := HookWndProc;
  if Assigned(FForm) and (TMethod(FForm.WindowProc).Code = TMethod(LCurrent).Code)
    and (TMethod(FForm.WindowProc).Data = Self) then
    FForm.WindowProc := FOldWndProc;
  inherited;
end;

procedure TScreenCodeHook.HookWndProc(var Msg: TMessage);
var
  LText: string;
begin
  if (Msg.Msg = WM_SETTEXT) and (Msg.LParam <> 0) then
  begin
    LText := TScreenCodes.Decorate(PChar(Msg.LParam), FCode);
    Msg.LParam := LPARAM(PChar(LText));
    FOldWndProc(Msg);
  end
  else
    FOldWndProc(Msg);
end;

{ TScreenCodes }

class destructor TScreenCodes.Destroy;
begin
  if FInstalled and Assigned(Screen) then
    Screen.OnActiveFormChange := FPrevActiveFormChange;
  FreeAndNil(FHandler);
end;

class procedure TScreenCodes.Install;
begin
  if FInstalled then
    Exit;
  FHandler := TScreenCodes.Create;
  FPrevActiveFormChange := Screen.OnActiveFormChange;
  Screen.OnActiveFormChange := FHandler.ActiveFormChange;
  FInstalled := True;
end;

class function TScreenCodes.Decorate(const ACaption: string; ACode: Integer): string;
var
  LSuffix: string;
begin
  LSuffix := ' ' + FormatScreenCode(ACode);
  Result := StringReplace(ACaption, LSuffix, '', [rfReplaceAll]);
  Result := TrimRight(Result) + LSuffix;
end;

class function TScreenCodes.CodeOf(AForm: TCustomForm): Integer;
var
  LHook: TScreenCodeHook;
begin
  LHook := FindHook(AForm);
  if Assigned(LHook) then
    Result := LHook.FCode
  else
    Result := 0;
end;

class procedure TScreenCodes.Attach(AForm: TCustomForm; ACode: Integer);
begin
  if (AForm = nil) or (ACode <= 0) or (CodeOf(AForm) > 0) then
    Exit;
  TScreenCodeHook.CreateHook(AForm, ACode);
  // mevcut başlık kancadan geçsin (aynı metin atanırsa VCL WM_SETTEXT göndermez)
  AForm.Caption := Decorate(AForm.Caption, ACode);
end;

// Sahip zincirinde kodu olan ilk form; modal formlar (seçim listesi, diyalog) devralmaz
class function TScreenCodes.InheritedCode(AForm: TCustomForm): Integer;
var
  LOwner: TComponent;
begin
  Result := 0;
  if fsModal in AForm.FormState then
    Exit;
  LOwner := AForm.Owner;
  while Assigned(LOwner) do
  begin
    if LOwner is TCustomForm then
    begin
      Result := CodeOf(TCustomForm(LOwner));
      if Result > 0 then
        Exit;
    end;
    LOwner := LOwner.Owner;
  end;
end;

procedure TScreenCodes.ActiveFormChange(Sender: TObject);
var
  LForm: TCustomForm;
begin
  try
    LForm := Screen.ActiveCustomForm;
    if Assigned(LForm) and (CodeOf(LForm) = 0) then
    begin
      if FPending > 0 then
      begin
        Attach(LForm, FPending);
        FPending := 0;
      end
      else
        Attach(LForm, InheritedCode(LForm));
    end;
  finally
    if Assigned(FPrevActiveFormChange) then
      FPrevActiveFormChange(Sender);
  end;
end;

class procedure TScreenCodes.RunWithCode(ACode: Integer; const AProc: TProc);
var
  LBefore: TArray<TCustomForm>;
  LForm: TCustomForm;
  I: Integer;
  LFound: Boolean;
begin
  if ACode <= 0 then
  begin
    AProc();
    Exit;
  end;

  Install;
  LBefore := [];
  for I := 0 to Screen.CustomFormCount - 1 do
    LBefore := LBefore + [Screen.CustomForms[I]];

  FPending := ACode;
  try
    AProc();
  finally
    // etkinleşmeden kalan (ör. arka planda açılan) yeni form da kodu alır
    if FPending > 0 then
      for I := 0 to Screen.CustomFormCount - 1 do
      begin
        LForm := Screen.CustomForms[I];
        LFound := False;
        for var LOld in LBefore do
          if LOld = LForm then
          begin
            LFound := True;
            Break;
          end;
        if not LFound and (CodeOf(LForm) = 0) then
        begin
          Attach(LForm, FPending);
          Break;
        end;
      end;
    FPending := 0;
  end;
end;

end.
