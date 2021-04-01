unit ufrmChBankaSubesi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmChBankaSubesi = class(TfrmBaseInputDB)
    lblbanka_id: TLabel;
    lblsube_kodu: TLabel;
    edtsube_kodu: TEdit;
    lblsube_adi: TLabel;
    edtsube_adi: TEdit;
    lblsube_il_id: TLabel;
    edtbanka_id: TEdit;
    edtsube_il_id: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData(); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Globals,
  Ths.Erp.Database.Table.ChBankaSubesi,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.ChBanka;

{$R *.dfm}

procedure TfrmChBankaSubesi.FormCreate(Sender: TObject);
begin
  inherited;
  edtbanka_id.OnHelperProcess := HelperProcess;
  edtsube_kodu.OnHelperProcess := HelperProcess;
end;

procedure TfrmChBankaSubesi.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmChBankaSubesi.RefreshData();
begin
  edtbanka_id.Text := VarToStr(FormatedVariantVal(TChBankaSubesi(Table).Banka));
  edtsube_kodu.Text := VarToStr(FormatedVariantVal(TChBankaSubesi(Table).SubeKodu));
  edtsube_adi.Text := VarToStr(FormatedVariantVal(TChBankaSubesi(Table).SubeAdi));
  edtsube_il_id.Text := VarToStr(FormatedVariantVal(TChBankaSubesi(Table).SubeIl));
end;

procedure TfrmChBankaSubesi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChBankaSubesi(Table).Banka.Value := edtbanka_id.Text;
      TChBankaSubesi(Table).SubeKodu.Value := edtsube_kodu.Text;
      TChBankaSubesi(Table).SubeAdi.Value := edtsube_adi.Text;
      TChBankaSubesi(Table).SubeIl.Value := edtsube_il_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
