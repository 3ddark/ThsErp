unit Grid.Paging;

// Sunucu tarafı sayfalama durumu ve SQL'i: taban gövde (ORDER BY'sız) + hızlı filtre (:qc*) + arama (:pg_s*) +
// popup filtre satırları, başlık sıralaması + taban sıralama + id, LIMIT / OFFSET, kayıt sayısı + alt toplamlar

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, Grid.Types, Grid.Footer;

type
  TGridPager = class
  private
    FEnabled: Boolean;
    FReady: Boolean;
    FPageSize: Integer;          // 0 = tümü
    FPageIndex: Integer;         // 0 tabanlı
    FTotalCount: Int64;
    FBaseSql: string;            // ORDER BY olmadan (sabit + dinamik filtreler dahil)
    FBaseOrderBy: string;
    FBaseParams: TFDParams;
    FSortFields: string;         // başlık sıralaması: 'alan:A;alan:D'
    FSearchText: string;
    FSearchSql: string;          // hızlı arama koşulu (FSearchText parametreleriyle)
    FQuickSql: string;           // hızlı filtre koşulu (:qc0, :qc1 …)
    FQuickParams: TArray<Variant>;
    FFilterLines: TStringList;   // popup filtre satırları (ilki hariç ' AND ' önekli)
    procedure SetPageIndex(AValue: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    // FormShow'da (sabit + dinamik filtreler eklendikten sonra) gövde ve parametreler saklanır
    procedure Capture(AQry: TFDQuery);
    procedure SetSearch(const AText, ASql: string);
    procedure SetQuickCondition(const ASql: string; const AParams: array of Variant);
    // AExpression boşsa eklenmez
    procedure AddFilter(const AExpression: string);

    function IsPaged: Boolean;
    function PageCount: Integer;
    // Sorgu gövdesi + tüm çalışma anı koşulları (sıralama / LIMIT yok)
    function FilteredSql: string;
    function OrderBy: string;
    function PageSql: string;
    // İstemci tarafı mod: gövde + hızlı filtre + taban sıralama
    function ClientSql: string;
    procedure ApplyParams(AQuery: TFDQuery);
    function CreateQuery(AConnection: TFDCustomConnection; const ASql: string): TFDQuery;
    // Kayıt sayısı + alt toplamlar tek sorguda (AFooter nil olabilir; ADataSet: hangi kolonlar var)
    procedure LoadTotals(AConnection: TFDCustomConnection; ADataSet: TDataSet; AFooter: TGridFooter);
    // Kaydın filtreli / sıralı listedeki sayfası (0 tabanlı); bulunamazsa -1
    function FindPageOfId(AConnection: TFDCustomConnection; AId: Int64): Integer;
    // Ekrandaki ilk kayıt korunarak sayfa boyutu değişir
    procedure ChangePageSize(AValue: Integer);

    property Enabled: Boolean read FEnabled write FEnabled;
    property Ready: Boolean read FReady;
    property PageSize: Integer read FPageSize write FPageSize;
    property PageIndex: Integer read FPageIndex write SetPageIndex;
    property TotalCount: Int64 read FTotalCount;
    property SortFields: string read FSortFields write FSortFields;
    property SearchText: string read FSearchText;
    property QuickSql: string read FQuickSql;
    property FilterLines: TStringList read FFilterLines;
  end;

// Liste sayfa boyutu kullanıcı başına tek ayar (sys_user_setting 'grid.page_size'; 0 = tümü)
function GridPageSize: Integer;
procedure SetGridPageSize(AValue: Integer);

var
  GGridPageSize: Integer = -1;   // -1: henüz okunmadı

implementation

uses
  System.Variants, System.StrUtils, System.Generics.Collections, Logger, Ths.Globals, Grid.Sql, SysUserSetting.Service;

function GridPageSize: Integer;
var
  LService: TSysUserSettingService;
  LValues: TDictionary<string, string>;
  LText: string;
  LValue, i: Integer;
begin
  if GGridPageSize < 0 then
  begin
    GGridPageSize := GRID_DEFAULT_PAGE_SIZE;
    try
      LService := TSysUserSettingService.Create;
      try
        LValues := LService.GetValues(GRID_PAGE_SIZE_KEY);
        try
          if LValues.TryGetValue(GRID_PAGE_SIZE_KEY, LText) and TryStrToInt(LText, LValue) then
            for i := Low(GRID_PAGE_SIZES) to High(GRID_PAGE_SIZES) do
              if GRID_PAGE_SIZES[i] = LValue then
                GGridPageSize := LValue;
        finally
          LValues.Free;
        end;
      finally
        LService.Free;
      end;
    except
      on E: Exception do
        GLogger.WarningFmt('Sayfa boyutu okunamadı: %s', [E.Message]);
    end;
  end;
  Result := GGridPageSize;
end;

procedure SetGridPageSize(AValue: Integer);
var
  LService: TSysUserSettingService;
begin
  if AValue = GGridPageSize then
    Exit;
  GGridPageSize := AValue;
  try
    LService := TSysUserSettingService.Create;
    try
      LService.SetValue(GRID_PAGE_SIZE_KEY, IntToStr(AValue));
    finally
      LService.Free;
    end;
  except
    on E: Exception do
      GLogger.WarningFmt('Sayfa boyutu kaydedilemedi: %s', [E.Message]);
  end;
end;

{ TGridPager }

constructor TGridPager.Create;
begin
  inherited Create;
  FEnabled := True;
  FFilterLines := TStringList.Create;
end;

destructor TGridPager.Destroy;
begin
  FFilterLines.Free;
  FBaseParams.Free;
  inherited;
end;

procedure TGridPager.SetPageIndex(AValue: Integer);
begin
  if AValue < 0 then
    AValue := 0;
  FPageIndex := AValue;
end;

procedure TGridPager.Capture(AQry: TFDQuery);
begin
  SplitOrderBy(AQry.SQL.Text, FBaseSql, FBaseOrderBy);
  FreeAndNil(FBaseParams);
  FBaseParams := TFDParams.Create;
  FBaseParams.Assign(AQry.Params);
  FReady := True;
end;

procedure TGridPager.SetSearch(const AText, ASql: string);
begin
  FSearchText := AText;
  FSearchSql := ASql;
end;

procedure TGridPager.SetQuickCondition(const ASql: string; const AParams: array of Variant);
var
  i: Integer;
begin
  FQuickSql := Trim(ASql);
  SetLength(FQuickParams, Length(AParams));
  for i := 0 to High(AParams) do
    FQuickParams[i] := AParams[i];
end;

procedure TGridPager.AddFilter(const AExpression: string);
begin
  if AExpression = '' then
    Exit;
  if FFilterLines.Count > 0 then
    FFilterLines.Add(' AND ' + AExpression)
  else
    FFilterLines.Add(AExpression);
end;

function TGridPager.IsPaged: Boolean;
begin
  Result := FEnabled and FReady;
end;

function TGridPager.PageCount: Integer;
begin
  if (FPageSize <= 0) or (FTotalCount <= 0) then
    Result := 1
  else
    Result := Integer((FTotalCount + FPageSize - 1) div FPageSize);
end;

function TGridPager.FilteredSql: string;
var
  LCond: string;

  procedure AddCond(const ACond: string);
  begin
    if LCond <> '' then
      LCond := LCond + ' AND ';
    LCond := LCond + '(' + ACond + ')';
  end;

begin
  LCond := '';
  if FQuickSql <> '' then
    AddCond(FQuickSql);
  if FSearchSql <> '' then
    AddCond(FSearchSql);
  if FFilterLines.Count > 0 then
    AddCond(Trim(FFilterLines.Text));
  Result := AddWhereCondition(FBaseSql, LCond);
end;

function TGridPager.OrderBy: string;
begin
  Result := SortFieldsToOrderBy(FSortFields, FBaseOrderBy);
end;

function TGridPager.PageSql: string;
begin
  Result := FilteredSql + ' ORDER BY ' + OrderBy;
  if FPageSize > 0 then
    Result := Result + Format(' LIMIT %d OFFSET %d', [FPageSize, Int64(FPageIndex) * FPageSize]);
end;

function TGridPager.ClientSql: string;
begin
  Result := FBaseSql;
  if FQuickSql <> '' then
    Result := AddWhereCondition(Result, '(' + FQuickSql + ')');
  if FBaseOrderBy <> '' then
    Result := Result + ' ORDER BY ' + FBaseOrderBy;
end;

procedure TGridPager.ApplyParams(AQuery: TFDQuery);
var
  i: Integer;
  LParam: TFDParam;
begin
  if Assigned(FBaseParams) then
    for i := 0 to FBaseParams.Count - 1 do
    begin
      LParam := AQuery.Params.FindParam(FBaseParams[i].Name);
      if Assigned(LParam) then
      begin
        LParam.DataType := FBaseParams[i].DataType;
        LParam.Value := FBaseParams[i].Value;
      end;
    end;

  LParam := AQuery.Params.FindParam('pg_s');
  if Assigned(LParam) then
    LParam.AsWideString := '%' + LikeEscape(FSearchText) + '%';
  LParam := AQuery.Params.FindParam('pg_su');
  if Assigned(LParam) then
    LParam.AsWideString := '%' + LikeEscape(Ths.Globals.UpperCaseTr(FSearchText)) + '%';
  LParam := AQuery.Params.FindParam('pg_sl');
  if Assigned(LParam) then
    LParam.AsWideString := '%' + LikeEscape(Ths.Globals.LowerCaseTr(FSearchText)) + '%';

  for i := 0 to High(FQuickParams) do
  begin
    LParam := AQuery.Params.FindParam('qc' + IntToStr(i));
    if Assigned(LParam) then
      LParam.Value := FQuickParams[i];
  end;
end;

function TGridPager.CreateQuery(AConnection: TFDCustomConnection; const ASql: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := AConnection;
    Result.SQL.Text := ASql;
    ApplyParams(Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TGridPager.LoadTotals(AConnection: TFDCustomConnection; ADataSet: TDataSet; AFooter: TGridFooter);
var
  LSelect: string;
  LQ: TFDQuery;
begin
  LSelect := 'count(*) AS pg_total';
  if Assigned(AFooter) then
    LSelect := LSelect + AFooter.AggregateSelectList(ADataSet);

  LQ := CreateQuery(AConnection, 'SELECT ' + LSelect + ' FROM (' + FilteredSql + ') pg_t');
  try
    LQ.Open;
    FTotalCount := LQ.FieldByName('pg_total').AsLargeInt;
    if Assigned(AFooter) then
      AFooter.AssignServerValues(LQ);
  finally
    LQ.Free;
  end;
end;

function TGridPager.FindPageOfId(AConnection: TFDCustomConnection; AId: Int64): Integer;
var
  LSql: string;
  LQ: TFDQuery;
begin
  Result := -1;
  if (FPageSize <= 0) or (AId <= 0) then
    Exit;

  LSql := TrimLeft(FilteredSql);
  if not StartsText('SELECT ', LSql) or StartsText('SELECT DISTINCT', LSql) then
    Exit;
  LSql := 'SELECT row_number() OVER (ORDER BY ' + OrderBy + ') AS pg_rn, ' + LSql.Substring(Length('SELECT '));

  LQ := CreateQuery(AConnection, 'SELECT pg_r.pg_rn FROM (' + LSql + ') pg_r WHERE pg_r.id = ' + IntToStr(AId));
  try
    LQ.Open;
    if not LQ.IsEmpty then
      Result := (LQ.Fields[0].AsLargeInt - 1) div FPageSize;
  finally
    LQ.Free;
  end;
end;

procedure TGridPager.ChangePageSize(AValue: Integer);
var
  LFirstRow: Int64;
begin
  if AValue < 0 then
    AValue := 0;
  if AValue = FPageSize then
    Exit;
  LFirstRow := Int64(FPageIndex) * FPageSize;
  FPageSize := AValue;
  if FPageSize > 0 then
    FPageIndex := Integer(LFirstRow div FPageSize)
  else
    FPageIndex := 0;
end;

end.
