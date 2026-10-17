unit ufrmEInvPackagingTypes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvPackagingType.Service, EInvPackagingType, ufrmEInvPackagingType;

type
  TfrmEInvPackagingTypes = class(TfrmGrid<TEInvPackagingType, TEInvPackagingTypeService>)
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

procedure TfrmEInvPackagingTypes.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvPackagingTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvPackagingType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvPackagingType.Create(Self, Service, TEInvPackagingType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvPackagingType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvPackagingTypes.SetSelectedItem;

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

procedure TfrmEInvPackagingTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvPackagingTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvPackagingTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.TitlePlural, 'Packaging Types');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.ColCode, 'Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.ColName, 'Name'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvPackagingType.ColIsActive, 'Active'));
end;

end.
