unit ufrmBbkFuarKatilim;

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
  TfrmBbkFuarKatilim = class(TfrmBaseInputDB)
    lblkayit_id: TLabel;
    edtkayit_id: TEdit;
    edtfuar_id: TEdit;
    lblfuar_id: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.BbkFuarKatilim
  ;

procedure TfrmBbkFuarKatilim.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TBbkFuarKatilim(Table).KayitID.Value := edtkayit_id.Text;
      TBbkFuarKatilim(Table).FuarID.Value := edtfuar_id.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmBbkFuarKatilim.FormCreate(Sender: TObject);
begin
  inherited;
  //edtfuar.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmBbkFuarKatilim.RefreshData;
begin
  edtkayit_id.Text := FormatedVariantVal(TBbkFuarKatilim(Table).KayitID);
  edtfuar_id.Text := FormatedVariantVal(TBbkFuarKatilim(Table).FuarID);
end;

end.
