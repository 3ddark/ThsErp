unit ufrmSetEmpLanguageLevel;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.AppEvnts,
  Vcl.Samples.Spin, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  ufrmBase, ufrmBaseInputDB, Ths.Database.Table.SetPrsLisanSeviyeleri;

type
  TfrmSetEmpLanguageLevel = class(TfrmBaseInputDB)
    edtlisan_seviyesi: TEdit;
    lbllisan_seviyesi: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

procedure TfrmSetEmpLanguageLevel.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsLisanSeviyesi(Table).LisanSeviyesi.Value := edtlisan_seviyesi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.

