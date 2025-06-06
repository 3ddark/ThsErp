﻿unit ufrmSetSatTeklifDurum;

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
  edtteklif_durum.Text := TSetSatTeklifDurum(Table).TeklifDurum.AsString;
  edtaciklama.Text := TSetSatTeklifDurum(Table).Aciklama.AsString;
end;

procedure TfrmSetSatTeklifDurum.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetSatTeklifDurum(Table).TeklifDurum.Value := edtteklif_durum.Text;
      TSetSatTeklifDurum(Table).Aciklama.Value := edtaciklama.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
