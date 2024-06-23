unit ufrmChBanka;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo, ufrmBase,
  ufrmBaseInputDB;

type
  TfrmChBanka = class(TfrmBaseInputDB)
    lblbanka_adi: TLabel;
    edtbanka_adi: TEdit;
    lblswift_kodu: TLabel;
    edtswift_kodu: TEdit;
  published
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.ChBankalar;

{$R *.dfm}

procedure TfrmChBanka.RefreshData();
begin
  edtbanka_adi.Text := TChBanka(Table).BankaAdi.AsString;
  edtswift_kodu.Text := TChBanka(Table).SwiftKodu.AsString;
end;

procedure TfrmChBanka.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChBanka(Table).BankaAdi.Value := edtbanka_adi.Text;
      TChBanka(Table).SwiftKodu.Value := edtswift_kodu.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.

