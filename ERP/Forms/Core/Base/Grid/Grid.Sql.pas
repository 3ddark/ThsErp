unit Grid.Sql;

// Liste sorgusu için SQL / filtre ifadesi üreten saf yardımcılar (form ve veritabanı bağımsız)

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, Data.DB, Vcl.DBGrids;

// LIKE desenindeki joker karakterler (\ % _) kullanıcı metninde düz karakter sayılır
function LikeEscape(const S: string): string;
// ACond boşsa ASql aynen; WHERE varsa AND, yoksa WHERE ile eklenir
function AddWhereCondition(const ASql, ACond: string): string;
// SQL değişmezi (popup "Filtrele"): tarih ISO, ondalık nokta, metin tırnaklı; desteklenmeyen tip boş
function SqlLiteral(AField: TField): string;
// Popup Filtrele / Hariç tut koşulu. APaged: SQL (tırnaklı kolon, ISO değer, zaman damgası saniyeye yuvarlanır),
// değilse istemci tarafı TDataSet.Filter ifadesi. Desteklenmeyen tip / NULL değer boş döner
function FieldFilterExpression(AField: TField; const AOperator: string; APaged: Boolean): string;
// Sorgunun sondaki (parantez dengesi tutan) ORDER BY'ı ayrılır
procedure SplitOrderBy(const ASql: string; out ABody, AOrderBy: string);
// Başlık sıralaması ('alan:A;alan:D') + taban sıralama; sayfalar arası kayma olmasın diye sonda her zaman id
function SortFieldsToOrderBy(const ASortFields, ABaseOrderBy: string): string;
// Başlık tıklaması: AMulti (Ctrl) ise alan listeye eklenir / yönü değişir, değilse tek alan (aynı alansa yön değişir)
function ToggleSortFields(const ACurrent, AFieldName: string; AMulti: Boolean): string;
// Sunucu tarafı hızlı filtre: görünen kolonlarda; metin her yerde (ILIKE + Türkçe büyük / küçük harf parametreleri
// :pg_s / :pg_su / :pg_sl), sayı / tarih / mantıksal eşitlik. Aranabilir kolon yoksa '1 = 0'
function BuildSearchSql(AColumns: TDBGridColumns; const AText: string): string;
// İstemci tarafı hızlı filtre (TDataSet.Filter): id dışındaki tüm kolonlar
function BuildClientSearchFilter(AColumns: TDBGridColumns; const AText: string): string;
// 'SELECT … FROM şema.vw_x …' -> 'vw_x'
function ExtractViewName(const ASql: string): string;

implementation

uses
  Ths.Globals;

function LikeEscape(const S: string): string;
begin
  Result := StringReplace(S, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '%', '\%', [rfReplaceAll]);
  Result := StringReplace(Result, '_', '\_', [rfReplaceAll]);
end;

function AddWhereCondition(const ASql, ACond: string): string;
begin
  Result := ASql;
  if ACond = '' then
    Exit;
  if Pos('WHERE', UpperCase(Result)) > 0 then
    Result := Result + ' AND ' + ACond
  else
    Result := Result + ' WHERE ' + ACond;
end;

function SqlLiteral(AField: TField): string;
begin
  Result := '';
  case AField.DataType of
    ftString, ftWideString, ftMemo, ftWideMemo, ftFmtMemo, ftFixedChar, ftFixedWideChar, ftGuid:
      Result := QuotedStr(AField.AsString);
    ftSmallint, ftInteger, ftWord, ftLargeint, ftAutoInc, ftLongWord, ftShortint, ftByte:
      Result := AField.AsString;
    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
      Result := FloatToStr(AField.AsFloat, TFormatSettings.Invariant);
    ftBoolean:
      Result := IfThen(AField.AsBoolean, 'true', 'false');
    ftDate:
      Result := 'DATE ' + QuotedStr(FormatDateTime('yyyy-mm-dd', AField.AsDateTime));
    ftTime:
      Result := 'TIME ' + QuotedStr(FormatDateTime('hh:nn:ss', AField.AsDateTime));
    ftDateTime, ftTimeStamp, ftOraTimeStamp:
      Result := 'TIMESTAMP ' + QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', AField.AsDateTime));
  end;
end;

function FieldFilterExpression(AField: TField; const AOperator: string; APaged: Boolean): string;
var
  LValue: string;
