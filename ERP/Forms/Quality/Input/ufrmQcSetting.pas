unit ufrmQcSetting;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  QcSetting.Service, QcSetting;

type
  // Firma kalite kontrol ayarı (tek kayıt, dashboard'dan doğrudan açılır): modül açık / kapalı, red (karantina) ambarı.
  // Kapalıyken mal kabul / stok / fatura akışı kontrol adımı olmadan aynen çalışır.
  TfrmQcSetting = class(TfrmInputSimpleDB<TQcSetting, TQcSettingService>)
    pnlContent: TPanel;
    lblCompanyTitle: TLabel;
    edtCompanyTitle: TEdit;
    chkIsEnabled: TCheckBox;
    lblRejectStkWarehouseId: TLabel;
    edtRejectStkWarehouseId: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses;  // TfrmStkWarehouses helper output form

procedure TfrmQcSetting.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; firma servisten
  Table.IsEnabled := chkIsEnabled.Checked;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmQcSetting.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtRejectStkWarehouseId.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmQcSetting.FormShow(Sender: TObject);
begin
  inherited;
  if chkIsEnabled.CanFocus then
    chkIsEnabled.SetFocus;
end;

procedure TfrmQcSetting.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.TitleSingular, 'Quality Control Settings');
  lblCompanyTitle.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.ColCompanyTitle, 'Company');
  chkIsEnabled.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.ColIsEnabled, 'Incoming quality control enabled');
  lblRejectStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.ColRejectStkWarehouseId, 'Reject (Quarantine) Warehouse');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TQcSetting.ColDescription, 'Description');
end;

procedure TfrmQcSetting.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmWarehouse: TfrmStkWarehouses;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtRejectStkWarehouseId.Name then
  begin
    LFrmWarehouse := TfrmStkWarehouses.Create(LEdit, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LFrmWarehouse.IsHelper := True;
      LFrmWarehouse.ShowModal;
      if LFrmWarehouse.DataTransfer then
        if LFrmWarehouse.CleanAndClose then
        begin
          Table.RejectStkWarehouseId := 0;
          Table.RejectWarehouseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.RejectStkWarehouseId := LFrmWarehouse.Table.Id;
          Table.RejectWarehouseName := LFrmWarehouse.Table.WarehouseName;
          LEdit.Text := Table.RejectWarehouseName;
        end;
    finally
      LFrmWarehouse.Free;
    end;
  end;
end;

procedure TfrmQcSetting.RefreshData;
begin
  inherited;
  edtCompanyTitle.Text := Table.CompanyTitle;
  chkIsEnabled.Checked := Table.IsEnabled;
  edtRejectStkWarehouseId.Text := Table.RejectWarehouseName;
  edtDescription.Text := Table.Description;
end;

end.
