unit ufrmSetBbkFirmaTipi;

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
  , Vcl.ExtDlgs,

  FireDAC.Comp.Client,

  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,

  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetBbkFirmaTipi = class(TfrmBaseInputDB)
    lblfirma_tipi: TLabel;
    edtfirma_tipi: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Table.SetBbkFirmaTipi;

procedure TfrmSetBbkFirmaTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkFirmaTipi(Table).FirmaTipi.Value := edtfirma_tipi.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkFirmaTipi.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetBbkFirmaTipi.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetBbkFirmaTipi.RefreshData;
begin
  edtfirma_tipi.Text := FormatedVariantVal(TSetBbkFirmaTipi(Table).FirmaTipi);
end;

end.
