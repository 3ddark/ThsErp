unit ufrmInputSimpleDB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Math, System.SysUtils,
  System.StrUtils, System.Rtti, System.Types, System.TypInfo,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  Ths.DialogHelper, Ths.Globals, SysViewColumn, MetaProvider,
  Entity, Service, SharedFormTypes;

type
  TfrmInputSimpleDB<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TForm)
  private
    FService: TS;
    FTable: TE;

    FFormMode: TInputFormMode;
    FDefaultSelectFilter: string;
    FRefreshGridEvent: TAfterCrudRefreshGrid;
    FAfterDeleteEvent: TNotifyEvent;

    FPanelMain: TPanel;
    FPanelFooter: TPanel;
    FStatusBase: TStatusBar;

    FPgcBase: TPageControl;
    FBtnSpin: TSpinButton;
    FBtnAccept: TButton;
    FBtnClose: TButton;
    FBtnDelete: TButton;

    procedure DoAfterDeleteEvent(Sender: TObject);

    procedure SetService(const Value: TS);
    procedure SetTable(const Value: TE);
    function ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
  protected
    procedure SetControlsDisabledOrEnabled(AContainerControl: TWinControl = nil; ADisable: Boolean = True);

    procedure BindEntityToControls(AEntity: TObject; AForm: TForm; Meta: TEntityMeta);
  public
    property Service: TS read FService write SetService;
    property Table: TE read FTable write SetTable;

    property FormMode: TInputFormMode read FFormMode write FFormMode;
    property DefaultSelectFilter: string read FDefaultSelectFilter write FDefaultSelectFilter;

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
    function ValidateInput(AContainerControl: TWinControl = nil): Boolean; virtual;
    procedure InitializeInputCase; virtual;

    procedure PrepareForm;
    procedure CreatePanelMain;
    procedure CreatePanelFooter;
    procedure CreatePageControl;
    procedure CreateBtnSpin;
    procedure CreateBtnAccept;
    procedure CreateBtnClose;
    procedure CreateBtnDelete;
  published
    property AfterDeleteEvent: TNotifyEvent read FAfterDeleteEvent write FAfterDeleteEvent;
  end;

implementation

uses Logger, EntityAttributes;

procedure TfrmInputSimpleDB<TE, TS>.BindEntityToControls(AEntity: TObject; AForm: TForm; Meta: TEntityMeta);
var
  propMeta: TPropertyMeta;
  ctrl: TControl;
begin
  if Meta = nil then
    Exit;

  for propMeta in Meta.Properties.Values do
  begin
    ctrl := AForm.FindComponent('edt' + propMeta.ColumnName) as TControl;
    if not Assigned(ctrl) then
      Continue;

    if Assigned(AForm.FindComponent('lbl' + propMeta.ColumnName)) then
      (AForm.FindComponent('lbl' + propMeta.ColumnName) as TLabel).Caption := propMeta.DisplayLabel;

    if ctrl is TEdit then
    begin
      if propMeta.MaxLength > 0 then
        (ctrl as TEdit).MaxLength := propMeta.MaxLength
      else
      case propMeta.PropertyType.TypeKind of
        tkInteger, tkInt64: (ctrl as TEdit).MaxLength := 10;
        tkFloat: (ctrl as TEdit).MaxLength := 18;
        tkUString, tkString, tkLString: (ctrl as TEdit).MaxLength := 255;
      end;

      if SameText(propMeta.PropertyType.Name, 'TDate') then
        (ctrl as TEdit).MaxLength := 10
      else if SameText(propMeta.PropertyType.Name, 'TTime') then
        (ctrl as TEdit).MaxLength := 5;
    end;

    if propMeta.Required then
      ctrl.Tag := 1;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnAcceptClick(Sender: TObject);
