unit ufrmQcInspection;

// Giriş kalite kontrol kaydı: mal kabul kalemi (kontrol bekleyen kalemler listesinden) seçilir, uygunsuz miktar ve
// uygunsuzluk kararı girilir (uygunsuz miktar yoksa karar servisçe temizlenir). Kontrol edilen miktar mal kabul kaleminden, uygun miktar ve sonuç servisten; panelde
// gösterilir (uygunsuz miktar değiştikçe anında).

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager, Detail.Totals,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  QcInspection.Service, QcInspection;

type
  TfrmQcInspection = class(TfrmInputSimpleDB<TQcInspection, TQcInspectionService>)
    pnlContent: TPanel;
    lblInspectionNo: TLabel;
    edtInspectionNo: TEdit;
    lblInspectionDate: TLabel;
    edtInspectionDate: TEdit;
    lblPurReceiptDetailId: TLabel;
    edtPurReceiptDetailId: TEdit;
    lblRejectedQuantity: TLabel;
    edtRejectedQuantity: TEdit;
    lblRejectedUom: TLabel;
    lblDisposition: TLabel;
    cbbDisposition: TComboBox;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    procedure InputChanged(Sender: TObject);
    // Uygun miktar / sonuç girilen uygunsuz miktardan (servisle aynı hesap), Table'a yazmadan
    procedure ShowAmounts;
  public
    destructor Destroy; override;
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, QcLookup,
  QcReceiptLine, QcReceiptLine.Service, ufrmQcReceiptLines,   // TfrmQcReceiptLines helper output form
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees;         // TfrmEmpEmployees helper output form

const
  ROW_RECEIPT = 'receipt';
  ROW_SUPPLIER = 'supplier';
  ROW_INVENTORY = 'inventory';
  ROW_QUANTITY = 'quantity';
  ROW_ACCEPTED = 'accepted';
  ROW_RESULT = 'result';

procedure TfrmQcInspection.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.InspectionNo := edtInspectionNo.Text;
  Table.InspectionDate := StrToDateDef(edtInspectionDate.Text, 0);
  Table.RejectedQuantity := StrToCurrDef(edtRejectedQuantity.Text, 0);
  Table.Disposition := cbbDisposition.ItemIndex + 1;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmQcInspection.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtInspectionNo.thsInputDataType := itString;
  edtInspectionNo.CharCase := TEditCharCase.ecUpperCase;
  edtInspectionDate.thsInputDataType := itDate;
  edtPurReceiptDetailId.OnHelperProcess := HelperProcess;
  edtRejectedQuantity.thsInputDataType := itFloat;
  edtRejectedQuantity.thsDecimalDigitCount := TDecimalPlaces.Quantity;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtDescription.thsInputDataType := itString;
  edtRejectedQuantity.OnChange := InputChanged;
  TQcLookup.FillItems(cbbDisposition.Items, qlkDisposition);

  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_RECEIPT);
  FTotals.AddRow(ROW_SUPPLIER);
  FTotals.AddRow(ROW_INVENTORY);
  FTotals.AddRow(ROW_QUANTITY);
  FTotals.AddRow(ROW_ACCEPTED);
  FTotals.AddRow(ROW_RESULT, True);
  pnlTotals.Height := FTotals.RequiredHeight;
end;

destructor TfrmQcInspection.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmQcInspection.FormShow(Sender: TObject);
begin
  inherited;
  if edtRejectedQuantity.CanFocus then
    edtRejectedQuantity.SetFocus;
end;

procedure TfrmQcInspection.InputChanged(Sender: TObject);
begin
  ShowAmounts;
end;

procedure TfrmQcInspection.ShowAmounts;
var
  LCalc: TQcInspection;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  LCalc := TQcInspection.Create;
  try
    LCalc.Quantity := Table.Quantity;
    LCalc.RejectedQuantity := StrToCurrDef(edtRejectedQuantity.Text, 0);
    TQcInspectionService.CalculateResult(LCalc);
    FTotals.SetText(ROW_RECEIPT, Trim(Table.ReceiptNo + ' / ' + IntToStr(Table.ReceiptLineNo)));
    FTotals.SetText(ROW_SUPPLIER, Table.AccountName);
    FTotals.SetText(ROW_INVENTORY, Trim(Table.InventoryCode + ' ' + Table.InventoryName));
    FTotals.SetValue(ROW_QUANTITY, Table.Quantity, Table.UomCode, -1);
    FTotals.SetValue(ROW_ACCEPTED, LCalc.AcceptedQuantity, Table.UomCode, -1);
    FTotals.SetText(ROW_RESULT, TQcLookup.Text(qlkResult, LCalc.InspectionResult));
  finally
    LCalc.Free;
  end;
  lblRejectedUom.Caption := Table.UomCode;
end;

