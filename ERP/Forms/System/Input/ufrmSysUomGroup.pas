unit ufrmSysUomGroup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  AppContext, SysUomGroup.Service, SysUomGroup, SysLanguage, LocalizationManager;

type
  TfrmSysUomType = class(TfrmInputSimpleDB<TSysUomGroup, TSysUomGroupService>)
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

procedure TfrmSysUomType.BtnAcceptClick(Sender: TObject);
  procedure SetOrAddTranslation(ALangId: Int64; const ALocale, AName: string);
  var
    i: Integer;
    LTrans: TSysUomGroupTranslation;
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
          Table.Translations[i].Name := AName;
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound and (Trim(AName) <> '') then
    begin
      LTrans := TSysUomGroupTranslation.Create;
      LTrans.SysUomGroupId := Table.Id;
      LTrans.SysLanguageId := ALangId;
      LTrans.Name := AName;
      LTrans.SysLanguage := TSysLanguage.Create;
      LTrans.SysLanguage.Id := ALangId;
      LTrans.SysLanguage.Locale := ALocale;
      Table.Translations.Add(LTrans);
    end;
  end;
begin
  Table.Key := edtKey.Text;

  SetOrAddTranslation(CLangID_EN, CLangLocaleEN, edtNameEN.Text);
  SetOrAddTranslation(CLangID_TR, CLangLocaleTR, edtNameTR.Text);

  inherited;
end;

procedure TfrmSysUomType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
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
  lblNameEN.Caption := TLocalizationManager.Translate('sys_uom_type.name_en', 'Tip Adı (İngilizce)');
  lblNameTR.Caption := TLocalizationManager.Translate('sys_uom_type.name_tr', 'Tip Adı (Türkçe)');
end;

procedure TfrmSysUomType.RefreshData;
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
      if Assigned(Table.Translations[i].SysLanguage) then
      begin
        if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleEN) then
          edtNameEN.Text := Table.Translations[i].Name
        else if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleTR) then
          edtNameTR.Text := Table.Translations[i].Name;
      end
      else
      begin
        if Table.Translations[i].SysLanguageId = CLangID_EN then
          edtNameEN.Text := Table.Translations[i].Name
        else if Table.Translations[i].SysLanguageId = CLangID_TR then
          edtNameTR.Text := Table.Translations[i].Name;
      end;
    end;
  end;
end;

end.