var
  n1: Integer;
  LId: Int64;
  validation: TValidationResult;
  LMsgs: string;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    validation := Table.Validate;
    if validation.IsValid then
      validation.Free
    else
    begin
      LMsgs := '';
      for n1 := 0 to Length(validation.Errors)-1 do
        LMsgs := LMsgs + validation.Errors[n1].FieldName + ': ' + validation.Errors[n1].Message + sLineBreak;
      ShowMessage(LMsgs);
      validation.Free;
      Exit;
    end;
    //ValidateInput(PanelMain);
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    try
      Service.BusinessInsert(Self.Table, True, True, False);
      RefreshParentGrid(True);
      ModalResult := mrOK;
      Close;
    except
      ModalResult := mrNone;//dont close window in exception

      //eger begin transaction demiyorsa insert pencere kapansin cunku rollback yapildi artik insert etmemeli
      //Onceki islemler geri alindigi icin
      if (Service.UoW.InTransaction) then
        Close;
      raise;
    end;
  end
  else if (FormMode = ifmUpdate) then
  begin
    if TThsDialogHelper.CustomMsgDlg('Kaydı güncellemek istediğinden emin misin?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      SetControlsDisabledOrEnabled(PanelMain, True);
      try
        Service.BusinessUpdate(Table, Service.UoW.InTransaction, True, True);
        RefreshParentGrid(True);
        ModalResult := mrOK;
        Close;
      except
        ModalResult := mrNone;
        btnSpin.Visible := true;
        FormMode := ifmRewiev;
        btnAccept.Caption := 'Güncelle';
        btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
        btnAccept.Width := Max(100, btnAccept.Width);
        btnDelete.Visible := false;
        Repaint;
      end;
    end;
  end
  else if (FormMode = ifmRewiev) then
  begin
    SetControlsDisabledOrEnabled(PanelMain, False);

    if (not Service.UoW.InTransaction) then
    begin
      LId := Table.Id;
      FreeAndNil(Table);
      Table := Service.BusinessFindById(LId, (not Service.UoW.InTransaction), True, True);

      if (Table = nil) then
        raise Exception.Create('Siz inceleme ekranındayken kayıt başka kullanıcı tarafından silinmiş.' + AddLBs(2) + 'Kaydı tekrar kontrol edin!');

      FormMode := ifmUpdate;

      btnSpin.Visible := false;

      btnAccept.Caption := 'Onayla';
      btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
      btnAccept.Width := Max(100, btnAccept.Width);
      if Service.Uow.IsAuthorized(ptUpdate, True, False)
      then  btnAccept.Enabled := True
      else  btnAccept.Enabled := False;

      btnDelete.Visible := True;
      btnDelete.OnClick := btnDeleteClick;

      RefreshData;

      Repaint;

//      FocusFirstControl;

      btnDelete.Left := btnAccept.Left-btnDelete.Width;
    end
    else
      CustomMsgDlg('Aktif bir kayıt güncellemeniz var. önce açık olan işleminizi bitirin!', mtError, [mbOK], ['Tamam'], mbOK, 'Bilgilendirme');
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnDeleteClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate)then
  begin
    if CustomMsgDlg('Kaydı silmek istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      try
        Service.BusinessDelete(Table, not Service.Uow.InTransaction, True, False);
        DoAfterDeleteEvent(Sender);

        RefreshParentGrid(False);
        ModalResult := mrOK;
        Close;
      except
        ModalResult := mrNone;
        FormMode := ifmRewiev;
        btnSpin.Visible := True;
        btnDelete.Visible := False;
        btnAccept.Caption := 'Güncelle';
        btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
        btnAccept.Width := Max(100, btnAccept.Width);

        Repaint;
      end;
    end;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnSpinDownClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnSpinUpClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
end;

constructor TfrmInputSimpleDB<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; AFormMode: TInputFormMode; ARefreshGridEvent: TAfterCrudRefreshGrid);
var LModeStr: string;
begin
  Create(Owner);

  case AFormMode of
    ifmNone: LModeStr := 'None';
    ifmNewRecord: LModeStr := 'New Record';
    ifmRewiev: LModeStr := 'Review';
    ifmUpdate: LModeStr := 'Update';
    ifmReadOnly: LModeStr := 'Read Only';
    ifmCopyNewRecord: LModeStr := 'Copy with New Record';
  end;

  GLogger.InfoFmt('Created Input Form: %s %s "%s"', [Self.ClassName, ATable.ClassName, LModeStr]);

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

