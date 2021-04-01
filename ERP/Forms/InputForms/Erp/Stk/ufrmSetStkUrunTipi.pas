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
    chkis_hammadde: TCheckBox;
    lblis_hammadde: TLabel;
    chkis_yari_mamul: TCheckBox;
    lblis_yari_mamul: TLabel;
    chkis_mamul: TCheckBox;
    lblis_mamul: TLabel;
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
      TSetStkUrunTipi(Table).IsHammadde.Value := chkis_hammadde.Checked;
      TSetStkUrunTipi(Table).IsYariMamul.Value := chkis_yari_mamul.Checked;
      TSetStkUrunTipi(Table).IsMamul.Value := chkis_mamul.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetStkUrunTipi.RefreshData;
begin
  edturun_tipi.Text := FormatedVariantVal(TSetStkUrunTipi(Table).UrunTipi);
  chkis_hammadde.Checked := TSetStkUrunTipi(Table).IsHammadde.Value;
  chkis_yari_mamul.Checked := TSetStkUrunTipi(Table).IsYariMamul.Value;
  chkis_mamul.Checked := TSetStkUrunTipi(Table).IsMamul.Value;
end;

end.
