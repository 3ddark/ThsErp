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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
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
  Ths.Globals,
  ufrmSysIlceler,
  Ths.Database.Table.SysDistrict,
  Ths.Database.Table.SysCity,
  ufrmSysCities;

{$R *.dfm}

procedure TfrmSysIlce.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysCities;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtsehir_id.Name then
      begin
        LFrm := TfrmSysCities.Create(TEdit(Sender), Self, TSysCity.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysDistrict(Table).CityID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := FormatedVariantVal(TSysCity(LFrm.Table).City);
              TSysDistrict(Table).CityID.Value := FormatedVariantVal(LFrm.Table.Id);
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
  edtilce_adi.Text := VarToStr(FormatedVariantVal(TSysDistrict(Table).District));
  edtsehir_id.Text := VarToStr(FormatedVariantVal(TSysDistrict(Table).City));
end;

procedure TfrmSysIlce.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysDistrict(Table).District.Value := edtilce_adi.Text;
      TSysDistrict(Table).City.Value := edtsehir_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
