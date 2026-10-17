unit ufrmEInvDeliveryTerm;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvDeliveryTerm.Service, EInvDeliveryTerm;

type
  TfrmEInvDeliveryTerm = class(TfrmInputSimpleDB<TEInvDeliveryTerm, TEInvDeliveryTermService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblIsIncoterms: TLabel;
    chkIsIncoterms: TCheckBox;
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

procedure TfrmEInvDeliveryTerm.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.IsIncoterms := chkIsIncoterms.Checked;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvDeliveryTerm.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
end;

procedure TfrmEInvDeliveryTerm.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvDeliveryTerm.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.TitleSingular, 'Delivery Term');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColCode, 'Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColName, 'Name');
  lblIsIncoterms.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColIsIncoterms, 'INCOTERMS (written to e-document)');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColIsActive, 'Active');
end;

procedure TfrmEInvDeliveryTerm.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  chkIsIncoterms.Checked := Table.IsIncoterms;
  chkIsActive.Checked := Table.IsActive;
end;

end.
