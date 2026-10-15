unit ufrmSysMenus;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmGrid, SharedFormTypes, LocalizationManager,
  SysMenu, SysMenu.Service, ufrmSysMenu;

type
  // Menü ekranları (sys_menu): ad / arama kelimesi / aktiflik / yetki bakımı. Kopyalama yok (kod benzersiz ve kalıcı).
  TfrmSysMenus = class(TfrmGrid<TSysMenu, TSysMenuService>)
  public
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
    procedure DefineColumnWidths; override;
    procedure FormShow(Sender: TObject); override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

function TfrmSysMenus.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if AFormMode = ifmRewiev then
    Result := TfrmSysMenu.Create(Self, Service, Table.Clone, AFormMode, Self.RefreshParentGrid)
  else if AFormMode = ifmNewRecord then
    Result := TfrmSysMenu.Create(Self, Service, TSysMenu.Create, AFormMode, Self.RefreshParentGrid);
end;

procedure TfrmSysMenus.DefineColumnWidths;
begin
  inherited;
  SetColumnProperty('id', 0);
  SetColumnProperty('parent_code', 0);
  SetColumnProperty('sys_permission_id', 0);
  SetColumnProperty('locale', 0);
  SetColumnProperty('menu_code', 70);
  SetColumnProperty('menu_name', 220);
  SetColumnProperty('parent_path', 200);
  SetColumnProperty('keywords', 260);
  SetColumnProperty('permission_code', 70);
  SetColumnProperty('permission_name', 180);
  SetColumnProperty('is_active', 50);
  SetColumnProperty('action_name', 200);
  SetColumnProperty('menu_key', 200);
end;

procedure TfrmSysMenus.FormShow(Sender: TObject);
begin
  inherited;
  mniDuplicate.Visible := False;
  ApplyLocalization;
end;

procedure TfrmSysMenus.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysMenu.TitlePlural, 'Menu Screens');
  SetColumnTitle('menu_code',       TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuCode, 'Code'));
  SetColumnTitle('menu_name',       TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuName, 'Screen / Folder Name'));
  SetColumnTitle('parent_path',     TLocalizationManager.Translate(TLangKeys.TSysMenu.ColParentPath, 'Parent Folder'));
  SetColumnTitle('keywords',        TLocalizationManager.Translate(TLangKeys.TSysMenu.ColKeywords, 'Search Keywords'));
  SetColumnTitle('permission_code', TLocalizationManager.Translate(TLangKeys.TSysMenu.ColPermissionCode, 'Permission Code'));
  SetColumnTitle('permission_name', TLocalizationManager.Translate(TLangKeys.TSysMenu.ColPermission, 'Read Permission'));
  SetColumnTitle('is_active',       TLocalizationManager.Translate(TLangKeys.TSysMenu.ColIsActive, 'Active'));
  SetColumnTitle('action_name',     TLocalizationManager.Translate(TLangKeys.TSysMenu.ColActionName, 'Action'));
  SetColumnTitle('menu_key',        TLocalizationManager.Translate(TLangKeys.TSysMenu.ColMenuKey, 'Key'));
end;

end.
