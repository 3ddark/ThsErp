unit ufrmEmpLanguageAbility;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpLanguageAbility.Service, EmpLanguageAbility;

type
  TfrmEmpLanguageAbility = class(TfrmInputSimpleDB<TEmpLanguageAbility, TEmpLanguageAbilityService>)
    pnlContent: TPanel;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblEmpLanguageId: TLabel;
    edtEmpLanguageId: TEdit;
    lblReadLevel: TLabel;
    cbbReadLevel: TComboBox;
    lblWriteLevel: TLabel;
    cbbWriteLevel: TComboBox;
    lblSpeakLevel: TLabel;
    cbbSpeakLevel: TComboBox;
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
  EmpLookup,
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees,                           // TfrmEmpEmployees helper output form
  EmpLanguage, EmpLanguage.Service, ufrmEmpLanguages;                           // TfrmEmpLanguages helper output form

procedure TfrmEmpLanguageAbility.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.ReadLevel := cbbReadLevel.ItemIndex + 1;  // seçim yoksa 0 -> zorunluluk kontrolü
  Table.WriteLevel := cbbWriteLevel.ItemIndex + 1;  // seçim yoksa 0 -> zorunluluk kontrolü
  Table.SpeakLevel := cbbSpeakLevel.ItemIndex + 1;  // seçim yoksa 0 -> zorunluluk kontrolü
  inherited;
end;

procedure TfrmEmpLanguageAbility.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtEmpLanguageId.OnHelperProcess := HelperProcess;
  TEmpLookup.FillItems(cbbReadLevel.Items, elkLanguageLevel);
  TEmpLookup.FillItems(cbbWriteLevel.Items, elkLanguageLevel);
  TEmpLookup.FillItems(cbbSpeakLevel.Items, elkLanguageLevel);
end;

procedure TfrmEmpLanguageAbility.FormShow(Sender: TObject);
begin
  inherited;
  if edtEmpLanguageId.CanFocus then
    edtEmpLanguageId.SetFocus;
end;

procedure TfrmEmpLanguageAbility.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.TitleSingular, 'Employee Language');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColEmployee, 'Employee');
  lblEmpLanguageId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColLanguageName, 'Language');
  lblReadLevel.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColReadLevel, 'Reading');
  lblWriteLevel.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColWriteLevel, 'Writing');
  lblSpeakLevel.Caption := TLocalizationManager.Translate(TLangKeys.TEmpLanguageAbility.ColSpeakLevel, 'Speaking');
  LIndex := cbbReadLevel.ItemIndex;
  TEmpLookup.FillItems(cbbReadLevel.Items, elkLanguageLevel);
  cbbReadLevel.ItemIndex := LIndex;
  LIndex := cbbWriteLevel.ItemIndex;
  TEmpLookup.FillItems(cbbWriteLevel.Items, elkLanguageLevel);
  cbbWriteLevel.ItemIndex := LIndex;
  LIndex := cbbSpeakLevel.ItemIndex;
  TEmpLookup.FillItems(cbbSpeakLevel.Items, elkLanguageLevel);
  cbbSpeakLevel.ItemIndex := LIndex;
end;

procedure TfrmEmpLanguageAbility.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
  LFrmEmpLanguageId: TfrmEmpLanguages;
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
  else if LEdit.Name = edtEmpLanguageId.Name then
  begin
    LFrmEmpLanguageId := TfrmEmpLanguages.Create(LEdit, TEmpLanguageService.Create, TEmpLanguage.Create);
    try
      LFrmEmpLanguageId.IsHelper := True;
      LFrmEmpLanguageId.ShowModal;
      if LFrmEmpLanguageId.DataTransfer then
        if LFrmEmpLanguageId.CleanAndClose then
        begin
          Table.EmpLanguageId := 0;
          Table.LanguageName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpLanguageId := LFrmEmpLanguageId.Table.Id;
          Table.LanguageName := LFrmEmpLanguageId.Table.LanguageName;
          LEdit.Text := Table.LanguageName;
        end;
    finally
      LFrmEmpLanguageId.Free;
    end;
  end;
end;

procedure TfrmEmpLanguageAbility.RefreshData;
begin
  inherited;
  edtEmpEmployeeId.Text := Table.EmployeeFullName;
  edtEmpLanguageId.Text := Table.LanguageName;
  cbbReadLevel.ItemIndex := Table.ReadLevel - 1;
  cbbWriteLevel.ItemIndex := Table.WriteLevel - 1;
  cbbSpeakLevel.ItemIndex := Table.SpeakLevel - 1;
end;

end.
