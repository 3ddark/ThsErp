unit FilterCriterion;

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections,
  System.Character, LocalizationManager;

type
  TFilterCriterion = record
  private
    FFieldName : string;
    FParamName : string;
    FOperator  : string;
    FValue     : TValue;
    procedure SetOperator (const AValue: string);
    procedure SetFieldName(const AValue: string);
    procedure SetParamName(const AValue: string);
    function  GetParamName: string;
  public
    class function IsSafeOperator(const AOp: string): Boolean; static;
    class function New(const AFieldName, AOperator: string; AValue: TValue): TFilterCriterion; static;
    class function NewWithParam(const AFieldName, AOperator, AParamName: string; AValue: TValue): TFilterCriterion; static;
    property FieldName : string read FFieldName write SetFieldName;
    property ParamName : string read GetParamName write SetParamName;
    property Operator  : string read FOperator   write SetOperator;
    property Value     : TValue read FValue      write FValue;
  end;

  TFilterCriteria = TList<TFilterCriterion>;

implementation

class function TFilterCriterion.IsSafeOperator(const AOp: string): Boolean;
const
  AllowedOps: array[0..10] of string = (
    '=', '<>', '>', '<', '>=', '<=',
    'LIKE', 'ILIKE', 'NOT LIKE', 'IN', 'NOT IN');
var
  Op, CleanOp: string;
begin
  Result   := False;
  CleanOp  := UpperCase(Trim(AOp));
  for Op in AllowedOps do
    if CleanOp = Op then
      Exit(True);
end;

procedure TFilterCriterion.SetOperator(const AValue: string);
var
  CleanOp: string;
begin
  CleanOp := Trim(AValue);
  if not IsSafeOperator(CleanOp) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSecurity.InvalidOperator, [AValue]));
  FOperator := CleanOp;
end;

procedure TFilterCriterion.SetFieldName(const AValue: string);
var
  CleanPath: string;
  Ch: Char;
begin
  CleanPath := Trim(AValue);
  for Ch in CleanPath do
    if not CharInSet(Ch, ['a'..'z', 'A'..'Z', '0'..'9', '_', '.']) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSecurity.InvalidFieldName, [AValue]));
  FFieldName := CleanPath;
end;

function TFilterCriterion.GetParamName: string;
begin
  if FParamName <> '' then
    Exit(FParamName);
  Result := StringReplace(FFieldName, '.', '_', [rfReplaceAll]);
end;

procedure TFilterCriterion.SetParamName(const AValue: string);
var
  Ch: Char;
begin
  for Ch in Trim(AValue) do
    if not CharInSet(Ch, ['a'..'z', 'A'..'Z', '0'..'9', '_']) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSecurity.InvalidFieldName, [AValue]));
  FParamName := Trim(AValue);
end;

class function TFilterCriterion.New(const AFieldName, AOperator: string; AValue: TValue): TFilterCriterion;
begin
  Result.FieldName := AFieldName;
  Result.Operator  := AOperator;
  Result.Value     := AValue;
end;

class function TFilterCriterion.NewWithParam(const AFieldName, AOperator, AParamName: string; AValue: TValue): TFilterCriterion;
begin
  Result.FieldName := AFieldName;
  Result.Operator  := AOperator;
  Result.ParamName := AParamName;
  Result.Value     := AValue;
end;

end.
