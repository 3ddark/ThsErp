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
    lblCountryCode: TLabel;
    lblCountryName: TLabel;
    lblISOYear: TLabel;
    lblISOCCTLD: TLabel;
    lblIsEuMember: TLabel;
    edtCountryCode: TEdit;
    edtCountryName: TEdit;
    edtISOYear: TEdit;
    edtISOCCTLD: TEdit;
    chkIsEuMember: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCountry.BtnAcceptClick(Sender: TObject);
begin
  Table.CountryCode := edtCountryCode.Text;
  Table.CountryName := edtCountryName.Text;
  Table.ISOYear := StrToIntDef(edtISOYear.Text, 0);
  Table.ISOCCTLD := edtISOCCTLD.Text;
  Table.IsEuMember := chkIsEuMember.Checked;
  inherited;
end;

procedure TfrmSysCountry.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysCountry.InitializeInputCase;
begin
  inherited;
  edtISOYear.thsInputDataType := itInteger;
end;

procedure TfrmSysCountry.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Country';

  edtCountryCode.SetFocus;
end;

procedure TfrmSysCountry.RefreshData;
begin
  inherited;
  edtCountryCode.Text := Table.CountryCode;
  edtCountryName.Text := Table.CountryName;
  edtISOYear.Text := Table.ISOYear.ToString;
  edtISOCCTLD.Text := Table.ISOCCTLD;
  chkIsEuMember.Checked := Table.IsEuMember;
end;

end.
