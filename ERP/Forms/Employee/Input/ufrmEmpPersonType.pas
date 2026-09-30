unit ufrmEmpPersonType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpPersonType.Service, EmpPersonType;

type
  TfrmEmpPersonType = class(TfrmInputSimpleDB<TEmpPersonType, TEmpPersonTypeService>)
    pnlContent: TPanel;
    lblPersonTypeKey: TLabel;
    edtPersonTypeKey: TEdit;
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

procedure TfrmEmpPersonType.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair: TPair<string, string>;
  LTrans: TEmpPersonTypeTranslation;
  LFound: Boolean;
  i: Integer;
begin
  Table.PersonTypeKey := edtPersonTypeKey.Text;

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
        LTrans := TEmpPersonTypeTranslation.Create;
        LTrans.EmpPersonTypeId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        if not Assigned(Table.Translations) then
          Table.Translations := TObjectList<TEmpPersonTypeTranslation>.Create(True);
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmEmpPersonType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPersonTypeKey.thsInputDataType := itString;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TEmpPersonType.ColPersonType, 'Employee Type'),
    lblPersonTypeKey);
end;

procedure TfrmEmpPersonType.FormShow(Sender: TObject);
begin
  inherited;
  if edtPersonTypeKey.CanFocus then
    edtPersonTypeKey.SetFocus;
end;

procedure TfrmEmpPersonType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonType.TitleSingular, 'Employee Type');
  lblPersonTypeKey.Caption := TLocalizationManager.Translate(TLangKeys.TEmpPersonType.ColPersonTypeKey, 'Key');
  UpdateTranslationLabels(scrlbxTranslations, 'Name', TLocalizationManager.Translate(TLangKeys.TEmpPersonType.ColPersonType, 'Employee Type'));
end;

procedure TfrmEmpPersonType.RefreshData;
var
  LValues: TTranslationMap;
  LTrans: TEmpPersonTypeTranslation;
begin
  inherited;
  edtPersonTypeKey.Text := Table.PersonTypeKey;

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
