unit ufrmSetBbkBolge;

interface

{$I ThsERP.inc}

uses
    Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , Dialogs
  , StdCtrls
  , ExtCtrls
  , ComCtrls
  , StrUtils
  , DateUtils
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin
  , Vcl.ExtDlgs

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  ;

type
  TfrmSetBbkBolge = class(TfrmBaseInputDB)
    lblbolge: TLabel;
    edtbolge: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetBbkBolge
  ;

procedure TfrmSetBbkBolge.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkBolge(Table).Bolge.Value := edtbolge.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkBolge.RefreshData;
begin
  edtbolge.Text := FormatedVariantVal(TSetBbkBolge(Table).Bolge);
end;

end.
