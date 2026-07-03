unit ufrmAccBanks;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, AccBank.Service, AccBank, ufrmAccBank;

type
  TfrmAccBanks = class(TfrmGrid<TAccBank, TAccBankService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

function TfrmAccBanks.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccBank.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccBank.Create(Self, Service, TAccBank.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccBank.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccBanks.DefineColumnWidths;
begin
  SetColumnProperty('id',           0, 'Id');
  SetColumnProperty('name',        250, 'Banka Ad'#305);
  SetColumnProperty('swift_code',   120, 'SWIFT Kodu');
end;

procedure TfrmAccBanks.DefineFooterColumns;
begin
  // No footer columns
end;

procedure TfrmAccBanks.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Bankalar';
end;

end.
