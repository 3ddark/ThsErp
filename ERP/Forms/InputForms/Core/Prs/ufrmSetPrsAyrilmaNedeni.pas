unit ufrmSetPrsAyrilmaNedeni;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,
  Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,

  ufrmBase, ufrmBaseInputDB;

type
  TfrmSetPrsAyrilmaNedeni = class(TfrmBaseInputDB)
    edtayrilma_nedeni: TEdit;
    lblayrilma_nedeni: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table.SetPrsAyrilmaNedenleri;

{$R *.dfm}

procedure TfrmSetPrsAyrilmaNedeni.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
