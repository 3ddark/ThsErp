unit ufrmStkInventory;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkInventory.Service, StkInventory;

type
  TfrmStkInventory = class(TfrmInputSimpleDB<TStkInventory, TStkInventoryService>)
    pnlContent: TPanel;
    pgcMain: TPageControl;
    tsGeneral: TTabSheet;
    lblCode: TLabel;
    edtCode: TEdit;
    lblName: TLabel;
    edtName: TEdit;
    lblStkGroupId: TLabel;
    edtStkGroupId: TEdit;
    lblStkProductTypeId: TLabel;
    edtStkProductTypeId: TEdit;
    lblSysUomId: TLabel;
    edtSysUomId: TEdit;
    lblSellable: TLabel;
    chkSellable: TCheckBox;
    lblSpecialCode: TLabel;
    edtSpecialCode: TEdit;
    lblBrand: TLabel;
    edtBrand: TEdit;
    lblMinStockAmount: TLabel;
    edtMinStockAmount: TEdit;
    lblSupplyDuration: TLabel;
    edtSupplyDuration: TEdit;
    lblWidth: TLabel;
    edtWidth: TEdit;
    lblLength: TLabel;
    edtLength: TEdit;
    lblHeight: TLabel;
    edtHeight: TEdit;
    lblWeight: TLabel;
    edtWeight: TEdit;
    lblSysCountryId: TLabel;
    edtSysCountryId: TEdit;
    lblEinvGtipId: TLabel;
    edtEinvGtipId: TEdit;
    lblDiibProductDescription: TLabel;
    edtDiibProductDescription: TEdit;
    lblProductOverview: TLabel;
    mmoProductOverview: TMemo;
    lblImage: TLabel;
    pnlImage: TPanel;
    imgImage: TImage;
    btnImageLoad: TButton;
    btnImageClear: TButton;
    tsMonetary: TTabSheet;
    lblBuyingPrice: TLabel;
    edtBuyingPrice: TEdit;
    lblBuyingCurrency: TLabel;
    edtBuyingCurrency: TEdit;
    lblBuyingDiscount: TLabel;
    edtBuyingDiscount: TEdit;
    lblExportPrice: TLabel;
    edtExportPrice: TEdit;
    lblExportCurrency: TLabel;
    edtExportCurrency: TEdit;
    lblSalesPrice: TLabel;
    edtSalesPrice: TEdit;
    lblSalesCurrency: TLabel;
    edtSalesCurrency: TEdit;
    lblSalesDiscount: TLabel;
    edtSalesDiscount: TEdit;
    lblCurrentQuantity: TLabel;
    lblCurrentQuantityVal: TLabel;
    lblAverageCost: TLabel;
    lblAverageCostVal: TLabel;
    tsKind: TTabSheet;
    lblKindName: TLabel;
    btnKindEdit: TButton;
    grdKindValues: TStringGrid;
    tsAccounting: TTabSheet;
    lblAccountingInfo: TLabel;
    lblOverrideHeader: TLabel;
    lblDefaultHeader: TLabel;
    lblVatRate: TLabel;
    cbbVatRate: TComboBox;
    lblDefaultVatRate: TLabel;
    lblRawMaterialStockAccount: TLabel;
    edtRawMaterialStockAccount: TEdit;
    lblDefaultRawMaterialStockAccount: TLabel;
    lblRawMaterialUsageAccount: TLabel;
    edtRawMaterialUsageAccount: TEdit;
    lblDefaultRawMaterialUsageAccount: TLabel;
    lblSemiProductAccount: TLabel;
    edtSemiProductAccount: TEdit;
    lblDefaultSemiProductAccount: TLabel;
    lblSalesAccount: TLabel;
    edtSalesAccount: TEdit;
    lblDefaultSalesAccount: TLabel;
    lblSalesReturnAccount: TLabel;
    edtSalesReturnAccount: TEdit;
    lblDefaultSalesReturnAccount: TLabel;
    lblPurchaseAccount: TLabel;
    edtPurchaseAccount: TEdit;
    lblDefaultPurchaseAccount: TLabel;
    lblPurchaseReturnAccount: TLabel;
    edtPurchaseReturnAccount: TEdit;
    lblDefaultPurchaseReturnAccount: TLabel;
    tsSummary: TTabSheet;
    lblSumCurrentQuantity: TLabel;
    lblSumCurrentQuantityVal: TLabel;
    lblSumAverageCost: TLabel;
    lblSumAverageCostVal: TLabel;
    lblSumOpeningQuantity: TLabel;
    lblSumOpeningQuantityVal: TLabel;
    lblSumOpeningPrice: TLabel;
    lblSumOpeningPriceVal: TLabel;
    lblSumOpeningAmount: TLabel;
    lblSumOpeningAmountVal: TLabel;
    lblSumIncomingQuantity: TLabel;
    lblSumIncomingQuantityVal: TLabel;
    lblSumIncomingAmount: TLabel;
    lblSumIncomingAmountVal: TLabel;
    lblSumOutgoingQuantity: TLabel;
    lblSumOutgoingQuantityVal: TLabel;
    lblSumOutgoingAmount: TLabel;
    lblSumOutgoingAmountVal: TLabel;
    lblSumLastBuyDate: TLabel;
    lblSumLastBuyDateVal: TLabel;
    lblSumLastBuyQuantity: TLabel;
    lblSumLastBuyQuantityVal: TLabel;
    lblSumLastBuyPrice: TLabel;
    lblSumLastBuyPriceVal: TLabel;
    lblWarehouseStocks: TLabel;
    grdWarehouseStocks: TStringGrid;
    procedure btnImageLoadClick(Sender: TObject);
    procedure btnImageClearClick(Sender: TObject);
    procedure btnKindEditClick(Sender: TObject);
    procedure cbbVatRateChange(Sender: TObject);
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    // Formda seçilen resim; yalnız değiştiyse Table.Image'e yazılır (aksi halde kayıtta resme dokunulmaz)
    FImageBytes: TBytes;
    FImageChanged: Boolean;
    procedure ShowImage(const ABytes: TBytes);
    // KDV oranı yalnız tanımlı oranlardan (acc_set_tax_rate) seçilir; ilk (boş) seçenek = grubun oranı
    procedure FillVatRates;
    procedure SelectVatRate;
    // Grup / KDV oranı değişince gruptan gelen değerler yeniden okunur
    procedure ApplyVatRateText;
    procedure ReloadDefaults;
    procedure RefreshDefaultLabels;
    procedure LoadKindInfo;
    procedure LoadSummary;
    procedure ClearSummary;
    function IsSavedRecord: Boolean;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  StkGroup, StkGroup.Service, ufrmStkGroups,                                    // TfrmStkGroups helper output form
  StkProductType, StkProductType.Service, ufrmStkProductTypes,                  // TfrmStkProductTypes helper output form
  SysUom, SysUom.Service, ufrmSysUoms,                                          // TfrmSysUoms helper output form
  SysCurrency, SysCurrency.Service, ufrmSysCurrencies,                          // TfrmSysCurrencies helper output form
  SysCountry, SysCountry.Service, ufrmSysCountries,                             // TfrmSysCountries helper output form
  EInvGtip, EInvGtip.Service, ufrmEInvGtips,                                    // TfrmEInvGtips helper output form
  AccAccount, AccAccount.Service, ufrmAccAccounts,                              // TfrmAccAccounts helper output form
  StkCardKindInfo, StkCardKindInfo.Service, ufrmStkCardKindInfos,               // TfrmStkCardKindInfos
  StkInventorySummary,
  System.IOUtils, Vcl.ExtDlgs;

