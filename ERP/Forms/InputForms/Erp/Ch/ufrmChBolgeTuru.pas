unit ufrmChBolgeTuru;

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
  TfrmChBolgeTuru = class(TfrmBaseInputDB)
    edtbolge_turu: TEdit;
    lblbolge_turu: TLabel;
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
  , Ths.Erp.Database.Table.ChBolgeTuru
  ;

{$R *.dfm}

procedure TfrmChBolgeTuru.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtbolge_turu.Text := FormatedVariantVal(TChBolgeTuru(Table).BolgeTuru.DataType, TChBolgeTuru(Table).BolgeTuru.Value);
end;

procedure TfrmChBolgeTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChBolgeTuru(Table).BolgeTuru.Value := edtbolge_turu.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
