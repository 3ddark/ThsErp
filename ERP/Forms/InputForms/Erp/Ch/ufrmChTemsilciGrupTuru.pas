unit ufrmChTemsilciGrupTuru;

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
  TfrmChTemsilciGrupTuru = class(TfrmBaseInputDB)
    edttemsilci_grup_turu: TEdit;
    lbltemsilci_grup_turu: TLabel;
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
  , Ths.Erp.Database.Table.ChTemsilciGrupTuru
  ;

{$R *.dfm}

procedure TfrmChTemsilciGrupTuru.RefreshData();
begin
  //control içeriðini table class ile doldur
  edttemsilci_grup_turu.Text := FormatedVariantVal(TChTemsilciGrupTuru(Table).TemsilciGrupTuru.DataType, TChTemsilciGrupTuru(Table).TemsilciGrupTuru.Value);
end;

procedure TfrmChTemsilciGrupTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChTemsilciGrupTuru(Table).TemsilciGrupTuru.Value := edttemsilci_grup_turu.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
