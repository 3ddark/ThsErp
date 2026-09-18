unit ufrmSysGridFilters;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysGridFilter.Service, SysGridFilter, ufrmSysGridFilter;

type
  TfrmSysGridFilters = class(TfrmGrid<TSysGridFilter, TSysGridFilterService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridFilters.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridFilter.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridFilter.Create(Self, Service, TSysGridFilter.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridFilter.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridFilters.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColId, 'Id'));
  SetColumnProperty('table_name',    120, TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColTableName, 'Table Name'));
  SetColumnProperty('filter_content', 300, TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColFilterContent, 'Filter Content'));
end;

procedure TfrmSysGridFilters.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysGridFilters.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.TitlePlural, 'Grid Filters');
  SetColumnTitle('id',             TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColId, 'Id'));
  SetColumnTitle('table_name',     TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColTableName, 'Table Name'));
  SetColumnTitle('filter_content', TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColFilterContent, 'Filter Content'));
end;

end.
