unit ufrmSysGridSort;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, System.StrUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  SysGridSort.Service, SysGridSort,
  SysViewTable.Service, SysViewTable, ufrmSysViewTables,
  SysGridColumnHelper;

type
  TfrmSysGridSort = class(TfrmInputSimpleDB<TSysGridSort, TSysGridSortService>)
    pnlContent: TPanel;
    lblTableName: TLabel;
    lblColumnName: TLabel;
    lblSortDirection: TLabel;
    lblSortList: TLabel;
    lblSortContent: TLabel;
    edtTableName: TEdit;
    cbbColumnName: TComboBox;
    cbbSortDirection: TComboBox;
    btnAddSort: TButton;
    btnDeleteSort: TButton;
    btnMoveUp: TButton;
    btnMoveDown: TButton;
    btnClearSort: TButton;
    lbxSortList: TListBox;
    edtSortContent: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure edtTableNameExit(Sender: TObject);
    procedure btnAddSortClick(Sender: TObject);
    procedure btnDeleteSortClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnClearSortClick(Sender: TObject);
  public
    procedure HelperProcess(Sender: TObject);
    procedure PopulateColumnList(const ATableName: string);
    procedure BuildSortContentFromList;
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysGridSort.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtTableName.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysGridSort.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtTableName.SetFocus;
end;

procedure TfrmSysGridSort.ApplyLocalization;
var
  LPrevIndex: Integer;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.TitleSingular, 'Grid Sort');
  lblTableName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColTableName, 'Table Name');
  lblColumnName.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColColumnName, 'Column Name');
  lblSortDirection.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.LblSortDirection, 'Direction');
  lblSortList.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.LblSortList, 'Sort List');
  lblSortContent.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.ColSortContent, 'Sort Content');

  btnAddSort.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.BtnAdd, '+ Add');
  btnDeleteSort.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.BtnDelete, '- Delete');
  btnMoveUp.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.BtnMoveUp, 'Move Up');
  btnMoveDown.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.BtnMoveDown, 'Move Down');
  btnClearSort.Caption := TLocalizationManager.Translate(TLangKeys.TSysGridSort.BtnClear, 'Clear');

  LPrevIndex := cbbSortDirection.ItemIndex;
  cbbSortDirection.Items.BeginUpdate;
  try
    cbbSortDirection.Items.Clear;
    cbbSortDirection.Items.Add('ASC (' + TLocalizationManager.Translate(TLangKeys.TSysGridSort.SortAsc, 'Ascending') + ')');
    cbbSortDirection.Items.Add('DESC (' + TLocalizationManager.Translate(TLangKeys.TSysGridSort.SortDesc, 'Descending') + ')');
  finally
    cbbSortDirection.Items.EndUpdate;
  end;
  if (LPrevIndex >= 0) and (LPrevIndex < cbbSortDirection.Items.Count) then
    cbbSortDirection.ItemIndex := LPrevIndex
  else
    cbbSortDirection.ItemIndex := 0;
end;

procedure TfrmSysGridSort.InitializeInputCase;
begin
  inherited;
  edtTableName.thsInputDataType := itString;
  edtTableName.MaxLength := 128;
  edtSortContent.thsInputDataType := itString;
end;

procedure TfrmSysGridSort.PopulateColumnList(const ATableName: string);
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

procedure TfrmSysGridSort.HelperProcess(Sender: TObject);
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

procedure TfrmSysGridSort.edtTableNameExit(Sender: TObject);
begin
  if Trim(edtTableName.Text) <> '' then
    PopulateColumnList(edtTableName.Text);
end;

procedure TfrmSysGridSort.btnAddSortClick(Sender: TObject);
var
  LColName, LDir, LItemText, LPrefix: string;
  i: Integer;
