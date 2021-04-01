unit ufrmAyarCekSenetCashEdiciTipi;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmAyarCekSenetCashEdiciTipi = class(TfrmBaseInputDB)
    edtDeger: TEdit;
    lblDeger: TLabel;
  published
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.AyarCekSenetCashEdiciTipi;

{$R *.dfm}

procedure TfrmAyarCekSenetCashEdiciTipi.RefreshData();
begin
  edtDeger.Text := FormatedVariantVal(TAyarCekSenetCashEdiciTipi(Table).Deger);
end;

procedure TfrmAyarCekSenetCashEdiciTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TAyarCekSenetCashEdiciTipi(Table).Deger.Value := edtDeger.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
