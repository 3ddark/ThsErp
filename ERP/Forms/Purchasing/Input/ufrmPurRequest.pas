unit ufrmPurRequest;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurRequest.Service, PurRequest;

type
  TfrmPurRequest = class(TfrmInputSimpleDB<TPurRequest, TPurRequestService>)
    pnlContent: TPanel;
    lblRequestNo: TLabel;
    edtRequestNo: TEdit;
    lblRequestDate: TLabel;
    edtRequestDate: TEdit;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblRequiredDate: TLabel;
    edtRequiredDate: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
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
  PurLookup,
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees;

procedure TfrmPurRequest.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.RequestNo := edtRequestNo.Text;
  Table.RequestDate := StrToDateDef(edtRequestDate.Text, 0);
  Table.RequiredDate := StrToDateDef(edtRequiredDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurRequest.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtRequestNo.thsInputDataType := itString;
  edtRequestNo.CharCase := TEditCharCase.ecUpperCase;
  edtRequestDate.thsInputDataType := itDate;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtRequiredDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurRequest.FormShow(Sender: TObject);
begin
  inherited;
  if edtRequestDate.CanFocus then
    edtRequestDate.SetFocus;
end;

procedure TfrmPurRequest.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.TitleSingular, 'Purchase Request');
  lblRequestNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequestNo, 'Request No');
  lblRequestDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequestDate, 'Request Date');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColEmpEmployeeId, 'Requested By');
  lblRequiredDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequiredDate, 'Required Date');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColStatus, 'Status');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColDescription, 'Description');
end;

procedure TfrmPurRequest.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
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
          Table.EmployeeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpEmployeeId := LFrmEmpEmployeeId.Table.Id;
          Table.EmployeeName := LFrmEmpEmployeeId.Table.FullName;
          LEdit.Text := Table.EmployeeName;
        end;
    finally
      LFrmEmpEmployeeId.Free;
    end;
  end;
end;

procedure TfrmPurRequest.RefreshData;
begin
  inherited;
  edtRequestNo.Text := Table.RequestNo;
  if Table.RequestDate > 0 then
    edtRequestDate.Text := DateToStr(Table.RequestDate)
  else
    edtRequestDate.Text := '';
  edtEmpEmployeeId.Text := Table.EmployeeName;
  if Table.RequiredDate > 0 then
    edtRequiredDate.Text := DateToStr(Table.RequiredDate)
  else
    edtRequiredDate.Text := '';
  edtStatusText.Text := TPurLookup.Text(plkRequestStatus, Table.Status);
  edtDescription.Text := Table.Description;
end;

end.
