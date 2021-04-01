unit ufrmSetEinvTasimaUcreti;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Buttons,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Data.DB,
  FireDAC.Comp.Client,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Constants;

type
  TfrmSetEinvTasimaUcreti = class(TfrmBaseInputDB)
    edttasima_ucreti: TEdit;
    lbltasima_ucreti: TLabel;
    chkis_active: TCheckBox;
    lblis_active: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  end;

implementation

uses
  Ths.Erp.Database.Table.SetEinvTasimaUcreti;

{$R *.dfm}

procedure TfrmSetEinvTasimaUcreti.RefreshData();
begin
  edttasima_ucreti.Text := TSetEinvTasimaUcreti(Table).TasimaUcreti.Value;
  chkis_active.Checked := TSetEinvTasimaUcreti(Table).IsActive.Value;
end;

procedure TfrmSetEinvTasimaUcreti.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvTasimaUcreti(Table).IsActive.Value := chkis_active.Checked;
      TSetEinvTasimaUcreti(Table).TasimaUcreti.Value := edttasima_ucreti.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
