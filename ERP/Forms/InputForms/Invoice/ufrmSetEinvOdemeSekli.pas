unit ufrmSetEinvOdemeSekli;

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
  TfrmSetEinvOdemeSekli = class(TfrmBaseInputDB)
    lblis_active: TLabel;
    chkis_active: TCheckBox;
    lblodeme_sekli: TLabel;
    edtodeme_sekli: TEdit;
    lblkod: TLabel;
    edtkod: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblis_efatura: TLabel;
    chkis_efatura: TCheckBox;
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table.SetEinvOdemeSekli;

{$R *.dfm}

procedure TfrmSetEinvOdemeSekli.RefreshData;
begin
  chkis_active.Checked := TSetEinvOdemeSekli(Table).IsAktif.Value;
  edtodeme_sekli.Text := TSetEinvOdemeSekli(Table).OdemeSekli.Value;
  edtkod.Text := TSetEinvOdemeSekli(Table).Kod.Value;
  edtaciklama.Text := TSetEinvOdemeSekli(Table).Aciklama.Value;
  chkis_efatura.Checked := TSetEinvOdemeSekli(Table).IsEFatura.Value;
end;

procedure TfrmSetEinvOdemeSekli.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvOdemeSekli(Table).IsAktif.Value := chkis_active.Checked;
      TSetEinvOdemeSekli(Table).OdemeSekli.Value := edtodeme_sekli.Text;
      TSetEinvOdemeSekli(Table).Kod.Value := edtkod.Text;
      TSetEinvOdemeSekli(Table).Aciklama.Value := edtaciklama.Text;
      TSetEinvOdemeSekli(Table).IsEFatura.Value := chkis_efatura.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
