unit ufrmSysOlcuBirimi;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysOlcuBirimleri;

type
  TfrmSysOlcuBirimi = class(TfrmBaseInputDB)
    lblunit: TLabel;
    edtunit: TEdit;
    lblunit_einv: TLabel;
    edtunit_einv: TEdit;
    lblexplanation: TLabel;
    edtexplanation: TEdit;
    lblis_decimal: TLabel;
    chkis_decimal: TCheckBox;
    lblunit_type_id: TLabel;
    edtunit_type_id: TEdit;
    lblmultiply: TLabel;
    edtmultiply: TEdit;
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
      TSysOlcuBirimi(Table).Birim.Value := edtunit.Text;
      TSysOlcuBirimi(Table).BirimEInv.Value := edtunit_einv.Text;
      TSysOlcuBirimi(Table).Aciklama.Value := edtexplanation.Text;
      TSysOlcuBirimi(Table).IsOndalik.Value := chkis_decimal.Checked;
      TSysOlcuBirimi(Table).BirimiTipiID.Value := edtunit_type_id.Text;
      TSysOlcuBirimi(Table).Carpan.Value := edtmultiply.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysOlcuBirimi.FormShow(Sender: TObject);
begin
  edtunit_type_id.OnHelperProcess := HelperProcess;
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
      if TEdit(Sender).Name = edtunit_type_id.Name then
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
  edtunit.Text := TSysOlcuBirimi(Table).Birim.AsString;
  edtunit_einv.Text := TSysOlcuBirimi(Table).BirimEInv.AsString;
  edtexplanation.Text := TSysOlcuBirimi(Table).Aciklama.AsString;
  chkis_decimal.Checked := TSysOlcuBirimi(Table).IsOndalik.AsBoolean;
  edtunit_type_id.Text := TSysOlcuBirimi(Table).BirimTipi.AsString;
  edtmultiply.Text := TSysOlcuBirimi(Table).Carpan.AsString;
end;

end.