const
  MAX_IMAGE_SIZE_KB = 2048;

procedure TfrmStkInventory.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri ve karta özel hesaplar HelperProcess içinde doğrudan Table'a yazılır
  Table.Code := edtCode.Text;
  Table.Name := edtName.Text;
  Table.Sellable := chkSellable.Checked;
  Table.BuyingPrice := StrToCurrDef(edtBuyingPrice.Text, 0);
  Table.BuyingDiscount := StrToCurrDef(edtBuyingDiscount.Text, 0);
  Table.SalesPrice := StrToCurrDef(edtSalesPrice.Text, 0);
  Table.SalesDiscount := StrToCurrDef(edtSalesDiscount.Text, 0);
  Table.ExportPrice := StrToCurrDef(edtExportPrice.Text, 0);
  Table.SpecialCode := edtSpecialCode.Text;
  Table.Brand := edtBrand.Text;
  Table.Width := StrToFloatDef(edtWidth.Text, 0);
  Table.Length := StrToFloatDef(edtLength.Text, 0);
  Table.Height := StrToFloatDef(edtHeight.Text, 0);
  Table.Weight := StrToFloatDef(edtWeight.Text, 0);
  Table.SupplyDuration := StrToIntDef(edtSupplyDuration.Text, 0);
  Table.MinStockAmount := StrToFloatDef(edtMinStockAmount.Text, 0);
  Table.DiibProductDescription := edtDiibProductDescription.Text;
  Table.ProductOverview := mmoProductOverview.Lines.Text;
  ApplyVatRateText;

  if FImageChanged then
    Table.Image := FImageBytes
  else
    Table.ImageLoaded := False;  // resim değişmedi: stk_image satırına yazılmaz
  inherited;
end;

