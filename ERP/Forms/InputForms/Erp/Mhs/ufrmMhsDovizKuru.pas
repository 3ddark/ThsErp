unit ufrmMhsDovizKuru;

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
  ufrmBaseInputDB;

type
  TfrmMhsDovizKuru = class(TfrmBaseInputDB)
    lbltarih: TLabel;
    edttarih: TEdit;
    lblpara_birimi: TLabel;
    edtpara_birimi: TEdit;
    lblkur: TLabel;
    edtkur: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysParaBirimi,
  ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.MhsDovizKuru;

{$R *.dfm}

procedure TfrmMhsDovizKuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TMhsDovizKuru(Table).Tarih.Value := edttarih.Text;
      TMhsDovizKuru(Table).ParaBirimi.Value := edtpara_birimi.Text;
      TMhsDovizKuru(Table).Kur.Value := edtkur.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmMhsDovizKuru.FormShow(Sender: TObject);
begin
  inherited;
  edtkur.thsDecimalDigitCount := FormatedVariantVal(GSysOndalikHane.DovizKuru);
end;

procedure TfrmMhsDovizKuru.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysParaBirimleri;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtpara_birimi.Name then
      begin
        LFrm := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, TSysParaBirimi.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
              TEdit(Sender).Clear
            else
            TEdit(Sender).Text := FormatedVariantVal(TSysParaBirimi(LFrm.Table).ParaBirimi);
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmMhsDovizKuru.RefreshData;
begin
  edttarih.Text := FormatedVariantVal(TMhsDovizKuru(Table).Tarih);
  edtpara_birimi.Text := FormatedVariantVal(TMhsDovizKuru(Table).ParaBirimi);
  edtkur.Text := FormatedVariantVal(TMhsDovizKuru(Table).Kur);
end;

end.
