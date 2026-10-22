unit ufrmQcRules;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  QcRule.Service, QcRule, ufrmQcRule;

type
  // Kalite kontrol kuralları: stok grubu ya da stok kartı bazında kontrol gerekliliği (kart kuralı grubu ezer)
  TfrmQcRules = class(TfrmGrid<TQcRule, TQcRuleService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmQcRules.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmQcRule.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmQcRule.Create(Self, Service, TQcRule.Create, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmQcRules.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_group_id', 0);
  SetColumnProperty('stk_inventory_id', 0);
end;

procedure TfrmQcRules.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmQcRules.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TQcRule.TitlePlural, 'Quality Control Rules');
  SetColumnTitle('group_name', TLocalizationManager.Translate(TLangKeys.TQcRule.ColGroupName, 'Stock Group'));
  SetColumnTitle('inventory_code', TLocalizationManager.Translate(TLangKeys.TQcRule.ColInventoryCode, 'Stock Code'));
  SetColumnTitle('inventory_name', TLocalizationManager.Translate(TLangKeys.TQcRule.ColInventoryName, 'Stock Name'));
  SetColumnTitle('is_required', TLocalizationManager.Translate(TLangKeys.TQcRule.ColIsRequired, 'Inspection Required'));
  SetColumnTitle('inspection_criteria', TLocalizationManager.Translate(TLangKeys.TQcRule.ColInspectionCriteria, 'Inspection Criteria'));
end;

end.
