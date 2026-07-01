unit ufrmSetStkBarkodHazirlikDosyaTuru;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit, Ths.Erp.Helper.ComboBox, Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB, Vcl.Samples.Spin;

type
  TfrmSetStkBarkodHazirlikDosyaTuru = class(TfrmBaseInputDB)
    edtTur: TEdit;
    lblTur: TLabel;
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
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
  , Ths.Erp.Database.Table.SetStkBarkodHazirlikDosyaTuru
  ;

{$R *.dfm}

procedure TfrmSetStkBarkodHazirlikDosyaTuru.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtTur.Text := FormatedVariantVal(TSetStkBarkodHazirlikDosyaTuru(Table).Tur.DataType, TSetStkBarkodHazirlikDosyaTuru(Table).Tur.Value);
end;

procedure TfrmSetStkBarkodHazirlikDosyaTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetStkBarkodHazirlikDosyaTuru(Table).Tur.Value := edtTur.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
