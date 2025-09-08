unit StkKindFamily;

interface

uses
  SysUtils, Classes, Types, BaseEntity;

type
  [TableName('stk_kind_families')]
  TStkKindFamily = class(TEntity)
  private
    FFamily: TEntityField<string>;
    FDescription: TEntityField<string>;
    FActive: TEntityField<Boolean>;
  public
    property Family: TEntityField<string> read FFamily write FFamily;
    property Description: TEntityField<string> read FDescription write FDescription;
    property Active: TEntityField<Boolean> read FActive write FActive;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkKindFamily.Create();
begin
  inherited;
  FFamily := TEntityField<string>.Create(Self, 'family');
  FDescription := TEntityField<string>.Create(Self, 'description');
  FActive := TEntityField<Boolean>.Create(Self, 'active');
end;

destructor TStkKindFamily.Destroy;
begin
  inherited;
end;

end.
