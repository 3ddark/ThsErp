unit ufrmAccBankBranches;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccBankBranch.Service, AccBankBranch, ufrmAccBankBranch;

type
  TfrmAccBankBranches = class(TfrmGrid<TAccBankBranch, TAccBankBranchService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccBankBranches.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccBankBranch.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccBankBranch.Create(Self, Service, TAccBankBranch.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccBankBranch.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccBankBranches.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('bank_id',     80, 'Bank ID');
  SetColumnProperty('code',         60, 'Code');
  SetColumnProperty('name',        200, 'Name');
  SetColumnProperty('city_id',      80, 'City ID');
end;

procedure TfrmAccBankBranches.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccBankBranches.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Bank Branches';
end;

end.
