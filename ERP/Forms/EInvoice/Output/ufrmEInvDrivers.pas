unit ufrmEInvDrivers;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvDriver.Service, EInvDriver, ufrmEInvDriver;

type
  TfrmEInvDrivers = class(TfrmGrid<TEInvDriver, TEInvDriverService>)
  private

  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    procedure SetActiveOnly;
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

procedure TfrmEInvDrivers.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvDrivers.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvDriver.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvDriver.Create(Self, Service, TEInvDriver.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvDriver.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvDrivers.SetSelectedItem;

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
  Table.FullName := FieldText('full_name');
end;

procedure TfrmEInvDrivers.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvDrivers.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvDrivers.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDriver.TitlePlural, 'Drivers');
  SetColumnTitle('first_name', TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColFirstName, 'First Name'));
  SetColumnTitle('family_name', TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColFamilyName, 'Last Name'));
  SetColumnTitle('national_id', TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColNationalId, 'National ID'));
  SetColumnTitle('phone', TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColPhone, 'Phone'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColIsActive, 'Active'));
  SetColumnTitle('full_name', TLocalizationManager.Translate(TLangKeys.TEInvDriver.ColFullName, 'Driver'));
end;

end.
