unit ufrmSetChHesapTipi;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.Samples.Spin, Vcl.AppEvnts, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSetChHesapTipi = class(TfrmBaseInputDB)
    edthesap_tipi: TEdit;
    lblhesap_tipi: TLabel;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SetChHesapTipi;

{$R *.dfm}

procedure TfrmSetChHesapTipi.RefreshData();
begin
  edthesap_tipi.Text := TSetChHesapTipi(Table).HesapTipi.AsString;
end;

procedure TfrmSetChHesapTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChHesapTipi(Table).HesapTipi.Value := edthesap_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
