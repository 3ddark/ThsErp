unit ufrmSysKullanici;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Constants,
  Ths.Database.Table.SysKullanicilar;

type
  TfrmSysKullanici = class(TfrmBaseInputDB)
    lbluser_name: TLabel;
    edtuser_name: TEdit;
    lbluser_pass: TLabel;
    edtuser_pass: TEdit;
    lblis_active: TLabel;
    chkis_active: TCheckBox;
    lblis_manager: TLabel;
    chkis_manager: TCheckBox;
    lblis_super_user: TLabel;
    chkis_super_user: TCheckBox;
    lblip_address: TLabel;
    edtip_address: TEdit;
    lblmac_address: TLabel;
    edtmac_address: TEdit;
    lblperson_id: TLabel;
    edtperson_id: TEdit;
  public
    destructor Destroy; override;
    procedure Repaint; override;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

uses
  ufrmPrsPersoneller,
  Ths.Database.Table.PrsPersoneller;

{$R *.dfm}

procedure TfrmSysKullanici.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysKullanici(Table).KullaniciAdi.Value := edtuser_name.Text;

      if (edtuser_pass.Text <> TSysKullanici(Table).KullaniciSifre.Value) then
        TSysKullanici(Table).KullaniciSifre.Value := edtuser_pass.Text;

      TSysKullanici(Table).IsAktif.Value := chkis_active.Checked;
      TSysKullanici(Table).IsYonetici.Value := chkis_manager.Checked;
      TSysKullanici(Table).IsSuperKullanici.Value := chkis_super_user.Checked;
      TSysKullanici(Table).IpAdres.Value := edtip_address.Text;
      TSysKullanici(Table).MacAdres.Value := edtmac_address.Text;

      //emp_card data take from helper form
      inherited;
    end;
  end
  else
    inherited;
end;

destructor TfrmSysKullanici.Destroy;
begin
  inherited;
end;

procedure TfrmSysKullanici.FormCreate(Sender: TObject);
begin
  inherited;

  edtperson_id.OnHelperProcess := HelperProcess;

  //encrypted data can be lowercase characters
  edtuser_pass.CharCase := ecNormal;
end;

procedure TfrmSysKullanici.HelperProcess(Sender: TObject);
var
  LFrmEmpCard: TfrmPrsPersoneller;
  LEmpCard: TPrsPersonel;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtperson_id.Name then
      begin
        LEmpCard := TPrsPersonel.Create(Table.Database);
        LFrmEmpCard := TfrmPrsPersoneller.Create(TEdit(Sender), Self, LEmpCard, fomNormal, True);
        try
          LFrmEmpCard.ShowModal;
          if LFrmEmpCard.DataAktar then
          begin
            TSysKullanici(Table).PersonelID.Value := LFrmEmpCard.Table.Id.Value;
            TEdit(Sender).Text := LEmpCard.AdSoyad.Value;
          end;
        finally
          LFrmEmpCard.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysKullanici.RefreshData;
begin
  edtuser_name.Text := TSysKullanici(Table).KullaniciAdi.Value;
  edtuser_pass.Text := TSysKullanici(Table).KullaniciSifre.Value;
  chkis_active.Checked := TSysKullanici(Table).IsAktif.Value;
  chkis_manager.Checked := TSysKullanici(Table).IsYonetici.Value;
  chkis_super_user.Checked := TSysKullanici(Table).IsSuperKullanici.Value;
  edtip_address.Text := TSysKullanici(Table).IpAdres.Value;
  edtmac_address.Text := TSysKullanici(Table).MacAdres.Value;
  edtperson_id.Text := TSysKullanici(Table).AdSoyad.Value;

  edtuser_pass.Clear;
  edtuser_pass.MaxLength := 16;
end;

procedure TfrmSysKullanici.Repaint;
begin
  inherited;
  if (FormMode = ifmUpdate) then
  begin
    edtuser_pass.thsRequiredData := False;
  end;

  edtuser_pass.CharCase := ecNormal;
end;

end.
