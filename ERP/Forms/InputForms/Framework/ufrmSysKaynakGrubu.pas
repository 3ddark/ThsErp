unit ufrmSysKaynakGrubu;

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
  Ths.Erp.Database.Table.SysKaynakGrup;

type
  TfrmSysKaynakGrubu = class(TfrmBaseInputDB)
    edtkaynak_grup: TEdit;
    lblkaynak_grup: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData();override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysKaynakGrubu.RefreshData();
begin
  edtkaynak_grup.Text := TSysKaynakGrup(Table).KaynakGrup.Value;
end;

procedure TfrmSysKaynakGrubu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysKaynakGrup(Table).KaynakGrup.Value := edtkaynak_grup.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
