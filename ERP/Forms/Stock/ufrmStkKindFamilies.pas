unit ufrmStkKindFamilies;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, BaseEntity, StkKindFamilyService, StkKindFamily, ufrmStkKindFamily;

type
  TfrmStkKindFamilies = class(TfrmGrid<TStkKindFamily, TStkKindFamilyService>)
    procedure FormShow(Sender: TObject); override;
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmStkKindFamilies.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindFamily.Create(Application, Service, Table.CloneEntity<TStkKindFamily>(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKindFamily.Create(Application, Service, TStkKindFamily.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindFamily.Create(Application, Service, Table.CloneEntity<TStkKindFamily>(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKindFamilies.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Be yeni özel caption override;';
end;

procedure TfrmStkKindFamilies.SetSelectedItem;
begin
  Table.Id.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Id.FieldName).AsInteger);
  Table.Family.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Family.FieldName).AsString);
  Table.Description.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Description.FieldName).AsString);
  Table.Active.ValueFirstSet(grd.DataSource.DataSet.FieldByName(Table.Active.FieldName).AsBoolean);
end;

end.

