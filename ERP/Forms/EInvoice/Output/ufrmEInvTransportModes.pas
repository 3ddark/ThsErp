unit ufrmEInvTransportModes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvTransportMode.Service, EInvTransportMode, ufrmEInvTransportMode;

type
  TfrmEInvTransportModes = class(TfrmGrid<TEInvTransportMode, TEInvTransportModeService>)
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

procedure TfrmEInvTransportModes.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvTransportModes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvTransportMode.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvTransportMode.Create(Self, Service, TEInvTransportMode.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvTransportMode.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvTransportModes.SetSelectedItem;

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

procedure TfrmEInvTransportModes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvTransportModes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvTransportModes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.TitlePlural, 'Transport Modes');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.ColCode, 'Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.ColName, 'Name'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvTransportMode.ColIsActive, 'Active'));
end;

end.
