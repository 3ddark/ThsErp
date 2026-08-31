unit ufrmSysDecimalPlaces;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysDecimalPlace.Service, SysDecimalPlace, ufrmSysDecimalPlace, LocalizationManager;

type
  TfrmSysDecimalPlaces = class(TfrmGrid<TSysDecimalPlace, TSysDecimalPlaceService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysDecimalPlaces.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysDecimalPlace.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysDecimalPlace.Create(Self, Service, TSysDecimalPlace.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysDecimalPlace.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysDecimalPlaces.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',               0, TLocalizationManager.Translate(TLangKeys.TGridColumn.ColId, 'Id'));
  SetColumnProperty('quantity',        70, TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColQuantity, 'Quantity'));
  SetColumnProperty('price',           70, TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColPrice, 'Price'));
  SetColumnProperty('total',           70, TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColTotal, 'Total'));
  SetColumnProperty('stock_quantity',  70, TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColStockQuantity, 'Stock Quantity'));
  SetColumnProperty('exchange_rate',   70, TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.ColExchangeRate, 'Exchange Rate'));
end;

procedure TfrmSysDecimalPlaces.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysDecimalPlaces.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysDecimalPlaces.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysDecimalPlace.TitlePlural, 'Decimal Places');
end;

end.
