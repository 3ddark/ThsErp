unit ufrmAccExchangeRates;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccExchangeRate.Service, AccExchangeRate, ufrmAccExchangeRate;

type
  TfrmAccExchangeRates = class(TfrmGrid<TAccExchangeRate, TAccExchangeRateService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccExchangeRates.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccExchangeRate.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccExchangeRate.Create(Self, Service, TAccExchangeRate.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccExchangeRate.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccExchangeRates.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('rate_date',   100, 'Date');
  SetColumnProperty('currency',     80, 'Currency');
  SetColumnProperty('rate',        120, 'Rate');
end;

procedure TfrmAccExchangeRates.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccExchangeRates.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Exchange Rates';
end;

end.
