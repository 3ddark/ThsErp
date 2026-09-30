unit StkKindFamily;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('stk_kind_family')]
  TStkKindFamily = class(TEntity)
  private
    FFamily: string;
    FDescription: string;
    FActive: Boolean;
  public
    [Column('family')]
    [MaxLength(32), Required(TLangKeys.TValidation.Required, True)]
    property Family: string read FFamily write FFamily;

    [Column('description')]
    [MaxLength(250)]
    property Description: string read FDescription write FDescription;

    [Column('active')]
    property Active: Boolean read FActive write FActive;

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
  Result.Id := Self.Id;
  Result.Family := Self.Family;
  Result.Description := Self.Description;
  Result.Active := Self.Active;
end;

end.
