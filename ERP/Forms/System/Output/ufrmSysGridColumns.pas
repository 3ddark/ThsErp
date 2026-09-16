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
    Result := TfrmSysGridColumn.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, TSysGridColumn.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridColumns.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',           0, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColId, 'Id'));
  SetColumnProperty('table_name', 150, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColTableName, 'Table Name'));
  SetColumnProperty('column_name',150, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnName, 'Column Name'));
  SetColumnProperty('column_width',80, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnWidth, 'Width'));
  SetColumnProperty('column_order',80, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColColumnOrder, 'Order'));
  SetColumnProperty('is_show',     60, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsShow, 'Show'));
  SetColumnProperty('is_fetch',    60, TLocalizationManager.Translate(TLangKeys.TSysGridColumn.ColIsFetch, 'Fetch'));
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
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridColumn.TitlePlural, 'Grid Column Settings');
end;

end.
