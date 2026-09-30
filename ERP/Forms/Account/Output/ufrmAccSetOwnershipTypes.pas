unit ufrmAccSetOwnershipTypes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccSetOwnershipType.Service, AccSetOwnershipType, ufrmAccSetOwnershipType;

type
  TfrmAccSetOwnershipTypes = class(TfrmGrid<TAccSetOwnershipType, TAccSetOwnershipTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmAccSetOwnershipTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccSetOwnershipType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccSetOwnershipType.Create(Self, Service, TAccSetOwnershipType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccSetOwnershipType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccSetOwnershipTypes.SetSelectedItem;

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
  Table.OwnershipTypeName := FieldText('ownership_type_name');
end;

procedure TfrmAccSetOwnershipTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmAccSetOwnershipTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccSetOwnershipTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.TitlePlural, 'Ownership Types');
  SetColumnTitle('ownership_type_key', TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.ColOwnershipTypeKey, 'Key'));
  SetColumnTitle('ownership_type_name', TLocalizationManager.Translate(TLangKeys.TAccSetOwnershipType.ColOwnershipTypeName, 'Ownership Type'));
end;

end.
