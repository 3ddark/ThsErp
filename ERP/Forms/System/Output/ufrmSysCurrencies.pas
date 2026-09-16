unit ufrmSysCurrencies;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysCurrency.Service, SysCurrency, ufrmSysCurrency;

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
    Result := TfrmSysCurrency.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCurrency.Create(Self, Service, TSysCurrency.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCurrency.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCurrencies.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',            0);
  SetColumnProperty('currency',    100);
  SetColumnProperty('symbol',       80);
  SetColumnProperty('description', 220);
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysCurrency.TitlePlural, 'Currencies');
  SetColumnTitle('id',          TLocalizationManager.Translate(TLangKeys.TSysCurrency.ColId, 'Id'));
  SetColumnTitle('currency',    TLocalizationManager.Translate(TLangKeys.TSysCurrency.ColCode, 'Currency Code'));
  SetColumnTitle('symbol',      TLocalizationManager.Translate(TLangKeys.TSysCurrency.ColSymbol, 'Symbol'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TSysCurrency.ColDescription, 'Description'));
end;

end.

