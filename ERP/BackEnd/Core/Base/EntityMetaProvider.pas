unit EntityMetaProvider;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  System.Rtti, System.Variants, System.StrUtils,
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
begin
  FFieldMetaCache.Free;
end;

class function TEntityMetaProvider.GetFieldMeta(const TableName: string): TArray<TSysViewColumn>;
var
  FieldMetaList: TList<TSysViewColumn>;
  LSysViewColumn: TSysViewColumn;
begin
  if FFieldMetaCache.ContainsKey(TableName) then
  begin
    FFieldMetaCache.TryGetValue(TableName, Result);
    Exit;
  end;

  FieldMetaList := TList<TSysViewColumn>.Create;
  try
    LSysViewColumn := TSysViewColumn.Create;
    try
//      TServiceContainer.Instance.
//
//      while not LSysViewColumn.Eof do
//      begin
//        FM.FieldName   := LSysViewColumn.FieldByName('COLUMN_NAME').AsString;
//        FM.Required    := LSysViewColumn.FieldByName('NULLABLE').AsInteger = 0;
//        FM.MaxLength   := LSysViewColumn.FieldByName('COLUMN_LENGTH').AsInteger;
//        FM.DataTypeName := LSysViewColumn.FieldByName('COLUMN_TYPENAME').AsString;
//        FM.DataTypeInt := LSysViewColumn.FieldByName('COLUMN_DATATYPE').AsInteger;
//
//        FieldMetaList.Add(FM);
//        LSysViewColumn.Next;
//      end;
    finally
      LSysViewColumn.Free;
    end;

    Result := FieldMetaList.ToArray;
    FFieldMetaCache.Add(TableName, Result);
  finally
    FieldMetaList.Free;
  end;
end;

end.
