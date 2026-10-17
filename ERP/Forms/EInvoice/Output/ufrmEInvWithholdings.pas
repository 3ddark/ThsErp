unit ufrmEInvWithholdings;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvWithholding.Service, EInvWithholding, ufrmEInvWithholding;

type
  TfrmEInvWithholdings = class(TfrmGrid<TEInvWithholding, TEInvWithholdingService>)
  private

  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    procedure SetActiveOnly;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvWithholdings.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvWithholdings.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvWithholding.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvWithholding.Create(Self, Service, TEInvWithholding.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvWithholding.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvWithholdings.SetSelectedItem;

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

end;

procedure TfrmEInvWithholdings.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvWithholdings.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvWithholdings.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvWithholding.TitlePlural, 'Withholding Codes');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColCode, 'Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColName, 'Description'));
  SetColumnTitle('rate', TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColRate, 'Withholding Rate (%)'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvWithholding.ColIsActive, 'Active'));
end;

end.
