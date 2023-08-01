unit ufrmAbout;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Math,
  System.Win.Registry,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Samples.Spin,
  ufrmBase;

type
  TfrmAbout = class(TfrmBase)
    lblArchitecture: TLabel;
    lblValArchitecture: TLabel;
    lblWindowsOSVersion: TLabel;
    lblValWindowsOSVersion: TLabel;
    lblDeveloper: TLabel;
    lblValDeveloper: TLabel;
    lblCompany: TLabel;
    lblValCompany: TLabel;
    lblCpuInfo: TLabel;
    lblValCpuInfo: TLabel;
    lblRamInfo: TLabel;
    lblValRamInfo: TLabel;
    img1: TImage;
    procedure FormClick(Sender: TObject);
  published
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

procedure TfrmAbout.FormClick(Sender: TObject);
begin
  inherited;
  Close;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  LOSVer: _OSVERSIONINFOW;
  LMemoryStatus: _MEMORYSTATUSEX;
  LReg: TRegistry;
begin
  inherited;

  btnClose.Visible := True;

  LOSVer.dwOSVersionInfoSize := SizeOf(_OSVERSIONINFOW);
  GetVersionEx(LOSVer);

  lblValArchitecture.Caption := TOSVersion.ToString;
  lblValWindowsOSVersion.Caption := LOSVer.dwMajorVersion.ToString;

  LMemoryStatus.dwLength := SizeOf(LMemoryStatus);
  GlobalMemoryStatusEx(LMemoryStatus);
  if LMemoryStatus.ullTotalPhys > 0 then
    lblValRamInfo.Caption := RoundTo(((LMemoryStatus.ullTotalPhys/1024)/1024/1024), -2).ToString + ' GB';


  //if give parameter KEY_READ dont need administration right
  LReg := TRegistry.Create(KEY_READ);
  try
    LReg.RootKey := HKEY_LOCAL_MACHINE;
    if LReg.OpenKey('\Hardware\Description\System\CentralProcessor\0', False) then
    begin
      lblValCpuInfo.Caption := LReg.ReadString('Identifier') + ' ' +
                               LReg.ReadString('ProcessorNameString');
    end;
  finally
    LReg.Free;
  end;
end;

end.
