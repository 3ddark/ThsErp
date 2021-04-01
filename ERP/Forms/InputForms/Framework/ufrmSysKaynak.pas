unit ufrmSysKaynak;

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
  Ths.Erp.Database.Table.SysKaynak;

type
  TfrmSysKaynak = class(TfrmBaseInputDB)
    lblkaynak_grup_id: TLabel;
    lblkaynak_kodu: TLabel;
    lblkaynak_adi: TLabel;
    edtkaynak_grup_id: TEdit;
    edtkaynak_kodu: TEdit;
    edtkaynak_adi: TEdit;
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
  Ths.Erp.Globals,
  ufrmSysKaynakGruplari,
  Ths.Erp.Database.Table.SysKaynakGrup;

procedure TfrmSysKaynak.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //source_group_id data take from helper form
      TSysKaynak(Table).KaynakKodu.Value := StrToInt(edtkaynak_kodu.Text);
      TSysKaynak(Table).KaynakAdi.Value := edtkaynak_adi.Text;
      TSysKaynak(Table).KaynakGrup.Value := edtkaynak_grup_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysKaynak.FormShow(Sender: TObject);
begin
  edtkaynak_grup_id.OnHelperProcess := HelperProcess;
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
      if TEdit(Sender).Name = edtkaynak_grup_id.Name then
      begin
        LFrm := TfrmSysKaynakGruplari.Create(TEdit(Sender), Self, TSysKaynakGrup.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            TSysKaynak(Table).KaynakGrupID.Value := LFrm.Table.Id.Value;
            TEdit(Sender).Text := TSysKaynakGrup(LFrm.TableHelper).KaynakGrup.Value;
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
  edtkaynak_grup_id.Text := FormatedVariantVal(TSysKaynak(Table).KaynakGrup);
  edtkaynak_kodu.Text := FormatedVariantVal(TSysKaynak(Table).KaynakKodu);
  edtkaynak_adi.Text := FormatedVariantVal(TSysKaynak(Table).KaynakAdi);
end;

end.
