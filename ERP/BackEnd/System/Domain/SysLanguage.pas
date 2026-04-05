unit SysLanguage;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_languages')]
  TSysCurrency = class(TEntity)
  private
    FLngCode: string;
    FDescription: string;
  public
    [Column('lng_code')]
    property LngCode: string read FLngCode write FLngCode;

    [Column('description')]
    property Description: string read FDescription write FDescription;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysCurrency.Create();
begin
  inherited;
end;

destructor TSysCurrency.Destroy;
begin
  inherited;
end;

end.
