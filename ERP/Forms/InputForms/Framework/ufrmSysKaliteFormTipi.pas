unit ufrmSysKaliteFormTipi;

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
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SysKaliteFormTipi;

type
  TfrmSysKaliteFormTipi = class(TfrmBaseInputDB)
    edtform_tipi: TEdit;
    lblform_tipi: TLabel;
  public
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData();override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysKaliteFormTipi.RefreshData();
begin
  edtform_tipi.Text := TSysKaliteFormTipi(Table).FormTipi.Value;
end;

procedure TfrmSysKaliteFormTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysKaliteFormTipi(Table).FormTipi.Value := edtform_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
