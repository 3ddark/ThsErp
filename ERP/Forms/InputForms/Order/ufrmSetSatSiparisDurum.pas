unit ufrmSetSatSiparisDurum;

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
  TfrmSetSatSiparisDurum = class(TfrmBaseInputDB)
    chkis_active: TCheckBox;
    edtaciklama: TEdit;
    edtteklif_durum: TEdit;
    lblaciklama: TLabel;
    lblteklif_durum: TLabel;
    lblis_active: TLabel;
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table.SetSatSiparisDurum;

{$R *.dfm}

procedure TfrmSetSatSiparisDurum.RefreshData();
begin
  //control içeriğini table class ile doldur
  edtteklif_durum.Text := TSetSatSiparisDurum(Table).SiparisDurum.AsString;
  edtaciklama.Text := TSetSatSiparisDurum(Table).Aciklama.AsString;
  chkis_active.Checked := TSetSatSiparisDurum(Table).IsAktif.AsBoolean;
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
