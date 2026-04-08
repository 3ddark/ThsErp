unit ufrmSysUomTypes;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysUomType.Service, SysUomType, ufrmSysUomType;

type
  TfrmSysUomTypes = class(TfrmGrid<TsysUomType, TSysUomTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysUomTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUomType.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUomType.Create(Application, Service, TSysUomType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUomType.Create(Application, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUomTypes.DefineColumnWidths;
begin
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('measure_type',  150, 'Ölçü Birimi Tipi');
end;

procedure TfrmSysUomTypes.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('measure_type', atCount, '#,##0 " Ölçü Birimi Tipi"');
end;

procedure TfrmSysUomTypes.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Sistem Ölçü Birimi Tipleri';
end;

end.
