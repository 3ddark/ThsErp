unit ufrmSysUoms;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysUom.Service, SysUom, ufrmSysUom, LocalizationManager;

type
  TfrmSysUoms = class(TfrmGrid<TSysUom, TSysUomService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses Service;

function TfrmSysUoms.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUom.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUom.Create(Self, Service, TSysUom.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUom.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUoms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('sys_uom.col_id', 'Id'));
  SetColumnProperty('unit_code',      90, TLocalizationManager.Translate('sys_uom.col_unit', 'Unit Code'));
  SetColumnProperty('unit_einv',      90, TLocalizationManager.Translate('sys_uom.col_unit_einv', 'E-Invoice Unit Code'));
  SetColumnProperty('description',   150, TLocalizationManager.Translate('sys_uom.col_description', 'Description'));
  SetColumnProperty('decimal',        70, TLocalizationManager.Translate('sys_uom.col_decimal', 'Decimal'));
  SetColumnProperty('measure_type_id', 0, TLocalizationManager.Translate('sys_uom.col_measure_type_id', 'Measure Type Id'));
  SetColumnProperty('multiplier',     70, TLocalizationManager.Translate('sys_uom.col_multiplier', 'Multiplier'));
end;

procedure TfrmSysUoms.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysUoms.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysUoms.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_uom.title_plural', 'Units of Measurement');
end;

end.
