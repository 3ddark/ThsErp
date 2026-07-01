unit ufrmStkStokHareketi;

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
  TfrmStkStokHareketi = class(TfrmBaseInputDB)
    edtMiktar: TEdit;
    edtStokKodu: TEdit;
    edtTarih: TEdit;
    edtTutar: TEdit;
    lblMiktar: TLabel;
    lblStokKodu: TLabel;
    lblTarih: TLabel;
    lblTutar: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
  end;

implementation

uses
  Ths.Erp.Database.Table.StkStokHareketi;

{$R *.dfm}

procedure TfrmStkStokHareketi.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtStokKodu.Text := TStkStokHareketi(Table).StokKodu.Value;
  edtMiktar.Text := TStkStokHareketi(Table).Miktar.Value;
  edtTutar.Text := TStkStokHareketi(Table).Tutar.Value;
  edtTarih.Text := TStkStokHareketi(Table).Tarih.Value;
end;

procedure TfrmStkStokHareketi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkStokHareketi(Table).StokKodu.Value := edtStokKodu.Text;
      TStkStokHareketi(Table).Miktar.Value := edtMiktar.Text;
      TStkStokHareketi(Table).Tutar.Value := edtTutar.Text;
      TStkStokHareketi(Table).Tarih.Value := edtTarih.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