procedure TfrmInputSimpleDB<TE, TS>.CreateBtnAccept;
begin
  BtnAccept := TButton.Create(PanelFooter);
  BtnAccept.Parent := PanelFooter;
  BtnAccept.AlignWithMargins := True;
  BtnAccept.Padding.Left := 4;
  BtnAccept.Padding.Right := 4;
  BtnAccept.TabOrder := 1;
  BtnAccept.Caption := '&' + 'Kaydet';
  BtnAccept.OnClick := BtnAcceptClick;
  BtnAccept.Align := alRight;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreateBtnClose;
begin
  BtnClose := TButton.Create(PanelFooter);
  BtnClose.Parent := PanelFooter;
  BtnClose.AlignWithMargins := True;
  BtnClose.Padding.Left := 4;
  BtnClose.Padding.Right := 4;
  BtnClose.TabOrder := 2;
  BtnClose.Caption := '&' + 'Kapat';
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreateBtnDelete;
begin
  BtnDelete := TButton.Create(PanelFooter);
  BtnDelete.Parent := PanelFooter;
  BtnDelete.AlignWithMargins := True;
  BtnDelete.Padding.Left := 4;
  BtnDelete.Padding.Right := 4;
  BtnDelete.TabOrder := 3;
  BtnDelete.Caption := '&' + 'Sil';
  BtnDelete.OnClick := BtnDeleteClick;
  BtnDelete.Align := alLeft;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreateBtnSpin;
begin
  BtnSpin := TSpinButton.Create(PanelFooter);
  BtnSpin.Parent := PanelFooter;
  BtnSpin.AlignWithMargins := True;
  BtnSpin.Padding.Left := 4;
  BtnSpin.Padding.Right := 4;
  BtnSpin.TabOrder := 0;
  BtnSpin.OnUpClick := BtnSpinUpClick;
  BtnSpin.OnDownClick := BtnSpinDownClick;
  BtnSpin.Align := alLeft;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreatePageControl;
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.CreatePanelFooter;
begin
  PanelFooter := TPanel.Create(PanelMain);
  PanelFooter.Parent := PanelMain;
  PanelFooter.Align := alBottom;
  PanelFooter.BevelOuter := bvNone;
  PanelFooter.Height := 36;
  PanelFooter.ParentColor := True;
  PanelFooter.Visible := True;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreatePanelMain;
begin
  PanelMain := TPanel.Create(Self);
  PanelMain.Parent := Self;
  PanelMain.Align := alClient;
  PanelMain.BevelOuter := bvNone;
  PanelMain.ParentColor := True;
  PanelMain.Visible := True;
end;

destructor TfrmInputSimpleDB<TE, TS>.Destroy;
begin
  FreeAndNil(Table);
  Service := nil;
  inherited;
end;

procedure TfrmInputSimpleDB<TE, TS>.DoAfterDeleteEvent(Sender: TObject);
begin
  if Assigned(FAfterDeleteEvent) then
    FAfterDeleteEvent(Sender);
end;

procedure TfrmInputSimpleDB<TE, TS>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FormMode = ifmUpdate then
  begin
    if Service.Uow.InTransaction then
    begin
      Service.Uow.Rollback;
    end;
  end;

  Action := caFree;
end;

procedure TfrmInputSimpleDB<TE, TS>.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.FormKeyPress(Sender: TObject; var Key: Char);
var
  LPrevKey: SmallInt;
