unit ufrmSetTekTeklifTipi;

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
  TfrmSetTekTeklifTipi = class(TfrmBaseInputDB)
    lblteklif_tipi: TLabel;
    edtteklif_tipi: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblis_aktif: TLabel;
    chkis_aktif: TCheckBox;
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SetTekTeklifTipi;

{$R *.dfm}

procedure TfrmSetTekTeklifTipi.RefreshData();
begin
  edtteklif_tipi.Text := TSetTekTeklifTipi(Table).TeklifTipi.AsString;
  edtaciklama.Text := TSetTekTeklifTipi(Table).Aciklama.AsString;
  chkis_aktif.Checked := TSetTekTeklifTipi(Table).IsAktif.AsBoolean;
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
