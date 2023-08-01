unit ufrmBase;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, System.Math, System.Rtti, Vcl.Forms, Vcl.Samples.Spin,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Dialogs,
  Vcl.ImgList, Vcl.Graphics, Vcl.Menus, Vcl.ActnList, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Combobox, Ths.Helper.Memo,
  udm, Ths.Database.Table;

const
  WM_AFTER_SHOW = WM_USER + 300; // custom message
  WM_AFTER_CREATE = WM_USER + 301; // custom message

const
  COLUMN_GRID_OBJECT = 0;

type
  TInputFormMode = (ifmNone, ifmNewRecord, ifmRewiev, ifmUpdate, ifmReadOnly, ifmCopyNewRecord);
  TInputFormViewMode = (ivmNormal, ivmSort);
  TFormDecimalMode = (fomBuying, fomSale, fomStock, fomNormal);

  //forward declaration
  TfrmConfirmation = class
  end;

type
  TfrmBase = class(TForm)
    AppEvntsBase: TApplicationEvents;
    dlgPntBase: TPrintDialog;
    pnlBottom: TPanel;
    pnlMain: TPanel;
    btnSpin: TSpinButton;
    btnAccept: TButton;
    btnClose: TButton;
    btnDelete: TButton;
    stbBase: TStatusBar;
    procedure btnAcceptClick(Sender: TObject);virtual;
    procedure btnDeleteClick(Sender: TObject);virtual;
    procedure btnCloseClick(Sender: TObject);virtual;
    procedure btnSpinUpClick(Sender: TObject);virtual;
    procedure btnSpinDownClick(Sender: TObject);virtual;
    procedure FormDestroy(Sender: TObject);virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);virtual;
    procedure FormKeyPress(Sender: TObject; var Key: Char);virtual;
    procedure FormCreate(Sender: TObject); virtual;
    procedure FormResize(Sender: TObject); virtual;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);virtual;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormPaint(Sender: TObject); virtual;

    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
    procedure WmAfterCreate(var Msg: TMessage); message WM_AFTER_CREATE;
    procedure stbBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect); virtual;

    procedure scaleByDPI(AParent: TWinControl);
  private
    FTable: TTable;
    FFormMode: TInputFormMode;
    FFormViewMode: TInputFormViewMode;
    FFormDecimalMode: TFormDecimalMode;
    FWithCommitTransaction: Boolean;
    FWithRollbackTransaction: Boolean;
    FDefaultSelectFilter: string;
    FAcceptBtnDoAction: Boolean;

    FParentForm: TForm;

    FMsgFormClose: string;
    FMsgTitleFormClose: string;

    FfrmConfirmation: TfrmConfirmation;

    FmrBtnAccept: Integer;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil):boolean;virtual;
    procedure fillComboBoxData(var pControl: TCombobox;
        pTable: TTable; const pFieldName: TArray<string>; pFilter: string;
        pWithObject: Boolean = False; pAddEmptyOne: Boolean = False;
        pFieldSeperate: string = ' ');
  public
    TempMsg: string;
    property Table: TTable read FTable write FTable;
    property FormMode: TInputFormMode read FFormMode write FFormMode;
    property FormViewMode: TInputFormViewMode read FFormViewMode write FFormViewMode;
    property FormOndalikMod: TFormDecimalMode read FFormDecimalMode write FFormDecimalMode;
    property WithCommitTransaction: Boolean read FWithCommitTransaction write FWithCommitTransaction;
    property WithRollbackTransaction: Boolean read FWithRollbackTransaction write FWithRollbackTransaction;
    property DefaultSelectFilter: string read FDefaultSelectFilter write FDefaultSelectFilter;
    property ParentForm: TForm read FParentForm write FParentForm;
    property MesajFormClose: string read FMsgFormClose write FMsgFormClose;
    property MesajTitleFormClose: string read FMsgTitleFormClose write FMsgTitleFormClose;
    property frmConfirmation: TfrmConfirmation read FfrmConfirmation write FfrmConfirmation;
    property AcceptBtnDoAction: Boolean read FAcceptBtnDoAction write FAcceptBtnDoAction;

    property mrBtnAccept: Integer read FmrBtnAccept write FmrBtnAccept;

    constructor Create(
      AOwner: TComponent;
      AParentForm: TForm = nil;
      ATable: TTable = nil;
      AFormMode: TInputFormMode = ifmNone;
      AFormDecimalMode: TFormDecimalMode = fomNormal;
      AFormViewMode: TInputFormViewMode = ivmNormal;
      AAcceptBtnDoAction: Boolean = True);reintroduce;overload;

    function FocusedFirstControl(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean; virtual;
    procedure RepaintThsEditComboForHelperProcessSing(vPanelGroupboxPagecontrolTabsheet: TWinControl);

    procedure SetButtonImages32(pButton: TButton; pImageNo: Integer);
    procedure SetButtonImages16(pButton: TButton; pImageNo: Integer);
    procedure SetActionImages(pAct: TAction; pImageNo: Integer);
    procedure SetMNIImages(pMni: TMenuItem; pImageNo: Integer);

    procedure CreateLangGuiContentFormforFormCaption();
  end;

implementation

uses
  Ths.Constants,
  Ths.Globals,
  ufrmSysLisanGuiIcerik,
  Ths.Database.Table.SysLisanGuiIcerikler;

{$R *.dfm}

constructor TfrmBase.Create(
  AOwner: TComponent;
  AParentForm: TForm;
  ATable: TTable;
  AFormMode: TInputFormMode;
  AFormDecimalMode: TFormDecimalMode;
  AFormViewMode: TInputFormViewMode;
  AAcceptBtnDoAction: Boolean);
begin
  FWithCommitTransaction := True;
  FWithRollbackTransaction := True;

  FParentForm := AParentForm;
  FFormMode := AFormMode;
  FFormViewMode := AFormViewMode;
  FFormDecimalMode := AFormDecimalMode;
  FTable := ATable;
  FAcceptBtnDoAction := AAcceptBtnDoAction;

  inherited Create(AOwner);
end;

procedure TfrmBase.CreateLangGuiContentFormforFormCaption;
var
  LLangGuiContent: TSysLisanGuiIcerik;
begin
  LLangGuiContent := TSysLisanGuiIcerik.Create(GDataBase);

  LLangGuiContent.Lisan.Value := AppLanguage;
  LLangGuiContent.Kod.Value := Self.Name;
  LLangGuiContent.IcerikTipi.Value := LngFormCaption;
  LLangGuiContent.TabloAdi.Value := '';
  LLangGuiContent.Deger.Value := Self.Caption;

  TfrmSysLisanGuiIcerik.Create(Self, nil, LLangGuiContent, ifmCopyNewRecord, fomNormal, ivmSort).ShowModal;
  Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);
