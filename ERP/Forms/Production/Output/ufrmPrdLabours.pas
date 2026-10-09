unit ufrmPrdLabours;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  PrdLabour.Service, PrdLabour, ufrmPrdLabour;

type
  TfrmPrdLabours = class(TfrmGrid<TPrdLabour, TPrdLabourService>)
  private
    procedure CostTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  PrdLookup;

procedure TfrmPrdLabours.CostTypeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TPrdLookup.Text(plkCostType, Sender.AsInteger);
end;

function TfrmPrdLabours.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmPrdLabour.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmPrdLabour.Create(Self, Service, TPrdLabour.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmPrdLabour.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmPrdLabours.SetSelectedItem;

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
  Table.UomCode := FieldText('uom_code');
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmPrdLabours.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('sys_uom_id', 0);
  LField := Grd.DataSource.DataSet.FindField('cost_type');
  if Assigned(LField) then
    LField.OnGetText := CostTypeGetText;
end;

procedure TfrmPrdLabours.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmPrdLabours.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TPrdLabour.TitlePlural, 'Labours / Costs');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColCode, 'Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColName, 'Name'));
  SetColumnTitle('cost_type', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColCostType, 'Cost Type'));
  SetColumnTitle('unit_price', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColUnitPrice, 'Unit Price'));
  SetColumnTitle('currency', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColCurrency, 'Currency'));
  SetColumnTitle('acc_account_code', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColAccAccountCode, 'Expense Account'));
  SetColumnTitle('uom_code', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColSysUomId, 'Unit'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TPrdLabour.ColAccAccountCode, 'Expense Account'));
end;

end.
