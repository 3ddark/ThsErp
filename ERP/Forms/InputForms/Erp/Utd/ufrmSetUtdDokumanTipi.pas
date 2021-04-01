unit ufrmSetUtdDokumanTipi;

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
  TfrmSetUtdDokumanTipi = class(TfrmBaseInputDB)
    lblalt_klasor: TLabel;
    lbldokuman_tipi: TLabel;
    edtdokuman_tipi: TEdit;
    edtalt_klasor: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetUtdDokumanTipi
  ;

procedure TfrmSetUtdDokumanTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetUtdDokumanTipi(Table).DokumanTipi.Value := edtdokuman_tipi.Text;
      TSetUtdDokumanTipi(Table).AltKlasor.Value := edtalt_klasor.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetUtdDokumanTipi.FormCreate(Sender: TObject);
begin
  inherited;
  edtalt_klasor.CharCase := TEditCharCase.ecNormal;
end;

procedure TfrmSetUtdDokumanTipi.RefreshData;
begin
  edtdokuman_tipi.Text := FormatedVariantVal(TSetUtdDokumanTipi(Table).DokumanTipi);
  edtalt_klasor.Text := FormatedVariantVal(TSetUtdDokumanTipi(Table).AltKlasor);
end;

end.
