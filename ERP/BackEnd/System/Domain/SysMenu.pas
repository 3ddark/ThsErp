unit SysMenu;

interface

{$I Ths.inc}

uses
  System.SysUtils;

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
    Allowed: Boolean;          // servis doldurur: okuma yetkisi (super user hepsi)
    // oturumdaki kullanıcının tercihleri (sys_user_menu)
    IsFavorite: Boolean;
    OpenCount: Integer;
    LastOpenedAt: TDateTime;   // 0 = hiç açılmadı
    function Level: TSysMenuLevel;
    function IsFolder: Boolean;
    function CodeText: string;
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

end.