end;

procedure TfrmBase.btnAcceptClick(Sender: TObject);
begin
//
end;

procedure TfrmBase.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmBase.btnDeleteClick(Sender: TObject);
begin
//
end;

procedure TfrmBase.fillComboBoxData(var pControl: TCombobox;
  pTable: TTable; const pFieldName: TArray<string>; pFilter: string;
  pWithObject: Boolean; pAddEmptyOne: Boolean;
  pFieldSeperate: string);
var
  n1, n2, n3: Integer;
  LValue: Variant;
begin
  pTable.SelectToList(pFilter, False, False);
  pControl.Clear;
  pControl.Items.BeginUpdate;
  pControl.thsHasContainCustomVal := not pWithObject;
  try
    if pAddEmptyOne then
      pControl.Items.Add('');


    for n1 := 0 to pTable.List.Count-1 do
    begin
      for n2 := 0 to Length(pFieldName)-1 do
      begin
        LValue := '';

        for n3 := 0 to Length(TTable(pTable.List[n1]).Fields)-1 do
          if TTable(pTable.List[n1]).Fields[n3].FieldName = pFieldName[n2] then
          begin
            if (TTable(pTable.List[n1]).Fields[n3].DataType = ftString)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftWideString)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftMemo)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftWideMemo)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftFixedChar)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftFixedWideChar)
            then
              LValue := LValue + ' ' + TTable(pTable.List[n1]).Fields[n3].Value
            else
            if (TTable(pTable.List[n1]).Fields[n3].DataType = ftFloat)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftBCD)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftFMTBcd)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftWord)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftSmallint)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftInteger)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftLargeint)
            then
              LValue := LValue + ' ' + VarToStr(TTable(pTable.List[n1]).Fields[n3].Value)
            else
            if (TTable(pTable.List[n1]).Fields[n3].DataType = ftDate)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftDateTime)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftTime)
            or (TTable(pTable.List[n1]).Fields[n3].DataType = ftTimeStamp)
            then
              LValue := LValue + ' ' + VarToStr(TTable(pTable.List[n1]).Fields[n3].Value)
          end;
      end;

      if pWithObject then
        pControl.AddItem(Trim(LValue), TTable(pTable.List[n1]))
      else
        pControl.Items.Add(Trim(LValue));
    end;
  finally
    if pControl.Items.Count > 0 then
      pControl.ItemIndex := 0;

    pControl.Items.EndUpdate;
  end;
