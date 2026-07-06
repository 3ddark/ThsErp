unit ufrmSysPasswordChange;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInput, Ths.Database.Table,
  Ths.Database.Table.SysKullanicilar;

type
  TfrmSysPasswordChange = class(TfrmBaseInput)
    lblCurrentPassword: TLabel;
    edtCurrentPassword: TEdit;
    lblNewPassword: TLabel;
    edtNewPassword: TEdit;
    lblNewPassword2: TLabel;
    edtNewPassword2: TEdit;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
    procedure btnCloseClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals;

{$R *.dfm}

procedure TfrmSysPasswordChange.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if TSysKullanici(Table).ChangePassword(edtCurrentPassword.Text) then
      begin
        CustomMsgDlg('Your password has been updated successfully!', mtInformation, [mbOK], ['OK'], mbOK, 'Password Update');
      end;
    end;
  end;
end;

procedure TfrmSysPasswordChange.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSysPasswordChange.FormCreate(Sender: TObject);
begin
  inherited;
  if FormMode = ifmUpdate then
  begin
    btnAccept.Visible := True;
    btnAccept.Caption := 'Confirm';
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
  end;
end;

procedure TfrmSysPasswordChange.RefreshData;
begin
  inherited;
  edtCurrentPassword.Clear;
  edtNewPassword.Clear;
  edtNewPassword2.Clear;
end;

function TfrmSysPasswordChange.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := True;
  if (Trim(edtNewPassword.Text) = '') or (Trim(edtNewPassword.Text).Length < 1) or (Trim(edtNewPassword.Text) <> Trim(edtNewPassword2.Text)) then
    Result := False;
end;

end.
