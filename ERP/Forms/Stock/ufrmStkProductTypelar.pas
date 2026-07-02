unit ufrmStkProductTypelar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkProductTypeService, StkProductType, ufrmStkProductType;

type
  TfrmStkProductTypelar = class(TfrmGrid<TStkProductType, TStkProductTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkProductTypelar.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkProductType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkProductType.Create(Self, Service, TStkProductType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkProductType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkProductTypelar.DefineColumnWidths;
begin
  SetColumnProperty('id',                    0, 'Id');
  SetColumnProperty('product_type_name',   150, 'Product Type Name');
  SetColumnProperty('description',         200, 'Description');
  SetColumnProperty('active',               60, 'Active');
end;

procedure TfrmStkProductTypelar.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkProductTypelar.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Product Types';
end;

end.
