unit ufrmSysMenu;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysMenu, SysMenu.Service, SysLanguage, SysPermission, SysPermission.Service;

type
  // Menü satırı: ad + arama kelimeleri (dil bazında), aktiflik, okuma yetkisi.
  // Kod / anahtar / action yalnız yeni kayıtta girilir (sonra değişmez; servis de reddeder).
  TfrmSysMenu = class(TfrmInputSimpleDB<TSysMenu, TSysMenuService>)
    pnlContent: TPanel;
    lblMenuCode: TLabel;
    edtMenuCode: TEdit;
    lblMenuKey: TLabel;
    edtMenuKey: TEdit;
    lblActionName: TLabel;
    edtActionName: TEdit;
    lblSysPermissionId: TLabel;
    edtSysPermissionId: TEdit;
    chkIsActive: TCheckBox;
    scrlbxMenuName: TScrollBox;
    scrlbxKeywords: TScrollBox;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    procedure LayoutTranslations;
  public
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmSysPermissions;   // TfrmSysPermissions helper output form

const
  FIELD_NAME = 'MenuName';
  FIELD_KEYWORDS = 'Keywords';

procedure TfrmSysMenu.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSysPermissionId.OnHelperProcess := HelperProcess;
  edtMenuCode.thsInputDataType := itInteger;
  edtMenuKey.thsInputDataType := itString;
  edtActionName.thsInputDataType := itString;

  BuildTranslationControls(scrlbxMenuName, FIELD_NAME,
    TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuName, 'Screen / Folder Name'), lblMenuCode);
  BuildTranslationControls(scrlbxKeywords, FIELD_KEYWORDS,
    TLocalizationManager.Translate(TLangKeys.TSysMenu.ColKeywords, 'Search Keywords'), lblMenuCode);
  LayoutTranslations;
end;

// çeviri kutularının yüksekliği dil sayısına göre: altlarındaki kutu ve form yüksekliği buna göre
procedure TfrmSysMenu.LayoutTranslations;
var
  LBottom: Integer;
begin
  scrlbxKeywords.Top := scrlbxMenuName.Top + scrlbxMenuName.Height + 6;
  LBottom := scrlbxKeywords.Top + scrlbxKeywords.Height;
  Self.ClientHeight := LBottom + 12 + 36 + 20;
end;

procedure TfrmSysMenu.FormShow(Sender: TObject);
var
  LNew: Boolean;
begin
  inherited;
  // kalıcı alanlar yalnız yeni kayıtta (salt okunur kilidi ReadOnly ile; bunlar Enabled ile kapatılır)
  LNew := FormMode in [ifmNewRecord, ifmCopyNewRecord];
  edtMenuCode.Enabled := LNew;
  edtMenuKey.Enabled := LNew;
  edtActionName.Enabled := LNew;
  if LNew and edtMenuCode.CanFocus then
    edtMenuCode.SetFocus
  else if chkIsActive.CanFocus then
    chkIsActive.SetFocus;
end;

procedure TfrmSysMenu.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrm: TfrmSysPermissions;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := TEdit(Sender);
  if LEdit.Name <> edtSysPermissionId.Name then
    Exit;

  LFrm := TfrmSysPermissions.Create(LEdit, TSysPermissionService.Create, TSysPermission.Create);
  try
    LFrm.IsHelper := True;
    LFrm.ShowModal;
    if LFrm.DataTransfer then
    begin
      if LFrm.CleanAndClose then
      begin
        Table.SysPermissionId := 0;
        Table.PermissionCode := 0;
        Table.PermissionName := '';
        LEdit.Clear;
      end
      else
      begin
        Table.SysPermissionId := LFrm.Table.Id;
        Table.PermissionCode := LFrm.Table.PermissionCode;
        Table.PermissionName := Format('%d - %s', [LFrm.Table.PermissionCode, LFrm.Table.PermissionKey]);
        LEdit.Text := Table.PermissionName;
      end;
    end;
  finally
    LFrm.Free;
  end;
