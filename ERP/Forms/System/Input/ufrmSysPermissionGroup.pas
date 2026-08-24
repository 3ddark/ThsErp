unit ufrmSysPermissionGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  AppContext, SysPermissionGroup.Service, SysPermissionGroup, SysLanguage, LocalizationManager;

type
  TfrmSysPermissionGroup = class(TfrmInputSimpleDB<TSysPermissionGroup, TSysPermissionGroupService>)
    pnlContent: TPanel;
    lblKey: TLabel;
    edtKey: TEdit;
    lblNameEN: TLabel;
    edtNameEN: TEdit;
    lblNameTR: TLabel;
    edtNameTR: TEdit;
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
  procedure SetOrAddTranslation(ALangId: Int64; const ALocale, AName: string);
  var
    i: Integer;
    LTrans: TSysPermissionGroupTranslation;
    LFound: Boolean;
  begin
    LFound := False;
    if Assigned(Table.Translations) then
    begin
      for i := 0 to Table.Translations.Count - 1 do
      begin
        if (Assigned(Table.Translations[i].Language) and SameText(Table.Translations[i].Language.Locale, ALocale))
        or (Table.Translations[i].LanguageId = ALangId) then
        begin
          Table.Translations[i].Name := AName;
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound and (Trim(AName) <> '') then
    begin
      LTrans := TSysPermissionGroupTranslation.Create;
      LTrans.PermissionGroupId := Table.Id;
      LTrans.LanguageId := ALangId;
      LTrans.Name := AName;
      LTrans.Language := TSysLanguage.Create;
      LTrans.Language.Id := ALangId;
      LTrans.Language.Locale := ALocale;
      Table.Translations.Add(LTrans);
    end;
  end;
begin
  Table.Key := edtKey.Text;

  SetOrAddTranslation(CLangID_EN, CLangLocaleEN, edtNameEN.Text);
  SetOrAddTranslation(CLangID_TR, CLangLocaleTR, edtNameTR.Text);

  inherited;
end;

procedure TfrmSysPermissionGroup.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysPermissionGroup.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtKey.SetFocus;
end;

procedure TfrmSysPermissionGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPermissionGroup.TitleSingular, 'Yetki Grubu');
  lblKey.Caption := TLocalizationManager.Translate(TLangKeys.TPermissionGroup.LblKey, 'Grup Anahtarı');
  lblNameEN.Caption := TLocalizationManager.Translate(TLangKeys.TPermissionGroup.LblNameEN, 'Grup Adı (İngilizce)');
  lblNameTR.Caption := TLocalizationManager.Translate(TLangKeys.TPermissionGroup.LblNameTR, 'Grup Adı (Türkçe)');
end;

procedure TfrmSysPermissionGroup.RefreshData;
var
  i: Integer;
begin
  inherited;
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
end;

end.
