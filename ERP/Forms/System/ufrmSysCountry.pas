unit ufrmSysCountry;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCountry.Service, SysCountry, Vcl.ExtCtrls;

type
  TfrmSysCountry = class(TfrmInputSimpleDbX<TSysCountry, TSysCountryService>)
    pnlMain: TPanel;
    lblcountry_code: TLabel;
    edtcountry_code: TEdit;
    lblcountry_name: TLabel;
    edtcountry_name: TEdit;
    lbliso_year: TLabel;
    edtiso_year: TEdit;
    lbliso_cctld: TLabel;
    edtiso_cctld: TEdit;
    lblis_eu_member: TLabel;
    chkis_eu_member: TCheckBox;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCountry.BtnAcceptClick(Sender: TObject);
begin
  Table.CountryCode.Value := edtcountry_code.Text;
  Table.CountryName.Value := edtcountry_name.Text;
  Table.ISOYear.Value := StrToIntDef(edtiso_year.Text, 0);
  Table.ISOCCTLD.Value :=  edtiso_cctld.Text;
  Table.IsEuMember.Value := chkis_eu_member.Checked;
  inherited;
end;

procedure TfrmSysCountry.FormCreate(Sender: TObject);
begin
  inherited;

  pnlMain.Parent := PanelMain;
  PanelMain := pnlMain;
end;

procedure TfrmSysCountry.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Country';

  edtcountry_code.SetFocus;
end;

procedure TfrmSysCountry.RefreshData;
begin
  inherited;
  edtcountry_code.Text := Table.CountryCode.Value;
  edtcountry_name.Text := Table.CountryCode.Value;
  edtiso_year.Text := Table.ISOYear.Value.ToString;
  edtiso_cctld.Text := Table.ISOCCTLD.Value;
  chkis_eu_member.Checked := Table.IsEuMember.Value;
end;

end.

