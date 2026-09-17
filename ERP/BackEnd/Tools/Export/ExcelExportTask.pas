unit ExcelExportTask;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Threading,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Intf, Logger,
  Vcl.Graphics, zexmlss, zexlsx;

type
  TExportStrategy = (esSmall, esMedium, esLarge);

  TExportColumnInfo = record
    FieldName: string;
    Caption: string;
  end;

  TExportParamInfo = record
    Name: string;
    Value: Variant;
  end;

  TExportProgressEvent = reference to procedure(ACurrent, ATotal: Integer; const AStatus: string);
  TExportCompleteEvent = reference to procedure(ASuccess: Boolean; const AErrorMsg: string);

  TExcelExportTask = class
  private
    FConnParams: TStringList;
    FIds: TArray<Int64>;
    FStrategy: TExportStrategy;
    FTableName: string;
    FWhereText: string;
    FParams: TArray<TExportParamInfo>;
    FColumns: TArray<TExportColumnInfo>;
    FFilePath: string;
    FCancelled: Boolean;
    FOnProgress: TExportProgressEvent;
    FOnComplete: TExportCompleteEvent;

    procedure ReportProgress(ACurrent, ATotal: Integer; const AStatus: string);
    procedure ReportComplete(ASuccess: Boolean; const AErrorMsg: string);
    function IdArrayToStr(const AIds: TArray<Int64>): string;
    procedure BatchInsertTempIds(AConn: TFDConnection; const AIds: TArray<Int64>);
    procedure WriteDatasetToFile(Qry: TFDQuery);
  public
    constructor Create(
      ASourceConnParams: TStrings;
      const AIds: TArray<Int64>;
      AStrategy: TExportStrategy;
      const ATableName: string;
      const AWhereText: string;
      const AParams: TArray<TExportParamInfo>;
      const AColumns: TArray<TExportColumnInfo>;
      const AFilePath: string
    );
    destructor Destroy; override;

    procedure Cancel;
    procedure Execute;

    property OnProgress: TExportProgressEvent read FOnProgress write FOnProgress;
    property OnComplete: TExportCompleteEvent read FOnComplete write FOnComplete;
  end;

implementation

constructor TExcelExportTask.Create(
  ASourceConnParams: TStrings;
  const AIds: TArray<Int64>;
  AStrategy: TExportStrategy;
  const ATableName: string;
  const AWhereText: string;
  const AParams: TArray<TExportParamInfo>;
  const AColumns: TArray<TExportColumnInfo>;
  const AFilePath: string
);
begin
  inherited Create;
  FConnParams := TStringList.Create;
  FConnParams.Assign(ASourceConnParams);
  FIds := AIds;
  FStrategy := AStrategy;
  FTableName := ATableName;
  FWhereText := AWhereText;
  FParams := AParams;
  FColumns := AColumns;
  FFilePath := AFilePath;
  FCancelled := False;
end;

destructor TExcelExportTask.Destroy;
begin
  FConnParams.Free;
  inherited;
end;

procedure TExcelExportTask.Cancel;
begin
  FCancelled := True;
end;

procedure TExcelExportTask.ReportProgress(ACurrent, ATotal: Integer; const AStatus: string);
var
  Cur, Tot: Integer;
  Sta: string;
begin
  if not Assigned(FOnProgress) then Exit;
  Cur := ACurrent;
  Tot := ATotal;
  Sta := AStatus;
  TThread.Queue(nil, procedure
  begin
    if Assigned(FOnProgress) then
      FOnProgress(Cur, Tot, Sta);
  end);
end;

procedure TExcelExportTask.ReportComplete(ASuccess: Boolean; const AErrorMsg: string);
var
  Succ: Boolean;
  Err: string;
begin
  Succ := ASuccess;
  Err := AErrorMsg;
  TThread.Queue(nil, procedure
  begin
    if Assigned(FOnComplete) then
      FOnComplete(Succ, Err);
  end);
end;

function TExcelExportTask.IdArrayToStr(const AIds: TArray<Int64>): string;
var
  SB: TStringBuilder;
  i: Integer;
