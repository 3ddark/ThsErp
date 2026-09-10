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
  TfrmSysUomType = class(TfrmInputSimpleDB<TSysUomGroup, TSysUomGroupService>)
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

procedure TfrmSysUomType.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair  : TPair<string, string>;
  i      : Integer;
  LTrans : TSysUomGroupTranslation;
  LFound : Boolean;
begin
  Table.Key := edtKey.Text;

  LValues := CollectTranslationValues(scrlbxTranslations, 'PermissionGroupName');
  try
    for LPair in LValues do
    begin
      LFound := False;
      if Assigned(Table.Translations) then
        for i := 0 to Table.Translations.Count - 1 do
          if SameText(Table.Translations[i].SysLanguage.Locale, LPair.Key) then
          begin
            Table.Translations[i].Name := LPair.Value;
            LFound := True;
            Break;
          end;

      if not LFound and (Trim(LPair.Value) <> '') then
      begin
        LTrans := TSysUomGroupTranslation.Create;
        LTrans.SysUomGroupId := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.Name := LPair.Value;
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

procedure TfrmSysUomType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;

  BuildTranslationControls(
    scrlbxTranslations,
    'Name',
    TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColName, 'Name'),
    lblKey);
end;

procedure TfrmSysUomType.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtKey.SetFocus;
end;

procedure TfrmSysUomType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_uom_type.title.singular', 'Ölçü Birimi Tipi');
  lblKey.Caption := TLocalizationManager.Translate('sys_uom_type.key', 'Tip Anahtarı');
end;

procedure TfrmSysUomType.RefreshData;
var
  LValues: TTranslationMap;
  i      : Integer;
  LTrans : TSysUomGroupTranslation;
begin
  inherited;
  edtKey.Text := Table.Key;

  LValues := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for i := 0 to Table.Translations.Count - 1 do
      begin
        LTrans := Table.Translations[i];
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
          LValues.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.Name);
      end;

    FillTranslationControls(scrlbxTranslations, LValues);
  finally
    LValues.Free;
  end;
end;

end.
