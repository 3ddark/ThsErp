unit ufrmSysGridFilter;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridFilter.Service, SysGridFilter,
  SysViewTable.Service, SysViewTable, ufrmSysViewTables,
  SysGridColumnHelper;

type
  TfrmSysGridFilter = class(TfrmInputSimpleDB<TSysGridFilter, TSysGridFilterService>)
    pnlContent: TPanel;
    lblTableName: TLabel;
    lblColumnName: TLabel;
    lblOperator: TLabel;
    lblValue: TLabel;
    lblConjunction: TLabel;
    lblFilterList: TLabel;
    lblFilterContent: TLabel;
    edtTableName: TEdit;
    cbbColumnName: TComboBox;
    cbbOperator: TComboBox;
    chkNot: TCheckBox;
    edtValue: TEdit;
    cbbConjunction: TComboBox;
    btnAddFilter: TButton;
    btnDeleteFilter: TButton;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    btnClearFilter: TButton;
    lbxFilterList: TListBox;
    mmoFilterContent: TMemo;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure edtTableNameExit(Sender: TObject);
    procedure cbbOperatorChange(Sender: TObject);
    procedure btnAddFilterClick(Sender: TObject);
    procedure btnDeleteFilterClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnClearFilterClick(Sender: TObject);
  public
    procedure HelperProcess(Sender: TObject);
    procedure PopulateColumnList(const ATableName: string);
    procedure BuildFilterContentFromList;
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysGridFilter.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtTableName.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysGridFilter.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtTableName.SetFocus;
end;

procedure TfrmSysGridFilter.ApplyLocalization;
var
  LPrevIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.TitleSingular, 'Grid Filter');
  lblTableName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColTableName, 'Table Name');
  lblColumnName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColColumnName, 'Column Name');
  lblOperator.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.LblOperator, 'Operator');
  lblValue.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.LblValue, 'Value');
  lblConjunction.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.LblConjunction, 'Conjunction');
  chkNot.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ChkNot, 'NOT');
  lblFilterList.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.LblFilterList, 'Filter List');
  lblFilterContent.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.ColFilterContent, 'Filter Content');

  btnAddFilter.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.BtnAdd, '+ Add');
  btnDeleteFilter.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.BtnDelete, '- Delete');
  btnMoveUp.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.BtnMoveUp, 'Move Up');
  btnMoveDown.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.BtnMoveDown, 'Move Down');
  btnClearFilter.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridFilter.BtnClear, 'Clear');

  LPrevIndex := cbbOperator.ItemIndex;
  cbbOperator.Items.BeginUpdate;
  try
    cbbOperator.Items.Clear;
    cbbOperator.Items.Add('= (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpEqual, 'Equal') + ')');
    cbbOperator.Items.Add('<> (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpNotEqual, 'Not Equal') + ')');
    cbbOperator.Items.Add('> (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpGreater, 'Greater Than') + ')');
    cbbOperator.Items.Add('>= (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpGreaterEqual, 'Greater or Equal') + ')');
    cbbOperator.Items.Add('< (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpLess, 'Less Than') + ')');
    cbbOperator.Items.Add('<= (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpLessEqual, 'Less or Equal') + ')');
    cbbOperator.Items.Add('LIKE (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpLike, 'Contains') + ')');
    cbbOperator.Items.Add('NOT LIKE (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpNotLike, 'Not Contains') + ')');
    cbbOperator.Items.Add('STARTS WITH (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpStartsWith, 'Starts With') + ')');
    cbbOperator.Items.Add('ENDS WITH (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpEndsWith, 'Ends With') + ')');
    cbbOperator.Items.Add('IS NULL (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpIsNull, 'Is Null') + ')');
    cbbOperator.Items.Add('IS NOT NULL (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpIsNotNull, 'Is Not Null') + ')');
    cbbOperator.Items.Add('IN (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpIn, 'In') + ')');
    cbbOperator.Items.Add('NOT IN (' + TLocalizationManager.Translate(TLangKeys.TSysGridFilter.OpNotIn, 'Not In') + ')');
  finally
    cbbOperator.Items.EndUpdate;
  end;
  if (LPrevIndex >= 0) and (LPrevIndex < cbbOperator.Items.Count) then
    cbbOperator.ItemIndex := LPrevIndex
  else
    cbbOperator.ItemIndex := 0;

  LPrevIndex := cbbConjunction.ItemIndex;
  cbbConjunction.Items.BeginUpdate;
  try
    cbbConjunction.Items.Clear;
    cbbConjunction.Items.Add('AND');
    cbbConjunction.Items.Add('OR');
  finally
    cbbConjunction.Items.EndUpdate;
  end;
  if (LPrevIndex >= 0) and (LPrevIndex < cbbConjunction.Items.Count) then
    cbbConjunction.ItemIndex := LPrevIndex
  else
    cbbConjunction.ItemIndex := 0;
