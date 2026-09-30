unit ufrmAccSetTaxRates;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccSetTaxRate.Service, AccSetTaxRate, ufrmAccSetTaxRate;

type
  TfrmAccSetTaxRates = class(TfrmGrid<TAccSetTaxRate, TAccSetTaxRateService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmAccSetTaxRates.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccSetTaxRate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccSetTaxRate.Create(Self, Service, TAccSetTaxRate.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccSetTaxRate.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccSetTaxRates.SetSelectedItem;

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

procedure TfrmAccSetTaxRates.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmAccSetTaxRates.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccSetTaxRates.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.TitlePlural, 'Tax Rates');
  SetColumnTitle('tax_rate', TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColTaxRate, 'Tax Rate'));
  SetColumnTitle('sales_account', TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColSalesAccount, 'Sales Account'));
  SetColumnTitle('sales_return_account', TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColSalesReturnAccount, 'Sales Return Account'));
  SetColumnTitle('purchase_account', TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColPurchaseAccount, 'Purchase Account'));
  SetColumnTitle('purchase_return_account', TLocalizationManager.Translate(TLangKeys.TAccSetTaxRate.ColPurchaseReturnAccount, 'Purchase Return Account'));
end;

end.
