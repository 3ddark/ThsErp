unit ufrmEInvTaxType;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvTaxType.Service, EInvTaxType;

type
  TfrmEInvTaxType = class(TfrmInputSimpleDB<TEInvTaxType, TEInvTaxTypeService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblShortName: TLabel;
    edtShortName: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
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
  EInvLookup;

procedure TfrmEInvTaxType.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.ShortName := edtShortName.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvTaxType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  edtShortName.thsInputDataType := itString;
end;

procedure TfrmEInvTaxType.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvTaxType.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.TitleSingular, 'Tax Type Code');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColCode, 'Tax Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColName, 'Name');
  lblShortName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColShortName, 'Short Name');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTaxType.ColIsActive, 'Active');
end;

procedure TfrmEInvTaxType.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  edtShortName.Text := Table.ShortName;
  chkIsActive.Checked := Table.IsActive;
end;

end.
