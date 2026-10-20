unit ufrmEInvDeliveryTerms;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvDeliveryTerm.Service, EInvDeliveryTerm, ufrmEInvDeliveryTerm;

type
  TfrmEInvDeliveryTerms = class(TfrmGrid<TEInvDeliveryTerm, TEInvDeliveryTermService>)
  private

  public
    // Yardımcı seçimde yalnız aktif kayıtlar (Show öncesi)
    procedure SetActiveOnly;
    // Yalnız Incoterms (True: ihracat) ya da yalnız yurt içi teslim şekilleri (False)
    procedure SetIncotermsOnly(AValue: Boolean);
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

procedure TfrmEInvDeliveryTerms.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

procedure TfrmEInvDeliveryTerms.SetIncotermsOnly(AValue: Boolean);
begin
  AddFixedFilter('is_incoterms', AValue);
end;

function TfrmEInvDeliveryTerms.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvDeliveryTerm.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvDeliveryTerm.Create(Self, Service, TEInvDeliveryTerm.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvDeliveryTerm.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvDeliveryTerms.SetSelectedItem;

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

procedure TfrmEInvDeliveryTerms.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvDeliveryTerms.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvDeliveryTerms.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.TitlePlural, 'Delivery Terms');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColCode, 'Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColName, 'Name'));
  SetColumnTitle('is_incoterms', TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColIsIncoterms, 'INCOTERMS (written to e-document)'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvDeliveryTerm.ColIsActive, 'Active'));
end;

end.
