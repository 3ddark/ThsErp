unit ufrmSetPrsAyrilmaTipi;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, Vcl.Samples.Spin,

  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,

  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetPrsAyrilmaTipi = class(TfrmBaseInputDB)
    edtayrilma_tipi: TEdit;
    lblayrilma_tipi: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

procedure TfrmSetPrsAyrilmaTipi.btnAcceptClick(Sender: TObject);
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
