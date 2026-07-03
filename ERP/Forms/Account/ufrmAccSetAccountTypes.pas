unit ufrmAccSetAccountTypes;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SetAccAccountType.Service, SetAccAccountType, ufrmAccSetAccountType;

type
  TfrmAccSetAccountTypes = class(TfrmGrid<TSetAccAccountType, TSetAccAccountTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccSetAccountTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccSetAccountType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccSetAccountType.Create(Self, Service, TSetAccAccountType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccSetAccountType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccSetAccountTypes.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('name',        250, 'Name');
end;

procedure TfrmAccSetAccountTypes.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccSetAccountTypes.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Account Types';
end;

end.
