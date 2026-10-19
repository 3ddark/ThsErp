unit ufrmAccExchangeRates;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccExchangeRate.Service, AccExchangeRate, ufrmAccExchangeRate;

type
  TfrmAccExchangeRates = class(TfrmGrid<TAccExchangeRate, TAccExchangeRateService>)
  private
    procedure mniTcmbClick(Sender: TObject);
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

// Son TCMB bülteni (cuma bülteni cumartesi / pazar için de yazılır); elle girilmiş kurlar korunur
procedure TfrmAccExchangeRates.mniTcmbClick(Sender: TObject);
var
  LCount: Integer;
  LDate: TDate;
begin
  LDate := Service.UpdateFromTcmb(0, True, LCount);
  RefreshParentGrid(True);
  ShowMessage(Format(TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.TcmbImported,
    'Central Bank rates of %s imported (%d records).'), [DateToStr(LDate), LCount]));
end;

procedure TfrmAccExchangeRates.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;
  AddPopupMenuSpliter();
  AddMenu(TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.MenuTcmb, 'Update from Central Bank (TCMB)'),
    'mniTcmb', mniTcmbClick);
end;

function TfrmAccExchangeRates.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccExchangeRate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccExchangeRate.Create(Self, Service, TAccExchangeRate.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccExchangeRate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccExchangeRates.SetSelectedItem;

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
end;

procedure TfrmAccExchangeRates.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmAccExchangeRates.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccExchangeRates.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.TitlePlural, 'Exchange Rates');
  SetColumnTitle('rate_date', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColRateDate, 'Date'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColCurrency, 'Currency'));
  SetColumnTitle('rate', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColForexBuying, 'Forex Buying'));
  SetColumnTitle('forex_selling', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColForexSelling, 'Forex Selling'));
  SetColumnTitle('banknote_buying', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColBanknoteBuying, 'Banknote Buying'));
  SetColumnTitle('banknote_selling', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColBanknoteSelling, 'Banknote Selling'));
  SetColumnTitle('source', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColSource, 'Source'));
end;

end.
