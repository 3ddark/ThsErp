unit BaseRepository;

interface

uses
  SysUtils, Classes, Types, System.Rtti, System.TypInfo, System.Generics.Collections,
  DB, FireDAC.Comp.Client, FireDAC.Stan.Param, BaseEntity, TableNameService;

type
  IBaseRepository<T> = interface
    ['{41099611-B2E2-4851-865D-F5417081E31F}']

    function CreateQueryForUI(const AFilterKey: string): string;
    function Find(AFilter: string; ALock: Boolean): TList<T>;
    function FindById(AId: Integer; ALock: Boolean): T;
    procedure Save(AEntity: T);
    procedure Delete(AId: Integer);
  end;

  TBaseRepository<T> = class(TInterfacedObject, IBaseRepository<T>)
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
    procedure Delete(AId: Integer); virtual; abstract;

    function ExistsByField(const AFieldName: string; const AValue: T): Boolean;
    procedure DeleteById(AId: Integer; ATableName: string);
  end;

implementation

constructor TBaseRepository<T>.Create(AConnection: TFDConnection);
begin
  inherited Create;
  if not Assigned(AConnection) then
    raise Exception.Create('Repository için geçerli bir bağlantı nesnesi sağlanmadı.');
  FConnection := AConnection;
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

