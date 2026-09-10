unit ufrmSysPermission;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysPermission.Service, SysPermission, SysLanguage,
  SysPermissionGroup, SysPermissionGroup.Service, ufrmSysPermissionGroups;

type
  TfrmSysPermission = class(TfrmInputSimpleDB<TSysPermission, TSysPermissionService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblKey: TLabel;
    edtKey: TEdit;
    lblGroupId: TLabel;
    edtGroupId: TEdit;
    scrlbxTranslations: TScrollBox;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    function ValidateInput(AContainerControl: TWinControl = nil): Boolean; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysPermission.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmGroup: TfrmSysPermissionGroups;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtGroupId.Name then
  begin
    LFrmGroup := TfrmSysPermissionGroups.Create(LEdit, TSysPermissionGroupService.Create, TSysPermissionGroup.Create);
    try
      LFrmGroup.IsHelper := True;
      LFrmGroup.ShowModal;
      if LFrmGroup.DataTransfer then
      begin
        if LFrmGroup.CleanAndClose then
        begin
          Table.GroupId := 0;
          LEdit.Clear;
        end
        else
        begin
          Table.GroupId := LFrmGroup.Table.Id;
          LEdit.Text := LFrmGroup.Table.PermissionGroupKey;
        end;
      end;
    finally
      LFrmGroup.Free;
    end;
  end;
end;

procedure TfrmSysPermission.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair  : TPair<string, string>;
  i      : Integer;
  LTrans : TSysPermissionTranslation;
  LFound : Boolean;
begin
  Table.Code := StrToIntDef(edtCode.Text, 0);
  Table.Key  := edtKey.Text;

  LValues := CollectTranslationValues(scrlbxTranslations, 'Name');
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
        LTrans := TSysPermissionTranslation.Create;
        LTrans.SysPermissionId := Table.Id;
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

procedure TfrmSysPermission.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtGroupId.OnHelperProcess := HelperProcess;

  BuildTranslationControls(
    scrlbxTranslations,
    'PermissionGroupName',
    TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.ColGroupName, 'Group Name'),
    lblKey);
end;

function TfrmSysPermission.ValidateInput(AContainerControl: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(AContainerControl);
  if not Result then Exit;

  if StrToIntDef(edtCode.Text, 0) <= 0 then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysPermission.CodePositive, 'The Permission Code must be a positive number.'));
    edtCode.SetFocus;
    Exit(False);
  end;

  if Table.GroupId <= 0 then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysPermission.GroupRequired, 'Please select a valid Permission Group.'));
    edtGroupId.SetFocus;
    Exit(False);
  end;
end;

procedure TfrmSysPermission.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtCode.SetFocus;
end;

procedure TfrmSysPermission.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.TitleSingular, 'SysPermission');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.ColPermissionCode, 'Permission Code');
  lblKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.ColKey, 'Permission Key');
  lblGroupId.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.ColGroupId, 'Permission Group');
end;

procedure TfrmSysPermission.RefreshData;
var
  LValues: TTranslationMap;
  i      : Integer;
  LTrans : TSysPermissionTranslation;
begin
  inherited;
  edtCode.Text := IntToStr(Table.Code);
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

  edtGroupId.Text := Table.SysPermissionGroup.PermissionGroupKey;
end;

end.
