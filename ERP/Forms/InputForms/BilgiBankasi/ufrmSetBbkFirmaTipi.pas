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
  , Vcl.ExtDlgs

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB

  , Ths.Erp.Database.Table.SetBbkKayitTipi
  ;

type
  TfrmSetBbkFirmaTipi = class(TfrmBaseInputDB)
    lblfirma_tipi: TLabel;
    edtfirma_tipi: TEdit;
    lblkayit_tipi_id: TLabel;
    cbbkayit_tipi_id: TComboBox;
  private
    FKayitTipi: TSetBbkKayitTipi;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetBbkFirmaTipi
  ;

procedure TfrmSetBbkFirmaTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetBbkFirmaTipi(Table).FirmaTipi.Value := edtfirma_tipi.Text;
      if (cbbkayit_tipi_id.ItemIndex > -1) and ((cbbkayit_tipi_id.Items.Objects[cbbkayit_tipi_id.ItemIndex]) <> nil) then
        TSetBbkFirmaTipi(Table).KayitTipiID.Value := TSetBbkKayitTipi(cbbkayit_tipi_id.Items.Objects[cbbkayit_tipi_id.ItemIndex]).Id.Value;
      TSetBbkFirmaTipi(Table).KayitTipi.Value := cbbkayit_tipi_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetBbkFirmaTipi.FormCreate(Sender: TObject);
begin
  inherited;

  FKayitTipi := TSetBbkKayitTipi.Create(GDataBase);
  fillComboBoxData(cbbkayit_tipi_id, FKayitTipi, [FKayitTipi.KayitTipi.FieldName], '', True);
end;

procedure TfrmSetBbkFirmaTipi.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FKayitTipi);
  inherited;
end;

procedure TfrmSetBbkFirmaTipi.RefreshData;
begin
  edtfirma_tipi.Text := FormatedVariantVal(TSetBbkFirmaTipi(Table).FirmaTipi);
  cbbkayit_tipi_id.ItemIndex := cbbkayit_tipi_id.Items.IndexOf(FormatedVariantVal(TSetBbkFirmaTipi(Table).KayitTipi));
end;

end.
