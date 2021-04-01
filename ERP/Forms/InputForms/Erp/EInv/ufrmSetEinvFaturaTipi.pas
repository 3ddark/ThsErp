unit ufrmSetEinvFaturaTipi;

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
  TfrmSetEinvFaturaTipi = class(TfrmBaseInputDB)
    edtTip: TEdit;
    lblTip: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  end;

implementation

uses
  Ths.Erp.Database.Table.SetEInvFaturaTipi;

{$R *.dfm}

procedure TfrmSetEinvFaturaTipi.RefreshData();
begin
  edtTip.Text := TSetEinvFaturaTipi(Table).FaturaTipi.Value;
end;

procedure TfrmSetEinvFaturaTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetEinvFaturaTipi(Table).FaturaTipi.Value := edtTip.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
