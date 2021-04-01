unit ufrmSetEinvOdemeSekli;

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
  TfrmSetEinvOdemeSekli = class(TfrmBaseInputDB)
    lblis_active: TLabel;
    chkis_active: TCheckBox;
    lblodeme_sekli: TLabel;
    edtodeme_sekli: TEdit;
    lblkod: TLabel;
    edtkod: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblis_efatura: TLabel;
    chkis_efatura: TCheckBox;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  end;

implementation

uses
  Ths.Erp.Database.Table.SetEinvOdemeSekli;

{$R *.dfm}

procedure TfrmSetEinvOdemeSekli.RefreshData();
begin
  chkis_active.Checked := TSetEinvOdemeSekli(Table).IsActive.Value;
  edtodeme_sekli.Text := TSetEinvOdemeSekli(Table).OdemeSekli.Value;
  edtkod.Text := TSetEinvOdemeSekli(Table).Kod.Value;
  edtaciklama.Text := TSetEinvOdemeSekli(Table).Aciklama.Value;
  chkis_efatura.Checked := TSetEinvOdemeSekli(Table).IsEFatura.Value;
end;

procedure TfrmSetEinvOdemeSekli.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvOdemeSekli(Table).IsActive.Value := chkis_active.Checked;
      TSetEinvOdemeSekli(Table).OdemeSekli.Value := edtodeme_sekli.Text;
      TSetEinvOdemeSekli(Table).Kod.Value := edtkod.Text;
      TSetEinvOdemeSekli(Table).Aciklama.Value := edtaciklama.Text;
      TSetEinvOdemeSekli(Table).IsEFatura.Value := chkis_efatura.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
