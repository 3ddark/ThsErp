unit ufrmSysUser;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUser.Service, SysUser;

type
  TfrmSysUser = class(TfrmInputSimpleDB<TSysUser, TSysUserService>)
    pnlContent: TPanel;
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
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
    lblUserPassword: TLabel;
    edtUserPassword: TEdit;
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
  ufrmEmpEmployees, EmpEmployee, EmpEmployee.Service, Ths.Globals;

procedure TfrmSysUser.BtnAcceptClick(Sender: TObject);
begin
  Table.Username := edtUsername.Text;

  if edtUserPassword.Visible then
    Table.UserPassword := edtUserPassword.Text;
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
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtUserPassword.CharCase := ecNormal;
  // Login ekranı gibi kullanıcı adı her zaman büyük harf (normalizasyon serviste de yapılır)
  edtUsername.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmSysUser.FormShow(Sender: TObject);
begin
  inherited;
  edtUsername.SetFocus;
end;

procedure TfrmSysUser.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.TitleSingular, 'User');
  lblUsername.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'Username');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColEmployeeId, 'Employee');
  lblUserPassword.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserPassword, 'Password');
  lblActive.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColActive, 'Active');
  lblManager.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColManager, 'Manager');
  lblSuperUser.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColSuperUser, 'Super User');
  lblIpAddress.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColIpAddress, 'IP Address');
  lblMacAddress.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColMacAddress, 'MAC Address');
  chkActive.Caption := lblActive.Caption;
  chkManager.Caption := lblManager.Caption;
  chkSuperUser.Caption := lblSuperUser.Caption;
end;

procedure TfrmSysUser.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPrs: TfrmEmpEmployees;
begin
  if Sender is TEdit then
  begin
    LEdit := (Sender as TEdit);
    if LEdit.Name = edtEmpEmployeeId.Name then
    begin
      LFrmPrs := TfrmEmpEmployees.Create(LEdit, TEmpEmployeeService.Create, TEmpEmployee.Create, True, True);
      try
        LFrmPrs.ShowModal;
        if LFrmPrs.DataTransfer then
        begin
          if LFrmPrs.CleanAndClose then
          begin
            Table.EmpEmployeeId := 0;
            LEdit.Clear;
          end
          else
          begin
            Table.EmpEmployeeId := LFrmPrs.Table.Id;
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
  if Table.EmpEmployeeId > 0 then
  begin
    edtEmpEmployeeId.Text := Trim(Table.PersonName + ' ' + Table.PersonSurname);
    if edtEmpEmployeeId.Text = '' then
      edtEmpEmployeeId.Text := Table.EmpEmployeeId.ToString;
  end
  else
    edtEmpEmployeeId.Text := '';

  lblUserPassword.Visible := FormMode in [ifmNewRecord, ifmCopyNewRecord];
  edtUserPassword.Visible := lblUserPassword.Visible;
  edtUserPassword.Clear;
  chkActive.Checked := Table.Active;
  chkManager.Checked := Table.Manager;
  chkSuperUser.Checked := Table.SuperUser;
  edtIpAddress.Text := Table.IpAddress;
  edtMacAddress.Text := Table.MacAddress;
end;

end.
