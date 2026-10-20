unit ufrmSlsDispatchDetail;

// Sevk irsaliyesi: başlık (sls_dispatch) + kalemler (Table.Lines, sls_dispatch_detail) tek ekranda. Kalemler bellekte
// irsaliye servisiyle eklenir / değişir / çıkar (satır formu TfrmSlsDispatchLine); Onayla Service.BusinessSaveWithDetails
// ile başlık ve kalemleri (stok çıkış hareketleri dahil) tek transaction'da yazar. Durum (bekliyor / kapandı)
// faturalardan, servis tutar; faturalanan kalem silinemez / azaltılamaz. e-İrsaliye / Taşıma sekmesi: senaryo (boş = kağıt
// irsaliye; e-İrsaliye mükellefi cari seçilince TEMELIRSALIYE önerilir), ETTN / durum (servis), fiili sevk saati, taşıyıcı
// firma ya da araç + dorse + şoför tanım kartları (kurallar TSlsDispatchService.CheckEDespatch).

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsDispatch.Service, SlsDispatch, SlsDispatchDetail.Service, SlsDispatchDetail;

type
  TfrmSlsDispatchDetail = class(TfrmInputDetailedDB<TSlsDispatch, TSlsDispatchService>)
    pnlContent: TPanel;
    pgcHeader: TPageControl;
    tsGeneral: TTabSheet;
    tsEDespatch: TTabSheet;
    lblDispatchNo: TLabel;
    edtDispatchNo: TEdit;
    lblDispatchDate: TLabel;
    edtDispatchDate: TEdit;
    lblAccAccountId: TLabel;
    edtAccAccountId: TEdit;
    lblStkWarehouseId: TLabel;
    edtStkWarehouseId: TEdit;
    lblCurrency: TLabel;
    edtCurrency: TEdit;
    lblSlsOrderId: TLabel;
    edtSlsOrderId: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    lblEinvProfileId: TLabel;
    edtEinvProfileId: TEdit;
    lblEinvUuid: TLabel;
    edtEinvUuid: TEdit;
    lblEinvStatusText: TLabel;
    edtEinvStatusText: TEdit;
    lblDespatchTime: TLabel;
    edtDespatchTime: TEdit;
    lblCarrierAccAccountId: TLabel;
    edtCarrierAccAccountId: TEdit;
    lblEinvVehicleId: TLabel;
    edtEinvVehicleId: TEdit;
    lblTrailer1EinvVehicleId: TLabel;
    edtTrailer1EinvVehicleId: TEdit;
    lblTrailer2EinvVehicleId: TLabel;
    edtTrailer2EinvVehicleId: TEdit;
    lblDriver1EinvDriverId: TLabel;
    edtDriver1EinvDriverId: TEdit;
    lblDriver2EinvDriverId: TLabel;
    edtDriver2EinvDriverId: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TSlsDispatchDetail>;
    procedure ShowTotals;
    procedure ShowTotalValues;
    procedure ShowEDespatchFields;
  protected
    procedure DetailsChanged; override;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    // e-İrsaliye / Taşıma sekmesinin seçim listeleri
    procedure EDespatchHelper(AEdit: TEdit);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache,
  SlsLookup, Grid.Types, ufrmSlsDispatchLine,
  AccAccount, AccAccount.Service, ufrmAccAccounts,
  StkWarehouse, StkWarehouse.Service, ufrmStkWarehouses,
  SlsOrder, SlsOrder.Service, ufrmSlsOrders,
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,
  EInvLookup,
  EInvProfile, EInvProfile.Service, ufrmEInvProfiles,     // TfrmEInvProfiles helper output form
  EInvVehicle, EInvVehicle.Service, ufrmEInvVehicles,     // TfrmEInvVehicles helper output form
  EInvDriver, EInvDriver.Service, ufrmEInvDrivers;        // TfrmEInvDrivers helper output form

