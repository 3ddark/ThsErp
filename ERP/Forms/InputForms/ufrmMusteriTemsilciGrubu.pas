unit ufrmMusteriTemsilciGrubu;

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
  TfrmMusteriTemsilciGrubu = class(TfrmBaseInputDB)
    edtGecmisAgustos: TEdit;
    edtGecmisAralik: TEdit;
    edtGecmisEkim: TEdit;
    edtGecmisEylul: TEdit;
    edtGecmisHaziran: TEdit;
    edtGecmisKasim: TEdit;
    edtGecmisMart: TEdit;
    edtGecmisMayis: TEdit;
    edtGecmisNisan: TEdit;
    edtGecmisOcak: TEdit;
    edtGecmisSubat: TEdit;
    edtGecmisTemmuz: TEdit;
    edtHedefAgustos: TEdit;
    edtHedefAralik: TEdit;
    edtHedefEkim: TEdit;
    edtHedefEylul: TEdit;
    edtHedefHaziran: TEdit;
    edtHedefKasim: TEdit;
    edtHedefMart: TEdit;
    edtHedefMayis: TEdit;
    edtHedefNisan: TEdit;
    edtHedefOcak: TEdit;
    edtHedefSubat: TEdit;
    edtHedefTemmuz: TEdit;
    edtTemsilciGrupAdi: TEdit;
    lblGecmisAgustos: TLabel;
    lblGecmisAralik: TLabel;
    lblGecmisEkim: TLabel;
    lblGecmisEylul: TLabel;
    lblGecmisHaziran: TLabel;
    lblGecmisKasim: TLabel;
    lblGecmisMart: TLabel;
    lblGecmisMayis: TLabel;
    lblGecmisNisan: TLabel;
    lblGecmisOcak: TLabel;
    lblGecmisSubat: TLabel;
    lblGecmisTemmuz: TLabel;
    lblHedefAgustos: TLabel;
    lblHedefAralik: TLabel;
    lblHedefEkim: TLabel;
    lblHedefEylul: TLabel;
    lblHedefHaziran: TLabel;
    lblHedefKasim: TLabel;
    lblHedefMart: TLabel;
    lblHedefMayis: TLabel;
    lblHedefNisan: TLabel;
    lblHedefOcak: TLabel;
    lblHedefSubat: TLabel;
    lblHedefTemmuz: TLabel;
    lblTemsilciGrupAdi: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.MusteriTemsilciGrubu;

{$R *.dfm}

procedure TfrmMusteriTemsilciGrubu.RefreshData();
begin
  //control i�eri�ini table class ile doldur
  edtTemsilciGrupAdi.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).TemsilciGrupAdi.FieldType, TMusteriTemsilciGrubu(Table).TemsilciGrupAdi.Value);
  edtGecmisOcak.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisOcak.FieldType, TMusteriTemsilciGrubu(Table).GecmisOcak.Value);
  edtGecmisSubat.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisSubat.FieldType, TMusteriTemsilciGrubu(Table).GecmisSubat.Value);
  edtGecmisMart.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisMart.FieldType, TMusteriTemsilciGrubu(Table).GecmisMart.Value);
  edtGecmisNisan.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisNisan.FieldType, TMusteriTemsilciGrubu(Table).GecmisNisan.Value);
  edtGecmisMayis.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisMayis.FieldType, TMusteriTemsilciGrubu(Table).GecmisMayis.Value);
  edtGecmisHaziran.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisHaziran.FieldType, TMusteriTemsilciGrubu(Table).GecmisHaziran.Value);
  edtGecmisTemmuz.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisTemmuz.FieldType, TMusteriTemsilciGrubu(Table).GecmisTemmuz.Value);
  edtGecmisAgustos.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisAgustos.FieldType, TMusteriTemsilciGrubu(Table).GecmisAgustos.Value);
  edtGecmisEylul.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisEylul.FieldType, TMusteriTemsilciGrubu(Table).GecmisEylul.Value);
  edtGecmisEkim.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisEkim.FieldType, TMusteriTemsilciGrubu(Table).GecmisEkim.Value);
  edtGecmisKasim.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisKasim.FieldType, TMusteriTemsilciGrubu(Table).GecmisKasim.Value);
  edtGecmisAralik.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).GecmisAralik.FieldType, TMusteriTemsilciGrubu(Table).GecmisAralik.Value);
  edtHedefOcak.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefOcak.FieldType, TMusteriTemsilciGrubu(Table).HedefOcak.Value);
  edtHedefSubat.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefSubat.FieldType, TMusteriTemsilciGrubu(Table).HedefSubat.Value);
  edtHedefMart.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefMart.FieldType, TMusteriTemsilciGrubu(Table).HedefMart.Value);
  edtHedefNisan.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefNisan.FieldType, TMusteriTemsilciGrubu(Table).HedefNisan.Value);
  edtHedefMayis.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefMayis.FieldType, TMusteriTemsilciGrubu(Table).HedefMayis.Value);
  edtHedefHaziran.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefHaziran.FieldType, TMusteriTemsilciGrubu(Table).HedefHaziran.Value);
  edtHedefTemmuz.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefTemmuz.FieldType, TMusteriTemsilciGrubu(Table).HedefTemmuz.Value);
  edtHedefAgustos.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefAgustos.FieldType, TMusteriTemsilciGrubu(Table).HedefAgustos.Value);
  edtHedefEylul.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefEylul.FieldType, TMusteriTemsilciGrubu(Table).HedefEylul.Value);
  edtHedefEkim.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefEkim.FieldType, TMusteriTemsilciGrubu(Table).HedefEkim.Value);
  edtHedefKasim.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefKasim.FieldType, TMusteriTemsilciGrubu(Table).HedefKasim.Value);
  edtHedefAralik.Text := FormatedVariantVal(TMusteriTemsilciGrubu(Table).HedefAralik.FieldType, TMusteriTemsilciGrubu(Table).HedefAralik.Value);
