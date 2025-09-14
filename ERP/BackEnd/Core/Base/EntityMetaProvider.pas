unit EntityMetaProvider;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  System.Rtti, System.Variants,
  SysViewColumn;

type
  TEntityMetaProvider = class
  private
    class var FFieldMetaCache: TDictionary<string, TArray<TSysViewColumn>>;
    class constructor Create;
    class destructor Destroy;
  public
    class function GetFieldMeta(const TableName: string): TArray<TSysViewColumn>;
  end;

implementation

uses ServiceContainer;

class constructor TEntityMetaProvider.Create;
begin
  FFieldMetaCache := TDictionary<string, TArray<TSysViewColumn>>.Create;
end;

class destructor TEntityMetaProvider.Destroy;
var
  nArr, n1: Integer;
  AArrModel: TArray<TSysViewColumn>;
  AKey: string;
begin
  for AKey in FFieldMetaCache.Keys do
  begin
    FFieldMetaCache.TryGetValue(AKey, AArrModel);
    if AArrModel <> nil then
    begin
      for nArr := 0 to Length(AArrModel)-1 do
      begin
        for n1 := 0 to AArrModel[nArr].Fields.Count-1 do
          AArrModel[nArr].Fields.Items[n1].OwnerEntity := nil;
        AArrModel[nArr] := nil;
      end;
    end;
  end;
  FFieldMetaCache.Free;
end;

class function TEntityMetaProvider.GetFieldMeta(const TableName: string): TArray<TSysViewColumn>;
var
  FieldMetaList: TList<TSysViewColumn>;
  LSysViewColumn: TSysViewColumn;
  n1: Integer;
begin
  if FFieldMetaCache.ContainsKey(TableName) then
  begin
    FFieldMetaCache.TryGetValue(TableName, Result);
    Exit;
  end;

  FieldMetaList := nil;
  try
    LSysViewColumn := TSysViewColumn.Create;
    try
      FieldMetaList := TServiceContainer.Instance.SysViewColumnService.Find(' AND ' + LSysViewColumn.OrjTableName.QryName + '=' + QuotedStr(TableName), False);
    finally
      for n1 := 0 to LSysViewColumn.Fields.Count-1 do
        LSysViewColumn.Fields.Items[n1].OwnerEntity := nil;
    end;

    Result := FieldMetaList.ToArray;
    FFieldMetaCache.Add(TableName, Result);
  finally
    if FieldMetaList <> nil then
      FieldMetaList.Free;
  end;
end;

end.
