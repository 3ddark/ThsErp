unit ufrmSysOlcuBirimiTipi;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSysOlcuBirimiTipi = class(TfrmBaseInputDB)
    lblunit_type: TLabel;
    edtunit_type: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  ufrmSysOlcuBirimiTipleri,
  Ths.Database.Table.SysOlcuBirimiTipleri;

{$R *.dfm}

procedure TfrmSysOlcuBirimiTipi.RefreshData;
begin
  edtunit_type.Text := TSysOlcuBirimiTipi(Table).OlcuBirimiTipi.AsString;
end;

procedure TfrmSysOlcuBirimiTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysOlcuBirimiTipi(Table).OlcuBirimiTipi.Value := edtunit_type.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
