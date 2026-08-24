unit ufrmEmpDriverLicence;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpDriverLicence.Service, EmpDriverLicence, LocalizationManager;

type
  TfrmEmpDriverLicence = class(TfrmInputSimpleDB<TEmpDriverLicence, TEmpDriverLicenceService>)
    pnlContent: TPanel;
    lblPersonId: TLabel;
    edtPersonId: TEdit;
    lblDriverLicenseId: TLabel;
    edtDriverLicenseId: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EmpPerson, EmpPerson.Service, ufrmEmpPersons,
  EmpDriverLicenceType, EmpDriverLicenceType.Service, ufrmEmpDriverLicenceTypes;

procedure TfrmEmpDriverLicence.BtnAcceptClick(Sender: TObject);
begin
  inherited;
end;

procedure TfrmEmpDriverLicence.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPersonId.OnHelperProcess := HelperProcess;
  edtDriverLicenseId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEmpDriverLicence.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtPersonId.SetFocus;
end;

procedure TfrmEmpDriverLicence.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_driver_ability.title_singular', 'Personel Sürücü Belgesi');
  lblPersonId.Caption := TLocalizationManager.Translate('emp_driver_ability.lbl_person_id', 'Personel');
  lblDriverLicenseId.Caption := TLocalizationManager.Translate('emp_driver_ability.lbl_license_id', 'Ehliyet Sınıfı');
end;

procedure TfrmEmpDriverLicence.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPerson: TfrmEmpPersons;
  LFrmLicenceType: TfrmEmpDriverLicenceTypes;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtPersonId.Name then
    begin
      LFrmPerson := TfrmEmpPersons.Create(LEdit, TEmpPersonService.Create, TEmpPerson.Create);
      try
        LFrmPerson.IsHelper := True;
        LFrmPerson.ShowModal;
        if LFrmPerson.DataTransfer then
        begin
          if LFrmPerson.CleanAndClose then
          begin
            Table.PersonId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.PersonId := LFrmPerson.Table.Id;
            LEdit.Text := LFrmPerson.Table.FullName;
          end;
        end;
      finally
        LFrmPerson.Free;
      end;
    end
    else if LEdit.Name = edtDriverLicenseId.Name then
    begin
      LFrmLicenceType := TfrmEmpDriverLicenceTypes.Create(LEdit, TEmpDriverLicenceTypeService.Create, TEmpDriverLicenseType.Create);
      try
        LFrmLicenceType.IsHelper := True;
        LFrmLicenceType.ShowModal;
        if LFrmLicenceType.DataTransfer then
        begin
          if LFrmLicenceType.CleanAndClose then
          begin
            Table.DriverLicenseId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.DriverLicenseId := LFrmLicenceType.Table.Id;
            LEdit.Text := LFrmLicenceType.Table.LicenseName;
          end;
        end;
      finally
        LFrmLicenceType.Free;
      end;
    end;
  end;
end;

procedure TfrmEmpDriverLicence.InitializeInputCase;
begin
  inherited;
  edtPersonId.thsInputDataType := itInteger;
  edtDriverLicenseId.thsInputDataType := itInteger;
end;

procedure TfrmEmpDriverLicence.RefreshData;
begin
  inherited;
  edtPersonId.Text := Table.PersonId.ToString;
  if Assigned(Table.Ehliyet) then
    edtDriverLicenseId.Text := Table.Ehliyet.LicenseName
  else
    edtDriverLicenseId.Text := Table.DriverLicenseId.ToString;
end;

end.
