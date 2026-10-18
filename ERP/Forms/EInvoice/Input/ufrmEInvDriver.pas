unit ufrmEInvDriver;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvDriver.Service, EInvDriver;

type
  TfrmEInvDriver = class(TfrmInputSimpleDB<TEInvDriver, TEInvDriverService>)
    pnlContent: TPanel;
    lblFirstName: TLabel;
    edtFirstName: TEdit;
    lblFamilyName: TLabel;
    edtFamilyName: TEdit;
    lblNationalId: TLabel;
    edtNationalId: TEdit;
    lblPhone: TLabel;
    edtPhone: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvDriver.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.FirstName := edtFirstName.Text;
  Table.FamilyName := edtFamilyName.Text;
  Table.NationalId := edtNationalId.Text;
  Table.Phone := edtPhone.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvDriver.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtFirstName.thsInputDataType := itString;
  edtFamilyName.thsInputDataType := itString;
  edtNationalId.thsInputDataType := itString;
  edtPhone.thsInputDataType := itString;
end;

procedure TfrmEInvDriver.FormShow(Sender: TObject);
begin
  inherited;
  if edtFirstName.CanFocus then
    edtFirstName.SetFocus;
end;

procedure TfrmEInvDriver.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.TitleSingular, 'Driver');
  lblFirstName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColFirstName, 'First Name');
  lblFamilyName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColFamilyName, 'Last Name');
  lblNationalId.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColNationalId, 'National ID');
  lblPhone.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColPhone, 'Phone');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColIsActive, 'Active');
end;

procedure TfrmEInvDriver.RefreshData;
begin
  inherited;
  edtFirstName.Text := Table.FirstName;
  edtFamilyName.Text := Table.FamilyName;
  edtNationalId.Text := Table.NationalId;
  edtPhone.Text := Table.Phone;
  chkIsActive.Checked := Table.IsActive;
end;

end.
