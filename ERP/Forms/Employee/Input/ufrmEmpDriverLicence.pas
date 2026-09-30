unit ufrmEmpDriverLicence;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpDriverLicence.Service, EmpDriverLicence;

type
  TfrmEmpDriverLicence = class(TfrmInputSimpleDB<TEmpDriverLicence, TEmpDriverLicenceService>)
    pnlContent: TPanel;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblEmpDriverLicenseTypeId: TLabel;
    edtEmpDriverLicenseTypeId: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees,                           // TfrmEmpEmployees helper output form
  EmpDriverLicenceType, EmpDriverLicenceType.Service, ufrmEmpDriverLicenceTypes;// TfrmEmpDriverLicenceTypes helper output form

procedure TfrmEmpDriverLicence.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  inherited;
end;

procedure TfrmEmpDriverLicence.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtEmpDriverLicenseTypeId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEmpDriverLicence.FormShow(Sender: TObject);
begin
  inherited;
  if edtEmpDriverLicenseTypeId.CanFocus then
    edtEmpDriverLicenseTypeId.SetFocus;
end;

procedure TfrmEmpDriverLicence.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.TitleSingular, 'Employee Driver License');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.ColEmployee, 'Employee');
  lblEmpDriverLicenseTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpDriverAbility.ColLicenseName, 'License Class');
end;

procedure TfrmEmpDriverLicence.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
  LFrmEmpDriverLicenseTypeId: TfrmEmpDriverLicenceTypes;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtEmpEmployeeId.Name then
  begin
    LFrmEmpEmployeeId := TfrmEmpEmployees.Create(LEdit, TEmpEmployeeService.Create, TEmpEmployee.Create);
    try
      LFrmEmpEmployeeId.IsHelper := True;
      LFrmEmpEmployeeId.ShowModal;
      if LFrmEmpEmployeeId.DataTransfer then
        if LFrmEmpEmployeeId.CleanAndClose then
        begin
          Table.EmpEmployeeId := 0;
          Table.EmployeeFullName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpEmployeeId := LFrmEmpEmployeeId.Table.Id;
          Table.EmployeeFullName := LFrmEmpEmployeeId.Table.FullName;
          LEdit.Text := Table.EmployeeFullName;
        end;
    finally
      LFrmEmpEmployeeId.Free;
    end;
  end
  else if LEdit.Name = edtEmpDriverLicenseTypeId.Name then
  begin
    LFrmEmpDriverLicenseTypeId := TfrmEmpDriverLicenceTypes.Create(LEdit, TEmpDriverLicenseTypeService.Create, TEmpDriverLicenseType.Create);
    try
      LFrmEmpDriverLicenseTypeId.IsHelper := True;
      LFrmEmpDriverLicenseTypeId.ShowModal;
      if LFrmEmpDriverLicenseTypeId.DataTransfer then
        if LFrmEmpDriverLicenseTypeId.CleanAndClose then
        begin
          Table.EmpDriverLicenseTypeId := 0;
          Table.LicenseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpDriverLicenseTypeId := LFrmEmpDriverLicenseTypeId.Table.Id;
          Table.LicenseName := LFrmEmpDriverLicenseTypeId.Table.LicenseName;
          LEdit.Text := Table.LicenseName;
        end;
    finally
      LFrmEmpDriverLicenseTypeId.Free;
    end;
  end;
end;

procedure TfrmEmpDriverLicence.RefreshData;
begin
  inherited;
  edtEmpEmployeeId.Text := Table.EmployeeFullName;
  edtEmpDriverLicenseTypeId.Text := Table.LicenseName;
end;

end.
