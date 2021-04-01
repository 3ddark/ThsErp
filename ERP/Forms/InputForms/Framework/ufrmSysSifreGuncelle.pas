unit ufrmSysSifreGuncelle;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInput,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKullanici;

type
  TfrmSysSifreGuncelle = class(TfrmBaseInput)
    lblold_password: TLabel;
    edtold_password: TEdit;
    lblnew_password: TLabel;
    edtnew_password: TEdit;
    lblnew_password2: TLabel;
    edtnew_password2: TEdit;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
    procedure btnCloseClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

{$R *.dfm}

procedure TfrmSysSifreGuncelle.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if setUserPassword(edtold_password.Text, edtnew_password.Text, GSysKullanici.Id.Value) then
      begin
        GSysKullanici.SelectToList(' AND ' + GSysKullanici.TableName + '.' + GSysKullanici.Id.FieldName + '=' + VarToStr(Table.Id.Value), False, False);

        CustomMsgDlg('Þifreniz baþarýlý bir þekilde güncellendi!' + FERHAT_UYARI, mtInformation, [mbOK], ['TAMAM'], mbOK, 'Þifre Güncelleme');
        Close;
      end;
    end;
  end;
end;

procedure TfrmSysSifreGuncelle.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSysSifreGuncelle.FormCreate(Sender: TObject);
begin
  inherited;
  if FormMode = ifmUpdate then
  begin
    btnAccept.Visible := True;
    btnAccept.Caption := TranslateText('CONFIRM', FrameworkLang.ButtonAccept, LngButton, LngSystem);
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
  end;
end;

procedure TfrmSysSifreGuncelle.RefreshData;
begin
  inherited;
  edtold_password.Clear;
  edtnew_password.Clear;
  edtnew_password2.Clear;
end;

function TfrmSysSifreGuncelle.ValidateInput(
  panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := True;
  if (Trim(edtnew_password.Text) = '')
  or (Trim(edtnew_password.Text).Length < 1)
  or (Trim(edtnew_password.Text) <> Trim(edtnew_password2.Text))
  then
    Result := False;
end;

end.