procedure TfrmQcInspection.ApplyLocalization;
var
  LIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.TitleSingular, 'Quality Inspection');
  lblInspectionNo.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInspectionNo, 'Inspection No');
  lblInspectionDate.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInspectionDate, 'Inspection Date');
  lblPurReceiptDetailId.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColPurReceiptDetailId, 'Goods Receipt Line');
  lblRejectedQuantity.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColRejectedQuantity, 'Rejected Quantity');
  lblDisposition.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColDisposition, 'Disposition');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColEmployeeName, 'Inspected By');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TQcInspection.ColDescription, 'Findings / Description');
  LIndex := cbbDisposition.ItemIndex;
  TQcLookup.FillItems(cbbDisposition.Items, qlkDisposition);
  cbbDisposition.ItemIndex := LIndex;
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_RECEIPT, TLocalizationManager.Translate(TLangKeys.TQcInspection.ColReceiptNo, 'Receipt No'));
    FTotals.SetCaption(ROW_SUPPLIER, TLocalizationManager.Translate(TLangKeys.TQcInspection.ColAccountName, 'Supplier'));
    FTotals.SetCaption(ROW_INVENTORY, TLocalizationManager.Translate(TLangKeys.TQcInspection.ColInventoryName, 'Stock Name'));
    FTotals.SetCaption(ROW_QUANTITY, TLocalizationManager.Translate(TLangKeys.TQcInspection.ColQuantity, 'Inspected Quantity'));
    FTotals.SetCaption(ROW_ACCEPTED, TLocalizationManager.Translate(TLangKeys.TQcInspection.ColAcceptedQuantity, 'Accepted Quantity'));
    FTotals.SetCaption(ROW_RESULT, TLocalizationManager.Translate(TLangKeys.TQcInspection.ColResult, 'Result'));
  end;
end;

procedure TfrmQcInspection.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmLine: TfrmQcReceiptLines;
  LFrmEmployee: TfrmEmpEmployees;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtPurReceiptDetailId.Name then
  begin
    LFrmLine := TfrmQcReceiptLines.Create(LEdit, TQcReceiptLineService.Create, TQcReceiptLine.Create);
    try
      LFrmLine.IsHelper := True;
      LFrmLine.ShowModal;
      if LFrmLine.DataTransfer then
        if LFrmLine.CleanAndClose then
        begin
          Table.PurReceiptDetailId := 0;
          Table.ReceiptNo := '';
          Table.ReceiptLineNo := 0;
          Table.AccountName := '';
          Table.InventoryCode := '';
          Table.InventoryName := '';
          Table.UomCode := '';
          Table.Quantity := 0;
          LEdit.Clear;
        end
        else
        begin
          // kontrol bekleyen kalemler listesinin id'si = mal kabul kalemi id
          Table.PurReceiptDetailId := LFrmLine.Table.Id;
          Table.PurReceiptId := LFrmLine.Table.PurReceiptId;
          Table.ReceiptNo := LFrmLine.Table.ReceiptNo;
          Table.ReceiptLineNo := LFrmLine.Table.LineNo;
          Table.AccountName := LFrmLine.Table.AccountName;
          Table.WarehouseName := LFrmLine.Table.WarehouseName;
          Table.StkInventoryId := LFrmLine.Table.StkInventoryId;
          Table.InventoryCode := LFrmLine.Table.InventoryCode;
          Table.InventoryName := LFrmLine.Table.InventoryName;
          Table.UomCode := LFrmLine.Table.UomCode;
          Table.Quantity := LFrmLine.Table.Quantity;
          LEdit.Text := Table.ReceiptNo + ' / ' + IntToStr(Table.ReceiptLineNo);
        end;
      ShowAmounts;
    finally
      LFrmLine.Free;
    end;
  end
  else if LEdit.Name = edtEmpEmployeeId.Name then
  begin
    LFrmEmployee := TfrmEmpEmployees.Create(LEdit, TEmpEmployeeService.Create, TEmpEmployee.Create);
    try
      LFrmEmployee.IsHelper := True;
      LFrmEmployee.ShowModal;
      if LFrmEmployee.DataTransfer then
        if LFrmEmployee.CleanAndClose then
        begin
          Table.EmpEmployeeId := 0;
          Table.EmployeeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpEmployeeId := LFrmEmployee.Table.Id;
          Table.EmployeeName := LFrmEmployee.Table.FullName;
          LEdit.Text := Table.EmployeeName;
        end;
    finally
      LFrmEmployee.Free;
    end;
  end;
end;

procedure TfrmQcInspection.RefreshData;
begin
  inherited;
  edtInspectionNo.Text := Table.InspectionNo;
  if Table.InspectionDate > 0 then
    edtInspectionDate.Text := DateToStr(Table.InspectionDate)
  else
    edtInspectionDate.Text := '';
  if Table.PurReceiptDetailId > 0 then
    edtPurReceiptDetailId.Text := Table.ReceiptNo + ' / ' + IntToStr(Table.ReceiptLineNo)
  else
    edtPurReceiptDetailId.Text := '';
  edtRejectedQuantity.Text := CurrToStr(Table.RejectedQuantity);
  cbbDisposition.ItemIndex := Table.Disposition - 1;
  edtEmpEmployeeId.Text := Table.EmployeeName;
  edtDescription.Text := Table.Description;
  ShowAmounts;
end;

end.
