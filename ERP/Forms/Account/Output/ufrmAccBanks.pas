unit ufrmAccBanks;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccBank.Service, AccBank, ufrmAccBank;

type
  TfrmAccBanks = class(TfrmGrid<TAccBank, TAccBankService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
    procedure SetSelectedItem; override;
  end;

implementation

{$R *.dfm}

function TfrmAccBanks.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccBank.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccBank.Create(Self, Service, TAccBank.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccBank.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmAccBanks.DefineColumnWidths;
begin
  SetColumnProperty('id', 0);
  SetColumnProperty('bank_name', 250);
  SetColumnProperty('swift_code', 120);
end;

procedure TfrmAccBanks.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmAccBanks.SetSelectedItem;
begin
  inherited;
  Table.BankName := Grd.DataSource.DataSet.FieldByName('bank_name').AsString;
  Table.SWiftCode := Grd.DataSource.DataSet.FieldByName('swift_code').AsString;
end;

procedure TfrmAccBanks.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccBank.TitlePlural, 'Banks');
  SetColumnTitle('bank_name',   TLocalizationManager.Translate(TLangKeys.TAccBank.ColBankName, 'Bank Name'));
  SetColumnTitle('swift_code',  TLocalizationManager.Translate(TLangKeys.TAccBank.ColSwiftCode, 'Swift Code'));
end;

end.
