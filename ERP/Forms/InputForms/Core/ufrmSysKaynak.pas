unit ufrmSysKaynak;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysKaynaklar;

type
  TfrmSysKaynak = class(TfrmBaseInputDB)
    lblresource_group_id: TLabel;
    lblresource_code: TLabel;
    lblresource_name: TLabel;
    edtresource_group_id: TEdit;
    edtresource_code: TEdit;
    edtresource_name: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals,
  ufrmSysKaynakGruplari,
  Ths.Database.Table.SysKaynakGruplari;

procedure TfrmSysKaynak.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //source_group_id data take from helper form
      TSysKaynak(Table).KaynakKodu.Value := StrToInt(edtresource_code.Text);
      TSysKaynak(Table).KaynakAdi.Value := edtresource_name.Text;
      TSysKaynak(Table).KaynakGrubu.Value := edtresource_group_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysKaynak.FormShow(Sender: TObject);
begin
  edtresource_group_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysKaynak.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysKaynakGruplari;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtresource_group_id.Name then
      begin
        LFrm := TfrmSysKaynakGruplari.Create(TEdit(Sender), Self, TSysKaynakGrubu.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            TSysKaynak(Table).KaynakGrupID.Value := LFrm.Table.Id.Value;
            TEdit(Sender).Text := TSysKaynakGrubu(LFrm.TableHelper).Grup.Value;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysKaynak.RefreshData;
begin
  edtresource_group_id.Text := TSysKaynak(Table).KaynakGrubu.AsString;
  edtresource_code.Text := TSysKaynak(Table).KaynakKodu.AsString;
  edtresource_name.Text := TSysKaynak(Table).KaynakAdi.AsString;
end;

end.
