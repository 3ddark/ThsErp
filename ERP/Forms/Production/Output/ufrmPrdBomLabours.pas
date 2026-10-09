unit ufrmPrdBomLabours;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdBomLabour.Service, PrdBomLabour, ufrmPrdBomLabour;

type
  TfrmPrdBomLabours = class(TfrmGrid<TPrdBomLabour, TPrdBomLabourService>)
  private
    FFixedMasterId: Int64;
    FFixedMasterName: string;
  public
    procedure SetFixedBom(AMasterId: Int64; const AMasterName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmPrdBomLabours.SetFixedBom(AMasterId: Int64; const AMasterName: string);
begin
  FFixedMasterId := AMasterId;
  FFixedMasterName := AMasterName;
  AddFixedFilter('prd_bom_id', AMasterId);
end;

function TfrmPrdBomLabours.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TPrdBomLabour;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdBomLabour.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TPrdBomLabour.Create;
    if FFixedMasterId > 0 then
    begin
      LNew.PrdBomId := FFixedMasterId;
      LNew.BomName := FFixedMasterName;
    end;
    Result := TfrmPrdBomLabour.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdBomLabour.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdBomLabours.SetSelectedItem;

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
  Table.BomName := FieldText('bom_name');
  Table.LabourCode := FieldText('labour_code');
  Table.LabourName := FieldText('labour_name');
  Table.UnitPrice := FieldText('unit_price');
  Table.Currency := FieldText('currency');
  Table.TotalAmount := FieldText('total_amount');
end;

procedure TfrmPrdBomLabours.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('prd_bom_id', 0);
  SetColumnProperty('prd_labour_id', 0);
end;

procedure TfrmPrdBomLabours.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdBomLabours.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.TitlePlural, 'BoM Labours');
  if FFixedMasterName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedMasterName;
  SetColumnTitle('quantity', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColQuantity, 'Quantity'));
  SetColumnTitle('bom_name', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColBomName, 'BoM'));
  SetColumnTitle('labour_code', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColLabourCode, 'Labour Code'));
  SetColumnTitle('labour_name', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColLabourName, 'Labour / Cost'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColCurrency, 'Currency'));
  SetColumnTitle('total_amount', TLocalizationManager.Translate(TLangKeys.TPrdBomLabour.ColTotalAmount, 'Total Amount'));
end;

end.