begin
  LColName := Trim(cbbColumnName.Text);
  if LColName = '' then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysGridSort.WarnSelectColumn, 'Please select a column.'));
    cbbColumnName.SetFocus;
    Exit;
  end;

  if not TGridColumnHelper.IsValidIdentifier(LColName) then
  begin
    ShowMessage(TLocalizationManager.Translate(TLangKeys.TSysGridSort.WarnInvalidColumn, [LColName], 'Invalid column name: %s'));
    Exit;
  end;

  if cbbSortDirection.ItemIndex = 1 then
    LDir := 'DESC'
  else
    LDir := 'ASC';

  LItemText := LColName + ' ' + LDir;
  LPrefix := UpperCase(LColName) + ' ';

  // If this column is already in the list update direction, otherwise append
  for i := 0 to lbxSortList.Items.Count - 1 do
  begin
    if StartsText(LPrefix, UpperCase(lbxSortList.Items[i]) + ' ') then
    begin
      lbxSortList.Items[i] := LItemText;
      BuildSortContentFromList;
      Exit;
    end;
  end;

  lbxSortList.Items.Add(LItemText);
  BuildSortContentFromList;
end;

procedure TfrmSysGridSort.btnDeleteSortClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := lbxSortList.ItemIndex;
  if LIdx >= 0 then
  begin
    lbxSortList.Items.Delete(LIdx);
    if LIdx < lbxSortList.Items.Count then
      lbxSortList.ItemIndex := LIdx
    else if lbxSortList.Items.Count > 0 then
      lbxSortList.ItemIndex := lbxSortList.Items.Count - 1;
    BuildSortContentFromList;
  end;
end;

procedure TfrmSysGridSort.btnMoveUpClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := lbxSortList.ItemIndex;
  if LIdx > 0 then
  begin
    lbxSortList.Items.Exchange(LIdx, LIdx - 1);
    lbxSortList.ItemIndex := LIdx - 1;
    BuildSortContentFromList;
  end;
end;

procedure TfrmSysGridSort.btnMoveDownClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := lbxSortList.ItemIndex;
  if (LIdx >= 0) and (LIdx < lbxSortList.Items.Count - 1) then
  begin
    lbxSortList.Items.Exchange(LIdx, LIdx + 1);
    lbxSortList.ItemIndex := LIdx + 1;
    BuildSortContentFromList;
  end;
end;

procedure TfrmSysGridSort.btnClearSortClick(Sender: TObject);
begin
  lbxSortList.Items.Clear;
  edtSortContent.Clear;
end;

procedure TfrmSysGridSort.BuildSortContentFromList;
var
  LParts: TStringList;
  i: Integer;
begin
  LParts := TStringList.Create;
  try
    for i := 0 to lbxSortList.Items.Count - 1 do
    begin
      if Trim(lbxSortList.Items[i]) <> '' then
        LParts.Add(Trim(lbxSortList.Items[i]));
    end;
    LParts.Delimiter := ',';
    LParts.StrictDelimiter := True;
    edtSortContent.Text := string.Join(', ', LParts.ToStringArray);
  finally
    LParts.Free;
  end;
end;

procedure TfrmSysGridSort.RefreshData;
var
  LRawSort: string;
  LTokens: TArray<string>;
  LToken: string;
begin
  inherited;
  edtTableName.Text := Table.TableName;
  PopulateColumnList(Table.TableName);

  edtSortContent.Text := Table.SortContent;

  lbxSortList.Items.BeginUpdate;
  try
    lbxSortList.Items.Clear;
    LRawSort := Trim(Table.SortContent);
    if StartsText('ORDER BY ', LRawSort) then
      LRawSort := Trim(Copy(LRawSort, 10, MaxInt));

    if LRawSort <> '' then
    begin
      LTokens := LRawSort.Split([',']);
      for LToken in LTokens do
      begin
        if Trim(LToken) <> '' then
          lbxSortList.Items.Add(Trim(LToken));
      end;
    end;
  finally
    lbxSortList.Items.EndUpdate;
  end;
end;

procedure TfrmSysGridSort.BtnAcceptClick(Sender: TObject);
var
  LSortStr: string;
begin
  LSortStr := Trim(edtSortContent.Text);

  // SQL Injection Validation
  if not TGridColumnHelper.ValidateSortClause(LSortStr) then
    raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TSysGridSort.SecInvalidSort, 'Security Warning: Invalid sort expression detected (SQL Injection protection).'));

  Table.TableName := Trim(edtTableName.Text);
  Table.SortContent := LSortStr;
  inherited;
end;

end.
