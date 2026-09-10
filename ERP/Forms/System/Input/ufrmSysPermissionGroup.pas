unit ufrmSysPermissionGroup;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysPermissionGroup.Service, SysPermissionGroup, SysLanguage;

type
  TfrmSysPermissionGroup = class(TfrmInputSimpleDB<TSysPermissionGroup, TSysPermissionGroupService>)
    pnlContent: TPanel;
    lblPermissionGroupKey: TLabel;
    edtPermissionGroupKey: TEdit;
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

procedure TfrmSysPermissionGroup.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair  : TPair<string, string>;
  i      : Integer;
  LTrans : TSysPermissionGroupTranslation;
  LFound : Boolean;
begin
  Table.PermissionGroupKey := edtPermissionGroupKey.Text;

  LValues := CollectTranslationValues(scrlbxTranslations, 'PermissionGroupName');
  try
    for LPair in LValues do
    begin
      LFound := False;
      if Assigned(Table.Translations) then
        for i := 0 to Table.Translations.Count - 1 do
          if SameText(Table.Translations[i].SysLanguage.Locale, LPair.Key) then
          begin
            Table.Translations[i].PermissionGroupName := LPair.Value;
            LFound := True;
            Break;
          end;

      if not LFound and (Trim(LPair.Value) <> '') then
      begin
        LTrans := TSysPermissionGroupTranslation.Create;
        LTrans.SysPermissionGroupId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.PermissionGroupName := LPair.Value;
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

procedure TfrmSysPermissionGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;

  BuildTranslationControls(
    scrlbxTranslations,
    'PermissionGroupName',
    TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.ColGroupName, 'Group Name'),
    lblPermissionGroupKey);
end;

procedure TfrmSysPermissionGroup.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtPermissionGroupKey.SetFocus;
end;

procedure TfrmSysPermissionGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.TitleSingular, 'Permission Group');
  lblPermissionGroupKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.LblKey, 'Permission Group Key');
end;

procedure TfrmSysPermissionGroup.RefreshData;
var
  LValues: TTranslationMap;
  i      : Integer;
  LTrans : TSysPermissionGroupTranslation;
begin
  inherited;
  edtPermissionGroupKey.Text := Table.PermissionGroupKey;

  LValues := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for i := 0 to Table.Translations.Count - 1 do
      begin
        LTrans := Table.Translations[i];
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
          LValues.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.PermissionGroupName);
      end;

    FillTranslationControls(scrlbxTranslations, LValues);
  finally
    LValues.Free;
  end;
end;

end.
