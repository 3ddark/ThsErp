unit ufrmEmpPerson;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Samples.Spin, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EmpPerson.Service, EmpPerson, LocalizationManager;

type
  TfrmEmpPerson = class(TfrmInputSimpleDB<TEmpPerson, TEmpPersonService>)
    pnlContent: TPanel;
    lblName: TLabel;
    edtName: TEdit;
    lblSurname: TLabel;
    edtSurname: TEdit;
    lblPhone1: TLabel;
    edtPhone1: TEdit;
    lblPhone2: TLabel;
    edtPhone2: TEdit;
    lblPersonTypeId: TLabel;
    edtPersonTypeId: TEdit;
    lblUnitId: TLabel;
    edtUnitId: TEdit;
    lblTaskId: TLabel;
    edtTaskId: TEdit;
    lblBirth: TLabel;
    dtpBirth: TDateTimePicker;
    lblBlood: TLabel;
    edtBlood: TEdit;
    lblGender: TLabel;
    cbbGender: TComboBox;
    lblMilitaryStatus: TLabel;
    cbbMilitaryStatus: TComboBox;
    lblMaritalStatus: TLabel;
    cbbMaritalStatus: TComboBox;
    lblChild: TLabel;
    seChild: TSpinEdit;
    lblRelatedName: TLabel;
    edtRelatedName: TEdit;
    lblRelatedPhone: TLabel;
    edtRelatedPhone: TEdit;
    lblShoe: TLabel;
    seShoe: TSpinEdit;
    lblDress: TLabel;
    edtDress: TEdit;
    lblNotes: TLabel;
    mmoNotes: TMemo;
    lblTransportationId: TLabel;
    edtTransportationId: TEdit;
    lblSpecialNotes: TLabel;
    mmoSpecialNotes: TMemo;
    lblSalary: TLabel;
    edtSalary: TEdit;
    lblNumberOfBonus: TLabel;
    seNumberOfBonus: TSpinEdit;
    lblBonus: TLabel;
    lblIdentification: TLabel;
    edtIdentification: TEdit;
    lblActive: TLabel;
    chkActive: TCheckBox;
    edtBonus: TEdit;
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
  EmpPersonType, EmpPersonType.Service, ufrmEmpPersonTypes,
  EmpUnit, EmpUnit.Service, ufrmEmpUnits,
  EmpTask, EmpTask.Service, ufrmEmpTasks,
  EmpTransportation, EmpTransportation.Service, ufrmEmpTransportations,
  SysAddress, SysAddress.Service, ufrmSysAddresses;

procedure TfrmEmpPerson.BtnAcceptClick(Sender: TObject);
begin
  Table.Name := edtName.Text;
  Table.Surname := edtSurname.Text;
  Table.FullName := Trim(edtName.Text + ' ' + edtSurname.Text);
  Table.Phone1 := edtPhone1.Text;
  Table.Phone2 := edtPhone2.Text;
  Table.Birth := dtpBirth.Date;
  Table.Blood := edtBlood.Text;
  Table.Gender := cbbGender.ItemIndex + 1;
  Table.MilitaryStatus := cbbMilitaryStatus.ItemIndex + 1;
  Table.MaritalStatus := cbbMaritalStatus.ItemIndex + 1;
  Table.Child := seChild.Value;
  Table.RelatedName := edtRelatedName.Text;
  Table.RelatedPhone := edtRelatedPhone.Text;
  Table.Shoe := seShoe.Value;
  Table.Dress := edtDress.Text;
  Table.Notes := mmoNotes.Text;
  Table.SpecialNotes := mmoSpecialNotes.Text;
  Table.Salary := StrToCurrDef(edtSalary.Text, 0);
  Table.NumberOfBonus := seNumberOfBonus.Value;
  Table.Bonus := StrToCurrDef(edtBonus.Text, 0);
  Table.Identification := edtIdentification.Text;
  Table.Active := chkActive.Checked;
  inherited;
end;

procedure TfrmEmpPerson.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPersonTypeId.OnHelperProcess := HelperProcess;
  edtUnitId.OnHelperProcess := HelperProcess;
  edtTaskId.OnHelperProcess := HelperProcess;
  edtTransportationId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEmpPerson.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtName.SetFocus;
