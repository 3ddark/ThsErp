unit ufrmAccSetAccountType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccSetAccountType.Service, AccSetAccountType;

type
  TfrmAccSetAccountType = class(TfrmInputSimpleDB<TAccSetAccountType, TAccSetAccountTypeService>)
    pnlContent: TPanel;
    lblAccountTypeKey: TLabel;
    edtAccountTypeKey: TEdit;
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

procedure TfrmAccSetAccountType.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair: TPair<string, string>;
  LTrans: TAccSetAccountTypeTranslation;
  LFound: Boolean;
  i: Integer;
begin
  Table.AccountTypeKey := edtAccountTypeKey.Text;

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
        LTrans := TAccSetAccountTypeTranslation.Create;
        LTrans.AccSetAccountTypeId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        if not Assigned(Table.Translations) then
          Table.Translations := TObjectList<TAccSetAccountTypeTranslation>.Create(True);
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmAccSetAccountType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccountTypeKey.thsInputDataType := itString;
  edtAccountTypeKey.CharCase := TEditCharCase.ecUpperCase;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.ColAccountTypeName, 'Account Type'),
    lblAccountTypeKey);
end;

procedure TfrmAccSetAccountType.FormShow(Sender: TObject);
begin
  inherited;
  if edtAccountTypeKey.CanFocus then
    edtAccountTypeKey.SetFocus;
end;

procedure TfrmAccSetAccountType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.TitleSingular, 'Account Type');
  lblAccountTypeKey.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.ColAccountTypeKey, 'Key');
  UpdateTranslationLabels(scrlbxTranslations, 'Name', TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.ColAccountTypeName, 'Account Type'));
end;

procedure TfrmAccSetAccountType.RefreshData;
var
  LValues: TTranslationMap;
  LTrans: TAccSetAccountTypeTranslation;
begin
  inherited;
  edtAccountTypeKey.Text := Table.AccountTypeKey;

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
