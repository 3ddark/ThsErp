unit ufrmSetPrsGecisSistemiKarti;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,

  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB;

type
  TfrmSetPrsGecisSistemiKarti = class(TfrmBaseInputDB)
    cbbkart_no: TComboBox;
    chkis_aktif: TCheckBox;
    edtkart_id: TEdit;
    edtpersonel_no: TEdit;
    lblis_aktif: TLabel;
    lblkart_id: TLabel;
    lblkart_no: TLabel;
    lblpersonel_no: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SetPrsGecisSistemiKarti;

{$R *.dfm}

procedure TfrmSetPrsGecisSistemiKarti.btnAcceptClick(Sender: TObject);
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
