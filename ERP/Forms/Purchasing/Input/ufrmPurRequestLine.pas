unit ufrmPurRequestLine;

// Talep kalemi satır formu (TfrmPurRequestDetail'den modal): bellekteki satırı düzenler, DB'ye talep ile birlikte yazılır.
// Girilenler: sıra no, stok, miktar (ölçü birimi yanında), gerekli tarih. Sipariş edilen / kalan miktar panelde.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputLineDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurRequestDetail.Service, PurRequestDetail;

type
  TfrmPurRequestLine = class(TfrmInputLineDB<TPurRequestDetail, TPurRequestDetailService>)
    pnlContent: TPanel;
    lblLineNo: TLabel;
    edtLineNo: TEdit;
    lblStkInventoryId: TLabel;
    edtStkInventoryId: TEdit;
    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUomCode: TLabel;
    lblRequiredDate: TLabel;
    edtRequiredDate: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    procedure ShowAmounts;
  protected
    procedure PrepareLine; override;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache,
  StkInventory, StkInventory.Service, ufrmStkInventories;   // TfrmStkInventories helper output form

const
  ROW_ORDERED = 'ordered';
  ROW_REMAINING = 'remaining';

procedure TfrmPurRequestLine.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır; talep (pur_request_id) ana formdan gelir
  Table.LineNo := StrToIntDef(edtLineNo.Text, 0);
  Table.Quantity := StrToCurrDef(edtQuantity.Text, 0);
  Table.RequiredDate := StrToDateDef(edtRequiredDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

// Kabul: alan kontrolleri (servisin belge kaydıyla aynı kurallar)
procedure TfrmPurRequestLine.PrepareLine;
begin
  inherited;
  TPurRequestDetailService.CheckLine(Table);
end;

procedure TfrmPurRequestLine.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtLineNo.thsInputDataType := itInteger;
  edtStkInventoryId.OnHelperProcess := HelperProcess;
  edtQuantity.thsInputDataType := itFloat;
  edtQuantity.thsDecimalDigitCount := TDecimalPlaces.Quantity;
  edtRequiredDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;

  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_ORDERED);
  FTotals.AddRow(ROW_REMAINING);
  pnlTotals.Height := FTotals.RequiredHeight;
end;

destructor TfrmPurRequestLine.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmPurRequestLine.FormShow(Sender: TObject);
begin
  inherited;
  if edtStkInventoryId.CanFocus then
    edtStkInventoryId.SetFocus;
end;

procedure TfrmPurRequestLine.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.TitleSingular, 'Request Line');
  lblLineNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColLineNo, 'Line No');
  lblStkInventoryId.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColStkInventoryId, 'Stock Card');
  lblQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColQuantity, 'Quantity');
  lblRequiredDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRequiredDate, 'Required Date');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_ORDERED, TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColOrderedQuantity, 'Ordered Quantity'));
    FTotals.SetCaption(ROW_REMAINING, TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRemainingQuantity, 'Remaining'));
  end;
end;

procedure TfrmPurRequestLine.ShowAmounts;
var
  LRemaining: Currency;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  LRemaining := StrToCurrDef(edtQuantity.Text, 0) - Table.OrderedQuantity;
  if LRemaining < 0 then
    LRemaining := 0;
  FTotals.SetValue(ROW_ORDERED, Table.OrderedQuantity, Table.UomCode, -1);
  FTotals.SetValue(ROW_REMAINING, LRemaining, Table.UomCode, -1);
end;

procedure TfrmPurRequestLine.HelperProcess(Sender: TObject);
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
          Table.UomCode := Service.GetUomCode(Table.StkInventoryId);
          LEdit.Text := Table.InventoryName;
        end;
      lblUomCode.Caption := Table.UomCode;
      ShowAmounts;
    finally
      LFrmStkInventoryId.Free;
    end;
  end;
end;

procedure TfrmPurRequestLine.RefreshData;
begin
  inherited;
  edtLineNo.Text := IntToStr(Table.LineNo);
  edtStkInventoryId.Text := Table.InventoryName;
  edtQuantity.Text := CurrToStr(Table.Quantity);
  lblUomCode.Caption := Table.UomCode;
  if Table.RequiredDate > 0 then
    edtRequiredDate.Text := DateToStr(Table.RequiredDate)
  else
    edtRequiredDate.Text := '';
  edtDescription.Text := Table.Description;
  ShowAmounts;
end;

end.
