unit ufrmSetStkBarkodTezgah;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, Vcl.Samples.Spin
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  , Ths.Erp.Database.Table.StkStokAmbar
  ;

type
  TfrmSetStkBarkodTezgah = class(TfrmBaseInputDB)
    cbbAmbar: TComboBox;
    edtTezgahAdi: TEdit;
    lblAmbar: TLabel;
    lblTezgahAdi: TLabel;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
  private
    vAmbar: TStkStokAmbar;
  published
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SetStkBarkodTezgah
  ;

{$R *.dfm}

procedure TfrmSetStkBarkodTezgah.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  vAmbar := TStkStokAmbar.Create(Table.Database);
  vAmbar.SelectToList('', False, False);
  cbbAmbar.Clear;
  for n1 := 0 to vAmbar.List.Count-1 do
    cbbAmbar.AddItem( TStkStokAmbar(vAmbar.List[n1]).AmbarAdi.Value, TStkStokAmbar(vAmbar.List[n1]) );
  cbbAmbar.ItemIndex := -1;
end;

procedure TfrmSetStkBarkodTezgah.FormDestroy(Sender: TObject);
begin
  vAmbar.Free;

  inherited;
end;

procedure TfrmSetStkBarkodTezgah.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtTezgahAdi.Text := FormatedVariantVal(TAyarBarkodTezgah(Table).TezgahAdi.DataType, TAyarBarkodTezgah(Table).TezgahAdi.Value);
  cbbAmbar.ItemIndex := cbbAmbar.Items.IndexOf( FormatedVariantVal(TAyarBarkodTezgah(Table).Ambar.DataType, TAyarBarkodTezgah(Table).Ambar.Value) );
end;

procedure TfrmSetStkBarkodTezgah.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TAyarBarkodTezgah(Table).TezgahAdi.Value := edtTezgahAdi.Text;
      TAyarBarkodTezgah(Table).Ambar.Value := cbbAmbar.Text;
      if Assigned( TStkStokAmbar(cbbAmbar.Items.Objects[cbbAmbar.ItemIndex]) ) then
        TAyarBarkodTezgah(Table).AmbarID.Value := TStkStokAmbar(cbbAmbar.Items.Objects[cbbAmbar.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
