unit ufrmSysUoms;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysUom.Service, SysUom, ufrmSysUom;

type
  TfrmSysUoms = class(TfrmGrid<TSysUom, TSysUomService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses Service;

function TfrmSysUoms.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUom.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUom.Create(Application, Service, TSysUom.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUom.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUoms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('unit',          150, 'Unit');
end;

procedure TfrmSysUoms.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('unit', atCount, '#,##0 " Unit"');
end;

procedure TfrmSysUoms.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Unit Of Measurements';
end;

end.
