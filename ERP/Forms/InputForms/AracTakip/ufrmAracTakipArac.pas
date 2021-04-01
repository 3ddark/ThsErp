unit ufrmAracTakipArac;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,

  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB;

type
  TfrmAracTakipArac = class(TfrmBaseInputDB)
    lblMarka: TLabel;
    edtMarka: TEdit;
    lblModel: TLabel;
    edtModel: TEdit;
    lblPlaka: TLabel;
    edtPlaka: TEdit;
    lblRenk: TLabel;
    edtRenk: TEdit;
    lblGelisTarihi: TLabel;
    edtGelisTarihi: TEdit;
    lblGelisKM: TLabel;
    edtGelisKM: TEdit;
    lblGelisYeri: TLabel;
    edtGelisYeri: TEdit;
    lblAciklama: TLabel;
    mmoAciklama: TMemo;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblAktifKM: TLabel;
    edtAktifKM: TEdit;
    lblAktifKonum: TLabel;
    edtAktifKonum: TEdit;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    procedure FormCreate(Sender: TObject);override;
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
  , Ths.Erp.Database.Table.Arac.Arac
  ;

{$R *.dfm}

procedure TfrmAracTakipArac.FormCreate(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmAracTakipArac.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtMarka.Text := FormatedVariantVal(TArac(Table).Marka.DataType, TArac(Table).Marka.Value);
  edtModel.Text := FormatedVariantVal(TArac(Table).Model.DataType, TArac(Table).Model.Value);
  edtPlaka.Text := FormatedVariantVal(TArac(Table).Plaka.DataType, TArac(Table).Plaka.Value);
  edtRenk.Text := FormatedVariantVal(TArac(Table).Renk.DataType, TArac(Table).Renk.Value);
  edtGelisTarihi.Text := FormatedVariantVal(TArac(Table).GelisTarihi.DataType, TArac(Table).GelisTarihi.Value);
  edtGelisKM.Text := FormatedVariantVal(TArac(Table).GelisKM.DataType, TArac(Table).GelisKM.Value);
  edtGelisYeri.Text := FormatedVariantVal(TArac(Table).GelisYeri.DataType, TArac(Table).GelisYeri.Value);
  mmoAciklama.Text := FormatedVariantVal(TArac(Table).Aciklama.DataType, TArac(Table).Aciklama.Value);
  chkIsActive.Checked := FormatedVariantVal(TArac(Table).IsActive.DataType, TArac(Table).IsActive.Value);
  edtAktifKM.Text := FormatedVariantVal(TArac(Table).AktifKM.DataType, TArac(Table).AktifKM.Value);
  edtAktifKonum.Text := FormatedVariantVal(TArac(Table).AktifKonum.DataType, TArac(Table).AktifKonum.Value);
end;

procedure TfrmAracTakipArac.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TArac(Table).Marka.Value := edtMarka.Text;
      TArac(Table).Model.Value := edtModel.Text;
      TArac(Table).Plaka.Value := edtPlaka.Text;
      TArac(Table).Renk.Value := edtRenk.Text;
      TArac(Table).GelisTarihi.Value := edtGelisTarihi.Text;
      TArac(Table).GelisKM.Value := edtGelisKM.Text;
      TArac(Table).GelisYeri.Value := edtGelisYeri.Text;
      TArac(Table).Aciklama.Value := mmoAciklama.Text;
      TArac(Table).IsActive.Value := chkIsActive.Checked;
      TArac(Table).AktifKM.Value := edtAktifKM.Text;
      TArac(Table).AktifKonum.Value := edtAktifKonum.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