end;

function TfrmBase.FocusedFirstControl(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
var
  nIndex, nProcessCount: Integer;
  PanelContainer: TWinControl;
begin
  nProcessCount := 0;
  nProcessCount := nProcessCount + 1;
  PanelContainer := nil;

  Result := False;
  if nProcessCount = 1 then
    Result := False;

  if panel_groupbox_pagecontrol_tabsheet = nil then
    PanelContainer := pnlMain
  else
  begin
    if panel_groupbox_pagecontrol_tabsheet.ClassType = TPanel then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TPanel
    else if panel_groupbox_pagecontrol_tabsheet.ClassType = TGroupBox then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TGroupBox
    else if panel_groupbox_pagecontrol_tabsheet.ClassType = TPageControl then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TPageControl
    else if panel_groupbox_pagecontrol_tabsheet.ClassType = TTabSheet then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TTabSheet;
  end;

  for nIndex := 0 to PanelContainer.ControlCount-1 do
  begin
    if Result then
      Exit;

    if PanelContainer.Controls[nIndex].ClassType = TPanel then
      Result := FocusedFirstControl(PanelContainer.Controls[nIndex] as TPanel)
    else if PanelContainer.Controls[nIndex].ClassType = TGroupBox then
      Result := FocusedFirstControl(PanelContainer.Controls[nIndex] as TGroupBox)
    else if PanelContainer.Controls[nIndex].ClassType = TPageControl then
      Result := FocusedFirstControl(PanelContainer.Controls[nIndex] as TPageControl)
    else if PanelContainer.Controls[nIndex].ClassType = TTabSheet then
    begin
      if PanelContainer is TPageControl then
      begin
        if TPageControl(PanelContainer).ActivePageIndex = TTabSheet(PanelContainer.Controls[nIndex]).TabIndex then
          Result := FocusedFirstControl(PanelContainer.Controls[nIndex] as TTabSheet)
      end
      else
        Result := FocusedFirstControl(PanelContainer.Controls[nIndex] as TTabSheet)
    end
    else
    if (TControl(PanelContainer.Controls[nIndex]).ClassType = TCheckBox)
    or (TControl(PanelContainer.Controls[nIndex]).ClassType = TRadioGroup)
    or (TControl(PanelContainer.Controls[nIndex]).ClassType = TRadioButton)
    or (TControl(PanelContainer.Controls[nIndex]).ClassType = TEdit)
    or (TControl(PanelContainer.Controls[nIndex]).ClassType = TComboBox)
    or (TControl(PanelContainer.Controls[nIndex]).ClassType = TMemo)
    then
    begin

      if  Self.Visible
      and TControl(TControl(PanelContainer.Controls[nIndex]).Parent).Visible
      and TControl(PanelContainer.Controls[nIndex]).Enabled
      and TControl(PanelContainer.Controls[nIndex]).Visible
      then
      begin
        if  TWinControl(PanelContainer.Controls[nIndex]).TabStop
        and TWinControl(PanelContainer.Controls[nIndex]).Visible
        and TWinControl(PanelContainer.Controls[nIndex]).Enabled
        then
        begin
          TWinControl(PanelContainer.Controls[nIndex]).SetFocus;
          Result := True;
          break;
        end;
      end;
    end;
  end;
end;

procedure TfrmBase.RepaintThsEditComboForHelperProcessSing(vPanelGroupboxPagecontrolTabsheet: TWinControl);
var
  nIndex: Integer;
  PanelContainer: TWinControl;
begin
  PanelContainer := nil;

  if vPanelGroupboxPagecontrolTabsheet = nil then
    PanelContainer := pnlMain
  else
  begin
    if vPanelGroupboxPagecontrolTabsheet.ClassType = TPanel then
      PanelContainer := vPanelGroupboxPagecontrolTabsheet as TPanel
    else if vPanelGroupboxPagecontrolTabsheet.ClassType = TGroupBox then
      PanelContainer := vPanelGroupboxPagecontrolTabsheet as TGroupBox
    else if vPanelGroupboxPagecontrolTabsheet.ClassType = TPageControl then
      PanelContainer := vPanelGroupboxPagecontrolTabsheet as TPageControl
    else if vPanelGroupboxPagecontrolTabsheet.ClassType = TTabSheet then
      PanelContainer := vPanelGroupboxPagecontrolTabsheet as TTabSheet;
  end;

  for nIndex := 0 to PanelContainer.ControlCount-1 do
  begin
    if PanelContainer.Controls[nIndex].ClassType = TPanel then
      RepaintThsEditComboForHelperProcessSing(PanelContainer.Controls[nIndex] as TPanel)
    else if PanelContainer.Controls[nIndex].ClassType = TGroupBox then
      RepaintThsEditComboForHelperProcessSing(PanelContainer.Controls[nIndex] as TGroupBox)
    else if PanelContainer.Controls[nIndex].ClassType = TPageControl then
      RepaintThsEditComboForHelperProcessSing(PanelContainer.Controls[nIndex] as TPageControl)
    else if PanelContainer.Controls[nIndex].ClassType = TTabSheet then
    begin
      if PanelContainer is TPageControl then
      begin
        if TPageControl(PanelContainer).ActivePageIndex = TTabSheet(PanelContainer.Controls[nIndex]).TabIndex then
          RepaintThsEditComboForHelperProcessSing(PanelContainer.Controls[nIndex] as TTabSheet)
      end
      else
        RepaintThsEditComboForHelperProcessSing(PanelContainer.Controls[nIndex] as TTabSheet)
    end
    else
    if (TControl(PanelContainer.Controls[nIndex]).ClassType = TEdit)
    or (TControl(PanelContainer.Controls[nIndex]).ClassType = TCombobox)
    then
    begin
      TWinControl(PanelContainer.Controls[nIndex]).Repaint;
    end;
  end;
end;

procedure TfrmBase.scaleByDPI(AParent: TWinControl);
var
  n1: Integer;
begin
  for n1 := 0 to AParent.ControlCount-1 do
  begin
    if AParent.Controls[n1] is TPageControl then
      scaleByDPI(TPageControl(AParent.Controls[n1]))
    else if AParent.Controls[n1] is TTabSheet then
      scaleByDPI(TTabSheet(AParent.Controls[n1]))
    else if AParent.Controls[n1] is TPanel then
      scaleByDPI(TPanel(AParent.Controls[n1]))
    else if AParent.Controls[n1] is TLabel then
//      TLabel(AParent.Controls[n1]).Font.Size := TFunctions.scaleBySystemDPI(TLabel(AParent.Controls[n1]).Font.Size);
  end;
end;

procedure TfrmBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  Self.Release;
end;

procedure TfrmBase.FormCreate(Sender: TObject);
begin
  if Table <> nil then
  begin
    if Table.Id.AsInteger > 0 then
      FDefaultSelectFilter := ' and ' + Table.Id.QryName + '=' + Table.Id.AsString;
  end;

  frmConfirmation := TfrmConfirmation.Create;

  btnSpin.OnDownClick := btnSpinDownClick;
  btnSpin.OnUpClick   := btnSpinUpClick;
  btnDelete.OnClick := btnDeleteClick;
  btnAccept.OnClick := btnAcceptClick;
  btnClose.OnClick := btnCloseClick;

  btnSpin.Visible := False;
  btnDelete.Visible := False;
  btnAccept.Visible := False;

  stbBase.Visible := False;
  //statusbar manual draw mode
//  for n1 := 0 to stbBase.Panels.Count - 1 do
//    stbBase.Panels.Items[n1].Style := psOwnerDraw;

  PostMessage(self.Handle, WM_AFTER_CREATE, 0, 0);
end;

procedure TfrmBase.FormDestroy(Sender: TObject);
begin
  if AcceptBtnDoAction AND Assigned(Table) and (Table <> nil) {and not (Self.ClassParent = TfrmBaseInputDB)} then
    Table.Destroy;

  frmConfirmation.Free;

  inherited;
end;

procedure TfrmBase.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
//  frmMain.RefreshStatusBar;
end;

procedure TfrmBase.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
  begin
    Key := #0;
    btnCloseClick(btnClose);
  end
  else
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    if (Sender is TWinControl) then
    begin
      if (Sender.ClassType <> TEdit)
      and (Sender.ClassType <> TMemo)
      and (Sender.ClassType <> TCombobox)
      then
       if HiWord(GetKeyState(VK_SHIFT)) <> 0 then
          PostMessage((Sender as TWinControl).Handle, WM_NEXTDLGCTL, 1, 0)
       else
          PostMessage((Sender as TWinControl).Handle, WM_NEXTDLGCTL, 0, 0);
    end;
  end
  else
    inherited;
//  frmMain.RefreshStatusBar;
end;

procedure TfrmBase.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  frmMain.RefreshStatusBar;

  if Key = VK_F4 then
  begin
    if btnDelete.Visible and btnDelete.Enabled and Self.Visible then
      btnDelete.Click;
  end
  else if Key = VK_F5 then
  begin
    if btnAccept.Visible and btnAccept.Enabled and Self.Visible then
      btnAccept.Click
  end
  else if Key = VK_F6 then
  begin
    if btnClose.Visible and btnClose.Enabled and Self.Visible then
      btnClose.Click;
  end
  else if Key = VK_F11 then
  begin
    Self.AlphaBlend := not Self.AlphaBlend;
    Self.AlphaBlendValue := 50;
  end
  ;
end;

procedure TfrmBase.FormPaint(Sender: TObject);
begin
  inherited;
  RepaintThsEditComboForHelperProcessSing(pnlMain);
end;

procedure TfrmBase.FormResize(Sender: TObject);
begin
//
end;

procedure TfrmBase.FormShow(Sender: TObject);
begin
  inherited;
  FocusedFirstControl(pnlMain);

//  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0);
end;

procedure TfrmBase.SetActionImages(pAct: TAction; pImageNo: Integer);
begin
  pAct.ImageIndex := pImageNo;
end;

procedure TfrmBase.SetButtonImages16(pButton: TButton; pImageNo: Integer);
begin
  pButton.Images := dm.il16;
  pButton.HotImageIndex := pImageNo;
  pButton.ImageIndex := pImageNo;
end;

procedure TfrmBase.SetButtonImages32(pButton: TButton; pImageNo: Integer);
begin
  pButton.Images := dm.il32;
  pButton.HotImageIndex := pImageNo;
  pButton.ImageIndex := pImageNo;
end;

procedure TfrmBase.SetMNIImages(pMni: TMenuItem; pImageNo: Integer);
begin
  pMni.ImageIndex := pImageNo;
end;

procedure TfrmBase.stbBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
  vIco: Integer;
begin
  stbBase.Canvas.Font.Size := 7;
  stbBase.Canvas.Font.Name := DefaultFontName;
  stbBase.Canvas.Font.Style := [fsBold];

  stbBase.Canvas.TextRect(Rect,
    Rect.Left + dm.il16.Width + 4,
    Rect.Top + (stbBase.Height-stbBase.Canvas.TextHeight(Panel.Text)) div 2 - 2,
    Panel.Text);

  vIco := -1;
  case Panel.Index of
    STATUS_SQL_SERVER: vIco := IMG_DATABASE;
    STATUS_DATE: vIco := IMG_CALENDAR;
//    STATUS_EX_RATE_USD: vIco := IMG_SEARCH;
//    STATUS_EX_RATE_EUR: vIco := IMG_SEARCH;
    STATUS_USERNAME: vIco := IMG_USER_HE;
    STATUS_KEY_F4: vIco := IMG_FAVORITE;
    STATUS_KEY_F5: vIco := IMG_FAVORITE;
    STATUS_KEY_F6: vIco := IMG_FAVORITE;
    STATUS_KEY_F7: vIco := IMG_FAVORITE;
    STATUS_KEY_F11: vIco := IMG_FAVORITE;
  end;

  if vIco > -1 then
  begin
    dm.il16.Draw(StatusBar.Canvas, Rect.Left, Rect.Top, vIco);
    Panel.Width := stbBase.Canvas.TextWidth(Panel.Text)+ dm.il16.Width + 16;
  end;
end;

procedure TfrmBase.btnSpinDownClick(Sender: TObject);
begin
//
end;

procedure TfrmBase.btnSpinUpClick(Sender: TObject);
begin
//
end;

function TfrmBase.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): boolean;
var
  nIndex, nIndex2, nProcessCount: Integer;
  PanelContainer: TWinControl;
  LControlName: string;

  function ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
  var
    nIndex: Integer;
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
        for nIndex := 0 to Sender.ControlCount -1 do begin
          AControlName := Sender.Controls[nIndex].Name;
          if Sender.Controls[nIndex].ClassType = TEdit then begin
            if (TEdit(Sender.Controls[nIndex]).thsRequiredData) then
              if (TEdit(Sender.Controls[nIndex]).Text = '') then begin
                Result := False;
                TEdit(Sender.Controls[nIndex]).Repaint;
                Break;
              end;
          end else if Sender.Controls[nIndex].ClassType = TMemo then begin
            if (TMemo(Sender.Controls[nIndex]).thsRequiredData) then
              if (TMemo(Sender.Controls[nIndex]).Text = '') then begin
                Result := False;
                TMemo(Sender.Controls[nIndex]).Repaint;
                Break;
              end;
          end else if Sender.Controls[nIndex].ClassType = TCombobox then begin
            if (TCombobox(Sender.Controls[nIndex]).thsRequiredData) then
              if (TCombobox(Sender.Controls[nIndex]).Text  = '') then begin
                Result := False;
                TCombobox(Sender.Controls[nIndex]).Repaint;
                Break;
              end;
          end;
        end;
      end;
    end;
  end;

