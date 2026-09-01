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
    lblPermissionGroupKey: TLabel;
    edtPermissionGroupKey: TEdit;
    lblPermissionGroupName_en_US: TLabel;
    edtPermissionGroupName_en_US: TEdit;
    lblPermissionGroupName_tr_TR: TLabel;
    edtPermissionGroupName_tr_TR: TEdit;
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
        if (Assigned(Table.Translations[i].SysLanguage) and SameText(Table.Translations[i].SysLanguage.Locale, ALocale))
        or (Table.Translations[i].SysLanguageId = ALangId) then
        begin
          Table.Translations[i].PermissionGroupName := AName;
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound and (Trim(AName) <> '') then
    begin
      LTrans := TSysPermissionGroupTranslation.Create;
      LTrans.SysPermissionGroupId := Table.Id;
      LTrans.SysLanguageId := ALangId;
      LTrans.PermissionGroupName := AName;
      LTrans.SysLanguage := TSysLanguage.Create;
      LTrans.SysLanguage.Id := ALangId;
      LTrans.SysLanguage.Locale := ALocale;
      Table.Translations.Add(LTrans);
    end;
  end;
begin
  Table.PermissionGroupKey := edtPermissionGroupKey.Text;

  SetOrAddTranslation(CLangID_EN, CLangLocaleEN, edtPermissionGroupName_en_US.Text);
  SetOrAddTranslation(CLangID_TR, CLangLocaleTR, edtPermissionGroupName_tr_TR.Text);

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
  edtPermissionGroupKey.SetFocus;
end;

procedure TfrmSysPermissionGroup.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.TitleSingular, 'Permission Group');
  lblPermissionGroupKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.LblKey, 'Permission Group Key');
  lblPermissionGroupName_en_US.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.LblNameEN, 'Group Name (en-US)');
  lblPermissionGroupName_tr_TR.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionGroup.LblNameTR, 'Group Name (tr-TR)');
end;

procedure TfrmSysPermissionGroup.RefreshData;
var
  i: Integer;
begin
  inherited;
  edtPermissionGroupKey.Text := Table.PermissionGroupKey;
  edtPermissionGroupName_en_US.Text := '';
  edtPermissionGroupName_tr_TR.Text := '';

  if Assigned(Table.Translations) then
  begin
    for i := 0 to Table.Translations.Count - 1 do
    begin
      if Assigned(Table.Translations[i].SysLanguage) then
      begin
        if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleEN) then
          edtPermissionGroupName_en_US.Text := Table.Translations[i].PermissionGroupName
        else if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleTR) then
          edtPermissionGroupName_tr_TR.Text := Table.Translations[i].PermissionGroupName;
      end
      else
      begin
        if Table.Translations[i].SysLanguageId = CLangID_EN then
          edtPermissionGroupName_en_US.Text := Table.Translations[i].PermissionGroupName
        else if Table.Translations[i].SysLanguageId = CLangID_TR then
          edtPermissionGroupName_tr_TR.Text := Table.Translations[i].PermissionGroupName;
      end;
    end;
  end;
end;

end.
