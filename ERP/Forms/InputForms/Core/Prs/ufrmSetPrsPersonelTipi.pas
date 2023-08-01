unit ufrmSetPrsPersonelTipi;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSetPrsPersonelTipi = class(TfrmBaseInputDB)
    lblemployee_type: TLabel;
    edtemployee_type: TEdit;
  published
    procedure RefreshData; override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  ufrmSetPrsPersonelTipleri,
  Ths.Database.Table.SetPrsPersonelTipleri;

{$R *.dfm}

procedure TfrmSetPrsPersonelTipi.RefreshData;
begin
  edtemployee_type.Text := TSetPrsPersonelTipi(Table).PersonelTipi.AsString;
end;

procedure TfrmSetPrsPersonelTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsPersonelTipi(Table).PersonelTipi.Value := edtemployee_type.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
