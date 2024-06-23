unit ufrmSetPrsTasimaServisi;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.AppEvnts,
  System.ImageList, Vcl.ImgList, Vcl.Samples.Spin, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo, ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetPrsTasimaServisi = class(TfrmBaseInputDB)
    lblarac_no: TLabel;
    edtarac_no: TEdit;
    lblarac_adi: TLabel;
    edtarac_adi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Database.Table.SetPrsTasimaServisleri;

{$R *.dfm}

procedure TfrmSetPrsTasimaServisi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsTasimaServisi(Table).AracNo.Value := edtarac_no.Text;
      TSetPrsTasimaServisi(Table).AracAdi.Value := edtarac_adi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetPrsTasimaServisi.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetPrsTasimaServisi.RefreshData;
begin
  edtarac_no.Text := TSetPrsTasimaServisi(Table).AracNo.Value;
  edtarac_adi.Text := TSetPrsTasimaServisi(Table).AracAdi.Value;
end;

end.

