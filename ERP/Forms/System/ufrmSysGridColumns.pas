unit ufrmSysGridColumns;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysGridColumn.Service, SysGridColumn, ufrmSysGridColumn;

type
  TfrmSysGridColumns = class(TfrmGrid<TSysGridColumn, TSysGridColumnService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmSysGridColumns.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysGridColumn.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, TSysGridColumn.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColumn.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysGridColumns.DefineFooterColumns;
begin
  inherited;
//
end;

procedure TfrmSysGridColumns.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'System Grid Columns';
end;

end.
