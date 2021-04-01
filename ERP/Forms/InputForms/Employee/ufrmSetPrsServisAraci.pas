unit ufrmSetPrsServisAraci;

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
  TfrmSetPrsServisAraci = class(TfrmBaseInputDB)
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
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SetPrsServisAraci;

{$R *.dfm}

procedure TfrmSetPrsServisAraci.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsServisAraci(Table).AracNo.Value := edtarac_no.Text;
      TSetPrsServisAraci(Table).AracAdi.Value := edtarac_adi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetPrsServisAraci.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetPrsServisAraci.RefreshData;
begin
  edtarac_no.Text := TSetPrsServisAraci(Table).AracNo.Value;
  edtarac_adi.Text := TSetPrsServisAraci(Table).AracAdi.Value;
end;

end.
