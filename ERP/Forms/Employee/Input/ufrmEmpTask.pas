unit ufrmEmpTask;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpTask.Service, EmpTask;

type
  TfrmEmpTask = class(TfrmInputSimpleDB<TEmpTask, TEmpTaskService>)
    pnlContent: TPanel;
    lblTaskKey: TLabel;
    edtTaskKey: TEdit;
    scrlbxTranslations: TScrollBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysLanguage;

procedure TfrmEmpTask.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair: TPair<string, string>;
  LTrans: TEmpTaskTranslation;
  LFound: Boolean;
  i: Integer;
begin
  Table.TaskKey := edtTaskKey.Text;

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
        LTrans := TEmpTaskTranslation.Create;
        LTrans.EmpTaskId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        if not Assigned(Table.Translations) then
          Table.Translations := TObjectList<TEmpTaskTranslation>.Create(True);
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmEmpTask.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtTaskKey.thsInputDataType := itString;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TEmpTask.ColTaskName, 'Task Name'),
    lblTaskKey);
end;

procedure TfrmEmpTask.FormShow(Sender: TObject);
begin
  inherited;
  if edtTaskKey.CanFocus then
    edtTaskKey.SetFocus;
end;

procedure TfrmEmpTask.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTask.TitleSingular, 'Task');
  lblTaskKey.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTask.ColTaskKey, 'Key');
  UpdateTranslationLabels(scrlbxTranslations, 'Name', TLocalizationManager.Translate(TLangKeys.TEmpTask.ColTaskName, 'Task Name'));
end;

procedure TfrmEmpTask.RefreshData;
var
  LValues: TTranslationMap;
  LTrans: TEmpTaskTranslation;
begin
  inherited;
  edtTaskKey.Text := Table.TaskKey;

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
