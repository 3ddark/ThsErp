unit ufrmEmpEmployee;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, System.Math,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EmpEmployee.Service, EmpEmployee;

type
  TfrmEmpEmployee = class(TfrmInputSimpleDB<TEmpEmployee, TEmpEmployeeService>)
    pnlContent: TPanel;
    lblName: TLabel;
    edtName: TEdit;
    lblSurname: TLabel;
    edtSurname: TEdit;
    lblPhone1: TLabel;
    edtPhone1: TEdit;
    lblPhone2: TLabel;
    edtPhone2: TEdit;
    lblEmpPersonTypeId: TLabel;
    edtEmpPersonTypeId: TEdit;
    lblEmpUnitId: TLabel;
    edtEmpUnitId: TEdit;
    lblEmpTaskId: TLabel;
    edtEmpTaskId: TEdit;
    lblBirthDate: TLabel;
    edtBirthDate: TEdit;
    lblBloodType: TLabel;
    cbbBloodType: TComboBox;
    lblGender: TLabel;
    cbbGender: TComboBox;
    lblMilitaryStatus: TLabel;
    cbbMilitaryStatus: TComboBox;
    lblMaritalStatus: TLabel;
    cbbMaritalStatus: TComboBox;
    lblChild: TLabel;
    cbbChild: TComboBox;
    lblRelativeName: TLabel;
    edtRelativeName: TEdit;
    lblRelativePhone: TLabel;
    edtRelativePhone: TEdit;
    lblShoeSize: TLabel;
    edtShoeSize: TEdit;
    lblClothingSize: TLabel;
    cbbClothingSize: TComboBox;
    lblEmpTransportationId: TLabel;
    edtEmpTransportationId: TEdit;
    lblSalaryAmount: TLabel;
    edtSalaryAmount: TEdit;
    lblBonusCount: TLabel;
    cbbBonusCount: TComboBox;
    lblBonusAmount: TLabel;
    edtBonusAmount: TEdit;
    lblIdDocumentNo: TLabel;
    edtIdDocumentNo: TEdit;
    lblActive: TLabel;
    chkActive: TCheckBox;
    lblNotes: TLabel;
    mmoNotes: TMemo;
    lblSpecialNotes: TLabel;
    mmoSpecialNotes: TMemo;
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
  EmpPersonType, EmpPersonType.Service, ufrmEmpPersonTypes,                 // TfrmEmpPersonTypes helper output form
  EmpUnit, EmpUnit.Service, ufrmEmpUnits,                                   // TfrmEmpUnits helper output form
  EmpTask, EmpTask.Service, ufrmEmpTasks,                                   // TfrmEmpTasks helper output form
  EmpTransportation, EmpTransportation.Service, ufrmEmpTransportations,
  EmpLookup;     // TfrmEmpTransportations helper output form

// Combo index <-> DB smallint (1 tabanlı; seçim yok = 0 -> NULL / zorunluluk hatası)
function ComboToValue(ACombo: TComboBox): SmallInt;
begin
  Result := ACombo.ItemIndex + 1;
end;

procedure ValueToCombo(ACombo: TComboBox; AValue: SmallInt);
begin
  if (AValue >= 1) and (AValue <= ACombo.Items.Count) then
    ACombo.ItemIndex := AValue - 1
  else
    ACombo.ItemIndex := -1;
end;

// Metin olarak saklanan seçenekler (kan grubu, beden); seçim yok = '' -> NULL
function ComboToText(ACombo: TComboBox): string;
begin
  if ACombo.ItemIndex >= 0 then
    Result := ACombo.Items[ACombo.ItemIndex]
  else
    Result := '';
end;

// Seçenekleri aktif dile göre yeniden doldurur, seçimi korur
procedure FillLookupCombo(ACombo: TComboBox; AKind: TEmpLookupKind);
var
  LIndex: Integer;
begin
  LIndex := ACombo.ItemIndex;
  TEmpLookup.FillItems(ACombo.Items, AKind);
  ACombo.ItemIndex := LIndex;
end;

