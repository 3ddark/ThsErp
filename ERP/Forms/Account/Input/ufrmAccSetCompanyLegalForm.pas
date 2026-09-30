unit ufrmAccSetCompanyLegalForm;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  AccSetCompanyLegalForm.Service, AccSetCompanyLegalForm;

type
  TfrmAccSetCompanyLegalForm = class(TfrmInputSimpleDB<TAccSetCompanyLegalForm, TAccSetCompanyLegalFormService>)
    pnlContent: TPanel;
    lblLegalFormKey: TLabel;
    edtLegalFormKey: TEdit;
    scrlbxTranslations: TScrollBox;
    lblAccSetOwnershipTypeId: TLabel;
    edtAccSetOwnershipTypeId: TEdit;
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
  AccSetOwnershipType, AccSetOwnershipType.Service, ufrmAccSetOwnershipTypes;   // TfrmAccSetOwnershipTypes helper output form

procedure TfrmAccSetCompanyLegalForm.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair: TPair<string, string>;
  LTrans: TAccSetCompanyLegalFormTranslation;
  LFound: Boolean;
  i: Integer;
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.LegalFormKey := edtLegalFormKey.Text;

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
        LTrans := TAccSetCompanyLegalFormTranslation.Create;
        LTrans.AccSetCompanyLegalFormId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        if not Assigned(Table.Translations) then
          Table.Translations := TObjectList<TAccSetCompanyLegalFormTranslation>.Create(True);
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmAccSetCompanyLegalForm.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtAccSetOwnershipTypeId.OnHelperProcess := HelperProcess;
  edtLegalFormKey.thsInputDataType := itString;
  edtLegalFormKey.CharCase := TEditCharCase.ecUpperCase;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColLegalFormName, 'Legal Form'),
    lblLegalFormKey);
end;

procedure TfrmAccSetCompanyLegalForm.FormShow(Sender: TObject);
begin
  inherited;
  if edtLegalFormKey.CanFocus then
    edtLegalFormKey.SetFocus;
end;

procedure TfrmAccSetCompanyLegalForm.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.TitleSingular, 'Company Legal Form');
  lblLegalFormKey.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColLegalFormKey, 'Key');
  lblAccSetOwnershipTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColOwnershipType, 'Ownership Type');
  UpdateTranslationLabels(scrlbxTranslations, 'Name', TLocalizationManager.Translate(TLangKeys.TAccSetCompanyLegalForm.ColLegalFormName, 'Legal Form'));
end;

procedure TfrmAccSetCompanyLegalForm.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccSetOwnershipTypeId: TfrmAccSetOwnershipTypes;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccSetOwnershipTypeId.Name then
  begin
    LFrmAccSetOwnershipTypeId := TfrmAccSetOwnershipTypes.Create(LEdit, TAccSetOwnershipTypeService.Create, TAccSetOwnershipType.Create);
    try
      LFrmAccSetOwnershipTypeId.IsHelper := True;
      LFrmAccSetOwnershipTypeId.ShowModal;
      if LFrmAccSetOwnershipTypeId.DataTransfer then
        if LFrmAccSetOwnershipTypeId.CleanAndClose then
        begin
          Table.AccSetOwnershipTypeId := 0;
          Table.OwnershipTypeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccSetOwnershipTypeId := LFrmAccSetOwnershipTypeId.Table.Id;
          Table.OwnershipTypeName := LFrmAccSetOwnershipTypeId.Table.OwnershipTypeName;
          LEdit.Text := Table.OwnershipTypeName;
        end;
    finally
      LFrmAccSetOwnershipTypeId.Free;
    end;
  end;
end;

procedure TfrmAccSetCompanyLegalForm.RefreshData;
var
  LValues: TTranslationMap;
  LTrans: TAccSetCompanyLegalFormTranslation;
begin
  inherited;
  edtLegalFormKey.Text := Table.LegalFormKey;
  edtAccSetOwnershipTypeId.Text := Table.OwnershipTypeName;

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
