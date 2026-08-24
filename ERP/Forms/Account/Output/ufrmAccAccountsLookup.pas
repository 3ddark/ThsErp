unit ufrmAccAccountsLookup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccAccount.Service, AccAccount, ufrmAccAccountLookup;

type
  TfrmAccAccountsLookup = class(TfrmGrid<TAccAccount, TAccAccountService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccAccountsLookup.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccAccountLookup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccAccountLookup.Create(Self, Service, TAccAccount.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccAccountLookup.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccAccountsLookup.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('code',        150, 'Account Code');
  SetColumnProperty('name',        300, 'Account Name');
end;

procedure TfrmAccAccountsLookup.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccAccountsLookup.FormShow(Sender: TObject);
begin
  Qry.SQL.Add(' AND (code LIKE ''%-%%-%%'' OR code LIKE ''%-%'')');
  inherited;
  Self.Caption := 'Select Account';
end;

end.
