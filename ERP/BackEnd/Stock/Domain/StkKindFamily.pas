unit StkKindFamily;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_kind_family')]
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

    function Clone: TStkKindFamily;
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

function TStkKindFamily.Clone: TStkKindFamily;
begin
  Result := TStkKindFamily.Create;
  Result.Family := Self.Family;
  Result.Description := Self.Description;
  Result.Active := Self.Active;
end;

end.
