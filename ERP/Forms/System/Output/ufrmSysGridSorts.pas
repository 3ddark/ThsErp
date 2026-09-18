unit ufrmSysGridSorts;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysGridSort.Service, SysGridSort, ufrmSysGridSort;

type
  TfrmSysGridSorts = class(TfrmGrid<TSysGridSort, TSysGridSortService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridSorts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridSort.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridSort.Create(Self, Service, TSysGridSort.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridSort.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridSorts.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColId, 'Id'));
  SetColumnProperty('table_name',    120, TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColTableName, 'Table Name'));
  SetColumnProperty('sort_content',  300, TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColSortContent, 'Sort Content'));
end;

procedure TfrmSysGridSorts.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysGridSorts.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.TitlePlural, 'Grid Sorts');
end;

end.
