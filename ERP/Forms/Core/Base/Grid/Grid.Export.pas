unit Grid.Export;

// Liste dışa aktarımı: Excel (arka planda TExcelExportTask + ilerleme penceresi) ve CSV (görünen kolon sırası)

interface

uses
  System.SysUtils, System.Classes, Data.DB, Vcl.DBGrids, FireDAC.Stan.Param;

type
  TGridExport = class
  public
    // AIds: filtreye uyan kayıtlar; ATableName / AWhereClause / AParams: görünümden yeniden okunmaları için
    class procedure ToExcel(AOwner: TComponent; AConnectionParams: TStrings; AGrid: TDBGrid; AParams: TFDParams;
      const AIds: TArray<Int64>; const ATableName, AWhereClause, ASavePath: string);
    // ADataSet baştan sona okunur (kontroller kapalı), kolonlar AGrid'deki sırayla
    class procedure ToCsv(AGrid: TDBGrid; ADataSet: TDataSet; const AFileName: string);
  end;

function CsvSafe(const S: string): string;

implementation

uses
  Winapi.Windows, Winapi.ShellAPI, System.Threading, System.Generics.Collections, Vcl.Dialogs,
  LocalizationManager, ExcelExportTask, ufrmExportProgress, FormHost;

function CsvSafe(const S: string): string;
begin
  Result := StringReplace(S, '"', '""', [rfReplaceAll]);
  if (Pos(',', Result) > 0) or (Pos('"', Result) > 0) or (Pos(#13, Result) > 0) or (Pos(#10, Result) > 0) then
    Result := '"' + Result + '"';
end;

class procedure TGridExport.ToExcel(AOwner: TComponent; AConnectionParams: TStrings; AGrid: TDBGrid; AParams: TFDParams;
  const AIds: TArray<Int64>; const ATableName, AWhereClause, ASavePath: string);
var
  LStrategy: TExportStrategy;
  LTask: TExcelExportTask;
  LProgress: TfrmExportProgress;
  LColumns: TList<TExportColumnInfo>;
  LColumn: TExportColumnInfo;
  LParams: TList<TExportParamInfo>;
  LParam: TExportParamInfo;
  LSavePath: string;
  i: Integer;
begin
  if Length(AIds) <= 5000 then
    LStrategy := esSmall
  else if Length(AIds) <= 100000 then
    LStrategy := esMedium
  else
    LStrategy := esLarge;

  LColumns := TList<TExportColumnInfo>.Create;
  LParams := TList<TExportParamInfo>.Create;
  try
    for i := 0 to AGrid.Columns.Count - 1 do
      if AGrid.Columns[i].Visible and Assigned(AGrid.Columns[i].Field) then
      begin
        LColumn.FieldName := AGrid.Columns[i].FieldName;
        LColumn.Caption := AGrid.Columns[i].Title.Caption;
        LColumns.Add(LColumn);
      end;

    for i := 0 to AParams.Count - 1 do
    begin
      LParam.Name := AParams[i].Name;
      LParam.Value := AParams[i].Value;
      LParams.Add(LParam);
    end;

    LTask := TExcelExportTask.Create(AConnectionParams, AIds, LStrategy, ATableName, AWhereClause,
      LParams.ToArray, LColumns.ToArray, ASavePath);
  finally
    LParams.Free;
    LColumns.Free;
  end;

  LSavePath := ASavePath;
  LProgress := TfrmExportProgress.Create(AOwner);
  LProgress.Position := OwnerCenterPosition(AOwner);
  LProgress.Show;

  LTask.OnProgress := procedure(ACurrent, ATotal: Integer; const AStatus: string)
  begin
    if Assigned(LProgress) then
      LProgress.UpdateProgress(ACurrent, ATotal, AStatus);
  end;

  LTask.OnComplete := procedure(ASuccess: Boolean; const AErrorMsg: string)
  begin
    if Assigned(LProgress) then
      LProgress.Close;

    if ASuccess then
    begin
      if FileExists(LSavePath) then
        ShellExecute(0, 'open', PChar(LSavePath), nil, nil, SW_SHOWNORMAL);
    end
    else if AErrorMsg <> '' then
      ShowMessage(TLocalizationManager.Translate('msg.export_error', 'Export Error: ') + AErrorMsg);

    FreeAndNil(LTask);
  end;

  LProgress.OnCancel := procedure
  begin
    if Assigned(LTask) then
      LTask.Cancel;
  end;

  TTask.Run(procedure
  begin
    LTask.Execute;
  end);
end;

class procedure TGridExport.ToCsv(AGrid: TDBGrid; ADataSet: TDataSet; const AFileName: string);
var
  LLines: TStringList;
  LLine: string;
  LField: TField;
  i: Integer;
begin
  LLines := TStringList.Create;
  try
    LLine := '';
    for i := 0 to AGrid.Columns.Count - 1 do
    begin
      LLine := LLine + AGrid.Columns[i].Title.Caption;
      if i < AGrid.Columns.Count - 1 then
        LLine := LLine + ',';
    end;
    LLines.Add(LLine);

    ADataSet.DisableControls;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        LLine := '';
        for i := 0 to AGrid.Columns.Count - 1 do
        begin
          LField := ADataSet.FindField(AGrid.Columns[i].FieldName);
          if Assigned(LField) then
            LLine := LLine + CsvSafe(LField.AsString);
          if i < AGrid.Columns.Count - 1 then
            LLine := LLine + ',';
        end;
        LLines.Add(LLine);
        ADataSet.Next;
      end;
    finally
      ADataSet.EnableControls;
    end;

    LLines.SaveToFile(AFileName, TEncoding.UTF8);
  finally
    LLines.Free;
  end;
end;

end.