end;

procedure TfrmEmpPerson.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_person.title_singular', 'Personel');
  lblName.Caption := TLocalizationManager.Translate('emp_person.lbl_name', 'Adı');
  lblSurname.Caption := TLocalizationManager.Translate('emp_person.lbl_surname', 'Soyadı');
  lblPhone1.Caption := TLocalizationManager.Translate('emp_person.lbl_phone1', 'Telefon 1');
  lblPhone2.Caption := TLocalizationManager.Translate('emp_person.lbl_phone2', 'Telefon 2');
  lblPersonTypeId.Caption := TLocalizationManager.Translate('emp_person.lbl_person_type_id', 'Personel Tipi');
  lblUnitId.Caption := TLocalizationManager.Translate('emp_person.lbl_unit_id', 'Birim');
  lblTaskId.Caption := TLocalizationManager.Translate('emp_person.lbl_task_id', 'Görev');
  lblBirth.Caption := TLocalizationManager.Translate('emp_person.lbl_birth', 'Doğum Tarihi');
  lblBlood.Caption := TLocalizationManager.Translate('emp_person.lbl_blood', 'Kan Grubu');
  lblGender.Caption := TLocalizationManager.Translate('emp_person.lbl_gender', 'Cinsiyet');
  lblMilitaryStatus.Caption := TLocalizationManager.Translate('emp_person.lbl_military_status', 'Askerlik Durumu');
  lblMaritalStatus.Caption := TLocalizationManager.Translate('emp_person.lbl_marital_status', 'Medeni Durum');
  lblChild.Caption := TLocalizationManager.Translate('emp_person.lbl_child', 'Çocuk Sayısı');
  lblRelatedName.Caption := TLocalizationManager.Translate('emp_person.lbl_related_name', 'Yakın Adı');
  lblRelatedPhone.Caption := TLocalizationManager.Translate('emp_person.lbl_related_phone', 'Yakın Tel');
  lblShoe.Caption := TLocalizationManager.Translate('emp_person.lbl_shoe', 'Ayakkabı No');
  lblDress.Caption := TLocalizationManager.Translate('emp_person.lbl_dress', 'Beden');
  lblNotes.Caption := TLocalizationManager.Translate('emp_person.lbl_notes', 'Notlar');
  lblTransportationId.Caption := TLocalizationManager.Translate('emp_person.lbl_transportation_id', 'Servis Güzergahı');
  lblSpecialNotes.Caption := TLocalizationManager.Translate('emp_person.lbl_special_notes', 'Özel Notlar');
  lblSalary.Caption := TLocalizationManager.Translate('emp_person.lbl_salary', 'Maaş');
  lblNumberOfBonus.Caption := TLocalizationManager.Translate('emp_person.lbl_number_of_bonus', 'Ikramiye Adedi');
  lblBonus.Caption := TLocalizationManager.Translate('emp_person.lbl_bonus', 'Ikramiye Tutarı');
  lblIdentification.Caption := TLocalizationManager.Translate('emp_person.lbl_identification', 'T.C. / Kimlik No');
  lblActive.Caption := TLocalizationManager.Translate('emp_person.lbl_active', 'Aktif');
end;

