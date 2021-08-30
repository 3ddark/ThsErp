unit ufrmSysIlce;

interface

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
  TfrmSysIlce = class(TfrmBaseInputDB)
    lblilce_adi: TLabel;
    edtilce_adi: TEdit;
    lblsehir_id: TLabel;
    edtsehir_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  ufrmSysIlceler,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysIlce,
  Ths.Erp.Database.Table.SysSehir,
  ufrmSysSehirler;

{$R *.dfm}

procedure TfrmSysIlce.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysSehirler;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtsehir_id.Name then
      begin
        LFrm := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysIlce(Table).SehirId.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := FormatedVariantVal(TSysSehir(LFrm.Table).SehirAdi);
              TSysIlce(Table).SehirId.Value := FormatedVariantVal(LFrm.Table.Id);
            end;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysIlce.RefreshData;
begin
  edtilce_adi.Text := VarToStr(FormatedVariantVal(TSysIlce(Table).IlceAdi));
  edtsehir_id.Text := VarToStr(FormatedVariantVal(TSysIlce(Table).SehirAdi));
end;

procedure TfrmSysIlce.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysIlce(Table).IlceAdi.Value := edtilce_adi.Text;
      TSysIlce(Table).SehirAdi.Value := edtsehir_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