begin
  Result := '';
  if (AField = nil) or AField.IsNull then
    Exit;

  if APaged then
  begin
    LValue := SqlLiteral(AField);
    if LValue = '' then
      Exit;
    // zaman damgası DB'de mikro saniyeli, ekrandaki değer saniyeli: saniyeye yuvarlanarak karşılaştırılır
    if AField.DataType in [ftDateTime, ftTimeStamp, ftOraTimeStamp] then
      Result := 'date_trunc(''second'', ' + AnsiQuotedStr(AField.FieldName, '"') + ')' + AOperator + LValue
    else
      Result := AnsiQuotedStr(AField.FieldName, '"') + AOperator + LValue;
    Exit;
  end;

  case AField.DataType of
    ftString, ftWideString, ftMemo, ftFmtMemo, ftWideMemo, ftDate, ftTime, ftDateTime, ftOraTimeStamp:
      Result := AField.FieldName + AOperator + QuotedStr(AField.AsString);
    ftSmallint, ftInteger, ftWord, ftBoolean, ftFloat, ftCurrency, ftBCD, ftBytes, ftVarBytes, ftAutoInc, ftBlob,
    ftGraphic, ftFixedChar, ftLargeint, ftArray, ftTimeStamp, ftFMTBcd, ftFixedWideChar, ftLongWord, ftShortint,
    ftByte, ftExtended, ftSingle:
      Result := AField.FieldName + AOperator + AField.AsString;
  end;
end;

procedure SplitOrderBy(const ASql: string; out ABody, AOrderBy: string);
var
  LSql, LTail: string;
  LPos, LDepth, i: Integer;
begin
  LSql := TrimRight(ASql);
  AOrderBy := '';
  LPos := UpperCase(LSql).LastIndexOf('ORDER BY');
  if LPos >= 0 then
  begin
    LTail := LSql.Substring(LPos + Length('ORDER BY'));
    // parantez dengesi bozuksa ORDER BY bir alt sorguya / pencere fonksiyonuna aittir
    LDepth := 0;
    for i := 1 to Length(LTail) do
      if LTail[i] = '(' then
        Inc(LDepth)
      else if LTail[i] = ')' then
        Dec(LDepth);
    if LDepth = 0 then
    begin
      AOrderBy := Trim(LTail);
      LSql := TrimRight(LSql.Substring(0, LPos));
    end;
  end;
  ABody := LSql;
end;

function SortFieldsToOrderBy(const ASortFields, ABaseOrderBy: string): string;
var
  LList: TStringList;
  LName, LDir, LLower: string;
  i: Integer;
begin
  Result := '';
  if ASortFields <> '' then
  begin
    LList := TStringList.Create;
    try
      LList.Delimiter := ';';
      LList.StrictDelimiter := True;
      LList.DelimitedText := ASortFields;
      for i := 0 to LList.Count - 1 do
      begin
        LName := LList[i];
        LDir := 'ASC';
        if EndsText(':D', LName) then
          LDir := 'DESC';
        if (Length(LName) > 2) and (LName[Length(LName) - 1] = ':') then
          SetLength(LName, Length(LName) - 2);
        if LName = '' then
          Continue;
        if Result <> '' then
          Result := Result + ', ';
        Result := Result + AnsiQuotedStr(LName, '"') + ' ' + LDir;
      end;
    finally
      LList.Free;
    end;
  end;

  if ABaseOrderBy <> '' then
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + ABaseOrderBy;
  end;

  // Aynı değerli satırlar sayfalar arasında kaymasın / tekrar etmesin
  LLower := LowerCase(Trim(Result));
  if Result = '' then
    Result := 'id'
  else if not (EndsText(' id', ' ' + LLower) or EndsText(' id asc', ' ' + LLower) or EndsText(' id desc', ' ' + LLower)) then
    Result := Result + ', id';
end;

function ToggleSortFields(const ACurrent, AFieldName: string; AMulti: Boolean): string;
var
  LList: TStringList;
  LAsc, LDesc: string;
  i, LIndex: Integer;
begin
  LAsc := AFieldName + ':A';
  LDesc := AFieldName + ':D';
  LList := TStringList.Create;
  try
    LList.Delimiter := ';';
    LList.StrictDelimiter := True;
    if ACurrent <> '' then
      LList.DelimitedText := ACurrent;

    LIndex := -1;
    for i := 0 to LList.Count - 1 do
      if (LList[i] = LAsc) or (LList[i] = LDesc) then
      begin
        LIndex := i;
        Break;
      end;

    if AMulti then
    begin
      // Ctrl: listede varsa yönü değişir, yoksa artan olarak sona eklenir
      if LIndex >= 0 then
        LList[LIndex] := IfThen(LList[LIndex] = LAsc, LDesc, LAsc)
      else
        LList.Add(LAsc);
    end
    else
    begin
      // tek alan: aynı alana tekrar tıklanınca yön değişir
      if (LIndex >= 0) and (LList[LIndex] = LAsc) then
        LAsc := LDesc;
      LList.Clear;
      LList.Add(LAsc);
    end;

    Result := string.Join(';', LList.ToStringArray);
  finally
    LList.Free;
  end;
end;

function BuildSearchSql(AColumns: TDBGridColumns; const AText: string): string;
var
  i: Integer;
  LCol: TColumn;
  LField: TField;
  LName: string;
  LFloat: Double;
  LDate: TDateTime;
  LIsNumber, LIsDate, LIsBool: Boolean;
  LParts: TStringList;
