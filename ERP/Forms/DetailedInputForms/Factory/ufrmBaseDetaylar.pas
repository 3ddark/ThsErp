unit ufrmBaseDetaylar;

interface

{$I Ths.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Variants,
  System.Math,
  System.Rtti,
  System.UITypes,
  System.Actions,
  System.Win.ComObj,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  Vcl.Grids,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.AppEvnts,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.ActnList,
  Data.DB,
  Data.FmtBcd,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  Ths.Helper.StringGrid,
  udm,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Constants,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.TableDetailed,
  Ths.Database.Table.View.SysViewColumns;

type
  TfrmBaseDetaylar = class(TfrmBaseInputDB)
    splLeft: TSplitter;
    splHeader: TSplitter;
    pnlHeader: TPanel;
    pnlContent: TPanel;
    pnlLeft: TPanel;
    pgcContent: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    strngrd3: TStringGrid;
    pm1: TPopupMenu;
    pnl1: TPanel;
    grpGenelToplamKalan: TGroupBox;
    grpGenelToplam: TGroupBox;
    flwpnl1: TFlowPanel;
    pnl2: TPanel;
    flwpnl2: TFlowPanel;
    pnl3: TPanel;
    flwpnl3: TFlowPanel;
    mniExportExcel1: TMenuItem;
    mniPrint1: TMenuItem;
    pm2: TPopupMenu;
    mniExportExcel2: TMenuItem;
    mniPrint2: TMenuItem;
    pm3: TPopupMenu;
    mniExportExcel3: TMenuItem;
    mniPrint3: TMenuItem;
    lblToplamTutar: TLabel;
    lblValToplamTutar: TLabel;
    lblToplamIskontoTutar: TLabel;
    lblValToplamIskontoTutar: TLabel;
    lblAraToplam: TLabel;
    lblValAraToplam: TLabel;
    lblToplamKDVTutar: TLabel;
    lblValToplamKDVTutar: TLabel;
    lblGenelToplam: TLabel;
    lblValGenelToplam: TLabel;
    lblToplamTutarKalan: TLabel;
    lblValToplamTutarKalan: TLabel;
    lblToplamIskontoTutarKalan: TLabel;
    lblValToplamIskontoTutarKalan: TLabel;
    lblAraToplamKalan: TLabel;
    lblValAraToplamKalan: TLabel;
    lblToplamKDVTutarKalan: TLabel;
    lblValToplamKDVTutarKalan: TLabel;
    lblGenelToplamKalan: TLabel;
    lblValGenelToplamKalan: TLabel;
    strngrd1: TStringGrid;
    pgcHeader: TPageControl;
    tsHeader: TTabSheet;
    tsHeaderDiger: TTabSheet;
    btnHeaderShowHide: TButton;
    strngrd2: TStringGrid;
    actlstdetaylar_form: TActionList;
    actexport_excel1: TAction;
    actprint1: TAction;
    actadd1: TAction;
    mniadd1: TMenuItem;
    mniN1: TMenuItem;
    mniadd2: TMenuItem;
    mniN2: TMenuItem;
    actadd2: TAction;
    actadd3: TAction;
    actexport_excel2: TAction;
    actexport_excel3: TAction;
    actprint2: TAction;
    actprint3: TAction;
    mniadd3: TMenuItem;
    mniN3: TMenuItem;
    actcopy1: TAction;
    actcopy2: TAction;
    actcopy3: TAction;
    dlgSave: TSaveDialog;
    pb1: TProgressBar;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure btnHeaderShowHideClick(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState); virtual;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure mniPrint2Click(Sender: TObject);
    procedure actexport_excel1Execute(Sender: TObject); virtual;
    procedure actexport_excel2Execute(Sender: TObject); virtual;
    procedure actexport_excel3Execute(Sender: TObject); virtual;
    procedure actprint1Execute(Sender: TObject);
    procedure actprint2Execute(Sender: TObject);
    procedure actprint3Execute(Sender: TObject);
    procedure actadd1Execute(Sender: TObject);
    procedure actadd2Execute(Sender: TObject);
    procedure actadd3Execute(Sender: TObject);
    procedure actcopy1Execute(Sender: TObject);
    procedure actcopy3Execute(Sender: TObject);
    procedure actcopy2Execute(Sender: TObject);
  private
    FHeaderFormMode: TInputFormMode;

/// <summary>
///  InputDB formlarındaki Edit Memo ComboBox gibi kontrollerin zorunlu alan, maks leng, charcase gibi özelliklerini form ilk açılışta ayarlıyor.
/// </summary>
///  <remarks>
///  NOT: Bu kontroller direkt olarak pnlMain üzerinde veya pgcMain içindeki TabSheet ler içinde olmalı
///  </remarks>
    procedure SetControlDBProperty(pIsOnlyRepaint: Boolean = False);
  protected
    procedure GridReset(); virtual;
    procedure GridFill(); virtual;
  public
    function CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; virtual;
    function CreateDetailInputForm2(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; virtual;
    function CreateDetailInputForm3(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; virtual;

    procedure ClearTotalLabels;

    procedure AddDetay(ADetay: TTable; AGrid: TStringGrid); virtual;
    procedure RemoveDetay(ADetay: TTable; AGrid: TStringGrid); virtual;
    procedure UpdateDetay(ADetay: TTable; AGrid: TStringGrid); virtual;

    procedure GridDecRow(pGrid: TStringGrid; pCount: Integer = 1);
    procedure GridDelRow(pGrid: TStringGrid; pRowNo: Integer);
    procedure GridClearRowsByRowNo(pGrid: TStringGrid; pRowNo: Integer);
    procedure GridHideCol(pGrid: TStringGrid; pColNo: Integer);
    procedure GridColWidth(pGrid: TStringGrid; pColWidth, pColNo: Integer);

    property HeaderFormMode: TInputFormMode read FHeaderFormMode write FHeaderFormMode;
  published
    procedure GridDblClick(Sender: TObject); virtual;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData; override;
    procedure ExportExcel(AGrid: TStringGrid; AAllColumn: Boolean = False);

    procedure ConditionDrawCell(Sender: TObject; ARow, ACol: Longint; var Value: string; var AStyle: TThsStyle); virtual;
    procedure btnSpinDownClick(Sender: TObject); override;
    procedure btnSpinUpClick(Sender: TObject); override;
  end;

implementation

uses
  ufrmBaseDBGrid,
  Ths.Globals;

{$R *.dfm}

procedure TfrmBaseDetaylar.btnAcceptClick(Sender: TObject);
begin
  btnAccept.Enabled := False;
  try
    inherited;

    if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
    begin
      mniadd1.Enabled := True;
      mniadd2.Enabled := True;
      mniadd3.Enabled := True;
    end;

  finally
    btnAccept.Enabled := true;
  end;
end;

procedure TfrmBaseDetaylar.btnHeaderShowHideClick(Sender: TObject);
begin
  pnlHeader.Visible := not pnlHeader.Visible;
  if pnlHeader.Visible then
    //btnHeaderShowHide.Caption := '-'
    btnHeaderShowHide.ImageIndex := 60  //up arrow
  else
    //btnHeaderShowHide.Caption := '+';
    btnHeaderShowHide.ImageIndex := 19; //down arrow
  //set max visible control top + height + 4 on the active tabsheet
  //change active tab sheet resize header panel the max visible control top + height + 4 on the active tabsheet
end;

procedure TfrmBaseDetaylar.btnSpinDownClick(Sender: TObject);
var
  ATable: TTable;
begin
  if (Self.ParentForm <> nil) then
  begin
    if TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecNo < TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecordCount then
    begin
      TfrmBaseDBGrid(ParentForm).MoveUp;

      Table.LogicalSelect(' and ' + Table.Id.QryName + '=' + IntToStr(TfrmBaseDBGrid(ParentForm).Table.Id.Value), False, False, False);
      ATable := TTableDetailed(Table.List[0]).Clone;
      Table.Free;
      Table := nil;
      Table := ATable;
      DefaultSelectFilter := ' and ' + Table.Id.QryName + '=' + IntToStr(Table.Id.Value);
      RefreshData;
    end;
  end;
end;

procedure TfrmBaseDetaylar.btnSpinUpClick(Sender: TObject);
var
  ATable: TTable;
begin
  if (Self.ParentForm <> nil) then
  begin
    if TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecNo > 1 then
    begin
      TfrmBaseDBGrid(ParentForm).MoveDown;

      Table.LogicalSelect(' and ' + Table.Id.QryName + '=' + IntToStr(TfrmBaseDBGrid(ParentForm).Table.Id.Value), False, False, False);
      ATable := TTableDetailed(Table.List[0]).Clone;
      Table.Free;
      Table := nil;
      Table := ATable;
      DefaultSelectFilter := ' and ' + Table.Id.QryName + '=' + IntToStr(Table.Id.Value);
      RefreshData;
    end;
  end;
end;

procedure TfrmBaseDetaylar.ClearTotalLabels;
begin
  lblValToplamTutar.Caption := '';
  lblValToplamIskontoTutar.Caption := '';
  lblValAraToplam.Caption := '';
  lblValToplamKDVTutar.Caption := '';
  lblValGenelToplam.Caption := '';

  lblValToplamTutarKalan.Caption := '';
  lblValToplamIskontoTutarKalan.Caption := '';
  lblValAraToplamKalan.Caption := '';
  lblValToplamKDVTutarKalan.Caption := '';
  lblValGenelToplamKalan.Caption := '';
end;

function TfrmBaseDetaylar.CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := nil;
end;

function TfrmBaseDetaylar.CreateDetailInputForm2(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := nil;
end;

function TfrmBaseDetaylar.CreateDetailInputForm3(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := nil;
end;

procedure TfrmBaseDetaylar.ExportExcel(AGrid: TStringGrid; AAllColumn: Boolean);
var
  ExcelApplication, Sheet: Variant;
  LColCount, nRow, nCol, LRowCount, LWidth: Integer;
  LDosyaAdi, LRange: string;
begin
  dlgSave.Filter := FILE_FILTER_XLSX;
  dlgSave.DefaultExt := FILE_EXT_XLSX;
  dlgSave.FileName := Self.Caption + ' ' + DateToStr(Table.Database.GetToday);
  dlgSave.InitialDir := '%USERPROFILE%\desktop';
  if not dlgSave.Execute then
    Exit;

  LDosyaAdi := dlgSave.FileName;

  Cursor := crHourGlass;
  try
    ExcelApplication := CreateOleObject('Excel.Application');
    ExcelApplication.Visible := False;
  except
    Showmessage('Excel dosya oluşturulamadı,' + AddLBs(2) +
                'Bilgisayarında Microsoft Excel kurulu olduğundan emin misin?');
    Exit;
  end;

  LRowCount := AGrid.RowCount;
//  AGrid.BeginUpdate;
  try
    ExcelApplication.WorkBooks.Add(-4167);   //Add excel workbook
    ExcelApplication.WorkBooks[1].WorkSheets[1].Name := 'Sayfa1';
    Sheet := ExcelApplication.WorkBooks[1].WorkSheets['Sayfa1'];

    LColCount := 0;
    for nCol := 0 to AGrid.ColCount-1 do
      if (AGrid.ColWidths[nCol] > 0) or AAllColumn then
        Inc(LColCount);

    LRange := 'A1:' + Chr(64 + LColCount) + IntToStr(LRowCount+1);
    //Col names A..Z total 26 cols After 27 col start again AA, AB ..
    if LColCount > 26 then
      LRange := 'A1:' + Chr(64 + LColCount div 26) + Chr(64 + LColCount mod 26) + IntToStr(LRowCount+1);

    //Format cells in excel sheet
    Sheet.Range[LRange].Borders.LineStyle := 7; //line style
    Sheet.Range[LRange].Borders.color := clGray;

    LColCount := 0;
    for nCol := 0 to AGrid.ColCount-1 do
      if (AGrid.ColWidths[nCol] > 0) or AAllColumn then
      begin
        Inc(LColCount);
        Sheet.Cells[1, LColCount].Interior.Color := AGrid.CellStyles[nCol, 0].Color;
        Sheet.Cells[1, LColCount].Font.Bold := fsBold in AGrid.CellStyles[nCol, 0].Font.Style;
        Sheet.Cells[1, LColCount] := AGrid.Cells[nCol, 0];

        LWidth := 0;
        LWidth := IfThen(LWidth = -1, 60, AGrid.ColWidths[nCol]);
        Sheet.Columns[LColCount].ColumnWidth := (((LWidth / 28) * 5.1425) - 0.71);
        //Sheet.Columns[LColCount].NumberFormat := '_-* #.##0,00 _₺_-;-* #.##0,00 _₺_-;_-* "-"?? _₺_-;_-@_-'
      end;

    pb1.Max := AGrid.RowCount;
    pb1.Position := 0;
    pb1.Visible := True;

    for nRow := 1 to AGrid.RowCount-1 do
    begin
      LColCount := 0;
      for nCol := 0 to AGrid.ColCount-1 do
        if (AGrid.ColWidths[nCol] > 0) or AAllColumn then
        begin
          Inc(LColCount);
          Sheet.Cells[nRow+1, LColCount] := AGrid.Cells[nCol, nRow];
        end;
      pb1.Position := nRow;
    end;

    DeleteFile(LDosyaAdi);
    Sheet.SaveAs(LDosyaAdi);

    ExcelApplication.Visible := True;
//    ExcelApplication.Quit;
    ExcelApplication := Unassigned;
    Sheet := Unassigned;
  finally
    pb1.Visible := False;
    pb1.Position := 0;
    Screen.Cursor := crDefault;
//    AGrid.EndUpdate;
  end;
end;

procedure TfrmBaseDetaylar.FormCreate(Sender: TObject);
begin
  inherited;

  if Assigned(Table) then
  begin
    ResetSession();
    SetControlDBProperty();
  end;

  pnlLeft.Visible := False;
  splLeft.Visible := False;
  btnHeaderShowHide.Caption := '';
  btnHeaderShowHide.ImageIndex := 60; //up arrow
  tsHeaderDiger.TabVisible := False;

  ts2.TabVisible := False;
  ts3.TabVisible := False;
  mniadd1.Enabled := False;
  mniadd2.Enabled := False;
  mniadd3.Enabled := False;

  strngrd1.OnConditionDrawCell := ConditionDrawCell;
  strngrd2.OnConditionDrawCell := ConditionDrawCell;
  strngrd3.OnConditionDrawCell := ConditionDrawCell;

  mniPrint1.Visible := True;
  mniPrint2.Visible := True;
  mniPrint3.Visible := True;

  ClearTotalLabels;
  grpGenelToplamKalan.Visible := False;
  grpGenelToplam.Visible := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    mniadd1.Enabled := True;
    mniadd2.Enabled := True;
    mniadd3.Enabled := True;
  end
  else
  if (FormMode = ifmNone) or (FormMode = ifmRewiev) or (FormMode = ifmReadOnly) then
  begin
    mniadd1.Enabled := False;
    mniadd2.Enabled := False;
    mniadd3.Enabled := False;
  end;
end;

procedure TfrmBaseDetaylar.FormDestroy(Sender: TObject);
begin
  //
  inherited;
end;

procedure TfrmBaseDetaylar.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (btnSpin.Visible) and (Key = VK_NEXT) then  //page_down
    btnSpinDownClick(btnSpin) //grid içinde gezinmek için burada kapatıldı.
  else if (btnSpin.Visible) and (Key = VK_PRIOR) then  //page_up
    btnSpinUpClick(btnSpin) //grid içinde gezinmek için burada kapatıldı.
  else if (Key = VK_RETURN) then
  begin
    if Sender is TStringGrid then
      GridDblClick(Sender)
  end
  else
    inherited;
end;

procedure TfrmBaseDetaylar.FormShow(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  //ufrmBase kodu
  FocusedFirstControl(pnlMain);



  //ufrmBaseInput kodu
  stbBase.Panels.Add;
  for n1 := 0 to stbBase.Panels.Count - 1 do
    stbBase.Panels.Items[n1].Style := psOwnerDraw;

  //form ve page control page 0 caption bilgisini dil dosyasına göre doldur
  //page control page 0 için isternise miras alan formda değişiklik yapılabilir.
  if Assigned(Table) then
  begin
    Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);
    pgcMain.Pages[0].Caption := Self.Caption;
  end;

  //burası yukarıdaki caption doldurma kodundan sonra gelmeli pagecontrol tablardaki başlıkları düzenliyor.
  SetCaptionFromLangContent();

  if Self.FormMode = ifmRewiev then
  begin
    //eğer başka pencerede açık transaction varsa güncelleme moduna hiç girilmemli
    if (GDatabase.Connection.InTransaction) then
    begin
      btnAccept.Visible   := False;
      btnDelete.Visible     := False;
      btnAccept.OnClick   := nil;
      btnDelete.OnClick     := nil;
    end;

    if ParentForm <> nil then
    begin
      btnSpin.Visible := True;
    end;

    //Burada inceleme modunda olduğu için bütün kontrolleri kapatmak gerekiyor.
    SetControlsDisabledOrEnabled(pnlMain, True);
  end
  else
  begin
    //Burada yeni kayıt, kopya yeni kayıt veya güncelleme modunda olduğu için bütün kontrolleri açmak gerekiyor.
    SetControlsDisabledOrEnabled(pnlMain, False);
  end;

  mniAddLanguageContent.Visible := False;
  if (GSysKullanici.IsSuperKullanici.Value) and (FormMode = ifmRewiev) then
  begin
    //yeni kayıtta transactionlardan dolayı sorun oluyor. Düzeltmek için uğralılmadı
    SetLabelPopup();
    mniAddLanguageContent.Visible := True;
  end;

//  if (FormMode <> ifmNewRecord ) then
//    RefreshData;
//ferhat buraya bak normal input db formlarda iki kere refreshdata yapıyor. Bunu engelle
//detaylı formlarda da refresh yapmalı fakat input db formlarından gelmediği için burada yapıldı.
//yapıyı gözden geçir



  //ufrmBaseInputDB kodu
  if pgcMain.Visible and pgcMain.Enabled and tsMain.TabVisible and tsMain.Enabled then
    pgcMain.ActivePageIndex := tsMain.TabIndex;

  if (FormMode <> ifmNewRecord ) then
    RefreshData;

  //sadece sayısal alanların gösterim şeklini (basamaklı ve ondalıklı) düzeltmek için yazıldı
  if Assigned(Table) then
    SetControlDBProperty(True);
  Repaint;



  //BaseDetaylar kodu
  if (FormMode = ifmNewRecord) then
    GridReset
  else if (FormMode = ifmCopyNewRecord) then
    GridFill;
end;

procedure TfrmBaseDetaylar.GridClearRowsByRowNo(pGrid: TStringGrid; pRowNo: Integer);
var
  n1: Integer;
begin
  for n1 := 0 to pGrid.ColCount-1 do
  begin
    pGrid.Cells[n1, pRowNo] := '';
    if n1 = 0 then
    begin
      if Assigned(pGrid.Objects[n1, pRowNo]) then
        pGrid.Objects[n1, pRowNo].Destroy;
    end;
  end;
end;

procedure TfrmBaseDetaylar.GridColWidth(pGrid: TStringGrid; pColWidth, pColNo: Integer);
begin
  pGrid.ColWidths[pColNo] := pColWidth;
end;

procedure TfrmBaseDetaylar.GridDecRow(pGrid: TStringGrid; pCount: Integer);
begin
  pGrid.RowCount := pGrid.RowCount - pCount;
end;

procedure TfrmBaseDetaylar.GridDelRow(pGrid: TStringGrid; pRowNo: Integer);
var
  n1: Integer;
begin
  pGrid.Invalidate;
  for n1 := pRowNo to pGrid.RowCount - 2 do
    pGrid.Rows[n1].Assign(pGrid.Rows[n1 + 1]);
  pGrid.RowCount := pGrid.RowCount - 1;
end;

procedure TfrmBaseDetaylar.GridFill();
begin

end;

procedure TfrmBaseDetaylar.GridHideCol(pGrid: TStringGrid; pColNo: Integer);
begin
  pGrid.ColWidths[pColNo] := -1;
end;

procedure TfrmBaseDetaylar.GridReset();
begin
  //use for row numbers
  strngrd1.ColWidths[0] := 30;
  strngrd2.ColWidths[0] := 30;
  strngrd3.ColWidths[0] := 30;
end;

procedure TfrmBaseDetaylar.mniPrint2Click(Sender: TObject);
begin
  inherited;
  ExportExcel(strngrd2);
end;

procedure TfrmBaseDetaylar.ConditionDrawCell(Sender: TObject; ARow, ACol: Longint; var Value: string; var AStyle: TThsStyle);
begin
//
end;

procedure TfrmBaseDetaylar.GridDblClick(Sender: TObject);
var
  AForm: TForm;
begin
  if TControl(Sender).ClassType <> TStringGrid then
    Exit;
  if TControl(Sender).Name = strngrd1.Name then
  begin
    if Assigned(TStringGrid(Sender).Objects[COLUMN_GRID_OBJECT, TStringGrid(Sender).Row]) then
      if (FormMode = ifmRewiev) then
      begin
        AForm := CreateDetailInputForm1(ifmRewiev, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end
      else if (FormMode = ifmReadOnly) then
      begin
        AForm := CreateDetailInputForm1(ifmReadOnly, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end
      else if (FormMode = ifmUpdate)
           or (FormMode = ifmCopyNewRecord)
           or (FormMode = ifmNewRecord)
      then
      begin
        AForm := CreateDetailInputForm1(ifmUpdate, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end;
  end
  else if TControl(Sender).Name = strngrd2.Name then
  begin
    if Assigned(TStringGrid(Sender).Objects[COLUMN_GRID_OBJECT, TStringGrid(Sender).Row]) then
      if (FormMode = ifmRewiev) then
      begin
        AForm := CreateDetailInputForm2(ifmRewiev, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end
      else if (FormMode = ifmReadOnly) then
      begin
        AForm := CreateDetailInputForm2(ifmReadOnly, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end
      else if (FormMode = ifmUpdate)
           or (FormMode = ifmCopyNewRecord)
           or (FormMode = ifmNewRecord)
      then
      begin
        AForm := CreateDetailInputForm2(ifmUpdate, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end;
  end
  else if TControl(Sender).Name = strngrd3.Name then
  begin
    if Assigned(TStringGrid(Sender).Objects[COLUMN_GRID_OBJECT, TStringGrid(Sender).Row]) then
      if (FormMode = ifmRewiev) then
      begin
        AForm := CreateDetailInputForm3(ifmRewiev, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end
      else if (FormMode = ifmReadOnly) then
      begin
        AForm := CreateDetailInputForm3(ifmReadOnly, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end
      else if (FormMode = ifmUpdate)
           or (FormMode = ifmCopyNewRecord)
           or (FormMode = ifmNewRecord)
      then
      begin
        AForm := CreateDetailInputForm3(ifmUpdate, TStringGrid(Sender));
        if AForm <> nil then
          AForm.Show;
      end;
  end;
end;

procedure TfrmBaseDetaylar.GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  //
end;

procedure TfrmBaseDetaylar.actadd1Execute(Sender: TObject);
var
  AForm: TForm;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    if (ts1.Visible) and (strngrd1.Visible) and (pgcContent.TabIndex = ts1.TabIndex) then
    begin
      AForm := CreateDetailInputForm1(ifmNewRecord, strngrd1);
      if AForm <> nil then
        AForm.Show;
    end;
  end;
end;

procedure TfrmBaseDetaylar.actadd2Execute(Sender: TObject);
var
  AForm: TForm;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    if (ts2.Visible) and (strngrd2.Visible) and (pgcContent.TabIndex = ts2.TabIndex) then
    begin
      AForm := CreateDetailInputForm2(ifmNewRecord, strngrd2);
      if AForm <> nil then
        AForm.Show;
    end;
  end;
end;

procedure TfrmBaseDetaylar.actadd3Execute(Sender: TObject);
var
  AForm: TForm;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    if (ts3.Visible) and (strngrd3.Visible) and (pgcContent.TabIndex = ts3.TabIndex) then
    begin
      AForm := CreateDetailInputForm3(ifmNewRecord, strngrd3);
      if AForm <> nil then
        AForm.Show;
    end;
  end;
end;

procedure TfrmBaseDetaylar.actcopy1Execute(Sender: TObject);
var
  AForm: TForm;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    if (ts1.Visible) and (strngrd1.Visible) and (pgcContent.TabIndex = ts1.TabIndex) then
      if Assigned(strngrd1.Objects[strngrd1.Col, strngrd1.Row]) then
      begin
        AForm := CreateDetailInputForm1(ifmCopyNewRecord, strngrd1);
        if AForm <> nil then
          AForm.Show;
      end;
  end;
end;

procedure TfrmBaseDetaylar.actcopy2Execute(Sender: TObject);
var
  AForm: TForm;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    if (ts2.Visible) and (strngrd2.Visible) and (pgcContent.TabIndex = ts2.TabIndex) then
      if Assigned(strngrd2.Objects[strngrd2.Col, strngrd2.Row]) then
      begin
        AForm := CreateDetailInputForm2(ifmCopyNewRecord, strngrd2);
        if AForm <> nil then
          AForm.Show;
      end;
  end;
end;

procedure TfrmBaseDetaylar.actcopy3Execute(Sender: TObject);
var
  AForm: TForm;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) or (FormMode = ifmCopyNewRecord) then
  begin
    if (ts3.Visible) and (strngrd3.Visible) and (pgcContent.TabIndex = ts3.TabIndex) then
      if Assigned(strngrd3.Objects[strngrd3.Col, strngrd3.Row]) then
      begin
        AForm := CreateDetailInputForm3(ifmCopyNewRecord, strngrd3);
        if AForm <> nil then
          AForm.Show;
      end;
  end;
end;

procedure TfrmBaseDetaylar.actexport_excel1Execute(Sender: TObject);
begin
  ExportExcel(strngrd1);
end;

procedure TfrmBaseDetaylar.actexport_excel2Execute(Sender: TObject);
begin
  ExportExcel(strngrd2);
end;

procedure TfrmBaseDetaylar.actexport_excel3Execute(Sender: TObject);
begin
  ExportExcel(strngrd3);
end;

procedure TfrmBaseDetaylar.actprint1Execute(Sender: TObject);
begin
//
end;

procedure TfrmBaseDetaylar.actprint2Execute(Sender: TObject);
begin
//
end;

procedure TfrmBaseDetaylar.actprint3Execute(Sender: TObject);
begin
//
end;

procedure TfrmBaseDetaylar.AddDetay(ADetay: TTable; AGrid: TStringGrid);
begin
  GridFill();
end;

procedure TfrmBaseDetaylar.RefreshData;
begin
  inherited;
end;

procedure TfrmBaseDetaylar.RemoveDetay(ADetay: TTable; AGrid: TStringGrid);
begin
  GridFill();
end;

procedure TfrmBaseDetaylar.SetControlDBProperty(pIsOnlyRepaint: Boolean);
var
  n1, n2: Integer;
  vControl, vPageControl, vParent: TControl;
  vColName: string;

  ctx: TRttiContext;
  typ: TRttiType;
  fld: TRttiField;
  AValue: TValue;
  AObject: TObject;
  vTable: TTable;
  vSysTableInfo: TSysViewColumns;

  procedure SubSetControlProperty(pParent: TControl; pColumns: TSysViewColumns);
  begin
    vColName := pColumns.OrjColumnName.Value;
    vControl := TWinControl(pParent).FindChildControl(PRX_EDIT + vColName);
    if Assigned(vControl) then
    begin
      if pIsOnlyRepaint then
      begin
        TEdit(vControl).Repaint;
      end
      else
      begin
        TEdit(vControl).CharCase := VCL.StdCtrls.ecUpperCase;
        TEdit(vControl).MaxLength := pColumns.CharacterMaximumLength.Value;
        TEdit(vControl).thsDBFieldName := pColumns.OrjColumnName.Value;
        TEdit(vControl).thsRequiredData := not pColumns.IsNullable.Value;
        TEdit(vControl).thsActiveYear4Digit := GSysApplicationSetting.Donem.Value;
        TEdit(vControl).OnCalculatorProcess := nil;

        if (pColumns.DataType.Value = 'text')
        or (pColumns.DataType.Value = 'character varying')
        then
          TEdit(vControl).thsInputDataType := itString
        else
        if (pColumns.DataType.Value = 'smallint')
        or (pColumns.DataType.Value = 'integer')
        or (pColumns.DataType.Value = 'bigint')
        then
        begin
          TEdit(vControl).thsInputDataType := itInteger;
          TEdit(vControl).OnCalculatorProcess := OnCalculate;

          if (pColumns.DataType.Value = 'smallint') then
            TEdit(vControl).MaxLength := 5
          else if (pColumns.DataType.Value = 'integer') then
            TEdit(vControl).MaxLength := 10
          else if (pColumns.DataType.Value = 'bigint') then
            TEdit(vControl).MaxLength := 19;
        end
        else
        if (pColumns.DataType.Value = 'date')
        or (pColumns.DataType.Value = 'timestamp without time zone')
        then
        begin
          TEdit(vControl).thsInputDataType := itDate;

          if (pColumns.DataType.Value = 'date') then
            TEdit(vControl).MaxLength := 10
          else if (pColumns.DataType.Value = 'timestamp without time zone') then
            TEdit(vControl).MaxLength := 19;
        end
        else if (pColumns.DataType.Value = 'double precision') then
        begin
          TEdit(vControl).thsInputDataType := itFloat;
          TEdit(vControl).OnCalculatorProcess := OnCalculate;
        end
        else if (pColumns.DataType.Value = 'numeric') then
        begin
          TEdit(vControl).thsInputDataType := itMoney;
          TEdit(vControl).Alignment := taRightJustify;
          TEdit(vControl).OnCalculatorProcess := OnCalculate;
        end;
      end;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_MEMO + vColName);
    if Assigned(vControl) then
    begin
      if pIsOnlyRepaint then
      begin
        TMemo(vControl).Repaint;
      end
      else
      begin
        TMemo(vControl).CharCase := VCL.StdCtrls.ecUpperCase;
        TMemo(vControl).MaxLength := pColumns.CharacterMaximumLength.Value;
        TMemo(vControl).thsDBFieldName := pColumns.OrjColumnName.Value;
        TMemo(vControl).thsRequiredData := not pColumns.IsNullable.Value;

        if (pColumns.DataType.Value = 'text')
        or (pColumns.DataType.Value = 'character varying')
        then
          TMemo(vControl).thsInputDataType := itString
        else
        if (pColumns.DataType.Value = 'smallint')
        or (pColumns.DataType.Value = 'integer')
        or (pColumns.DataType.Value = 'bigint')
        then
        begin
          TMemo(vControl).thsInputDataType := itInteger;

          if (pColumns.DataType.Value = 'smallint') then
            TEdit(vControl).MaxLength := 5
          else if (pColumns.DataType.Value = 'integer') then
            TEdit(vControl).MaxLength := 10
          else if (pColumns.DataType.Value = 'bigint') then
            TEdit(vControl).MaxLength := 19;
        end
        else
        if (pColumns.DataType.Value = 'date')
        or (pColumns.DataType.Value = 'timestamp without time zone')
        then
        begin
          TMemo(vControl).thsInputDataType := itDate;

          if (pColumns.DataType.Value = 'date') then
            TEdit(vControl).MaxLength := 10
          else if (pColumns.DataType.Value = 'timestamp without time zone') then
            TEdit(vControl).MaxLength := 19;
        end
        else if (pColumns.DataType.Value = 'double precision') then
          TCombobox(vControl).thsInputDataType := itFloat
        else if (pColumns.DataType.Value = 'numeric') then
        begin
          TMemo(vControl).thsInputDataType := itMoney;
          TMemo(vControl).Alignment := taRightJustify;
        end;
      end;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_COMBOBOX + vColName);
    if Assigned(vControl) then
    begin
      if pIsOnlyRepaint then
      begin
        TCombobox(vControl).Repaint;
      end
      else
      begin
        TCombobox(vControl).CharCase := VCL.StdCtrls.ecUpperCase;
        if (pColumns.DataType.Value = 'smallint') then
          TCombobox(vControl).MaxLength := IfThen(pColumns.CharacterMaximumLength.Value > 5, 5, pColumns.CharacterMaximumLength.Value);
        TCombobox(vControl).thsDBFieldName := pColumns.OrjColumnName.Value;
        TCombobox(vControl).thsRequiredData := not pColumns.IsNullable.Value;

        TCombobox(vControl).thsInputDataType := itString;

        if (pColumns.DataType.Value = 'text')
        or (pColumns.DataType.Value = 'character varying')
        then
          TCombobox(vControl).thsInputDataType := itString
        else
        if (pColumns.DataType.Value = 'integer')
        or (pColumns.DataType.Value = 'bigint')
        or (pColumns.DataType.Value = 'smallint')
        then
          TCombobox(vControl).thsInputDataType := itInteger
        else
        if (pColumns.DataType.Value = 'date')
        or (pColumns.DataType.Value = 'timestamp without time zone')
        then
          TCombobox(vControl).thsInputDataType := itDate
        else if (pColumns.DataType.Value = 'double precision') then
          TCombobox(vControl).thsInputDataType := itFloat
        else if (pColumns.DataType.Value = 'numeric') then
        begin
          TCombobox(vControl).thsInputDataType := itMoney;
        end;
      end;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_CHECKBOX + vColName);
    if Assigned(vControl) then
    begin
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_RADIOGROUP + vColName);
    if Assigned(vControl) then
    begin
    end;
  end;

begin
  vPageControl := pnlHeader.FindChildControl(pgcHeader.Name);
  if Assigned(vPageControl) then
  begin
    for n1 := 0 to TPageControl(vPageControl).PageCount-1 do
    begin
      vParent := TPageControl(vPageControl).Pages[n1];
      for n2 := 0 to GSysTableInfo.List.Count-1 do
        if TSysViewColumns(GSysTableInfo.List[n2]).OrjTableName.Value = Table.TableName then
          SubSetControlProperty(vParent, TSysViewColumns(GSysTableInfo.List[n2]));
    end;

    //is_contain_table(Table) evet ise control set yap hayır ise çık
    vTable := getContainTable(Table);
    if Assigned(vTable) then
    begin
      vSysTableInfo := TSysViewColumns.Create(Table.Database);
      try
        vSysTableInfo.SelectToList(' AND ' + vSysTableInfo.TableName + '.' + vSysTableInfo.OrjTableName.FieldName + '=' + QuotedStr(vTable.TableName), False, False);
        typ := ctx.GetType(vTable.ClassType);
        if Assigned(typ) then
          for fld in typ.GetFields do
            if Assigned(fld) then
              if fld.FieldType is TRttiInstanceType then
                if TRttiInstanceType(fld.FieldType).MetaclassType.InheritsFrom(TFieldDB) then
                begin
                  AValue := fld.GetValue(vTable);
                  AObject := nil;
                  if not AValue.IsEmpty then
                    AObject := AValue.AsObject;

                  if Assigned(AObject) then
                    if AObject.InheritsFrom(TFieldDB) then
                      for n1 := 0 to TPageControl(vPageControl).PageCount-1 do
                      begin
                        vParent := TPageControl(vPageControl).Pages[n1];
                        for n2 := 0 to vSysTableInfo.List.Count-1 do
                          SubSetControlProperty(vParent, TSysViewColumns(vSysTableInfo.List[n2]));
                      end;
                end
      finally
        vSysTableInfo.Free;
      end;
    end;
  end
  else
  begin
    vParent := pnlMain;
    for n1 := 0 to GSysTableInfo.List.Count-1 do
      SubSetControlProperty(vParent, TSysViewColumns(GSysTableInfo.List[n1]));
    //ilk önce sınıfa ait tüm kontrolleri düzenle
    //daha sonra rtti ile table sınıfı taranacak ve içinde ttable tipinden bir field varsa
    //table sınıfı bulunup buradan sysviewcolums bilgileri çekilecek.
    //Bu çekilen column bilgilerine uyan kontrol varmı diye tüm hepsi taranacak ve bulunanlar için bilgiler set edilecek
    //is_contain_table(Table) evet ise control set yap hayır ise çık
    vTable := getContainTable(Table);
    if Assigned(vTable) then
    begin
      vSysTableInfo := TSysViewColumns.Create(Table.Database);
      try
        vSysTableInfo.SelectToList(' AND ' + vSysTableInfo.TableName + '.' + vSysTableInfo.OrjTableName.FieldName + '=' + QuotedStr(vTable.TableName), False, False);
        typ := ctx.GetType(vTable.ClassType);
        if Assigned(typ) then
          for fld in typ.GetFields do
            if Assigned(fld) then
              if fld.FieldType is TRttiInstanceType then
                if TRttiInstanceType(fld.FieldType).MetaclassType.InheritsFrom(TFieldDB) then
                begin
                  AValue := fld.GetValue(vTable);
                  AObject := nil;
                  if not AValue.IsEmpty then
                    AObject := AValue.AsObject;

                  if Assigned(AObject) then
                    if AObject.InheritsFrom(TFieldDB) then
                    begin
                      vParent := pnlMain;
                      for n1 := 0 to vSysTableInfo.List.Count-1 do
                        SubSetControlProperty(vParent, TSysViewColumns(vSysTableInfo.List[n1]));
                    end
                end
      finally
        vSysTableInfo.Free;
      end;
    end;
  end;
end;

procedure TfrmBaseDetaylar.UpdateDetay(ADetay: TTable; AGrid: TStringGrid);
begin
  GridFill();
end;

end.
