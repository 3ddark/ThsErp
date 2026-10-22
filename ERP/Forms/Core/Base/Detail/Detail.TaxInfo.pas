unit Detail.TaxInfo;

// Belgenin vergi bilgisi (fatura formlarında bir detay sekmesi): üstte cari vergi bilgisi (belgedeki kopya: ünvan,
// vergi dairesi, vergi no / TCKN; salt okunur, cari kartından gelir), altta vergi dökümü (KDV oran bazında matrah /
// tutar, KDV tevkifatı kod bazında). Kontroller kodla oluşturulur; döküm kayıtlı belgenin DB özetidir
// ({belge}_tax_summary, kaydedilmemiş kalem değişikliklerini göstermez). Zorunlu bilgi eksikse kırmızı uyarı satırı
// gösterilir (alanlar kırmızı işaretlenmez: salt okunur, formun zorunlu alan kontrolüne girmemeli; kural belge servisinde).

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Ths.Helper.Edit, SysDocumentTrail;

type
  TDocumentTaxInfo = class
  private
    FGroup: TGroupBox;
    FLblTitle: TLabel;
    FLblTaxOffice: TLabel;
    FLblTaxNo: TLabel;
    FEdtTitle: TEdit;
    FEdtTaxOffice: TEdit;
    FEdtTaxNo: TEdit;
    FLblMissing: TLabel;
    FMissingNo: Boolean;
    FMissingOffice: Boolean;
    FLblSummary: TLabel;
    FList: TListView;
    FRows: TArray<TSysDocumentTaxRow>;
    FCurrency: string;
    FPerson: Boolean;
    function AddRow(AOwner: TComponent; ARow: Integer; out ALabel: TLabel): TEdit;
    procedure FillList;
  public
    // AParent: sekme; kontroller AOwner'a (form) aittir
    constructor Create(AOwner: TComponent; AParent: TWinControl);
    // ARequired: eksik vergi no (tüzel kişide vergi dairesi de) kırmızı uyarıyla gösterilir (ör. ihracat dışı satış faturası)
    procedure SetParty(const ATitle, ATaxOffice, ATaxNo: string; ATaxpayerType: Integer; ARequired: Boolean);
    procedure SetSummary(const ARows: TArray<TSysDocumentTaxRow>; const ACurrency: string);
    procedure ApplyLocalization;
  end;

implementation

uses
  LocalizationManager, AccLookup, SysDecimalPlace.Cache;

const
  ROW_TOP = 20;
  ROW_HEIGHT = 25;
  LABEL_WIDTH = 120;
  EDIT_WIDTH = 360;

constructor TDocumentTaxInfo.Create(AOwner: TComponent; AParent: TWinControl);
var
  LColumn: TListColumn;
  i: Integer;
begin
  inherited Create;
  FGroup := TGroupBox.Create(AOwner);
  FGroup.Parent := AParent;
  FGroup.Align := alTop;
  FGroup.AlignWithMargins := True;
  FGroup.Height := ROW_TOP + 4 * ROW_HEIGHT + 8;

  FEdtTitle := AddRow(AOwner, 0, FLblTitle);
  FEdtTaxOffice := AddRow(AOwner, 1, FLblTaxOffice);
  FEdtTaxNo := AddRow(AOwner, 2, FLblTaxNo);

  FLblMissing := TLabel.Create(AOwner);
  FLblMissing.Parent := FGroup;
  FLblMissing.Left := 8 + LABEL_WIDTH + 6;
  FLblMissing.Top := ROW_TOP + 3 * ROW_HEIGHT + 4;
  FLblMissing.Font.Color := clRed;
  FLblMissing.Font.Style := [fsBold];
  FLblMissing.Visible := False;

  FLblSummary := TLabel.Create(AOwner);
  FLblSummary.Parent := AParent;
  FLblSummary.Align := alTop;
  FLblSummary.Top := FGroup.Top + FGroup.Height;
  FLblSummary.AlignWithMargins := True;
  FLblSummary.Font.Style := [fsBold];

  FList := TListView.Create(AOwner);
  FList.Parent := AParent;
  FList.Align := alClient;
  FList.AlignWithMargins := True;
  FList.ViewStyle := vsReport;
  FList.ReadOnly := True;
  FList.RowSelect := True;
  FList.GridLines := True;
  for i := 0 to 4 do
  begin
    LColumn := FList.Columns.Add;
    if i in [0, 1] then
      LColumn.Width := 220
    else
    begin
      LColumn.Width := 120;
      LColumn.Alignment := taRightJustify;
    end;
  end;
  FList.Columns[1].Width := 300;
