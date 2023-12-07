unit ufrmSysOlcuBirimiTipi;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSysOlcuBirimiTipi = class(TfrmBaseInputDB)
    lblolcu_birimi_tipi: TLabel;
    edtolcu_birimi_tipi: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.SysOlcuBirimiTipleri;

{$R *.dfm}

procedure TfrmSysOlcuBirimiTipi.RefreshData;
begin
  edtolcu_birimi_tipi.Text := TSysOlcuBirimiTipi(Table).OlcuBirimiTipi.AsString;
end;

procedure TfrmSysOlcuBirimiTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysOlcuBirimiTipi(Table).OlcuBirimiTipi.Value := edtolcu_birimi_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.

