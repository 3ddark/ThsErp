unit ufrmSysRegions;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysRegion.Service, SysRegion, ufrmSysRegion;

type
  TfrmSysRegions = class(TfrmGrid<TSysRegion, TSysRegionService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysRegions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysRegion.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysRegion.Create(Application, Service, TSysRegion.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysRegion.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysRegions.DefineColumnWidths;
begin
  SetColumnProperty('id',            0, 'Id');
  SetColumnProperty('region_name',  80, 'Region Name');
end;

procedure TfrmSysRegions.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('region_name', atCount, '#,##0 " Region"');
end;

procedure TfrmSysRegions.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Regions';
end;

end.

