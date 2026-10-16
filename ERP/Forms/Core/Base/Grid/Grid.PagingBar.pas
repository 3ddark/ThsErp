unit Grid.PagingBar;

// Liste alt çubuğundaki sayfa denetimleri: « ‹ [sayfa] / n › »  "x - y / toplam"  [sayfa boyutu]

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TGridPageEvent = procedure(APageIndex: Integer) of object;
  TGridPageSizeEvent = procedure(APageSize: Integer) of object;

  TGridPagingBar = class
  private
    FPanel: TPanel;
    FBtnFirst: TButton;
    FBtnPrev: TButton;
    FBtnNext: TButton;
    FBtnLast: TButton;
    FEdtPage: TEdit;
    FLblPageCount: TLabel;
    FLblInfo: TLabel;
    FCbbPageSize: TComboBox;
    FPageIndex: Integer;
    FPageCount: Integer;
    FOnGoToPage: TGridPageEvent;
    FOnPageSize: TGridPageSizeEvent;
    function NewButton(const ACaption: string; AOnClick: TNotifyEvent; ALeft: Integer): TButton;
    procedure BtnFirstClick(Sender: TObject);
    procedure BtnPrevClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnLastClick(Sender: TObject);
    procedure EdtPageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CbbPageSizeChange(Sender: TObject);
    procedure DoGoToPage(AIndex: Integer);
  public
    constructor Create(AParent: TWinControl);
    procedure ApplyLocalization;
    procedure Update(APageIndex, APageCount, APageSize: Integer; ATotalCount: Int64);

    property Panel: TPanel read FPanel;
    // Düğme / Enter ile seçilen sayfa (0 tabanlı, sınırlandırılmamış)
    property OnGoToPage: TGridPageEvent read FOnGoToPage write FOnGoToPage;
    property OnPageSize: TGridPageSizeEvent read FOnPageSize write FOnPageSize;
  end;

implementation

uses
  LocalizationManager, Grid.Types;

constructor TGridPagingBar.Create(AParent: TWinControl);
var
  i: Integer;
begin
  inherited Create;
  FPageCount := 1;

  FPanel := TPanel.Create(AParent);
  FPanel.Parent := AParent;
  FPanel.Align := alClient;
  FPanel.BevelOuter := bvNone;
  FPanel.ParentColor := True;
  FPanel.ShowHint := True;
  FPanel.Visible := False;

  // Hizalama sırası Left değerine göre: kontroller tek seferde hizalansın
  FPanel.DisableAlign;
  try
    FBtnFirst := NewButton(#$00AB, BtnFirstClick, 10000);
    FBtnPrev := NewButton(#$2039, BtnPrevClick, 10010);

    FEdtPage := TEdit.Create(FPanel);
    FEdtPage.Parent := FPanel;
    FEdtPage.Left := 10020;
    FEdtPage.Width := 44;
    FEdtPage.Align := alLeft;
    FEdtPage.AlignWithMargins := True;
    FEdtPage.Margins.SetBounds(4, 3, 2, 3);
    FEdtPage.NumbersOnly := True;
    FEdtPage.Alignment := taCenter;
    FEdtPage.TabStop := False;
    FEdtPage.OnKeyDown := EdtPageKeyDown;

    FLblPageCount := TLabel.Create(FPanel);
    FLblPageCount.Parent := FPanel;
    FLblPageCount.Left := 10030;
    FLblPageCount.Align := alLeft;
    FLblPageCount.AlignWithMargins := True;
    FLblPageCount.Margins.SetBounds(2, 3, 4, 3);
    FLblPageCount.Layout := tlCenter;

    FBtnNext := NewButton(#$203A, BtnNextClick, 10040);
    FBtnLast := NewButton(#$00BB, BtnLastClick, 10050);

    FLblInfo := TLabel.Create(FPanel);
    FLblInfo.Parent := FPanel;
    FLblInfo.Left := 10060;
    FLblInfo.Align := alLeft;
    FLblInfo.AlignWithMargins := True;
    FLblInfo.Margins.SetBounds(10, 3, 4, 3);
    FLblInfo.Layout := tlCenter;

    FCbbPageSize := TComboBox.Create(FPanel);
    FCbbPageSize.Parent := FPanel;
    FCbbPageSize.Align := alRight;
    FCbbPageSize.AlignWithMargins := True;
    FCbbPageSize.Margins.SetBounds(4, 3, 8, 3);
    FCbbPageSize.Style := csDropDownList;
    FCbbPageSize.Width := 70;
    FCbbPageSize.TabStop := False;
    for i := Low(GRID_PAGE_SIZES) to High(GRID_PAGE_SIZES) do
      if GRID_PAGE_SIZES[i] > 0 then
        FCbbPageSize.Items.Add(IntToStr(GRID_PAGE_SIZES[i]))
      else
        FCbbPageSize.Items.Add('All');
    FCbbPageSize.OnChange := CbbPageSizeChange;
  finally
    FPanel.EnableAlign;
  end;

  ApplyLocalization;
end;

function TGridPagingBar.NewButton(const ACaption: string; AOnClick: TNotifyEvent; ALeft: Integer): TButton;
begin
  Result := TButton.Create(FPanel);
  Result.Parent := FPanel;
  Result.Left := ALeft;
  Result.Width := 26;
  Result.Align := alLeft;
  Result.AlignWithMargins := True;
  Result.Margins.SetBounds(1, 2, 1, 2);
  Result.Caption := ACaption;
  Result.TabStop := False;
  Result.OnClick := AOnClick;
end;

procedure TGridPagingBar.ApplyLocalization;
var
  LIndex: Integer;
begin
  FBtnFirst.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageFirst, 'First page');
  FBtnPrev.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PagePrevious, 'Previous page (Ctrl+PgUp)');
  FBtnNext.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageNext, 'Next page (Ctrl+PgDn)');
  FBtnLast.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageLast, 'Last page');
  FEdtPage.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageNumber, 'Page number (Enter)');
  FCbbPageSize.Hint := TLocalizationManager.Translate(TLangKeys.TGeneral.PageSize, 'Rows per page');

  LIndex := FCbbPageSize.ItemIndex;
  FCbbPageSize.Items[FCbbPageSize.Items.Count - 1] := TLocalizationManager.Translate(TLangKeys.TGeneral.PageAll, 'All');
  FCbbPageSize.ItemIndex := LIndex;
