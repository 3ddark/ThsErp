unit ufrmPrdBoms;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdBom.Service, PrdBom, ufrmPrdBomDetail;

type
  TfrmPrdBoms = class(TfrmGrid<TPrdBom, TPrdBomService>)
  public

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmPrdBoms.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdBomDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPrdBomDetail.Create(Self, Service, TPrdBom.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdBomDetail.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdBoms.SetSelectedItem;

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
  Table.InventoryCode := FieldText('inventory_code');
  Table.InventoryName := FieldText('inventory_name');
  Table.RawCount := FieldText('raw_count');
  Table.LabourCount := FieldText('labour_count');
end;

procedure TfrmPrdBoms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_inventory_id', 0);
end;

procedure TfrmPrdBoms.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdBoms.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBom.TitlePlural, 'BoMs');
  SetColumnTitle('bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBomName, 'BoM Name'));
  SetColumnTitle('base_quantity', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColBaseQuantity, 'Base Quantity'));
  SetColumnTitle('is_default', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsDefault, 'Default BoM'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColIsActive, 'Active'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColDescription, 'Description'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColInventoryName, 'Product'));
  SetColumnTitle('raw_count', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColRawCount, 'Raw Materials'));
  SetColumnTitle('labour_count', TLocalizationManager.Translate(TLangKeys.TPrdBom.ColLabourCount, 'Labours'));
end;

end.
