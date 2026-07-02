unit ufrmStkKindPropertylar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkKindPropertyService, StkKindProperty, ufrmStkKindProperty;

type
  TfrmStkKindPropertylar = class(TfrmGrid<TStkKindProperty, TStkKindPropertyService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkKindPropertylar.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindProperty.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKindProperty.Create(Self, Service, TStkKindProperty.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindProperty.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKindPropertylar.DefineColumnWidths;
begin
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('kind',           100, 'Kind');
  SetColumnProperty('description',    200, 'Description');
  SetColumnProperty('s1',             60, 'S1');
  SetColumnProperty('s2',             60, 'S2');
  SetColumnProperty('s3',             60, 'S3');
  SetColumnProperty('s4',             60, 'S4');
  SetColumnProperty('s5',             60, 'S5');
  SetColumnProperty('s6',             60, 'S6');
  SetColumnProperty('s7',             60, 'S7');
  SetColumnProperty('s8',             60, 'S8');
  SetColumnProperty('s9',             60, 'S9');
  SetColumnProperty('s10',            60, 'S10');
end;

procedure TfrmStkKindPropertylar.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkKindPropertylar.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Kind Properties';
end;

end.
