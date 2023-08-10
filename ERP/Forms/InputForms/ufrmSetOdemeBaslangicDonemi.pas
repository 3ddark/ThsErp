unit ufrmSetOdemeBaslangicDonemi;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetOdemeBaslangicDonemi = class(TfrmBaseInputDB)
    chkis_aktif: TCheckBox;
    edtaciklama: TEdit;
    edtodeme_baslangic_donemi: TEdit;
    lblaciklama: TLabel;
    lblodeme_baslangic_donemi: TLabel;
    lblis_aktif: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SetOdemeBaslangicDonemi;

{$R *.dfm}

procedure TfrmSetOdemeBaslangicDonemi.RefreshData();
begin
  edtodeme_baslangic_donemi.Text := TSetOdemeBaslangicDonemi(Table).OdemeBaslangicDonemi.AsString;
  edtaciklama.Text := TSetOdemeBaslangicDonemi(Table).Aciklama.AsString;
  chkis_aktif.Checked := TSetOdemeBaslangicDonemi(Table).IsAktif.AsBoolean;
end;

procedure TfrmSetOdemeBaslangicDonemi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetOdemeBaslangicDonemi(Table).OdemeBaslangicDonemi.Value := edtodeme_baslangic_donemi.Text;
      TSetOdemeBaslangicDonemi(Table).Aciklama.Value := edtaciklama.Text;
      TSetOdemeBaslangicDonemi(Table).IsAktif.Value := chkis_aktif.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
