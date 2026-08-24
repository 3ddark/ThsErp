unit ufrmSysLanguage;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  AppContext, SysLanguage.Service, SysLanguage, LocalizationManager;

type
  TfrmSysLanguage = class(TfrmInputSimpleDB<TSysLanguage, TSysLanguageService>)
    pnlContent: TPanel;
    lblLocale: TLabel;
    lblNativeName: TLabel;
    edtLocale: TEdit;
    edtNativeName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysLanguage.BtnAcceptClick(Sender: TObject);
begin
  Table.Locale := edtLocale.Text;
  Table.NativeName := edtNativeName.Text;
  inherited;
end;

procedure TfrmSysLanguage.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysLanguage.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtLocale.SetFocus;
end;

procedure TfrmSysLanguage.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysLanguage.TitleSingular, 'Lisan');
  lblLocale.Caption := TLocalizationManager.Translate(TLangKeys.TSysLanguage.LblLocale, 'Lisan Kodu (Locale)');
  lblNativeName.Caption := TLocalizationManager.Translate(TLangKeys.TSysLanguage.LblNativeName, 'Lisan Adı (Native Name)');
end;

procedure TfrmSysLanguage.RefreshData;
begin
  inherited;
  edtLocale.Text := Table.Locale;
  edtNativeName.Text := Table.NativeName;
end;

end.
