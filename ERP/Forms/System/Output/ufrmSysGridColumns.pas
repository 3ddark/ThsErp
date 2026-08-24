unit ufrmSysGridColumns;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGridColumn.Service, SysGridColumn, ufrmSysGridColumn, LocalizationManager;

type
  TfrmSysGridColumns = class(TfrmGrid<TSysGridColumn, TSysGridColumnService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridColumns.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridColumn.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, TSysGridColumn.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridColumns.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',           0, TLocalizationManager.Translate('sys_grid_column.col_id', 'Id'));
  SetColumnProperty('table_name', 150, TLocalizationManager.Translate('sys_grid_column.col_table_name', 'Table Name'));
  SetColumnProperty('column_name',150, TLocalizationManager.Translate('sys_grid_column.col_column_name', 'Column Name'));
  SetColumnProperty('column_width',80, TLocalizationManager.Translate('sys_grid_column.col_column_width', 'Width'));
  SetColumnProperty('column_order',80, TLocalizationManager.Translate('sys_grid_column.col_column_order', 'Order'));
  SetColumnProperty('is_show',     60, TLocalizationManager.Translate('sys_grid_column.col_is_show', 'Show'));
end;

procedure TfrmSysGridColumns.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysGridColumns.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysGridColumns.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_grid_column.title_plural', 'Grid Column Settings');
end;

end.
