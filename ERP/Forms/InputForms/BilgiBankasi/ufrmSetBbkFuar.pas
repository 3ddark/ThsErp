unit ufrmSetBbkFuar;

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
  TfrmSetBbkFuar = class(TfrmBaseInputDB)
    lblfuar: TLabel;
    edtfuar: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetBbkFuar
  ;

procedure TfrmSetBbkFuar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkFuar(Table).Fuar.Value := edtfuar.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkFuar.FormCreate(Sender: TObject);
begin
  inherited;
  //edtfuar.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmSetBbkFuar.RefreshData;
begin
  edtfuar.Text := FormatedVariantVal(TSetBbkFuar(Table).Fuar);
end;

end.
