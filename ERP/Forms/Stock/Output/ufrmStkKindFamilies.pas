unit ufrmStkKindFamilies;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, StkKindFamily.Service, StkKindFamily, ufrmStkKindFamily,
  LocalizationManager;

type
  TfrmStkKindFamilies = class(TfrmGrid<TStkKindFamily, TStkKindFamilyService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineFooterColumns; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmStkKindFamilies.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmStkKindFamily.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmStkKindFamily.Create(Self, Service, TStkKindFamily.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmStkKindFamily.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmStkKindFamilies.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',              0, TLocalizationManager.Translate('stk_kind_family.col_id', 'Id'));
  SetColumnProperty('family',         120, TLocalizationManager.Translate('stk_kind_family.col_family', 'Family'));
  SetColumnProperty('description',    200, TLocalizationManager.Translate('stk_kind_family.col_description', 'Description'));
  SetColumnProperty('active',          60, TLocalizationManager.Translate('stk_kind_family.col_active', 'Active'));
end;

procedure TfrmStkKindFamilies.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
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
  Self.Caption := TLocalizationManager.Translate('stk_kind_family.title_plural', 'Stock Kind Families');
end;

end.
