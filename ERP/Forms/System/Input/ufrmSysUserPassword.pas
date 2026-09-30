unit ufrmSysUserPassword;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Samples.Spin, System.UITypes,
  ufrmBase, LocalizationManager;

type
  TSysUserPasswordMode = (spmReset, spmChange);

  TfrmSysUserPassword = class(TfrmBase)
    lblUsername: TLabel;
    edtUsername: TEdit;
    lblOldPassword: TLabel;
    edtOldPassword: TEdit;
    lblNewPassword: TLabel;
    edtNewPassword: TEdit;
    lblNewPasswordConfirm: TLabel;
    edtNewPasswordConfirm: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
  private
    FMode: TSysUserPasswordMode;
    FUserId: Int64;
    FUsername: string;
  public
    procedure ApplyLocalization; override;

    class procedure ShowReset(AOwner: TComponent; AUserId: Int64; const AUsername: string);
    class procedure ShowChange(AOwner: TComponent);
  end;

implementation

{$R *.dfm}

uses
  AppContext, SysUser.Service;

class procedure TfrmSysUserPassword.ShowReset(AOwner: TComponent; AUserId: Int64; const AUsername: string);
var
  LFrm: TfrmSysUserPassword;
begin
  LFrm := TfrmSysUserPassword.Create(AOwner);
  LFrm.FMode := spmReset;
  LFrm.FUserId := AUserId;
  LFrm.FUsername := AUsername;
  LFrm.ShowModal;
end;

class procedure TfrmSysUserPassword.ShowChange(AOwner: TComponent);
var
  LFrm: TfrmSysUserPassword;
begin
  LFrm := TfrmSysUserPassword.Create(AOwner);
  LFrm.FMode := spmChange;
  if Assigned(TAppContext.Instance.CurrentUser) then
  begin
    LFrm.FUserId := TAppContext.Instance.CurrentUser.GetUserId;
    LFrm.FUsername := TAppContext.Instance.CurrentUser.GetUsername;
  end;
  LFrm.ShowModal;
end;

procedure TfrmSysUserPassword.FormCreate(Sender: TObject);
begin
  inherited;
  btnAccept.Visible := True;
  edtUsername.ReadOnly := True;
  edtUsername.TabStop := False;
end;

procedure TfrmSysUserPassword.FormShow(Sender: TObject);
const
  ROW_HEIGHT = 25;
begin
  edtUsername.Text := FUsername;

  if FMode = spmReset then
  begin
    lblOldPassword.Visible := False;
    edtOldPassword.Visible := False;
    lblNewPassword.Top := lblNewPassword.Top - ROW_HEIGHT;
    edtNewPassword.Top := edtNewPassword.Top - ROW_HEIGHT;
    lblNewPasswordConfirm.Top := lblNewPasswordConfirm.Top - ROW_HEIGHT;
    edtNewPasswordConfirm.Top := edtNewPasswordConfirm.Top - ROW_HEIGHT;
    Self.ClientHeight := Self.ClientHeight - ROW_HEIGHT;
  end;

  ApplyLocalization;
  inherited;

  if (FMode = spmChange) and edtOldPassword.CanFocus then
    edtOldPassword.SetFocus
  else if edtNewPassword.CanFocus then
    edtNewPassword.SetFocus;
end;

procedure TfrmSysUserPassword.ApplyLocalization;
begin
  inherited;
  if FMode = spmReset then
    Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.TitleResetPassword, 'Reset Password')
  else
    Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.TitleChangePassword, 'Change Password');

  lblUsername.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.ColUserName, 'Username');
  lblOldPassword.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.LblOldPassword, 'Current Password');
  lblNewPassword.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.LblNewPassword, 'New Password');
  lblNewPasswordConfirm.Caption := TLocalizationManager.Translate(TLangKeys.TSysUser.LblNewPasswordConfirm, 'Confirm New Password');
  btnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Confirm');
end;

procedure TfrmSysUserPassword.btnAcceptClick(Sender: TObject);
var
  LService: TSysUserService;
begin
  if edtNewPassword.Text <> edtNewPasswordConfirm.Text then
  begin
    MessageDlg(TLocalizationManager.Translate(TLangKeys.TSysUser.PasswordMismatch, 'The new password and its confirmation do not match.'),
      mtWarning, [mbOK], 0);
    edtNewPasswordConfirm.SetFocus;
    Exit;
  end;

  LService := TSysUserService.Create;
  try
    try
      if FMode = spmReset then
        LService.ResetPassword(FUserId, edtNewPassword.Text, True)
      else
        LService.ChangeOwnPassword(edtOldPassword.Text, edtNewPassword.Text);
    except
      on E: Exception do
      begin
        MessageDlg(E.Message, mtError, [mbOK], 0);
        Exit;
      end;
    end;
  finally
    LService.Free;
  end;

  if FMode = spmReset then
    MessageDlg(TLocalizationManager.Translate(TLangKeys.TSysUser.PasswordResetDone, 'The password has been reset.'), mtInformation, [mbOK], 0)
  else
    MessageDlg(TLocalizationManager.Translate(TLangKeys.TSysUser.PasswordChangeDone, 'Your password has been changed.'), mtInformation, [mbOK], 0);

  Self.Close;
end;

end.
