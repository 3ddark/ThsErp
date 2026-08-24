unit ufrmEmpTransportations;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, EmpTransportation.Service, EmpTransportation, ufrmEmpTransportation,
  LocalizationManager;

type
  TfrmEmpTransportations = class(TfrmGrid<TEmpTransportation, TEmpTransportationService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmEmpTransportations.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEmpTransportation.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEmpTransportation.Create(Self, Service, TEmpTransportation.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEmpTransportation.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmEmpTransportations.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0, TLocalizationManager.Translate('emp_transportation.col_id', 'Id'));
  SetColumnProperty('car_no', 80, TLocalizationManager.Translate('emp_transportation.col_car_no', 'Araç No'));
  SetColumnProperty('car_name', 200, TLocalizationManager.Translate('emp_transportation.col_car_name', 'Araç Adı'));
end;

procedure TfrmEmpTransportations.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmEmpTransportations.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmEmpTransportations.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_transportation.title_plural', 'Servis / Ulaşım');
end;

end.
