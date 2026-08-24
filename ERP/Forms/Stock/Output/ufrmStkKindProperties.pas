unit ufrmStkKindProperties;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkKindProperty.Service, StkKindProperty, ufrmStkKindProperty,
  LocalizationManager;

type
  TfrmStkKindProperties = class(TfrmGrid<TStkKindProperty, TStkKindPropertyService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmStkKindProperties.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindProperty.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKindProperty.Create(Self, Service, TStkKindProperty.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindProperty.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKindProperties.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('stk_kind_property.col_id', 'Id'));
  SetColumnProperty('kind',           100, TLocalizationManager.Translate('stk_kind_property.col_kind', 'Kind'));
  SetColumnProperty('desciption',     200, TLocalizationManager.Translate('stk_kind_property.col_description', 'Description'));
  SetColumnProperty('s1',             60, TLocalizationManager.Translate('stk_kind_property.col_s1', 'S1'));
  SetColumnProperty('s2',             60, TLocalizationManager.Translate('stk_kind_property.col_s2', 'S2'));
  SetColumnProperty('s3',             60, TLocalizationManager.Translate('stk_kind_property.col_s3', 'S3'));
  SetColumnProperty('s4',             60, TLocalizationManager.Translate('stk_kind_property.col_s4', 'S4'));
  SetColumnProperty('s5',             60, TLocalizationManager.Translate('stk_kind_property.col_s5', 'S5'));
  SetColumnProperty('s6',             60, TLocalizationManager.Translate('stk_kind_property.col_s6', 'S6'));
  SetColumnProperty('s7',             60, TLocalizationManager.Translate('stk_kind_property.col_s7', 'S7'));
  SetColumnProperty('s8',             60, TLocalizationManager.Translate('stk_kind_property.col_s8', 'S8'));
  SetColumnProperty('s9',             60, TLocalizationManager.Translate('stk_kind_property.col_s9', 'S9'));
end;

procedure TfrmStkKindProperties.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
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
  Self.Caption := TLocalizationManager.Translate('stk_kind_property.title_plural', 'Stock Kind Properties');
end;

end.
