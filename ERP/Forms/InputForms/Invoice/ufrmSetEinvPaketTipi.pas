unit ufrmSetEinvPaketTipi;

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
  TfrmSetEinvPaketTipi = class(TfrmBaseInputDB)
    lblpaket_adi: TLabel;
    lblis_active: TLabel;
    lblkod: TLabel;
    lblaciklama: TLabel;
    chkis_active: TCheckBox;
    edtkod: TEdit;
    edtpaket_adi: TEdit;
    edtaciklama: TEdit;
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table.SetEinvPaketTipi;

{$R *.dfm}

procedure TfrmSetEinvPaketTipi.RefreshData;
begin
  chkis_active.Checked := TSetEinvPaketTipi(Table).IsAktif.Value;
  edtkod.Text := TSetEinvPaketTipi(Table).Kod.Value;
  edtpaket_adi.Text := TSetEinvPaketTipi(Table).PaketTipi.Value;
  edtaciklama.Text := TSetEinvPaketTipi(Table).Aciklama.Value;
end;

procedure TfrmSetEinvPaketTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvPaketTipi(Table).IsAktif.Value := chkis_active.Checked;
      TSetEinvPaketTipi(Table).Kod.Value := edtkod.Text;
      TSetEinvPaketTipi(Table).PaketTipi.Value := edtpaket_adi.Text;
      TSetEinvPaketTipi(Table).Aciklama.Value := edtaciklama.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
