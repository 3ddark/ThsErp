unit ufrmEmpPersonAddress;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpPersonAddress.Service, EmpPersonAddress;

type
  TfrmEmpPersonAddress = class(TfrmInputSimpleDB<TEmpPersonAddress, TEmpPersonAddressService>)
    pnlContent: TPanel;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblSysAddressId: TLabel;
    edtSysAddressId: TEdit;
    lblAddressType: TLabel;
    cbbAddressType: TComboBox;
    lblIsPrimary: TLabel;
    chkIsPrimary: TCheckBox;
    lblValidFrom: TLabel;
    edtValidFrom: TEdit;
    lblValidTo: TLabel;
    edtValidTo: TEdit;
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
  SysAddress, SysAddress.Service, ufrmSysAddresses;                             // TfrmSysAddresses helper output form

function AddressToText(AAddress: TSysAddress): string;
var
  LParts: TStringList;

  procedure AddPart(const AValue: string);
  begin
    if Trim(AValue) <> '' then
      LParts.Add(Trim(AValue));
  end;

begin
  LParts := TStringList.Create;
  try
    AddPart(AAddress.Neighborhood);
    AddPart(AAddress.Street);
    AddPart(AAddress.DoorNumber);
    AddPart(AAddress.District);
    LParts.Delimiter := ',';
    LParts.StrictDelimiter := True;
    Result := StringReplace(LParts.DelimitedText, ',', ', ', [rfReplaceAll]);
  finally
    LParts.Free;
  end;
end;

procedure TfrmEmpPersonAddress.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  if cbbAddressType.ItemIndex >= 0 then
    Table.AddressType := cbbAddressType.Items[cbbAddressType.ItemIndex]
  else
    Table.AddressType := '';
  Table.IsPrimary := chkIsPrimary.Checked;
  Table.ValidFrom := StrToDateDef(edtValidFrom.Text, 0);
  Table.ValidTo := StrToDateDef(edtValidTo.Text, 0);
  inherited;
end;

procedure TfrmEmpPersonAddress.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtSysAddressId.OnHelperProcess := HelperProcess;
  edtValidFrom.thsInputDataType := itDate;
  edtValidTo.thsInputDataType := itDate;
end;

procedure TfrmEmpPersonAddress.FormShow(Sender: TObject);
begin
  inherited;
  if edtSysAddressId.CanFocus then
    edtSysAddressId.SetFocus;
end;

procedure TfrmEmpPersonAddress.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.TitleSingular, 'Employee Address');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColEmployee, 'Employee');
  lblSysAddressId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColAddress, 'Address');
  lblAddressType.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColAddressType, 'Address Type');
  lblIsPrimary.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColIsPrimary, 'Primary');
  lblValidFrom.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColValidFrom, 'Valid From');
  lblValidTo.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonAddress.ColValidTo, 'Valid To');
end;

procedure TfrmEmpPersonAddress.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
  LFrmSysAddressId: TfrmSysAddresses;
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
  else if LEdit.Name = edtSysAddressId.Name then
  begin
    LFrmSysAddressId := TfrmSysAddresses.Create(LEdit, TSysAddressService.Create, TSysAddress.Create);
    try
      LFrmSysAddressId.IsHelper := True;
      LFrmSysAddressId.ShowModal;
      if LFrmSysAddressId.DataTransfer then
        if LFrmSysAddressId.CleanAndClose then
        begin
          Table.SysAddressId := 0;
          Table.AddressText := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysAddressId := LFrmSysAddressId.Table.Id;
          Table.AddressText := AddressToText(LFrmSysAddressId.Table);
          LEdit.Text := Table.AddressText;
        end;
    finally
      LFrmSysAddressId.Free;
    end;
  end;
end;

procedure TfrmEmpPersonAddress.RefreshData;
begin
  inherited;
  edtEmpEmployeeId.Text := Table.EmployeeFullName;
  edtSysAddressId.Text := Table.AddressText;
  cbbAddressType.ItemIndex := cbbAddressType.Items.IndexOf(Table.AddressType);
  if cbbAddressType.ItemIndex < 0 then
    cbbAddressType.ItemIndex := 0;
  chkIsPrimary.Checked := Table.IsPrimary;
  if Table.ValidFrom > 0 then
    edtValidFrom.Text := DateToStr(Table.ValidFrom)
  else
    edtValidFrom.Text := '';
  if Table.ValidTo > 0 then
    edtValidTo.Text := DateToStr(Table.ValidTo)
  else
    edtValidTo.Text := '';
end;

end.