begin
  nProcessCount := 0;
  nProcessCount := nProcessCount + 1;
  Result := true;
  PanelContainer := nil;

  if panel_groupbox_pagecontrol_tabsheet = nil then
    PanelContainer := pnlMain
  else begin
    if panel_groupbox_pagecontrol_tabsheet.ClassType = TPanel then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TPanel
    else if panel_groupbox_pagecontrol_tabsheet.ClassType = TGroupBox then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TGroupBox
    else if panel_groupbox_pagecontrol_tabsheet.ClassType = TPageControl then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TPageControl
    else if panel_groupbox_pagecontrol_tabsheet.ClassType = TTabSheet then
      PanelContainer := panel_groupbox_pagecontrol_tabsheet as TTabSheet;
  end;

  if (FormMode=ifmUpdate) or (FormMode=ifmNewRecord) or (FormMode=ifmCopyNewRecord) then begin
    for nIndex := 0 to PanelContainer.ControlCount -1 do begin
      if PanelContainer.Controls[nIndex].ClassType = TPanel then
        Result := ValidateSubControls(PanelContainer.Controls[nIndex] as TPanel, LControlName)
      else if PanelContainer.Controls[nIndex].ClassType = TGroupBox then
        Result := ValidateSubControls(PanelContainer.Controls[nIndex] as TGroupBox, LControlName)
      else if PanelContainer.Controls[nIndex].ClassType = TPageControl then
      begin
        for nIndex2 := 0 to (PanelContainer.Controls[nIndex] as TPageControl).PageCount-1 do
        begin
          Result := ValidateSubControls((PanelContainer.Controls[nIndex] as TPageControl).Pages[nIndex2], LControlName);
          if not Result then
            Break;
        end;
      end
      else if PanelContainer.Controls[nIndex].ClassType = TTabSheet then
        Result := ValidateSubControls(PanelContainer.Controls[nIndex] as TTabSheet, LControlName)
      else if PanelContainer.Controls[nIndex].ClassType = TEdit then
        Result := ValidateSubControls(TEdit(PanelContainer.Controls[nIndex]), LControlName)
      else if PanelContainer.Controls[nIndex].ClassType = TMemo then
        Result := ValidateSubControls(TMemo(PanelContainer.Controls[nIndex]), LControlName)
      else if PanelContainer.Controls[nIndex].ClassType = TCombobox then
        Result := ValidateSubControls(TCombobox(PanelContainer.Controls[nIndex]), LControlName);

      if not Result then
        Break;
    end;
  end;

  if (nProcessCount = 1) then
  begin
    Repaint;
    if (not Result) then
      raise Exception.Create('Zorunlu alanlar boþ olamaz. Kýrmýzý renkli giriþler zorunludur.' + AddLBs(3) + LControlName);
  end;
end;

procedure TfrmBase.WmAfterShow(var Msg: TMessage);
begin
  scaleByDPI(pnlMain);
end;

procedure TfrmBase.WmAfterCreate(var Msg: TMessage);
begin
//
end;

end.
