unit ufrmEmpLanguageAbility;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  EmpLanguageAbility.Service, EmpLanguageAbility, LocalizationManager;

type
  TfrmEmpLanguageAbility = class(TfrmInputSimpleDB<TEmpLanguageAbility, TEmpLanguageAbilityService>)
    pnlContent: TPanel;
    lblPersonelId: TLabel;
    edtPersonelId: TEdit;
    lblLisanId: TLabel;
    edtLisanId: TEdit;
    lblOkumaId: TLabel;
    edtOkumaId: TEdit;
    lblYazmaId: TLabel;
    edtYazmaId: TEdit;
    lblKonusmaId: TLabel;
    edtKonusmaId: TEdit;
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
  EmpLanguage, EmpLanguage.Service, ufrmEmpLanguages,
  EmpLanguageLevel, EmpLanguageLevel.Service, ufrmEmpLanguageLevels;

procedure TfrmEmpLanguageAbility.BtnAcceptClick(Sender: TObject);
begin
  inherited;
end;

procedure TfrmEmpLanguageAbility.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPersonelId.OnHelperProcess := HelperProcess;
  edtLisanId.OnHelperProcess := HelperProcess;
  edtOkumaId.OnHelperProcess := HelperProcess;
  edtYazmaId.OnHelperProcess := HelperProcess;
  edtKonusmaId.OnHelperProcess := HelperProcess;
end;

procedure TfrmEmpLanguageAbility.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtPersonelId.SetFocus;
end;

procedure TfrmEmpLanguageAbility.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_language_ability.title_singular', 'Personel Dil Yetkinliği');
  lblPersonelId.Caption := TLocalizationManager.Translate('emp_language_ability.lbl_personel_id', 'Personel');
  lblLisanId.Caption := TLocalizationManager.Translate('emp_language_ability.lbl_lisan_id', 'Yabancı Dil');
  lblOkumaId.Caption := TLocalizationManager.Translate('emp_language_ability.lbl_okuma_id', 'Okuma');
  lblYazmaId.Caption := TLocalizationManager.Translate('emp_language_ability.lbl_yazma_id', 'Yazma');
  lblKonusmaId.Caption := TLocalizationManager.Translate('emp_language_ability.lbl_konusma_id', 'Konuşma');
end;

procedure TfrmEmpLanguageAbility.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPerson: TfrmEmpPersons;
  LFrmLang: TfrmEmpLanguages;
  LFrmLevel: TfrmEmpLanguageLevels;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtPersonelId.Name then
    begin
      LFrmPerson := TfrmEmpPersons.Create(LEdit, TEmpPersonService.Create, TEmpPerson.Create);
      try
        LFrmPerson.IsHelper := True;
        LFrmPerson.ShowModal;
        if LFrmPerson.DataTransfer then
        begin
          if LFrmPerson.CleanAndClose then
          begin
            Table.PersonelID := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.PersonelID := LFrmPerson.Table.Id;
            LEdit.Text := LFrmPerson.Table.FullName;
          end;
        end;
      finally
        LFrmPerson.Free;
      end;
    end
    else if LEdit.Name = edtLisanId.Name then
    begin
      LFrmLang := TfrmEmpLanguages.Create(LEdit, TEmpLanguageService.Create, TEmpLanguage.Create);
      try
        LFrmLang.IsHelper := True;
        LFrmLang.ShowModal;
        if LFrmLang.DataTransfer then
        begin
          if LFrmLang.CleanAndClose then
          begin
            Table.LisanID := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.LisanID := LFrmLang.Table.Id;
            LEdit.Text := LFrmLang.Table.LanguageName;
          end;
        end;
      finally
        LFrmLang.Free;
      end;
    end
    else if (LEdit.Name = edtOkumaId.Name) or (LEdit.Name = edtYazmaId.Name) or (LEdit.Name = edtKonusmaId.Name) then
    begin
      LFrmLevel := TfrmEmpLanguageLevels.Create(LEdit, TEmpLanguageLevelService.Create, TEmpLanguageLevel.Create);
      try
        LFrmLevel.IsHelper := True;
        LFrmLevel.ShowModal;
        if LFrmLevel.DataTransfer then
        begin
          if LFrmLevel.CleanAndClose then
          begin
            if LEdit.Name = edtOkumaId.Name then Table.OkumaID := 0
            else if LEdit.Name = edtYazmaId.Name then Table.YazmaID := 0
            else if LEdit.Name = edtKonusmaId.Name then Table.KonusmaID := 0;
            LEdit.Clear;
          end
          else
          begin
            if LEdit.Name = edtOkumaId.Name then Table.OkumaID := LFrmLevel.Table.Id
            else if LEdit.Name = edtYazmaId.Name then Table.YazmaID := LFrmLevel.Table.Id
            else if LEdit.Name = edtKonusmaId.Name then Table.KonusmaID := LFrmLevel.Table.Id;
            LEdit.Text := LFrmLevel.Table.LanguageLevel;
          end;
        end;
      finally
        LFrmLevel.Free;
      end;
    end;
  end;
end;

procedure TfrmEmpLanguageAbility.InitializeInputCase;
begin
  inherited;
  edtPersonelId.thsInputDataType := itInteger;
  edtLisanId.thsInputDataType := itInteger;
  edtOkumaId.thsInputDataType := itInteger;
  edtYazmaId.thsInputDataType := itInteger;
  edtKonusmaId.thsInputDataType := itInteger;
end;

procedure TfrmEmpLanguageAbility.RefreshData;
begin
  inherited;
  edtPersonelId.Text := Table.PersonelID.ToString;
  if Assigned(Table.Lisan) then
    edtLisanId.Text := Table.Lisan.LanguageName
  else
    edtLisanId.Text := Table.LisanID.ToString;

  if Assigned(Table.Okuma) then
    edtOkumaId.Text := Table.Okuma.LanguageLevel
  else
    edtOkumaId.Text := Table.OkumaID.ToString;

  if Assigned(Table.Yazma) then
    edtYazmaId.Text := Table.Yazma.LanguageLevel
  else
    edtYazmaId.Text := Table.YazmaID.ToString;

  if Assigned(Table.Konusma) then
    edtKonusmaId.Text := Table.Konusma.LanguageLevel
  else
    edtKonusmaId.Text := Table.KonusmaID.ToString;
end;

end.
