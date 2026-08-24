unit ufrmSysLanguages;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysLanguage.Service, SysLanguage, ufrmSysLanguage,
  LocalizationManager;

type
  TfrmSysLanguages = class(TfrmGrid<TSysLanguage, TSysLanguageService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysLanguages.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysLanguage.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysLanguage.Create(Self, Service, TSysLanguage.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLanguage.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysLanguages.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',            0, TLocalizationManager.Translate('sys_language.col_id', 'Id'));
  SetColumnProperty('locale',      120, TLocalizationManager.Translate(TLangKeys.TSysLanguage.ColLocale, 'Lisan Kodu'));
  SetColumnProperty('native_name', 250, TLocalizationManager.Translate(TLangKeys.TSysLanguage.ColNativeName, 'Lisan Adı'));
end;

procedure TfrmSysLanguages.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysLanguages.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysLanguages.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysLanguage.TitlePlural, 'Lisanlar');
end;

end.
