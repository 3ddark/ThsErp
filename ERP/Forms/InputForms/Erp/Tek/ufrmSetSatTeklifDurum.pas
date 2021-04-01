unit ufrmSetSatTeklifDurum;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , System.SysUtils
  , System.StrUtils
  , System.Classes
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.ComCtrls
  , Dialogs
  , System.Variants
  , Vcl.Samples.Spin
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.Graphics
  , Vcl.AppEvnts
  , System.Math
  , Vcl.ImgList
  , Vcl.Menus
  , Data.DB
  , Data.FmtBcd
  , System.Rtti

  , FireDAC.Stan.Option
  , FireDAC.Stan.Intf
  , FireDAC.Comp.Client
  , FireDAC.Stan.Error
  , FireDAC.UI.Intf
  , FireDAC.Stan.Def
  , FireDAC.Stan.Pool
  , FireDAC.Stan.Async
  , FireDAC.Phys
  , FireDAC.VCLUI.Wait

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.Memo
  , Ths.Erp.Helper.ComboBox

  , udm
  , ufrmBase
  , ufrmBaseInputDB
  ;

type
  TfrmSetSatTeklifDurum = class(TfrmBaseInputDB)
    lblteklif_durum: TLabel;
    edtteklif_durum: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblis_aktif: TLabel;
    chkis_aktif: TCheckBox;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SetSatTeklifDurum
  ;

{$R *.dfm}

procedure TfrmSetSatTeklifDurum.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtteklif_durum.Text := FormatedVariantVal(TSetSatTeklifDurum(Table).TeklifDurum);
  edtaciklama.Text := FormatedVariantVal(TSetSatTeklifDurum(Table).Aciklama);
  chkis_aktif.Checked := FormatedVariantVal(TSetSatTeklifDurum(Table).IsAktif);
end;

procedure TfrmSetSatTeklifDurum.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetSatTeklifDurum(Table).TeklifDurum.Value := edtteklif_durum.Text;
      TSetSatTeklifDurum(Table).Aciklama.Value := edtaciklama.Text;
      TSetSatTeklifDurum(Table).IsAktif.Value := chkis_aktif.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
