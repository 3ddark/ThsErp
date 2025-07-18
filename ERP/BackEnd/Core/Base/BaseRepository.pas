unit BaseRepository;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Rtti, DB, ZConnection, ZDataset;

type
  TBaseRepository = class(TObject)
  private
    FTableName: string;
  protected
    FConnection: TZConnection;
    function NewQuery(AOwner: TComponent): TZQuery;
  public
    constructor Create(AConnection: TZConnection);

    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;

    property TableName: string read FTableName write FTableName;
    property Connection: TZConnection read FConnection;

    function ExistsByField<T>(const AFieldName: string; const AValue: T): Boolean;

    procedure DeleteById(AId: Integer);
  end;

implementation

constructor TBaseRepository.Create(AConnection: TZConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Repository için geçerli bir baðlantý nesnesi saðlanmadý.');
  FConnection := AConnection;
end;

procedure TBaseRepository.DeleteById(AId: Integer);
var
  Q: TZQuery;
begin
  Q := NewQuery(nil);
  try
    Q.SQL.Text := Format('DELETE FROM %s WHERE id = :p_id', [TableName]);
    Q.ParamByName('p_id').AsInteger := AId;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TBaseRepository.NewQuery(AOwner: TComponent): TZQuery;
begin
  Result := TZQuery.Create(AOwner);
  Result.Connection := FConnection;
end;

procedure TBaseRepository.BeginTransaction;
begin
  Self.Connection.StartTransaction;
end;

procedure TBaseRepository.CommitTransaction;
begin
  Self.Connection.Commit;
end;

procedure TBaseRepository.RollbackTransaction;
begin
  Self.Connection.Rollback;
end;

function TBaseRepository.ExistsByField<T>(const AFieldName: string; const AValue: T): Boolean;
var
  Q: TZQuery;
  V: TValue;
begin
  Q := NewQuery(nil);
  try
    Q.SQL.Text := Format('SELECT EXISTS(SELECT id FROM %s WHERE %s = :p_value);', [TableName, AFieldName]);

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

