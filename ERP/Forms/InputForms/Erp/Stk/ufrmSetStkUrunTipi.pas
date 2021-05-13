unit ufrmSetStkUrunTipi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils,
  Vcl.Menus, Vcl.AppEvnts, Vcl.Samples.Spin,
  Ths.Erp.Helper.Edit,
  ufrmBase, ufrmBaseInputDB;

type
  TfrmSetStkUrunTipi = class(TfrmBaseInputDB)
    lblurun_tipi: TLabel;
    edturun_tipi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Table.SetStkUrunTipi;

{$R *.dfm}

procedure TfrmSetStkUrunTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetStkUrunTipi(Table).UrunTipi.Value := edturun_tipi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetStkUrunTipi.RefreshData;
begin
  edturun_tipi.Text := FormatedVariantVal(TSetStkUrunTipi(Table).UrunTipi);
end;

end.
