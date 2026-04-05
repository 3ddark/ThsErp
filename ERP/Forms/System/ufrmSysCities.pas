unit ufrmSysCities;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysCity.Service, SysCity, ufrmSysCity,
  SysCountry.Service, SysCountry;

type
  TfrmSysCities = class(TfrmGrid<TSysCity, TSysCityService>)
    procedure FormShow(Sender: TObject); override;
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmSysCities.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCity.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCity.Create(Application, Service, TSysCity.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCity.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCities.DefineColumnWidths;
begin
  SetColumnWidth('id',               0);
  SetColumnWidth('city_name',      100);
  SetColumnWidth('car_plate_code',  90);
end;

procedure TfrmSysCities.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0 " Şehir"');
end;

procedure TfrmSysCities.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Sistem Şehirler';
end;

procedure TfrmSysCities.SetSelectedItem;
begin
  inherited;

end;

end.

