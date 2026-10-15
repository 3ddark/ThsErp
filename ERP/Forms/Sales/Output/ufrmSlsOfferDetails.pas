unit ufrmSlsOfferDetails;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SlsOfferDetail.Service, SlsOfferDetail, ufrmSlsOfferDetail;

type
  TfrmSlsOfferDetails = class(TfrmGrid<TSlsOfferDetail, TSlsOfferDetailService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
    FFixedCurrency: string;
    procedure OfferStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure SetFixedOffer(AMasterId: Int64; const AMasterName, ACurrency: string);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SlsLookup;

procedure TfrmSlsOfferDetails.OfferStatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TSlsLookup.Text(slkOfferStatus, Sender.AsInteger);
end;
procedure TfrmSlsOfferDetails.SetFixedOffer(AMasterId: Int64; const AMasterName, ACurrency: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  FFixedCurrency := ACurrency;
  AddFixedFilter('sls_offer_id', AMasterId);
end;

function TfrmSlsOfferDetails.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TSlsOfferDetail;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSlsOfferDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TSlsOfferDetail.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.SlsOfferId := FFixedMasterId;
      LNew.OfferNo := FFixedMasterName;
      LNew.Currency := FFixedCurrency;
    end;
    Result := TfrmSlsOfferDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
  begin
    LNew := Table.Clone;
    // Kopya: yeni sıra no, sipariş edilen miktar sıfırlanır
    LNew.LineNo := 0;
    LNew.OrderedQuantity := 0;
    Result := TfrmSlsOfferDetail.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmSlsOfferDetails.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.OfferNo := FieldText('offer_no');
  Table.Currency := FieldText('currency');
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.UomCode := FieldText('uom_code');
end;

procedure TfrmSlsOfferDetails.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sls_offer_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
  SetColumnProperty('acc_account_id', 0);
  LField := Grd.DataSource.DataSet.FindField('offer_status');
  if Assigned(LField) then
    LField.OnGetText := OfferStatusGetText;
end;

procedure TfrmSlsOfferDetails.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSlsOfferDetails.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.TitlePlural, 'Offer Lines');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColLineNo, 'Line No'));
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColQuantity, 'Quantity'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('discount_rate', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountRate, 'Discount (%)'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatRate, 'VAT (%)'));
  SetColumnTitle('gross_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColGrossAmount, 'Gross Amount'));
  SetColumnTitle('discount_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDiscountAmount, 'Discount Amount'));
  SetColumnTitle('net_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColNetAmount, 'Net Amount'));
  SetColumnTitle('vat_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColVatAmount, 'VAT Amount'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColTotalAmount, 'Total'));
  SetColumnTitle('ordered_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColOrderedQuantity, 'Ordered Quantity'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColDescription, 'Description'));
  SetColumnTitle('offer_no', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColOfferNo, 'Offer No'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColCurrency, 'Currency'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColInventoryName, 'Stock Name'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColUomCode, 'Unit'));
  SetColumnTitle('remaining_quantity', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColRemainingQuantity, 'Remaining Quantity'));
  SetColumnTitle('offer_status', TLocalizationManager.Translate(TLangKeys.TSlsOfferDetail.ColOfferStatus, 'Status'));
end;

end.
