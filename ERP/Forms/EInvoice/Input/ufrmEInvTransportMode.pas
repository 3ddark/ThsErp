unit ufrmEInvTransportMode;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvTransportMode.Service, EInvTransportMode;

type
  TfrmEInvTransportMode = class(TfrmInputSimpleDB<TEInvTransportMode, TEInvTransportModeService>)
    pnlContent: TPanel;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
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

procedure TfrmEInvTransportMode.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvTransportMode.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
end;

procedure TfrmEInvTransportMode.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmEInvTransportMode.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.TitleSingular, 'Transport Mode');
  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.ColCode, 'Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.ColName, 'Name');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.ColIsActive, 'Active');
end;

procedure TfrmEInvTransportMode.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  chkIsActive.Checked := Table.IsActive;
end;

end.
