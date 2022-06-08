unit ufrmSetSatSiparisDurum;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.DateUtils
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin

  , Data.DB
  , FireDAC.Comp.Client
  , Ths.Erp.Database.Singleton

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB

  , Ths.Erp.Constants
  ;

type
  TfrmSetSatSiparisDurum = class(TfrmBaseInputDB)
    chkis_active: TCheckBox;
    edtaciklama: TEdit;
    edtteklif_durum: TEdit;
    lblaciklama: TLabel;
    lblteklif_durum: TLabel;
    lblis_active: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetSatSiparisDurum
  ;

{$R *.dfm}

procedure TfrmSetSatSiparisDurum.RefreshData();
begin
  //control içeriğini table class ile doldur
  edtteklif_durum.Text := FormatedVariantVal(TSetSatSiparisDurum(Table).SiparisDurum.DataType, TSetSatSiparisDurum(Table).SiparisDurum.Value);
  edtaciklama.Text := FormatedVariantVal(TSetSatSiparisDurum(Table).Aciklama.DataType, TSetSatSiparisDurum(Table).Aciklama.Value);
  chkis_active.Checked := FormatedVariantVal(TSetSatSiparisDurum(Table).IsAktif.DataType, TSetSatSiparisDurum(Table).IsAktif.Value);
end;

procedure TfrmSetSatSiparisDurum.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetSatSiparisDurum(Table).SiparisDurum.Value := edtteklif_durum.Text;
      TSetSatSiparisDurum(Table).Aciklama.Value := edtaciklama.Text;
      TSetSatSiparisDurum(Table).IsAktif.Value := chkis_active.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
