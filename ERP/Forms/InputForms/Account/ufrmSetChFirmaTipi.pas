unit ufrmSetChFirmaTipi;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Database.Table.SetChFirmaTuru;

type
  TfrmSetChFirmaTipi = class(TfrmBaseInputDB)
    cbbfirma_turu_id: TComboBox;
    edtfirma_tipi: TEdit;
    lblfirma_tipi: TLabel;
    lblfirma_turu_id: TLabel;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormDestroy(Sender: TObject); override;
  private
    FFirmaTuru: TSetChFirmaTuru;
  public
  protected
  published
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SetChFirmaTipi;

{$R *.dfm}

procedure TfrmSetChFirmaTipi.FormCreate(Sender: TObject);
begin
  inherited;

  FFirmaTuru := TSetChFirmaTuru.Create(Table.Database);
  fillComboBoxData(cbbfirma_turu_id, FFirmaTuru, [FFirmaTuru.FirmaTuru.FieldName], '', True);
  cbbfirma_turu_id.ItemIndex := -1;
end;

procedure TfrmSetChFirmaTipi.FormDestroy(Sender: TObject);
begin
  if Assigned(FFirmaTuru) then
    FFirmaTuru.Free;

  inherited;
end;

procedure TfrmSetChFirmaTipi.RefreshData();
begin
  //control içeriðini table class ile doldur
  edtfirma_tipi.Text := TSetChFirmaTipi(Table).FirmaTipi.Value;
  cbbfirma_turu_id.ItemIndex := cbbfirma_turu_id.Items.IndexOf( FormatedVariantVal(TSetChFirmaTipi(Table).FirmaTuru.DataType, TSetChFirmaTipi(Table).FirmaTuru.Value) );
end;

procedure TfrmSetChFirmaTipi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChFirmaTipi(Table).FirmaTipi.Value := edtfirma_tipi.Text;
      TSetChFirmaTipi(Table).FirmaTuru.Value := cbbfirma_turu_id.Text;
      if Assigned(cbbfirma_turu_id.Items.Objects[cbbfirma_turu_id.ItemIndex]) then
        TSetChFirmaTipi(Table).FirmaTuruID.Value := TSetChFirmaTuru(cbbfirma_turu_id.Items.Objects[cbbfirma_turu_id.ItemIndex]).Id.Value;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
