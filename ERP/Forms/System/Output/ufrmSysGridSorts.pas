unit ufrmSysGridSorts;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGridSort.Service, SysGridSort, ufrmSysGridSort;

type
  TfrmSysGridSorts = class(TfrmGrid<TSysGridSort, TSysGridSortService>)
  public
    procedure DefineColumnWidths; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridSorts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridSort.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridSort.Create(Self, Service, TSysGridSort.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridSort.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridSorts.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('table_name',    120, 'Table Name');
  SetColumnProperty('sort_content',  300, 'Sort Content');
end;

procedure TfrmSysGridSorts.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysGridSorts.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Grid Sorts';
end;

end.