procedure TfrmStkInventory.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  pgcMain.ActivePage := tsGeneral;
  edtStkGroupId.OnHelperProcess := HelperProcess;
  edtStkProductTypeId.OnHelperProcess := HelperProcess;
  edtSysUomId.OnHelperProcess := HelperProcess;
  edtBuyingCurrency.OnHelperProcess := HelperProcess;
  edtSalesCurrency.OnHelperProcess := HelperProcess;
  edtExportCurrency.OnHelperProcess := HelperProcess;
  edtSysCountryId.OnHelperProcess := HelperProcess;
  edtEinvGtipId.OnHelperProcess := HelperProcess;
  edtRawMaterialStockAccount.OnHelperProcess := HelperProcess;
  edtRawMaterialUsageAccount.OnHelperProcess := HelperProcess;
  edtSemiProductAccount.OnHelperProcess := HelperProcess;
  edtSalesAccount.OnHelperProcess := HelperProcess;
  edtSalesReturnAccount.OnHelperProcess := HelperProcess;
  edtPurchaseAccount.OnHelperProcess := HelperProcess;
  edtPurchaseReturnAccount.OnHelperProcess := HelperProcess;
  edtCode.thsInputDataType := itString;
  edtCode.CharCase := TEditCharCase.ecUpperCase;
  edtName.thsInputDataType := itString;
  edtBuyingPrice.thsInputDataType := itFloat;
  edtBuyingDiscount.thsInputDataType := itFloat;
  edtSalesPrice.thsInputDataType := itFloat;
  edtSalesDiscount.thsInputDataType := itFloat;
  edtExportPrice.thsInputDataType := itFloat;
  edtSpecialCode.thsInputDataType := itString;
  edtBrand.thsInputDataType := itString;
  edtWidth.thsInputDataType := itFloat;
  edtLength.thsInputDataType := itFloat;
  edtHeight.thsInputDataType := itFloat;
  edtWeight.thsInputDataType := itFloat;
  edtSupplyDuration.thsInputDataType := itInteger;
  edtMinStockAmount.thsInputDataType := itFloat;
  edtDiibProductDescription.thsInputDataType := itString;
  cbbVatRate.OnChange := cbbVatRateChange;
  FillVatRates;
end;

procedure TfrmStkInventory.FormShow(Sender: TObject);
begin
  inherited;
  pgcMain.ActivePage := tsGeneral;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmStkInventory.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TitleSingular, 'Stock Card');
  tsGeneral.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TabGeneral, 'General');
  tsMonetary.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TabMonetary, 'Monetary');
  tsKind.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TabKind, 'Kind Properties');
  tsAccounting.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TabAccounting, 'Group Properties / Accounting');
  tsSummary.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TabSummary, 'Summary');

  lblCode.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCode, 'Stock Code');
  lblName.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColName, 'Stock Name');
  lblStkGroupId.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColGroup, 'Group');
  lblStkProductTypeId.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColProductType, 'Product Type');
  lblSysUomId.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColUom, 'Unit');
  lblSellable.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSellable, 'Sellable');
  lblBuyingPrice.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingPrice, 'Buying Price');
  lblBuyingCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingCurrency, 'Buying Currency');
  lblBuyingDiscount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBuyingDiscount, 'Buying Discount (%)');
  lblSalesPrice.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesPrice, 'Sales Price');
  lblSalesCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesCurrency, 'Sales Currency');
  lblSalesDiscount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesDiscount, 'Sales Discount (%)');
  lblExportPrice.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColExportPrice, 'Export Price');
  lblExportCurrency.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColExportCurrency, 'Export Currency');
  lblCurrentQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCurrentQuantity, 'Current Quantity');
  lblAverageCost.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColAverageCost, 'Average Cost');
  lblSpecialCode.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSpecialCode, 'Special Code');
  lblBrand.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBrand, 'Brand');
  lblWidth.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWidth, 'Width');
  lblLength.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColLength, 'Length');
  lblHeight.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColHeight, 'Height');
  lblWeight.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWeight, 'Weight');
  lblSupplyDuration.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSupplyDuration, 'Supply Duration (Days)');
  lblMinStockAmount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColMinStockAmount, 'Minimum Stock');
  lblSysCountryId.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCountry, 'Origin Country');
  lblEinvGtipId.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColGtipCode, 'GTIP Code');
  lblDiibProductDescription.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColDiibProductDescription, 'DIIB Description');
  lblProductOverview.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColProductOverview, 'Product Overview');
  lblImage.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.Image, 'Image');
  btnImageLoad.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ImageLoad, 'Load...');
  btnImageClear.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ImageClear, 'Clear');

  // Cins özelliği
  btnKindEdit.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.KindEdit, 'Edit Kind Information...');
  grdKindValues.Cells[0, 0] := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColProperty, 'Property');
  grdKindValues.Cells[1, 0] := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColValue, 'Value');

  // Grup özellikleri / muhasebe
  lblAccountingInfo.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.AccountingInfo,
    'Empty fields use the stock group value (VAT accounts: the tax rate row of the effective VAT rate). Fill a field to override it for this card only.');
  lblOverrideHeader.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.LblOverride, 'Card Specific');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColVatRate, 'VAT Rate (%)');
  lblRawMaterialStockAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColRawMaterialStockAccount, 'Raw Material Stock Account');
  lblRawMaterialUsageAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColRawMaterialUsageAccount, 'Raw Material Usage Account');
  lblSemiProductAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSemiProductAccount, 'Semi-Product Account');
  lblSalesAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesAccount, 'Sales VAT Account');
  lblSalesReturnAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSalesReturnAccount, 'Sales Return VAT Account');
  lblPurchaseAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColPurchaseAccount, 'Purchase VAT Account');
  lblPurchaseReturnAccount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColPurchaseReturnAccount, 'Purchase Return VAT Account');
  if Assigned(Table) then
    RefreshDefaultLabels;

  // Özetler
  lblSumCurrentQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColCurrentQuantity, 'Current Quantity');
  lblSumAverageCost.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColAverageCost, 'Average Cost');
  lblSumOpeningQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOpeningQuantity, 'Opening Quantity');
  lblSumOpeningPrice.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOpeningPrice, 'Opening Price');
  lblSumOpeningAmount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOpeningAmount, 'Opening Amount');
  lblSumIncomingQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColIncomingQuantity, 'Incoming Quantity');
  lblSumIncomingAmount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColIncomingAmount, 'Incoming Amount');
  lblSumOutgoingQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOutgoingQuantity, 'Outgoing Quantity');
  lblSumOutgoingAmount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColOutgoingAmount, 'Outgoing Amount');
  lblSumLastBuyDate.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyDate, 'Last Buy Date');
  lblSumLastBuyQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyQuantity, 'Last Buy Quantity');
  lblSumLastBuyPrice.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventorySummary.ColLastBuyPrice, 'Last Buy Price');
  lblWarehouseStocks.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.WarehouseStocks, 'Warehouse Stock Status');
  grdWarehouseStocks.Cells[0, 0] := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWarehouse, 'Warehouse');
  grdWarehouseStocks.Cells[1, 0] := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColQuantity, 'Quantity');
