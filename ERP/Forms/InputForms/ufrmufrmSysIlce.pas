unit ufrmSysIlce;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Math,
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
  ufrmBaseInputDB;

type
  TfrmufrmSysIlce = class(TfrmBaseInputDB)
    lblilce_adi: TLabel;
    edtilce_adi: TEdit;
    lblsehir_id: TLabel;
    edtsehir_id: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  ufrmufrmSysIlces,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysIlce;

{$R *.dfm}

procedure TfrmufrmSysIlce.RefreshData;
begin
  edtilce_adi.Text := VarToStr(FormatedVariantVal(TSysIlce(Table).IlceAdi));
  edtsehir_id.Text := VarToStr(FormatedVariantVal(TSysIlce(Table).SehirId));
end;

procedure TfrmufrmSysIlce.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysIlce(Table).IlceAdi.Value := edtilce_adi.Text;
      TSysIlce(Table).SehirId.Value := StrToIntDef(edtsehir_id.Text, 0);
      inherited;
    end;
  end
  else
    inherited;
end;

end.
