unit Grid.ColumnSelector;

// Liste popup "Kolonlar": aranabilir onay listesiyle kolon görünürlüğü (kodla kurulan pencere, DFM yok)

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.CheckLst, Vcl.DBGrids;

type
  TfrmColumnSelector = class(TForm)
  private
    FEditSearch: TEdit;
    FCheckListBox: TCheckListBox;
    FColumns: TList<TColumn>;
    FCheckedStates: TDictionary<TColumn, Boolean>;
    procedure EditSearchChange(Sender: TObject);
    procedure CheckListBoxClickCheck(Sender: TObject);
    procedure RebuildList;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  public
    constructor Create(AOwner: TComponent; AColumns: TList<TColumn>); reintroduce;
    destructor Destroy; override;
    function GetCheckedState(AColumn: TColumn): Boolean;
    // Onaylanırsa kolon görünürlükleri uygulanır; sonuç: değişiklik onaylandı mı
    class function Execute(AOwner: TComponent; AGrid: TDBGrid): Boolean;
  end;

implementation

uses
  LocalizationManager, Ths.Globals, FormHost;

constructor TfrmColumnSelector.Create(AOwner: TComponent; AColumns: TList<TColumn>);
var
  LPanelButtons: TPanel;
  LBtnOk, LBtnCancel: TButton;
  LCol: TColumn;
begin
  inherited CreateNew(AOwner);

  Self.OnKeyPress := FormKeyPress;

  FColumns := AColumns;
  FCheckedStates := TDictionary<TColumn, Boolean>.Create;
  for LCol in FColumns do
    FCheckedStates.Add(LCol, LCol.Visible);

  KeyPreview := True;
  Caption := TLocalizationManager.Translate('column_selector.title', 'Column Selection');
  Position := OwnerCenterPosition(AOwner);
  Width := 450;
  Height := 500;
  BorderStyle := bsSizeable;

  FEditSearch := TEdit.Create(Self);
  FEditSearch.Parent := Self;
  FEditSearch.Align := alTop;
  FEditSearch.Height := 24;
  FEditSearch.Margins.SetBounds(8, 8, 8, 8);
  FEditSearch.AlignWithMargins := True;
  FEditSearch.TextHint := TLocalizationManager.Translate('column_selector.search_hint', 'Search Column...');
  FEditSearch.OnChange := EditSearchChange;

  LPanelButtons := TPanel.Create(Self);
  LPanelButtons.Parent := Self;
  LPanelButtons.Align := alBottom;
  LPanelButtons.Height := 40;
  LPanelButtons.BevelOuter := bvNone;

  LBtnCancel := TButton.Create(Self);
  LBtnCancel.Parent := LPanelButtons;
  LBtnCancel.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Cancel, 'Cancel');
  LBtnCancel.ModalResult := mrCancel;
  LBtnCancel.Left := Self.ClientWidth - LBtnCancel.Width - 12;
  LBtnCancel.Top := 8;
  LBtnCancel.Anchors := [akRight, akBottom];

  LBtnOk := TButton.Create(Self);
  LBtnOk.Parent := LPanelButtons;
  LBtnOk.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'OK');
  LBtnOk.ModalResult := mrOk;
  LBtnOk.Default := True;
  LBtnOk.Left := LBtnCancel.Left - LBtnOk.Width - 8;
  LBtnOk.Top := 8;
  LBtnOk.Anchors := [akRight, akBottom];

  FCheckListBox := TCheckListBox.Create(Self);
  FCheckListBox.Parent := Self;
  FCheckListBox.Align := alClient;
  FCheckListBox.Margins.SetBounds(8, 0, 8, 0);
  FCheckListBox.AlignWithMargins := True;
  FCheckListBox.OnClickCheck := CheckListBoxClickCheck;

  RebuildList;
end;

destructor TfrmColumnSelector.Destroy;
begin
  FCheckedStates.Free;
  inherited;
end;

class function TfrmColumnSelector.Execute(AOwner: TComponent; AGrid: TDBGrid): Boolean;
var
  LColumns: TList<TColumn>;
  LSelector: TfrmColumnSelector;
  LCol: TColumn;
  i: Integer;
begin
  LColumns := TList<TColumn>.Create;
  try
    for i := 0 to AGrid.Columns.Count - 1 do
      LColumns.Add(AGrid.Columns[i]);

    LSelector := TfrmColumnSelector.Create(AOwner, LColumns);
    try
      Result := LSelector.ShowModal = mrOk;
      if Result then
        for LCol in LColumns do
          LCol.Visible := LSelector.GetCheckedState(LCol);
    finally
      LSelector.Free;
    end;
  finally
    LColumns.Free;
  end;
end;

procedure TfrmColumnSelector.EditSearchChange(Sender: TObject);
begin
  RebuildList;
end;

procedure TfrmColumnSelector.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Key := #0;
    Self.Close;
  end;
end;

procedure TfrmColumnSelector.CheckListBoxClickCheck(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FCheckListBox.Items.Count - 1 do
    FCheckedStates[TColumn(FCheckListBox.Items.Objects[i])] := FCheckListBox.Checked[i];
end;

function TfrmColumnSelector.GetCheckedState(AColumn: TColumn): Boolean;
begin
  Result := FCheckedStates[AColumn];
end;

procedure TfrmColumnSelector.RebuildList;
var
  LCol: TColumn;
  LSearchText, LText: string;
  LIndex: Integer;
begin
  FCheckListBox.Items.BeginUpdate;
  try
    FCheckListBox.Items.Clear;
    LSearchText := Trim(FEditSearch.Text);
    for LCol in FColumns do
    begin
      LText := LCol.Title.Caption;
      if LText = '' then
        LText := LCol.FieldName;
      if (LSearchText = '') or (Pos(LowerCaseTr(LSearchText), LowerCaseTr(LText)) > 0) then
      begin
        LIndex := FCheckListBox.Items.AddObject(LText, LCol);
        FCheckListBox.Checked[LIndex] := FCheckedStates[LCol];
      end;
    end;
  finally
    FCheckListBox.Items.EndUpdate;
  end;
end;

end.
