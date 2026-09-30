unit ufrmAccSetAccountTypes;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  AccSetAccountType.Service, AccSetAccountType, ufrmAccSetAccountType;

type
  TfrmAccSetAccountTypes = class(TfrmGrid<TAccSetAccountType, TAccSetAccountTypeService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmAccSetAccountTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmAccSetAccountType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmAccSetAccountType.Create(Self, Service, TAccSetAccountType.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmAccSetAccountType.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmAccSetAccountTypes.SetSelectedItem;

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
  Table.AccountTypeName := FieldText('account_type_name');
end;

procedure TfrmAccSetAccountTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('locale', 0);
end;

procedure TfrmAccSetAccountTypes.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmAccSetAccountTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.TitlePlural, 'Account Types');
  SetColumnTitle('account_type_key', TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.ColAccountTypeKey, 'Key'));
  SetColumnTitle('account_type_name', TLocalizationManager.Translate(TLangKeys.TAccSetAccountType.ColAccountTypeName, 'Account Type'));
end;

end.
