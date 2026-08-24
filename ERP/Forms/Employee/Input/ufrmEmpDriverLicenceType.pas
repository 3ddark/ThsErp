unit ufrmEmpDriverLicenceType;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpDriverLicenceType.Service, EmpDriverLicenceType, LocalizationManager;

type
  TfrmEmpDriverLicenceType = class(TfrmInputSimpleDB<TEmpDriverLicenseType, TEmpDriverLicenceTypeService>)
    pnlContent: TPanel;
    lblLicenseName: TLabel;
    edtLicenseName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
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
end;

procedure TfrmEmpDriverLicenceType.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtLicenseName.SetFocus;
end;

procedure TfrmEmpDriverLicenceType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_driver_license_type.title_singular', 'Sürücü Belgesi Tipi');
  lblLicenseName.Caption := TLocalizationManager.Translate('emp_driver_license_type.lbl_license_name', 'Ehliyet Sınıfı');
end;

procedure TfrmEmpDriverLicenceType.InitializeInputCase;
begin
  inherited;
  edtLicenseName.thsInputDataType := itString;
  edtLicenseName.MaxLength := 32;
end;

procedure TfrmEmpDriverLicenceType.RefreshData;
begin
  inherited;
  edtLicenseName.Text := Table.LicenseName;
end;

end.