end;

procedure TfrmMusteriTemsilciGrubu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TMusteriTemsilciGrubu(Table).TemsilciGrupAdi.Value := edtTemsilciGrupAdi.Text;
      TMusteriTemsilciGrubu(Table).GecmisOcak.Value := edtGecmisOcak.Text;
      TMusteriTemsilciGrubu(Table).GecmisSubat.Value := edtGecmisSubat.Text;
      TMusteriTemsilciGrubu(Table).GecmisMart.Value := edtGecmisMart.Text;
      TMusteriTemsilciGrubu(Table).GecmisNisan.Value := edtGecmisNisan.Text;
      TMusteriTemsilciGrubu(Table).GecmisMayis.Value := edtGecmisMayis.Text;
      TMusteriTemsilciGrubu(Table).GecmisHaziran.Value := edtGecmisHaziran.Text;
      TMusteriTemsilciGrubu(Table).GecmisTemmuz.Value := edtGecmisTemmuz.Text;
      TMusteriTemsilciGrubu(Table).GecmisAgustos.Value := edtGecmisAgustos.Text;
      TMusteriTemsilciGrubu(Table).GecmisEylul.Value := edtGecmisEylul.Text;
      TMusteriTemsilciGrubu(Table).GecmisEkim.Value := edtGecmisEkim.Text;
      TMusteriTemsilciGrubu(Table).GecmisKasim.Value := edtGecmisKasim.Text;
      TMusteriTemsilciGrubu(Table).GecmisAralik.Value := edtGecmisAralik.Text;
      TMusteriTemsilciGrubu(Table).HedefOcak.Value := edtHedefOcak.Text;
      TMusteriTemsilciGrubu(Table).HedefSubat.Value := edtHedefSubat.Text;
      TMusteriTemsilciGrubu(Table).HedefMart.Value := edtHedefMart.Text;
      TMusteriTemsilciGrubu(Table).HedefNisan.Value := edtHedefNisan.Text;
      TMusteriTemsilciGrubu(Table).HedefMayis.Value := edtHedefMayis.Text;
      TMusteriTemsilciGrubu(Table).HedefHaziran.Value := edtHedefHaziran.Text;
      TMusteriTemsilciGrubu(Table).HedefTemmuz.Value := edtHedefTemmuz.Text;
      TMusteriTemsilciGrubu(Table).HedefAgustos.Value := edtHedefAgustos.Text;
      TMusteriTemsilciGrubu(Table).HedefEylul.Value := edtHedefEylul.Text;
      TMusteriTemsilciGrubu(Table).HedefEkim.Value := edtHedefEkim.Text;
      TMusteriTemsilciGrubu(Table).HedefKasim.Value := edtHedefKasim.Text;
      TMusteriTemsilciGrubu(Table).HedefAralik.Value := edtHedefAralik.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
