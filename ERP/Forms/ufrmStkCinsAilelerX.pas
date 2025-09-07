unit ufrmStkCinsAilelerX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, BaseEntity, StkCinsAileService, StkCinsAile, ufrmStkCinsAileX;

type
  TfrmStkCinsAilelerX = class(TfrmGrid<TStkCinsAile, TStkCinsAileService>)
    procedure FormShow(Sender: TObject); override;
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmStkCinsAilelerX.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkCinsAileX.Create(Application, Service, Table.CloneEntity<TStkCinsAile>(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkCinsAileX.Create(Application, Service, TStkCinsAile.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkCinsAileX.Create(Application, Service, Table.CloneEntity<TStkCinsAile>(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkCinsAilelerX.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Be yeni özel caption override;';
end;

procedure TfrmStkCinsAilelerX.SetSelectedItem;
begin
  Table.Id.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Id.FieldName).AsInteger);
  Table.Family.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Family.FieldName).AsString);
  Table.Description.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Description.FieldName).AsString);
  Table.Active.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Active.FieldName).AsBoolean);
end;

end.

