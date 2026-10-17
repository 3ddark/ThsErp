unit ufrmEInvProfile;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvProfile.Service, EInvProfile;

type
  TfrmEInvProfile = class(TfrmInputSimpleDB<TEInvProfile, TEInvProfileService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblDocumentKind: TLabel;
    cbbDocumentKind: TComboBox;
    lblRequiresExportInfo: TLabel;
    chkRequiresExportInfo: TCheckBox;
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

procedure TfrmEInvProfile.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.DocumentKind := cbbDocumentKind.ItemIndex + 1;
  Table.RequiresExportInfo := chkRequiresExportInfo.Checked;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvProfile.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  TEInvLookup.FillItems(cbbDocumentKind.Items, elkDocumentKind);
end;

procedure TfrmEInvProfile.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvProfile.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.TitleSingular, 'e-Document Profile');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColCode, 'Profile ID');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColName, 'Name');
  lblDocumentKind.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColDocumentKind, 'Document Kind');
  LIndex := cbbDocumentKind.ItemIndex;
  TEInvLookup.FillItems(cbbDocumentKind.Items, elkDocumentKind);
  cbbDocumentKind.ItemIndex := LIndex;
  lblRequiresExportInfo.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColRequiresExportInfo, 'Export Info Required (GTIP, Package, Delivery Term)');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvProfile.ColIsActive, 'Active');
end;

procedure TfrmEInvProfile.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  cbbDocumentKind.ItemIndex := Table.DocumentKind - 1;
  chkRequiresExportInfo.Checked := Table.RequiresExportInfo;
  chkIsActive.Checked := Table.IsActive;
end;

end.
