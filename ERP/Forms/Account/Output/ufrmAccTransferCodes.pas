unit ufrmAccTransferCodes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccTransferCode.Service, AccTransferCode, ufrmAccTransferCode;

type
  TfrmAccTransferCodes = class(TfrmGrid<TAccTransferCode, TAccTransferCodeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmAccTransferCodes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccTransferCode.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccTransferCode.Create(Self, Service, TAccTransferCode.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccTransferCode.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccTransferCodes.SetSelectedItem;

  function FieldText(const AFieldName: string): string;
  var
    LField: TField;
  begin
    LField := Grd.DataSource.DataSet.FindField(AFieldName);
    if Assigned(LField) then
      Result := LField.AsString
    else
      Result := '';
  end;

begin
  inherited;
  Table.AccountName := FieldText('account_name');
end;

procedure TfrmAccTransferCodes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmAccTransferCodes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccTransferCodes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccTransferCode.TitlePlural, 'Transfer Codes');
  SetColumnTitle('transfer_code', TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColTransferCode, 'Transfer Code'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColDescription, 'Description'));
  SetColumnTitle('account', TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColAccount, 'Account'));
  SetColumnTitle('account_name', TLocalizationManager.Translate(TLangKeys.TAccTransferCode.ColAccountName, 'Account Name'));
end;

end.
