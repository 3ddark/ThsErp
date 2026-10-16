unit ufrmSlsOfferLine;

// Teklif kalemi satır formu (TfrmSlsOfferDetail'den modal): bellekteki satırı düzenler, DB'ye teklifle birlikte yazılır

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsOfferDetail.Service, SlsOfferDetail;

type
  TfrmSlsOfferLine = class(TfrmInputLineDB<TSlsOfferDetail, TSlsOfferDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblDiscountRate: TLabel;
    edtDiscountRate: TEdit;
    lblVatRate: TLabel;
    edtVatRate: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblGrossAmount: TLabel;
    edtGrossAmount: TEdit;
    lblDiscountAmount: TLabel;
    edtDiscountAmount: TEdit;
    lblNetAmount: TLabel;
    edtNetAmount: TEdit;
    lblVatAmount: TLabel;
    edtVatAmount: TEdit;
    lblTotalAmount: TLabel;
    edtTotalAmount: TEdit;
    lblOrderedQuantity: TLabel;
    edtOrderedQuantity: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FillInventoryDefaults;
  protected
    procedure PrepareLine; override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup,
  StkInventory, StkInventory.Service, ufrmStkInventories;   // TfrmStkInventories helper output form

procedure TfrmSlsOfferLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; teklif (sls_offer_id) ana formdan gelir, formda gösterilmez
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.DiscountRate := StrToCurrDef(edtDiscountRate.Text, 0);
  Table.VatRate := StrToCurrDef(edtVatRate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

// Grid ve başlık toplamları için tutarlar bellekte de hesaplanır (kayıtta servis yeniden hesaplar)
procedure TfrmSlsOfferLine.PrepareLine;
var
  LGross, LDiscount, LNet, LVat, LTotal: Currency;
begin
  inherited;
  LGross := 0; LDiscount := 0; LNet := 0; LVat := 0; LTotal := 0;
  TSlsLookup.CalculateLine(Table.Quantity, Table.UnitPrice, Table.DiscountRate, Table.VatRate,
    LGross, LDiscount, LNet, LVat, LTotal);
  Table.GrossAmount := LGross;
  Table.DiscountAmount := LDiscount;
  Table.NetAmount := LNet;
  Table.VatAmount := LVat;
  Table.TotalAmount := LTotal;
end;

procedure TfrmSlsOfferLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDiscountRate.thsInputDataType := itFloat;
  edtVatRate.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSlsOfferLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmSlsOfferLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.TitleSingular, 'Offer Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUnitPrice, 'Unit Price');
  lblDiscountRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountRate, 'Discount (%)');
  lblVatRate.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatRate, 'VAT (%)');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDescription, 'Description');
  lblGrossAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColGrossAmount, 'Gross Amount');
  lblDiscountAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountAmount, 'Discount Amount');
  lblNetAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColNetAmount, 'Net Amount');
  lblVatAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatAmount, 'VAT Amount');
  lblTotalAmount.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColTotalAmount, 'Total');
  lblOrderedQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColOrderedQuantity, 'Ordered Quantity');
end;

procedure TfrmSlsOfferLine.HelperProcess(Sender: TObject);
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
          Table.InventoryCode := '';
          Table.InventoryName := '';
          Table.UomCode := '';
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
        FillInventoryDefaults;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının satış fiyatı (belge para biriminde ise), satış iskontosu ve geçerli KDV oranı önerilir
procedure TfrmSlsOfferLine.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice);
  edtDiscountRate.Text := CurrToStr(LDiscount);
  edtVatRate.Text := CurrToStr(LVat);
end;

procedure TfrmSlsOfferLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDiscountRate.Text := CurrToStr(Table.DiscountRate);
  edtVatRate.Text := CurrToStr(Table.VatRate);
  edtDescription.Text := Table.Description;
  edtGrossAmount.Text := CurrToStr(Table.GrossAmount);
  edtDiscountAmount.Text := CurrToStr(Table.DiscountAmount);
  edtNetAmount.Text := CurrToStr(Table.NetAmount);
  edtVatAmount.Text := CurrToStr(Table.VatAmount);
  edtTotalAmount.Text := CurrToStr(Table.TotalAmount);
  edtOrderedQuantity.Text := CurrToStr(Table.OrderedQuantity);
end;

end.
