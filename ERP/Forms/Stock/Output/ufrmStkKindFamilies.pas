unit ufrmStkKindFamilies;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  StkKindFamily.Service, StkKindFamily, ufrmStkKindFamily;

type
  TfrmStkKindFamilies = class(TfrmGrid<TStkKindFamily, TStkKindFamilyService>)
  private
    FmniProperties: TMenuItem;
    procedure mniPropertiesClick(Sender: TObject);
  public
    procedure PreparePopupMenu; override;
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure SetSelectedItem; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  ufrmStkKindProperties, StkKindProperty, StkKindProperty.Service;              // TfrmStkKindProperties

function TfrmStkKindFamilies.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindFamily.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKindFamily.Create(Self, Service, TStkKindFamily.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindFamily.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKindFamilies.PreparePopupMenu;
begin
  inherited;
  if IsHelper then
    Exit;

  AddPopupMenuSpliter();
  FmniProperties := AddMenu(TLocalizationManager.Translate(TLangKeys.TStkKindFamily.MenuProperties, 'Kind Properties'), 'mniProperties', mniPropertiesClick);
end;

procedure TfrmStkKindFamilies.mniPropertiesClick(Sender: TObject);
var
  LFrm: TfrmStkKindProperties;
begin
  if Grd.DataSource.DataSet.IsEmpty then
    Exit;

  SetSelectedItem;
  LFrm := TfrmStkKindProperties.Create(Self, TStkKindPropertyService.Create, TStkKindProperty.Create);
  LFrm.SetFixedKindFamily(Table.Id, Table.Family);
  LFrm.Show;
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmStkKindFamilies.SetSelectedItem;

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

procedure TfrmStkKindFamilies.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
end;

procedure TfrmStkKindFamilies.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmStkKindFamilies.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.TitlePlural, 'Kind Families');
  if Assigned(FmniProperties) then
    FmniProperties.Caption := TLocalizationManager.Translate(TLangKeys.TStkKindFamily.MenuProperties, 'Kind Properties');
  SetColumnTitle('family', TLocalizationManager.Translate(TLangKeys.TStkKindFamily.ColFamily, 'Family'));
  SetColumnTitle('description', TLocalizationManager.Translate(TLangKeys.TStkKindFamily.ColDescription, 'Description'));
  SetColumnTitle('active', TLocalizationManager.Translate(TLangKeys.TStkKindFamily.ColActive, 'Active'));
end;

end.