procedure TfrmSlsDispatchDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.DispatchNo := edtDispatchNo.Text;
  Table.DispatchDate := StrToDateDef(edtDispatchDate.Text, 0);
  Table.Description := edtDescription.Text;
  if Trim(edtDespatchTime.Text) = '' then
    Table.DespatchTime := 0
  else
    Table.DespatchTime := Frac(StrToTimeDef(edtDespatchTime.Text, 0));
  inherited;
end;

procedure TfrmSlsDispatchDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow('total', True);
  pnlTotals.Height := FTotals.RequiredHeight;

  edtDispatchNo.thsInputDataType := itString;
  edtDispatchNo.CharCase := TEditCharCase.ecUpperCase;
  edtDispatchDate.thsInputDataType := itDate;
  edtAccAccountId.OnHelperProcess := HelperProcess;
  edtStkWarehouseId.OnHelperProcess := HelperProcess;
  edtSlsOrderId.OnHelperProcess := HelperProcess;
  edtCurrency.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
  edtDespatchTime.thsInputDataType := itTime;
  edtEinvProfileId.OnHelperProcess := HelperProcess;
  edtCarrierAccAccountId.OnHelperProcess := HelperProcess;
  edtEinvVehicleId.OnHelperProcess := HelperProcess;
  edtTrailer1EinvVehicleId.OnHelperProcess := HelperProcess;
  edtTrailer2EinvVehicleId.OnHelperProcess := HelperProcess;
  edtDriver1EinvDriverId.OnHelperProcess := HelperProcess;
  edtDriver2EinvDriverId.OnHelperProcess := HelperProcess;
  pgcHeader.ActivePage := tsGeneral;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / hesap irsaliye servisinde
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuLines, 'Lines'));
  FLines := AddDetail<TSlsDispatchDetail>(FPageLines, 'vw_sls_dispatch_detail',
    function: TObjectList<TSlsDispatchDetail>
    begin
      Result := Table.Lines;
    end,
    function: TSlsDispatchDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TSlsDispatchDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TSlsDispatchDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TSlsDispatchDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmSlsDispatchLine.Create(Self, TSlsDispatchDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('amount', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('sls_dispatch_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('sls_order_detail_id', 0);
  FLines.Grid.SetColumnProperty('dispatch_no', 0);
  FLines.Grid.SetColumnProperty('currency', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 200);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 160);
end;

destructor TfrmSlsDispatchDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmSlsDispatchDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtDispatchDate.CanFocus then
    edtDispatchDate.SetFocus;
end;

procedure TfrmSlsDispatchDetail.ShowTotalValues;
begin
  if Assigned(FTotals) and Assigned(Table) then
    FTotals.SetValue('total', Table.TotalAmount, Table.Currency);
end;

procedure TfrmSlsDispatchDetail.ShowTotals;
begin
  if not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  ShowTotalValues;
end;

procedure TfrmSlsDispatchDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmSlsDispatchDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TitleSingular, 'Delivery Note');
  lblDispatchNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchNo, 'Delivery Note No');
  lblDispatchDate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDispatchDate, 'Delivery Note Date');
  lblAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColAccAccountId, 'Customer');
  lblStkWarehouseId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColStkWarehouseId, 'Warehouse');
  lblSlsOrderId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColSlsOrderId, 'Order');
  lblCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCurrency, 'Currency');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColStatus, 'Status');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDescription, 'Description');
  tsGeneral.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TabGeneral, 'General');
  tsEDespatch.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.TabEDespatch, 'e-Despatch / Transport');
  lblEinvProfileId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvProfileId, 'Profile');
  lblEinvUuid.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvUuid, 'UUID (ETTN)');
  lblEinvStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvStatus, 'e-Document Status');
  lblDespatchTime.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDespatchTime, 'Despatch Time');
  lblCarrierAccAccountId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColCarrierAccAccountId, 'Carrier');
  lblEinvVehicleId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColEinvVehicleId, 'Vehicle Plate');
  lblTrailer1EinvVehicleId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTrailer1EinvVehicleId, 'Trailer 1');
  lblTrailer2EinvVehicleId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTrailer2EinvVehicleId, 'Trailer 2');
  lblDriver1EinvDriverId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDriver1EinvDriverId, 'Driver 1');
  lblDriver2EinvDriverId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColDriver2EinvDriverId, 'Driver 2');
  if Assigned(Table) then
    edtEinvStatusText.Text := TEInvLookup.Text(elkEInvStatus, Table.EinvStatus);
  if Assigned(FTotals) then
    FTotals.SetCaption('total', TLocalizationManager.Translate(TLangKeys.TSlsDispatch.ColTotalAmount, 'Total'));

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatch.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUnitPrice, 'Net Unit Price'));
    FLines.Grid.SetColumnTitle('amount', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColAmount, 'Amount'));
    FLines.Grid.SetColumnTitle('invoiced_quantity', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColInvoicedQuantity, 'Invoiced Quantity'));
    FLines.Grid.SetColumnTitle('order_no', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColOrderNo, 'Order No'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmSlsDispatchDetail.ShowEDespatchFields;
begin
  if not Assigned(Table) then
    Exit;
  edtEinvProfileId.Text := Table.ProfileCode;
  edtEinvUuid.Text := UpperCase(Table.EinvUuid);
  edtEinvStatusText.Text := TEInvLookup.Text(elkEInvStatus, Table.EinvStatus);
  if Table.DespatchTime > 0 then
    edtDespatchTime.Text := FormatDateTime('hh:nn', Table.DespatchTime)
  else
    edtDespatchTime.Text := '';
  edtCarrierAccAccountId.Text := Table.CarrierName;
  edtEinvVehicleId.Text := Table.VehiclePlate;
  edtTrailer1EinvVehicleId.Text := Table.Trailer1Plate;
  edtTrailer2EinvVehicleId.Text := Table.Trailer2Plate;
  edtDriver1EinvDriverId.Text := Table.Driver1Name;
  edtDriver2EinvDriverId.Text := Table.Driver2Name;
end;

procedure TfrmSlsDispatchDetail.EDespatchHelper(AEdit: TEdit);

  // araç / dorse seçimi: ATrailer = dorse listesi
  procedure PickVehicle(ATrailer: Boolean; var AId: Int64; var APlate: string);
  var
    LFrm: TfrmEInvVehicles;
  begin
    LFrm := TfrmEInvVehicles.Create(AEdit, TEInvVehicleService.Create, TEInvVehicle.Create);
    try
      LFrm.IsHelper := True;
      LFrm.SetActiveOnly(ATrailer);
      LFrm.ShowModal;
      if LFrm.DataTransfer then
        if LFrm.CleanAndClose then
        begin
          AId := 0;
          APlate := '';
        end
        else
        begin
          AId := LFrm.Table.Id;
          APlate := LFrm.Table.PlateNo;
        end;
    finally
      LFrm.Free;
    end;
  end;

  procedure PickDriver(var AId: Int64; var AName: string);
  var
    LFrm: TfrmEInvDrivers;
  begin
    LFrm := TfrmEInvDrivers.Create(AEdit, TEInvDriverService.Create, TEInvDriver.Create);
    try
      LFrm.IsHelper := True;
      LFrm.SetActiveOnly;
      LFrm.ShowModal;
      if LFrm.DataTransfer then
        if LFrm.CleanAndClose then
        begin
          AId := 0;
          AName := '';
        end
        else
        begin
          AId := LFrm.Table.Id;
          AName := Trim(LFrm.Table.FirstName + ' ' + LFrm.Table.FamilyName);
        end;
    finally
      LFrm.Free;
    end;
  end;

var
  LFrmProfile: TfrmEInvProfiles;
  LFrmCarrier: TfrmAccAccounts;
  LId: Int64;
  LText: string;
begin
  if AEdit.Name = edtEinvProfileId.Name then
  begin
    LFrmProfile := TfrmEInvProfiles.Create(AEdit, TEInvProfileService.Create, TEInvProfile.Create);
    try
      LFrmProfile.IsHelper := True;
      LFrmProfile.SetActiveOnly(False, True);
      LFrmProfile.ShowModal;
      if LFrmProfile.DataTransfer then
        if LFrmProfile.CleanAndClose then
        begin
          Table.EinvProfileId := 0;
          Table.ProfileCode := '';
        end
        else
        begin
          Table.EinvProfileId := LFrmProfile.Table.Id;
          Table.ProfileCode := LFrmProfile.Table.Code;
        end;
    finally
      LFrmProfile.Free;
    end;
  end
  else if AEdit.Name = edtCarrierAccAccountId.Name then
  begin
    LFrmCarrier := TfrmAccAccounts.Create(AEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmCarrier.IsHelper := True;
      LFrmCarrier.ShowModal;
      if LFrmCarrier.DataTransfer then
        if LFrmCarrier.CleanAndClose then
        begin
          Table.CarrierAccAccountId := 0;
          Table.CarrierCode := '';
          Table.CarrierName := '';
        end
        else
        begin
          Table.CarrierAccAccountId := LFrmCarrier.Table.Id;
          Table.CarrierCode := LFrmCarrier.Table.Code;
          Table.CarrierName := LFrmCarrier.Table.Name;
        end;
    finally
      LFrmCarrier.Free;
    end;
  end
  else if AEdit.Name = edtEinvVehicleId.Name then
  begin
    LId := Table.EinvVehicleId;
    LText := Table.VehiclePlate;
    PickVehicle(False, LId, LText);
    Table.EinvVehicleId := LId;
    Table.VehiclePlate := LText;
  end
  else if AEdit.Name = edtTrailer1EinvVehicleId.Name then
  begin
    LId := Table.Trailer1EinvVehicleId;
    LText := Table.Trailer1Plate;
    PickVehicle(True, LId, LText);
    Table.Trailer1EinvVehicleId := LId;
    Table.Trailer1Plate := LText;
  end
  else if AEdit.Name = edtTrailer2EinvVehicleId.Name then
  begin
    LId := Table.Trailer2EinvVehicleId;
    LText := Table.Trailer2Plate;
    PickVehicle(True, LId, LText);
    Table.Trailer2EinvVehicleId := LId;
    Table.Trailer2Plate := LText;
  end
  else if AEdit.Name = edtDriver1EinvDriverId.Name then
  begin
    LId := Table.Driver1EinvDriverId;
    LText := Table.Driver1Name;
    PickDriver(LId, LText);
    Table.Driver1EinvDriverId := LId;
    Table.Driver1Name := LText;
  end
  else if AEdit.Name = edtDriver2EinvDriverId.Name then
  begin
    LId := Table.Driver2EinvDriverId;
    LText := Table.Driver2Name;
    PickDriver(LId, LText);
    Table.Driver2EinvDriverId := LId;
    Table.Driver2Name := LText;
  end
  else
    Exit;
  ShowEDespatchFields;
end;

procedure TfrmSlsDispatchDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmAccAccountId: TfrmAccAccounts;
  LFrmStkWarehouseId: TfrmStkWarehouses;
  LFrmSlsOrderId: TfrmSlsOrders;
  LFrmCurrency: TfrmSysCurrencies;
  LLine: TSlsDispatchDetail;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtAccAccountId.Name then
  begin
    LFrmAccAccountId := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccAccountId.IsHelper := True;
      LFrmAccAccountId.ShowModal;
      if LFrmAccAccountId.DataTransfer then
        if LFrmAccAccountId.CleanAndClose then
        begin
          Table.AccAccountId := 0;
          Table.AccountCode := '';
          Table.AccountName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.AccAccountId := LFrmAccAccountId.Table.Id;
          Table.AccountCode := LFrmAccAccountId.Table.Code;
          Table.AccountName := LFrmAccAccountId.Table.Name;
          LEdit.Text := Table.AccountName;
          Service.SuggestEDespatch(Table, LFrmAccAccountId.Table.EDespatchActive);
          ShowEDespatchFields;
        end;
    finally
      LFrmAccAccountId.Free;
    end;
  end
  else if LEdit.Name = edtStkWarehouseId.Name then
  begin
    LFrmStkWarehouseId := TfrmStkWarehouses.Create(LEdit, TStkWarehouseService.Create, TStkWarehouse.Create);
    try
      LFrmStkWarehouseId.IsHelper := True;
      LFrmStkWarehouseId.ShowModal;
      if LFrmStkWarehouseId.DataTransfer then
        if LFrmStkWarehouseId.CleanAndClose then
        begin
          Table.StkWarehouseId := 0;
          Table.WarehouseName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkWarehouseId := LFrmStkWarehouseId.Table.Id;
          Table.WarehouseName := LFrmStkWarehouseId.Table.WarehouseName;
          LEdit.Text := Table.WarehouseName;
        end;
    finally
      LFrmStkWarehouseId.Free;
    end;
  end
  else if LEdit.Name = edtSlsOrderId.Name then
  begin
    LFrmSlsOrderId := TfrmSlsOrders.Create(LEdit, TSlsOrderService.Create, TSlsOrder.Create);
    try
      LFrmSlsOrderId.IsHelper := True;
      LFrmSlsOrderId.ShowModal;
      if LFrmSlsOrderId.DataTransfer then
        if LFrmSlsOrderId.CleanAndClose then
        begin
          Table.SlsOrderId := 0;
          Table.OrderNo := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SlsOrderId := LFrmSlsOrderId.Table.Id;
          Table.OrderNo := LFrmSlsOrderId.Table.OrderNo;
          LEdit.Text := Table.OrderNo;
        end;
      // Sipariş seçilince müşteri / ambar / para birimi siparişten gelir
      if LFrmSlsOrderId.DataTransfer and not LFrmSlsOrderId.CleanAndClose then
      begin
        Table.AccAccountId := LFrmSlsOrderId.Table.AccAccountId;
        Table.AccountName := LFrmSlsOrderId.Table.AccountName;
        edtAccAccountId.Text := Table.AccountName;
        Table.Currency := LFrmSlsOrderId.Table.Currency;
        edtCurrency.Text := Table.Currency;
        if LFrmSlsOrderId.Table.StkWarehouseId > 0 then
        begin
          Table.StkWarehouseId := LFrmSlsOrderId.Table.StkWarehouseId;
          Table.WarehouseName := LFrmSlsOrderId.Table.WarehouseName;
          edtStkWarehouseId.Text := Table.WarehouseName;
        end;
        for LLine in Table.Lines do
          LLine.Currency := Table.Currency;
        ShowTotalValues;
      end;
    finally
      LFrmSlsOrderId.Free;
    end;
  end
  else if LEdit.Name = edtCurrency.Name then
  begin
    LFrmCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmCurrency.IsHelper := True;
      LFrmCurrency.ShowModal;
      if LFrmCurrency.DataTransfer then
        if LFrmCurrency.CleanAndClose then
        begin
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.Currency := LFrmCurrency.Table.Currency;
          LEdit.Text := Table.Currency;
        end;
      // kalemlerin para birimi (fiyat önerisi) ve toplamın gösterimi belgeyle aynı
      for LLine in Table.Lines do
        LLine.Currency := Table.Currency;
      ShowTotalValues;
    finally
      LFrmCurrency.Free;
    end;
  end
  else
    EDespatchHelper(LEdit);
end;

procedure TfrmSlsDispatchDetail.RefreshData;
begin
  inherited;
  edtDispatchNo.Text := Table.DispatchNo;
  if Table.DispatchDate > 0 then
    edtDispatchDate.Text := DateToStr(Table.DispatchDate)
  else
    edtDispatchDate.Text := '';
  edtAccAccountId.Text := Table.AccountName;
  edtStkWarehouseId.Text := Table.WarehouseName;
  edtSlsOrderId.Text := Table.OrderNo;
  edtCurrency.Text := Table.Currency;
  edtStatusText.Text := TSlsLookup.Text(slkDispatchStatus, Table.Status);
  edtDescription.Text := Table.Description;
  ShowEDespatchFields;
  if Table.Lines.Count > 0 then
    ShowTotals
  else
    ShowTotalValues;
end;

end.