end;

procedure TfrmStkInventory.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkGroupId: TfrmStkGroups;
  LFrmStkProductTypeId: TfrmStkProductTypes;
  LFrmSysUomId: TfrmSysUoms;
  LFrmBuyingCurrency: TfrmSysCurrencies;
  LFrmSalesCurrency: TfrmSysCurrencies;
  LFrmExportCurrency: TfrmSysCurrencies;
  LFrmSysCountryId: TfrmSysCountries;
  LFrmEinvGtipId: TfrmEInvGtips;
  LAccount: string;

  // Hesap planından seçim; temizle = karta özel değer kaldırılır (gruptan gelir)
  function PickAccount(out ACode: string): Boolean;
  var
    LFrmAccount: TfrmAccAccounts;
  begin
    Result := False;
    ACode := '';
    LFrmAccount := TfrmAccAccounts.Create(LEdit, TAccAccountService.Create, TAccAccount.Create);
    try
      LFrmAccount.IsHelper := True;
      LFrmAccount.ShowModal;
      if LFrmAccount.DataTransfer then
      begin
        Result := True;
        if not LFrmAccount.CleanAndClose then
          ACode := LFrmAccount.Table.Code;
      end;
    finally
      LFrmAccount.Free;
    end;
  end;

begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkGroupId.Name then
  begin
    LFrmStkGroupId := TfrmStkGroups.Create(LEdit, TStkGroupService.Create, TStkGroup.Create);
    try
      LFrmStkGroupId.IsHelper := True;
      LFrmStkGroupId.ShowModal;
      if LFrmStkGroupId.DataTransfer then
      begin
        if LFrmStkGroupId.CleanAndClose then
        begin
          Table.StkGroupId := 0;
          Table.GroupName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkGroupId := LFrmStkGroupId.Table.Id;
          Table.GroupName := LFrmStkGroupId.Table.Name;
          LEdit.Text := Table.GroupName;
        end;
        ReloadDefaults;
      end;
    finally
      LFrmStkGroupId.Free;
    end;
  end
  else if LEdit.Name = edtStkProductTypeId.Name then
  begin
    LFrmStkProductTypeId := TfrmStkProductTypes.Create(LEdit, TStkProductTypeService.Create, TStkProductType.Create);
    try
      LFrmStkProductTypeId.IsHelper := True;
      LFrmStkProductTypeId.ShowModal;
      if LFrmStkProductTypeId.DataTransfer then
        if LFrmStkProductTypeId.CleanAndClose then
        begin
          Table.StkProductTypeId := 0;
          Table.ProductTypeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkProductTypeId := LFrmStkProductTypeId.Table.Id;
          Table.ProductTypeName := LFrmStkProductTypeId.Table.ProductTypeName;
          LEdit.Text := Table.ProductTypeName;
        end;
    finally
      LFrmStkProductTypeId.Free;
    end;
  end
  else if LEdit.Name = edtSysUomId.Name then
  begin
    LFrmSysUomId := TfrmSysUoms.Create(LEdit, TSysUomService.Create, TSysUom.Create);
    try
      LFrmSysUomId.IsHelper := True;
      LFrmSysUomId.ShowModal;
      if LFrmSysUomId.DataTransfer then
        if LFrmSysUomId.CleanAndClose then
        begin
          Table.SysUomId := 0;
          Table.UomName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysUomId := LFrmSysUomId.Table.Id;
          Table.UomName := LFrmSysUomId.Table.UomName;
          LEdit.Text := Table.UomName;
        end;
    finally
      LFrmSysUomId.Free;
    end;
  end
  else if LEdit.Name = edtBuyingCurrency.Name then
  begin
    LFrmBuyingCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmBuyingCurrency.IsHelper := True;
      LFrmBuyingCurrency.ShowModal;
      if LFrmBuyingCurrency.DataTransfer then
        if LFrmBuyingCurrency.CleanAndClose then
        begin
          Table.BuyingCurrency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.BuyingCurrency := LFrmBuyingCurrency.Table.Currency;
          LEdit.Text := Table.BuyingCurrency;
        end;
    finally
      LFrmBuyingCurrency.Free;
    end;
  end
  else if LEdit.Name = edtSalesCurrency.Name then
  begin
    LFrmSalesCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmSalesCurrency.IsHelper := True;
      LFrmSalesCurrency.ShowModal;
      if LFrmSalesCurrency.DataTransfer then
        if LFrmSalesCurrency.CleanAndClose then
        begin
          Table.SalesCurrency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SalesCurrency := LFrmSalesCurrency.Table.Currency;
          LEdit.Text := Table.SalesCurrency;
        end;
    finally
      LFrmSalesCurrency.Free;
    end;
  end
  else if LEdit.Name = edtExportCurrency.Name then
  begin
    LFrmExportCurrency := TfrmSysCurrencies.Create(LEdit, TSysCurrencyService.Create, TSysCurrency.Create);
    try
      LFrmExportCurrency.IsHelper := True;
      LFrmExportCurrency.ShowModal;
      if LFrmExportCurrency.DataTransfer then
        if LFrmExportCurrency.CleanAndClose then
        begin
          Table.ExportCurrency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.ExportCurrency := LFrmExportCurrency.Table.Currency;
          LEdit.Text := Table.ExportCurrency;
        end;
    finally
      LFrmExportCurrency.Free;
    end;
  end
  else if LEdit.Name = edtSysCountryId.Name then
  begin
    LFrmSysCountryId := TfrmSysCountries.Create(LEdit, TSysCountryService.Create, TSysCountry.Create);
    try
      LFrmSysCountryId.IsHelper := True;
      LFrmSysCountryId.ShowModal;
      if LFrmSysCountryId.DataTransfer then
        if LFrmSysCountryId.CleanAndClose then
        begin
          Table.SysCountryId := 0;
          Table.CountryName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SysCountryId := LFrmSysCountryId.Table.Id;
          Table.CountryName := LFrmSysCountryId.Table.CountryName;
          LEdit.Text := Table.CountryName;
        end;
    finally
      LFrmSysCountryId.Free;
    end;
  end
  else if LEdit.Name = edtEinvGtipId.Name then
  begin
    LFrmEinvGtipId := TfrmEInvGtips.Create(LEdit, TEInvGtipService.Create, TEInvGtip.Create);
    try
      LFrmEinvGtipId.IsHelper := True;
      LFrmEinvGtipId.ShowModal;
      if LFrmEinvGtipId.DataTransfer then
        if LFrmEinvGtipId.CleanAndClose then
        begin
          Table.EinvGtipId := 0;
          Table.GtipCode := '';
          Table.GtipName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EinvGtipId := LFrmEinvGtipId.Table.Id;
          Table.GtipCode := LFrmEinvGtipId.Table.Code;
          Table.GtipName := LFrmEinvGtipId.Table.Name;
          LEdit.Text := Table.GtipCode;
        end;
    finally
      LFrmEinvGtipId.Free;
    end;
  end
  else if (LEdit = edtRawMaterialStockAccount) or (LEdit = edtRawMaterialUsageAccount) or
          (LEdit = edtSemiProductAccount) or (LEdit = edtSalesAccount) or (LEdit = edtSalesReturnAccount) or
          (LEdit = edtPurchaseAccount) or (LEdit = edtPurchaseReturnAccount) then
  begin
    if not PickAccount(LAccount) then
      Exit;

    if LEdit = edtRawMaterialStockAccount then
      Table.RawMaterialStockAccount := LAccount
    else if LEdit = edtRawMaterialUsageAccount then
      Table.RawMaterialUsageAccount := LAccount
    else if LEdit = edtSemiProductAccount then
      Table.SemiProductAccount := LAccount
    else if LEdit = edtSalesAccount then
      Table.SalesAccount := LAccount
    else if LEdit = edtSalesReturnAccount then
      Table.SalesReturnAccount := LAccount
    else if LEdit = edtPurchaseAccount then
      Table.PurchaseAccount := LAccount
    else if LEdit = edtPurchaseReturnAccount then
      Table.PurchaseReturnAccount := LAccount;
    LEdit.Text := LAccount;
    RefreshDefaultLabels;
  end;
