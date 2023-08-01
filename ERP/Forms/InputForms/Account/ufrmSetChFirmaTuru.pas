unit ufrmSetChFirmaTuru;

interface

{$I Ths.inc}

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
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetChFirmaTuru = class(TfrmBaseInputDB)
    edtfirma_turu: TEdit;
    lblfirma_turu: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
  end;

implementation

uses
  Ths.Database.Table.SetChFirmaTuru;

{$R *.dfm}

procedure TfrmSetChFirmaTuru.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtfirma_turu.Text := TSetChFirmaTuru(Table).FirmaTuru.Value;
end;

procedure TfrmSetChFirmaTuru.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChFirmaTuru(Table).FirmaTuru.Value := edtfirma_turu.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
