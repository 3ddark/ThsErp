unit ufrmSysUserPermissionTemplate;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUserPermissionTemplate.Service, SysUserPermissionTemplate;

type
  TfrmSysUserPermissionTemplate = class(TfrmInputSimpleDB<TSysUserPermissionTemplate, TSysUserPermissionTemplateService>)
    pnlContent: TPanel;
    lblSysUserId: TLabel;
    edtSysUserId: TEdit;
    lblSysPermissionTemplateId: TLabel;
    edtSysPermissionTemplateId: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmSysUsers, SysUser, SysUser.Service,                                           // TfrmSysUsers helper output form
  ufrmSysPermissionTemplates, SysPermissionTemplate, SysPermissionTemplate.Service; // TfrmSysPermissionTemplates helper output form

procedure TfrmSysUserPermissionTemplate.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSysUserId.OnHelperProcess := HelperProcess;
  edtSysPermissionTemplateId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysUserPermissionTemplate.FormShow(Sender: TObject);
begin
  inherited;
  if (Table.SysUserId > 0) and edtSysPermissionTemplateId.CanFocus then
    edtSysPermissionTemplateId.SetFocus
  else if edtSysUserId.CanFocus then
    edtSysUserId.SetFocus;
end;

procedure TfrmSysUserPermissionTemplate.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUserPermissionTemplate.TitleSingular, 'User Permission Template');
  lblSysUserId.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.TitleSingular, 'User');
  lblSysPermissionTemplateId.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.TitleSingular, 'Permission Template');
end;

procedure TfrmSysUserPermissionTemplate.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmUser: TfrmSysUsers;
  LFrmTemplate: TfrmSysPermissionTemplates;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtSysUserId.Name then
    begin
      LFrmUser := TfrmSysUsers.Create(LEdit, TSysUserService.Create, TSysUser.Create);
      try
        LFrmUser.IsHelper := True;
        LFrmUser.ShowModal;
        if LFrmUser.DataTransfer then
          if LFrmUser.CleanAndClose then
          begin
            Table.SysUserId := 0;
            Table.Username := '';
            LEdit.Clear;
          end
          else
          begin
            Table.SysUserId := LFrmUser.Table.Id;
            Table.Username := LFrmUser.Table.Username;
            LEdit.Text := Table.Username;
          end;
      finally
        LFrmUser.Free;
      end;
    end
    else if LEdit.Name = edtSysPermissionTemplateId.Name then
    begin
      LFrmTemplate := TfrmSysPermissionTemplates.Create(LEdit, TSysPermissionTemplateService.Create, TSysPermissionTemplate.Create);
      try
        LFrmTemplate.IsHelper := True;
        LFrmTemplate.ShowModal;
        if LFrmTemplate.DataTransfer then
          if LFrmTemplate.CleanAndClose then
          begin
            Table.SysPermissionTemplateId := 0;
            Table.TemplateName := '';
            LEdit.Clear;
          end
          else
          begin
            Table.SysPermissionTemplateId := LFrmTemplate.Table.Id;
            Table.TemplateName := LFrmTemplate.Table.TemplateName;
            LEdit.Text := Table.TemplateName;
          end;
      finally
        LFrmTemplate.Free;
      end;
    end;
  end;
end;

procedure TfrmSysUserPermissionTemplate.RefreshData;
begin
  inherited;
  if Table.SysUserId > 0 then
    edtSysUserId.Text := Table.Username
  else
    edtSysUserId.Text := '';

  if Table.SysPermissionTemplateId > 0 then
    edtSysPermissionTemplateId.Text := Table.TemplateName
  else
    edtSysPermissionTemplateId.Text := '';
end;

end.