end;

procedure TfrmStkInventory.RefreshData;
begin
  inherited;
  edtCode.Text := Table.Code;
  edtName.Text := Table.Name;
  edtStkGroupId.Text := Table.GroupName;
  edtStkProductTypeId.Text := Table.ProductTypeName;
  edtSysUomId.Text := Table.UomName;
  chkSellable.Checked := Table.Sellable;
  edtBuyingPrice.Text := CurrToStr(Table.BuyingPrice);
  edtBuyingCurrency.Text := Table.BuyingCurrency;
  edtBuyingDiscount.Text := CurrToStr(Table.BuyingDiscount);
  edtSalesPrice.Text := CurrToStr(Table.SalesPrice);
  edtSalesCurrency.Text := Table.SalesCurrency;
  edtSalesDiscount.Text := CurrToStr(Table.SalesDiscount);
  edtExportPrice.Text := CurrToStr(Table.ExportPrice);
  edtExportCurrency.Text := Table.ExportCurrency;
  edtSpecialCode.Text := Table.SpecialCode;
  edtBrand.Text := Table.Brand;
  edtWidth.Text := FloatToStr(Table.Width);
  edtLength.Text := FloatToStr(Table.Length);
  edtHeight.Text := FloatToStr(Table.Height);
  edtWeight.Text := FloatToStr(Table.Weight);
  edtSupplyDuration.Text := IntToStr(Table.SupplyDuration);
  edtMinStockAmount.Text := FloatToStr(Table.MinStockAmount);
  edtSysCountryId.Text := Table.CountryName;
  edtEinvGtipId.Text := Table.GtipCode;
  edtDiibProductDescription.Text := Table.DiibProductDescription;
  mmoProductOverview.Lines.Text := Table.ProductOverview;

  // Karta özel muhasebe ayarları
  SelectVatRate;
  edtRawMaterialStockAccount.Text := Table.RawMaterialStockAccount;
  edtRawMaterialUsageAccount.Text := Table.RawMaterialUsageAccount;
  edtSemiProductAccount.Text := Table.SemiProductAccount;
  edtSalesAccount.Text := Table.SalesAccount;
  edtSalesReturnAccount.Text := Table.SalesReturnAccount;
  edtPurchaseAccount.Text := Table.PurchaseAccount;
  edtPurchaseReturnAccount.Text := Table.PurchaseReturnAccount;
  // Yeni kayıtta / kopyada view değerleri yok: gruptan gelenler yeniden okunur
  if not IsSavedRecord then
    ReloadDefaults
  else
    RefreshDefaultLabels;

  FImageBytes := Copy(Table.Image);
  FImageChanged := False;
  ShowImage(FImageBytes);

  if IsSavedRecord then
  begin
    lblCurrentQuantityVal.Caption := Table.CurrentQuantity;
    lblAverageCostVal.Caption := Table.AverageCost;
  end
  else
  begin
    lblCurrentQuantityVal.Caption := '-';
    lblAverageCostVal.Caption := '-';
  end;
  LoadKindInfo;
  LoadSummary;
