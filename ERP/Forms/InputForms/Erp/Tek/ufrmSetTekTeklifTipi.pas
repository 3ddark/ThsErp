unit ufrmSetTekTeklifTipi;

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
  TfrmSetTekTeklifTipi = class(TfrmBaseInputDB)
    lblteklif_tipi: TLabel;
    edtteklif_tipi: TEdit;
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
  , Ths.Erp.Database.Table.SetTekTeklifTipi
  ;

{$R *.dfm}

procedure TfrmSetTekTeklifTipi.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtteklif_tipi.Text := FormatedVariantVal(TSetTekTeklifTipi(Table).TeklifTipi);
  edtaciklama.Text := FormatedVariantVal(TSetTekTeklifTipi(Table).Aciklama);
  chkis_aktif.Checked := FormatedVariantVal(TSetTekTeklifTipi(Table).IsAktif);
end;

procedure TfrmSetTekTeklifTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetTekTeklifTipi(Table).TeklifTipi.Value := edtteklif_tipi.Text;
      TSetTekTeklifTipi(Table).Aciklama.Value := edtaciklama.Text;
      TSetTekTeklifTipi(Table).IsAktif.Value := chkis_aktif.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
