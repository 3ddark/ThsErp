unit ufrmSysOlcuBirimi;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysOlcuBirimleri;

type
  TfrmSysOlcuBirimi = class(TfrmBaseInputDB)
    lblbirim: TLabel;
    edtbirim: TEdit;
    lblbirim_einv: TLabel;
    edtbirim_einv: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblis_ondalik: TLabel;
    chkis_ondalik: TCheckBox;
    lblbirim_tipi_id: TLabel;
    edtbirim_tipi_id: TEdit;
    lblcarpan: TLabel;
    edtcarpan: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Database.Table.SysOlcuBirimiTipleri, ufrmSysOlcuBirimiTipleri;

{$R *.dfm}

procedure TfrmSysOlcuBirimi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysOlcuBirimi(Table).Birim.Value := edtbirim.Text;
      TSysOlcuBirimi(Table).BirimEInv.Value := edtbirim_einv.Text;
      TSysOlcuBirimi(Table).Aciklama.Value := edtaciklama.Text;
      TSysOlcuBirimi(Table).IsOndalik.Value := chkis_ondalik.Checked;
      TSysOlcuBirimi(Table).Carpan.Value := edtcarpan.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysOlcuBirimi.FormShow(Sender: TObject);
begin
  edtbirim_tipi_id.OnHelperProcess := HelperProcess;
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
      if TEdit(Sender).Name = edtbirim_tipi_id.Name then
      begin
        LFrmBirimTipi := TfrmSysOlcuBirimiTipleri.Create(TEdit(Sender), Self, TSysOlcuBirimiTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmBirimTipi.ShowModal;
          if LFrmBirimTipi.DataAktar then
          begin
            if LFrmBirimTipi.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysOlcuBirimi(Table).BirimiTipiID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSysOlcuBirimiTipi(LFrmBirimTipi.Table).OlcuBirimiTipi.AsString;
              TSysOlcuBirimi(Table).BirimiTipiID.Value := LFrmBirimTipi.Table.Id.Value;
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
  edtbirim.Text := TSysOlcuBirimi(Table).Birim.AsString;
  edtbirim_einv.Text := TSysOlcuBirimi(Table).BirimEInv.AsString;
  edtaciklama.Text := TSysOlcuBirimi(Table).Aciklama.AsString;
  chkis_ondalik.Checked := TSysOlcuBirimi(Table).IsOndalik.AsBoolean;
  edtbirim_tipi_id.Text := TSysOlcuBirimi(Table).BirimTipi.AsString;
  edtcarpan.Text := TSysOlcuBirimi(Table).Carpan.AsString;
end;

end.

