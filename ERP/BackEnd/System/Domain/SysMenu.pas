unit SysMenu;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager, SysLanguage;

type
  TSysMenuLevel = (smlModule, smlGroup, smlScreen);

  // Menü ağacı satırı (vw_sys_menu, etkin dilde). Kod MMGGSS: modül MM0000, grup MMGG00, ekran SS 01-99.
  // Kodlar kalıcıdır: ekran başlığında gösterilir, kılavuz / destek bu kodla ekranı tarif eder.
  TSysMenuItem = record
    Id: Int64;
    MenuCode: Integer;
    ParentCode: Integer;       // modülde 0
    MenuKey: string;
    ActionName: string;        // klasörde boş
    PermissionCode: Integer;   // 0 = herkese açık (klasörler, şifre değiştir)
    MenuName: string;
    Keywords: string;
    IsActive: Boolean;         // pasif satır (ve altındakiler) ağaçta görünmez, action'ı kapalı
    Allowed: Boolean;          // servis doldurur: okuma yetkisi (super user hepsi)
    // oturumdaki kullanıcının tercihleri (sys_user_menu)
    IsFavorite: Boolean;
    OpenCount: Integer;
    LastOpenedAt: TDateTime;   // 0 = hiç açılmadı
    function Level: TSysMenuLevel;
    function IsFolder: Boolean;
    function CodeText: string;
  end;

  [Table('sys_menu_translation', 'public')]
  TSysMenuTranslation = class(TEntityBase)
  private
    FSysMenuId: Int64;
    FSysLanguageId: Int64;
    FMenuName: string;
    FKeywords: string;
    FSysLanguage: TSysLanguage;
  public
    [Column('sys_menu_id', [cpPrimaryKey])]
    property SysMenuId: Int64 read FSysMenuId write FSysMenuId;

    [Column('sys_language_id', [cpPrimaryKey])]
    property SysLanguageId: Int64 read FSysLanguageId write FSysLanguageId;

    [Column('menu_name'), MaxLength(128)]
    property MenuName: string read FMenuName write FMenuName;

    [Column('keywords'), MaxLength(512)]
    property Keywords: string read FKeywords write FKeywords;

    [BelongsTo('SysLanguageId')]
    property SysLanguage: TSysLanguage read FSysLanguage write FSysLanguage;

    constructor Create; override;
    destructor Destroy; override;
    function Clone: TSysMenuTranslation;
  end;

  // Menü bakım ekranı: ad / anahtar kelime (dil bazında), aktiflik, yetki. Kod, anahtar ve action eklendikten sonra değişmez.
  [Table('sys_menu', 'public')]
  TSysMenu = class(TEntity)
  private
    FMenuCode: Integer;
    FMenuKey: string;
    FActionName: string;
    FSysPermissionId: Int64;
    FIsActive: Boolean;
    FParentCode: Integer;
    FPermissionCode: Integer;
    FPermissionName: string;
    FMenuName: string;
    FParentPath: string;
    FTranslations: TObjectList<TSysMenuTranslation>;
  public
    [Column('menu_code', [cpNotNull]), Required(TLangKeys.TValidation.Required, True)]
    property MenuCode: Integer read FMenuCode write FMenuCode;

    [Column('menu_key', [cpNotNull]), MaxLength(64), Required(TLangKeys.TValidation.Required, True)]
    property MenuKey: string read FMenuKey write FMenuKey;

    [Column('action_name'), MaxLength(64)]
    property ActionName: string read FActionName write FActionName;

    [Column('sys_permission_id')]
    property SysPermissionId: Int64 read FSysPermissionId write FSysPermissionId;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    // koddan türetilir (generated column)
    [NotMapped]
    property ParentCode: Integer read FParentCode write FParentCode;
    [NotMapped]
    property PermissionCode: Integer read FPermissionCode write FPermissionCode;
    [NotMapped]
    property PermissionName: string read FPermissionName write FPermissionName;
    [NotMapped]
    property MenuName: string read FMenuName write FMenuName;
    [NotMapped]
    property ParentPath: string read FParentPath write FParentPath;

    [HasMany('SysMenuId', 'Id')]
    property Translations: TObjectList<TSysMenuTranslation> read FTranslations write FTranslations;

    constructor Create; override;
    destructor Destroy; override;
    function Clone: TSysMenu;
    function IsFolder: Boolean;
  end;

  // Ekran başlığına eklenen kod: "Müşteri Çekleri [300301]"
  function FormatScreenCode(ACode: Integer): string;

implementation

function FormatScreenCode(ACode: Integer): string;
begin
  Result := Format('[%d]', [ACode]);
end;

{ TSysMenuItem }

function TSysMenuItem.Level: TSysMenuLevel;
begin
  if MenuCode mod 10000 = 0 then
    Result := smlModule
  else if MenuCode mod 100 = 0 then
    Result := smlGroup
  else
    Result := smlScreen;
end;

function TSysMenuItem.IsFolder: Boolean;
begin
  Result := Level <> smlScreen;
end;

function TSysMenuItem.CodeText: string;
begin
  Result := IntToStr(MenuCode);
end;

{ TSysMenuTranslation }

constructor TSysMenuTranslation.Create;
begin
  inherited;
  FSysLanguage := nil;
end;

destructor TSysMenuTranslation.Destroy;
begin
  FSysLanguage.Free;
  inherited;
end;

function TSysMenuTranslation.Clone: TSysMenuTranslation;
begin
  Result := TSysMenuTranslation.Create;
  Result.SysMenuId := Self.SysMenuId;
  Result.SysLanguageId := Self.SysLanguageId;
  Result.MenuName := Self.MenuName;
  Result.Keywords := Self.Keywords;
  if Assigned(Self.SysLanguage) then
    Result.SysLanguage := Self.SysLanguage.Clone;
end;

{ TSysMenu }

constructor TSysMenu.Create;
begin
  inherited;
  FIsActive := True;
  FTranslations := nil;
end;

destructor TSysMenu.Destroy;
begin
  FTranslations.Free;
  inherited;
end;

function TSysMenu.IsFolder: Boolean;
begin
  Result := FMenuCode mod 100 = 0;
end;

function TSysMenu.Clone: TSysMenu;
var
  LItem: TSysMenuTranslation;
begin
  Result := TSysMenu.Create;
  Result.Id := Self.Id;
  Result.MenuCode := Self.MenuCode;
  Result.MenuKey := Self.MenuKey;
  Result.ActionName := Self.ActionName;
  Result.SysPermissionId := Self.SysPermissionId;
  Result.IsActive := Self.IsActive;
  Result.ParentCode := Self.ParentCode;
  Result.PermissionCode := Self.PermissionCode;
  Result.PermissionName := Self.PermissionName;
  Result.MenuName := Self.MenuName;
  Result.ParentPath := Self.ParentPath;
  Result.Translations := TObjectList<TSysMenuTranslation>.Create(True);
  if Assigned(Self.Translations) then
    for LItem in Self.Translations do
      Result.Translations.Add(LItem.Clone);
end;

end.
