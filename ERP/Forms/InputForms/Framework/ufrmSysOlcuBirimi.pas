unit ufrmSysOlcuBirimi;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
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
  Ths.Erp.Database.Table.SysOlcuBirimi;

type
  TfrmSysOlcuBirimi = class(TfrmBaseInputDB)
    lblolcu_birimi: TLabel;
    edtolcu_birimi: TEdit;
    lblolcu_birimi_einv: TLabel;
    edtolcu_birimi_einv: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblis_ondalik: TLabel;
    chkis_ondalik: TCheckBox;
    lblolcu_birimi_tipi_id: TLabel;
    edtolcu_birimi_tipi_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Database.Table.SysOlcuBirimiTipi,
  ufrmSysOlcuBirimiTipleri;

{$R *.dfm}

procedure TfrmSysOlcuBirimi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysOlcuBirimi(Table).OlcuBirimi.Value := edtolcu_birimi.Text;
      TSysOlcuBirimi(Table).OlcuBirimiEInv.Value := edtolcu_birimi_einv.Text;
      TSysOlcuBirimi(Table).Aciklama.Value := edtaciklama.Text;
      TSysOlcuBirimi(Table).IsOndalik.Value := chkis_ondalik.Checked;
      TSysOlcuBirimi(Table).OlcuBirimiTipi.Value := edtolcu_birimi_tipi_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysOlcuBirimi.FormShow(Sender: TObject);
begin
  edtolcu_birimi_tipi_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysOlcuBirimi.HelperProcess(Sender: TObject);
var
  LFrmBirimTipi: TfrmSysOlcuBirimiTipleri;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtolcu_birimi_tipi_id.Name then
      begin
        LFrmBirimTipi := TfrmSysOlcuBirimiTipleri.Create(TEdit(Sender), Self, TSysOlcuBirimiTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmBirimTipi.ShowModal;
          if LFrmBirimTipi.DataAktar then
          begin
            if LFrmBirimTipi.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysOlcuBirimi(Table).OlcuBirimiTipiID.Value := 0;
            end else begin
              TEdit(Sender).Text := TSysOlcuBirimiTipi(LFrmBirimTipi.Table).OlcuBirimiTipi.AsString;
              TSysOlcuBirimi(Table).OlcuBirimiTipiID.Value := LFrmBirimTipi.Table.Id.Value;
            end;
          end;
        finally
          LFrmBirimTipi.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmSysOlcuBirimi.RefreshData;
begin
  edtolcu_birimi.Text := TSysOlcuBirimi(Table).OlcuBirimi.AsString;
  edtolcu_birimi_einv.Text := TSysOlcuBirimi(Table).OlcuBirimiEInv.AsString;
  edtaciklama.Text := TSysOlcuBirimi(Table).Aciklama.AsString;
  chkis_ondalik.Checked := TSysOlcuBirimi(Table).IsOndalik.AsBoolean;
  edtolcu_birimi_tipi_id.Text := TSysOlcuBirimi(Table).OlcuBirimiTipi.AsString;
end;

end.