begin
  Result := '';
  if AText = '' then
    Exit;

  LIsNumber := TryStrToFloat(AText, LFloat);
  LIsDate := TryStrToDate(AText, LDate);
  LIsBool := SameText(AText, 'TRUE') or SameText(AText, 'FALSE');

  LParts := TStringList.Create;
  try
    for i := 0 to AColumns.Count - 1 do
    begin
      LCol := AColumns[i];
      LField := LCol.Field;
      if not LCol.Visible or not Assigned(LField) or SameText(LCol.FieldName, 'id') then
        Continue;
      LName := AnsiQuotedStr(LCol.FieldName, '"');
      case LField.DataType of
        ftString, ftWideString, ftMemo, ftWideMemo, ftFixedChar, ftFixedWideChar:
          LParts.Add(Format('(%0:s ILIKE :pg_s OR %0:s LIKE :pg_su OR %0:s LIKE :pg_sl)', [LName]));
        ftSmallint, ftInteger, ftWord, ftLargeint, ftLongWord, ftShortint, ftByte,
        ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftExtended, ftSingle:
          if LIsNumber then
            LParts.Add(LName + ' = ' + FloatToStr(LFloat, TFormatSettings.Invariant));
        ftBoolean:
          if LIsBool then
            LParts.Add(LName + ' = ' + LowerCase(AText));
        ftDate, ftDateTime, ftTimeStamp:
          if LIsDate then
            LParts.Add(Format('CAST(%s AS date) = DATE %s', [LName, QuotedStr(FormatDateTime('yyyy-mm-dd', LDate))]));
      end;
    end;

    // aranabilir kolon yoksa hiçbir kayıt eşleşmez
    if LParts.Count = 0 then
      Result := '1 = 0'
    else
      Result := string.Join(' OR ', LParts.ToStringArray);
  finally
    LParts.Free;
  end;
end;

function BuildClientSearchFilter(AColumns: TDBGridColumns; const AText: string): string;
var
  i, LInt: Integer;
  LFloat: Double;
  LDate: TDateTime;
  LIsNumber, LIsBool, LIsDate: Boolean;
  LCol: TColumn;

  procedure AddPart(const APart: string);
  begin
    if Result <> '' then
      Result := Result + ' OR ';
    Result := Result + APart;
  end;

begin
  Result := '';
  if AText = '' then
    Exit;

  LIsNumber := TryStrToInt(AText, LInt) or TryStrToFloat(AText, LFloat);
  LIsBool := SameText(AText, 'TRUE') or SameText(AText, 'FALSE');
  LIsDate := TryStrToDate(AText, LDate) or TryStrToTime(AText, LDate) or TryStrToDateTime(AText, LDate);

  for i := 0 to AColumns.Count - 1 do
  begin
    LCol := AColumns[i];
    if (LCol.FieldName = 'id') or not Assigned(LCol.Field) then
      Continue;
    case LCol.Field.DataType of
      ftString, ftWideString, ftMemo, ftWideMemo:
        AddPart(LCol.FieldName + ' LIKE ' + QuotedStr('%' + Ths.Globals.UpperCaseTr(AText) + '%') +
          ' OR ' + LCol.FieldName + ' LIKE ' + QuotedStr('%' + Ths.Globals.LowerCaseTr(AText) + '%'));
      ftWord, ftLongWord, ftByte, ftShortint, ftSmallint, ftInteger, ftLargeint, ftFloat, ftCurrency, ftBCD, ftSingle:
        if LIsNumber then
          AddPart(LCol.FieldName + ' = ' + StringReplace(AText, ',', '.', [rfReplaceAll]));
      ftBoolean:
        if LIsBool then
          AddPart(LCol.FieldName + ' = ' + UpperCase(AText));
      ftDate, ftTime, ftDateTime:
        if LIsDate then
          AddPart(LCol.FieldName + ' = ' + QuotedStr(AText));
    end;
  end;
end;

function ExtractViewName(const ASql: string): string;
var
  LUpper: string;
  LFromPos, LEndPos, LDotPos: Integer;
begin
  Result := '';
  LUpper := UpperCase(ASql);
  LFromPos := Pos(' FROM ', LUpper);
  if LFromPos = 0 then
    Exit;
  Inc(LFromPos, 6);

  LEndPos := LFromPos;
  while LEndPos <= Length(ASql) do
  begin
    if CharInSet(ASql[LEndPos], [' ', #9, #13, #10]) then
      Break;
    Inc(LEndPos);
  end;

  Result := LowerCase(Trim(Copy(ASql, LFromPos, LEndPos - LFromPos)));
  LDotPos := LastDelimiter('.', Result);
  if LDotPos > 0 then
    Result := Copy(Result, LDotPos + 1, MaxInt);
end;

end.
