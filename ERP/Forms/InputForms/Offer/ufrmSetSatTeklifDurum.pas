unit ufrmSetSatTeklifDurum;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  System.Classes,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  ufrmBase,
  ufrmBaseInputDB;

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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SetSatTeklifDurum;

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
