unit ufrmSysCurrencies;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysCurrency.Service, SysCurrency, ufrmSysCurrency, LocalizationManager;

type
  TfrmSysCurrencies = class(TfrmGrid<TSysCurrency, TSysCurrencyService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysCurrencies.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCurrency.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCurrency.Create(Self, Service, TSysCurrency.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCurrency.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCurrencies.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',             0, TLocalizationManager.Translate('sys_currency.col_id', 'Id'));
  SetColumnProperty('currency',     100, TLocalizationManager.Translate('sys_currency.col_code', 'Currency Code'));
  SetColumnProperty('symbol',        80, TLocalizationManager.Translate('sys_currency.col_symbol', 'Symbol'));
  SetColumnProperty('description',  220, TLocalizationManager.Translate('sys_currency.col_description', 'Description'));
end;

procedure TfrmSysCurrencies.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysCurrencies.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysCurrencies.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_currency.title_plural', 'Currencies');
end;

end.

