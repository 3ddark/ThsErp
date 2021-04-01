unit ufrmSysKaliteFormNo;

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
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKaliteFormNo,
  ufrmSysTables,
  Ths.Erp.Database.Table.View.SysViewTables,
  ufrmSysKaliteFormTipleri,
  Ths.Erp.Database.Table.SysKaliteFormTipi;

type
  TfrmSysKaliteFormNo = class(TfrmBaseInputDB)
    lbltablo_adi: TLabel;
    edttablo_adi: TEdit;
    lblform_no: TLabel;
    edtform_no: TEdit;
    lblform_tipi_id: TLabel;
    edtform_tipi_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysKaliteFormNo.FormCreate(Sender: TObject);
begin
  edttablo_adi.OnHelperProcess := HelperProcess;
  edtform_tipi_id.OnHelperProcess := HelperProcess;

  inherited;

  edttablo_adi.CharCase := ecNormal;
  edtform_no.CharCase := ecNormal;
end;

procedure TfrmSysKaliteFormNo.HelperProcess(Sender: TObject);
var
  LFrmTables: TfrmSysTables;
  LFrmForms: TfrmSysKaliteFormTipleri;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edttablo_adi.Name then
      begin
        LFrmTables := TfrmSysTables.Create(TEdit(Sender), Self, TSysViewTables.Create(Table.Database), fomNormal, True);
        try
          LFrmTables.ShowModal;
          if LFrmTables.DataAktar then
          begin
            TSysQualityFormNumber(Table).TabloAdi.Value := TSysViewTables(LFrmTables.Table).TableName1.Value;
            TEdit(Sender).Text := TSysQualityFormNumber(Table).TabloAdi.Value;
          end;
        finally
          LFrmTables.Free;
        end;
      end
      else if TEdit(Sender).Name = edtform_tipi_id.Name then
      begin
        LFrmForms := TfrmSysKaliteFormTipleri.Create(TEdit(Sender), Self, TSysKaliteFormTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmForms.ShowModal;
          if LFrmForms.DataAktar then
          begin
            TSysQualityFormNumber(Table).FormTipiID.Value := TSysKaliteFormTipi(LFrmForms.Table).Id.Value;
            TEdit(Sender).Text := TSysKaliteFormTipi(LFrmForms.Table).FormTipi.Value;
          end;
        finally
          LFrmForms.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSysKaliteFormNo.RefreshData();
begin
  edttablo_adi.Text := TSysQualityFormNumber(Table).TabloAdi.Value;
  edtform_no.Text := TSysQualityFormNumber(Table).FormNo.Value;
  edtform_tipi_id.Text := TSysQualityFormNumber(Table).FormTipi.Value;
end;

procedure TfrmSysKaliteFormNo.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysQualityFormNumber(Table).TabloAdi.Value := edttablo_adi.Text;
      TSysQualityFormNumber(Table).FormNo.Value := edtform_no.Text;
      //form_type_id data take from helper form
      inherited;
    end;
  end
  else
    inherited;
end;

end.
