unit ufrmSysRegions;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysRegion.Service, SysRegion, ufrmSysRegion, LocalizationManager;

type
  TfrmSysRegions = class(TfrmGrid<TSysRegion, TSysRegionService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysRegions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysRegion.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysRegion.Create(Self, Service, TSysRegion.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysRegion.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysRegions.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',    0, TLocalizationManager.Translate('sys_region.col_id', 'Id'));
  SetColumnProperty('name', 200, TLocalizationManager.Translate('sys_region.col_name', 'Region Name'));
end;

procedure TfrmSysRegions.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysRegions.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmSysRegions.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_region.title_plural', 'Regions');

end;

end.

