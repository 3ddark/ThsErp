unit ufrmSetRctIscilikGiderTipi;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetRctIscilikGiderTipi = class(TfrmBaseInputDB)
    edtgider_tipi: TEdit;
    lblgider_tipi: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SetRctIscilikGiderTipi;

{$R *.dfm}

procedure TfrmSetRctIscilikGiderTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetRctIscilikGiderTipi(Table).GiderTipi.Value := edtgider_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetRctIscilikGiderTipi.RefreshData;
begin
  edtgider_tipi.Text := FormatedVariantVal(TSetRctIscilikGiderTipi(Table).GiderTipi);
end;

end.
