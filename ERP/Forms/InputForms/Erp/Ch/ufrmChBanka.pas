unit ufrmChBanka;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase, ufrmBaseInputDB;

type
  TfrmChBanka = class(TfrmBaseInputDB)
    lblbanka_adi: TLabel;
    edtbanka_adi: TEdit;
    lblswift_kodu: TLabel;
    edtswift_kodu: TEdit;
    lblis_active: TLabel;
    chkis_active: TCheckBox;
  published
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.ChBanka;

{$R *.dfm}

procedure TfrmChBanka.RefreshData();
begin
  edtbanka_adi.Text := FormatedVariantVal(TChBanka(Table).BankaAdi);
  edtswift_kodu.Text := FormatedVariantVal(TChBanka(Table).SwiftKodu);
  chkis_active.Checked := FormatedVariantVal(TChBanka(Table).IsActive);
end;

procedure TfrmChBanka.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChBanka(Table).BankaAdi.Value := edtbanka_adi.Text;
      TChBanka(Table).SwiftKodu.Value := edtswift_kodu.Text;
      TChBanka(Table).IsActive.Value := chkis_active.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
