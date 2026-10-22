unit ufrmAccVoucherDetail;

// Muhasebe fişi: başlık (acc_voucher) + kalemler (Table.Lines, acc_voucher_detail) tek ekranda. Kalemler bellekte fiş
// servisiyle eklenir / değişir / çıkar (satır formu TfrmAccVoucherLine); Onayla Service.BusinessSaveWithDetails ile
// tek transaction'da yazar (borç = alacak dengesi kayıtta denetlenir). Panelde borç / alacak toplamı ve fark.

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Generics.Collections,
  ufrmInputDetailedDB, Detail.Lines, Detail.Totals, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  AccVoucher.Service, AccVoucher, AccVoucherDetail.Service, AccVoucherDetail;

type
  TfrmAccVoucherDetail = class(TfrmInputDetailedDB<TAccVoucher, TAccVoucherService>)
    pnlContent: TPanel;
    lblVoucherNo: TLabel;
    edtVoucherNo: TEdit;
    lblVoucherDate: TLabel;
    edtVoucherDate: TEdit;
    lblVoucherType: TLabel;
    cbbVoucherType: TComboBox;
    lblJournalNo: TLabel;
    edtJournalNo: TEdit;
    lblDescription: TLabel;
    edtDescription: TEdit;
    pnlTotals: TPanel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
    FTotals: TTotalsPanel;
    FPageLines: TTabSheet;
    FLines: TDetailSet<TAccVoucherDetail>;
    procedure ShowTotals;
  protected
    procedure DetailsChanged; override;
  public
    destructor Destroy; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  SysDecimalPlace.Cache, Grid.Types, AccLookup, ufrmAccVoucherLine;

const
  ROW_DEBIT = 'debit';
  ROW_CREDIT = 'credit';
  ROW_DIFF = 'diff';

procedure TfrmAccVoucherDetail.BtnAcceptClick(Sender: TObject);
begin
  Table.VoucherNo := edtVoucherNo.Text;
  Table.VoucherDate := StrToDateDef(edtVoucherDate.Text, 0);
  Table.VoucherType := cbbVoucherType.ItemIndex + 1;
  Table.Description := edtDescription.Text;
  inherited;
end;

