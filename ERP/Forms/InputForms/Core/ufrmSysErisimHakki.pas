unit ufrmSysErisimHakki;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysErisimHaklari;

type
  TfrmSysErisimHakki = class(TfrmBaseInputDB)
    lbluser_id: TLabel;
    edtuser_id: TEdit;
    lblresource_id: TLabel;
    edtresource_id: TEdit;
    lblis_read: TLabel;
    chkis_read: TCheckBox;
    lblis_add: TLabel;
    chkis_add: TCheckBox;
    lblis_update: TLabel;
    chkis_update: TCheckBox;
    lblis_delete: TLabel;
    chkis_delete: TCheckBox;
    lblis_special: TLabel;
    chkis_special: TCheckBox;
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
  Ths.Database.Table.SysKullanicilar,
  ufrmSysKaynaklar,
  Ths.Database.Table.SysKaynaklar;

{$R *.dfm}

procedure TfrmSysErisimHakki.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //user_name and source_name data take from helper form
      TSysErisimHakki(Table).IsOkuma.Value := chkis_read.Checked;
      TSysErisimHakki(Table).IsEkleme.Value := chkis_add.Checked;
      TSysErisimHakki(Table).IsGuncelleme.Value := chkis_update.Checked;
      TSysErisimHakki(Table).IsSilme.Value := chkis_delete.Checked;
      TSysErisimHakki(Table).IsOzel.Value := chkis_special.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysErisimHakki.FormShow(Sender: TObject);
begin
  edtuser_id.OnHelperProcess := HelperProcess;
  edtresource_id.OnHelperProcess := HelperProcess;
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
      if TEdit(Sender).Name = edtuser_id.Name then
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
      else if TEdit(Sender).Name = edtresource_id.Name then
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
  edtuser_id.Text := TSysErisimHakki(Table).Kullanici.Value;
  edtresource_id.Text := TSysErisimHakki(Table).KaynakAdi.Value;
  chkis_read.Checked := TSysErisimHakki(Table).IsOkuma.Value;
  chkis_add.Checked := TSysErisimHakki(Table).IsEkleme.Value;
  chkis_update.Checked := TSysErisimHakki(Table).IsGuncelleme.Value;
  chkis_delete.Checked := TSysErisimHakki(Table).IsSilme.Value;
  chkis_special.Checked := TSysErisimHakki(Table).IsOzel.Value;
end;

end.
