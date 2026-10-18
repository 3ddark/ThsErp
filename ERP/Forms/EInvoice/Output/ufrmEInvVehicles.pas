unit ufrmEInvVehicles;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvVehicle.Service, EInvVehicle, ufrmEInvVehicle;

type
  TfrmEInvVehicles = class(TfrmGrid<TEInvVehicle, TEInvVehicleService>)
  private

  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    procedure SetActiveOnly(ATrailer: Boolean);
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvVehicles.SetActiveOnly(ATrailer: Boolean);
begin
  AddFixedFilter('is_active', True);
  AddFixedFilter('is_trailer', ATrailer);
end;

function TfrmEInvVehicles.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvVehicle.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvVehicle.Create(Self, Service, TEInvVehicle.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvVehicle.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvVehicles.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;

end;

procedure TfrmEInvVehicles.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvVehicles.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvVehicles.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.TitlePlural, 'Vehicles / Trailers');
  SetColumnTitle('plate_no', TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColPlateNo, 'Plate No'));
  SetColumnTitle('is_trailer', TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColIsTrailer, 'Trailer'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColDescription, 'Description'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColIsActive, 'Active'));
end;

end.
