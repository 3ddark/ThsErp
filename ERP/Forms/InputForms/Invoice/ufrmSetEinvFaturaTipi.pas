unit ufrmSetEinvFaturaTipi;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
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
  TfrmSetEinvFaturaTipi = class(TfrmBaseInputDB)
    edtTip: TEdit;
    lblTip: TLabel;
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table.SetEinvFaturaTipleri;

{$R *.dfm}

procedure TfrmSetEinvFaturaTipi.RefreshData();
begin
  edtTip.Text := TSetEinvFaturaTipi(Table).FaturaTipi.Value;
end;

procedure TfrmSetEinvFaturaTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvFaturaTipi(Table).FaturaTipi.Value := edtTip.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
