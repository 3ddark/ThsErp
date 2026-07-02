unit ufrmStkGrouplar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkGroupService, StkGroup, ufrmStkGroup;

type
  TfrmStkGrouplar = class(TfrmGrid<TStkGroup, TStkGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkGrouplar.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkGroup.Create(Self, Service, TStkGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkGroup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkGrouplar.DefineColumnWidths;
begin
  SetColumnProperty('id',                    0, 'Id');
  SetColumnProperty('group_name',          120, 'Group Name');
  SetColumnProperty('vat_rate',             80, 'VAT Rate');
  SetColumnProperty('raw_material_stock_account', 130, 'RM Stock Account');
  SetColumnProperty('raw_material_usage_account', 130, 'RM Usage Account');
  SetColumnProperty('semi_product_account',      130, 'Semi Product Acct');
end;

procedure TfrmStkGrouplar.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkGrouplar.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Groups';
end;

end.
