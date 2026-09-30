unit ufrmSysPermissionTemplateRight;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysPermissionTemplateRight.Service, SysPermissionTemplateRight;

type
  TfrmSysPermissionTemplateRight = class(TfrmInputSimpleDB<TSysPermissionTemplateRight, TSysPermissionTemplateRightService>)
    pnlContent: TPanel;
    lblSysPermissionTemplateId: TLabel;
    edtSysPermissionTemplateId: TEdit;
    lblSysPermissionId: TLabel;
    edtSysPermissionId: TEdit;
    chkIsRead: TCheckBox;
    chkIsAdd: TCheckBox;
    chkIsUpdate: TCheckBox;
    chkIsDelete: TCheckBox;
    chkIsSpecial: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
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
  Data.DB,
  ufrmSysPermissionTemplates, SysPermissionTemplate, SysPermissionTemplate.Service,  // TfrmSysPermissionTemplates helper output form
  ufrmSysPermissions, SysPermission, SysPermission.Service;                          // TfrmSysPermissions helper output form

procedure TfrmSysPermissionTemplateRight.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.IsRead := chkIsRead.Checked;
  Table.IsAdd := chkIsAdd.Checked;
  Table.IsUpdate := chkIsUpdate.Checked;
  Table.IsDelete := chkIsDelete.Checked;
  Table.IsSpecial := chkIsSpecial.Checked;
  inherited;
end;

procedure TfrmSysPermissionTemplateRight.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSysPermissionTemplateId.OnHelperProcess := HelperProcess;
  edtSysPermissionId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysPermissionTemplateRight.FormShow(Sender: TObject);
begin
  inherited;
  if (Table.SysPermissionTemplateId > 0) and edtSysPermissionId.CanFocus then
    edtSysPermissionId.SetFocus
  else if edtSysPermissionTemplateId.CanFocus then
    edtSysPermissionTemplateId.SetFocus;
end;

procedure TfrmSysPermissionTemplateRight.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplateRight.TitleSingular, 'Template Right');
  lblSysPermissionTemplateId.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermissionTemplate.TitleSingular, 'Permission Template');
  lblSysPermissionId.Caption := TLocalizationManager.Translate(TLangKeys.TSysPermission.TitleSingular, 'Permission');
  chkIsRead.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColRead, 'Read');
  chkIsAdd.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColAdd, 'Add');
  chkIsUpdate.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColUpdate, 'Update');
  chkIsDelete.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColDelete, 'Delete');
  chkIsSpecial.Caption := TLocalizationManager.Translate(TLangKeys.TSysAccessRight.ColSpecial, 'Special');
end;

procedure TfrmSysPermissionTemplateRight.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmTemplate: TfrmSysPermissionTemplates;
  LFrmPermission: TfrmSysPermissions;
  LField: TField;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtSysPermissionTemplateId.Name then
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
    end
    else if LEdit.Name = edtSysPermissionId.Name then
    begin
      LFrmPermission := TfrmSysPermissions.Create(LEdit, TSysPermissionService.Create, TSysPermission.Create);
      try
        LFrmPermission.IsHelper := True;
        LFrmPermission.ShowModal;
        if LFrmPermission.DataTransfer then
          if LFrmPermission.CleanAndClose then
          begin
            Table.SysPermissionId := 0;
            Table.PermissionName := '';
            LEdit.Clear;
          end
          else
          begin
            Table.SysPermissionId := LFrmPermission.Table.Id;
            // Çevrilmiş izin adı, yoksa anahtar
            LField := nil;
            if Assigned(LFrmPermission.Qry) and LFrmPermission.Qry.Active then
              LField := LFrmPermission.Qry.FindField('permission_name');
            if Assigned(LField) and (LField.AsString <> '') then
              Table.PermissionName := LField.AsString
            else
              Table.PermissionName := LFrmPermission.Table.PermissionKey;
            LEdit.Text := Table.PermissionName;
          end;
      finally
        LFrmPermission.Free;
      end;
    end;
  end;
end;

procedure TfrmSysPermissionTemplateRight.RefreshData;
begin
  inherited;
  if Table.SysPermissionTemplateId > 0 then
    edtSysPermissionTemplateId.Text := Table.TemplateName
  else
    edtSysPermissionTemplateId.Text := '';

  if Table.SysPermissionId > 0 then
    edtSysPermissionId.Text := Table.PermissionName
  else
    edtSysPermissionId.Text := '';

  chkIsRead.Checked := Table.IsRead;
  chkIsAdd.Checked := Table.IsAdd;
  chkIsUpdate.Checked := Table.IsUpdate;
  chkIsDelete.Checked := Table.IsDelete;
  chkIsSpecial.Checked := Table.IsSpecial;
end;

end.
