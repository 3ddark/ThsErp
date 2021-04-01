unit ufrmSetChHesapTipi;

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
  TfrmSetChHesapTipi = class(TfrmBaseInputDB)
    edtDeger: TEdit;
    lblDeger: TLabel;
    chkis_ana_hesap: TCheckBox;
    lblis_ana_hesap: TLabel;
    chkis_ara_hesap: TCheckBox;
    lblis_ara_hesap: TLabel;
    chkis_son_hesap: TCheckBox;
    lblis_son_hesap: TLabel;
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
  , Ths.Erp.Database.Table.SetChHesapTipi
  ;

{$R *.dfm}

procedure TfrmSetChHesapTipi.RefreshData();
begin
  edtDeger.Text := FormatedVariantVal(TSetChHesapTipi(Table).HesapTipi.DataType, TSetChHesapTipi(Table).HesapTipi.Value);
  chkis_ana_hesap.Checked := FormatedVariantVal(TSetChHesapTipi(Table).IsAnaHesap.DataType, TSetChHesapTipi(Table).IsAnaHesap.Value);
  chkis_ara_hesap.Checked := FormatedVariantVal(TSetChHesapTipi(Table).IsAraHesap.DataType, TSetChHesapTipi(Table).IsAraHesap.Value);
  chkis_son_hesap.Checked := FormatedVariantVal(TSetChHesapTipi(Table).IsSonHesap.DataType, TSetChHesapTipi(Table).IsSonHesap.Value);
end;

procedure TfrmSetChHesapTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChHesapTipi(Table).HesapTipi.Value := edtDeger.Text;
      TSetChHesapTipi(Table).IsAnaHesap.Value := chkis_ana_hesap.Checked;
      TSetChHesapTipi(Table).IsAraHesap.Value := chkis_ara_hesap.Checked;
      TSetChHesapTipi(Table).IsSonHesap.Value := chkis_son_hesap.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
