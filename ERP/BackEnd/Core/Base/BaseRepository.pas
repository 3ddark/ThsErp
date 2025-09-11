unit BaseRepository;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.StrUtils,
  System.Rtti, System.TypInfo, System.Generics.Collections, DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, TableNameService;

type
  IBaseRepository<T> = interface
    ['{41099611-B2E2-4851-865D-F5417081E31F}']
  end;

  TBaseRepository<T: TEntity> = class(TInterfacedObject, IBaseRepository<T>)
  protected
    FConnection: TFDConnection;
    function NewQuery(AOwner: TComponent): TFDQuery;
  public
    constructor Create(AConnection: TFDConnection);

    property Connection: TFDConnection read FConnection;

    function CreateQueryForUI(const AFilterKey: string): string; virtual; abstract;
    function Find(AFilter: string; ALock: Boolean): TList<T>; virtual; abstract;
    function FindById(AId: Integer; ALock: Boolean): T; virtual; abstract;
    procedure Save(AEntity: T); virtual; abstract;

    function ExistsByField(const AFieldName: string; const AValue: T): Boolean;
    procedure DeleteById(AId: Integer; ATableName: string);

    procedure Add(AModel: T); virtual;
    procedure AddBatch(AModels: TArray<T>);

    procedure Update(AModel: T); virtual;
    procedure UpdateBatch(AModels: TArray<T>);

    procedure Delete(AId: Int64); overload; virtual;
    procedure Delete(AModel: T); overload; virtual;
    procedure DeleteBatch(AModels: TArray<T>); overload;
    procedure DeleteBatch(AIDs: TArray<Int64>); overload;
    procedure DeleteBatch(AFilter: string = ''); overload;
  end;

implementation

procedure TBaseRepository<T>.Add(AModel: T);
var
  Q: TFDQuery;
  LTableName, LFieldNames, LParams: string;
  n1: Integer;
begin
  if AModel.Fields.Count = 0 then
    Exit;

  if AModel.Id.Value > 0 then
    Exit;

  Q := NewQuery(nil);
  try
    LTableName := TTableNameService.TableName(AModel.ClassType);

    LFieldNames := '';
    LParams := '';
    for n1 := 0 to AModel.Fields.Count-1 do
    begin
      LFieldNames := LFieldNames + AModel.Fields[n1].FieldName + ',';
      LParams := LParams + ':' + AModel.Fields[n1].AsString + ',';
    end;

    LFieldNames := Trim(LFieldNames);
    LFieldNames := LeftStr(LFieldNames, Length(LFieldNames)-1);

    LParams := Trim(LParams);
    LParams := LeftStr(LParams, Length(LParams)-1);

    Q.SQL.Text := Format('INSERT INTO %s (' + LFieldNames + ') VALUES (' + LParams + ') RETURNING %s',[
      LTableName,
      AModel.Id.FieldName
    ]);
    Q.ParamByName(AEntity.Family.AsParamName).AsString := AEntity.Family.Value;
    Q.ParamByName(AEntity.Description.AsParamName).AsString := AEntity.Description.Value;
    Q.ParamByName(AEntity.Active.AsParamName).AsBoolean := AEntity.Active.Value;
    Q.Open;
    AEntity.Id.ValueFirstSet(Q.FieldByName('id').AsInteger);
  finally
    Q.Free;
  end;
end;

procedure TBaseRepository<T>.AddBatch(AModels: TArray<T>);
var
  AModel: T;
begin
  for AModel in AModels do
    Self.Save(AModel);
end;

constructor TBaseRepository<T>.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Repository için geçerli bir bağlantı nesnesi sağlanmadı.');
  FConnection := AConnection;
end;

procedure TBaseRepository<T>.Delete(AModel: T);
begin
  inherited;
end;

procedure TBaseRepository<T>.Delete(AId: Int64);
begin
  inherited;
end;

procedure TBaseRepository<T>.DeleteBatch(AFilter: string);
begin
  inherited;
end;

procedure TBaseRepository<T>.DeleteBatch(AIDs: TArray<Int64>);
begin

end;

procedure TBaseRepository<T>.DeleteBatch(AModels: TArray<T>);
begin

end;

procedure TBaseRepository<T>.DeleteById(AId: Integer; ATableName: string);
var
  Q: TFDQuery;
begin
  Q := NewQuery(nil);
  try
    Q.SQL.Text := Format('DELETE FROM %s WHERE id = :%s', [ATableName, 'p_id']);
    Q.ParamByName('p_id').AsInteger := AId;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TBaseRepository<T>.NewQuery(AOwner: TComponent): TFDQuery;
begin
  Result := TFDQuery.Create(AOwner);
  Result.Connection := FConnection;
end;

procedure TBaseRepository<T>.Update(AModel: T);
begin
  //
end;

procedure TBaseRepository<T>.UpdateBatch(AModels: TArray<T>);
begin

end;

function TBaseRepository<T>.ExistsByField(const AFieldName: string; const AValue: T): Boolean;
var
  Q: TFDQuery;
  V: TValue;
begin
  Q := NewQuery(nil);
  try
    Q.SQL.Text := Format('SELECT EXISTS(SELECT id FROM %s WHERE %s = :p_value);', ['', AFieldName]);

    V := TValue.From<T>(AValue);

    case V.Kind of
      tkUString, tkString, tkWString:
        Q.ParamByName('p_value').AsString := V.AsString;
      tkInteger, tkInt64:
        Q.ParamByName('p_value').AsInteger := V.AsInteger;
      tkFloat:
        begin
          if V.TypeInfo = TypeInfo(TDateTime) then
            Q.ParamByName('p_value').AsDateTime := V.AsExtended
          else
            Q.ParamByName('p_value').AsFloat := V.AsExtended;
        end;
    else
        raise Exception.Create('Unsupported field type in ExistsByField');
    end;

    Q.Open;
    Result := Q.Fields[0].AsBoolean;
  finally
    Q.Free;
  end;
end;

end.

