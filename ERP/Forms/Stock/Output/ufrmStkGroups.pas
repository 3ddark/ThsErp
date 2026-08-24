unit ufrmStkGroups;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkGroup.Service, StkGroup, ufrmStkGroup,
  LocalizationManager;

type
  TfrmStkGroups = class(TfrmGrid<TStkGroup, TStkGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
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
    Result := TfrmStkGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkGroup.Create(Self, Service, TStkGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkGroups.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',                          0, TLocalizationManager.Translate('stk_group.col_id', 'Id'));
  SetColumnProperty('name',                      120, TLocalizationManager.Translate('stk_group.col_group_name', 'Group Name'));
  SetColumnProperty('vat_rate',                   80, TLocalizationManager.Translate('stk_group.col_vat_rate', 'VAT Rate'));
  SetColumnProperty('raw_material_stock_account', 130, TLocalizationManager.Translate('stk_group.col_rm_stock_account', 'RM Stock Account'));
  SetColumnProperty('raw_material_usage_account', 130, TLocalizationManager.Translate('stk_group.col_rm_usage_account', 'RM Usage Account'));
  SetColumnProperty('semi_product_account',      130, TLocalizationManager.Translate('stk_group.col_semi_product_account', 'Semi Product Acct'));
end;

procedure TfrmStkGroups.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
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
  Self.Caption := TLocalizationManager.Translate('stk_group.title_plural', 'Stock Groups');
end;

end.
