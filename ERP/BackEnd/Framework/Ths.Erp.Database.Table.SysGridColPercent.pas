unit Ths.Erp.Database.Table.SysGridColPercent;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , FireDAC.Stan.Param
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSysGridColPercent = class(TTable)
  private
    FTableName: TFieldDB;
    FColumnName: TFieldDB;
    FMaxValue: TFieldDB;
    FColorBar: TFieldDB;
    FColorBarBack: TFieldDB;
    FColorBarText: TFieldDB;
    FColorBarTextActive: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TableName1: TFieldDB read FTableName write FTableName;
    Property ColumnName: TFieldDB read FColumnName write FColumnName;
    property MaxValue: TFieldDB read FMaxValue write FMaxValue;
    property ColorBar: TFieldDB read FColorBar write FColorBar;
    property ColorBarBack: TFieldDB read FColorBarBack write FColorBarBack;
    property ColorBarText: TFieldDB read FColorBarText write FColorBarText;
    property ColorBarTextActive: TFieldDB read FColorBarTextActive write FColorBarTextActive;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysGridColPercent.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_col_percent';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FTableName  := TFieldDB.Create('table_name', ftString, '', Self);
  FColumnName := TFieldDB.Create('column_name', ftString, '', Self);
  FMaxValue := TFieldDB.Create('max_value', ftFloat, 0, Self);
  FColorBar := TFieldDB.Create('color_bar', ftInteger, 0, Self);
  FColorBarBack := TFieldDB.Create('color_bar_back', ftInteger, 0, Self);
  FColorBarText := TFieldDB.Create('color_bar_text', ftInteger, 0, Self);
  FColorBarTextActive := TFieldDB.Create('color_bar_text_active', ftInteger, 0, Self);
end;

procedure TSysGridColPercent.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTableName.FieldName,
        TableName + '.' + FColumnName.FieldName,
        TableName + '.' + FMaxValue.FieldName,
        TableName + '.' + FColorBar.FieldName,
        TableName + '.' + FColorBarBack.FieldName,
        TableName + '.' + FColorBarText.FieldName,
        TableName + '.' + FColorBarTextActive.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FTableName, 'Tablo Adý', QueryOfDS);
      setFieldTitle(FColumnName, 'Kolon Adý', QueryOfDS);
      setFieldTitle(FMaxValue, 'Maksimum Deðer', QueryOfDS);
      setFieldTitle(FColorBar, 'Bar Rengi', QueryOfDS);
      setFieldTitle(FColorBarBack, 'Bar Arkaplan Rengi', QueryOfDS);
      setFieldTitle(FColorBarText, 'Bar Yazý Rengi', QueryOfDS);
      setFieldTitle(FColorBarTextActive, 'Bar Aktif Yazý Rengi', QueryOfDS);
	  end;
  end;
end;

procedure TSysGridColPercent.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTableName.FieldName,
        TableName + '.' + FColumnName.FieldName,
        TableName + '.' + FMaxValue.FieldName,
        TableName + '.' + FColorBar.FieldName,
        TableName + '.' + FColorBarBack.FieldName,
        TableName + '.' + FColorBarText.FieldName,
        TableName + '.' + FColorBarTextActive.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ]);
		  Open;

		  FreeListContent();
		  List.Clear;
		  while NOT EOF do
		  begin
		    PrepareTableClassFromQuery(QueryOfList);

		    List.Add(Self.Clone);

		    Next;
		  end;
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysGridColPercent.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTableName.FieldName,
        FColumnName.FieldName,
        FMaxValue.FieldName,
        FColorBar.FieldName,
        FColorBarBack.FieldName,
        FColorBarText.FieldName,
        FColorBarTextActive.FieldName
      ]);

      PrepareInsertQueryParams;

      //bu kodlar sýfýr deðer alabilmesi durumu için yazýldý.
      QueryOfInsert.ParamByName(FMaxValue.FieldName).Value := FMaxValue.Value;
      QueryOfInsert.ParamByName(FColorBar.FieldName).Value := FColorBar.Value;
      QueryOfInsert.ParamByName(FColorBarBack.FieldName).Value := FColorBarBack.Value;
      QueryOfInsert.ParamByName(FColorBarText.FieldName).Value := FColorBarText.Value;
      QueryOfInsert.ParamByName(FColorBarTextActive.FieldName).Value := FColorBarTextActive.Value;

		  Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        AID := 0;

		  EmptyDataSet;
		  Close;
	  end;
    Self.notify;
  end;
end;

procedure TSysGridColPercent.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTableName.FieldName,
        FColumnName.FieldName,
        FMaxValue.FieldName,
        FColorBar.FieldName,
        FColorBarBack.FieldName,
        FColorBarText.FieldName,
        FColorBarTextActive.FieldName
      ]);

      PrepareUpdateQueryParams;

      //bu kodlar sýfýr deðer alabilmesi durumu için yazýldý.
      QueryOfUpdate.ParamByName(FMaxValue.FieldName).Value := FMaxValue.Value;
      QueryOfUpdate.ParamByName(FColorBar.FieldName).Value := FColorBar.Value;
      QueryOfUpdate.ParamByName(FColorBarBack.FieldName).Value := FColorBarBack.Value;
      QueryOfUpdate.ParamByName(FColorBarText.FieldName).Value := FColorBarText.Value;
      QueryOfUpdate.ParamByName(FColorBarTextActive.FieldName).Value := FColorBarTextActive.Value;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

function TSysGridColPercent.Clone: TTable;
begin
  Result := TSysGridColPercent.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
