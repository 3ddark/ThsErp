unit ufrmSysSifreDegistir;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase, ufrmBaseInput,
  Ths.Database.Table, Ths.Database.Table.SysKullanicilar;

type
  TfrmSysChangePassword = class(TfrmBaseInput)
    lblold_password: TLabel;
    edtold_password: TEdit;
    lblnew_password: TLabel;
    edtnew_password: TEdit;
    lblnew_password2: TLabel;
    edtnew_password2: TEdit;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
    procedure btnCloseClick(Sender: TObject); override;
  end;

implementation

uses Ths.Globals;

{$R *.dfm}

procedure TfrmSysChangePassword.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if setUserPassword(edtold_password.Text, edtnew_password.Text, GSysKullanici.Id.Value) then
      begin
        GSysKullanici.SelectToList(' AND ' + GSysKullanici.TableName + '.' + GSysKullanici.Id.FieldName + '=' + VarToStr(Table.Id.Value), False, False);

        CustomMsgDlg('Þifreniz baþarýlý bir þekilde güncellendi!', mtInformation, [mbOK], ['Tamam'], mbOK, 'Þifre Güncelleme');
      end;
    end;
  end;
end;

procedure TfrmSysChangePassword.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSysChangePassword.FormCreate(Sender: TObject);
begin
  inherited;
  if FormMode = ifmUpdate then
  begin
    btnAccept.Visible := True;
    btnAccept.Caption := 'Onayla';
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
  end;
end;

procedure TfrmSysChangePassword.RefreshData;
begin
  inherited;
  edtold_password.Clear;
  edtnew_password.Clear;
  edtnew_password2.Clear;
end;

function TfrmSysChangePassword.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := True;
  if (Trim(edtnew_password.Text) = '') or (Trim(edtnew_password.Text).Length < 1) or (Trim(edtnew_password.Text) <> Trim(edtnew_password2.Text)) then
    Result := False;
end;

end.