begin
  case Key of
    Char(VK_ESCAPE):
      begin
        Key := #0;
        Self.Close;
      end;
    Char(VK_RETURN):
      begin
        Key := #0;
        if (Sender is TWinControl) then
        begin
          if  (Sender.ClassType <> TEdit)
          and (Sender.ClassType <> TMemo)
          and (Sender.ClassType <> TCombobox)
          then
          begin
            if GetKeyState(VK_SHIFT) < 0 then LPrevKey := 1 else LPrevKey := 0;
            PostMessage((Sender as TWinControl).Handle, WM_NEXTDLGCTL, LPrevKey, 0);
          end;
        end;
      end;
  else
    inherited;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F4:
      begin
        Key := 0;
        if btnDelete.Visible and btnDelete.Enabled and Self.Visible then
          btnDelete.Click;
      end;
    VK_F5:
      begin
        Key := 0;
        if btnAccept.Visible and btnAccept.Enabled and Self.Visible then
          btnAccept.Click
      end;
    VK_F6:
      begin
        Key := 0;
        if btnClose.Visible and btnClose.Enabled and Self.Visible then
          btnClose.Click;
      end;
    VK_F11:
      begin
        Key := 0;
        Self.AlphaBlend := not Self.AlphaBlend;
        Self.AlphaBlendValue := 50;
      end;
  else
    inherited;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.FormShow(Sender: TObject);
var
  meta: TEntityMeta;
begin
  BtnAccept.Visible := False;
  BtnAccept.Visible := True;

  TMetaProviderManager.SetConnection(Service.Uow.Connection);
  meta := TMetaProviderManager.GetMeta(Table.ClassType);
  BindEntityToControls(Table, Self, meta);


  InitializeInputCase;

  case FormMode of
    ifmNone:
      begin
      end;
    ifmNewRecord:
      begin
        BtnSpin.Visible := False;
        BtnDelete.Visible := False;
        BtnDelete.OnClick := nil;
      end;
    ifmRewiev:
      begin
        RefreshData;
        BtnDelete.Visible := False;
        BtnDelete.OnClick := nil;
      end;
    ifmUpdate:
      begin
        RefreshData;
        BtnDelete.Visible := True;
        BtnDelete.OnClick := BtnDeleteClick;
      end;
    ifmReadOnly:
      begin
        RefreshData;
        BtnDelete.Visible := False;
        BtnDelete.OnClick := nil;
      end;
    ifmCopyNewRecord:
      begin
        BtnSpin.Visible := False;
        BtnDelete.Visible := False;
        BtnDelete.OnClick := nil;
      end;
  end;

  if (Self.FormMode = ifmRewiev)
  or (Self.FormMode = ifmReadOnly)
  then
  begin
    SetControlsDisabledOrEnabled(PgcBase, True);
  end;

  Repaint;
end;

procedure TfrmInputSimpleDB<TE, TS>.InitializeInputCase;
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.PrepareForm;
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
    CreateBtnAccept;
    CreateBtnClose;
    CreateBtnDelete;

  FStatusBase := TStatusBar.Create(Self);
  FStatusBase.Align := alBottom;
  FStatusBase.Parent := Self;
  FStatusBase.OnDrawPanel := StatusBarDrawPanel;
  FStatusBase.Font.Size := 8;
end;

procedure TfrmInputSimpleDB<TE, TS>.RefreshData;
begin
  RefreshDataAuto;
end;

procedure TfrmInputSimpleDB<TE, TS>.RefreshDataAuto;
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  if Assigned(FRefreshGridEvent) then
    FRefreshGridEvent(AFocusSelectedItem);
end;

procedure TfrmInputSimpleDB<TE, TS>.SetControlsDisabledOrEnabled(AContainerControl: TWinControl; ADisable: Boolean);
var
  n1: Integer;
  LPanelContainer: TWinControl;