end;

procedure TfrmSysMenu.BtnAcceptClick(Sender: TObject);
var
  LNames, LKeywords: TTranslationMap;
  LLocales: TList<string>;
  LLocale: string;
  LTrans: TSysMenuTranslation;
  I: Integer;
begin
  Table.MenuCode := StrToIntDef(edtMenuCode.Text, 0);
  Table.MenuKey := Trim(edtMenuKey.Text);
  Table.ActionName := Trim(edtActionName.Text);
  Table.IsActive := chkIsActive.Checked;

  LNames := CollectTranslationValues(scrlbxMenuName, FIELD_NAME);
  LKeywords := CollectTranslationValues(scrlbxKeywords, FIELD_KEYWORDS);
  LLocales := TList<string>.Create;
  try
    for LLocale in LNames.Keys do
      LLocales.Add(LLocale);
    for LLocale in LKeywords.Keys do
      if not LLocales.Contains(LLocale) then
        LLocales.Add(LLocale);

    if not Assigned(Table.Translations) then
      Table.Translations := TObjectList<TSysMenuTranslation>.Create(True);
    for LLocale in LLocales do
    begin
      LTrans := nil;
      for I := 0 to Table.Translations.Count - 1 do
        if Assigned(Table.Translations[I].SysLanguage) and SameText(Table.Translations[I].SysLanguage.Locale, LLocale) then
        begin
          LTrans := Table.Translations[I];
          Break;
        end;
      if LTrans = nil then
      begin
        LTrans := TSysMenuTranslation.Create;
        LTrans.SysMenuId := Table.Id;
        LTrans.SysLanguage := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LLocale;
        Table.Translations.Add(LTrans);
      end;
      if LNames.ContainsKey(LLocale) then
        LTrans.MenuName := LNames[LLocale];
      if LKeywords.ContainsKey(LLocale) then
        LTrans.Keywords := LKeywords[LLocale];
    end;
  finally
    LLocales.Free;
    LKeywords.Free;
    LNames.Free;
  end;

  inherited;
end;

procedure TfrmSysMenu.RefreshData;
var
  LNames, LKeywords: TTranslationMap;
  LTrans: TSysMenuTranslation;
begin
  inherited;
  if Table.MenuCode > 0 then
    edtMenuCode.Text := IntToStr(Table.MenuCode)
  else
    edtMenuCode.Text := '';
  edtMenuKey.Text := Table.MenuKey;
  edtActionName.Text := Table.ActionName;
  chkIsActive.Checked := Table.IsActive;
  if Table.SysPermissionId > 0 then
    edtSysPermissionId.Text := Format('%d - %s', [Table.PermissionCode, Table.PermissionName])
  else
    edtSysPermissionId.Text := '';

  LNames := TTranslationMap.Create;
  LKeywords := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for LTrans in Table.Translations do
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
        begin
          LNames.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.MenuName);
          LKeywords.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.Keywords);
        end;
    FillTranslationControls(scrlbxMenuName, LNames);
    FillTranslationControls(scrlbxKeywords, LKeywords);
  finally
    LKeywords.Free;
    LNames.Free;
  end;
end;

procedure TfrmSysMenu.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.TitleSingular, 'Menu Screen');
  lblMenuCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuCode, 'Code');
  lblMenuKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuKey, 'Key');
  lblActionName.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.ColActionName, 'Action');
  lblSysPermissionId.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.ColPermission, 'Read Permission');
  chkIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.ColIsActive, 'Active');
  UpdateTranslationLabels(scrlbxMenuName, FIELD_NAME, TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuName, 'Screen / Folder Name'));
  UpdateTranslationLabels(scrlbxKeywords, FIELD_KEYWORDS, TLocalizationManager.Translate(TLangKeys.TSysMenu.ColKeywords, 'Search Keywords'));
end;

end.
