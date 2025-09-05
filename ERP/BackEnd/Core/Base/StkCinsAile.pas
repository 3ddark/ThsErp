unit StkCinsAile;

interface

uses
  SysUtils, Classes, Types, BaseEntity;

type
  TStkCinsAile = class(TEntity)
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

constructor TStkCinsAile.Create();
begin
  inherited;
  TableName := 'stk_cins_aileleri';
  FFamily := TEntityField<string>.Create(Self, 'family');
  FDescription := TEntityField<string>.Create(Self, 'description');
  FActive := TEntityField<Boolean>.Create(Self, 'active');
end;

destructor TStkCinsAile.Destroy;
var
  n1: Integer;
begin
  for n1 := 0 to Fields.Count-1 do
    Fields.Items[n1] := nil;

  inherited;
end;

end.
