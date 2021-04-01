unit ufrmSetPrsPersonelTipi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, Vcl.Samples.Spin,

  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,

  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Globals,
  Ths.Erp.Database.Table.SetPrsPersonelTipi;

type
  TfrmSetPrsPersonelTipi = class(TfrmBaseInputDB)
    lblpersonel_tipi: TLabel;
    edtpersonel_tipi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSetPrsPersonelTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsPersonelTipi(Table).PersonelTipi.Value := edtpersonel_tipi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetPrsPersonelTipi.RefreshData;
begin
  edtpersonel_tipi.Text := FormatedVariantVal(TSetPrsPersonelTipi(Table).PersonelTipi);
end;

end.
