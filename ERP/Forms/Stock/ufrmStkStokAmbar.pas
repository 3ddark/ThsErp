unit ufrmStkStokAmbar;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase,
  ufrmBaseInputDB;

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
  Ths.Globals, Ths.Constants, Ths.Database.Table.StkAmbarlar;

{$R *.dfm}

procedure TfrmStkStokAmbar.RefreshData();
begin
  edtambar_adi.Text := TStkAmbar(Table).AmbarAdi.AsString;
  chkis_hammadde_ambari.Checked := TStkAmbar(Table).IsVarsayilanHammadde.AsBoolean;
  chkis_uretim_ambari.Checked := TStkAmbar(Table).IsVarsayilanUretim.AsBoolean;
  chkis_satis_ambari.Checked := TStkAmbar(Table).IsVarsayilanSatis.AsBoolean;
end;

procedure TfrmStkStokAmbar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkAmbar(Table).AmbarAdi.Value := edtambar_adi.Text;
      TStkAmbar(Table).IsVarsayilanHammadde.Value := chkis_hammadde_ambari.Checked;
      TStkAmbar(Table).IsVarsayilanUretim.Value := chkis_uretim_ambari.Checked;
      TStkAmbar(Table).IsVarsayilanSatis.Value := chkis_satis_ambari.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