end;

function TDocumentTaxInfo.AddRow(AOwner: TComponent; ARow: Integer; out ALabel: TLabel): TEdit;
begin
  ALabel := TLabel.Create(AOwner);
  ALabel.Parent := FGroup;
  ALabel.AutoSize := False;
  ALabel.Alignment := taRightJustify;
  ALabel.Left := 8;
  ALabel.Width := LABEL_WIDTH;
  ALabel.Top := ROW_TOP + ARow * ROW_HEIGHT + 4;

  Result := TEdit.Create(AOwner);
  Result.Parent := FGroup;
  Result.Left := 8 + LABEL_WIDTH + 6;
  Result.Width := EDIT_WIDTH;
  Result.Top := ROW_TOP + ARow * ROW_HEIGHT;
  Result.ReadOnly := True;
  Result.TabStop := False;
end;

procedure TDocumentTaxInfo.SetParty(const ATitle, ATaxOffice, ATaxNo: string; ATaxpayerType: Integer; ARequired: Boolean);
begin
  FPerson := ATaxpayerType = ACC_TAXPAYER_REAL;
  FEdtTitle.Text := ATitle;
  FEdtTaxOffice.Text := ATaxOffice;
  FEdtTaxNo.Text := ATaxNo;
  FMissingNo := ARequired and (Trim(ATaxNo) = '');
  FMissingOffice := ARequired and (ATaxpayerType = ACC_TAXPAYER_LEGAL) and (Trim(ATaxOffice) = '');
  FLblMissing.Visible := FMissingNo or FMissingOffice;
  ApplyLocalization;
end;

procedure TDocumentTaxInfo.SetSummary(const ARows: TArray<TSysDocumentTaxRow>; const ACurrency: string);
begin
  FRows := ARows;
  FCurrency := ACurrency;
  FillList;
end;

procedure TDocumentTaxInfo.FillList;
var
  LRow: TSysDocumentTaxRow;
  LItem: TListItem;
  LFormat: string;
begin
  LFormat := TDecimalPlaces.TotalFormat;
  FList.Items.BeginUpdate;
  try
    FList.Items.Clear;
    for LRow in FRows do
    begin
      LItem := FList.Items.Add;
      if LRow.SummaryType = DOC_TAX_VAT_WITHHOLDING then
      begin
        LItem.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.TypeWithholding, 'VAT Withholding') +
          ' ' + LRow.WithholdingCode;
        LItem.SubItems.Add(LRow.WithholdingName);
      end
      else
      begin
        LItem.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.TypeVat, 'VAT');
        LItem.SubItems.Add('');
      end;
      LItem.SubItems.Add('%' + FormatFloat('0.##', LRow.TaxRate));
      LItem.SubItems.Add(FormatFloat(LFormat, LRow.BaseAmount) + ' ' + FCurrency);
      LItem.SubItems.Add(FormatFloat(LFormat, LRow.TaxAmount) + ' ' + FCurrency);
    end;
  finally
    FList.Items.EndUpdate;
  end;
end;

procedure TDocumentTaxInfo.ApplyLocalization;
begin
  FGroup.Caption := ' ' + TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.GroupParty, 'Customer Tax Information (as on the document)') + ' ';
  FLblTitle.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.LblTitle, 'Title');
  FLblTaxOffice.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.LblTaxOffice, 'Tax Office');
  if FPerson then
    FLblTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.LblCitizenNo, 'Citizenship No')
  else
    FLblTaxNo.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.LblTaxNo, 'Tax No');
  if FMissingNo then
    FLblMissing.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TaxNoRequired,
      'The customer has no tax / identity number. It is required on a sales invoice other than export; complete the account card.')
  else if FMissingOffice then
    FLblMissing.Caption := TLocalizationManager.Translate(TLangKeys.TSlsInvoice.TaxOfficeRequired,
      'The customer (legal entity) has no tax office. It is required on a sales invoice other than export; complete the account card.')
  else
    FLblMissing.Caption := '';
  FLblSummary.Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.LblSummary, 'Tax Breakdown (saved document)');
  FList.Columns[0].Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.ColTax, 'Tax');
  FList.Columns[1].Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.ColDescription, 'Description');
  FList.Columns[2].Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.ColRate, 'Rate');
  FList.Columns[3].Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.ColBase, 'Base');
  FList.Columns[4].Caption := TLocalizationManager.Translate(TLangKeys.TDocumentTaxInfo.ColAmount, 'Amount');
  FillList;
end;

end.
