unit ufrmSysUomGroup;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  AppContext, SysUomGroup.Service, SysUomGroup, SysLanguage;

type
  TfrmSysUomGroup = class(TfrmInputSimpleDB<TSysUomGroup, TSysUomGroupService>)
    pnlContent: TPanel;
    lblKey: TLabel;
    edtKey: TEdit;
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

procedure TfrmSysUomGroup.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair  : TPair<string, string>;
  i      : Integer;
  LTrans : TSysUomGroupTranslation;
  LFound : Boolean;
begin
  Table.UomGroupKey := edtKey.Text;

  LValues := CollectTranslationValues(scrlbxTranslations, 'PermissionGroupName');
  try
    for LPair in LValues do
    begin
      LFound := False;
      if Assigned(Table.Translations) then
        for i := 0 to Table.Translations.Count - 1 do
          if SameText(Table.Translations[i].SysLanguage.Locale, LPair.Key) then
          begin
            Table.Translations[i].UomGroupName := LPair.Value;
            LFound := True;
            Break;
          end;

      if not LFound and (Trim(LPair.Value) <> '') then
      begin
        LTrans := TSysUomGroupTranslation.Create;
        LTrans.SysUomGroupId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.UomGroupName := LPair.Value;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;
  inherited;
end;

procedure TfrmSysUomGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;

  BuildTranslationControls(
    scrlbxTranslations,
    'UomGroupName',
    TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColName, 'UomGroupName'),
    lblKey);
end;

procedure TfrmSysUomGroup.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtKey.SetFocus;
end;

procedure TfrmSysUomGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUomGroup.TitleSingular, 'Unit of Measurement Type');
  lblKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColKey, 'Type Key');
  UpdateTranslationLabels(scrlbxTranslations, 'UomGroupName', TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColName, 'Name'));
end;

procedure TfrmSysUomGroup.RefreshData;
var
  LValues: TTranslationMap;
  i      : Integer;
  LTrans : TSysUomGroupTranslation;
begin
  inherited;
  edtKey.Text := Table.UomGroupKey;

  LValues := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for i := 0 to Table.Translations.Count - 1 do
      begin
        LTrans := Table.Translations[i];
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
          LValues.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.UomGroupName);
      end;

    FillTranslationControls(scrlbxTranslations, LValues);
  finally
    LValues.Free;
  end;
end;

end.