procedure TfrmEmpPerson.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPersonType: TfrmEmpPersonTypes;
  LFrmUnit: TfrmEmpUnits;
  LFrmTask: TfrmEmpTasks;
  LFrmTrans: TfrmEmpTransportations;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtPersonTypeId.Name then
    begin
      LFrmPersonType := TfrmEmpPersonTypes.Create(LEdit, TEmpPersonTypeService.Create, TEmpPersonType.Create);
      try
        LFrmPersonType.IsHelper := True;
        LFrmPersonType.ShowModal;
        if LFrmPersonType.DataTransfer then
        begin
          if LFrmPersonType.CleanAndClose then
          begin
            Table.PersonTypeId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.PersonTypeId := LFrmPersonType.Table.Id;
            LEdit.Text := LFrmPersonType.Table.PersonType;
          end;
        end;
      finally
        LFrmPersonType.Free;
      end;
    end
    else if LEdit.Name = edtUnitId.Name then
    begin
      LFrmUnit := TfrmEmpUnits.Create(LEdit, TEmpUnitService.Create, TEmpUnit.Create);
      try
        LFrmUnit.IsHelper := True;
        LFrmUnit.ShowModal;
        if LFrmUnit.DataTransfer then
        begin
          if LFrmUnit.CleanAndClose then
          begin
            Table.UnitId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.UnitId := LFrmUnit.Table.Id;
            LEdit.Text := LFrmUnit.Table.UnitName_;
          end;
        end;
      finally
        LFrmUnit.Free;
      end;
    end
    else if LEdit.Name = edtTaskId.Name then
    begin
      LFrmTask := TfrmEmpTasks.Create(LEdit, TEmpTaskService.Create, TEmpTask.Create);
      try
        LFrmTask.IsHelper := True;
        LFrmTask.ShowModal;
        if LFrmTask.DataTransfer then
        begin
          if LFrmTask.CleanAndClose then
          begin
            Table.TaskId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.TaskId := LFrmTask.Table.Id;
            LEdit.Text := LFrmTask.Table.TaskName;
          end;
        end;
      finally
        LFrmTask.Free;
      end;
    end
    else if LEdit.Name = edtTransportationId.Name then
    begin
      LFrmTrans := TfrmEmpTransportations.Create(LEdit, TEmpTransportationService.Create, TEmpTransportation.Create);
      try
        LFrmTrans.IsHelper := True;
        LFrmTrans.ShowModal;
        if LFrmTrans.DataTransfer then
        begin
          if LFrmTrans.CleanAndClose then
          begin
            Table.TransportationId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.TransportationId := LFrmTrans.Table.Id;
            LEdit.Text := LFrmTrans.Table.CarName;
          end;
        end;
      finally
        LFrmTrans.Free;
      end;
    end;
  end;
end;

procedure TfrmEmpPerson.RefreshData;
begin
  inherited;
  edtName.Text := Table.Name;
  edtSurname.Text := Table.Surname;
  edtPhone1.Text := Table.Phone1;
  edtPhone2.Text := Table.Phone2;
  if Assigned(Table.PersonType) then
    edtPersonTypeId.Text := Table.PersonType.PersonType
  else
    edtPersonTypeId.Text := '';
  if Assigned(Table.Unit_) then
    edtUnitId.Text := Table.Unit_.UnitName_
  else
    edtUnitId.Text := '';
  if Assigned(Table.Task) then
    edtTaskId.Text := Table.Task.TaskName
  else
    edtTaskId.Text := '';
  dtpBirth.Date := Table.Birth;
  edtBlood.Text := Table.Blood;
  if (Table.Gender >= 1) and (Table.Gender <= cbbGender.Items.Count) then
    cbbGender.ItemIndex := Table.Gender - 1
  else
    cbbGender.ItemIndex := 0;

  if (Table.MilitaryStatus >= 1) and (Table.MilitaryStatus <= cbbMilitaryStatus.Items.Count) then
    cbbMilitaryStatus.ItemIndex := Table.MilitaryStatus - 1
  else
    cbbMilitaryStatus.ItemIndex := 0;

  if (Table.MaritalStatus >= 1) and (Table.MaritalStatus <= cbbMaritalStatus.Items.Count) then
    cbbMaritalStatus.ItemIndex := Table.MaritalStatus - 1
  else
    cbbMaritalStatus.ItemIndex := 0;

  seChild.Value := Table.Child;
  edtRelatedName.Text := Table.RelatedName;
  edtRelatedPhone.Text := Table.RelatedPhone;
  seShoe.Value := Table.Shoe;
  edtDress.Text := Table.Dress;
  mmoNotes.Text := Table.Notes;
  edtTransportationId.Text := Table.TransportationId.ToString;
  mmoSpecialNotes.Text := Table.SpecialNotes;
  edtSalary.Text := CurrToStr(Table.Salary);
  seNumberOfBonus.Value := Table.NumberOfBonus;
  edtBonus.Text := CurrToStr(Table.Bonus);
  edtIdentification.Text := Table.Identification;
  chkActive.Checked := Table.Active;
end;

end.
