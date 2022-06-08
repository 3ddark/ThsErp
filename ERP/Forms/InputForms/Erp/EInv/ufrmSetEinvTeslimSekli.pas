unit ufrmSetEinvTeslimSekli;

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
  TfrmSetEinvTeslimSekli = class(TfrmBaseInputDB)
    lblis_active: TLabel;
    lblkod: TLabel;
    lblaciklama: TLabel;
    chkis_active: TCheckBox;
    edtkod: TEdit;
    edtaciklama: TEdit;
    chkis_efatura: TCheckBox;
    lblis_efatura: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  end;

implementation

uses
  Ths.Erp.Database.Table.SetEinvTeslimSekli;

{$R *.dfm}

procedure TfrmSetEinvTeslimSekli.RefreshData();
begin
  chkis_active.Checked := TSetEinvTeslimSekli(Table).IsAktif.Value;
  edtkod.Text := TSetEinvTeslimSekli(Table).TeslimSekli.Value;
  edtaciklama.Text := TSetEinvTeslimSekli(Table).Aciklama.Value;
  chkis_active.Checked := TSetEinvTeslimSekli(Table).IsEFatura.Value;
end;

procedure TfrmSetEinvTeslimSekli.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvTeslimSekli(Table).IsAktif.Value := chkis_active.Checked;
      TSetEinvTeslimSekli(Table).TeslimSekli.Value := edtkod.Text;
      TSetEinvTeslimSekli(Table).Aciklama.Value := edtaciklama.Text;
      TSetEinvTeslimSekli(Table).IsEFatura.Value := chkis_efatura.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
