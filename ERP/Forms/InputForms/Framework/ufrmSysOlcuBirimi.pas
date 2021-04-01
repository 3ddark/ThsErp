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
  published
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysOlcuBirimi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