end;

procedure TfrmSysGridFilter.InitializeInputCase;
begin
  inherited;
  edtTableName.thsInputDataType := itString;
  edtTableName.MaxLength := 128;
  mmoFilterContent.thsInputDataType := itString;
end;

procedure TfrmSysGridFilter.PopulateColumnList(const ATableName: string);
var
  LCols: TArray<string>;
  LCol: string;
begin
  cbbColumnName.Items.BeginUpdate;
  try
    cbbColumnName.Items.Clear;
    if (Trim(ATableName) <> '') and Assigned(Service) and Assigned(Service.UoW) and (Service.UoW.Connection <> nil) then
    begin
      LCols := TGridColumnHelper.GetTableColumnNames(Service.UoW.Connection, ATableName);
      for LCol in LCols do
        cbbColumnName.Items.Add(LCol);
    end;
  finally
    cbbColumnName.Items.EndUpdate;
  end;

  if cbbColumnName.Items.Count > 0 then
    cbbColumnName.ItemIndex := 0;
end;

procedure TfrmSysGridFilter.HelperProcess(Sender: TObject);
var
  LFrmViewTables: TfrmSysViewTables;
begin
  if Sender = edtTableName then
  begin
    LFrmViewTables := TfrmSysViewTables.Create(edtTableName, TSysViewTableService.Create, TSysViewTable.Create);
    try
      LFrmViewTables.IsHelper := True;
      LFrmViewTables.ShowModal;
      if LFrmViewTables.DataTransfer then
      begin
        if LFrmViewTables.CleanAndClose then
        begin
          Table.TableName := '';
          edtTableName.Clear;
          PopulateColumnList('');
        end
        else
        begin
          Table.TableName := LFrmViewTables.Table.TableName;
          edtTableName.Text := LFrmViewTables.Table.TableName;
          PopulateColumnList(LFrmViewTables.Table.TableName);
        end;
      end;
    finally
      LFrmViewTables.Free;
    end;
  end;
end;

procedure TfrmSysGridFilter.edtTableNameExit(Sender: TObject);
begin
  if Trim(edtTableName.Text) <> '' then
    PopulateColumnList(edtTableName.Text);
end;

procedure TfrmSysGridFilter.cbbOperatorChange(Sender: TObject);
var
  LText: string;
begin
  LText := UpperCase(cbbOperator.Text);
  if (Pos('IS NULL', LText) > 0) or (Pos('IS NOT NULL', LText) > 0) then
  begin
    edtValue.Enabled := False;
    edtValue.Text := '';
  end
  else
  begin
    edtValue.Enabled := True;
  end;
end;

procedure TfrmSysGridFilter.btnAddFilterClick(Sender: TObject);
var
  LColName, LOpText, LOp, LVal, LCond, LConj, LItemText: string;
  LParenPos: Integer;
begin
  LColName := Trim(cbbColumnName.Text);
  if LColName = '' then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysGridFilter.WarnSelectColumn, 'Please select a column.'));
    cbbColumnName.SetFocus;
    Exit;
  end;

  if not TGridColumnHelper.IsValidIdentifier(LColName) then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysGridFilter.WarnInvalidColumn, [LColName], 'Invalid column name: %s'));
    Exit;
  end;

  LOpText := Trim(cbbOperator.Text);
  LParenPos := Pos('(', LOpText);
  if LParenPos > 0 then
    LOp := Trim(Copy(LOpText, 1, LParenPos - 1))
  else
    LOp := LOpText;

  LVal := Trim(edtValue.Text);
  if (Pos('NULL', UpperCase(LOp)) = 0) and (LVal = '') then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysGridFilter.WarnEnterValue, 'Please enter a filter value.'));
    edtValue.SetFocus;
    Exit;
  end;

  try
    LCond := TGridColumnHelper.FormatFilterCondition(LColName, LOp, LVal, chkNot.Checked);
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.Message);
      Exit;
    end;
  end;

  if lbxFilterList.Items.Count > 0 then
  begin
    if cbbConjunction.ItemIndex = 1 then
      LConj := 'OR'
    else
      LConj := 'AND';
    LItemText := LConj + ' ' + LCond;
  end
  else
  begin
    LItemText := LCond;
  end;

  lbxFilterList.Items.Add(LItemText);
  BuildFilterContentFromList;
  edtValue.Clear;
