unit ufrmPrdBomDetail;

// Ürün reçetesi: başlık (prd_bom) + beş kalem listesi sekmelerde (hammaddeler, işçilik / giderler, yan ürünler,
// hammadde paketleri, işçilik paketleri). Kalemler bellekte reçete servisiyle eklenir / değişir / çıkar (satır
// formları modal); Onayla Service.BusinessSaveWithDetails ile başlık ve tüm listeleri tek transaction'da yazar.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Vcl.ComCtrls, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  PrdBom.Service, PrdBom,
  PrdBomRaw, PrdBomRaw.Service, PrdBomLabour, PrdBomLabour.Service, PrdBomByProduct, PrdBomByProduct.Service,
  PrdBomPacketRaw, PrdBomPacketRaw.Service, PrdBomPacketLabour, PrdBomPacketLabour.Service;

type
  TfrmPrdBomDetail = class(TfrmInputDetailedDB<TPrdBom, TPrdBomService>)
    pnlContent: TPanel;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblBomName: TLabel;
    edtBomName: TEdit;
    lblBaseQuantity: TLabel;
    edtBaseQuantity: TEdit;
    lblIsDefault: TLabel;
    chkIsDefault: TCheckBox;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FPageRaws: TTabSheet;
    FRaws: TDetailSet<TPrdBomRaw>;
    FPageLabours: TTabSheet;
    FLabours: TDetailSet<TPrdBomLabour>;
    FPageByProducts: TTabSheet;
    FByProducts: TDetailSet<TPrdBomByProduct>;
    FPagePacketRaws: TTabSheet;
    FPacketRaws: TDetailSet<TPrdBomPacketRaw>;
    FPagePacketLabours: TTabSheet;
    FPacketLabours: TDetailSet<TPrdBomPacketLabour>;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, Grid.Types, ufrmPrdBomRaw, ufrmPrdBomLabour, ufrmPrdBomByProduct, ufrmPrdBomPacketRaw, ufrmPrdBomPacketLabour,
  StkInventory, StkInventory.Service, ufrmStkInventories;                       // TfrmStkInventories helper output form

