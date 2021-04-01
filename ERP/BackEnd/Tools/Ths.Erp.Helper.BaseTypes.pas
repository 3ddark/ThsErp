unit Ths.Erp.Helper.BaseTypes;

interface

{$I ThsERP.inc}

uses
  System.SysUtils;

type
  TInputType = (itString, itInteger, itFloat, itMoney, itDate, itTime);

  function LowCase(pKey: Char): Char;
  function LowCaseTr(pKey: Char): Char;
  function UpCaseTr(pKey: Char): Char;
  function toMoneyToDouble(pVal: string; pInputType: TInputType): Double;

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
    'I': pKey := '�';
    '�': pKey := 'i';
    '�': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
  else
    pKey := LowCase(pKey);
  end;
  Result := pKey;
end;

function UpCaseTr(pKey: Char): Char;
begin
  case pKey of
    '�': pKey := 'I';
    'i': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
    '�': pKey := '�';
  else
    pKey := UpCase(pKey);
  end;
  Result := pKey;
end;

function toMoneyToDouble(pVal: string; pInputType: TInputType): Double;
begin
  Result := 0;
  if (pInputType = itMoney)
  or (pInputType = itFloat)
  then
    Result := StrToFloat(StringReplace(pVal, FormatSettings.ThousandSeparator, '', [rfReplaceAll]));
end;

end.
