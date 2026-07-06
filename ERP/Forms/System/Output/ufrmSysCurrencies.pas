unit ufrmSysCurrencies;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysCurrency.Service, SysCurrency, ufrmSysCurrency;

type
  TfrmSysCurrencies = class(TfrmGrid<TSysCurrency, TSysCurrencyService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysCurrencies.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysCurrency.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysCurrency.Create(Self, Service, TSysCurrency.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysCurrency.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysCurrencies.DefineColumnWidths;
begin
  SetColumnProperty('id',             0, 'Id');
  SetColumnProperty('currency',      80, 'Currency');
  SetColumnProperty('symbol',        60, 'Symbol');
  SetColumnProperty('description',  220, 'Description');
end;

procedure TfrmSysCurrencies.DefineFooterColumns;
begin
  AddFooterColumn('currency', atCount, 'Ort: #,##0');
end;

procedure TfrmSysCurrencies.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Currency';
end;

end.

