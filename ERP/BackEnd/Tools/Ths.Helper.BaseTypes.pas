unit Ths.Helper.BaseTypes;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Character;

type
  TInputType = (itString, itInteger, itFloat, itMoney, itDate, itTime);

  function LowCase(pKey: Char): Char;
  function LowCaseTr(pKey: Char): Char;
  function UpCaseTr(pKey: Char): Char;
  // Türkçe kurallarla büyük harf (i -> İ, ı -> I; diğer harfler Unicode)
  function UpperCaseTr(const AValue: string): string;
  function moneyToDouble(pVal: string; pInputType: TInputType): Double;

implementation

function LowCase(pKey: Char): Char;
begin
  //Result := Char(Word(pKey) or $0020);
  Result := pKey;
  if CharInSet(Result, ['A'..'Z']) then
    Inc(Result, Ord('a')-Ord('A'));
end;

function LowCaseTr(pKey: Char): Char;
begin
  case pKey of
    'I': pKey := Char('ı');
    'İ': pKey := 'i';
    'Ğ': pKey := 'ğ';
    'Ü': pKey := 'ü';
    'Ş': pKey := 'ş';
    'Ç': pKey := 'ç';
  else
    pKey := pKey.ToLower;
  end;
  Result := pKey;
end;

function UpCaseTr(pKey: Char): Char;
begin
  case pKey of
    'ı': pKey := 'I';
    'i': pKey := 'İ';
    'ğ': pKey := 'Ğ';
    'ü': pKey := 'Ü';
    'ş': pKey := 'Ş';
    'ç': pKey := 'Ç';
  else
    pKey := pKey.ToUpper;
  end;
  Result := pKey;
end;

function UpperCaseTr(const AValue: string): string;
var
  i: Integer;
begin
  Result := AValue;
  for i := 1 to Length(Result) do
    Result[i] := UpCaseTr(Result[i]);
end;

function moneyToDouble(pVal: string; pInputType: TInputType): Double;
begin
  Result := 0;
  if (pInputType = itMoney)
  or (pInputType = itFloat)
  then
    Result := StrToFloat(StringReplace(pVal, FormatSettings.ThousandSeparator, '', [rfReplaceAll]));
end;

end.
