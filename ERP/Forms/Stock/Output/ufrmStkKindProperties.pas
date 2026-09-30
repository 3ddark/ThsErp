unit ufrmStkKindProperties;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkKindProperty.Service, StkKindProperty, ufrmStkKindProperty;

type
  TfrmStkKindProperties = class(TfrmGrid<TStkKindProperty, TStkKindPropertyService>)
  private
    FFixedKindFamilyId: Int64;
    FFixedKindFamilyName: string;
  public
    procedure SetFixedKindFamily(AKindFamilyId: Int64; const AKindFamilyName: string);

    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkKindProperties.SetFixedKindFamily(AKindFamilyId: Int64; const AKindFamilyName: string);
begin
  FFixedKindFamilyId := AKindFamilyId;
  FFixedKindFamilyName := AKindFamilyName;
  AddFixedFilter('stk_kind_family_id', AKindFamilyId);
end;

function TfrmStkKindProperties.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
var
  LNew: TStkKindProperty;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindProperty.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
  begin
    LNew := TStkKindProperty.Create;
    if FFixedKindFamilyId > 0 then
    begin
      LNew.StkKindFamilyId := FFixedKindFamilyId;
      LNew.FamilyName := FFixedKindFamilyName;
    end;
    Result := TfrmStkKindProperty.Create(Self, Service, LNew, AFormMode, Self.RefreshParentGrid);
  end
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindProperty.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkKindProperties.SetSelectedItem;

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
  Table.FamilyName := FieldText('family_name');
end;

procedure TfrmStkKindProperties.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('stk_kind_family_id', 0);
end;

procedure TfrmStkKindProperties.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkKindProperties.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindProperty.TitlePlural, 'Kind Properties');
  if FFixedKindFamilyName <> '' then
    Self.Caption := Self.Caption + ' - ' + FFixedKindFamilyName;
  SetColumnTitle('kind', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColKind, 'Kind'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColDescription, 'Description'));
  SetColumnTitle('family_name', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColFamily, 'Family'));
  SetColumnTitle('s1', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS1, 'Text 1'));
  SetColumnTitle('s2', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS2, 'Text 2'));
  SetColumnTitle('s3', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS3, 'Text 3'));
  SetColumnTitle('s4', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS4, 'Text 4'));
  SetColumnTitle('s5', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS5, 'Text 5'));
  SetColumnTitle('s6', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS6, 'Text 6'));
  SetColumnTitle('s7', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS7, 'Text 7'));
  SetColumnTitle('s8', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS8, 'Text 8'));
  SetColumnTitle('s9', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS9, 'Text 9'));
  SetColumnTitle('s10', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColS10, 'Text 10'));
  SetColumnTitle('i1', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI1, 'Integer 1'));
  SetColumnTitle('i2', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI2, 'Integer 2'));
  SetColumnTitle('i3', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI3, 'Integer 3'));
  SetColumnTitle('i4', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI4, 'Integer 4'));
  SetColumnTitle('i5', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColI5, 'Integer 5'));
  SetColumnTitle('d1', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD1, 'Decimal 1'));
  SetColumnTitle('d2', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD2, 'Decimal 2'));
  SetColumnTitle('d3', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD3, 'Decimal 3'));
  SetColumnTitle('d4', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD4, 'Decimal 4'));
  SetColumnTitle('d5', TLocalizationManager.Translate(TLangKeys.TStkKindProperty.ColD5, 'Decimal 5'));
end;

end.
