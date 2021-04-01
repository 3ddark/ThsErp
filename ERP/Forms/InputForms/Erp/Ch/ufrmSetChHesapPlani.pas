unit ufrmSetChHesapPlani;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetChHesapPlani = class(TfrmBaseInputDB)
    lbltek_duzen_kodu: TLabel;
    edttek_duzen_kodu: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblseviye_sayisi: TLabel;
    cbbseviye_sayisi: TComboBox;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SetChHesapPlani;

{$R *.dfm}

procedure TfrmSetChHesapPlani.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChHesapPlani(Table).TekDuzenKodu.Value := edttek_duzen_kodu.Text;
      TSetChHesapPlani(Table).Aciklama.Value := edtaciklama.Text;
      TSetChHesapPlani(Table).SeviyeSayisi.Value := StrToIntDef(cbbseviye_sayisi.Text, 1);

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetChHesapPlani.FormCreate(Sender: TObject);
begin
  inherited;
  cbbseviye_sayisi.Clear;
  cbbseviye_sayisi.Items.Add('1');
  cbbseviye_sayisi.Items.Add('2');
  cbbseviye_sayisi.Items.Add('3');
  cbbseviye_sayisi.ItemIndex := 0;
end;

procedure TfrmSetChHesapPlani.RefreshData;
begin
  edttek_duzen_kodu.Text := FormatedVariantVal(TSetChHesapPlani(Table).TekDuzenKodu.DataType, TSetChHesapPlani(Table).TekDuzenKodu.Value);
  edtaciklama.Text := FormatedVariantVal(TSetChHesapPlani(Table).Aciklama.DataType, TSetChHesapPlani(Table).Aciklama.Value);
  cbbseviye_sayisi.ItemIndex := cbbseviye_sayisi.Items.IndexOf(VarToStr(FormatedVariantVal(TSetChHesapPlani(Table).SeviyeSayisi)));
end;

end.
