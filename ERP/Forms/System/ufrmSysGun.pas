unit ufrmSysGun;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSysGun = class(TfrmBaseInputDB)
    lblgun_adi: TLabel;
    edtgun_adi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Database.Table.SysGunler;

{$R *.dfm}

procedure TfrmSysGun.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysGun(Table).GunAdi.Value := edtgun_adi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysGun.FormCreate(Sender: TObject);
begin
  inherited;
  edtgun_adi.CharCase := ecNormal;
end;

procedure TfrmSysGun.RefreshData;
begin
  edtgun_adi.Text := TSysGun(Table).GunAdi.AsString;
end;

end.

