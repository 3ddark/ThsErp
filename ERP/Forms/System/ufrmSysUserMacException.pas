unit ufrmSysUserMacException;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.AppEvnts
  , Vcl.Menus
  , Vcl.Samples.Spin

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.Memo
  , Ths.Erp.Helper.ComboBox

  , ufrmBase
  , ufrmBaseInputDB

  , Ths.Erp.Database.Table.SysUserMacException
  ;

type
  TfrmSysUserMacException = class(TfrmBaseInputDB)
    lbluser_name_id: TLabel;
    edtuser_name_id: TEdit;
    lblip_address: TLabel;
    edtip_address: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  ufrmSysKullanicilar,
  Ths.Erp.Database.Table.SysKullanici;

{$R *.dfm}

procedure TfrmSysUserMacException.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysUserMacException(Table).IpAddress.Value := edtip_address.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysUserMacException.FormCreate(Sender: TObject);
begin
  inherited;

  edtip_address.CharCase := ecNormal;
end;

procedure TfrmSysUserMacException.FormShow(Sender: TObject);
begin
  edtuser_name_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysUserMacException.HelperProcess(Sender: TObject);
var
  LFrmUser: TfrmSysKullanicilar;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtuser_name_id.Name then
      begin
        LFrmUser := TfrmSysKullanicilar.Create(TEdit(Sender), Self, TSysKullanici.Create(Table.Database), fomNormal, True);
        try
          LFrmUser.ShowModal;
          if LFrmUser.DataAktar then
          begin
            TSysUserMacException(Table).UserNameID.Value := LFrmUser.Table.Id.Value;
            TEdit(Sender).Text := TSysKullanici(LFrmUser.TableHelper).KullaniciAdi.Value;
          end;
        finally
          LFrmUser.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysUserMacException.RefreshData;
begin
  edtuser_name_id.Text := TSysUserMacException(Table).UserName.Value;
  edtip_address.Text := TSysUserMacException(Table).IpAddress.Value;
end;

end.
