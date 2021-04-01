unit ufrmAyarOdemeBaslangicDonemi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit, Ths.Erp.Helper.ComboBox, Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB, Vcl.Samples.Spin;

type
  TfrmAyarOdemeBaslangicDonemi = class(TfrmBaseInputDB)
    chkIsActive: TCheckBox;
    edtAciklama: TEdit;
    edtDeger: TEdit;
    lblAciklama: TLabel;
    lblDeger: TLabel;
    lblIsActive: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.AyarOdemeBaslangicDonemi
  ;

{$R *.dfm}

procedure TfrmAyarOdemeBaslangicDonemi.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtDeger.Text := FormatedVariantVal(TAyarOdemeBaslangicDonemi(Table).Deger.DataType, TAyarOdemeBaslangicDonemi(Table).Deger.Value);
  edtAciklama.Text := FormatedVariantVal(TAyarOdemeBaslangicDonemi(Table).Aciklama.DataType, TAyarOdemeBaslangicDonemi(Table).Aciklama.Value);
  chkIsActive.Checked := FormatedVariantVal(TAyarOdemeBaslangicDonemi(Table).IsActive.DataType, TAyarOdemeBaslangicDonemi(Table).IsActive.Value);
end;

procedure TfrmAyarOdemeBaslangicDonemi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TAyarOdemeBaslangicDonemi(Table).Deger.Value := edtDeger.Text;
      TAyarOdemeBaslangicDonemi(Table).Aciklama.Value := edtAciklama.Text;
      TAyarOdemeBaslangicDonemi(Table).IsActive.Value := chkIsActive.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
