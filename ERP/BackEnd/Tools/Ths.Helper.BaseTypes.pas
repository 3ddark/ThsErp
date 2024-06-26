﻿unit Ths.Helper.BaseTypes;

interface

{$I Ths.inc}

uses
  System.SysUtils;

type
  TInputType = (itString, itInteger, itFloat, itMoney, itDate, itTime);

  function LowCase(pKey: Char): Char;
  function LowCaseTr(pKey: Char): Char;
  function UpCaseTr(pKey: Char): Char;
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
    pKey := LowCase(pKey);
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
    pKey := UpCase(pKey);
  end;
  Result := pKey;
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
