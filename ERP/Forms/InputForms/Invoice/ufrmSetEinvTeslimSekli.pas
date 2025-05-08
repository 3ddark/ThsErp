unit ufrmSetEinvTeslimSekli;

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
  TfrmSetEinvTeslimSekli = class(TfrmBaseInputDB)
    lblkod: TLabel;
    lblaciklama: TLabel;
    edtkod: TEdit;
    edtaciklama: TEdit;
    chkis_efatura: TCheckBox;
    lblis_efatura: TLabel;
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table.SetEinvTeslimSekli;

{$R *.dfm}

procedure TfrmSetEinvTeslimSekli.RefreshData();
begin
  edtkod.Text := TSetEinvTeslimSekli(Table).TeslimSekli.Value;
  edtaciklama.Text := TSetEinvTeslimSekli(Table).Aciklama.Value;
  chkis_efatura.Checked := TSetEinvTeslimSekli(Table).IsEFatura.Value;
end;

procedure TfrmSetEinvTeslimSekli.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvTeslimSekli(Table).TeslimSekli.Value := edtkod.Text;
      TSetEinvTeslimSekli(Table).Aciklama.Value := edtaciklama.Text;
      TSetEinvTeslimSekli(Table).IsEFatura.Value := chkis_efatura.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
