unit ufrmSetBbkKayitTipi;

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
  TfrmSetBbkKayitTipi = class(TfrmBaseInputDB)
    lblkayit_tipi: TLabel;
    edtkayit_tipi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetBbkKayitTipi
  ;

procedure TfrmSetBbkKayitTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkKayitTipi(Table).KayitTipi.Value := edtkayit_tipi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkKayitTipi.FormCreate(Sender: TObject);
begin
  inherited;
  //edtfuar.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmSetBbkKayitTipi.RefreshData;
begin
  edtkayit_tipi.Text := FormatedVariantVal(TSetBbkKayitTipi(Table).KayitTipi);
end;

end.
