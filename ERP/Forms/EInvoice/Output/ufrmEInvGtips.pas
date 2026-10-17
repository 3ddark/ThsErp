unit ufrmEInvGtips;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvGtip.Service, EInvGtip, ufrmEInvGtip;

type
  TfrmEInvGtips = class(TfrmGrid<TEInvGtip, TEInvGtipService>)
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

procedure TfrmEInvGtips.SetActiveOnly;
begin
  AddFixedFilter('is_active', True);
end;

function TfrmEInvGtips.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvGtip.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvGtip.Create(Self, Service, TEInvGtip.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvGtip.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvGtips.SetSelectedItem;

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

procedure TfrmEInvGtips.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);

end;

procedure TfrmEInvGtips.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvGtips.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvGtip.TitlePlural, 'GTIP Codes');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvGtip.ColCode, 'GTIP Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvGtip.ColName, 'Description'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvGtip.ColIsActive, 'Active'));
end;

end.
