unit QueryBuilder;

interface

uses
  System.SysUtils, System.Variants, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.Param;

type
  TSqlOperator = (opEqual, opNotEqual, opGreater, opLess, opGreaterOrEqual, opLessOrEqual, opLike, opILike, opIn);

  TFilterCondition = record
    FieldName: string;
    SqlOperator: TSqlOperator;
    Value: Variant;
    Logic: string; // 'AND' veya 'OR'
  end;

  TOrderByField = record
    FieldName: string;
    Direction: string; // ASC veya DESC
  end;

  TQueryBuilder = class
  private
    FTableName: string;
    FConditions: TArray<TFilterCondition>;
    FOrderBys: TArray<TOrderByField>;
    FLimit: Integer;
    FOffset: Integer;
    function SqlOperatorToString(AOp: TSqlOperator): string;
    function AddCondition(const Logic, AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
  public
    constructor Create(const ATableName: string);
    function Where(const AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
    function AndWhere(const AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
    function OrWhere(const AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
    function OrderBy(const AField: string; const ADirection: string = 'ASC'): TQueryBuilder;
    function Limit(const AValue: Integer): TQueryBuilder;
    function Offset(const AValue: Integer): TQueryBuilder;
    procedure BuildSQL(AQuery: TFDQuery);
  end;

implementation

function TQueryBuilder.SqlOperatorToString(AOp: TSqlOperator): string;
begin
  case AOp of
    opEqual:
      Result := '=';
    opNotEqual:
      Result := '<>';
    opGreater:
      Result := '>';
    opLess:
      Result := '<';
    opGreaterOrEqual:
      Result := '>=';
    opLessOrEqual:
      Result := '<=';
    opLike:
      Result := 'LIKE';
    opILike:
      Result := 'ILIKE';
    opIn:
      Result := 'IN';
  else
    raise Exception.Create('Ge�ersiz SQL operatörü');
  end;
end;

function TQueryBuilder.AddCondition(const Logic, AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
var
  cond: TFilterCondition;
begin
  cond.FieldName := AField;
  cond.SqlOperator := AOp;
  cond.Value := AValue;
  cond.Logic := Logic;
  FConditions := FConditions + [cond];
  Result := Self;
end;

function TQueryBuilder.Where(const AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
begin
  Result := AddCondition('AND', AField, AOp, AValue);
end;

function TQueryBuilder.AndWhere(const AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
begin
  Result := AddCondition('AND', AField, AOp, AValue);
end;

function TQueryBuilder.Offset(const AValue: Integer): TQueryBuilder;
begin
  FOffset := AValue;
  Result := Self;
end;

function TQueryBuilder.OrderBy(const AField, ADirection: string): TQueryBuilder;
var
  ord: TOrderByField;
begin
  ord.FieldName := AField;
  ord.Direction := ADirection;
  FOrderBys := FOrderBys + [ord];
  Result := Self;
end;

function TQueryBuilder.OrWhere(const AField: string; AOp: TSqlOperator; const AValue: Variant): TQueryBuilder;
begin
  Result := AddCondition('OR', AField, AOp, AValue);
end;

procedure TQueryBuilder.BuildSQL(AQuery: TFDQuery);
var
  SQLText: TStringBuilder;
  i, j: Integer;
  paramName: string;
  arr: TArray<Variant>;
begin
  SQLText := TStringBuilder.Create;
  try
    SQLText.Append('SELECT * FROM ').Append(FTableName);

    if Length(FConditions) > 0 then
    begin
      SQLText.Append(' WHERE ');
      for i := 0 to High(FConditions) do
      begin
        if i > 0 then
          SQLText.Append(' ').Append(FConditions[i].Logic).Append(' ');

        if FConditions[i].SqlOperator = opIn then
        begin
          // Array bekliyoruz
          if VarIsArray(FConditions[i].Value) then
          begin
            arr := FConditions[i].Value;
            SQLText.Append(FConditions[i].FieldName).Append(' IN (');
            for j := 0 to High(arr) do
            begin
              paramName := Format('p_%d_%d', [i, j]);
              if j > 0 then
                SQLText.Append(', ');
              SQLText.Append(':' + paramName);
            end;
            SQLText.Append(')');
          end
          else
            raise Exception.Create('opIn için değer bir array olmalı.');
        end
        else
        begin
          paramName := Format('p_%d', [i]);
          SQLText.Append(FConditions[i].FieldName).Append(' ').Append(SqlOperatorToString(FConditions[i].SqlOperator)).Append(' :' + paramName);
        end;
      end;
    end;

    if Length(FOrderBys) > 0 then
    begin
      SQLText.Append(' ORDER BY ');
      for i := 0 to High(FOrderBys) do
      begin
        if i > 0 then
          SQLText.Append(', ');
        SQLText.Append(FOrderBys[i].FieldName).Append(' ').Append(FOrderBys[i].Direction);
      end;
    end;

    if FLimit >= 0 then
      SQLText.Append(' LIMIT ').Append(FLimit);

    if FOffset >= 0 then
      SQLText.Append(' OFFSET ').Append(FOffset);

    // FireDAC parametrelerini doldur
    AQuery.SQL.Text := SQLText.ToString;
    AQuery.Params.Clear;

    for i := 0 to High(FConditions) do
    begin
      if FConditions[i].SqlOperator = opIn then
      begin
        arr := FConditions[i].Value;
        for j := 0 to High(arr) do
        begin
          paramName := Format('p_%d_%d', [i, j]);
          AQuery.ParamByName(paramName).Value := arr[j];
        end;
      end
      else
      begin
        paramName := Format('p_%d', [i]);
        AQuery.ParamByName(paramName).Value := FConditions[i].Value;
      end;
    end;

  finally
    SQLText.Free;
  end;
end;

constructor TQueryBuilder.Create(const ATableName: string);
begin
  FTableName := ATableName;
  SetLength(FConditions, 0);
  SetLength(FOrderBys, 0);
  FLimit := -1;
  FOffset := -1;
end;

function TQueryBuilder.Limit(const AValue: Integer): TQueryBuilder;
begin
  FLimit := AValue;
  Result := Self;
end;

end.

