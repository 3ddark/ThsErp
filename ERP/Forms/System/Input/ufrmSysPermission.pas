unit ufrmSysPermission;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysPermission.Service, SysPermission, AppContext,
  SysPermissionGroup, SysPermissionGroup.Service, ufrmSysPermissionGroups,
  SysLanguage, LocalizationManager;

type
  TfrmSysPermission = class(TfrmInputSimpleDB<TSysPermission, TSysPermissionService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblKey: TLabel;
    edtKey: TEdit;
    lblNameEN: TLabel;
    edtNameEN: TEdit;
    lblNameTR: TLabel;
    edtNameTR: TEdit;
    lblGroupId: TLabel;
    edtGroupId: TEdit;
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
          LEdit.Text := LFrmGroup.Table.Key;
        end;
      end;
    finally
      LFrmGroup.Free;
    end;
  end;
end;

procedure TfrmSysPermission.BtnAcceptClick(Sender: TObject);
  procedure SetOrAddTranslation(ALangId: Int64; const ALocale, AName: string);
  var
    i: Integer;
    LTrans: TSysPermissionTranslation;
    LFound: Boolean;
  begin
    LFound := False;
    if Assigned(Table.Translations) then
    begin
      for i := 0 to Table.Translations.Count - 1 do
      begin
        if (Assigned(Table.Translations[i].Language) and SameText(Table.Translations[i].Language.Locale, ALocale))
        or (Table.Translations[i].LanguageId = ALangId)
        then
        begin
          Table.Translations[i].Name := AName;
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound and (Trim(AName) <> '') then
    begin
      LTrans := TSysPermissionTranslation.Create;
      LTrans.PermissionId := Table.Id;
      LTrans.LanguageId := ALangId;
      LTrans.Name := AName;
      LTrans.Language := TSysLanguage.Create;
      LTrans.Language.Id := ALangId;
      LTrans.Language.Locale := ALocale;
      Table.Translations.Add(LTrans);
    end;
  end;
begin
  Table.Code := StrToIntDef(edtCode.Text, 0);
  Table.Key  := edtKey.Text;

  SetOrAddTranslation(CLangID_EN, CLangLocaleEN, edtNameEN.Text);
  SetOrAddTranslation(CLangID_TR, CLangLocaleTR, edtNameTR.Text);

  inherited;
end;

procedure TfrmSysPermission.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtGroupId.OnHelperProcess := HelperProcess;
end;

function TfrmSysPermission.ValidateInput(AContainerControl: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(AContainerControl);
  if not Result then Exit;

  if StrToIntDef(edtCode.Text, 0) <= 0 then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysPermission.CodePositive, 'Yetki Kodu pozitif bir sayı olmalıdır.'));
    edtCode.SetFocus;
    Exit(False);
  end;

  if Table.GroupId <= 0 then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysPermission.GroupRequired, 'Lütfen geçerli bir Yetki Grubu seçiniz.'));
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.TitleSingular, 'Yetki');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.LblCode, 'Yetki Kodu');
  lblKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.LblKey, 'Yetki Anahtarı');
  lblNameEN.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.LblNameEN, 'Yetki Adı (İngilizce)');
  lblNameTR.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.LblNameTR, 'Yetki Adı (Türkçe)');
  lblGroupId.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.LblGroupId, 'Yetki Grubu');
end;

procedure TfrmSysPermission.RefreshData;
var
  i: Integer;
begin
  inherited;
  edtCode.Text := IntToStr(Table.Code);
  edtKey.Text := Table.Key;
  edtNameEN.Text := '';
  edtNameTR.Text := '';

  if Assigned(Table.Translations) then
  begin
    for i := 0 to Table.Translations.Count - 1 do
    begin
      if Assigned(Table.Translations[i].Language) then
      begin
        if SameText(Table.Translations[i].Language.Locale, CLangLocaleEN) then
          edtNameEN.Text := Table.Translations[i].Name
        else if SameText(Table.Translations[i].Language.Locale, CLangLocaleTR) then
          edtNameTR.Text := Table.Translations[i].Name;
      end
      else
      begin
        if Table.Translations[i].LanguageId = CLangID_EN then
          edtNameEN.Text := Table.Translations[i].Name
        else if Table.Translations[i].LanguageId = CLangID_TR then
          edtNameTR.Text := Table.Translations[i].Name;
      end;
    end;
  end;

  if Assigned(Table.Group) then
    edtGroupId.Text := Table.Group.Key
  else
    edtGroupId.Text := '';
end;

end.
