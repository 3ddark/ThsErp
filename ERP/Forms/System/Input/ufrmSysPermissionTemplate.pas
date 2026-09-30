unit ufrmSysPermissionTemplate;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysPermissionTemplate.Service, SysPermissionTemplate;

type
  TfrmSysPermissionTemplate = class(TfrmInputSimpleDB<TSysPermissionTemplate, TSysPermissionTemplateService>)
    pnlContent: TPanel;
    lblTemplateKey: TLabel;
    lblTemplateName: TLabel;
    lblDescription: TLabel;
    lblActive: TLabel;
    edtTemplateKey: TEdit;
    edtTemplateName: TEdit;
    edtDescription: TEdit;
    chkActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysPermissionTemplate.BtnAcceptClick(Sender: TObject);
begin
  Table.TemplateKey := LowerCase(Trim(edtTemplateKey.Text));
  Table.TemplateName := Trim(edtTemplateName.Text);
  Table.Description := Trim(edtDescription.Text);
  Table.Active := chkActive.Checked;
  inherited;
end;

procedure TfrmSysPermissionTemplate.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtTemplateKey.CharCase := ecLowerCase;
  edtTemplateName.CharCase := ecNormal;
  edtDescription.CharCase := ecNormal;
  edtTemplateKey.thsInputDataType := itString;
  edtTemplateName.thsInputDataType := itString;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSysPermissionTemplate.FormShow(Sender: TObject);
begin
  inherited;
  if edtTemplateKey.CanFocus then
    edtTemplateKey.SetFocus;
end;

procedure TfrmSysPermissionTemplate.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.TitleSingular, 'Permission Template');
  lblTemplateKey.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColTemplateKey, 'Template Key');
  lblTemplateName.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColTemplateName, 'Template Name');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColDescription, 'Description');
  lblActive.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.ColActive, 'Active');
end;

procedure TfrmSysPermissionTemplate.RefreshData;
begin
  inherited;
  edtTemplateKey.Text := Table.TemplateKey;
  edtTemplateName.Text := Table.TemplateName;
  edtDescription.Text := Table.Description;
  chkActive.Checked := Table.Active;
end;

end.
