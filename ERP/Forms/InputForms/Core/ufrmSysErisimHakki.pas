unit ufrmSysErisimHakki;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysErisimHaklari;

type
  TfrmSysErisimHakki = class(TfrmBaseInputDB)
    lblkullanici_id: TLabel;
    edtkullanici_id: TEdit;
    lblkaynak_id: TLabel;
    edtkaynak_id: TEdit;
    lblis_okuma: TLabel;
    chkis_okuma: TCheckBox;
    lblis_ekleme: TLabel;
    chkis_ekleme: TCheckBox;
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
  ufrmSysKullanicilar, Ths.Database.Table.SysKullanicilar, ufrmSysKaynaklar,
  Ths.Database.Table.SysKaynaklar;

{$R *.dfm}

procedure TfrmSysErisimHakki.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //user_name and source_name data take from helper form
      TSysErisimHakki(Table).IsOkuma.Value := chkis_okuma.Checked;
      TSysErisimHakki(Table).IsEkleme.Value := chkis_ekleme.Checked;
      TSysErisimHakki(Table).IsGuncelleme.Value := chkis_guncelleme.Checked;
      TSysErisimHakki(Table).IsSilme.Value := chkis_silme.Checked;
      TSysErisimHakki(Table).IsOzel.Value := chkis_ozel.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysErisimHakki.FormShow(Sender: TObject);
begin
  edtkullanici_id.OnHelperProcess := HelperProcess;
  edtkaynak_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysErisimHakki.HelperProcess(Sender: TObject);
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

procedure TfrmSysErisimHakki.RefreshData;
begin
  edtkullanici_id.Text := TSysErisimHakki(Table).Kullanici.Value;
  edtkaynak_id.Text := TSysErisimHakki(Table).KaynakAdi.Value;
  chkis_okuma.Checked := TSysErisimHakki(Table).IsOkuma.Value;
  chkis_ekleme.Checked := TSysErisimHakki(Table).IsEkleme.Value;
  chkis_guncelleme.Checked := TSysErisimHakki(Table).IsGuncelleme.Value;
  chkis_silme.Checked := TSysErisimHakki(Table).IsSilme.Value;
  chkis_ozel.Checked := TSysErisimHakki(Table).IsOzel.Value;
end;

end.