begin
  LPanelContainer := nil;

  if AContainerControl = nil then
    LPanelContainer := PanelMain
  else
  begin
    if AContainerControl.ClassType = TPanel then
      LPanelContainer := AContainerControl as TPanel
    else if AContainerControl.ClassType = TGroupBox then
      LPanelContainer := AContainerControl as TGroupBox
    else if AContainerControl.ClassType = TPageControl then
      LPanelContainer := AContainerControl as TPageControl
    else if AContainerControl.ClassType = TTabSheet then
      LPanelContainer := AContainerControl as TTabSheet;
  end;

  for n1 := 0 to LPanelContainer.ControlCount-1 do
  begin
    if LPanelContainer.Controls[n1].ClassType = TPanel then
      SetControlsDisabledOrEnabled(LPanelContainer.Controls[n1] as TPanel, ADisable)
    else if LPanelContainer.Controls[n1].ClassType = TGroupBox then
      SetControlsDisabledOrEnabled(LPanelContainer.Controls[n1] as TGroupBox, ADisable)
    else if LPanelContainer.Controls[n1].ClassType = TPageControl then
      SetControlsDisabledOrEnabled(LPanelContainer.Controls[n1] as TPageControl, ADisable)
    else if LPanelContainer.Controls[n1].ClassType = TTabSheet then
      SetControlsDisabledOrEnabled(LPanelContainer.Controls[n1] as TTabSheet, ADisable)
    else if LPanelContainer.Controls[n1].ClassType = TEdit then
      TEdit(LPanelContainer.Controls[n1]).ReadOnly := ADisable
    else if LPanelContainer.Controls[n1].ClassType = TComboBox then
      TComboBox(LPanelContainer.Controls[n1]).Enabled := (ADisable = False)
    else if LPanelContainer.Controls[n1].ClassType = TMemo then
      TMemo(LPanelContainer.Controls[n1]).ReadOnly := ADisable
    else if LPanelContainer.Controls[n1].ClassType = TCheckBox then
      TCheckBox(LPanelContainer.Controls[n1]).Enabled := (ADisable = False)
    else if LPanelContainer.Controls[n1].ClassType = TRadioGroup then
      TRadioGroup(LPanelContainer.Controls[n1]).Enabled := (ADisable = False)
    else if LPanelContainer.Controls[n1].ClassType = TRadioButton then
      TRadioButton(LPanelContainer.Controls[n1]).Enabled := (ADisable = False);
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.SetService(const Value: TS);
begin
  FService := Value;
end;

procedure TfrmInputSimpleDB<TE, TS>.SetTable(const Value: TE);
begin
  FTable := Value;
end;

procedure TfrmInputSimpleDB<TE, TS>.StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
begin
//
end;

procedure TfrmInputSimpleDB<TE, TS>.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
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

function TfrmInputSimpleDB<TE, TS>.ValidateInput(AContainerControl: TWinControl): Boolean;
var
  nIndex, nIndex2, nProcessCount: Integer;
  LPanelContainer: TWinControl;
  LControlName: string;
