unit ufrmStkCinsAilesi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit, Ths.Erp.Helper.ComboBox, Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB, Vcl.Menus, Vcl.Samples.Spin;

type
  TfrmStkCinsAilesi = class(TfrmBaseInputDB)
    edtaile: TEdit;
    lblaile: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.StkCinsAilesi,
  Ths.Erp.Globals;

{$R *.dfm}

procedure TfrmStkCinsAilesi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkCinsAilesi(Table).Aile.Value := edtAile.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkCinsAilesi.RefreshData;
begin
  edtAile.Text := VarToStr(FormatedVariantVal(TStkCinsAilesi(Table).Aile));
end;

end.
