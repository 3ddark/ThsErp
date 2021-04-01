unit ufrmSysErisimHakki;

interface

{$I ThsERP.inc}

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
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SysErisimHakki;

type
  TfrmSysUserAccessRight = class(TfrmBaseInputDB)
    lblkullanici_id: TLabel;
    edtkullanici_id: TEdit;
    lblkaynak_id: TLabel;
    edtkaynak_id: TEdit;
    lblis_okuma: TLabel;
    chkis_okuma: TCheckBox;
    lblis_yeni_kayit: TLabel;
    chkis_yeni_kayit: TCheckBox;
    lblis_guncelleme: TLabel;
    chkis_guncelleme: TCheckBox;
    lblis_silme: TLabel;
    chkis_silme: TCheckBox;
    lblis_ozel: TLabel;
    chkis_ozel: TCheckBox;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  ufrmSysKullanicilar,
  Ths.Erp.Database.Table.SysKullanici,
  ufrmSysKaynaklar,
  Ths.Erp.Database.Table.SysKaynak;

{$R *.dfm}

procedure TfrmSysUserAccessRight.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //user_name and source_name data take from helper form
      TSysErisimHakki(Table).IsOkuma.Value := chkis_okuma.Checked;
      TSysErisimHakki(Table).IsYeniKayit.Value := chkis_yeni_kayit.Checked;
      TSysErisimHakki(Table).IsGuncelleme.Value := chkis_guncelleme.Checked;
      TSysErisimHakki(Table).IsSilme.Value := chkis_silme.Checked;
      TSysErisimHakki(Table).IsOzel.Value := chkis_ozel.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysUserAccessRight.FormShow(Sender: TObject);
begin
  edtkullanici_id.OnHelperProcess := HelperProcess;
  edtkaynak_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysUserAccessRight.HelperProcess(Sender: TObject);
var
  LFrmUser: TfrmSysKullanicilar;
  LUser: TSysKullanici;
  LFrmSource: TfrmSysKaynaklar;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtkullanici_id.Name then
      begin
        LUser := TSysKullanici.Create(Table.Database);
        LUser.SelectToList(' AND ' + LUser.TableName + '.' + LUser.IsAktif.FieldName + '=TRUE', False, False);
        LFrmUser := TfrmSysKullanicilar.Create(TEdit(Sender), Self, LUser, fomNormal, True);
        try
          LFrmUser.ShowModal;
          if LFrmUser.DataAktar then
          begin
            TSysErisimHakki(Table).KullaniciID.Value := LFrmUser.Table.Id.Value;
            TEdit(Sender).Text := TSysKullanici(LFrmUser.TableHelper).KullaniciAdi.Value;
          end;
        finally
          LFrmUser.Free;
        end;
      end
      else if TEdit(Sender).Name = edtkaynak_id.Name then
      begin
        LFrmSource := TfrmSysKaynaklar.Create(TEdit(Sender), Self, TSysKaynak.Create(Table.Database), fomNormal, True);
        try
          LFrmSource.ShowModal;
          if LFrmSource.DataAktar then
          begin
            TSysErisimHakki(Table).KaynakID.Value := LFrmSource.Table.Id.Value;
            TEdit(Sender).Text := TSysKaynak(LFrmSource.TableHelper).KaynakAdi.Value;
          end;
        finally
          LFrmSource.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysUserAccessRight.RefreshData;
begin
  edtkullanici_id.Text := TSysErisimHakki(Table).KullaniciAdi.Value;
  edtkaynak_id.Text := TSysErisimHakki(Table).KaynakAdi.Value;
  chkis_okuma.Checked := TSysErisimHakki(Table).IsOkuma.Value;
  chkis_yeni_kayit.Checked := TSysErisimHakki(Table).IsYeniKayit.Value;
  chkis_guncelleme.Checked := TSysErisimHakki(Table).IsGuncelleme.Value;
  chkis_silme.Checked := TSysErisimHakki(Table).IsSilme.Value;
  chkis_ozel.Checked := TSysErisimHakki(Table).IsOzel.Value;
end;

end.