procedure TfrmEmpEmployee.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; full_name servis tarafından üretilir
  Table.Name := edtName.Text;
  Table.Surname := edtSurname.Text;
  Table.Phone1 := edtPhone1.Text;
  Table.Phone2 := edtPhone2.Text;
  Table.BirthDate := StrToDateDef(edtBirthDate.Text, 0);
  Table.BloodType := ComboToText(cbbBloodType);
  Table.Gender := ComboToValue(cbbGender);
  Table.MilitaryStatus := ComboToValue(cbbMilitaryStatus);
  Table.MaritalStatus := ComboToValue(cbbMaritalStatus);
  Table.Child := Max(cbbChild.ItemIndex, 0);           // 0-30: ItemIndex = değer
  Table.RelativeName := edtRelativeName.Text;
  Table.RelativePhone := edtRelativePhone.Text;
  Table.ShoeSize := StrToIntDef(edtShoeSize.Text, 0);
  Table.ClothingSize := ComboToText(cbbClothingSize);
  Table.Notes := mmoNotes.Text;
  Table.SpecialNotes := mmoSpecialNotes.Text;
  Table.SalaryAmount := StrToCurrDef(edtSalaryAmount.Text, 0);
  Table.BonusCount := Max(cbbBonusCount.ItemIndex, 0);  // 0-30: ItemIndex = değer
  Table.BonusAmount := StrToCurrDef(edtBonusAmount.Text, 0);
  Table.IdDocumentNo := edtIdDocumentNo.Text;
  Table.Active := chkActive.Checked;
  inherited;
end;

procedure TfrmEmpEmployee.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;

  edtEmpPersonTypeId.OnHelperProcess := HelperProcess;
  edtEmpUnitId.OnHelperProcess := HelperProcess;
  edtEmpTaskId.OnHelperProcess := HelperProcess;
  edtEmpTransportationId.OnHelperProcess := HelperProcess;

  FillLookupCombo(cbbGender, elkGender);
  FillLookupCombo(cbbMilitaryStatus, elkMilitaryStatus);
  FillLookupCombo(cbbMaritalStatus, elkMaritalStatus);
  FillLookupCombo(cbbBloodType, elkBloodType);
  FillLookupCombo(cbbClothingSize, elkClothingSize);
  TEmpLookup.FillRange(cbbChild.Items, 0, 30);
  TEmpLookup.FillRange(cbbBonusCount.Items, 0, 30);

  edtName.thsInputDataType := itString;
  edtSurname.thsInputDataType := itString;
  edtBirthDate.thsInputDataType := itDate;
  edtShoeSize.thsInputDataType := itInteger;
  edtSalaryAmount.thsInputDataType := itFloat;
  edtBonusAmount.thsInputDataType := itFloat;
end;

procedure TfrmEmpEmployee.FormShow(Sender: TObject);
begin
  inherited;
  if edtName.CanFocus then
    edtName.SetFocus;
end;

procedure TfrmEmpEmployee.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.TitleSingular, 'Employee');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColName, 'First Name');
  lblSurname.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSurname, 'Surname');
  lblPhone1.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColPhone1, 'Phone 1');
  lblPhone2.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColPhone2, 'Phone 2');
  lblEmpPersonTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColPersonType, 'Employee Type');
  lblEmpUnitId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColUnitName, 'Unit');
  lblEmpTaskId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColTaskName, 'Task');
  lblBirthDate.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBirthDate, 'Birth Date');
  lblBloodType.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBloodType, 'Blood Type');
  lblGender.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColGender, 'Gender');
  lblMilitaryStatus.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColMilitaryStatus, 'Military Status');
  lblMaritalStatus.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColMaritalStatus, 'Marital Status');
  lblChild.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColChild, 'Children');
  lblRelativeName.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColRelativeName, 'Relative Name');
  lblRelativePhone.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColRelativePhone, 'Relative Phone');
  lblShoeSize.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColShoeSize, 'Shoe Size');
  lblClothingSize.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColClothingSize, 'Clothing Size');
  lblEmpTransportationId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColTransportation, 'Transportation');
  lblSalaryAmount.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSalaryAmount, 'Salary');
  lblBonusCount.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBonusCount, 'Bonus Count');
  lblBonusAmount.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColBonusAmount, 'Bonus Amount');
  lblIdDocumentNo.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColIdDocumentNo, 'ID Document No');
  lblActive.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColActive, 'Active');
  lblNotes.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColNotes, 'Notes');
  lblSpecialNotes.Caption := TLocalizationManager.Translate(TLangKeys.TEmpEmployee.ColSpecialNotes, 'Special Notes');

  FillLookupCombo(cbbGender, elkGender);
  FillLookupCombo(cbbMilitaryStatus, elkMilitaryStatus);
  FillLookupCombo(cbbMaritalStatus, elkMaritalStatus);
end;

