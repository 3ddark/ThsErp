unit ufrmPurReceiptDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurReceiptDetail.Service, PurReceiptDetail;

type
  TfrmPurReceiptDetail = class(TfrmInputSimpleDB<TPurReceiptDetail, TPurReceiptDetailService>)
    pnlContent: TPanel;
    lblPurReceiptId: TLabel;
    edtPurReceiptId: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUomCode: TLabel;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FillInventoryDefaults;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup,
  PurReceipt, PurReceipt.Service, ufrmPurReceipts,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmPurReceiptDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurReceiptDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPurReceiptId.OnHelperProcess := HelperProcess;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmPurReceiptDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmPurReceiptDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.TitleSingular, 'Receipt Line');
  lblPurReceiptId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColPurReceiptId, 'Goods Receipt');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColUnitPrice, 'Unit Cost');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurReceiptDetail.ColDescription, 'Description');
end;

procedure TfrmPurReceiptDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmPurReceiptId: TfrmPurReceipts;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPurReceiptId.Name then
  begin
    LFrmPurReceiptId := TfrmPurReceipts.Create(LEdit, TPurReceiptService.Create, TPurReceipt.Create);
    try
      LFrmPurReceiptId.IsHelper := True;
      LFrmPurReceiptId.ShowModal;
      if LFrmPurReceiptId.DataTransfer then
        if LFrmPurReceiptId.CleanAndClose then
        begin
          Table.PurReceiptId := 0;
          Table.ReceiptNo := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.PurReceiptId := LFrmPurReceiptId.Table.Id;
          Table.ReceiptNo := LFrmPurReceiptId.Table.ReceiptNo;
          Table.Currency := LFrmPurReceiptId.Table.Currency;
          LEdit.Text := Table.ReceiptNo;
        end;
    finally
      LFrmPurReceiptId.Free;
    end;
  end
  else if LEdit.Name = edtStkInventoryId.Name then
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
          Table.UomCode := Service.GetUomCode(Table.StkInventoryId);
          LEdit.Text := Table.InventoryName;
        end;
      lblUomCode.Caption := Table.UomCode;
      // Stok seçilince alış fiyatı (iskontolu) birim maliyet olarak önerilir
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
        FillInventoryDefaults;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının iskontolu alış fiyatı (belge para biriminde ise) birim maliyet olarak önerilir
procedure TfrmPurReceiptDetail.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice - LPrice * LDiscount / 100);
end;

procedure TfrmPurReceiptDetail.RefreshData;
begin
  inherited;
  edtPurReceiptId.Text := Table.ReceiptNo;
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  lblUomCode.Caption := Table.UomCode;
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDescription.Text := Table.Description;
end;

end.
