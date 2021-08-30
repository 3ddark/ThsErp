unit ufrmSysMahalle;

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
  TfrmSysMahalle = class(TfrmBaseInputDB)
    lblmahalle_adi: TLabel;
    edtmahalle_adi: TEdit;
    lblposta_kodu: TLabel;
    edtposta_kodu: TEdit;
    lblsemt_id: TLabel;
    edtsemt_id: TEdit;
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
  ufrmSysMahalleler,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysMahalle,
  ufrmSysSemtler,
  Ths.Erp.Database.Table.SysSemt;

{$R *.dfm}

procedure TfrmSysMahalle.FormShow(Sender: TObject);
begin
  edtsemt_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysMahalle.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysSemtler;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtsemt_id.Name then
      begin
        LFrm := TfrmSysSemtler.Create(TEdit(Sender), Self, TSysSemt.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysMahalle(Table).SemtId.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := FormatedVariantVal(TSysSemt(LFrm.Table).SemtAdi);
              TSysMahalle(Table).SemtId.Value := FormatedVariantVal(LFrm.Table.Id);
            end;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysMahalle.RefreshData;
begin
  edtmahalle_adi.Text := VarToStr(FormatedVariantVal(TSysMahalle(Table).MahalleAdi));
  edtposta_kodu.Text := VarToStr(FormatedVariantVal(TSysMahalle(Table).PostaKodu));
  edtsemt_id.Text := VarToStr(FormatedVariantVal(TSysMahalle(Table).SemtAdi));
end;

procedure TfrmSysMahalle.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysMahalle(Table).MahalleAdi.Value := edtmahalle_adi.Text;
      TSysMahalle(Table).PostaKodu.Value := edtposta_kodu.Text;
      TSysMahalle(Table).SemtAdi.Value := edtsemt_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
