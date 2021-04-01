unit Ths.Erp.Utils.InfoWindow;

interface

uses
    Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  ;

function BilgiVer(const AMesaj: string; AAutoClose: Boolean = True; AEkranSuresi: Integer = 1000): HWND;
procedure PencereHazirla(AProc: TProc);

implementation

procedure Gecikme(ms: Cardinal);
// Gecikme Fonksiyonu
var
  TheTime: Cardinal;
begin
  TheTime := GetTickCount + ms;
  while GetTickCount < TheTime do
    Application.ProcessMessages;
end;

function BilgiVer(const AMesaj: string; AAutoClose: Boolean = True; AEkranSuresi : Integer = 1000): HWND;
// Verilen Mesaj Süresi kadar Bilgi Penceresini Ekranda Tutar.
var
  FormWidth, FormHeight: Integer;
begin
  Result := 0;
  if Length(AMesaj.Trim) > 0 then
  begin
    try
      FormWidth := (AMesaj.Length * 10) + 30;
      FormHeight := 180;
      Result := CreateWindow(
                  'STATIC',
                  PWideChar(AMesaj),
                  WS_OVERLAPPED or WS_POPUPWINDOW or WS_THICKFRAME or SS_CENTER or SS_CENTERIMAGE,
                  (Screen.Width - FormWidth) div 2,
                  (Screen.Height - FormHeight) div 2,
                  FormWidth,
                  FormHeight,
                  Application.Mainform.Handle,
                  0,
                  HInstance,
                  nil
                );
      ShowWindow(Result, SW_SHOWNORMAL);
      UpdateWindow(Result);
    finally
      if AAutoClose then
      begin
        Gecikme(AEkranSuresi);
        DestroyWindow(Result);
        Result := 0;
      end;
    end;
  end;
end;

procedure PencereHazirla(AProc: TProc);
var
  hnwd: HWND;
begin
  hnwd := BilgiVer('Lütfen bekleyin... - Please wait...', False);
  try
    AProc;
  finally
    DestroyWindow(hnwd);
  end;
end;

end.
