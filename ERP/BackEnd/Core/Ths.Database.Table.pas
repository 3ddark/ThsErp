unit Ths.Database.Table;

interface

{$I Ths.inc}

uses
  Forms,
  SysUtils,
  Windows,
  Classes,
  Dialogs,
  Messages,
  System.Variants,
  Graphics,
  Controls,
  ExtCtrls,
  ComCtrls,
  System.UITypes,
  System.Rtti,
  Data.DB,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Combobox,
  Ths.Helper.Memo,
  Ths.Database;

{$M+}

type
  TJoinType = (jtLeft, jtRight, jtInner, jtFullOuter);

  TTable = class;

  TFieldDB = class
  private
    FFieldName: string;
    FDataType: TFieldType;
    FValue: Variant;
    FSize: Integer;
    FIsNullable: Boolean;
    FOtherFieldName: string;
    FOwnerTable: TTable;
    FTitle: string;
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
  public
    destructor Destroy; override;

    property FieldName: string read FFieldName write FFieldName;
    property DataType: TFieldType read FDataType write FDataType;
    property Value: Variant read GetValue write SetValue;
    property Size: Integer read FSize write FSize default 0;
    property IsNullable: Boolean read FIsNullable write FIsNullable default True;
    property OtherFieldName: string read FOtherFieldName write FOtherFieldName;
    property OwnerTable: TTable read FOwnerTable write FOwnerTable;
    property Title: string read FTitle write FTitle;

    constructor Create(const AFieldName: string;
                       const AFieldType: TFieldType;
                       const AValue: Variant;
                       AOwnerTable: TTable;
                       const ATitle: string;
                       const AOtherFieldName: string = '';
                       const AMaxLength: Integer=0;
                       const AIsNullable: Boolean=True);

    procedure Clone(var AField: TFieldDB);

    function QryName: string;

    function AsString: string;
    function AsFloat: Double;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsBoolean: Boolean;
    function AsDate: TDate;
    function AsDateTime: TDateTime;
    function AsTime: TTime;
    function AsBytes: TBytes;
  end;

  TTable = class
  private
    FSchemaName: string;
    FTableName: string;
    FTableSourceCode: string;

    FDatabase: TDatabase;

    FFields: TArray<TFieldDB>;

    function GetTableName: string;
    procedure SetTableName(ATableName: string);
  protected
    FList: TList;
    FDataSource: TDataSource;

    FQryOfDS: TZQuery;

    procedure FreeListContent; virtual;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); virtual;
    procedure BusinessInsert(APermissionControl: Boolean); virtual;
    procedure BusinessUpdate(APermissionControl: Boolean); virtual;
    procedure BusinessDelete(APermissionControl: Boolean); virtual;
  published
    constructor Create(ADatabase: TDatabase); virtual;
    destructor Destroy; override;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
  public
    Deleted: Boolean;
    Id: TFieldDB;

    property SchemaName: string read FSchemaName write FSchemaName;
    property TableName: string read GetTableName write SetTableName;
    property TableSourceCode: string read FTableSourceCode write FTableSourceCode;

    property Database: TDatabase read FDatabase;

    property List: TList read FList;

    property DataSource: TDataSource read FDataSource;

    property Fields: TArray<TFieldDB> read FFields write FFields;

    property QryOfDS: TZQuery read FQryOfDS write FQryOfDS;

    procedure Listen; virtual;
    procedure Unlisten; virtual;
    procedure Notify; virtual;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); virtual; abstract;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); virtual; abstract;

    procedure Insert(APermissionControl: Boolean=True); virtual;
    procedure DoInsert(APermissionControl: Boolean=True); virtual; abstract;
    procedure BeforeInsertDB;
    procedure AfterInsertDB;

    procedure Update(APermissionControl: Boolean=True); virtual;
    procedure DoUpdate(APermissionControl: Boolean=True); virtual; abstract;
    procedure BeforeUpdateDB;
    procedure AfterUpdateDB;

    procedure Delete(APermissionControl: Boolean=True); virtual;
    procedure DoDelete(APermissionControl: Boolean=True); virtual;
    procedure DoDeleteWith(AIDs: TArray<Int64>; APermissionControl: Boolean=True); virtual;
    procedure DoDeleteWithCustom(AIDs: TArray<Int64>; ATableName: string; APermissionControl: Boolean=True); virtual;
    procedure BeforeDeleteDB;
    procedure AfterDeleteDB;

    procedure Clear; virtual;
    function Clone: TTable; virtual; abstract;
    procedure CloneClassContent(ASrc, ADes: TTable);

    function LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionControl: Boolean):Boolean; virtual;
    function LogicalInsert(AWithBegin, AWithCommit, APermissionControl: Boolean):Boolean; virtual;
    function LogicalUpdate(AWithCommit, APermissionControl: Boolean):Boolean; virtual;
    function LogicalDelete(AWithCommit, APermissionControl: Boolean):Boolean; virtual;

    procedure PrepareTableClassFromQuery(AQuery: TZQuery);
    procedure PrepareInsertQueryParams(AQuery: TZQuery);
    procedure PrepareUpdateQueryParams(AQuery: TZQuery);

    function GetLockSQL(AFilter: string; ALock: Boolean): string;

    procedure PrepareTableRequiredValues;

    function GetFieldByFieldName(AFieldName: string): TFieldDB;

    procedure SetFieldDBPropsFromDbInfo;

    function FindField(AFieldName: string): TFieldDB;
  end;

  procedure setFieldTitle(AField: TFieldDB; ATitle: string; ADataSet: TDataSet);
  procedure setFieldValue(AField: TFieldDB; ADataSet: TDataSet);
  procedure setDisplayFormatString(AFieldName: string; AFormat: string; ADataSet: TDataSet);
  procedure setDisplayFormatInteger(AFieldName: string; AFormat: string; ADataSet: TDataSet);
  procedure setDisplayFormatFloat(AFieldName: string; AFormat: string; ADataSet: TDataSet);
  procedure setDisplayFormatDate(AFieldName: string; AFormat: string; ADataSet: TDataSet);
  function addLeftJoin(AFieldName, AIDFieldName, ATableName: string; IsPureData: Boolean = False): string;
  function addJoin(AJoin: TJoinType; ARefTable, ARefField, ATableName, AFieldName: string; ARefTableAlias: string = ''; ACustSQL: string = ''): string;
  function addField(ARefTable, ARefField, AFieldName: string; ARefTableAlias: string = ''): string;
  function addLangField(AFieldName: string; ADataFieldNameDiff: string = ''; IsPureData: Boolean = False): string;
  function GetVarArrayByteSize(AField: TFieldDB): Int64;
  procedure setValueFromImage(AField: TFieldDB; AImage: TImage);
  procedure LoadImageFromDB(AField: TFieldDB; AImage: TImage);

