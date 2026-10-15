unit ufrmSysAuditLogs;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysAuditLog, SysAuditLog.Service;

type
  // İşlem geçmişi (ths_audit.audit_log): salt okunur. Varsayılan: bu firmanın (DB ailesi) aktif dönemi;
  // kayıt geçmişi: tablo + kayıt no, tüm dönemler. Çift tık / Ctrl+Enter: alan alan eski / yeni değer.
  TfrmSysAuditLogs = class(TfrmGrid<TSysAuditLog, TSysAuditLogService>)
  private
    FCaptionSuffix: string;
    FIsRecordHistory: Boolean;
    FmniSameRecord: TMenuItem;
    FmniAllPeriods: TMenuItem;
    procedure ActionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure mniSameRecordClick(Sender: TObject);
    procedure mniAllPeriodsClick(Sender: TObject);
  public
    // Aktif dönem (fn_active_period) + bu firmanın veritabanları
    procedure SetCurrentPeriod;
    // Bu firmanın tüm dönemleri
    procedure SetAllPeriods;
    // Tek kaydın geçmişi (tüm dönemler)
    procedure SetFixedRecord(const ATableName: string; ARowId: Int64; const ARecordCaption: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure PreparePopupMenu; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;

    class procedure ShowRecordHistory(AOwner: TComponent; const ATableName: string; ARowId: Int64; const ARecordCaption: string);
  end;

implementation

{$R *.dfm}

uses
  ufrmSysAuditLogDetail;

procedure TfrmSysAuditLogs.ActionGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  Text := TSysAuditLog.ActionText(Sender.AsString);
end;

procedure TfrmSysAuditLogs.SetCurrentPeriod;
var
  LPeriod: SmallInt;
begin
  LPeriod := Service.ActivePeriod;
  AddFixedFilter('db_family', Service.DbFamily);
  AddFixedFilter('period_year', LPeriod);
  FCaptionSuffix := ' - ' + IntToStr(LPeriod);
end;

procedure TfrmSysAuditLogs.SetAllPeriods;
begin
  AddFixedFilter('db_family', Service.DbFamily);
  FCaptionSuffix := ' - ' + TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuAllPeriods, 'All Periods');
end;

procedure TfrmSysAuditLogs.SetFixedRecord(const ATableName: string; ARowId: Int64; const ARecordCaption: string);
begin
  FIsRecordHistory := True;
  AddFixedFilter('db_family', Service.DbFamily);
  AddFixedFilter('table_name', ATableName);
  AddFixedFilter('record_no', ARowId);
  FCaptionSuffix := ' - ' + ARecordCaption;
end;

class procedure TfrmSysAuditLogs.ShowRecordHistory(AOwner: TComponent; const ATableName: string; ARowId: Int64; const ARecordCaption: string);
var
  LFrm: TfrmSysAuditLogs;
begin
  LFrm := TfrmSysAuditLogs.Create(AOwner, TSysAuditLogService.Create, TSysAuditLog.Create);
  LFrm.SetFixedRecord(ATableName, ARowId, ARecordCaption);
  LFrm.Show;
end;

function TfrmSysAuditLogs.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if AFormMode = ifmRewiev then
    Result := TfrmSysAuditLogDetail.CreateFor(Self, Table.Clone);
end;

procedure TfrmSysAuditLogs.PreparePopupMenu;
begin
  inherited;
  AddPopupMenuSpliter;
  FmniSameRecord := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuSameRecord, 'Full History of This Record'),
    'mniSameRecord', mniSameRecordClick);
  FmniAllPeriods := AddMenu(TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuAllPeriods, 'All Periods'),
    'mniAllPeriods', mniAllPeriodsClick);
end;

procedure TfrmSysAuditLogs.mniSameRecordClick(Sender: TObject);
var
  LTable: string;
  LRowId: Int64;
begin
  if not Qry.Active or Qry.IsEmpty then
    Exit;
  LTable := Qry.FieldByName('table_name').AsString;
  LRowId := Qry.FieldByName('record_no').AsLargeInt;
  ShowRecordHistory(Self, LTable, LRowId, LTable + ' #' + LRowId.ToString);
end;

procedure TfrmSysAuditLogs.mniAllPeriodsClick(Sender: TObject);
var
  LFrm: TfrmSysAuditLogs;
begin
  LFrm := TfrmSysAuditLogs.Create(Self, TSysAuditLogService.Create, TSysAuditLog.Create);
  LFrm.SetAllPeriods;
  LFrm.Show;
