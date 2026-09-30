unit ufrmEmpUnit;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpUnit.Service, EmpUnit;

type
  TfrmEmpUnit = class(TfrmInputSimpleDB<TEmpUnit, TEmpUnitService>)
    pnlContent: TPanel;
    lblUnitKey: TLabel;
    edtUnitKey: TEdit;
    scrlbxTranslations: TScrollBox;
    lblEmpSectionId: TLabel;
    edtEmpSectionId: TEdit;
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
  SysLanguage,
  EmpSection, EmpSection.Service, ufrmEmpSections;                              // TfrmEmpSections helper output form

procedure TfrmEmpUnit.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair: TPair<string, string>;
  LTrans: TEmpUnitTranslation;
  LFound: Boolean;
  i: Integer;
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.UnitKey := edtUnitKey.Text;

  LValues := CollectTranslationValues(scrlbxTranslations, 'Name');
  try
    for LPair in LValues do
    begin
      LFound := False;
      if Assigned(Table.Translations) then
        for i := 0 to Table.Translations.Count - 1 do
          if Assigned(Table.Translations[i].SysLanguage)
          and SameText(Table.Translations[i].SysLanguage.Locale, LPair.Key) then
          begin
            Table.Translations[i].Name := LPair.Value;
            LFound := True;
            Break;
          end;

      if not LFound and (Trim(LPair.Value) <> '') then
      begin
        LTrans := TEmpUnitTranslation.Create;
        LTrans.EmpUnitId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        if not Assigned(Table.Translations) then
          Table.Translations := TObjectList<TEmpUnitTranslation>.Create(True);
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmEmpUnit.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtEmpSectionId.OnHelperProcess := HelperProcess;
  edtUnitKey.thsInputDataType := itString;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColUnitName, 'Unit Name'),
    lblUnitKey);
end;

procedure TfrmEmpUnit.FormShow(Sender: TObject);
begin
  inherited;
  if edtUnitKey.CanFocus then
    edtUnitKey.SetFocus;
end;

procedure TfrmEmpUnit.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpUnit.TitleSingular, 'Unit');
  lblUnitKey.Caption := TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColUnitKey, 'Key');
  lblEmpSectionId.Caption := TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColSection, 'Section');
  UpdateTranslationLabels(scrlbxTranslations, 'Name', TLocalizationManager.Translate(TLangKeys.TEmpUnit.ColUnitName, 'Unit Name'));
end;

procedure TfrmEmpUnit.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEmpSectionId: TfrmEmpSections;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtEmpSectionId.Name then
  begin
    LFrmEmpSectionId := TfrmEmpSections.Create(LEdit, TEmpSectionService.Create, TEmpSection.Create);
    try
      LFrmEmpSectionId.IsHelper := True;
      LFrmEmpSectionId.ShowModal;
      if LFrmEmpSectionId.DataTransfer then
        if LFrmEmpSectionId.CleanAndClose then
        begin
          Table.EmpSectionId := 0;
          Table.SectionName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpSectionId := LFrmEmpSectionId.Table.Id;
          Table.SectionName := LFrmEmpSectionId.Table.SectionName;
          LEdit.Text := Table.SectionName;
        end;
    finally
      LFrmEmpSectionId.Free;
    end;
  end;
end;

procedure TfrmEmpUnit.RefreshData;
var
  LValues: TTranslationMap;
  LTrans: TEmpUnitTranslation;
begin
  inherited;
  edtUnitKey.Text := Table.UnitKey;
  edtEmpSectionId.Text := Table.SectionName;

  LValues := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for LTrans in Table.Translations do
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
          LValues.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.Name);

    FillTranslationControls(scrlbxTranslations, LValues);
  finally
    LValues.Free;
  end;
end;

end.
