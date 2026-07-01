unit ufrmSetBbkFirmaTipi;

interface

{$I Ths.inc}

uses
  Windows,
  System.Classes,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetBbkFirmaTipi = class(TfrmBaseInputDB)
    lblfirma_tipi: TLabel;
    edtfirma_tipi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals,
  Ths.Database.Table.SetBbkFirmaTipi;

procedure TfrmSetBbkFirmaTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkFirmaTipi(Table).FirmaTipi.Value := edtfirma_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkFirmaTipi.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetBbkFirmaTipi.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetBbkFirmaTipi.RefreshData;
begin
  edtfirma_tipi.Text := TSetBbkFirmaTipi(Table).FirmaTipi.AsString;
end;

end.