end;

procedure TfrmSysAuditLogs.DefineColumnWidths;
var
  LField: TField;
  LName: string;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('db_family', 0);
  SetColumnProperty('table_schema', 0);
  SetColumnProperty('source_id', 0);
  SetColumnProperty('old_data', 0);
  SetColumnProperty('new_data', 0);

  LField := Grd.DataSource.DataSet.FindField('action');
  if Assigned(LField) then
    LField.OnGetText := ActionGetText;

  for LName in TArray<string>.Create('changed_at', 'received_at') do
  begin
    LField := Grd.DataSource.DataSet.FindField(LName);
    if LField is TSQLTimeStampField then
      TSQLTimeStampField(LField).DisplayFormat := 'dd.mm.yyyy hh:nn:ss'
    else if LField is TDateTimeField then
      TDateTimeField(LField).DisplayFormat := 'dd.mm.yyyy hh:nn:ss';
  end;
end;

procedure TfrmSysAuditLogs.FormShow(Sender: TObject);
begin
  inherited;
  if Assigned(BtnAdd) then
    BtnAdd.Visible := False;
  if Assigned(mniDuplicate) then
    mniDuplicate.Visible := False;
  // Tek kaydın geçmişinde "bu kaydın geçmişi" anlamsız; tüm dönemler yalnız dönem listesinde
  if Assigned(FmniSameRecord) then
    FmniSameRecord.Visible := not FIsRecordHistory;
  if Assigned(FmniAllPeriods) then
    FmniAllPeriods.Visible := not FIsRecordHistory;
  ApplyLocalization;
end;

procedure TfrmSysAuditLogs.ApplyLocalization;
begin
  inherited;
  if FIsRecordHistory then
    Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.TitleRecordHistory, 'Record History') + FCaptionSuffix
  else
    Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.TitlePlural, 'Audit Log') + FCaptionSuffix;

  if Assigned(FmniSameRecord) then
    FmniSameRecord.Caption := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuSameRecord, 'Full History of This Record');
  if Assigned(FmniAllPeriods) then
    FmniAllPeriods.Caption := TLocalizationManager.Translate(TLangKeys.TSysAuditLog.MenuAllPeriods, 'All Periods');

  SetColumnTitle('changed_at',       TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColChangedAt, 'Date / Time'));
  SetColumnTitle('app_user',         TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColAppUser, 'User'));
  SetColumnTitle('action',           TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColAction, 'Action'));
  SetColumnTitle('table_name',       TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColTableName, 'Table'));
  SetColumnTitle('record_no',          TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColRecordNo, 'Record Id'));
  SetColumnTitle('changed_columns',  TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColChangedColumns, 'Changed Fields'));
  SetColumnTitle('period_year',      TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColPeriodYear, 'Period'));
  SetColumnTitle('db_name',          TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColDbName, 'Database'));
  SetColumnTitle('db_user',          TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColDbUser, 'DB User'));
  SetColumnTitle('client_addr',      TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColClientAddr, 'IP Address'));
  SetColumnTitle('application_name', TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColApplicationName, 'Application'));
  SetColumnTitle('transaction_id',   TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColTransactionId, 'Transaction Id'));
  SetColumnTitle('received_at',      TLocalizationManager.Translate(TLangKeys.TSysAuditLog.ColReceivedAt, 'Received At'));
end;

// Her listede "İşlem Geçmişi" (TfrmGrid popup): tablo tetikleyicili ve kullanıcı geçmişi okuyabiliyorsa
function RecordHistoryAvailable(const ATableName: string): Boolean;
var
  LSvc: TSysAuditLogService;
begin
  Result := False;
  if ATableName = '' then
    Exit;
  LSvc := TSysAuditLogService.Create;
  try
    Result := LSvc.IsAudited(ATableName) and LSvc.IsAuthorized(ptRead, True);
  finally
    LSvc.Free;
  end;
end;

procedure RecordHistoryShow(AOwner: TComponent; const ATableName: string; ARowId: Int64; const ARecordCaption: string);
begin
  TfrmSysAuditLogs.ShowRecordHistory(AOwner, ATableName, ARowId, ARecordCaption);
end;

initialization
  GRecordHistoryAvailable := RecordHistoryAvailable;
  GRecordHistoryShow := RecordHistoryShow;

end.
