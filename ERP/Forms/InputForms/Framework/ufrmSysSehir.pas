unit ufrmSysSehir;

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
  ufrmBaseInputDB,
  Ths.Erp.Globals,
  Ths.Erp.Database.Table;

type
  TfrmSysSehir = class(TfrmBaseInputDB)
    lblulke_adi_id: TLabel;
    lblsehir_adi: TLabel;
    lblplaka_kodu: TLabel;
    edtsehir_adi: TEdit;
    edtplaka_kodu: TEdit;
    edtulke_adi_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysUlke,
  ufrmSysUlkeler;

{$R *.dfm}

procedure TfrmSysSehir.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysSehir(Table).SehirAdi.Value := edtsehir_adi.Text;
      TSysSehir(Table).PlakaKodu.Value := edtplaka_kodu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysSehir.FormShow(Sender: TObject);
begin
  edtulke_adi_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysSehir.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysUlkeler;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtulke_adi_id.Name then
      begin
        LFrm := TfrmSysUlkeler.Create(TEdit(Sender), Self, TSysUlke.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysSehir(Table).UlkeAdiID.Value := 0;
            end
            else
            begin
              TSysSehir(Table).UlkeAdiID.Value := FormatedVariantVal(LFrm.Table.Id);
              TEdit(Sender).Text := FormatedVariantVal(TSysUlke(LFrm.Table).UlkeAdi);
            end;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysSehir.RefreshData;
begin
  inherited;
  //
end;

end.
