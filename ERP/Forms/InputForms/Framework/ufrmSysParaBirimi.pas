unit ufrmSysParaBirimi;

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
  Ths.Erp.Database.Table.SysParaBirimi;

type
  TfrmSysParaBirimi = class(TfrmBaseInputDB)
    lblpara_birimi: TLabel;
    edtpara_birimi: TEdit;
    lblsembol: TLabel;
    edtsembol: TEdit;
    lblis_varsayilan: TLabel;
    chkis_varsayilan: TCheckBox;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysParaBirimi.btnAcceptClick(Sender: TObject);
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