end;

// Kopya (ifmCopyNewRecord) kaynak kaydın Id'sini taşır; cins/özet yalnız kayıtlı kart için gösterilir
function TfrmStkInventory.IsSavedRecord: Boolean;
begin
  Result := (FormMode in [ifmRewiev, ifmUpdate, ifmReadOnly]) and (Table.Id > 0);
end;

procedure TfrmStkInventory.FillVatRates;
var
  LRate: Currency;
begin
  cbbVatRate.Items.BeginUpdate;
  try
    cbbVatRate.Items.Clear;
    cbbVatRate.Items.Add('');
    for LRate in Service.GetVatRates do
      cbbVatRate.Items.Add(FormatFloat('0.##', LRate));
  finally
    cbbVatRate.Items.EndUpdate;
  end;
end;

// Karta özel oran yoksa boş seçenek; kayıtlı oran listede yoksa yine gösterilir (kayıtta reddedilir)
procedure TfrmStkInventory.SelectVatRate;
var
  LText: string;
begin
  if not Table.HasVatRate then
  begin
    cbbVatRate.ItemIndex := 0;
    Exit;
  end;
  LText := FormatFloat('0.##', Table.VatRate);
  if cbbVatRate.Items.IndexOf(LText) < 0 then
    cbbVatRate.Items.Add(LText);
  cbbVatRate.ItemIndex := cbbVatRate.Items.IndexOf(LText);
end;

