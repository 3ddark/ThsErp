unit ufrmBaseDetaylar;

interface

{$I ThsERP.inc}

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
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  frxClass,
  frxExportBaseDialog,
  frxExportPDF,
  frxDBSet,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.StringGrid,
  udm,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Constants,
  Ths.Erp.Database,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.TableDetailed,
  Ths.Erp.Database.Table.View.SysViewColumns;

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
    frxdbdtstBase: TfrxDBDataset;
    frxpdfxprtBase: TfrxPDFExport;
    frxrprtBase: TfrxReport;
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
///  InputDB formlarýndaki Edit Memo ComboBox gibi kontrollerin zorunlu alan, maks leng, charcase gibi özelliklerini form ilk açýlýþta ayarlýyor.
/// </summary>
///  <remarks>
///  NOT: Bu kontroller direkt olarak pnlMain üzerinde veya pgcMain içindeki TabSheet ler içinde olmalý
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
    procedure ExportExcel(AGrid: TStringGrid);
    procedure ExportAllGridToExcel();

    procedure ConditionDrawCell(Sender: TObject; ARow, ACol: Longint; var Value: string; var AStyle: TThsStyle); virtual;
    procedure btnSpinDownClick(Sender: TObject); override;
    procedure btnSpinUpClick(Sender: TObject); override;
  end;

implementation

uses
  ufrmBaseDBGrid,
  Ths.Erp.Globals,
  Ths.Erp.Database.Table.SysKaliteFormTipi;

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
    btnHeaderShowHide.Caption := '-'
  else
    btnHeaderShowHide.Caption := '+';
  //set max visible control top + height + 4 on the active tabsheet
  //change active tab sheet resize header panel the max visible control top + height + 4 on the active tabsheet
end;

procedure TfrmBaseDetaylar.btnSpinDownClick(Sender: TObject);
begin
  if (Self.ParentForm <> nil) then
  begin
    if TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecNo < TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecordCount then
    begin
      TfrmBaseDBGrid(ParentForm).MoveUp;

      Table.LogicalSelect(' and ' + Table.TableName + '.' + Table.Id.FieldName + '=' + IntToStr(TfrmBaseDBGrid(ParentForm).Table.Id.Value), False, False, False);
      DefaultSelectFilter := ' and ' + Table.TableName + '.' + Table.Id.FieldName + '=' + IntToStr(Table.Id.Value);
      RefreshData;
    end;
  end;
end;

procedure TfrmBaseDetaylar.btnSpinUpClick(Sender: TObject);
begin
  if (Self.ParentForm <> nil) then
  begin
    if TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecNo > 1 then
    begin
      TfrmBaseDBGrid(ParentForm).MoveDown;

      Table.LogicalSelect(' and ' + Table.TableName + '.' + Table.Id.FieldName + '=' + IntToStr(TfrmBaseDBGrid(ParentForm).Table.Id.Value), False, False, False);
      DefaultSelectFilter := ' and ' + Table.TableName + '.' + Table.Id.FieldName + '=' + IntToStr(Table.Id.Value);
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

procedure TfrmBaseDetaylar.ExportAllGridToExcel();
begin
  //Burasý daha sonra nasýl kullanýlacaksa doldurulacak.
  //Harici component kullanýlmadýðý için boþ býrakýldý. TMS veya DevEX ile çok kolay yapýlabilir.
  //Burayý bilgisayarda kurulu olan Excel i kullanarak çýktý verecek þekilde düzelteceðiz.
end;