procedure TfrmAccVoucherDetail.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  FTotals := TTotalsPanel.Create(pnlTotals);
  FTotals.AddRow(ROW_DEBIT);
  FTotals.AddRow(ROW_CREDIT);
  FTotals.AddRow(ROW_DIFF, True);
  pnlTotals.Height := FTotals.RequiredHeight;

  edtVoucherNo.thsInputDataType := itString;
  edtVoucherNo.CharCase := TEditCharCase.ecUpperCase;
  edtVoucherDate.thsInputDataType := itDate;
  edtDescription.thsInputDataType := itString;
  TAccLookup.FillItems(cbbVoucherType.Items, alkVoucherType);

  // Kalemler = Table.Lines (servis satır no sırasıyla okur); ekle / çıkar / toplamlar fiş servisinde
  FPageLines := AddDetailPage(TLocalizationManager.Translate(TLangKeys.TAccVoucher.MenuLines, 'Lines'));
  FLines := AddDetail<TAccVoucherDetail>(FPageLines, 'vw_acc_voucher_detail',
    function: TObjectList<TAccVoucherDetail>
    begin
      Result := Table.Lines;
    end,
    function: TAccVoucherDetail
    begin
      Result := Service.CreateLine(Table);
    end,
    procedure(ALine: TAccVoucherDetail)
    begin
      Service.AddLine(Table, ALine);
    end,
    procedure(ALine: TAccVoucherDetail)
    begin
      Service.RemoveLine(Table, ALine);
    end,
    function(ALine: TAccVoucherDetail; AMode: TInputFormMode): TForm
    begin
      Result := TfrmAccVoucherLine.Create(Self, TAccVoucherDetailService.Create, ALine, AMode, nil);
    end);

  FLines.Grid.AddFooterColumn('debit', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.AddFooterColumn('credit', atSum, TDecimalPlaces.TotalFormat);
  FLines.Grid.BuildData;
  FLines.Grid.SetColumnProperty('id', 0);
  FLines.Grid.SetColumnProperty('acc_voucher_id', 0);
  FLines.Grid.SetColumnProperty('acc_account_id', 0);
  FLines.Grid.SetColumnProperty('voucher_no', 0);
  FLines.Grid.SetColumnProperty('voucher_date', 0);
  FLines.Grid.SetColumnProperty('line_no', 50);
  FLines.Grid.SetColumnProperty('account_code', 110);
  FLines.Grid.SetColumnProperty('account_name', 220);
  FLines.Grid.SetColumnProperty('description', 220);
end;

destructor TfrmAccVoucherDetail.Destroy;
begin
  FreeAndNil(FTotals);
  inherited;
end;

procedure TfrmAccVoucherDetail.FormShow(Sender: TObject);
begin
  inherited;
  if edtVoucherDate.CanFocus then
    edtVoucherDate.SetFocus;
end;

// Borç / alacak toplamları kalemlerden (servis); fark sıfır değilse kayıt reddedilir
procedure TfrmAccVoucherDetail.ShowTotals;
begin
  if not Assigned(FTotals) or not Assigned(Table) then
    Exit;
  Service.Recalculate(Table);
  // fiş ana para biriminde (para birimi gösterilmez)
  FTotals.SetValue(ROW_DEBIT, Table.TotalDebit, '');
  FTotals.SetValue(ROW_CREDIT, Table.TotalCredit, '');
  FTotals.SetValue(ROW_DIFF, Table.TotalDebit - Table.TotalCredit, '');
end;

procedure TfrmAccVoucherDetail.DetailsChanged;
begin
  inherited;
  ShowTotals;
end;

procedure TfrmAccVoucherDetail.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.TitleSingular, 'Accounting Voucher');
  lblVoucherNo.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColVoucherNo, 'Voucher No');
  lblVoucherDate.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColVoucherDate, 'Voucher Date');
  lblVoucherType.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColVoucherType, 'Voucher Type');
  lblJournalNo.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColJournalNo, 'Journal No');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColDescription, 'Description');
  if Assigned(FTotals) then
  begin
    FTotals.SetCaption(ROW_DEBIT, TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColTotalDebit, 'Total Debit'));
    FTotals.SetCaption(ROW_CREDIT, TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColTotalCredit, 'Total Credit'));
    FTotals.SetCaption(ROW_DIFF, TLocalizationManager.Translate(TLangKeys.TAccVoucher.ColDifference, 'Difference'));
  end;

  if Assigned(FPageLines) then
    FPageLines.Caption := TLocalizationManager.Translate(TLangKeys.TAccVoucher.MenuLines, 'Lines');
  if Assigned(FLines) then
  begin
    FLines.Grid.SetColumnTitle('line_no', TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColLineNo, 'Line No'));
    FLines.Grid.SetColumnTitle('account_code', TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColAccountCode, 'Account Code'));
    FLines.Grid.SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColAccountName, 'Account Name'));
    FLines.Grid.SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColDescription, 'Description'));
    FLines.Grid.SetColumnTitle('debit', TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColDebit, 'Debit'));
    FLines.Grid.SetColumnTitle('credit', TLocalizationManager.Translate(TLangKeys.TAccVoucherDetail.ColCredit, 'Credit'));
  end;
end;

procedure TfrmAccVoucherDetail.RefreshData;
begin
  inherited;
  edtVoucherNo.Text := Table.VoucherNo;
  if Table.VoucherDate > 0 then
    edtVoucherDate.Text := DateToStr(Table.VoucherDate)
  else
    edtVoucherDate.Text := '';
  cbbVoucherType.ItemIndex := Table.VoucherType - 1;
  if Table.JournalNo > 0 then
    edtJournalNo.Text := IntToStr(Table.JournalNo)
  else
    edtJournalNo.Text := '';
  edtDescription.Text := Table.Description;
  ShowTotals;
end;

end.
