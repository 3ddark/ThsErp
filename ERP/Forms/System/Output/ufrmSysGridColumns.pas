unit ufrmSysGridColumns;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysGridColumn.Service, SysGridColumn, ufrmSysGridColumn;

type
  TfrmSysGridColumns = class(TfrmGrid<TSysGridColumn, TSysGridColumnService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridColumns.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridColumn.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, TSysGridColumn.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridColumns.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0);
  SetColumnProperty('table_name',    150);
  SetColumnProperty('column_name',   150);
  SetColumnProperty('column_width',   80);
  SetColumnProperty('column_order',   80);
  SetColumnProperty('is_show',        60);
  SetColumnProperty('is_fetch',       60);
  SetColumnProperty('aggregate_type',110);
end;

procedure TfrmSysGridColumns.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysGridColumns.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TitlePlural, 'Grid Column Settings');
  SetColumnTitle('id',             TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColId, 'Id'));
  SetColumnTitle('table_name',     TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColTableName, 'Table Name'));
  SetColumnTitle('column_name',    TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnName, 'Column Name'));
  SetColumnTitle('column_width',   TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnWidth, 'Width'));
  SetColumnTitle('column_order',   TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnOrder, 'Order'));
  SetColumnTitle('is_show',        TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsShow, 'Show'));
  SetColumnTitle('is_fetch',       TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsFetch, 'Fetch'));
  SetColumnTitle('aggregate_type', TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColAggregateType, 'Aggregate Type'));
end;

end.
