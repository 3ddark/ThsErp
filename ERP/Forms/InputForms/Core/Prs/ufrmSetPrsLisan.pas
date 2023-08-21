unit ufrmSetPrsLisan;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.AppEvnts,
  Vcl.Samples.Spin, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  ufrmBase, ufrmBaseInputDB, Ths.Database.Table.SetPrsLisanlar;

type
  TfrmSetPrsLisan = class(TfrmBaseInputDB)
    edtlisan: TEdit;
    lbllisan: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

procedure TfrmSetPrsLisan.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsLisan(Table).Lisan.Value := edtlisan.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.

