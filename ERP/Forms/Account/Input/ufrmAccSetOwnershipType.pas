unit ufrmAccSetOwnershipType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccSetOwnershipType.Service, AccSetOwnershipType;

type
  TfrmAccSetOwnershipType = class(TfrmInputSimpleDB<TAccSetOwnershipType, TAccSetOwnershipTypeService>)
    pnlContent: TPanel;
    lblOwnershipTypeKey: TLabel;
    edtOwnershipTypeKey: TEdit;
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

procedure TfrmAccSetOwnershipType.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair: TPair<string, string>;
  LTrans: TAccSetOwnershipTypeTranslation;
  LFound: Boolean;
  i: Integer;
begin
  Table.OwnershipTypeKey := edtOwnershipTypeKey.Text;

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
        LTrans := TAccSetOwnershipTypeTranslation.Create;
        LTrans.AccSetOwnershipTypeId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        if not Assigned(Table.Translations) then
          Table.Translations := TObjectList<TAccSetOwnershipTypeTranslation>.Create(True);
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmAccSetOwnershipType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtOwnershipTypeKey.thsInputDataType := itString;
  edtOwnershipTypeKey.CharCase := TEditCharCase.ecUpperCase;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.ColOwnershipTypeName, 'Ownership Type'),
    lblOwnershipTypeKey);
end;

procedure TfrmAccSetOwnershipType.FormShow(Sender: TObject);
begin
  inherited;
  if edtOwnershipTypeKey.CanFocus then
    edtOwnershipTypeKey.SetFocus;
end;

procedure TfrmAccSetOwnershipType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.TitleSingular, 'Ownership Type');
  lblOwnershipTypeKey.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.ColOwnershipTypeKey, 'Key');
  UpdateTranslationLabels(scrlbxTranslations, 'Name', TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.ColOwnershipTypeName, 'Ownership Type'));
end;

procedure TfrmAccSetOwnershipType.RefreshData;
var
  LValues: TTranslationMap;
  LTrans: TAccSetOwnershipTypeTranslation;
begin
  inherited;
  edtOwnershipTypeKey.Text := Table.OwnershipTypeKey;

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
