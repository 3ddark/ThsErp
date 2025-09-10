unit ufrmInputSimpleDbX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Math,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  Ths.DialogHelper,
  BaseEntity, BaseService, SharedFormTypes;

type
  TfrmInputSimpleDbX<TE: TEntity; TS: TBaseService<TE>> = class(TForm)
  private
    FService: TS;
    FTable: TE;

    FFormMode: TInputFormMode;
    FRefreshGridEvent: TAfterCrudRefreshGrid;

    FPanelMain: TPanel;
    FPanelFooter: TPanel;
    FStatusBase: TStatusBar;

    FPgcBase: TPageControl;
    FBtnSpin: TSpinButton;
    FBtnAccept: TButton;
    FBtnClose: TButton;
    FBtnDelete: TButton;
    procedure SetService(const Value: TS);
    procedure SetTable(const Value: TE);
  public
    property Service: TS read FService write SetService;
    property Table: TE read FTable write SetTable;

    property FormMode: TInputFormMode read FFormMode write FFormMode;

    property PanelMain: TPanel read FPanelMain write FPanelMain;
    property PanelFooter: TPanel read FPanelFooter write FPanelFooter;
    property StatusBase: TStatusBar read FStatusBase write FStatusBase;

    property PgcBase: TPageControl read FPgcBase write FPgcBase;
    property BtnSpin: TSpinButton read FBtnSpin write FBtnSpin;
    property BtnAccept: TButton read FBtnAccept write FBtnAccept;
    property BtnClose: TButton read FBtnClose write FBtnClose;
    property BtnDelete: TButton read FBtnDelete write FBtnDelete;

    constructor Create(AOwner: TComponent; AService: TS; ATable: TE; AFormMode: TInputFormMode; ARefreshGridEvent: TAfterCrudRefreshGrid); reintroduce; overload;
    destructor Destroy; override;

    //***form***
    procedure FormCreate(Sender: TObject); virtual;
    procedure FormDestroy(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure FormKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    //***status bar***
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    //***footer button events***
    procedure BtnSpinDownClick(Sender: TObject); virtual;
    procedure BtnSpinUpClick(Sender: TObject); virtual;
    procedure BtnAcceptClick(Sender: TObject); virtual;
    procedure BtnCloseClick(Sender: TObject); virtual;
    procedure BtnDeleteClick(Sender: TObject); virtual;

    procedure RefreshParentGrid(AFocusSelectedItem: Boolean);
    procedure RefreshDataAuto; virtual;
    procedure RefreshData; virtual;
    procedure StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);

    procedure PrepareForm;
    procedure CreatePanelMain;
    procedure CreatePanelFooter;
    procedure CreatePageControl;
    procedure CreateBtnSpin;
    procedure CreateBtnAccept;
    procedure CreateBtnClose;
    procedure CreateBtnDelete;
  end;

implementation

uses
  ufrmGrid;

