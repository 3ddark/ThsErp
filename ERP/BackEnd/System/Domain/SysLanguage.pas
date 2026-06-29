unit SysLanguage;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_languages')]
  TSysLanguage = class(TEntity)
  private
    FLngCode: string;
    FDescription: string;
  public
    [Column('lng_code'), MaxLength(2), Required()]
    property LngCode: string read FLngCode write FLngCode;

    [Column('description'), MaxLength(128)]
    property Description: string read FDescription write FDescription;

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