procedure TfrmPrdBomDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.BomName := edtBomName.Text;
  Table.BaseQuantity := StrToCurrDef(edtBaseQuantity.Text, 0);
  Table.IsDefault := chkIsDefault.Checked;
  Table.IsActive := chkIsActive.Checked;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPrdBomDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtBomName.thsInputDataType := itString;
  edtBaseQuantity.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;

  // Hammaddeler = Table.Raws (ana liste; satır no sırasıyla)
  FPageRaws := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuRaws, 'Raw Materials'));
  FRaws := AddDetail<TPrdBomRaw>(FPageRaws, 'vw_prd_bom_raw',
    function: TObjectList<TPrdBomRaw>
    begin
      Result := Table.Raws;
    end,
    function: TPrdBomRaw
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPrdBomRaw)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPrdBomRaw)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPrdBomRaw; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdBomRaw.Create(Self, TPrdBomRawService.Create, ALine, AMode, nil);
    end);
  FRaws.Grid.BuildData;
  FRaws.Grid.SetColumnProperty('id', 0);
  FRaws.Grid.SetColumnProperty('prd_bom_id', 0);
  FRaws.Grid.SetColumnProperty('bom_name', 0);
  FRaws.Grid.SetColumnProperty('stk_inventory_id', 0);
  FRaws.Grid.SetColumnProperty('sub_prd_bom_id', 0);
  FRaws.Grid.SetColumnProperty('inventory_code', 90);
  FRaws.Grid.SetColumnProperty('inventory_name', 220);
  FRaws.Grid.SetColumnProperty('line_no', 50);
  FRaws.Grid.SetColumnProperty('sub_bom_name', 160);

  // Labours / Costs = Table.Labours (ek liste: reçete servisinin genel kalem işlemleri)
  FPageLabours := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuLabours, 'Labours / Costs'));
  FLabours := AddDetail<TPrdBomLabour>(FPageLabours, 'vw_prd_bom_labour',
    function: TObjectList<TPrdBomLabour>
    begin
      Result := Table.Labours;
    end,
    function: TPrdBomLabour
    begin
      Result := Service.CreateItem<TPrdBomLabour>(Table, Table.Labours);
    end,
    procedure(ALine: TPrdBomLabour)
    begin
      Service.AddItem<TPrdBomLabour>(Table, Table.Labours, ALine);
    end,
    procedure(ALine: TPrdBomLabour)
    begin
      Service.RemoveItem<TPrdBomLabour>(Table.Labours, ALine);
    end,
    function(ALine: TPrdBomLabour; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdBomLabour.Create(Self, TPrdBomLabourService.Create, ALine, AMode, nil);
    end);
  FLabours.Grid.BuildData;
  FLabours.Grid.SetColumnProperty('id', 0);
  FLabours.Grid.SetColumnProperty('prd_bom_id', 0);
  FLabours.Grid.SetColumnProperty('bom_name', 0);
  FLabours.Grid.SetColumnProperty('prd_labour_id', 0);
  FLabours.Grid.SetColumnProperty('labour_code', 90);
  FLabours.Grid.SetColumnProperty('labour_name', 220);
  FLabours.Grid.SetColumnProperty('line_no', 50);

  // By-products = Table.ByProducts (ek liste: reçete servisinin genel kalem işlemleri)
  FPageByProducts := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuByProducts, 'By-products'));
  FByProducts := AddDetail<TPrdBomByProduct>(FPageByProducts, 'vw_prd_bom_by_product',
    function: TObjectList<TPrdBomByProduct>
    begin
      Result := Table.ByProducts;
    end,
    function: TPrdBomByProduct
    begin
      Result := Service.CreateItem<TPrdBomByProduct>(Table, Table.ByProducts);
    end,
    procedure(ALine: TPrdBomByProduct)
    begin
      Service.AddItem<TPrdBomByProduct>(Table, Table.ByProducts, ALine);
    end,
    procedure(ALine: TPrdBomByProduct)
    begin
      Service.RemoveItem<TPrdBomByProduct>(Table.ByProducts, ALine);
    end,
    function(ALine: TPrdBomByProduct; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdBomByProduct.Create(Self, TPrdBomByProductService.Create, ALine, AMode, nil);
    end);
  FByProducts.Grid.BuildData;
  FByProducts.Grid.SetColumnProperty('id', 0);
  FByProducts.Grid.SetColumnProperty('prd_bom_id', 0);
  FByProducts.Grid.SetColumnProperty('bom_name', 0);
  FByProducts.Grid.SetColumnProperty('stk_inventory_id', 0);
  FByProducts.Grid.SetColumnProperty('inventory_code', 90);
  FByProducts.Grid.SetColumnProperty('inventory_name', 220);
  FByProducts.Grid.SetColumnProperty('line_no', 50);

  // Raw Material Packets = Table.PacketRaws (ek liste: reçete servisinin genel kalem işlemleri)
  FPagePacketRaws := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketRaws, 'Raw Material Packets'));
  FPacketRaws := AddDetail<TPrdBomPacketRaw>(FPagePacketRaws, 'vw_prd_bom_packet_raw',
    function: TObjectList<TPrdBomPacketRaw>
    begin
      Result := Table.PacketRaws;
    end,
    function: TPrdBomPacketRaw
    begin
      Result := Service.CreateItem<TPrdBomPacketRaw>(Table, Table.PacketRaws);
    end,
    procedure(ALine: TPrdBomPacketRaw)
    begin
      Service.AddItem<TPrdBomPacketRaw>(Table, Table.PacketRaws, ALine);
    end,
    procedure(ALine: TPrdBomPacketRaw)
    begin
      Service.RemoveItem<TPrdBomPacketRaw>(Table.PacketRaws, ALine);
    end,
    function(ALine: TPrdBomPacketRaw; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdBomPacketRaw.Create(Self, TPrdBomPacketRawService.Create, ALine, AMode, nil);
    end);
  FPacketRaws.Grid.BuildData;
  FPacketRaws.Grid.SetColumnProperty('id', 0);
  FPacketRaws.Grid.SetColumnProperty('prd_bom_id', 0);
  FPacketRaws.Grid.SetColumnProperty('bom_name', 0);
  FPacketRaws.Grid.SetColumnProperty('prd_packet_raw_id', 0);
  FPacketRaws.Grid.SetColumnProperty('line_no', 50);
  FPacketRaws.Grid.SetColumnProperty('packet_name', 260);

  // Labour Packets = Table.PacketLabours (ek liste: reçete servisinin genel kalem işlemleri)
  FPagePacketLabours := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketLabours, 'Labour Packets'));
  FPacketLabours := AddDetail<TPrdBomPacketLabour>(FPagePacketLabours, 'vw_prd_bom_packet_labour',
    function: TObjectList<TPrdBomPacketLabour>
    begin
      Result := Table.PacketLabours;
    end,
    function: TPrdBomPacketLabour
    begin
      Result := Service.CreateItem<TPrdBomPacketLabour>(Table, Table.PacketLabours);
    end,
    procedure(ALine: TPrdBomPacketLabour)
    begin
      Service.AddItem<TPrdBomPacketLabour>(Table, Table.PacketLabours, ALine);
    end,
    procedure(ALine: TPrdBomPacketLabour)
    begin
      Service.RemoveItem<TPrdBomPacketLabour>(Table.PacketLabours, ALine);
    end,
    function(ALine: TPrdBomPacketLabour; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPrdBomPacketLabour.Create(Self, TPrdBomPacketLabourService.Create, ALine, AMode, nil);
    end);
  FPacketLabours.Grid.BuildData;
  FPacketLabours.Grid.SetColumnProperty('id', 0);
  FPacketLabours.Grid.SetColumnProperty('prd_bom_id', 0);
  FPacketLabours.Grid.SetColumnProperty('bom_name', 0);
  FPacketLabours.Grid.SetColumnProperty('prd_packet_labour_id', 0);
  FPacketLabours.Grid.SetColumnProperty('line_no', 50);
  FPacketLabours.Grid.SetColumnProperty('packet_name', 260);
end;

procedure TfrmPrdBomDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtBomName.CanFocus then
    edtBomName.SetFocus;
end;

procedure TfrmPrdBomDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.TitleSingular, 'BoM');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColStkInventoryId, 'Product');
  lblBomName.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBomName, 'BoM Name');
  lblBaseQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBaseQuantity, 'Base Quantity');
  lblIsDefault.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsDefault, 'Default BoM');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsActive, 'Active');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.ColDescription, 'Description');

  if Assigned(FPageRaws) then
    FPageRaws.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuRaws, 'Raw Materials');
  if Assigned(FRaws) then
  begin
    FRaws.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColLineNo, 'Line No'));
    FRaws.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColInventoryCode, 'Inventory Code'));
    FRaws.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColInventoryName, 'Inventory Name'));
    FRaws.Grid.SetColumnTitle('sub_bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColSubBomName, 'Sub Bom Name'));
    FRaws.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColQuantity, 'Quantity'));
    FRaws.Grid.SetColumnTitle('scrap_rate', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColScrapRate, 'Scrap Rate'));
    FRaws.Grid.SetColumnTitle('gross_quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomRaw.ColGrossQuantity, 'Gross Quantity'));
  end;

  if Assigned(FPageLabours) then
    FPageLabours.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuLabours, 'Labours / Costs');
  if Assigned(FLabours) then
  begin
    FLabours.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColLineNo, 'Line No'));
    FLabours.Grid.SetColumnTitle('labour_code', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColLabourCode, 'Labour Code'));
    FLabours.Grid.SetColumnTitle('labour_name', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColLabourName, 'Labour Name'));
    FLabours.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColQuantity, 'Quantity'));
    FLabours.Grid.SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColUnitPrice, 'Unit Price'));
    FLabours.Grid.SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColCurrency, 'Currency'));
    FLabours.Grid.SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColTotalAmount, 'Total Amount'));
  end;

  if Assigned(FPageByProducts) then
    FPageByProducts.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuByProducts, 'By-products');
  if Assigned(FByProducts) then
  begin
    FByProducts.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColLineNo, 'Line No'));
    FByProducts.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColInventoryCode, 'Inventory Code'));
    FByProducts.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColInventoryName, 'Inventory Name'));
    FByProducts.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomByProduct.ColQuantity, 'Quantity'));
  end;

  if Assigned(FPagePacketRaws) then
    FPagePacketRaws.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketRaws, 'Raw Material Packets');
  if Assigned(FPacketRaws) then
  begin
    FPacketRaws.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColLineNo, 'Line No'));
    FPacketRaws.Grid.SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColPacketName, 'Packet Name'));
    FPacketRaws.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketRaw.ColQuantity, 'Quantity'));
  end;

  if Assigned(FPagePacketLabours) then
    FPagePacketLabours.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.MenuPacketLabours, 'Labour Packets');
  if Assigned(FPacketLabours) then
  begin
    FPacketLabours.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColLineNo, 'Line No'));
    FPacketLabours.Grid.SetColumnTitle('packet_name', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColPacketName, 'Packet Name'));
    FPacketLabours.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomPacketLabour.ColQuantity, 'Quantity'));
  end;
end;

procedure TfrmPrdBomDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtStkInventoryId.Name then
  begin
    LFrmStkInventoryId := TfrmStkInventories.Create(LEdit, TStkInventoryService.Create, TStkInventory.Create);
    try
      LFrmStkInventoryId.IsHelper := True;
      LFrmStkInventoryId.ShowModal;
      if LFrmStkInventoryId.DataTransfer then
        if LFrmStkInventoryId.CleanAndClose then
        begin
          Table.StkInventoryId := 0;
          Table.InventoryName := '';
          Table.InventoryCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          LEdit.Text := Table.InventoryName;
        end;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

procedure TfrmPrdBomDetail.RefreshData;
begin
  inherited;
  edtStkInventoryId.Text := Table.InventoryName;
  edtBomName.Text := Table.BomName;
  edtBaseQuantity.Text := CurrToStr(Table.BaseQuantity);
  chkIsDefault.Checked := Table.IsDefault;
  chkIsActive.Checked := Table.IsActive;
  edtDescription.Text := Table.Description;
end;

end.
