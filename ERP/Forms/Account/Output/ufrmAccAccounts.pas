unit ufrmAccAccounts;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccAccount.Service, AccAccount, ufrmAccAccount;

type
  TfrmAccAccounts = class(TfrmGrid<TAccAccount, TAccAccountService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccAccounts.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccAccount.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccAccount.Create(Self, Service, TAccAccount.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccAccount.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccAccounts.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('code',        100, 'Code');
  SetColumnProperty('name',        350, 'Name');
  SetColumnProperty('type_id',      70, 'Type ID');
  SetColumnProperty('group_id',     80, 'Group ID');
  SetColumnProperty('region_id',    80, 'Region ID');
end;

procedure TfrmAccAccounts.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccAccounts.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Accounts';
end;

end.
