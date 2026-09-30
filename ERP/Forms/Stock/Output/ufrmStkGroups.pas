unit ufrmStkGroups;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkGroup.Service, StkGroup, ufrmStkGroup;

type
  TfrmStkGroups = class(TfrmGrid<TStkGroup, TStkGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmStkGroups.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkGroup.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkGroup.Create(Self, Service, TStkGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkGroup.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkGroups.SetSelectedItem;

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

procedure TfrmStkGroups.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmStkGroups.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkGroups.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkGroup.TitlePlural, 'Stock Groups');
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TStkGroup.ColName, 'Group Name'));
  SetColumnTitle('vat_rate', TLocalizationManager.Translate(TLangKeys.TStkGroup.ColVatRate, 'VAT Rate (%)'));
  SetColumnTitle('raw_material_stock_account', TLocalizationManager.Translate(TLangKeys.TStkGroup.ColRawMaterialStockAccount, 'Raw Material Stock Account'));
  SetColumnTitle('raw_material_usage_account', TLocalizationManager.Translate(TLangKeys.TStkGroup.ColRawMaterialUsageAccount, 'Raw Material Usage Account'));
  SetColumnTitle('semi_product_account', TLocalizationManager.Translate(TLangKeys.TStkGroup.ColSemiProductAccount, 'Semi-Product Account'));
end;

end.
