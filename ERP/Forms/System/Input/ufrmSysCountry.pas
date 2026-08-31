unit ufrmSysCountry;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCountry.Service, SysCountry, Vcl.ExtCtrls, Vcl.Samples.Spin,
  LocalizationManager;

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
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCountry.BtnAcceptClick(Sender: TObject);
begin
  Table.CountryCode := edtCountryCode.Text;
  Table.CountryKey := edtCountryName.Text;
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

procedure TfrmSysCountry.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtCountryCode.SetFocus;
end;

procedure TfrmSysCountry.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_country.title_singular', 'Ülke');
  lblCountryCode.Caption := TLocalizationManager.Translate('sys_country.lbl_code', 'Ülke Kodu (ISO 2)');
  lblCountryName.Caption := TLocalizationManager.Translate('sys_country.lbl_name', 'Ülke Adı');
end;

procedure TfrmSysCountry.RefreshData;
begin
  inherited;
  edtCountryCode.Text := Table.CountryCode;
  edtCountryName.Text := Table.CountryKey;
  edtISOYear.Text := Table.ISOYear.ToString;
  edtISOCCTLD.Text := Table.ISOCCTLD;
  chkIsEuMember.Checked := Table.IsEuMember;
end;

end.
