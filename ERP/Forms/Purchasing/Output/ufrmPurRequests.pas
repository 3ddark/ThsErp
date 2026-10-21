unit ufrmPurRequests;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PurRequest.Service, PurRequest, ufrmPurRequestDetail;

type
  TfrmPurRequests = class(TfrmGrid<TPurRequest, TPurRequestService>)
  private
    FmniApprove, FmniToDraft, FmniReject, FmniClose, FmniToOrder: TMenuItem;
    procedure mniApproveClick(Sender: TObject);
    procedure mniToDraftClick(Sender: TObject);
    procedure mniRejectClick(Sender: TObject);
    procedure mniCloseClick(Sender: TObject);
    procedure mniToOrderClick(Sender: TObject);
    procedure SetStatus(AStatus: SmallInt);
    procedure StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PurLookup,
  ufrmPurOrderDetail, PurOrder, PurOrder.Service,
  AccAccount, AccAccount.Service, ufrmAccAccounts;

procedure TfrmPurRequests.StatusGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPurLookup.Text(plkRequestStatus, Sender.AsInteger);
end;
procedure TfrmPurRequests.SetStatus(AStatus: SmallInt);
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  Service.ChangeStatus(Table.Id, AStatus, True);
  RefreshParentGrid(True);
end;

procedure TfrmPurRequests.mniApproveClick(Sender: TObject);
begin
  SetStatus(PUR_REQ_APPROVED);
end;

procedure TfrmPurRequests.mniToDraftClick(Sender: TObject);
begin
  SetStatus(PUR_REQ_DRAFT);
end;

procedure TfrmPurRequests.mniRejectClick(Sender: TObject);
begin
  SetStatus(PUR_REQ_REJECTED);
end;

procedure TfrmPurRequests.mniCloseClick(Sender: TObject);
begin
  SetStatus(PUR_REQ_CLOSED);
end;

// Tedarikçi seçilir, talebin kalan miktarlarıyla taslak sipariş açılır ve belge ekranında gösterilir
procedure TfrmPurRequests.mniToOrderClick(Sender: TObject);
var
  LHelper: TfrmAccAccounts;
  LOrderSvc: TPurOrderService;
  LOrder: TPurOrder;
  LOrderId: Int64;
  LFrm: TfrmPurOrderDetail;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LOrderId := 0;
  LHelper := TfrmAccAccounts.Create(Self, TAccAccountService.Create, TAccAccount.Create);
  try
    LHelper.IsHelper := True;
    LHelper.ShowModal;
    if LHelper.DataTransfer and not LHelper.CleanAndClose then
    begin
      LOrderSvc := TPurOrderService.Create;
      try
        LOrderId := LOrderSvc.CreateFromRequest(Table.Id, LHelper.Table.Id, True);
      finally
        LOrderSvc.Free;
      end;
    end;
  finally
    LHelper.Free;
  end;
  if LOrderId > 0 then
  begin
    // oluşan taslak sipariş belge ekranında (inceleme; Güncelle ile kalemler düzenlenir)
    LOrderSvc := TPurOrderService.Create;
    LOrder := LOrderSvc.FindById(LOrderId, False, True);
    LFrm := TfrmPurOrderDetail.Create(Self, LOrderSvc, LOrder, ifmRewiev, nil, ivmNormal, True);
    LFrm.Show;
    RefreshParentGrid(True);
  end;
end;

procedure TfrmPurRequests.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniApprove := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuApprove, 'Approve'), 'mniApprove', mniApproveClick);
  FmniToDraft := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuToDraft, 'Back to Draft'), 'mniToDraft', mniToDraftClick);
  FmniReject := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuReject, 'Reject'), 'mniReject', mniRejectClick);
  FmniClose := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuClose, 'Close'), 'mniClose', mniCloseClick);
  AddPopupMenuSpliter();
  FmniToOrder := AddMenu(TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuToOrder, 'Convert to Order...'), 'mniToOrder', mniToOrderClick);
end;

// Belge ekranı (başlık + kalemler); kopyada belge formu Service.PrepareCopy ile yeni no / taslak / yeni kalemler verir
function TfrmPurRequests.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPurRequestDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPurRequestDetail.Create(Self, Service, TPurRequest.Create, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPurRequests.SetSelectedItem;

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
  Table.EmployeeName := FieldText('employee_name');
end;

procedure TfrmPurRequests.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('emp_employee_id', 0);
  LField := Grd.DataSource.DataSet.FindField('status');
  if Assigned(LField) then
    LField.OnGetText := StatusGetText;
end;

procedure TfrmPurRequests.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPurRequests.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.TitlePlural, 'Purchase Requests');
  SetColumnTitle('request_no', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequestNo, 'Request No'));
  SetColumnTitle('request_date', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequestDate, 'Request Date'));
  SetColumnTitle('required_date', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColRequiredDate, 'Required Date'));
  SetColumnTitle('status', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColStatus, 'Status'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColDescription, 'Description'));
  SetColumnTitle('employee_name', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColEmployeeName, 'Requested By'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TPurRequest.ColLineCount, 'Lines'));
  if Assigned(FmniApprove) then
    FmniApprove.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuApprove, 'Approve');
  if Assigned(FmniToDraft) then
    FmniToDraft.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuToDraft, 'Back to Draft');
  if Assigned(FmniReject) then
    FmniReject.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuReject, 'Reject');
  if Assigned(FmniClose) then
    FmniClose.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuClose, 'Close');
  if Assigned(FmniToOrder) then
    FmniToOrder.Caption := TLocalizationManager.Translate(TLangKeys.TPurRequest.MenuToOrder, 'Convert to Order...');
end;

end.