procedure TfrmEmpEmployee.HelperProcess(Sender: TObject);
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
    if LEdit.Name = edtEmpPersonTypeId.Name then
    begin
      LFrmPersonType := TfrmEmpPersonTypes.Create(LEdit, TEmpPersonTypeService.Create, TEmpPersonType.Create);
      try
        LFrmPersonType.IsHelper := True;
        LFrmPersonType.ShowModal;
        if LFrmPersonType.DataTransfer then
          if LFrmPersonType.CleanAndClose then
          begin
            Table.EmpPersonTypeId := 0;
            Table.PersonType := '';
            LEdit.Clear;
          end
          else
          begin
            Table.EmpPersonTypeId := LFrmPersonType.Table.Id;
            Table.PersonType := LFrmPersonType.Table.PersonType;
            LEdit.Text := Table.PersonType;
          end;
      finally
        LFrmPersonType.Free;
      end;
    end
    else if LEdit.Name = edtEmpUnitId.Name then
    begin
      LFrmUnit := TfrmEmpUnits.Create(LEdit, TEmpUnitService.Create, TEmpUnit.Create);
      try
        LFrmUnit.IsHelper := True;
        LFrmUnit.ShowModal;
        if LFrmUnit.DataTransfer then
          if LFrmUnit.CleanAndClose then
          begin
            Table.EmpUnitId := 0;
            Table.EmpUnitName := '';
            LEdit.Clear;
          end
          else
          begin
            Table.EmpUnitId := LFrmUnit.Table.Id;
            Table.EmpUnitName := LFrmUnit.Table.EmpUnitName;
            LEdit.Text := Table.EmpUnitName;
          end;
      finally
        LFrmUnit.Free;
      end;
    end
    else if LEdit.Name = edtEmpTaskId.Name then
    begin
      LFrmTask := TfrmEmpTasks.Create(LEdit, TEmpTaskService.Create, TEmpTask.Create);
      try
        LFrmTask.IsHelper := True;
        LFrmTask.ShowModal;
        if LFrmTask.DataTransfer then
          if LFrmTask.CleanAndClose then
          begin
            Table.EmpTaskId := 0;
            Table.TaskName := '';
            LEdit.Clear;
          end
          else
          begin
            Table.EmpTaskId := LFrmTask.Table.Id;
            Table.TaskName := LFrmTask.Table.TaskName;
            LEdit.Text := Table.TaskName;
          end;
      finally
        LFrmTask.Free;
      end;
    end
    else if LEdit.Name = edtEmpTransportationId.Name then
    begin
      LFrmTrans := TfrmEmpTransportations.Create(LEdit, TEmpTransportationService.Create, TEmpTransportation.Create);
      try
        LFrmTrans.IsHelper := True;
        LFrmTrans.ShowModal;
        if LFrmTrans.DataTransfer then
          if LFrmTrans.CleanAndClose then
          begin
            Table.EmpTransportationId := 0;
            Table.TransportationName := '';
            LEdit.Clear;
          end
          else
          begin
            Table.EmpTransportationId := LFrmTrans.Table.Id;
            Table.TransportationName := LFrmTrans.Table.CarName;
            LEdit.Text := Table.TransportationName;
          end;
      finally
        LFrmTrans.Free;
      end;
    end;
  end;
end;

procedure TfrmEmpEmployee.RefreshData;
begin
  inherited;
  edtName.Text := Table.Name;
  edtSurname.Text := Table.Surname;
  edtPhone1.Text := Table.Phone1;
  edtPhone2.Text := Table.Phone2;
  edtEmpPersonTypeId.Text := Table.PersonType;
  edtEmpUnitId.Text := Table.EmpUnitName;
  edtEmpTaskId.Text := Table.TaskName;
  if Table.BirthDate > 0 then
    edtBirthDate.Text := DateToStr(Table.BirthDate)
  else
    edtBirthDate.Text := '';
  cbbBloodType.ItemIndex := cbbBloodType.Items.IndexOf(Table.BloodType);
  ValueToCombo(cbbGender, Table.Gender);
  ValueToCombo(cbbMilitaryStatus, Table.MilitaryStatus);
  ValueToCombo(cbbMaritalStatus, Table.MaritalStatus);
  cbbChild.ItemIndex := EnsureRange(Table.Child, 0, 30);
  edtRelativeName.Text := Table.RelativeName;
  edtRelativePhone.Text := Table.RelativePhone;
  edtShoeSize.Text := IntToStr(Table.ShoeSize);
  cbbClothingSize.ItemIndex := cbbClothingSize.Items.IndexOf(Table.ClothingSize);
  mmoNotes.Text := Table.Notes;
  edtEmpTransportationId.Text := Table.TransportationName;
  mmoSpecialNotes.Text := Table.SpecialNotes;
  edtSalaryAmount.Text := CurrToStr(Table.SalaryAmount);
  cbbBonusCount.ItemIndex := EnsureRange(Table.BonusCount, 0, 30);
  edtBonusAmount.Text := CurrToStr(Table.BonusAmount);
  edtIdDocumentNo.Text := Table.IdDocumentNo;
  chkActive.Checked := Table.Active;
end;

end.