procedure TfrmStkInventory.ApplyVatRateText;
begin
  if cbbVatRate.ItemIndex <= 0 then
  begin
    Table.HasVatRate := False;
    Table.VatRate := 0;
  end
  else
  begin
    Table.HasVatRate := True;
    Table.VatRate := StrToCurrDef(cbbVatRate.Items[cbbVatRate.ItemIndex], 0);
  end;
end;

procedure TfrmStkInventory.cbbVatRateChange(Sender: TObject);
var
  LHadValue: Boolean;
  LOldValue: Currency;
begin
  LHadValue := Table.HasVatRate;
  LOldValue := Table.VatRate;
  ApplyVatRateText;
  if (LHadValue <> Table.HasVatRate) or (LOldValue <> Table.VatRate) then
    ReloadDefaults;
end;

procedure TfrmStkInventory.ReloadDefaults;
begin
  Service.FillDefaults(Table);
  RefreshDefaultLabels;
end;

procedure TfrmStkInventory.RefreshDefaultLabels;

  procedure Show(ALabel: TLabel; const ADefault, AOverride: string);
  begin
    if ADefault = '' then
      ALabel.Caption := '-'
    else
      ALabel.Caption := ADefault;
    // Karta özel değer girilmişse gruptan gelen değer pasif görünür
    if AOverride <> '' then
      ALabel.Font.Color := clGrayText
    else
      ALabel.Font.Color := clWindowText;
  end;

var
  LVatOverride: string;
begin
  lblDefaultHeader.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.LblDefault, 'From Group');
  if Table.GroupName <> '' then
    lblDefaultHeader.Caption := lblDefaultHeader.Caption + ' (' + Table.GroupName + ')';

  if Table.HasVatRate then
    LVatOverride := CurrToStr(Table.VatRate)
  else
    LVatOverride := '';
  Show(lblDefaultVatRate, Table.DefaultVatRate, LVatOverride);
  Show(lblDefaultRawMaterialStockAccount, Table.DefaultRawMaterialStockAccount, Table.RawMaterialStockAccount);
  Show(lblDefaultRawMaterialUsageAccount, Table.DefaultRawMaterialUsageAccount, Table.RawMaterialUsageAccount);
  Show(lblDefaultSemiProductAccount, Table.DefaultSemiProductAccount, Table.SemiProductAccount);
  Show(lblDefaultSalesAccount, Table.DefaultSalesAccount, Table.SalesAccount);
  Show(lblDefaultSalesReturnAccount, Table.DefaultSalesReturnAccount, Table.SalesReturnAccount);
  Show(lblDefaultPurchaseAccount, Table.DefaultPurchaseAccount, Table.PurchaseAccount);
  Show(lblDefaultPurchaseReturnAccount, Table.DefaultPurchaseReturnAccount, Table.PurchaseReturnAccount);
end;

procedure TfrmStkInventory.LoadKindInfo;
var
  LValues: TArray<TStkInventoryKindValue>;
  LKindName: string;
  I: Integer;
begin
  // Cins bilgisi ayrı tabloda; güncelleme modunda açık transaction olduğu için yalnız incelemede düzenlenir
  btnKindEdit.Enabled := IsSavedRecord and (FormMode = ifmRewiev);
  LValues := nil;
  LKindName := '';
  if IsSavedRecord then
    LValues := Service.GetKindValues(Table.Id, LKindName);

  if LKindName = '' then
    lblKindName.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.KindNotDefined, 'No kind information has been entered for this stock card.')
  else
    lblKindName.Caption := TLocalizationManager.Translate(TLangKeys.TStkCardKindInfo.ColKind, 'Kind') + ': ' + LKindName;

  grdKindValues.RowCount := Length(LValues) + 1;
  if Length(LValues) = 0 then
  begin
    grdKindValues.RowCount := 2;
    grdKindValues.Cells[0, 1] := '';
    grdKindValues.Cells[1, 1] := '';
  end;
  for I := 0 to High(LValues) do
  begin
    grdKindValues.Cells[0, I + 1] := LValues[I].Caption;
    grdKindValues.Cells[1, I + 1] := LValues[I].Value;
  end;
end;

procedure TfrmStkInventory.ClearSummary;
begin
  lblSumCurrentQuantityVal.Caption := '-';
  lblSumAverageCostVal.Caption := '-';
  lblSumOpeningQuantityVal.Caption := '-';
  lblSumOpeningPriceVal.Caption := '-';
  lblSumOpeningAmountVal.Caption := '-';
  lblSumIncomingQuantityVal.Caption := '-';
  lblSumIncomingAmountVal.Caption := '-';
  lblSumOutgoingQuantityVal.Caption := '-';
  lblSumOutgoingAmountVal.Caption := '-';
  lblSumLastBuyDateVal.Caption := '-';
  lblSumLastBuyQuantityVal.Caption := '-';
  lblSumLastBuyPriceVal.Caption := '-';
  grdWarehouseStocks.RowCount := 2;
  grdWarehouseStocks.Cells[0, 1] := '';
  grdWarehouseStocks.Cells[1, 1] := '';
end;

