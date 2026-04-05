unit FilterCriterion;

interface

uses
  System.Rtti, System.Generics.Collections;

type
  TFilterCriterion = record
  private
    FPropertyNamePath: string;
    FOperator: string;
    FValue: TValue;
  public
    class function New(const APropertyNamePath, AOperator: string; AValue: TValue): TFilterCriterion; static;

    property PropertyNamePath: string read FPropertyNamePath write FPropertyNamePath;
    property Operator: string read FOperator write FOperator;
    property Value: TValue read FValue write FValue;
  end;

  TFilterCriteria = TList<TFilterCriterion>;

implementation

class function TFilterCriterion.New(const APropertyNamePath, AOperator: string; AValue: TValue): TFilterCriterion;
begin
  Result.PropertyNamePath := APropertyNamePath;
  Result.Operator := AOperator;
  Result.Value := AValue;
end;

end.
