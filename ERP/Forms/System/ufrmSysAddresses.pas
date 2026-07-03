unit ufrmSysAddresses;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysAddress.Service, SysAddress, ufrmSysAddress;

type
  TfrmSysAddresses = class(TfrmGrid<TSysAddress, TSysAddressService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysAddresses.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysAddress.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysAddress.Create(Self, Service, TSysAddress.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysAddress.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysAddresses.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('city_id',      80, 'City ID');
  SetColumnProperty('district',    120, 'District');
  SetColumnProperty('neighborhood', 120, 'Neighborhood');
  SetColumnProperty('quarter',     100, 'Quarter');
  SetColumnProperty('road',        120, 'Road');
  SetColumnProperty('street',      120, 'Street');
  SetColumnProperty('zip_code',     80, 'Zip Code');
end;

procedure TfrmSysAddresses.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmSysAddresses.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Addresses';
end;

end.
