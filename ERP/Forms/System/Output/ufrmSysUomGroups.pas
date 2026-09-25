unit ufrmSysUomGroups;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysUomGroup.Service, SysUomGroup, ufrmSysUomGroup;

type
  TfrmSysUomGroups = class(TfrmGrid<TSysUomGroup, TSysUomGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysUomGroups.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUomGroup.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUomGroup.Create(Self, Service, TSysUomGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUomGroup.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUomGroups.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',      0, TLocalizationManager.Translate(TLangKeys.TGridColumn.ColId, 'Id'));
  SetColumnProperty('locale',  0, TLocalizationManager.Translate(TLangKeys.TSysLanguage.ColLocale, 'Locale'));
end;

procedure TfrmSysUomGroups.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysUomGroups.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUomGroup.TitlePlural, 'Unit of Measurement Types');
  SetColumnTitle('uom_group_key',    TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColKey, 'Type Key'));
  SetColumnTitle('uom_group_name',   TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColName, 'Type Name'));
  SetColumnTitle('locale', TLocalizationManager.Translate(TLangKeys.TSysLanguage.ColLocale, 'Locale'));
end;

end.
