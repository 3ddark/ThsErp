unit ufrmSysUlke;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  ufrmBase, ufrmInputSimpleDbX, SharedFormTypes, SysCountry, SysCountry.Service;

type
  TfrmSysUlke = class(TfrmInputSimpleDbX<TSysCountry, TSysCountryService>)
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
      Table.CountryCode := edtcode.Text;
      Table.CountryName := edtcountry.Text;
      Table.ISOYear := StrToIntDef(edtiso_year.Text, 0);
      Table.ISOCCTLD := edtiso_cctld.Text;
      Table.IsEUMember := chkis_eu_member.Checked;

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
  edtcode.Text := Table.CountryCode;
  edtcountry.Text := Table.CountryName;
  edtiso_year.Text := Table.ISOYear.ToString;
  edtiso_cctld.Text := Table.ISOCCTLD;
  chkis_eu_member.Checked := Table.IsEUMember;
end;

end.

