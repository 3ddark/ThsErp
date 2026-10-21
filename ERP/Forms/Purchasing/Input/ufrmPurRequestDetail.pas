unit ufrmPurRequestDetail;

// Satın alma talebi: başlık (pur_request) + kalemler (Table.Lines, pur_request_detail) tek ekranda. Kalemler bellekte
// talep servisiyle eklenir / değişir / çıkar (satır formu TfrmPurRequestLine); Onayla Service.BusinessSaveWithDetails
// ile başlık ve kalemleri tek transaction'da yazar. Başlık ve kalemler yalnız taslakta değişir.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  PurRequest.Service, PurRequest, PurRequestDetail.Service, PurRequestDetail;

type
  TfrmPurRequestDetail = class(TfrmInputDetailedDB<TPurRequest, TPurRequestService>)
    pnlContent: TPanel;
    lblRequestNo: TLabel;
    edtRequestNo: TEdit;
    lblRequestDate: TLabel;
    edtRequestDate: TEdit;
    lblEmpEmployeeId: TLabel;
    edtEmpEmployeeId: TEdit;
    lblRequiredDate: TLabel;
    edtRequiredDate: TEdit;
    lblStatusText: TLabel;
    edtStatusText: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FPageLines: TTabSheet;
    FLines: TDetailSet<TPurRequestDetail>;
  protected
    // kalemler yalnız taslak talepte değişir
    function DetailsEditable: Boolean; override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache,
  PurLookup, Grid.Types, ufrmPurRequestLine,
  EmpEmployee, EmpEmployee.Service, ufrmEmpEmployees;     // TfrmEmpEmployees helper output form

procedure TfrmPurRequestDetail.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.RequestNo := edtRequestNo.Text;
  Table.RequestDate := StrToDateDef(edtRequestDate.Text, 0);
  Table.RequiredDate := StrToDateDef(edtRequiredDate.Text, 0);
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmPurRequestDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtRequestNo.thsInputDataType := itString;
  edtRequestNo.CharCase := TEditCharCase.ecUpperCase;
  edtRequestDate.thsInputDataType := itDate;
  edtEmpEmployeeId.OnHelperProcess := HelperProcess;
  edtRequiredDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar talep servisinde,
  // satır formu modal, kayıt talebe birlikte
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuLines, 'Lines'));
  FLines := AddDetail<TPurRequestDetail>(FPageLines, 'vw_pur_request_detail',
    function: TObjectList<TPurRequestDetail>
    begin
      Result := Table.Lines;
    end,
    function: TPurRequestDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TPurRequestDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TPurRequestDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TPurRequestDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmPurRequestLine.Create(Self, TPurRequestDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('quantity', atSum, TDecimalPlaces.DisplayFormat(TDecimalPlaces.Quantity));
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('pur_request_id', 0);
  FLines.Grid.SetColumnProperty('stk_inventory_id', 0);
  FLines.Grid.SetColumnProperty('request_no', 0);
  FLines.Grid.SetColumnProperty('request_status', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('inventory_code', 90);
  FLines.Grid.SetColumnProperty('inventory_name', 220);
  FLines.Grid.SetColumnProperty('uom_code', 50);
  FLines.Grid.SetColumnProperty('description', 180);
end;

procedure TfrmPurRequestDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtRequestDate.CanFocus then
    edtRequestDate.SetFocus;
end;

function TfrmPurRequestDetail.DetailsEditable: Boolean;
begin
  Result := inherited DetailsEditable and Assigned(Table) and (Table.Status = PUR_REQ_DRAFT);
end;

procedure TfrmPurRequestDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.TitleSingular, 'Purchase Request');
  lblRequestNo.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequestNo, 'Request No');
  lblRequestDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequestDate, 'Request Date');
  lblEmpEmployeeId.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColEmpEmployeeId, 'Requested By');
  lblRequiredDate.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequiredDate, 'Required Date');
  lblStatusText.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColStatus, 'Status');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.ColDescription, 'Description');

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColInventoryCode, 'Stock Code'));
    FLines.Grid.SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColInventoryName, 'Stock Name'));
    FLines.Grid.SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColUomCode, 'Unit'));
    FLines.Grid.SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColQuantity, 'Quantity'));
    FLines.Grid.SetColumnTitle('ordered_quantity', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColOrderedQuantity, 'Ordered Quantity'));
    FLines.Grid.SetColumnTitle('remaining_quantity', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRemainingQuantity, 'Remaining'));
    FLines.Grid.SetColumnTitle('required_date', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColRequiredDate, 'Required Date'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurRequestDetail.ColDescription, 'Description'));
  end;
end;

procedure TfrmPurRequestDetail.HelperProcess(Sender: TObject);
var
  LEdit: TEdit;
  LFrmEmpEmployeeId: TfrmEmpEmployees;
begin
  if not (Sender is TEdit) then
    Exit;
  LEdit := (Sender as TEdit);
  if LEdit.Name = edtEmpEmployeeId.Name then
  begin
    LFrmEmpEmployeeId := TfrmEmpEmployees.Create(LEdit, TEmpEmployeeService.Create, TEmpEmployee.Create);
    try
      LFrmEmpEmployeeId.IsHelper := True;
      LFrmEmpEmployeeId.ShowModal;
      if LFrmEmpEmployeeId.DataTransfer then
        if LFrmEmpEmployeeId.CleanAndClose then
        begin
          Table.EmpEmployeeId := 0;
          Table.EmployeeName := '';
          LEdit.Clear;
        end
        else
        begin
          Table.EmpEmployeeId := LFrmEmpEmployeeId.Table.Id;
          Table.EmployeeName := LFrmEmpEmployeeId.Table.FullName;
          LEdit.Text := Table.EmployeeName;
        end;
    finally
      LFrmEmpEmployeeId.Free;
    end;
  end;
end;

procedure TfrmPurRequestDetail.RefreshData;
begin
  inherited;
  edtRequestNo.Text := Table.RequestNo;
  if Table.RequestDate > 0 then
    edtRequestDate.Text := DateToStr(Table.RequestDate)
  else
    edtRequestDate.Text := '';
  edtEmpEmployeeId.Text := Table.EmployeeName;
  if Table.RequiredDate > 0 then
    edtRequiredDate.Text := DateToStr(Table.RequiredDate)
  else
    edtRequiredDate.Text := '';
  edtStatusText.Text := TPurLookup.Text(plkRequestStatus, Table.Status);
  edtDescription.Text := Table.Description;
end;

end.
