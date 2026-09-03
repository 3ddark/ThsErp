unit ufrmSysUser;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUser.Service, SysUser, LocalizationManager;

type
  TfrmSysUser = class(TfrmInputSimpleDB<TSysUser, TSysUserService>)
    pnlContent: TPanel;
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblPersonId: TLabel;
    edtPersonId: TEdit;
    lblActive: TLabel;
    chkActive: TCheckBox;
    lblManager: TLabel;
    chkManager: TCheckBox;
    lblSuperUser: TLabel;
    chkSuperUser: TCheckBox;
    lblIpAddress: TLabel;
    edtIpAddress: TEdit;
    lblMacAddress: TLabel;
    edtMacAddress: TEdit;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure HelperProcess(Sender: TObject);
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmEmpPersons, EmpPerson, EmpPerson.Service, Ths.Globals;

procedure TfrmSysUser.BtnAcceptClick(Sender: TObject);
begin
  Table.Username := edtUsername.Text;
  Table.PersonId := edtPersonId.Tag;
  Table.Active := chkActive.Checked;
  Table.Manager := chkManager.Checked;
  Table.SuperUser := chkSuperUser.Checked;
  Table.IpAddress := edtIpAddress.Text;
  Table.MacAddress := edtMacAddress.Text;
  inherited;
end;

procedure TfrmSysUser.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPersonId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysUser.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtUsername.SetFocus;
end;

procedure TfrmSysUser.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.TitleSingular, 'Kullanıcı');
  lblUsername.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'Kullanıcı Adı');
  lblPersonId.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColPersonId, 'Personel');
  lblActive.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColIsActive, 'Aktif');
  lblManager.Caption := TLocalizationManager.Translate('sys_user.lbl_is_admin', 'Yönetici');
  lblSuperUser.Caption := TLocalizationManager.Translate('sys_user.lbl_is_superuser', 'Süper Kullanıcı');
  lblIpAddress.Caption := TLocalizationManager.Translate('sys_user.lbl_ip_address', 'IP Adresi');
  lblMacAddress.Caption := TLocalizationManager.Translate('sys_user.lbl_mac_address', 'MAC Adresi');
end;

procedure TfrmSysUser.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrs: TfrmEmpPersons;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtPersonId.Name then
    begin
      LFrmPrs := TfrmEmpPersons.Create(LEdit, TEmpPersonService.Create, TEmpPerson.Create, True, True);
      try
        LFrmPrs.ShowModal;
        if LFrmPrs.DataTransfer then
        begin
          if LFrmPrs.CleanAndClose then
          begin
            edtPersonId.Tag := 0;
            LEdit.Clear;
          end
          else
          begin
            edtPersonId.Tag := LFrmPrs.Table.Id;
            LEdit.Text := LFrmPrs.Table.FullName;
          end;
        end;
      finally
        LFrmPrs.Free;
      end;
    end;
  end;
end;

procedure TfrmSysUser.RefreshData;
begin
  inherited;
  edtUsername.Text := Table.Username;
  edtPersonId.Tag := Table.PersonId;
  if Table.PersonId > 0 then
  begin
    if Table.PersonName <> '' then
      edtPersonId.Text := Trim(Table.PersonName + ' ' + Table.PersonSurname)
    else
      edtPersonId.Text := Table.PersonId.ToString;
  end
  else
    edtPersonId.Text := '';
  chkActive.Checked := Table.Active;
  chkManager.Checked := Table.Manager;
  chkSuperUser.Checked := Table.SuperUser;
  edtIpAddress.Text := Table.IpAddress;
  edtMacAddress.Text := Table.MacAddress;
end;

end.