begin
  SB := TStringBuilder.Create;
  try
    for i := 0 to High(AIds) do
    begin
      if i > 0 then SB.Append(',');
      SB.Append(AIds[i]);
    end;
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TExcelExportTask.BatchInsertTempIds(AConn: TFDConnection; const AIds: TArray<Int64>);
var
  SB: TStringBuilder;
  i, ChunkSize, Total: Integer;
begin
  AConn.ExecSQL('CREATE TEMP TABLE IF NOT EXISTS tmp_export_ids (id bigint) ON COMMIT DROP');
  AConn.ExecSQL('TRUNCATE TABLE tmp_export_ids');

  Total := Length(AIds);
  ChunkSize := 1000;
  i := 0;

  while i < Total do
  begin
    if FCancelled then Exit;
    SB := TStringBuilder.Create;
    try
      SB.Append('INSERT INTO tmp_export_ids (id) VALUES ');
      var BatchEnd := i + ChunkSize - 1;
      if BatchEnd >= Total then BatchEnd := Total - 1;

      for var j := i to BatchEnd do
      begin
        if j > i then SB.Append(',');
        SB.Append('(').Append(AIds[j]).Append(')');
      end;

      AConn.ExecSQL(SB.ToString);
      i := BatchEnd + 1;
    finally
      SB.Free;
    end;
  end;
end;

procedure TExcelExportTask.WriteDatasetToFile(Qry: TFDQuery);
var
  Book: TZEXMLSS;
  Sheet: TZSheet;
  Row, Total: Integer;
  i: Integer;
  Field: TField;
  Ext: string;
  HeaderStyleIndex: Integer;
  Fields: TArray<TField>;
begin
  Ext := LowerCase(ExtractFileExt(FFilePath));
  if (Ext <> '.xlsx') and (Ext <> '.xls') then
    FFilePath := ChangeFileExt(FFilePath, '.xlsx');

  if Length(FColumns) = 0 then
  begin
    SetLength(FColumns, Qry.FieldCount);
    for i := 0 to Qry.FieldCount - 1 do
    begin
      FColumns[i].FieldName := Qry.Fields[i].FieldName;
      FColumns[i].Caption := Qry.Fields[i].DisplayName;
    end;
  end;

  if Length(FColumns) = 0 then Exit;

  Book := TZEXMLSS.Create(nil);
  try
    HeaderStyleIndex := Book.Styles.Add(Book.Styles.DefaultStyle, False);
    Book.Styles[HeaderStyleIndex].Font.Style := [fsBold];

    Book.Sheets.Count := 1;
    Sheet := Book.Sheets[0];
    Sheet.Title := 'Sheet1';

    Total := Qry.RecordCount;
    if Total < 0 then
      Total := 0;

    Sheet.ColCount := Length(FColumns);
    Sheet.RowCount := Total + 1;

    // Header row
    for i := 0 to High(FColumns) do
    begin
      Sheet.Cell[i, 0].AsString := FColumns[i].Caption;
      Sheet.Cell[i, 0].CellStyle := HeaderStyleIndex;
    end;

    // Cache field references for performance
    SetLength(Fields, Length(FColumns));
    for i := 0 to High(FColumns) do
      Fields[i] := Qry.FindField(FColumns[i].FieldName);

    // Data rows
    Qry.First;
    Row := 1;

    while not Qry.Eof do
    begin
      if FCancelled then Break;

      if Row >= Sheet.RowCount then
        Sheet.RowCount := Row + 1000;

      for i := 0 to High(FColumns) do
      begin
        Field := Fields[i];
        if Assigned(Field) and not Field.IsNull then
        begin
          case Field.DataType of
            ftShortint, ftSmallint, ftInteger, ftWord, ftLongWord, ftLargeint:
              begin
                Sheet.Cell[i, Row].AsDouble := Field.AsFloat;
                Sheet.Cell[i, Row].CellType := ZENumber;
              end;
            ftFloat, ftCurrency, ftBCD, ftFMTBcd:
              begin
                Sheet.Cell[i, Row].AsDouble := Field.AsFloat;
                Sheet.Cell[i, Row].CellType := ZENumber;
              end;
            ftDate, ftTime, ftDateTime, ftTimeStamp:
              begin
                Sheet.Cell[i, Row].AsDateTime := Field.AsDateTime;
                Sheet.Cell[i, Row].CellType := ZEDateTime;
              end;
            ftBoolean:
              begin
                Sheet.Cell[i, Row].AsBoolean := Field.AsBoolean;
                Sheet.Cell[i, Row].CellType := ZEBoolean;
              end;
          else
            Sheet.Cell[i, Row].AsString := Field.AsString;
            Sheet.Cell[i, Row].CellType := ZEString;
          end;
        end;
      end;

      if (Row mod 500 = 0) or (Row = Total) then
        ReportProgress(Row, Total, Format('Excel (XLSX) yazılıyor: %d / %d', [Row, Total]));

      Inc(Row);
      Qry.Next;
    end;

    Sheet.RowCount := Row;

    if not FCancelled then
    begin
      ExportXmlssToXLSX(Book, FFilePath, [], [], False);
    end;
  finally
    Book.Free;
  end;
