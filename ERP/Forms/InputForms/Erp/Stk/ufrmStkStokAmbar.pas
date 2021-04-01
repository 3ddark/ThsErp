unit ufrmStkStokAmbar;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase, ufrmBaseInputDB;

type
  TfrmStkStokAmbar = class(TfrmBaseInputDB)
    lblambar_adi: TLabel;
    edtambar_adi: TEdit;
    lblis_hammadde_ambari: TLabel;
    chkis_hammadde_ambari: TCheckBox;
    lblis_uretim_ambari: TLabel;
    chkis_uretim_ambari: TCheckBox;
    lblis_satis_ambari: TLabel;
    chkis_satis_ambari: TCheckBox;
  published
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.StkStokAmbar;

{$R *.dfm}

procedure TfrmStkStokAmbar.RefreshData();
begin
  edtambar_adi.Text := FormatedVariantVal(TStkStokAmbar(Table).AmbarAdi.DataType, TStkStokAmbar(Table).AmbarAdi.Value);
  chkis_hammadde_ambari.Checked := FormatedVariantVal(TStkStokAmbar(Table).IsHammaddeAmbari);
  chkis_uretim_ambari.Checked := FormatedVariantVal(TStkStokAmbar(Table).IsUretimAmbari);
  chkis_satis_ambari.Checked := FormatedVariantVal(TStkStokAmbar(Table).IsSatisAmbari);
end;

procedure TfrmStkStokAmbar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkStokAmbar(Table).AmbarAdi.Value := edtambar_adi.Text;
      TStkStokAmbar(Table).IsHammaddeAmbari.Value := chkis_hammadde_ambari.Checked;
      TStkStokAmbar(Table).IsUretimAmbari.Value := chkis_uretim_ambari.Checked;
      TStkStokAmbar(Table).IsSatisAmbari.Value := chkis_satis_ambari.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
