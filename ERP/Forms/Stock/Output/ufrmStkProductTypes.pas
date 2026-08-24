unit ufrmStkProductTypes;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkProductType.Service, StkProductType, ufrmStkProductType,
  LocalizationManager;

type
  TfrmStkProductTypes = class(TfrmGrid<TStkProductType, TStkProductTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmStkProductTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkProductType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkProductType.Create(Self, Service, TStkProductType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkProductType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkProductTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',                    0, TLocalizationManager.Translate('stk_product_type.col_id', 'Id'));
  SetColumnProperty('product_type_name',   200, TLocalizationManager.Translate('stk_product_type.col_product_type_name', 'Product Type Name'));
end;

procedure TfrmStkProductTypes.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkProductTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkProductTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_product_type.title_plural', 'Stock Product Types');
end;

end.