implementation

uses
  Ths.Globals,
  Ths.Database.Table.View.SysViewColumns,
  Ths.Database.Table.SysErisimHaklari,
  Ths.Database.Table.SysKaynaklar;

procedure setFieldTitle(AField: TFieldDB; ATitle: string; ADataSet: TDataSet);
var
  AFld: TField;
begin
  AFld := ADataSet.FindField(AField.FieldName);
  if AFld <> nil then
    AFld.DisplayLabel := ATitle;
end;

procedure setFieldValue(AField: TFieldDB; ADataSet: TDataSet);
var
  AFld: TField;
begin
  AFld := ADataSet.FindField(AField.FieldName);
  if AFld <> nil then
  begin
    AField.Value := FormatedVariantVal(AFld.DataType, AFld.Value);
    if (AField.DataType = ftBytes) and AFld.IsBlob then
      AField.Value := TBlobField(AFld).Value;
  end;
end;

procedure setDisplayFormatString(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TIntegerField(AField).DisplayFormat := AFormat;
end;

procedure setDisplayFormatInteger(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TIntegerField(AField).DisplayFormat := AFormat;
end;

procedure setDisplayFormatFloat(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TFloatField(AField).DisplayFormat := AFormat;
end;

procedure setDisplayFormatDate(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TDateField(AField).DisplayFormat := AFormat;
end;

function addLeftJoin(AFieldName, AIDFieldName, ATableName: string; IsPureData: Boolean): string;
var
  LTableAlias: string;
begin
  begin
    if IsPureData then
    begin
      LTableAlias := 'data_' + AFieldName;
      Result := ' LEFT JOIN ' + ATableName + ' AS ' + LTableAlias + ' ON ' + LTableAlias + '.' + AFieldName + '=' + ATableName + '.' + AIDFieldName + ' ';
    end
    else
    begin
      //aynı lisan olunca id karşılığı verileri aynı tablodan çek
      LTableAlias := 'data_' + AFieldName;
      Result := ' LEFT JOIN ' + ATableName + ' AS ' + LTableAlias + ' ON ' + LTableAlias + '.' + 'id' + '=' + AIDFieldName + ' ';
    end;
  end;
end;

function addJoin(AJoin: TJoinType; ARefTable, ARefField, ATableName, AFieldName: string; ARefTableAlias: string; ACustSQL: string): string;
var
  LJoin, LTable: string;
begin
  case AJoin of
    jtLeft: LJoin := ' LEFT JOIN ';
    jtRight: LJoin := ' RIGHT JOIN ';
    jtInner: LJoin := ' INNER JOIN ';
    jtFullOuter: LJoin := ' FULL JOIN ';
  end;

  if ARefTableAlias <> '' then
    LTable := ARefTableAlias
  else
    LTable := ARefTable;

  Result := Trim(LJoin + ARefTable + ' ' + ARefTableAlias + ' ON ' + LTable + '.' + ARefField + '=' + ATableName + '.' + AFieldName + ' ' + ACustSQL);
end;

function addField(ARefTable, ARefField, AFieldName: string; ARefTableAlias: string): string;
var
  LTable: string;
begin
  if ARefTableAlias <> '' then
    LTable := ARefTableAlias
  else
    LTable := ARefTable;

  Result := LTable + '.' + ARefField + ' ' + AFieldName;
end;

function addLangField(AFieldName: string; ADataFieldNameDiff: string; IsPureData: Boolean): string;
begin
  if IsPureData then
    Result := 'data_' + AFieldName
  else
  begin
    if ADataFieldNameDiff <> '' then
      Result := 'data_' + AFieldName + '.' + ADataFieldNameDiff + ' AS ' + AFieldName
    else
      Result := 'data_' + AFieldName + '.' + AFieldName + ' AS ' + AFieldName
  end;
end;

function GetVarArrayByteSize(AField: TFieldDB): Int64;
begin
  Result := 0;
  if AField.DataType = ftBytes then
  begin
    if Length(AField.Value) = 0 then
      Exit;
    Result := ( VarArrayHighBound(AField.Value, 1) -
                VarArrayLowBound(AField.Value, 1) + 1
              ) * TVarData(AField.Value).VArray^.ElementSize;
  end;
end;

procedure setValueFromImage(AField: TFieldDB; AImage: TImage);
var
  ms: TMemoryStream;
  LLen: Int64;
  LByt: TBytes;
begin
  ms := TMemoryStream.Create;
  try
    if AImage.Picture.Graphic <> nil then
    begin
      AImage.Picture.Graphic.SaveToStream(ms);
      ms.Position := 0;
      LLen := ms.Size;
      SetLength(LByt, LLen);
      ms.Read(Pointer(LByt)^, LLen);
      AField.Value := LByt;
    end
    else
      AField.Value := 0;
  finally
    ms.Free;
  end;
end;

procedure LoadImageFromDB(AField: TFieldDB; AImage: TImage);
var
  ms: TMemoryStream;
  LPic: TPicture;
  LSize: Int64;
begin
  AImage.Picture.Assign(nil);
  if AField.DataType <> ftBytes then
    Exit;

  if not VarIsNull(AField.Value) then
  begin
    LPic := TPicture.Create;
    ms := TMemoryStream.Create;
    try
      LSize := GetVarArrayByteSize(AField);
      if LSize = 0 then
        Exit;

      ms.Write(AField.Value, 0, LSize);
      ms.Position := 0;
      LPic.LoadFromStream(ms);
      AImage.Picture.Assign(LPic);
    finally
      LPic.Free;
      ms.Free;
    end;
  end;
end;

constructor TFieldDB.Create(
  const AFieldName: string;
  const AFieldType: TFieldType;
  const AValue: Variant;
  AOwnerTable: TTable;
  const ATitle: string;
  const AOtherFieldName: string = '';
  const AMaxLength: Integer=0;
  const AIsNullable: Boolean=True);
begin
  FFieldName := AFieldName;
  FDataType := AFieldType;
  FValue := AValue;
  FSize := AMaxLength;
  FIsNullable := AIsNullable;
  if AOtherFieldName = ''
  then  FOtherFieldName := FFieldName
  else  FOtherFieldName := AOtherFieldName;

  FOwnerTable := AOwnerTable;

  if ATitle = ''
  then  FTitle := AFieldName
  else  FTitle := ATitle;

  if FOwnerTable <> nil then
  begin
    SetLength(FOwnerTable.FFields, Length(FOwnerTable.FFields)+1);
    FOwnerTable.FFields[Length(FOwnerTable.FFields)-1] := Self
  end;
end;

destructor TFieldDB.Destroy;
begin
  inherited;
end;

function TFieldDB.QryName: string;
begin
  Result := FOwnerTable.TableName + '.' + FieldName;
end;

function TFieldDB.GetValue: Variant;
begin
  Result := FValue;
end;

procedure TFieldDB.SetValue(const Value: Variant);
begin
  FValue := Value;

  if VarIsStr(FValue) and (FValue = '') then
    case FDataType of
      ftUnknown: ;
      ftString: ;
      ftSmallint: FValue := 0;
      ftInteger: FValue := 0;
      ftWord: FValue := 0;
      ftBoolean: ;
      ftFloat: FValue := 0;
      ftCurrency: FValue := 0;
      ftBCD: ;
      ftDate: FValue := 0;
      ftTime: FValue := 0;
      ftDateTime: FValue := 0;
      ftBytes: ;
      ftVarBytes: ;
      ftAutoInc: ;
      ftBlob: ;
      ftMemo: ;
      ftGraphic: ;
      ftFmtMemo: ;
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar: ;
      ftWideString: ;
      ftLargeint: ;
      ftADT: ;
      ftArray: ;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp: FValue := 0;
      ftFMTBcd: FValue := 0;
      ftFixedWideChar: ;
      ftWideMemo: ;
      ftOraTimeStamp: ;
      ftOraInterval: ;
      ftLongWord: FValue := 0;
      ftShortint: FValue := 0;
      ftByte: ;
      ftExtended: ;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle: ;
    end;
end;

function TFieldDB.AsBoolean: Boolean;
begin
  Result := StrToBool(System.Variants.VarToStr(FValue))
end;

function TFieldDB.AsBytes: TBytes;
begin
  if Self.DataType <> ftBytes then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  SetLength(Result, Length(Self.Value));
  Move(Self.Value, Result, Length(Self.Value));
end;

function TFieldDB.AsDate: TDate;
begin
  Result := System.Variants.VarToDateTime(FValue)
end;

function TFieldDB.AsDateTime: TDateTime;
begin
  Result := System.Variants.VarToDateTime(FValue);
end;

function TFieldDB.AsFloat: Double;
begin
  Result := FValue;
end;

function TFieldDB.AsInt64: Int64;
begin
  Result := VarToInt64(FValue);
end;

function TFieldDB.AsInteger: Integer;
begin
  Result := VarToInt(FValue);
end;

function TFieldDB.AsString: string;
begin
  try
    Result := VarToStr(FValue);
  except
    Result := '';
  end;
end;

function TFieldDB.AsTime: TTime;
begin
  Result := StrToTimeDef(VarToStr(FValue), 0);
end;

procedure TFieldDB.Clone(var AField: TFieldDB);
begin
  AField.FOwnerTable := FOwnerTable;
  AField.FFieldName := FFieldName;
  AField.FDataType := FDataType;
  AField.FValue := FValue;
  AField.FSize := FSize;
  AField.FIsNullable := FIsNullable;
  AField.FOtherFieldName := FOtherFieldName;
end;

procedure TTable.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  SelectToList(AFilter, ALock, APermissionControl);
end;

procedure TTable.BusinessInsert(APermissionControl: Boolean);
begin
  Insert(APermissionControl)
end;

procedure TTable.BusinessUpdate(APermissionControl: Boolean);
begin
  Update(APermissionControl)
end;

procedure TTable.BusinessDelete(APermissionControl: Boolean);
begin
  Delete(APermissionControl);
end;

procedure TTable.Clear;
var
  n1: Integer;
begin
  for n1 := 0 to Length(FFields)-1 do
  begin
    if Assigned(FFields[n1]) then
    begin
      with FFields[n1] do
      begin
        if (DataType = ftString)
        or (DataType = ftWideString)
        or (DataType = ftMemo)
        or (DataType = ftWideMemo)
        or (DataType = ftBytes)
        or (DataType = ftFmtMemo)
        or (DataType = ftFixedChar)
        or (DataType = ftFixedWideChar)
        then
          Value := ''
        else
        if (DataType = ftSmallint)
        or (DataType = ftInteger)
        or (DataType = ftWord)
        or (DataType = ftFloat)
        or (DataType = ftCurrency)
        or (DataType = ftBCD)
        or (DataType = ftDate)
        or (DataType = ftTime)
        or (DataType = ftDateTime)
        or (DataType = ftBytes)
        or (DataType = ftVarBytes)
        or (DataType = ftAutoInc)
        or (DataType = ftLargeint)
        or (DataType = ftTimeStamp)
        or (DataType = ftShortint)
        or (DataType = ftByte)
        then
          Value := 0
        else
        if (DataType = ftBoolean) then
          Value := False
        else
        if (DataType = ftBlob) then
          Value := Null;
      end;
    end;
  end;
end;

constructor TTable.Create(ADatabase: TDatabase);
begin
  if Trim(TableName) = '' then
    raise Exception.Create('You must define the TableName first in create!!!');

  FDatabase := ADatabase;
  FSchemaName := 'public';

  FList := TList.Create;
  FList.Clear;

  SetLength(FFields, 0);

  FQryOfDS := FDatabase.NewQuery;
  FQryOfDS.Name := 'QryOfDS';


  FDataSource := TDataSource.Create(nil);
  FDataSource.DataSet := FQryOfDS;

  Id := TFieldDB.Create('id', ftLargeint, 0, Self, 'ID');
  Id.Value := FDatabase.GetNewRecordId();

  Deleted := False;
end;

destructor TTable.Destroy;
var
  n1: Integer;
begin
  for n1 := 0 to Length(Fields)-1 do
    FreeAndNil(Fields[n1]);
  SetLength(FFields, 0);

  FreeListContent;

  if Assigned(FList) then FList.Free;
  if Assigned(FDataSource) then   FDataSource.Free;
  if Assigned(FQryOfDS) then      FQryOfDS.Free;

  FDatabase := nil;

  inherited;
end;

function TTable.FindField(AFieldName: string): TFieldDB;
var
  n1: Integer;
begin
  Result := nil;
  for n1 := 0 to Length(Fields)-1 do
    if Fields[n1].FieldName = AFieldName then
      Result := Fields[n1];
end;

procedure TTable.FreeListContent;
var
  n1: Integer;
  ATable: TTable;
begin
  for n1 := FList.Count-1 downto 0 do
  begin
    ATable := List.Items[n1];
    FreeAndNil(ATable);
    FList.Delete(n1);
  end;
  List.Clear;
end;

function TTable.GetFieldByFieldName(AFieldName: string): TFieldDB;
var
  n1, Len: Integer;
begin
  Result := nil;
  Len := Length(FFields);
  for n1 := 0 to  Len-1 do
    if FFields[n1].FieldName = AFieldName then
    begin
      Result := FFields[n1];
      Break;
    end;
end;

function TTable.GetLockSQL(AFilter: string; ALock: Boolean): string;
begin
  Result := AFilter;
  if (ALock) then
    Result := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT'
end;

function TTable.GetTableName: string;
begin
  Result := FTableName;
end;

procedure TTable.SetTableName(ATableName: string);
begin
  FTableName := ATableName;
end;

procedure TTable.AfterDeleteDB;
begin
//
end;

procedure TTable.AfterInsertDB;
begin
//
end;

procedure TTable.AfterUpdateDB;
begin
//
end;

procedure TTable.BeforeDeleteDB;
begin
//
end;

procedure TTable.BeforeInsertDB;
begin
//
end;

procedure TTable.BeforeUpdateDB;
begin
//
end;

procedure TTable.Insert(APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    BeforeInsertDB;
    DoInsert(APermissionControl);
    AfterInsertDB;
  end;
end;

procedure TTable.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    BeforeUpdateDB;
    DoUpdate(APermissionControl);
    AfterUpdateDB;
  end;
end;

procedure TTable.Delete(APermissionControl: Boolean);
begin
  if IsAuthorized(ptDelete, APermissionControl) then
  begin
    BeforeDeleteDB;
    DoDelete(APermissionControl);
    AfterDeleteDB;
  end;
end;

procedure TTable.DoDelete(APermissionControl: Boolean);
begin
  with Database.NewQuery() do
  try
    Close;
    SQL.Clear;
    SQL.Text := 'DELETE FROM ' + TableName + ' WHERE id=:id;';
    ParamByName(Id.FieldName).Value := Id.AsInteger;
    ExecSQL;
    Close;
  finally
    Free;
  end;
end;

procedure TTable.DoDeleteWith(AIDs: TArray<Int64>; APermissionControl: Boolean=True);
var
  LSb: TStringBuilder;
  n1: Integer;
  LIDs: string;
begin
  if IsAuthorized(ptDelete, APermissionControl) then
  begin
    if Length(AIDs) > 0 then
    begin
      LSb := TStringBuilder.Create;
      try
        LSb.Clear;
        for n1 := 0 to High(AIDs) do
        begin
          LSb.Append(IntToStr(AIDs[n1]));
          if n1 < High(AIDs) then
            LSb.Append(',');
        end;
        LIDs := LSb.ToString;
      finally
        LSb.Free;
      end;

      if LIDs <> '' then
      begin
        with Database.NewQuery() do
        try
          Close;
          SQL.Clear;
          SQL.Text := 'DELETE FROM ' + TableName + ' WHERE id in (:id);';
          ParamByName(Id.FieldName).Value := LIDs;
          ExecSQL;
          Close;
        finally
          Free;
        end;
      end;
    end;
  end;
end;

procedure TTable.DoDeleteWithCustom(AIDs: TArray<Int64>; ATableName: string; APermissionControl: Boolean=True);
var
  LSb: TStringBuilder;
  n1: Integer;
  LIDs: string;
begin
  if IsAuthorized(ptDelete, APermissionControl) then
  begin
    if Length(AIDs) > 0 then
    begin
      LSb := TStringBuilder.Create;
      try
        LSb.Clear;
        for n1 := 0 to High(AIDs) do
        begin
          LSb.Append(IntToStr(AIDs[n1]));
          if n1 < High(AIDs) then
            LSb.Append(',');
        end;
        LIDs := LSb.ToString;
      finally
        LSb.Free;
      end;

      if LIDs <> '' then
      begin
        with Database.NewQuery() do
        try
          Close;
          SQL.Clear;
          SQL.Text := 'DELETE FROM ' + ATableName + ' WHERE id in (:id);';
          ParamByName(Id.FieldName).Value := LIDs;
          ExecSQL;
          Close;
        finally
          Free;
        end;
      end;
    end;
  end;
end;

procedure TTable.Listen;
begin
  with Database.NewQuery() do
  try
    Close;
    SQL.Clear;
    SQL.Text := 'listen ' + TableName + ';';
    ExecSQL;
  finally
    Free;
  end;
end;

procedure TTable.Unlisten;
begin
  with Database.NewQuery() do
  try
    Close;
    SQL.Clear;
    SQL.Text := 'unlisten ' + TableName + ';';
    ExecSQL;
  finally
    Free;
  end;
end;

procedure TTable.Notify;
begin
  with Database.NewQuery() do
  try
    Close;
    SQL.Clear;
    SQL.Text := 'notify ' + TableName + ';';
    ExecSQL;
    Close;
  finally
    Free;
  end;
end;

function TTable.LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  try
    if not ALock then
      AWithBegin := False;

    if AWithBegin then
      Database.Connection.StartTransaction;
    BusinessSelect(AFilter, ALock, APermissionControl);
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
      if Database.Connection.InTransaction then
        Database.Connection.Rollback;
    end;
  end;
end;

function TTable.LogicalInsert(AWithBegin, AWithCommit, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  try
    if AWithBegin then
      GDatabase.Connection.StartTransaction;
    BusinessInsert(APermissionControl);
    if AWithCommit and GDatabase.Connection.InTransaction then
      GDatabase.Connection.Commit;
  except
    on E: Exception do
    begin
      if GDatabase.Connection.InTransaction then
        GDatabase.Connection.Rollback;
      Result := False;
      ShowMessage(E.Message);
    end;
  end;
end;

function TTable.LogicalUpdate(AWithCommit, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  try
    BusinessUpdate(APermissionControl);
    if AWithCommit then
      Database.Connection.Commit;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
      if Database.Connection.InTransaction then
        Database.Connection.Rollback;
    end;
  end;
end;

function TTable.LogicalDelete(AWithCommit, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  BusinessDelete(APermissionControl);
  if AWithCommit then
    Database.Connection.Commit;
end;

function TTable.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
var
  vField, vFilter, vMessage: string;//vSourceCode, vSourceName
  LErisimHakki: TSysErisimHakki;
  LKaynak: TSysKaynak;
begin
  Result := False;
  if APermissionControl then
  begin
    LErisimHakki := TSysErisimHakki.Create(Database);
    LKaynak := TSysKaynak.Create(Database);
    try
      vField := '';
      vFilter := '';
      vMessage := '';
      if APermissionType = ptRead then
      begin
        vField := LErisimHakki.IsOkuma.FieldName;
        vFilter := ' and ' + LErisimHakki.IsOkuma.FieldName + '=true ';
        vMessage := 'SELECT';
      end
      else if APermissionType = ptAddRecord then
      begin
        vField := LErisimHakki.IsEkleme.FieldName;
        vFilter := ' and ' + LErisimHakki.IsEkleme.FieldName + '=true ';
        vMessage := 'INSERT';
      end
      else if APermissionType = ptUpdate then
      begin
        vField := LErisimHakki.IsGuncelleme.FieldName;
        vFilter := ' and ' + LErisimHakki.IsGuncelleme.FieldName + '=true ';
        vMessage := 'UPDATE';
      end
      else if APermissionType = ptDelete then
      begin
        vField := LErisimHakki.IsSilme.FieldName;
        vFilter := ' and ' + LErisimHakki.IsSilme.FieldName + '=true ';
        vMessage := 'DELETE';
      end
      else if APermissionType = ptSpeacial then
      begin
        vField := LErisimHakki.IsOzel.FieldName;
        vFilter := ' and ' + LErisimHakki.IsOzel.FieldName + '=true ';
        vMessage := 'SPECIAL';
      end;

      with Database.NewQuery() do
      try
        Close;
        SQL.Text :=
          ' SELECT ' + vField +
          ' FROM ' + LErisimHakki.TableName +
          ' LEFT JOIN ' + LKaynak.TableName + ' ps ON ps.id=' + LErisimHakki.KaynakID.FieldName +
          ' WHERE ps.' + LKaynak.KaynakKodu.FieldName + '=' + QuotedStr(TableSourceCode) +
            ' AND ' + LErisimHakki.KullaniciID.FieldName + '=' + VarToStr(GSysKullanici.Id.Value) + vFilter;
        Open;
        while NOT EOF do
        begin
          Result := Fields.Fields[0].AsBoolean;

          Next;
        end;
        EmptyDataSet;
        Close;
      finally
        Free;
      end;

      if not Result then
      begin
        if AShowException then
          raise Exception.Create(
            'Process ' + vMessage + AddLBs(2) +
            'There is no access to this resource! : ' + TableName + ' ' + ClassName + sLineBreak +
            'Missing Permission Source Code for Table Name: ' + TableName);
      end;
    finally
      LErisimHakki.Free;
      LKaynak.Free;
    end;
  end
  else
    Result := True;
end;

procedure TTable.SetFieldDBPropsFromDbInfo;
var
  LCols: TSysViewColumns;
  AField: TFieldDB;
  n1, n2: Integer;
begin
  LCols := TSysViewColumns.Create(FDatabase);
  try
    LCols.SelectToList(' AND ' + LCols.OrjTableName.QryName + '=' + QuotedStr(FTableName) +
        ' ORDER BY ' + LCols.OrjTableName.FieldName + ', ' +
                       LCols.OrdinalPosition.FieldName + ' ASC ', False, False);

    for n1 := 0 to LCols.List.Count-1 do
    begin
      for n2 := 0 to Length(Fields)-1 do
      begin
        AField := Fields[n2];
        if  (TSysViewColumns(LCols.List[n1]).OrjTableName.Value = TableName)
        and (TSysViewColumns(LCols.List[n1]).OrjColumnName.Value = AField.FieldName)
        then
        begin
          AField.Size := 0;
          if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'bigint') then
            AField.DataType := ftLargeint
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'integer')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'smallint')
          then
            AField.DataType := ftInteger
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'boolean') then
            AField.DataType := ftBoolean
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'bytea') then
            //AField.DataType := ftBlob
          else
          if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'character')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'character varying')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'text')
          then
          begin
            AField.DataType := ftString;
            AField.Size := TSysViewColumns(LCols.List[n1]).CharacterMaximumLength.Value;
          end
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'double precision') then
            AField.DataType := ftFloat
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'numeric') then
            AField.DataType := ftBCD
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'date') then
            AField.DataType := ftDate
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'timestamp without time zone') then
            AField.DataType := ftDateTime;

          AField.IsNullable := TSysViewColumns(LCols.List[n1]).IsNullable.Value;
          break;
        end;
      end;
    end;
  finally
    FreeAndNil(LCols);
  end;
