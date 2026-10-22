unit QcLookup;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, LocalizationManager;

const
  // qc_inspection.result (DB CHECK 1-3; servis uygunsuz miktardan hesaplar)
  QC_RESULT_ACCEPTED = 1;  // uygun
  QC_RESULT_REJECTED = 2;  // uygunsuz
  QC_RESULT_PARTIAL  = 3;  // kısmen uygun

  // qc_inspection.disposition (DB CHECK 1-4; uygunsuz miktar varsa zorunlu)
  QC_DISP_RETURN      = 1;  // tedarikçiye iade
  QC_DISP_SCRAP       = 2;  // hurda
  QC_DISP_REWORK      = 3;  // yeniden işleme
  QC_DISP_CONCESSION  = 4;  // şartlı kabul

  // vw_qc_receipt_line.qc_status
  QC_STATUS_PENDING   = 1;  // kontrol bekliyor
  QC_STATUS_RECHECK   = 2;  // yeniden kontrol (mal kabul miktarı / stoğu değişti)
  QC_STATUS_DONE      = 3;  // kontrol edildi

  QC_PREFIX_INSPECTION = 'KK';

type
  // DB'de smallint olarak saklanan sabit seçenekler (1 tabanlı; 0 = seçilmemiş)
  TQcLookupKind = (qlkResult, qlkDisposition, qlkStatus);

  TQcLookup = class
  public
    class function Items(AKind: TQcLookupKind): TArray<string>;
    class function Text(AKind: TQcLookupKind; AValue: Integer): string;
    class function IsValid(AKind: TQcLookupKind; AValue: Integer): Boolean;
    class procedure FillItems(AItems: TStrings; AKind: TQcLookupKind);
  end;

implementation

class function TQcLookup.Items(AKind: TQcLookupKind): TArray<string>;
begin
  case AKind of
    qlkResult:
      Result := [TLocalizationManager.Translate(TLangKeys.TQcOption.ResAccepted, 'Accepted'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.ResRejected, 'Rejected'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.ResPartial, 'Partially Accepted')];
    qlkDisposition:
      Result := [TLocalizationManager.Translate(TLangKeys.TQcOption.DispReturn, 'Return to Supplier'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.DispScrap, 'Scrap'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.DispRework, 'Rework'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.DispConcession, 'Use As Is (Concession)')];
    qlkStatus:
      Result := [TLocalizationManager.Translate(TLangKeys.TQcOption.StatusPending, 'Awaiting Inspection'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.StatusRecheck, 'Re-inspection Needed'),
                 TLocalizationManager.Translate(TLangKeys.TQcOption.StatusDone, 'Inspected')];
  else
    Result := [];
  end;
end;

class function TQcLookup.Text(AKind: TQcLookupKind; AValue: Integer): string;
var
  LItems: TArray<string>;
begin
  LItems := Items(AKind);
  if (AValue >= 1) and (AValue <= Length(LItems)) then
    Result := LItems[AValue - 1]
  else
    Result := '';
end;

class function TQcLookup.IsValid(AKind: TQcLookupKind; AValue: Integer): Boolean;
begin
  Result := (AValue >= 1) and (AValue <= Length(Items(AKind)));
end;

class procedure TQcLookup.FillItems(AItems: TStrings; AKind: TQcLookupKind);
var
  LText: string;
begin
  AItems.BeginUpdate;
  try
    AItems.Clear;
    for LText in Items(AKind) do
      AItems.Add(LText);
  finally
    AItems.EndUpdate;
  end;
end;

end.
