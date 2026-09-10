unit ufrmSysCountry;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysCountry.Service, SysCountry;

type
  TfrmSysCountry = class(TfrmInputSimpleDB<TSysCountry, TSysCountryService>)
    pnlContent: TPanel;
    lblCountryCode: TLabel;
    lblISOYear: TLabel;
    lblISOCCTLD: TLabel;
    lblIsEuMember: TLabel;
    edtCountryCode: TEdit;
    edtISOYear: TEdit;
    edtISOCCTLD: TEdit;
    chkIsEuMember: TCheckBox;
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

uses
  SysLanguage;

procedure TfrmSysCountry.BtnAcceptClick(Sender: TObject);
var
  LValues: TTranslationMap;
  LPair  : TPair<string, string>;
  i      : Integer;
  LTrans : TSysCountryTranslation;
  LFound : Boolean;
begin
  Table.CountryCode := edtCountryCode.Text;
  Table.ISOYear     := StrToIntDef(edtISOYear.Text, 0);
  Table.ISOCCTLD    := edtISOCCTLD.Text;
  Table.IsEuMember  := chkIsEuMember.Checked;

  LValues := CollectTranslationValues(scrlbxTranslations, 'CountryName');
  try
    for LPair in LValues do
    begin
      LFound := False;
      if Assigned(Table.Translations) then
        for i := 0 to Table.Translations.Count - 1 do
          if SameText(Table.Translations[i].SysLanguage.Locale, LPair.Key) then
          begin
            Table.Translations[i].CountryName := LPair.Value;
            LFound := True;
            Break;
          end;

      if not LFound and (Trim(LPair.Value) <> '') then
      begin
        LTrans               := TSysCountryTranslation.Create;
        LTrans.SysCountryId  := Table.Id;
        LTrans.SysLanguageId := 0;
        LTrans.CountryName   := LPair.Value;
        LTrans.SysLanguage   := TSysLanguage.Create;
        LTrans.SysLanguage.Locale := LPair.Key;
        Table.Translations.Add(LTrans);
      end;
    end;
  finally
    LValues.Free;
  end;

  inherited;
end;

procedure TfrmSysCountry.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  scrlbxTranslations.Parent := PanelMain;
  edtCountryCode.CharCase := TEditCharCase.ecUpperCase;

  BuildTranslationControls(
    scrlbxTranslations,
    'CountryName',
    TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName, 'Country Name'),
    lblCountryCode);
end;

procedure TfrmSysCountry.FormShow(Sender: TObject);
begin
  inherited;
  edtCountryCode.SetFocus;
end;

procedure TfrmSysCountry.ApplyLocalization;
begin
  inherited;
  Self.Caption           := TLocalizationManager.Translate(TLangKeys.TSysCountry.TitleSingular, 'Country');
  lblCountryCode.Caption := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryCode, 'Country Code');
  lblISOYear.Caption     := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsoYear, 'ISO Year');
  lblISOCCTLD.Caption    := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsoCctld, 'ISO CCTLD');
  lblIsEuMember.Caption  := TLocalizationManager.Translate(TLangKeys.TSysCountry.ColIsEuMember, 'EU Member?');

  UpdateTranslationLabels(scrlbxTranslations, 'CountryName', TLocalizationManager.Translate(TLangKeys.TSysCountry.ColCountryName, 'Country Name'));
end;

procedure TfrmSysCountry.RefreshData;
var
  LValues: TTranslationMap;
  i      : Integer;
  LTrans : TSysCountryTranslation;
begin
  inherited;
  edtCountryCode.Text    := Table.CountryCode;
  edtISOYear.Text        := Table.ISOYear.ToString;
  edtISOCCTLD.Text       := Table.ISOCCTLD;
  chkIsEuMember.Checked  := Table.IsEuMember;

  LValues := TTranslationMap.Create;
  try
    if Assigned(Table.Translations) then
      for i := 0 to Table.Translations.Count - 1 do
      begin
        LTrans := Table.Translations[i];
        if Assigned(LTrans.SysLanguage) and (LTrans.SysLanguage.Locale <> '') then
          LValues.AddOrSetValue(LTrans.SysLanguage.Locale, LTrans.CountryName);
      end;

    FillTranslationControls(scrlbxTranslations, LValues);
  finally
    LValues.Free;
  end;
end;

end.
