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
      TMhsDovizKuru(Table).Tarih.Value := StrToDateDef(edttarih.Text, 0);
      TMhsDovizKuru(Table).ParaBirimi.Value := edtpara_birimi.Text;
      TMhsDovizKuru(Table).Kur.Value := StrToFloatDef(edtkur.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmMhsDovizKuru.FormShow(Sender: TObject);
begin
  edtpara_birimi.OnHelperProcess := HelperProcess;
  edtkur.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.AsInteger;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    edttarih.Text := DateToStr(GDataBase.DateDB);
  end;
end;

procedure TfrmMhsDovizKuru.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysParaBirimleri;
  LPara: TSysParaBirimi;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtpara_birimi.Name then
      begin
        LPara := TSysParaBirimi.Create(Table.Database);
        LFrm := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, LPara, fomNormal, True);
        //LFrm.QryFiltreVarsayilan := ' AND ' + LPara.IsVarsayilan.FieldName + '=False';
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
  edttarih.Text := TMhsDovizKuru(Table).Tarih.AsString;
  edtpara_birimi.Text := TMhsDovizKuru(Table).ParaBirimi.AsString;
  edtkur.Text := TMhsDovizKuru(Table).Kur.AsString;
end;

end.
