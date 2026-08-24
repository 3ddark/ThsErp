unit ufrmSysGridFilters;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGridFilter.Service, SysGridFilter, ufrmSysGridFilter, LocalizationManager;

type
  TfrmSysGridFilters = class(TfrmGrid<TSysGridFilter, TSysGridFilterService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridFilters.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridFilter.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridFilter.Create(Self, Service, TSysGridFilter.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridFilter.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridFilters.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('sys_grid_filter.col_id', 'Id'));
  SetColumnProperty('table_name',    120, TLocalizationManager.Translate('sys_grid_filter.col_table_name', 'Table Name'));
  SetColumnProperty('filter_content', 300, TLocalizationManager.Translate('sys_grid_filter.col_filter_content', 'Filter Content'));
end;

procedure TfrmSysGridFilters.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysGridFilters.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysGridFilters.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_grid_filter.title_plural', 'Grid Filters');
end;

end.