procedure TfrmInputSimpleDbX<TE, TS>.BtnAcceptClick(Sender: TObject);
//var
//  LTable: TEntity;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    try
      Service.BusinessInsert(Self.Table, True, True, False);//WithCommitTransaction
      RefreshParentGrid(True);
      ModalResult := mrOK;
      Close;
    except
      ModalResult := mrNone;//hata durumunda pencere kapanmas�n

      //eger begin transaction demiyorsa insert pencere kapans�n ��nk� rollback yap�ld art�k insert etmemeli
      //�nceki i�lemler geri al�nd��� i�in
      if (Service.UoW.Connection.InTransaction) then
        Close;
      raise;
    end;
  end
  else if (FormMode = ifmUpdate) then
  begin
    if TThsDialogHelper.CustomMsgDlg('Kayd� g�ncelleme istedi�inden emin misin?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], ['Evet', 'Hay�r'], mbNo, 'Kullan�c� Onay�') = mrYes then
    begin
      //Burada yeni kay�t veya g�ncelleme modunda oldu�u i�in b�t�n kontrolleri a�mak gerekiyor.
{      SetControlsDisabledOrEnabled(PanelMain, True);
      if (Table.LogicalUpdate(WithCommitTransaction, True)) then
      begin
        RefreshParentGrid(True);
        ModalResult := mrOK;
        Close;
      end
      else
      begin
        ModalResult := mrNone;
        btnSpin.Visible := true;
        FormMode := ifmRewiev;
        btnAccept.Caption := 'G�ncelle';
        btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
        btnAccept.Width := Max(100, btnAccept.Width);
        btnDelete.Visible := false;
        Repaint;
      end;
 }
    end;
  end
  else if (FormMode = ifmRewiev) then
  begin
{    //burada g�ncelleme modunda oldu�u i�in b�t�n kontrolleri a�mak gerekiyor.
    SetControlsDisabledOrEnabled(pnlMain, False);

    if (not Service.UoW.Connection.InTransaction) then
    begin
      //varsa kayd� kilitle
      if (Table.LogicalSelect(DefaultSelectFilter, True, ( not Service.UoW.InTransaction), True)) then
      begin
        //e�er aranan kay�t ba�ka bir kullan�c� taraf�ndan silinmi�se count 0 kal�r
        if (Table.List.Count = 0) then
          raise Exception.Create('Siz inceleme ekran�ndayken kay�t ba�ka kullan�c� taraf�ndan silinmi�.' + AddLBs(2) + 'Kayd� tekrar kontrol edin!');

        LTable := TTable(Table.List[0]).Clone;
        Table.Destroy;
        Table := LTable;

        btnSpin.Visible := false;
        FormMode := ifmUpdate;
        btnAccept.Caption := 'Onayla';
        btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
        btnAccept.Width := Max(100, btnAccept.Width);
        btnDelete.Visible := True;

        if Table.IsAuthorized(ptUpdate, True, False) then
          btnAccept.Enabled := True
        else
          btnAccept.Enabled := False;

        RefreshData;

        Repaint;

        FocusFirstControl;

        btnDelete.Left := btnAccept.Left-btnDelete.Width;
      end;
    end
    else
      CustomMsgDlg('Aktif bir kay�t g�ncellemeniz var. �nce a��k olan i�leminizi bitirin!', mtError, [mbOK], ['Tamam'], mbOK, 'Bilgilendirme');
}
  end;
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnDeleteClick(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnSpinDownClick(Sender: TObject);
begin

end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnSpinUpClick(Sender: TObject);
begin

end;

constructor TfrmInputSimpleDbX<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; AFormMode: TInputFormMode; ARefreshGridEvent: TAfterCrudRefreshGrid);
begin
  Create(Owner);

  SetService(AService);
  SetTable(ATable);

  FFormMode := AFormMode;

  FRefreshGridEvent := ARefreshGridEvent;

  Self.Caption := 'Base Title';

  PrepareForm();

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    BtnAccept.Visible := True;
    BtnClose.Visible := True;
    BtnAccept.Caption := 'Onayla';
    BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
    BtnAccept.Width := Max(100, BtnAccept.Width);
  end
  else if FormMode = ifmRewiev then
  begin
    BtnAccept.Visible := True;
    BtnClose.Visible := True;

    BtnAccept.Caption := 'Güncelle';
    BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
    BtnAccept.Width := Max(100, BtnAccept.Width);
    BtnDelete.Caption := 'Kayıt Sil';
    BtnDelete.Width := Canvas.TextWidth(BtnDelete.Caption) + 56;
    BtnDelete.Width := Max(100, BtnDelete.Width);
  end;
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreateBtnAccept;
begin
  BtnAccept := TButton.Create(PanelFooter);
  BtnAccept.Parent := PanelFooter;
  BtnAccept.TabOrder := 2;
  BtnAccept.Caption := 'Kaydet';
  BtnAccept.OnClick := BtnAcceptClick;
  BtnAccept.Align := alRight;
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreateBtnClose;
begin
  BtnClose := TButton.Create(PanelFooter);
  BtnClose.Parent := PanelFooter;
  BtnClose.TabOrder := 3;
  BtnClose.Caption := 'Kapat';
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreateBtnDelete;
begin
  BtnDelete := TButton.Create(PanelFooter);
  BtnDelete.Parent := PanelFooter;
  BtnDelete.TabOrder := 1;
  BtnDelete.Caption := 'Sil';
  BtnDelete.OnClick := BtnAcceptClick;
  BtnDelete.Align := alLeft;
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreateBtnSpin;
begin
  BtnSpin := TSpinButton.Create(PanelFooter);
  BtnSpin.Parent := PanelFooter;
  BtnSpin.TabOrder := 0;
  BtnSpin.OnUpClick := BtnSpinUpClick;
  BtnSpin.OnDownClick := BtnSpinDownClick;
  BtnSpin.Align := alLeft;
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreatePageControl;
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreatePanelFooter;
begin
  PanelFooter := TPanel.Create(PanelMain);
  PanelFooter.Parent := PanelMain;
  PanelFooter.Align := alBottom;
  PanelFooter.BevelOuter := bvNone;
  PanelFooter.Height := 28;
  PanelFooter.ParentColor := True;
  PanelFooter.Visible := True;
end;

procedure TfrmInputSimpleDbX<TE, TS>.CreatePanelMain;
begin
  PanelMain := TPanel.Create(Self);
  PanelMain.Parent := Self;
  PanelMain.Align := alClient;
  PanelMain.BevelOuter := bvNone;
  PanelMain.ParentColor := True;
  PanelMain.Visible := True;
end;

destructor TfrmInputSimpleDbX<TE, TS>.Destroy;
var
  n1: Integer;
begin
  Service := nil;

  for n1 := 0 to Table.Fields.Count-1 do
  begin
    if Table.Fields[n1].OwnerEntity <> nil then
      Table.Fields[n1].OwnerEntity := nil;
  end;
  Table := nil;
  inherited;
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Self.Close;
  end;
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.FormShow(Sender: TObject);
begin
  BtnAccept.Visible := False;
  BtnAccept.Visible := True;

  if (FormMode <> ifmNewRecord ) then
    RefreshData;

  Repaint;
end;

procedure TfrmInputSimpleDbX<TE, TS>.PrepareForm;
begin
  Self.Position := poOwnerFormCenter;
  Self.KeyPreview := True;
  Self.Constraints.MinWidth := 350;
  Self.Constraints.MaxWidth := Monitor.Width;
  Self.Constraints.MinHeight := 150;
  Self.Constraints.MaxHeight := Monitor.Height;

  //form event
  Self.OnCreate := FormCreate;
  Self.OnShow := FormShow;
  Self.OnClose := FormClose;
  Self.OnKeyPress := FormKeyPress;
  Self.OnKeyDown := FormKeyDown;
  Self.OnKeyUp := FormKeyUp;

  CreatePanelMain;
    CreatePageControl;
  CreatePanelFooter;
    CreateBtnSpin;
    CreateBtnClose;
    CreateBtnAccept;
    CreateBtnDelete;

  FStatusBase := TStatusBar.Create(Self);
  FStatusBase.Align := alBottom;
  FStatusBase.Parent := Self;
  FStatusBase.OnDrawPanel := StatusBarDrawPanel;
  FStatusBase.Font.Size := 8;
end;

procedure TfrmInputSimpleDbX<TE, TS>.RefreshData;
begin
  RefreshDataAuto;
end;

procedure TfrmInputSimpleDbX<TE, TS>.RefreshDataAuto;
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  if Assigned(FRefreshGridEvent) then
    FRefreshGridEvent(AFocusSelectedItem);
end;

procedure TfrmInputSimpleDbX<TE, TS>.SetService(const Value: TS);
begin
  FService := Value;
end;

procedure TfrmInputSimpleDbX<TE, TS>.SetTable(const Value: TE);
begin
  FTable := Value;
end;

procedure TfrmInputSimpleDbX<TE, TS>.StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
begin
//
end;

procedure TfrmInputSimpleDbX<TE, TS>.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
//var
//  vIco: Integer;
begin
//  FStatusBase.Canvas.Font.Name := DefaultFontName;
//  FStatusBase.Canvas.Font.Style := [fsBold];
//
//  FStatusBase.Canvas.TextRect(Rect,
//    Rect.Left + dm.il16.Width,
//    Rect.Top + (FStatusBase.Height-Canvas.TextHeight(Panel.Text)) div 2 - 2,
//    Panel.Text);
//
//  vIco := -1;
//  case Panel.Index of
//    DB_STATUS_RECORD_COUNT: vIco := IMG_SUM;
//    DB_STATUS_SQL_SERVER: vIco := IMG_SERVER;
//    DB_STATUS_PERIOD: vIco := IMG_CALENDAR;
//    DB_STATUS_USER: vIco := IMG_USER_HE;
//    DB_STATUS_KEY_F6: vIco := IMG_FAVORITE;
//    DB_STATUS_KEY_F7: vIco := IMG_FAVORITE;
//    DB_STATUS_KEY_F11: vIco := IMG_FAVORITE;
//  end;
//
//  if vIco > -1 then
//  begin
//    dm.il16.Draw(StatusBar.Canvas, Rect.Left, Rect.Top, vIco);
//    Panel.Width := FStatusBase.Canvas.TextWidth(Panel.Text)+ dm.il16.Width + 16;
//  end;
end;

end.
