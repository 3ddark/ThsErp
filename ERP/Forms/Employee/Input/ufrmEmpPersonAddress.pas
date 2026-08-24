unit ufrmEmpPersonAddress;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, EmpPersonAddress.Service, EmpPersonAddress, LocalizationManager;

type
  TfrmEmpPersonAddress = class(TfrmInputSimpleDB<TEmpPersonAddress, TEmpPersonAddressService>)
    pnlContent: TPanel;
    lblPersonId: TLabel;
    edtPersonId: TEdit;
    lblAddressId: TLabel;
    edtAddressId: TEdit;
    lblAddressType: TLabel;
    cbbAddressType: TComboBox;
    lblIsPrimary: TLabel;
    chkIsPrimary: TCheckBox;
    lblValidFrom: TLabel;
    dtpValidFrom: TDateTimePicker;
    lblValidTo: TLabel;
    dtpValidTo: TDateTimePicker;
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
  SysAddress, SysAddress.Service, ufrmSysAddresses;

procedure TfrmEmpPersonAddress.BtnAcceptClick(Sender: TObject);
begin
  if cbbAddressType.ItemIndex >= 0 then
    Table.AddressType := cbbAddressType.Items[cbbAddressType.ItemIndex]
  else
    Table.AddressType := 'HOME';
  Table.IsPrimary := chkIsPrimary.Checked;
  Table.ValidFrom := dtpValidFrom.Date;
  Table.ValidTo := dtpValidTo.Date;
  inherited;
end;

procedure TfrmEmpPersonAddress.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPersonId.OnHelperProcess := HelperProcess;
  edtAddressId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEmpPersonAddress.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtPersonId.SetFocus;
end;

procedure TfrmEmpPersonAddress.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_person_address.title_singular', 'Personel Adresi');
  lblPersonId.Caption := TLocalizationManager.Translate('emp_person_address.lbl_person_id', 'Personel');
  lblAddressId.Caption := TLocalizationManager.Translate('emp_person_address.lbl_address_id', 'Adres');
  lblAddressType.Caption := TLocalizationManager.Translate('emp_person_address.lbl_address_type', 'Adres Tipi');
  lblIsPrimary.Caption := TLocalizationManager.Translate('emp_person_address.lbl_is_primary', 'Birincil Adres');
  lblValidFrom.Caption := TLocalizationManager.Translate('emp_person_address.lbl_valid_from', 'Geçerlilik Başlangıcı');
  lblValidTo.Caption := TLocalizationManager.Translate('emp_person_address.lbl_valid_to', 'Geçerlilik Bitişi');
end;

procedure TfrmEmpPersonAddress.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPerson: TfrmEmpPersons;
  LFrmAddress: TfrmSysAddresses;
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
    else if LEdit.Name = edtAddressId.Name then
    begin
      LFrmAddress := TfrmSysAddresses.Create(LEdit, TSysAddressService.Create, TSysAddress.Create);
      try
        LFrmAddress.IsHelper := True;
        LFrmAddress.ShowModal;
        if LFrmAddress.DataTransfer then
        begin
          if LFrmAddress.CleanAndClose then
          begin
//            Table.AddressId := 0;
//            LEdit.Clear;
          end
          else
          begin
//            Table.AddressId := LFrmAddress.Table.Id;
//            LEdit.Text := LFrmAddress.Table.District;
          end;
        end;
      finally
        LFrmAddress.Free;
      end;
    end;
  end;
end;

procedure TfrmEmpPersonAddress.InitializeInputCase;
begin
  inherited;
  edtPersonId.thsInputDataType := itInteger;
  edtAddressId.thsInputDataType := itInteger;
end;

procedure TfrmEmpPersonAddress.RefreshData;
var
  LIdx: Integer;
begin
  inherited;
  edtPersonId.Text := Table.PersonId.ToString;
  if Assigned(Table.Person) then
    edtPersonId.Text := Table.Person.FullName;

  edtAddressId.Text := Table.AddressId.ToString;
  if Assigned(Table.Address) then
    edtAddressId.Text := Table.Address.District;

  LIdx := cbbAddressType.Items.IndexOf(Table.AddressType);
  if LIdx >= 0 then
    cbbAddressType.ItemIndex := LIdx
  else
    cbbAddressType.ItemIndex := 0;

  chkIsPrimary.Checked := Table.IsPrimary;
  dtpValidFrom.Date := Table.ValidFrom;
  dtpValidTo.Date := Table.ValidTo;
end;

end.
