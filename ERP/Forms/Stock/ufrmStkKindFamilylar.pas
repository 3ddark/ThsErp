unit ufrmStkKindFamilylar;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkKindFamilyService, StkKindFamily, ufrmStkKindFamily;

type
  TfrmStkKindFamilylar = class(TfrmGrid<TStkKindFamily, TStkKindFamilyService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmStkKindFamilylar.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindFamily.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKindFamily.Create(Self, Service, TStkKindFamily.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindFamily.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKindFamilylar.DefineColumnWidths;
begin
  SetColumnProperty('id',              0, 'Id');
  SetColumnProperty('family',         120, 'Family');
  SetColumnProperty('description',    200, 'Description');
  SetColumnProperty('active',          60, 'Active');
end;

procedure TfrmStkKindFamilylar.DefineFooterColumns;
begin
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmStkKindFamilylar.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Stock Kind Families';
end;

end.
