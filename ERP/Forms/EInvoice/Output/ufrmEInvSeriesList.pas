unit ufrmEInvSeriesList;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  EInvSeries.Service, EInvSeries, ufrmEInvSeries;

type
  TfrmEInvSeriesList = class(TfrmGrid<TEInvSeries, TEInvSeriesService>)
  private
    procedure SeriesScopeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
  public
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

procedure TfrmEInvSeriesList.SeriesScopeGetText(Sender: TField; var Text: string; DisplayText: Boolean);
begin
  if Sender.IsNull then
    Text := ''
  else
    Text := TEInvLookup.Text(elkSeriesScope, Sender.AsInteger);
end;

function TfrmEInvSeriesList.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmEInvSeries.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmEInvSeries.Create(Self, Service, TEInvSeries.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmEInvSeries.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

// Görüntü alanları [NotMapped] olduğu için grid satırından ayrıca okunur (helper dönüşü için)
procedure TfrmEInvSeriesList.SetSelectedItem;

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
  Table.LastNumber := FieldText('last_number');
end;

procedure TfrmEInvSeriesList.DefineColumnWidths;
var
  LField: TField;
begin
  inherited;
  SetColumnProperty('id', 0);
  LField := Grd.DataSource.DataSet.FindField('series_scope');
  if Assigned(LField) then
    LField.OnGetText := SeriesScopeGetText;
end;

procedure TfrmEInvSeriesList.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := True;
  ApplyLocalization;
end;

procedure TfrmEInvSeriesList.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvSeries.TitlePlural, 'e-Document Series');
  SetColumnTitle('code', TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColCode, 'Series Code'));
  SetColumnTitle('name', TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColName, 'Name'));
  SetColumnTitle('series_scope', TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColSeriesScope, 'Used For'));
  SetColumnTitle('is_default', TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColIsDefault, 'Default Series'));
  SetColumnTitle('is_active', TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColIsActive, 'Active'));
  SetColumnTitle('last_number', TLocalizationManager.Translate(TLangKeys.TEInvSeries.ColLastNumber, 'Last Number (Active Period)'));
end;

end.
