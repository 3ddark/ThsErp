unit ufrmSysUoms;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysUom.Service, SysUom, ufrmSysUom;

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
    Result := TfrmSysUom.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUom.Create(Self, Service, TSysUom.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUom.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUoms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('sys_uom.col_id', 'Id'));
  SetColumnProperty('measure_type_id', 0, TLocalizationManager.Translate('sys_uom.col_measure_type_id', 'Measure Type Id'));
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
  SetColumnTitle('unit_code',   TLocalizationManager.Translate('sys_uom.col_unit', 'Unit Code'));
  SetColumnTitle('unit_einv',   TLocalizationManager.Translate('sys_uom.col_unit_einv', 'E-Invoice Unit Code'));
  SetColumnTitle('description', TLocalizationManager.Translate('sys_uom.col_description', 'Description'));
  SetColumnTitle('decimal',     TLocalizationManager.Translate('sys_uom.col_decimal', 'Decimal'));
  SetColumnTitle('multiplier',  TLocalizationManager.Translate('sys_uom.col_multiplier', 'Multiplier'));
end;

end.
