unit ufrmSysGridSorts;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGridSort.Service, SysGridSort, ufrmSysGridSort, LocalizationManager;

type
  TfrmSysGridSorts = class(TfrmGrid<TSysGridSort, TSysGridSortService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridSorts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridSort.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridSort.Create(Self, Service, TSysGridSort.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridSort.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridSorts.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('sys_grid_sort.col_id', 'Id'));
  SetColumnProperty('table_name',    120, TLocalizationManager.Translate('sys_grid_sort.col_table_name', 'Table Name'));
  SetColumnProperty('sort_content',  300, TLocalizationManager.Translate('sys_grid_sort.col_sort_content', 'Sort Content'));
end;

procedure TfrmSysGridSorts.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysGridSorts.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysGridSorts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_grid_sort.title_plural', 'Grid Sorts');
end;

end.
