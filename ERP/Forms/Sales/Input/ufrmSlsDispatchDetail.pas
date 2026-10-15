unit ufrmSlsDispatchDetail;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SlsDispatchDetail.Service, SlsDispatchDetail;

type
  TfrmSlsDispatchDetail = class(TfrmInputSimpleDB<TSlsDispatchDetail, TSlsDispatchDetailService>)
    pnlContent: TPanel;
    lblSlsDispatchId: TLabel;
    edtSlsDispatchId: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
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
  SlsLookup,
  SlsDispatch, SlsDispatch.Service, ufrmSlsDispatches,
  StkInventory, StkInventory.Service, ufrmStkInventories;

procedure TfrmSlsDispatchDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.UnitPrice := StrToCurrDef(edtUnitPrice.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmSlsDispatchDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtSlsDispatchId.OnHelperProcess := HelperProcess;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtUnitPrice.thsInputDataType := itFloat;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmSlsDispatchDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmSlsDispatchDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.TitleSingular, 'Delivery Note Line');
  lblSlsDispatchId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColSlsDispatchId, 'Delivery Note');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColQuantity, 'Quantity');
  lblUnitPrice.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColUnitPrice, 'Net Unit Price');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TSlsDispatchDetail.ColDescription, 'Description');
end;

procedure TfrmSlsDispatchDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmSlsDispatchId: TfrmSlsDispatches;
  LFrmStkInventoryId: TfrmStkInventories;
begin
  if not (Sender is TEdit) then
    Exit;

  LEdit := (Sender as TEdit);
  if LEdit.Name = edtSlsDispatchId.Name then
  begin
    LFrmSlsDispatchId := TfrmSlsDispatches.Create(LEdit, TSlsDispatchService.Create, TSlsDispatch.Create);
    try
      LFrmSlsDispatchId.IsHelper := True;
      LFrmSlsDispatchId.ShowModal;
      if LFrmSlsDispatchId.DataTransfer then
        if LFrmSlsDispatchId.CleanAndClose then
        begin
          Table.SlsDispatchId := 0;
          Table.DispatchNo := '';
          Table.Currency := '';
          LEdit.Clear;
        end
        else
        begin
          Table.SlsDispatchId := LFrmSlsDispatchId.Table.Id;
          Table.DispatchNo := LFrmSlsDispatchId.Table.DispatchNo;
          Table.Currency := LFrmSlsDispatchId.Table.Currency;
          LEdit.Text := Table.DispatchNo;
        end;
    finally
      LFrmSlsDispatchId.Free;
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
          LEdit.Clear;
        end
        else
        begin
          Table.StkInventoryId := LFrmStkInventoryId.Table.Id;
          Table.InventoryCode := LFrmStkInventoryId.Table.Code;
          Table.InventoryName := LFrmStkInventoryId.Table.Name;
          LEdit.Text := Table.InventoryName;
        end;
      // Stok seçilince iskontolu satış fiyatı önerilir
      if LFrmStkInventoryId.DataTransfer and not LFrmStkInventoryId.CleanAndClose then
        FillInventoryDefaults;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

// Stok kartının iskontolu satış fiyatı (belge para biriminde ise) net birim fiyat olarak önerilir
procedure TfrmSlsDispatchDetail.FillInventoryDefaults;
var
  LPrice, LDiscount, LVat: Currency;
  LCurrency: string;
begin
  if not Service.GetInventoryDefaults(Table.StkInventoryId, LPrice, LCurrency, LDiscount, LVat) then
    Exit;
  if (Table.Currency = '') or (LCurrency = Table.Currency) then
    edtUnitPrice.Text := CurrToStr(LPrice - LPrice * LDiscount / 100);
end;

procedure TfrmSlsDispatchDetail.RefreshData;
begin
  inherited;
  edtSlsDispatchId.Text := Table.DispatchNo;
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  edtUnitPrice.Text := CurrToStr(Table.UnitPrice);
  edtDescription.Text := Table.Description;
end;

end.