end;

procedure TfrmSysGridFilter.btnDeleteFilterClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := lbxFilterList.ItemIndex;
  if LIdx >= 0 then
  begin
    lbxFilterList.Items.Delete(LIdx);
    if LIdx < lbxFilterList.Items.Count then
      lbxFilterList.ItemIndex := LIdx
    else if lbxFilterList.Items.Count > 0 then
      lbxFilterList.ItemIndex := lbxFilterList.Items.Count - 1;
    BuildFilterContentFromList;
  end;
end;

procedure TfrmSysGridFilter.btnMoveUpClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := lbxFilterList.ItemIndex;
  if LIdx > 0 then
  begin
    lbxFilterList.Items.Exchange(LIdx, LIdx - 1);
    lbxFilterList.ItemIndex := LIdx - 1;
    BuildFilterContentFromList;
  end;
end;

procedure TfrmSysGridFilter.btnMoveDownClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := lbxFilterList.ItemIndex;
  if (LIdx >= 0) and (LIdx < lbxFilterList.Items.Count - 1) then
  begin
    lbxFilterList.Items.Exchange(LIdx, LIdx + 1);
    lbxFilterList.ItemIndex := LIdx + 1;
    BuildFilterContentFromList;
  end;
end;

procedure TfrmSysGridFilter.btnClearFilterClick(Sender: TObject);
begin
  lbxFilterList.Items.Clear;
  mmoFilterContent.Clear;
end;

procedure TfrmSysGridFilter.BuildFilterContentFromList;
var
  LSB: TStringBuilder;
  i: Integer;
  LLine: string;
begin
  LSB := TStringBuilder.Create;
  try
    for i := 0 to lbxFilterList.Items.Count - 1 do
    begin
      LLine := Trim(lbxFilterList.Items[i]);
      if LLine = '' then Continue;

      if i = 0 then
      begin
        // First item should not start with AND or OR
        if StartsText('AND ', LLine) then
          LLine := Trim(Copy(LLine, 5, MaxInt))
        else if StartsText('OR ', LLine) then
          LLine := Trim(Copy(LLine, 4, MaxInt));
        lbxFilterList.Items[i] := LLine;
        LSB.Append(LLine);
      end
      else
      begin
        // Subsequent items must start with AND or OR
        if not (StartsText('AND ', LLine) or StartsText('OR ', LLine)) then
          LLine := 'AND ' + LLine;
        lbxFilterList.Items[i] := LLine;
        LSB.Append(' ' + LLine);
      end;
    end;
    mmoFilterContent.Text := LSB.ToString;
  finally
    LSB.Free;
  end;
end;

procedure TfrmSysGridFilter.RefreshData;
var
  LRaw: string;
  LTokens: TArray<string>;
  LToken: string;
begin
  inherited;
  edtTableName.Text := Table.TableName;
  PopulateColumnList(Table.TableName);
  mmoFilterContent.Text := Table.FilterContent;

  lbxFilterList.Items.BeginUpdate;
  try
    lbxFilterList.Items.Clear;
    LRaw := Trim(Table.FilterContent);
    if StartsText('WHERE ', LRaw) then
      LRaw := Trim(Copy(LRaw, 7, MaxInt));

    if LRaw <> '' then
    begin
      if Pos(#10, LRaw) > 0 then
      begin
        LTokens := LRaw.Split([#13, #10], TStringSplitOptions.ExcludeEmpty);
        for LToken in LTokens do
        begin
          if Trim(LToken) <> '' then
            lbxFilterList.Items.Add(Trim(LToken));
        end;
      end
      else
      begin
        lbxFilterList.Items.Add(LRaw);
      end;
    end;
  finally
    lbxFilterList.Items.EndUpdate;
  end;
end;

procedure TfrmSysGridFilter.BtnAcceptClick(Sender: TObject);
var
  LFilterStr: string;
begin
  LFilterStr := Trim(mmoFilterContent.Text);

  // SQL Injection Validation
  if not TGridColumnHelper.ValidateFilterClause(LFilterStr) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSysGridFilter.SecInvalidFilter, 'Security Warning: Invalid filter expression detected (SQL Injection protection).'));

  Table.TableName := Trim(edtTableName.Text);
  Table.FilterContent := LFilterStr;
  inherited;
end;

end.
