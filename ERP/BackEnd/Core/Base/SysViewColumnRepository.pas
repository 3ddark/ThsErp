unit SysViewColumnRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, SysViewColumn, TableNameService;

type
  TSysViewColumnRepository = class(TBaseRepository<TSysViewColumn>)
  public
    constructor Create(AConnection: TFDConnection);
    function CreateQueryForUI(const AFilterKey: string): string; override;
  end;

implementation

constructor TSysViewColumnRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysViewColumnRepository.CreateQueryForUI(const AFilterKey: string): string;
var
  SQL, LTableName: string;
  Entity: TSysViewColumn;
  n1: Integer;
begin
  Result := '';
  try
    Entity := TSysViewColumn.Create;
    try
      LTableName := TTableNameService.TableName(Entity.ClassType);

      SQL := Format('SELECT %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s FROM %s WHERE 1=1 ', [
        Entity.Id.QryName,
        Entity.TableName_.QryName,
        Entity.ColumnName.QryName,
        Entity.IsNullable.QryName,
        LTableName
        ]);
//        SELECT id, table_name, column_name, is_nullable, data_type, character_maximum_length, ordinal_position,
//        orj_table_name, orj_column_name, table_type, numeric_precision, numeric_scale FROM public.sys_view_columns;
    finally
      for n1 := 0 to Entity.Fields.Count-1 do
      begin
        if Entity.Fields[n1].OwnerEntity <> nil then
          Entity.Fields[n1].OwnerEntity := nil;
      end;
    end;

    Result := SQL;
  except
    raise;
  end;
end;

end.