procedure TfrmBaseDetaylar.ExportExcel(AGrid: TStringGrid);
begin
  //Burasý daha sonra nasýl kullanýlacaksa doldurulacak.
  //Harici component kullanýlmadýðý için boþ býrakýldý. TMS veya DevEX ile çok kolay yapýlabilir.
  //Burayý bilgisayarda kurulu olan Excel i kullanarak çýktý verecek þekilde düzelteceðiz.
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
  btnHeaderShowHide.Caption := '-';
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
    btnSpinDownClick(btnSpin) //grid içinde gezinmek için burada kapatýldý.
  else if (btnSpin.Visible) and (Key = VK_PRIOR) then  //page_up
    btnSpinUpClick(btnSpin) //grid içinde gezinmek için burada kapatýldý.
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
  //ufrmBase kodu
  FocusedFirstControl(pnlMain);



  //ufrmBaseInput kodu
  stbBase.Panels.Add;
  for n1 := 0 to stbBase.Panels.Count - 1 do
    stbBase.Panels.Items[n1].Style := psOwnerDraw;

  if Assigned(Table) then
    if GDataBase.Connection.Connected then
    begin
      if GSysUygulamaAyari.IsKaliteFormNoKullan.Value then
      begin
        stbBase.Panels.Items[STATUS_SQL_SERVER].Text := GetKaliteFormNo(Table.TableName, QtyInput);
        stbBase.Panels.Items[STATUS_SQL_SERVER].Width := stbBase.Width;
      end;
    end;

  //form ve page control page 0 caption bilgisini dil dosyasýna göre doldur
  //page control page 0 için isternise miras alan formda deðiþiklik yapýlabilir.
  if Assigned(Table) then
  begin
    Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);
    pgcMain.Pages[0].Caption := Self.Caption;
  end;

  //burasý yukarýdaki caption doldurma kodundan sonra gelmeli pagecontrol tablardaki baþlýklarý düzenliyor.
  SetCaptionFromLangContent();

  if Self.FormMode = ifmRewiev then
  begin
    //eðer baþka pencerede açýk transaction varsa güncelleme moduna hiç girilmemli
    if (Table.Database.Connection.InTransaction) then
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

    //Burada inceleme modunda olduðu için bütün kontrolleri kapatmak gerekiyor.
    SetControlsDisabledOrEnabled(pnlMain, True);
  end
  else
  begin
    //Burada yeni kayýt, kopya yeni kayýt veya güncelleme modunda olduðu için bütün kontrolleri açmak gerekiyor.
    SetControlsDisabledOrEnabled(pnlMain, False);
  end;

  mniAddLanguageContent.Visible := False;
  if (GSysKullanici.IsSuperKullanici.Value) and (FormMode = ifmRewiev) then
  begin
    //yeni kayýtta transactionlardan dolayý sorun oluyor. Düzeltmek için uðralýlmadý
    SetLabelPopup();
    mniAddLanguageContent.Visible := True;
  end;

//  if (FormMode <> ifmNewRecord ) then
//    RefreshData;
//ferhat buraya bak normal input db formlarda iki kere refreshdata yapýyor. Bunu engelle
//detaylý formlarda da refresh yapmalý fakat input db formlarýndan gelmediði için burada yapýldý.
//yapýyý gözden geçir

  Application.ProcessMessages;

  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0);



  //ufrmBaseInputDB kodu
  if pgcMain.Visible and pgcMain.Enabled and tsMain.TabVisible and tsMain.Enabled then
    pgcMain.ActivePageIndex := tsMain.TabIndex;

  if (FormMode <> ifmNewRecord ) then
    RefreshData;

  //sadece sayýsal alanlarýn gösterim þeklini (basamaklý ve ondalýklý) düzeltmek için yazýldý
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
        TEdit(vControl).thsActiveYear4Digit := GSysUygulamaAyari.Donem.Value;
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

    //is_contain_table(Table) evet ise control set yap hayýr ise çýk
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
    //ilk önce sýnýfa ait tüm kontrolleri düzenle
    //daha sonra rtti ile table sýnýfý taranacak ve içinde ttable tipinden bir field varsa
    //table sýnýfý bulunup buradan sysviewcolums bilgileri çekilecek.
    //Bu çekilen column bilgilerine uyan kontrol varmý diye tüm hepsi taranacak ve bulunanlar için bilgiler set edilecek
    //is_contain_table(Table) evet ise control set yap hayýr ise çýk
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
