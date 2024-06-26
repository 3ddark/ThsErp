unit Ths.Database.Table.View.SysViewColumns;

interface

{$I Ths.inc}

uses
  Classes,
  System.Variants,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.View;

type
  TSysViewColumns = class(TView)
  private
    FTabloAdi: TFieldDB;
    FColumnName: TFieldDB;
    FIsNullable: TFieldDB;
    FDataType: TFieldDB;
    FCharacterMaximumLength: TFieldDB;
    FOrdinalPosition: TFieldDB;
    FNumericPrecision: TFieldDB;
    FNumericScale: TFieldDB;
    FOrjTableName: TFieldDB;
    FOrjColumnName: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;

    procedure Clear; override;
    function Clone: TTable; override;

    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property ColumnName: TFieldDB read FColumnName write FColumnName;
    property IsNullable: TFieldDB read FIsNullable write FIsNullable;
    property DataType: TFieldDB read FDataType write FDataType;
    property CharacterMaximumLength: TFieldDB read FCharacterMaximumLength write FCharacterMaximumLength;
    property OrdinalPosition: TFieldDB read FOrdinalPosition write FOrdinalPosition;
    property NumericPrecision: TFieldDB read FNumericPrecision write FNumericPrecision;
    property NumericScale: TFieldDB read FNumericScale write FNumericScale;
    property OrjTableName: TFieldDB read FOrjTableName write FOrjTableName;
    property OrjColumnName: TFieldDB read FOrjColumnName write FOrjColumnName;
  end;

implementation

uses
  Ths.Constants;

constructor TSysViewColumns.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_view_columns';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTabloAdi  := TFieldDB.Create('table_name', ftWideString, '', Self, 'Tablo Adı');
  FColumnName := TFieldDB.Create('column_name', ftWideString, '', Self, 'Kolon Adı');
  FIsNullable := TFieldDB.Create('is_nullable', ftBoolean, False, Self, 'Null Olabilir');
  FDataType := TFieldDB.Create('data_type', ftWideString, '', Self, 'Veri Tipi');
  FCharacterMaximumLength := TFieldDB.Create('character_maximum_length', ftInteger, 0, Self, 'Maks Uzunluk');
  FOrdinalPosition := TFieldDB.Create('ordinal_position', ftInteger, 0, Self, 'Kolon Sırası');
  FNumericPrecision := TFieldDB.Create('numeric_precision', ftInteger, 0, Self, 'Numeric Hassaslık');
  FNumericScale := TFieldDB.Create('numeric_scale', ftInteger, 0, Self, 'Numeric Ölçek');
  FOrjTableName  := TFieldDB.Create('orj_table_name', ftWideString, '', Self, 'Orj Tablo Adı');
  FOrjColumnName := TFieldDB.Create('orj_column_name', ftWideString, '', Self, 'Orj Kolon Adı');
end;

function TSysViewColumns.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FTabloAdi.QryName,
      FColumnName.QryName,
      FIsNullable.QryName,
      FDataType.QryName,
      FCharacterMaximumLength.QryName,
      FOrdinalPosition.QryName,
      FNumericPrecision.QryName,
      FNumericScale.QryName,
      FOrjTableName.QryName,
      FOrjColumnName.QryName
    ],[
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSysViewColumns.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FTabloAdi.QryName,
      FColumnName.QryName,
      FIsNullable.QryName,
      FDataType.QryName,
      FCharacterMaximumLength.QryName,
      FOrdinalPosition.QryName,
      FNumericPrecision.QryName,
      FNumericScale.QryName,
      FOrjTableName.QryName,
      FOrjColumnName.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
	finally
    Free;
  end;
end;

procedure TSysViewColumns.Clear;
begin
  inherited;
  FIsNullable.Value := False;
end;

function TSysViewColumns.Clone: TTable;
begin
  Result := TSysViewColumns.Create(Database);
  CloneClassContent(Self, Result);
end;

end.


