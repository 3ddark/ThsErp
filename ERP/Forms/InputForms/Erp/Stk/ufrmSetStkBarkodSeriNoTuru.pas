unit ufrmSetStkBarkodSeriNoTuru;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts

  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  ;

type
  TfrmSetStkBarkodSeriNoTuru = class(TfrmBaseInputDB)
    edtAciklama: TEdit;
    edtTur: TEdit;
    lblAciklama: TLabel;
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
  , Ths.Erp.Database.Table.SetStkBarkodSeriNoTuru
  ;

{$R *.dfm}

procedure TfrmSetStkBarkodSeriNoTuru.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtTur.Text := FormatedVariantVal(TSetStkBarkodSeriNoTuru(Table).Tur.DataType, TSetStkBarkodSeriNoTuru(Table).Tur.Value);
  edtAciklama.Text := FormatedVariantVal(TSetStkBarkodSeriNoTuru(Table).Aciklama.DataType, TSetStkBarkodSeriNoTuru(Table).Aciklama.Value);
end;

procedure TfrmSetStkBarkodSeriNoTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetStkBarkodSeriNoTuru(Table).Tur.Value := edtTur.Text;
      TSetStkBarkodSeriNoTuru(Table).Aciklama.Value := edtAciklama.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
