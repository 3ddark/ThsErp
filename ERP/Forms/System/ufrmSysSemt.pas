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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
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
  Ths.Globals,
  ufrmSysSemtler,
  Ths.Database.Table.SysLocality,
  Ths.Database.Table.SysDistrict,
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
        LFrm := TfrmSysIlceler.Create(TEdit(Sender), Self, TSysDistrict.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysLocality(Table).DistrictID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := FormatedVariantVal(TSysDistrict(LFrm.Table).District);
              TSysLocality(Table).DistrictID.Value := FormatedVariantVal(LFrm.Table.Id);
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
  edtsemt_adi.Text := VarToStr(FormatedVariantVal(TSysLocality(Table).Locality));
  edtilce_id.Text := VarToStr(FormatedVariantVal(TSysLocality(Table).District));
end;

procedure TfrmSysSemt.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysLocality(Table).Locality.Value := edtsemt_adi.Text;
      TSysLocality(Table).District.Value := edtilce_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
