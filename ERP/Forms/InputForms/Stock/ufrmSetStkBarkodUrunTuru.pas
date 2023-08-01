unit ufrmSetStkBarkodUrunTuru;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit, Ths.Erp.Helper.ComboBox, Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB, Vcl.Samples.Spin;

type
  TfrmSetStkBarkodUrunTuru = class(TfrmBaseInputDB)
    edtTur: TEdit;
    lblTur: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SetStkBarkodUrunTuru
  ;

{$R *.dfm}

procedure TfrmSetStkBarkodUrunTuru.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtTur.Text := FormatedVariantVal(TSetStkBarkodUrunTuru(Table).Tur.DataType, TSetStkBarkodUrunTuru(Table).Tur.Value);
end;

procedure TfrmSetStkBarkodUrunTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetStkBarkodUrunTuru(Table).Tur.Value := edtTur.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
