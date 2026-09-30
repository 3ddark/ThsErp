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
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

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
  SetColumnTitle('rate', TLocalizationManager.Translate(TLangKeys.TAccExchangeRate.ColRate, 'Rate'));
end;

end.
