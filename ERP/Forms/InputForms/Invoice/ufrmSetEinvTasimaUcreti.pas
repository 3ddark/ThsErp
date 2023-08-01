unit ufrmSetEinvTasimaUcreti;

interface

{$I Ths.inc}

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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Constants;

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
  Ths.Database.Table.SetEinvTasimaUcreti;

{$R *.dfm}

procedure TfrmSetEinvTasimaUcreti.RefreshData();
begin
  edttasima_ucreti.Text := TSetEinvTasimaUcreti(Table).TasimaUcreti.Value;
  chkis_active.Checked := TSetEinvTasimaUcreti(Table).IsAktif.Value;
end;

procedure TfrmSetEinvTasimaUcreti.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvTasimaUcreti(Table).IsAktif.Value := chkis_active.Checked;
      TSetEinvTasimaUcreti(Table).TasimaUcreti.Value := edttasima_ucreti.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
