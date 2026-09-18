unit SharedFormTypes;

interface

uses
  System.Generics.Collections;

type
  TInputFormMode = (ifmNone, ifmNewRecord, ifmRewiev, ifmUpdate, ifmReadOnly, ifmCopyNewRecord);
  TInputFormViewMode = (ivmNormal, ivmSort);
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);

  TFormDecimalMode = (fomBuying, fomSale, fomStock, fomNormal);

  TAggregateType = (atSum, atCount, atAverage, atMin, atMax);

  TAfterCrudRefreshGrid = procedure(AFocusSelectedItem: Boolean) of object;

function AggregateTypeToInt(AAggType: TAggregateType): Integer;
function IntToAggregateType(AValue: Integer; out AAggType: TAggregateType): Boolean;
function AggregateTypeToSqlFunc(AAggType: TAggregateType): string;
function AggregateTypeToDefaultFormat(AAggType: TAggregateType): string;

implementation

function AggregateTypeToInt(AAggType: TAggregateType): Integer;
begin
  case AAggType of
    atSum:     Result := 1;
    atCount:   Result := 2;
    atAverage: Result := 3;
    atMin:     Result := 4;
    atMax:     Result := 5;
  else
    Result := 0;
  end;
end;

function IntToAggregateType(AValue: Integer; out AAggType: TAggregateType): Boolean;
begin
  Result := True;
  case AValue of
    1: AAggType := atSum;
    2: AAggType := atCount;
    3: AAggType := atAverage;
    4: AAggType := atMin;
    5: AAggType := atMax;
  else
    Result := False;
  end;
end;

function AggregateTypeToSqlFunc(AAggType: TAggregateType): string;
begin
  case AAggType of
    atSum:     Result := 'SUM';
    atCount:   Result := 'COUNT';
    atAverage: Result := 'AVG';
    atMin:     Result := 'MIN';
    atMax:     Result := 'MAX';
  else
    Result := 'SUM';
  end;
end;

function AggregateTypeToDefaultFormat(AAggType: TAggregateType): string;
begin
  case AAggType of
    atCount: Result := '#,##0';
  else
    Result := '#,##0.00';
  end;
end;

end.
