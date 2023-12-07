unit ufrmSysUlke;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Database.Table.SysUlkeler,
  Ths.Globals;

type
  TfrmSysUlke = class(TfrmBaseInputDB)
    lblcode: TLabel;
    lblcountry: TLabel;
    lbliso_year: TLabel;
    lbliso_cctld: TLabel;
    lblis_eu_member: TLabel;
    edtcode: TEdit;
    edtcountry: TEdit;
    edtiso_year: TEdit;
    edtiso_cctld: TEdit;
    chkis_eu_member: TCheckBox;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUlke.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysUlke(Table).UlkeKodu.Value := edtcode.Text;
      TSysUlke(Table).UlkeAdi.Value := edtcountry.Text;
      TSysUlke(Table).ISOYear.Value := StrToIntDef(edtiso_year.Text, 0);
      TSysUlke(Table).ISOCCTLD.Value := edtiso_cctld.Text;
      TSysUlke(Table).IsEUMember.Value := chkis_eu_member.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysUlke.FormCreate(Sender: TObject);
begin
  inherited;
  edtiso_cctld.CharCase := ecLowerCase;
end;

procedure TfrmSysUlke.RefreshData;
begin
  edtcode.Text := TSysUlke(Table).UlkeKodu.AsString;
  edtcountry.Text := TSysUlke(Table).UlkeAdi.AsString;
  edtiso_year.Text := TSysUlke(Table).ISOYear.AsString;
  edtiso_cctld.Text := TSysUlke(Table).ISOCCTLD.AsString;
  chkis_eu_member.Checked := TSysUlke(Table).IsEUMember.AsBoolean;
end;

end.