end;

procedure TGridPagingBar.Update(APageIndex, APageCount, APageSize: Integer; ATotalCount: Int64);
var
  LFrom, LTo: Int64;
  i: Integer;
begin
  FPageIndex := APageIndex;
  FPageCount := APageCount;

  FEdtPage.Text := IntToStr(APageIndex + 1);
  FEdtPage.Enabled := APageCount > 1;
  FLblPageCount.Caption := '/ ' + IntToStr(APageCount);
  FBtnFirst.Enabled := APageIndex > 0;
  FBtnPrev.Enabled := APageIndex > 0;
  FBtnNext.Enabled := APageIndex < APageCount - 1;
  FBtnLast.Enabled := APageIndex < APageCount - 1;

  if ATotalCount = 0 then
    LFrom := 0
  else if APageSize > 0 then
    LFrom := Int64(APageIndex) * APageSize + 1
  else
    LFrom := 1;
  LTo := ATotalCount;
  if (APageSize > 0) and (Int64(APageIndex + 1) * APageSize < LTo) then
    LTo := Int64(APageIndex + 1) * APageSize;
  FLblInfo.Caption := Format(TLocalizationManager.Translate(TLangKeys.TGeneral.PageInfo, '%s - %s of %s'),
    [FormatFloat('#,##0', LFrom), FormatFloat('#,##0', LTo), FormatFloat('#,##0', ATotalCount)]);

  for i := Low(GRID_PAGE_SIZES) to High(GRID_PAGE_SIZES) do
    if GRID_PAGE_SIZES[i] = APageSize then
      FCbbPageSize.ItemIndex := i;
end;

procedure TGridPagingBar.DoGoToPage(AIndex: Integer);
begin
  if Assigned(FOnGoToPage) then
    FOnGoToPage(AIndex);
end;

procedure TGridPagingBar.BtnFirstClick(Sender: TObject);
begin
  DoGoToPage(0);
end;

procedure TGridPagingBar.BtnPrevClick(Sender: TObject);
begin
  DoGoToPage(FPageIndex - 1);
end;

procedure TGridPagingBar.BtnNextClick(Sender: TObject);
begin
  DoGoToPage(FPageIndex + 1);
end;

procedure TGridPagingBar.BtnLastClick(Sender: TObject);
begin
  DoGoToPage(FPageCount - 1);
end;

procedure TGridPagingBar.EdtPageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    DoGoToPage(StrToIntDef(FEdtPage.Text, FPageIndex + 1) - 1);
  end;
end;

procedure TGridPagingBar.CbbPageSizeChange(Sender: TObject);
begin
  if (FCbbPageSize.ItemIndex >= 0) and Assigned(FOnPageSize) then
    FOnPageSize(GRID_PAGE_SIZES[FCbbPageSize.ItemIndex]);
end;

end.
