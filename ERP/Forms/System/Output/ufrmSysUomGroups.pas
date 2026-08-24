unit ufrmSysUomGroups;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  SharedFormTypes, SysUomGroup.Service, SysUomGroup, ufrmSysUomGroup, LocalizationManager;

type
  TfrmSysUomTypes = class(TfrmGrid<TSysUomGroup, TSysUomGroupService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure DefineFooterColumns; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysUomTypes.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysUomType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysUomType.Create(Self, Service, TSysUomGroup.Create, AFormMode, Self.RefreshParentGrid)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUomType.Create(Self, Service, Service.Clone(Table), AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysUomTypes.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id',      0, 'Id');
  SetColumnProperty('key',   150, TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColKey, 'Type Key'));
  SetColumnProperty('name',  200, TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColName, 'Type Name'));
  SetColumnProperty('locale',  0, TLocalizationManager.Translate(TLangKeys.TSysUomGroup.ColLocale, 'Locale'));
end;

procedure TfrmSysUomTypes.DefineFooterColumns;
begin
  inherited;
  AddFooterColumn('id', atCount, '#,##0');
end;

procedure TfrmSysUomTypes.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
end;

procedure TfrmSysUomTypes.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysUomGroup.TitlePlural, 'Unit of Measurement Types');
end;

end.
