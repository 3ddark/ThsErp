unit ufrmAccRegions;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccRegion.Service, AccRegion, ufrmAccRegion;

type
  TfrmAccRegions = class(TfrmGrid<TAccRegion, TAccRegionService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccRegions.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccRegion.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccRegion.Create(Self, Service, TAccRegion.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccRegion.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccRegions.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('name',        250, 'Region');
end;

procedure TfrmAccRegions.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccRegions.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Regions';
end;

end.