begin
  nProcessCount := 0;
  nProcessCount := nProcessCount + 1;
  Result := true;
  LPanelContainer := nil;

  if AContainerControl = nil then
    LPanelContainer := PanelMain
  else begin
    if AContainerControl.ClassType = TPanel then
      LPanelContainer := AContainerControl as TPanel
    else if AContainerControl.ClassType = TGroupBox then
      LPanelContainer := AContainerControl as TGroupBox
    else if AContainerControl.ClassType = TPageControl then
      LPanelContainer := AContainerControl as TPageControl
    else if AContainerControl.ClassType = TTabSheet then
      LPanelContainer := AContainerControl as TTabSheet;
  end;

  if (FormMode=ifmUpdate) or (FormMode=ifmNewRecord) or (FormMode=ifmCopyNewRecord) then begin
    for nIndex := 0 to LPanelContainer.ControlCount -1 do begin
      if LPanelContainer.Controls[nIndex].ClassType = TPanel then
        Result := ValidateSubControls(LPanelContainer.Controls[nIndex] as TPanel, LControlName)
      else if LPanelContainer.Controls[nIndex].ClassType = TGroupBox then
        Result := ValidateSubControls(LPanelContainer.Controls[nIndex] as TGroupBox, LControlName)
      else if LPanelContainer.Controls[nIndex].ClassType = TPageControl then
      begin
        for nIndex2 := 0 to (LPanelContainer.Controls[nIndex] as TPageControl).PageCount-1 do
        begin
          Result := ValidateSubControls((LPanelContainer.Controls[nIndex] as TPageControl).Pages[nIndex2], LControlName);
          if not Result then
            Break;
        end;
      end
      else if LPanelContainer.Controls[nIndex].ClassType = TTabSheet then
        Result := ValidateSubControls(LPanelContainer.Controls[nIndex] as TTabSheet, LControlName)
      else if LPanelContainer.Controls[nIndex].ClassType = TEdit then
        Result := ValidateSubControls(TEdit(LPanelContainer.Controls[nIndex]), LControlName)
      else if LPanelContainer.Controls[nIndex].ClassType = TMemo then
        Result := ValidateSubControls(TMemo(LPanelContainer.Controls[nIndex]), LControlName)
      else if LPanelContainer.Controls[nIndex].ClassType = TCombobox then
        Result := ValidateSubControls(TCombobox(LPanelContainer.Controls[nIndex]), LControlName);

      if not Result then
        Break;
    end;
  end;

  if (nProcessCount = 1) then
  begin
    Repaint;
    if (not Result) then
      raise Exception.Create('Zorunlu alanlar boş olamaz. Kırmızı renkli girişler zorunludur.' + AddLBs(3) + LControlName);
  end;
end;

function TfrmInputSimpleDB<TE, TS>.ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
var
  n1: Integer;
begin
    Result := True;
    if Sender.Visible then
    begin
      AControlName := Sender.Name;
      if (Sender.ClassType = TEdit)
      or (Sender.ClassType = TMemo)
      or (Sender.ClassType = TCombobox) then begin
        if Sender.ClassType = TEdit then begin
          if (TEdit(Sender).thsRequiredData) then
            if (TEdit(Sender).Text = '') then begin
              Result := False;
              TEdit(Sender).Repaint;
            end;
        end else if Sender.ClassType = TMemo then begin
          if (TMemo(Sender).thsRequiredData) then
            if (TMemo(Sender).Text = '') then begin
              Result := False;
              TMemo(Sender).Repaint;
            end;
        end else if Sender.ClassType = TCombobox then begin
          if (TCombobox(Sender).thsRequiredData) then
            if (TCombobox(Sender).Text  = '') then begin
              Result := False;
              TCombobox(Sender).Repaint;
            end;
        end;
      end else begin
        for n1 := 0 to Sender.ControlCount -1 do begin
          AControlName := Sender.Controls[n1].Name;
          if Sender.Controls[n1].ClassType = TEdit then begin
            if (TEdit(Sender.Controls[n1]).thsRequiredData) then
              if (TEdit(Sender.Controls[n1]).Text = '') then begin
                Result := False;
                TEdit(Sender.Controls[n1]).Repaint;
                Break;
              end;
          end else if Sender.Controls[n1].ClassType = TMemo then begin
            if (TMemo(Sender.Controls[n1]).thsRequiredData) then
              if (TMemo(Sender.Controls[n1]).Text = '') then begin
                Result := False;
                TMemo(Sender.Controls[n1]).Repaint;
                Break;
              end;
          end else if Sender.Controls[n1].ClassType = TCombobox then begin
            if (TCombobox(Sender.Controls[n1]).thsRequiredData) then
              if (TCombobox(Sender.Controls[n1]).Text  = '') then begin
                Result := False;
                TCombobox(Sender.Controls[n1]).Repaint;
                Break;
              end;
          end;
        end;
      end;
    end;
end;

end.
