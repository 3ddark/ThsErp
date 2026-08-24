unit SysLanguage;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

const
  CLangID_EN = 1;
  CLangID_TR = 2;
  CLangLocaleEN = 'en-US';
  CLangLocaleTR = 'tr-TR';

type
  [Table('sys_language')]
  TSysLanguage = class(TEntity)
  private
    FLocale: string;
    FNativeName: string;
  public
    [Column('locale'), MaxLength(32), Required()]
    property Locale: string read FLocale write FLocale;

    [Column('native_name'), MaxLength(64)]
    property NativeName: string read FNativeName write FNativeName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysLanguage.Create();
begin
  inherited;
end;

destructor TSysLanguage.Destroy;
begin
  inherited;
end;

end.
