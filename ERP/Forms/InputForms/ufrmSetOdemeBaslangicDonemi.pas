unit ufrmSetOdemeBaslangicDonemi;

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
  TfrmSetOdemeBaslangicDonemi = class(TfrmBaseInputDB)
    chkis_aktif: TCheckBox;
    edtaciklama: TEdit;
    edtodeme_baslangic_donemi: TEdit;
    lblaciklama: TLabel;
    lblodeme_baslangic_donemi: TLabel;
    lblis_aktif: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SetOdemeBaslangicDonemi;

{$R *.dfm}

procedure TfrmSetOdemeBaslangicDonemi.RefreshData();
begin
  edtodeme_baslangic_donemi.Text := FormatedVariantVal(TSetOdemeBaslangicDonemi(Table).OdemeBaslangicDonemi);
  edtaciklama.Text := FormatedVariantVal(TSetOdemeBaslangicDonemi(Table).Aciklama);
  chkis_aktif.Checked := FormatedVariantVal(TSetOdemeBaslangicDonemi(Table).IsAktif);
end;

procedure TfrmSetOdemeBaslangicDonemi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetOdemeBaslangicDonemi(Table).OdemeBaslangicDonemi.Value := edtodeme_baslangic_donemi.Text;
      TSetOdemeBaslangicDonemi(Table).Aciklama.Value := edtaciklama.Text;
      TSetOdemeBaslangicDonemi(Table).IsAktif.Value := chkis_aktif.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