end;

procedure TExcelExportTask.Execute;
var
  Conn: TFDConnection;
  Qry: TFDQuery;
  SelectCols: TStringBuilder;
  i: Integer;
begin
  Conn := nil;
  Qry := nil;
  try
    ReportProgress(0, 0, 'Veritabanına bağlanılıyor...');

    // Isolated FireDAC Connection for Thread Safety
    Conn := TFDConnection.Create(nil);
    Conn.Params.Assign(FConnParams);
    Conn.LoginPrompt := False;
    Conn.Open;

    if FCancelled then Exit;

    ReportProgress(0, 0, 'Sorgu hazırlanıyor...');
    Qry := TFDQuery.Create(nil);
    Qry.Connection := Conn;
    Qry.FetchOptions.Mode := fmAll;

    // Build SELECT column list from FColumns
    SelectCols := TStringBuilder.Create;
    try
      if Length(FColumns) > 0 then
      begin
        for i := 0 to High(FColumns) do
        begin
          if i > 0 then SelectCols.Append(', ');
          SelectCols.Append(FColumns[i].FieldName);
        end;
      end;

      if SelectCols.Length = 0 then
        SelectCols.Append('*');

      case FStrategy of
        esSmall:
          begin
            Qry.SQL.Text := Format('SELECT %s FROM %s WHERE id IN (%s)',
              [SelectCols.ToString, FTableName, IdArrayToStr(FIds)]);
          end;

        esMedium:
          begin
            ReportProgress(0, Length(FIds), 'Geçici tablo hazırlanıyor...');
            BatchInsertTempIds(Conn, FIds);
            if FCancelled then Exit;

            Qry.SQL.Text := Format('SELECT v.%s FROM %s v JOIN tmp_export_ids t ON t.id = v.id',
              [SelectCols.ToString.Replace(',', ', v.', [rfReplaceAll]), FTableName]);
          end;

        esLarge:
          begin
            Qry.SQL.Text := Format('SELECT %s FROM %s %s',
              [SelectCols.ToString, FTableName, FWhereText]);
            for var P in FParams do
              Qry.ParamByName(P.Name).Value := P.Value;
          end;
      end;
    finally
      SelectCols.Free;
    end;

    if FCancelled then Exit;

    ReportProgress(0, 0, 'Veriler çekiliyor...');
    Qry.Open;

    if FCancelled then Exit;

    ReportProgress(0, Qry.RecordCount, 'Excel yazılıyor...');
    WriteDatasetToFile(Qry);

    if FCancelled then
      ReportComplete(False, 'İşlem kullanıcı tarafından iptal edildi.')
    else
      ReportComplete(True, '');
  except
    on E: Exception do
    begin
      GLogger.ErrorFmt('Excel Export Task Hatası: %s', [E.Message]);
      ReportComplete(False, E.Message);
    end;
  end;

  FreeAndNil(Qry);
  if Assigned(Conn) then
  begin
    if Conn.Connected then Conn.Close;
    FreeAndNil(Conn);
  end;
end;

end.
