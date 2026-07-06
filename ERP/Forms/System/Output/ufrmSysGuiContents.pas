unit ufrmSysGuiContents;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGuiContent, SysGuiContent.Service, ufrmSysGuiContent;

type
  TfrmSysGuiContents = class(TfrmGrid<TSysGuiContent, TSysGuiContentService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants;

{$R *.dfm}

function TfrmSysGuiContents.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGuiContent.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGuiContent.Create(Self, Service, TSysGuiContent.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGuiContent.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGuiContents.DefineColumnWidths;
begin
  SetColumnProperty('id',               0, 'Id');
  SetColumnProperty('city_name',      100, 'City Name');
  SetColumnProperty('car_plate_code',  90, 'Car Plate Code');
  SetColumnProperty('country_id',       0, 'Country Id');
  SetColumnProperty('region_id',        0, 'Region Id');
  SetColumnProperty('country_code',    70, 'Country Code');
  SetColumnProperty('country_name',   100, 'Country Name');
  SetColumnProperty('region_name',    100, 'Region Name');
end;

procedure TfrmSysGuiContents.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysGuiContents.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Cities';
end;

end.
