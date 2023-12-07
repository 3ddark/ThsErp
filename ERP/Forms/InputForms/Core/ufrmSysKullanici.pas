unit ufrmSysKullanici;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Constants,
  Ths.Database.Table.SysKullanicilar;

type
  TfrmSysKullanici = class(TfrmBaseInputDB)
    lblkullanici_adi: TLabel;
    edtkullanici_adi: TEdit;
    lblkullanici_sifre: TLabel;
    edtkullanici_sifre: TEdit;
    lblis_aktif: TLabel;
    chkis_aktif: TCheckBox;
    lblis_yonetici: TLabel;
    chkis_yonetici: TCheckBox;
    lblis_super_kullanici: TLabel;
    chkis_super_kullanici: TCheckBox;
    lblip_adres: TLabel;
    edtip_adres: TEdit;
    lblmac_adres: TLabel;
    edtmac_adres: TEdit;
    lblpersonel_id: TLabel;
    edtpersonel_id: TEdit;
  public
    procedure Repaint; override;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

uses
  ufrmPrsPersoneller, Ths.Database.Table.PrsPersoneller;

{$R *.dfm}

procedure TfrmSysKullanici.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysKullanici(Table).KullaniciAdi.Value := edtkullanici_adi.Text;

      if (edtkullanici_sifre.Text <> TSysKullanici(Table).KullaniciSifre.Value) then
        TSysKullanici(Table).KullaniciSifre.Value := edtkullanici_sifre.Text;

      TSysKullanici(Table).IsAktif.Value := chkis_aktif.Checked;
      TSysKullanici(Table).IsYonetici.Value := chkis_yonetici.Checked;
      TSysKullanici(Table).IsSuperKullanici.Value := chkis_super_kullanici.Checked;
      TSysKullanici(Table).IpAdres.Value := edtip_adres.Text;
      TSysKullanici(Table).MacAdres.Value := edtmac_adres.Text;

      //emp_card data take from helper form
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysKullanici.FormCreate(Sender: TObject);
begin
  inherited;

  edtpersonel_id.OnHelperProcess := HelperProcess;

  //encrypted data can be lowercase characters
  edtkullanici_sifre.CharCase := ecNormal;
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
      if TEdit(Sender).Name = edtpersonel_id.Name then
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
  edtkullanici_adi.Text := TSysKullanici(Table).KullaniciAdi.Value;
  edtkullanici_sifre.Text := TSysKullanici(Table).KullaniciSifre.Value;
  chkis_aktif.Checked := TSysKullanici(Table).IsAktif.Value;
  chkis_yonetici.Checked := TSysKullanici(Table).IsYonetici.Value;
  chkis_super_kullanici.Checked := TSysKullanici(Table).IsSuperKullanici.Value;
  edtip_adres.Text := TSysKullanici(Table).IpAdres.Value;
  edtmac_adres.Text := TSysKullanici(Table).MacAdres.Value;
  edtpersonel_id.Text := TSysKullanici(Table).AdSoyad.Value;

  edtkullanici_sifre.Clear;
  edtkullanici_sifre.MaxLength := 16;
end;

procedure TfrmSysKullanici.Repaint;
begin
  inherited;
  if (FormMode = ifmUpdate) then
  begin
    edtkullanici_sifre.thsRequiredData := False;
  end;

  edtkullanici_sifre.CharCase := ecNormal;
end;

end.

