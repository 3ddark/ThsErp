unit PrsLanguageAbility;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes,
  SetPrsLanguage, SetPrsLanguageLevel, PrsPerson;

type
  [Table('prs_language_abilities')]
  TPrsLisanBilgisi = class(TEntity)
  private
    FLisanID: Int64;
    FLisan: TSetPrsLanguage;
    FOkumaID: Int64;
    FOkuma: TSetPrsLanguageLevel;
    FYazmaID: Int64;
    FYazma: TSetPrsLanguageLevel;
    FKonusmaID: Int64;
    FKonusma: TSetPrsLanguageLevel;
    FPersonelID: Int64;
    FPerson: TPrsPerson;
  public
    Property LisanID: Int64 read FLisanID write FLisanID;
    Property Lisan: TSetPrsLanguage read FLisan write FLisan;
    Property OkumaID: Int64 read FOkumaID write FOkumaID;
    Property Okuma: TSetPrsLanguageLevel read FOkuma write FOkuma;
    Property YazmaID: Int64 read FYazmaID write FYazmaID;
    Property Yazma: TSetPrsLanguageLevel read FYazma write FYazma;
    Property KonusmaID: Int64 read FKonusmaID write FKonusmaID;
    Property Konusma: TSetPrsLanguageLevel read FKonusma write FKonusma;
    Property PersonelID: Int64 read FPersonelID write FPersonelID;
    Property Personel: TPrsPerson read FPerson write FPerson;

    destructor Destroy; override;
    constructor Create; override;
  end;

implementation

constructor TPrsLisanBilgisi.Create();
begin
  inherited;
end;

destructor TPrsLisanBilgisi.Destroy;
begin
  inherited;
end;

end.
