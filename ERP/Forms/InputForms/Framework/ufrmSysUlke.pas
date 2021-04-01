unit ufrmSysUlke;

interface

{$I ThsERP.inc}

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
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Globals;

type
  TfrmSysUlke = class(TfrmBaseInputDB)
    lblulke_kodu: TLabel;
    lblulke_adi: TLabel;
    lbliso_yil: TLabel;
    lbliso_cctld_kod: TLabel;
    lblis_ab_uyesi: TLabel;
    edtulke_kodu: TEdit;
    edtulke_adi: TEdit;
    edtiso_yil: TEdit;
    edtiso_cctld_kod: TEdit;
    chkis_ab_uyesi: TCheckBox;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUlke.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysUlke(Table).UlkeKodu.Value := edtulke_kodu.Text;
      TSysUlke(Table).UlkeAdi.Value := edtulke_adi.Text;
      TSysUlke(Table).ISOYil.Value := StrToIntDef(edtiso_yil.Text, 0);
      TSysUlke(Table).ISOCCTLDKod.Value := edtiso_cctld_kod.Text;
      TSysUlke(Table).IsABUyesi.Value := chkis_ab_uyesi.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysUlke.FormCreate(Sender: TObject);
begin
  inherited;
  edtiso_cctld_kod.CharCase := ecLowerCase;
end;

procedure TfrmSysUlke.RefreshData;
begin
  edtulke_kodu.Text := FormatedVariantVal(TSysUlke(Table).UlkeKodu);
  edtulke_adi.Text := FormatedVariantVal(TSysUlke(Table).UlkeAdi);
  edtiso_yil.Text := VarToInt(FormatedVariantVal(TSysUlke(Table).ISOYil)).ToString;
  edtiso_cctld_kod.Text := FormatedVariantVal(TSysUlke(Table).ISOCCTLDKod);
  chkis_ab_uyesi.Checked := FormatedVariantVal(TSysUlke(Table).IsABUyesi);
end;

end.
