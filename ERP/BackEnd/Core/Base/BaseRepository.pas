unit BaseRepository;

interface

uses
  SysUtils, Classes, Types, System.Rtti, System.TypInfo, DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TBaseRepository = class(TObject)
  private
    FTableName: string;
  protected
    FConnection: TFDConnection;
    function NewQuery(AOwner: TComponent): TFDQuery;
  public
    constructor Create(AConnection: TFDConnection);

    property TableName: string read FTableName write FTableName;
    property Connection: TFDConnection read FConnection;

    function ExistsByField<T>(const AFieldName: string; const AValue: T): Boolean;

    procedure DeleteById(AId: Integer);
  end;

implementation

constructor TBaseRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Repository için geçerli bir bağlantı nesnesi sağlanmadı.');
  FConnection := AConnection;
end;

procedure TBaseRepository.DeleteById(AId: Integer);
var
  Q: TFDQuery;
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

function TBaseRepository.NewQuery(AOwner: TComponent): TFDQuery;
begin
  Result := TFDQuery.Create(AOwner);
  Result.Connection := FConnection;
end;

function TBaseRepository.ExistsByField<T>(const AFieldName: string; const AValue: T): Boolean;
var
  Q: TFDQuery;
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

