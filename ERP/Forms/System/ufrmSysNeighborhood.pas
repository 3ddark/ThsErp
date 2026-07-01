unit ufrmSysNeighborhood;

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
  Ths.Globals,
  ufrmSysMahalleler,
  Ths.Database.Table.SysNeighborhood,
  ufrmSysSemtler,
  Ths.Database.Table.SysLocality;

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
        LFrm := TfrmSysSemtler.Create(TEdit(Sender), Self, TSysLocality.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysNeighborhood(Table).LocalityID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := FormatedVariantVal(TSysLocality(LFrm.Table).Locality);
              TSysNeighborhood(Table).LocalityID.Value := FormatedVariantVal(LFrm.Table.Id);
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
  edtmahalle_adi.Text := TSysNeighborhood(Table).Neighborhood.AsString;
  edtposta_kodu.Text := TSysNeighborhood(Table).PostalCode.AsString;
  edtsemt_id.Text := TSysNeighborhood(Table).Locality.AsString;
end;

procedure TfrmSysMahalle.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysNeighborhood(Table).Neighborhood.Value := edtmahalle_adi.Text;
      TSysNeighborhood(Table).PostalCode.Value := edtposta_kodu.Text;
      TSysNeighborhood(Table).Locality.Value := edtsemt_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
