unit ufrmSysMukellefTipi;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SysOlcuBirimiTipleri;

type
  TfrmSysMukellefTipi = class(TfrmBaseInputDB)
    lbltaxpayer_type: TLabel;
    edttaxpayer_type: TEdit;
    lblis_default: TLabel;
    chkis_default: TCheckBox;
  published
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

uses Ths.Database.Table.SysVergiMukellefTipleri;

{$R *.dfm}

procedure TfrmSysMukellefTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysVergiMukellefTipi(Table).MukellefTipi.Value := edttaxpayer_type.Text;
      TSysVergiMukellefTipi(Table).IsVarsayilan.Value := chkis_default.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
