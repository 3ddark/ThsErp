unit TableNameService;

interface

uses
  System.Rtti, System.Generics.Collections, BaseEntity;

type
  TTableNameService = class
  private
    class var FCache: TDictionary<TClass, string>;
    class constructor Create;
    class destructor Destroy;
    class function ResolveTableName(AClass: TClass): string; static;
  public
    class function TableName(AClass: TClass): string; static;
  end;

implementation

class constructor TTableNameService.Create;
begin
  FCache := TDictionary<TClass, string>.Create;
end;

class destructor TTableNameService.Destroy;
begin
  FCache.Free;
end;

class function TTableNameService.ResolveTableName(AClass: TClass): string;
var
  ctx: TRttiContext;
  rType: TRttiType;
  attr: TCustomAttribute;
begin
  ctx := TRttiContext.Create;
  rType := ctx.GetType(AClass);

  for attr in rType.GetAttributes do
    if attr is TableNameAttribute then
      Exit(TableNameAttribute(attr).Name);

  // Eğer attribute tanımlı değilse class adını kullan
  Result := AClass.ClassName;
end;

class function TTableNameService.TableName(AClass: TClass): string;
begin
  if not FCache.TryGetValue(AClass, Result) then
  begin
    Result := ResolveTableName(AClass);
    FCache.Add(AClass, Result);
  end;
end;

end.
