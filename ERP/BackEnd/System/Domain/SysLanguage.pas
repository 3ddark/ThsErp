unit SysLanguage;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

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

    function Clone: TSysLanguage;
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

function TSysLanguage.Clone: TSysLanguage;
begin
  Result := TSysLanguage.Create;
  Result.Locale := Self.Locale;
  Result.NativeName := Self.NativeName;
end;

end.