end;

procedure TTable.PrepareTableClassFromQuery(AQuery: TZQuery);
var
  n1: Integer;
begin
  for n1 := 0 to Length(Fields)-1 do
    setFieldValue(Fields[n1], AQuery);
end;

procedure TTable.PrepareTableRequiredValues;
var
  n1: Integer;
  n2: Integer;
begin
  for n1 := 0 to GSysTableInfo.List.Count-1 do
  begin
    if VarToStr(TSysViewColumns(GSysTableInfo.List[n1]).OrjTableName.Value) = FTableName then
      for n2 := 0 to Length(Fields)-1 do
      begin
        if VarToStr(TSysViewColumns(GSysTableInfo.List[n1]).OrjColumnName.Value) = FFields[n2].FieldName then
          FFields[n2].FIsNullable := TSysViewColumns(GSysTableInfo.List[n1]).IsNullable.Value;
          FFields[n2].FSize := TSysViewColumns(GSysTableInfo.List[n1]).CharacterMaximumLength.Value;
      end;
  end;
end;

procedure TTable.PrepareInsertQueryParams(AQuery: TZQuery);
var
  n1: Integer;
begin
  for n1 := 0 to Length(Fields)-1 do
    if Fields[n1].FieldName <> 'id' then
      if AQuery.Params.FindParam(Fields[n1].FieldName) <> nil then
        NewParamForQuery(AQuery, Fields[n1]);
end;

procedure TTable.PrepareUpdateQueryParams(AQuery: TZQuery);
var
  n1: Integer;
begin
  for n1 := 0 to Length(Fields)-1 do
    if AQuery.Params.FindParam(Fields[n1].FieldName) <> nil then
      NewParamForQuery(AQuery, Fields[n1]);
end;

procedure TTable.CloneClassContent(ASrc, ADes: TTable);
var
  n1, n2: Integer;
begin
  for n1 := 0 to Length(ASrc.Fields)-1 do
    for n2 := 0 to Length(ADes.Fields)-1 do
      if ASrc.Fields[n1].FFieldName = ADes.Fields[n2].FFieldName then
      begin
        ADes.Fields[n2].FFieldName := ASrc.Fields[n1].FFieldName;
        ADes.Fields[n2].FDataType := ASrc.Fields[n1].FDataType;
        ADes.Fields[n2].FValue := ASrc.Fields[n1].FValue;
        ADes.Fields[n2].FSize := ASrc.Fields[n1].FSize;
        ADes.Fields[n2].FIsNullable := ASrc.Fields[n1].FIsNullable;
        ADes.Fields[n2].FOtherFieldName := ASrc.Fields[n1].FOtherFieldName;
        Break;
      end;
end;

end.

