unit SysLanguage;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_diller')]
  TSysLanguage = class(TEntity)
  private
    FKod: string;
    FAciklama: string;
  public
    [Column('kod'), MaxLength(2), Required()]
    property Kod: string read FKod write FKod;

    [Column('aciklama'), MaxLength(128)]
    property Aciklama: string read FAciklama write FAciklama;

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
