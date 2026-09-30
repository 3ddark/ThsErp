unit ufrmEmpDriverLicenceType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpDriverLicenceType.Service, EmpDriverLicenceType;

type
  TfrmEmpDriverLicenceType = class(TfrmInputSimpleDB<TEmpDriverLicenseType, TEmpDriverLicenseTypeService>)
    pnlContent: TPanel;
    lblLicenseName: TLabel;
    edtLicenseName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmEmpDriverLicenceType.BtnAcceptClick(Sender: TObject);
begin
  Table.LicenseName := edtLicenseName.Text;
  inherited;
end;

procedure TfrmEmpDriverLicenceType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLicenseName.thsInputDataType := itString;
  edtLicenseName.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmEmpDriverLicenceType.FormShow(Sender: TObject);
begin
  inherited;
  if edtLicenseName.CanFocus then
    edtLicenseName.SetFocus;
end;

procedure TfrmEmpDriverLicenceType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverLicenseType.TitleSingular, 'Driver License Type');
  lblLicenseName.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverLicenseType.ColLicenseName, 'License Class');
end;

procedure TfrmEmpDriverLicenceType.RefreshData;
begin
  inherited;
  edtLicenseName.Text := Table.LicenseName;
end;

end.
