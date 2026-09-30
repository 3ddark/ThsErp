unit ufrmStkInventory;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  StkInventory.Service, StkInventory;

type
  TfrmStkInventory = class(TfrmInputSimpleDB<TStkInventory, TStkInventoryService>)
    pnlContent: TPanel;
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
    lblBuyingPrice: TLabel;
    edtBuyingPrice: TEdit;
    lblBuyingCurrency: TLabel;
    edtBuyingCurrency: TEdit;
    lblBuyingDiscount: TLabel;
    edtBuyingDiscount: TEdit;
    lblSalesPrice: TLabel;
    edtSalesPrice: TEdit;
    lblSalesCurrency: TLabel;
    edtSalesCurrency: TEdit;
    lblSalesDiscount: TLabel;
    edtSalesDiscount: TEdit;
    lblExportPrice: TLabel;
    edtExportPrice: TEdit;
    lblExportCurrency: TLabel;
    edtExportCurrency: TEdit;
    lblSpecialCode: TLabel;
    edtSpecialCode: TEdit;
    lblBrand: TLabel;
    edtBrand: TEdit;
    lblWidth: TLabel;
    edtWidth: TEdit;
    lblLength: TLabel;
    edtLength: TEdit;
    lblHeight: TLabel;
    edtHeight: TEdit;
    lblWeight: TLabel;
    edtWeight: TEdit;
    lblSupplyDuration: TLabel;
    edtSupplyDuration: TEdit;
    lblMinStockAmount: TLabel;
    edtMinStockAmount: TEdit;
    lblSysCountryId: TLabel;
    edtSysCountryId: TEdit;
    lblHsNo: TLabel;
    edtHsNo: TEdit;
    lblDiibProductDescription: TLabel;
    edtDiibProductDescription: TEdit;
    lblProductOverview: TLabel;
    mmoProductOverview: TMemo;
    lblImage: TLabel;
    pnlImage: TPanel;
    imgImage: TImage;
    btnImageLoad: TButton;
    btnImageClear: TButton;
    procedure btnImageLoadClick(Sender: TObject);
    procedure btnImageClearClick(Sender: TObject);
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    // Formda seçilen resim; yalnız değiştiyse Table.Image'e yazılır (aksi halde kayıtta resme dokunulmaz)
    FImageBytes: TBytes;
    FImageChanged: Boolean;
    procedure ShowImage(const ABytes: TBytes);
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
  System.IOUtils, Vcl.ExtDlgs;

const
  MAX_IMAGE_SIZE_KB = 2048;

procedure TfrmStkInventory.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
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
  Table.HsNo := edtHsNo.Text;
  Table.DiibProductDescription := edtDiibProductDescription.Text;
  Table.ProductOverview := mmoProductOverview.Lines.Text;

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
  edtStkGroupId.OnHelperProcess := HelperProcess;
  edtStkProductTypeId.OnHelperProcess := HelperProcess;
  edtSysUomId.OnHelperProcess := HelperProcess;
  edtBuyingCurrency.OnHelperProcess := HelperProcess;
  edtSalesCurrency.OnHelperProcess := HelperProcess;
  edtExportCurrency.OnHelperProcess := HelperProcess;
  edtSysCountryId.OnHelperProcess := HelperProcess;
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
  edtHsNo.thsInputDataType := itString;
  edtHsNo.CharCase := TEditCharCase.ecUpperCase;
  edtDiibProductDescription.thsInputDataType := itString;
end;

procedure TfrmStkInventory.FormShow(Sender: TObject);
begin
  inherited;
  if edtCode.CanFocus then
    edtCode.SetFocus;
end;

procedure TfrmStkInventory.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.TitleSingular, 'Stock Card');
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
  lblSpecialCode.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSpecialCode, 'Special Code');
  lblBrand.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColBrand, 'Brand');
  lblWidth.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWidth, 'Width');
  lblLength.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColLength, 'Length');
  lblHeight.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColHeight, 'Height');
  lblWeight.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColWeight, 'Weight');
  lblSupplyDuration.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColSupplyDuration, 'Supply Duration (Days)');
  lblMinStockAmount.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColMinStockAmount, 'Minimum Stock');
  lblSysCountryId.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColCountry, 'Origin Country');
  lblHsNo.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColHsNo, 'HS Code');
  lblDiibProductDescription.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColDiibProductDescription, 'DIIB Description');
  lblProductOverview.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ColProductOverview, 'Product Overview');
  lblImage.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.Image, 'Image');
  btnImageLoad.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ImageLoad, 'Load...');
  btnImageClear.Caption := TLocalizationManager.Translate(TLangKeys.TStkInventory.ImageClear, 'Clear');
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
  edtHsNo.Text := Table.HsNo;
  edtDiibProductDescription.Text := Table.DiibProductDescription;
  mmoProductOverview.Lines.Text := Table.ProductOverview;

  FImageBytes := Copy(Table.Image);
  FImageChanged := False;
  ShowImage(FImageBytes);
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
