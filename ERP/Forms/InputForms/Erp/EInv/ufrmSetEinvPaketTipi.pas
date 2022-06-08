unit ufrmSetEinvPaketTipi;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.DateUtils
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin

  , Data.DB
  , FireDAC.Comp.Client
  , Ths.Erp.Database.Singleton

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB

  , Ths.Erp.Constants
  ;

type
  TfrmSetEinvPaketTipi = class(TfrmBaseInputDB)
    lblpaket_adi: TLabel;
    lblis_active: TLabel;
    lblkod: TLabel;
    lblaciklama: TLabel;
    chkis_active: TCheckBox;
    edtkod: TEdit;
    edtpaket_adi: TEdit;
    edtaciklama: TEdit;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  end;

implementation

uses
  Ths.Erp.Database.Table.SetEinvPaketTipi;

{$R *.dfm}

procedure TfrmSetEinvPaketTipi.RefreshData();
begin
  chkis_active.Checked := TSetEinvPaketTipi(Table).IsAktif.Value;
  edtkod.Text := TSetEinvPaketTipi(Table).Kod.Value;
  edtpaket_adi.Text := TSetEinvPaketTipi(Table).PaketTipi.Value;
  edtaciklama.Text := TSetEinvPaketTipi(Table).Aciklama.Value;
end;

procedure TfrmSetEinvPaketTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvPaketTipi(Table).IsAktif.Value := chkis_active.Checked;
      TSetEinvPaketTipi(Table).Kod.Value := edtkod.Text;
      TSetEinvPaketTipi(Table).PaketTipi.Value := edtpaket_adi.Text;
      TSetEinvPaketTipi(Table).Aciklama.Value := edtaciklama.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
