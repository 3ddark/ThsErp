unit ufrmAccAccountPlans;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccAccountPlan.Service, AccAccountPlan, ufrmAccAccountPlan;

type
  TfrmAccAccountPlans = class(TfrmGrid<TAccAccountPlan, TAccAccountPlanService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccAccountPlans.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccAccountPlan.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccAccountPlan.Create(Self, Service, TAccAccountPlan.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccAccountPlan.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccAccountPlans.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('code',        120, 'Code');
  SetColumnProperty('name',        300, 'Name');
  SetColumnProperty('level',         60, 'Level');
end;

procedure TfrmAccAccountPlans.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccAccountPlans.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Account Plans';
end;

end.