procedure TfrmStkInventory.LoadSummary;
var
  LSummary: TStkInventorySummary;
  LStocks: TArray<TStkInventoryWarehouseStock>;
  I: Integer;
begin
  ClearSummary;
  if not IsSavedRecord then
    Exit;

  LSummary := Service.GetSummary(Table.Id);
  try
    if Assigned(LSummary) then
    begin
      lblSumCurrentQuantityVal.Caption := CurrToStr(LSummary.CurrentQuantity);
      lblSumAverageCostVal.Caption := CurrToStr(LSummary.AverageCost);
      lblSumOpeningQuantityVal.Caption := CurrToStr(LSummary.OpeningQuantity);
      lblSumOpeningPriceVal.Caption := CurrToStr(LSummary.OpeningPrice);
      lblSumOpeningAmountVal.Caption := CurrToStr(LSummary.OpeningAmount);
      lblSumIncomingQuantityVal.Caption := CurrToStr(LSummary.IncomingQuantity);
      lblSumIncomingAmountVal.Caption := CurrToStr(LSummary.IncomingAmount);
      lblSumOutgoingQuantityVal.Caption := CurrToStr(LSummary.OutgoingQuantity);
      lblSumOutgoingAmountVal.Caption := CurrToStr(LSummary.OutgoingAmount);
      if LSummary.LastBuyDate > 0 then
        lblSumLastBuyDateVal.Caption := DateToStr(LSummary.LastBuyDate);
      lblSumLastBuyQuantityVal.Caption := CurrToStr(LSummary.LastBuyQuantity);
      lblSumLastBuyPriceVal.Caption := Trim(CurrToStr(LSummary.LastBuyPrice) + ' ' + LSummary.LastBuyCurrency);
    end;
  finally
    LSummary.Free;
  end;

  LStocks := Service.GetWarehouseStocks(Table.Id);
  if Length(LStocks) > 0 then
    grdWarehouseStocks.RowCount := Length(LStocks) + 1;
  for I := 0 to High(LStocks) do
  begin
    grdWarehouseStocks.Cells[0, I + 1] := LStocks[I].WarehouseName;
    grdWarehouseStocks.Cells[1, I + 1] := FloatToStr(LStocks[I].Quantity);
  end;
end;

procedure TfrmStkInventory.btnKindEditClick(Sender: TObject);
var
  LFrm: TfrmStkCardKindInfos;
begin
  if not IsSavedRecord then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TStkInventory.SaveFirst, 'Save the stock card first.'));

  LFrm := TfrmStkCardKindInfos.Create(Self, TStkCardKindInfoService.Create, TStkCardKindInfo.Create);
  try
    LFrm.SetFixedInventory(Table.Id, Table.Code + ' ' + Table.Name);
    LFrm.ShowModal;
  finally
    LFrm.Free;
  end;
  LoadKindInfo;
end;

procedure TfrmStkInventory.ShowImage(const ABytes: TBytes);
var
  LStream: TBytesStream;
  LWic: TWICImage;
begin
  imgImage.Picture.Assign(nil);
  if Length(ABytes) = 0 then
    Exit;

  LStream := TBytesStream.Create(ABytes);
  LWic := TWICImage.Create;
  try
    try
      LWic.LoadFromStream(LStream);
      imgImage.Picture.Assign(LWic);
    except
      // Okunamayan biçim: resim alanı boş gösterilir, veri korunur
      imgImage.Picture.Assign(nil);
    end;
  finally
    LWic.Free;
    LStream.Free;
  end;
end;

procedure TfrmStkInventory.btnImageLoadClick(Sender: TObject);
var
  LDialog: TOpenPictureDialog;
  LBytes: TBytes;
begin
  // İnceleme modunda (kontroller kilitliyken) resim değiştirilemez
  if mmoProductOverview.ReadOnly then
    Exit;

  LDialog := TOpenPictureDialog.Create(Self);
  try
    LDialog.Filter := 'Images (*.png;*.jpg;*.jpeg;*.bmp;*.gif)|*.png;*.jpg;*.jpeg;*.bmp;*.gif';
    if not LDialog.Execute then
      Exit;

    LBytes := TFile.ReadAllBytes(LDialog.FileName);
    if Length(LBytes) > MAX_IMAGE_SIZE_KB * 1024 then
      raise Exception.Create(Format(TLocalizationManager.Translate(TLangKeys.TStkInventory.ImageTooLarge,
        'Image file is too large (maximum %d KB).'), [MAX_IMAGE_SIZE_KB]));

    FImageBytes := LBytes;
    FImageChanged := True;
    ShowImage(FImageBytes);
  finally
    LDialog.Free;
  end;
end;

procedure TfrmStkInventory.btnImageClearClick(Sender: TObject);
begin
  if mmoProductOverview.ReadOnly then
    Exit;

  FImageBytes := nil;
  FImageChanged := True;
  ShowImage(FImageBytes);
end;

end.
