unit ufrmSysSemt;

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
  TfrmSysSemt = class(TfrmBaseInputDB)
    lblsemt_adi: TLabel;
    edtsemt_adi: TEdit;
    lblilce_id: TLabel;
    edtilce_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  ufrmSysSemtler,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysSemt,
  Ths.Erp.Database.Table.SysIlce,
  ufrmSysIlceler;

{$R *.dfm}

procedure TfrmSysSemt.FormShow(Sender: TObject);
begin
  edtilce_id.OnHelperProcess := HelperProcess;

  inherited;
end;

procedure TfrmSysSemt.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysIlceler;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtilce_id.Name then
      begin
        LFrm := TfrmSysIlceler.Create(TEdit(Sender), Self, TSysIlce.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysSemt(Table).IlceId.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := FormatedVariantVal(TSysIlce(LFrm.Table).IlceAdi);
              TSysSemt(Table).IlceId.Value := FormatedVariantVal(LFrm.Table.Id);
            end;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysSemt.RefreshData;
begin
  edtsemt_adi.Text := VarToStr(FormatedVariantVal(TSysSemt(Table).SemtAdi));
  edtilce_id.Text := VarToStr(FormatedVariantVal(TSysSemt(Table).IlceAdi));
end;

procedure TfrmSysSemt.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysSemt(Table).SemtAdi.Value := edtsemt_adi.Text;
      TSysSemt(Table).IlceAdi.Value := edtilce_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
