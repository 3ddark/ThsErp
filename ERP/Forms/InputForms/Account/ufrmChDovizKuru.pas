unit ufrmChDovizKuru;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase, ufrmBaseInputDB;

type
  TfrmChDovizKuru = class(TfrmBaseInputDB)
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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SysParaBirimleri,
  ufrmSysParaBirimleri,
  Ths.Database.Table.ChDovizKurlari;

{$R *.dfm}

procedure TfrmChDovizKuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChDovizKuru(Table).KurTarihi.Value := StrToDateDef(edttarih.Text, 0);
      TChDovizKuru(Table).Para.Value := edtpara_birimi.Text;
      TChDovizKuru(Table).Kur.Value := StrToFloatDef(edtkur.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmChDovizKuru.FormShow(Sender: TObject);
begin
  edtpara_birimi.OnHelperProcess := HelperProcess;
  edtkur.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.AsInteger;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    edttarih.Text := DateToStr(GDataBase.DateDB);
  end;
end;

procedure TfrmChDovizKuru.HelperProcess(Sender: TObject);
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
              TEdit(Sender).Text := TSysParaBirimi(LFrm.Table).Para.AsString;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmChDovizKuru.RefreshData;
begin
  edttarih.Text := TChDovizKuru(Table).KurTarihi.AsString;
  edtpara_birimi.Text := TChDovizKuru(Table).Para.AsString;
  edtkur.Text := TChDovizKuru(Table).Kur.AsString;
end;

end.
