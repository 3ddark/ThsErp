unit ufrmSetBbkCalismaDurumu;

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
  TfrmSetBbkCalismaDurumu = class(TfrmBaseInputDB)
    lblcalisma_durumu: TLabel;
    edtcalisma_durumu: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetBbkCalismaDurumu
  ;

procedure TfrmSetBbkCalismaDurumu.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkCalismaDurumu(Table).CalismaDurumu.Value := edtcalisma_durumu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkCalismaDurumu.RefreshData;
begin
  edtcalisma_durumu.Text := FormatedVariantVal(TSetBbkCalismaDurumu(Table).CalismaDurumu);
end;

end.
