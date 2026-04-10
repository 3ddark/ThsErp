unit ufrmSysCountry;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCountry.Service, SysCountry, Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TfrmSysCountry = class(TfrmInputSimpleDB<TSysCountry, TSysCountryService>)
    pnlContent: TPanel;
    lblcountry_code: TLabel;
    lblcountry_name: TLabel;
    lbliso_year: TLabel;
    lbliso_cctld: TLabel;
    lblis_eu_member: TLabel;
    edtcountry_code: TEdit;
    edtcountry_name: TEdit;
    edtiso_year: TEdit;
    edtiso_cctld: TEdit;
    chkis_eu_member: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCountry.BtnAcceptClick(Sender: TObject);
begin
  Table.CountryCode := edtcountry_code.Text;
  Table.CountryName := edtcountry_name.Text;
  Table.ISOYear := StrToIntDef(edtiso_year.Text, 0);
  Table.ISOCCTLD :=  edtiso_cctld.Text;
  Table.IsEuMember := chkis_eu_member.Checked;
  inherited;
end;

procedure TfrmSysCountry.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
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
  edtcountry_code.Text := Table.CountryCode;
  edtcountry_name.Text := Table.CountryName;
  edtiso_year.Text := Table.ISOYear.ToString;
  edtiso_cctld.Text := Table.ISOCCTLD;
  chkis_eu_member.Checked := Table.IsEuMember;
end;

end.

