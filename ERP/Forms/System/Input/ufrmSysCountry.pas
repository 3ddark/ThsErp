unit ufrmSysCountry;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCountry.Service, SysCountry, SysLanguage;

type
  TfrmSysCountry = class(TfrmInputSimpleDB<TSysCountry, TSysCountryService>)
    pnlContent: TPanel;
    lblCountryCode: TLabel;
    lblCountryName_en_US: TLabel;
    lblISOYear: TLabel;
    lblISOCCTLD: TLabel;
    lblIsEuMember: TLabel;
    edtCountryCode: TEdit;
    edtCountryName_en_US: TEdit;
    edtISOYear: TEdit;
    edtISOCCTLD: TEdit;
    chkIsEuMember: TCheckBox;
    lblCountryName_tr_TR: TLabel;
    edtCountryName_tr_TR: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysCountry.BtnAcceptClick(Sender: TObject);
  procedure SetOrAddTranslation(ALangId: Int64; const ALocale, AName: string);
  var
    i: Integer;
    LTrans: TSysCountryTranslation;
    LFound: Boolean;
  begin
    LFound := False;
    if Assigned(Table.Translations) then
    begin
      for i := 0 to Table.Translations.Count - 1 do
      begin
        if (Assigned(Table.Translations[i].SysLanguage) and SameText(Table.Translations[i].SysLanguage.Locale, ALocale))
        or (Table.Translations[i].SysLanguageId = ALangId)
        then
        begin
          Table.Translations[i].CountryName := AName;
          LFound := True;
          Break;
        end;
      end;
    end;

    if not LFound and (Trim(AName) <> '') then
    begin
      LTrans := TSysCountryTranslation.Create;
      LTrans.SysCountryId := Table.Id;
      LTrans.SysLanguageId := ALangId;
      LTrans.CountryName := AName;
      LTrans.SysLanguage := TSysLanguage.Create;
      LTrans.SysLanguage.Id := ALangId;
      LTrans.SysLanguage.Locale := ALocale;
      Table.Translations.Add(LTrans);
    end;
  end;
begin
  Table.CountryCode := edtCountryCode.Text;
  Table.ISOYear := StrToIntDef(edtISOYear.Text, 0);
  Table.ISOCCTLD := edtISOCCTLD.Text;
  Table.IsEuMember := chkIsEuMember.Checked;

  SetOrAddTranslation(CLangID_EN, CLangLocaleEN, edtCountryName_en_US.Text);
  SetOrAddTranslation(CLangID_TR, CLangLocaleTR, edtCountryName_tr_TR.Text);

  inherited;
end;

procedure TfrmSysCountry.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysCountry.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtCountryCode.SetFocus;
end;

procedure TfrmSysCountry.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.TitleSingular, 'Country');
  lblCountryCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryCode, 'Country Code (ISO 2)');
  lblCountryName_en_US.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName + ' (en-US)', 'Country Name (en-US)');
  lblCountryName_tr_TR.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName + ' (tr-TR)', 'Country Name (tr-TR)');
  lblISOYear.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsoYear, 'ISO Year');
  lblISOCCTLD.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsoCctld, 'ISO Cctld');
  lblIsEuMember.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsEuMember, 'EU Member?');
end;

procedure TfrmSysCountry.RefreshData;
var
  i: Integer;
begin
  inherited;
  edtCountryCode.Text := Table.CountryCode;
  edtISOYear.Text := Table.ISOYear.ToString;
  edtISOCCTLD.Text := Table.ISOCCTLD;
  chkIsEuMember.Checked := Table.IsEuMember;

  if Assigned(Table.Translations) then
  begin
    for i := 0 to Table.Translations.Count - 1 do
    begin
      if Assigned(Table.Translations[i].SysLanguage) then
      begin
        if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleEN) then
          edtCountryName_en_US.Text := Table.Translations[i].CountryName
        else if SameText(Table.Translations[i].SysLanguage.Locale, CLangLocaleTR) then
          edtCountryName_tr_TR.Text := Table.Translations[i].CountryName;
      end
      else
      begin
        if Table.Translations[i].SysLanguageId = CLangID_EN then
          edtCountryName_en_US.Text := Table.Translations[i].CountryName
        else if Table.Translations[i].SysLanguageId = CLangID_TR then
          edtCountryName_tr_TR.Text := Table.Translations[i].CountryName;
      end;
    end;
  end;
end;

end.
