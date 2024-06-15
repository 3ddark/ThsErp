unit ufrmSysSifreDegistir;

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
  TfrmSysSifreDegistir = class(TfrmBaseInput)
    lblmevcut_sifre: TLabel;
    edtmevcut_sifre: TEdit;
    lblyeni_sifre: TLabel;
    edtyeni_sifre: TEdit;
    lblyeni_sifre2: TLabel;
    edtyeni_sifre2: TEdit;
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

procedure TfrmSysSifreDegistir.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if TSysKullanici(Table).ChangePassword(edtmevcut_sifre.Text) then
      begin
        CustomMsgDlg('Þifreniz baþarýlý bir þekilde güncellendi!', mtInformation, [mbOK], ['Tamam'], mbOK, 'Þifre Güncelleme');
      end;
    end;
  end;
end;

procedure TfrmSysSifreDegistir.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSysSifreDegistir.FormCreate(Sender: TObject);
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

procedure TfrmSysSifreDegistir.RefreshData;
begin
  inherited;
  edtmevcut_sifre.Clear;
  edtyeni_sifre.Clear;
  edtyeni_sifre2.Clear;
end;

function TfrmSysSifreDegistir.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := True;
  if (Trim(edtyeni_sifre.Text) = '') or (Trim(edtyeni_sifre.Text).Length < 1) or (Trim(edtyeni_sifre.Text) <> Trim(edtyeni_sifre2.Text)) then
    Result := False;
end;

end.
