unit StkKindFamily;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_kind_families')]
  TStkKindFamily = class(TEntity)
  private
    FFamily: string;
    FDescription: string;
    FActive: Boolean;
  public
    [Column('family')]
    Property Family: string read FFamily write FFamily;

    [Column('description')]
    Property Description: string read FDescription write FDescription;

    [Column('active')]
    Property Active: Boolean read FActive write FActive;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkKindFamily.Create;
begin
  inherited;
  FActive := True;
end;

destructor TStkKindFamily.Destroy;
begin
  inherited;
end;

end.
