unit ufrmAccVouchers;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccVoucher.Service, AccVoucher, ufrmAccVoucherDetail;

type
  TfrmAccVouchers = class(TfrmGrid<TAccVoucher, TAccVoucherService>)
  private
    procedure VoucherTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, Grid.Types, AccLookup;

procedure TfrmAccVouchers.VoucherTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TAccLookup.Text(alkVoucherType, Sender.AsInteger);
end;

// Belge ekranı (başlık + kalemler); kopyada belge formu Service.PrepareCopy ile yeni no / yeni kalemler verir
function TfrmAccVouchers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccVoucherDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccVoucherDetail.Create(Self, Service, TAccVoucher.Create, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccVouchers.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  LField := Grd.DataSource.DataSet.FindField('voucher_type');
  if Assigned(LField) then
    LField.OnGetText := VoucherTypeGetText;
end;

procedure TfrmAccVouchers.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('total_debit', atSum, TDecimalPlaces.TotalFormat);
  AddFooterColumn('total_credit', atSum, TDecimalPlaces.TotalFormat);
end;

procedure TfrmAccVouchers.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccVouchers.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.TitlePlural, 'Accounting Vouchers');
  SetColumnTitle('voucher_no', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColVoucherNo, 'Voucher No'));
  SetColumnTitle('voucher_date', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColVoucherDate, 'Voucher Date'));
  SetColumnTitle('voucher_type', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColVoucherType, 'Voucher Type'));
  SetColumnTitle('journal_no', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColJournalNo, 'Journal No'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColDescription, 'Description'));
  SetColumnTitle('total_debit', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColTotalDebit, 'Total Debit'));
  SetColumnTitle('total_credit', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColTotalCredit, 'Total Credit'));
  SetColumnTitle('line_count', TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColLineCount, 'Lines'));
end;

end.
