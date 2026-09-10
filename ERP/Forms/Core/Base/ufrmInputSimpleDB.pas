unit ufrmInputSimpleDB;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Math, System.SysUtils,
  System.StrUtils, System.Rtti, System.Types, System.TypInfo,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB, System.Generics.Collections,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  Ths.DialogHelper, Ths.Globals, MetaProvider, Ths.Language.Cache,
  Entity, Service, SharedFormTypes, ufrmBase, LocalizationManager;

type
  TTranslationMap = TDictionary<string, string>;

  TfrmInputSimpleDB<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TForm, ILocalizable)
  private
    FService: TS;
    FTable: TE;

    FFormMode: TInputFormMode;
    FFormViewMode: TInputFormViewMode;
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

    procedure BuildTranslationControls(AContainer: TWinControl; const AFieldName, ALabel: string; ARefLabel: TLabel = nil);
    procedure UpdateTranslationLabels(AContainer: TWinControl; const AFieldName, ALabel: string);
    function CollectTranslationValues(AContainer: TWinControl; const AFieldName: string = ''): TTranslationMap;
    procedure FillTranslationControls(AContainer: TWinControl; AValues: TTranslationMap);
  public
    property Service: TS read FService write SetService;
    property Table: TE read FTable write SetTable;

    property FormMode: TInputFormMode read FFormMode write FFormMode;
    property FormViewMode: TInputFormViewMode read FFormViewMode write FFormViewMode;
    property DefaultSelectFilter: string read FDefaultSelectFilter write FDefaultSelectFilter;

    property PanelMain: TPanel read FPanelMain write FPanelMain;
    property PanelFooter: TPanel read FPanelFooter write FPanelFooter;
    property StatusBase: TStatusBar read FStatusBase write FStatusBase;

    property PgcBase: TPageControl read FPgcBase write FPgcBase;
    property BtnSpin: TSpinButton read FBtnSpin write FBtnSpin;
    property BtnAccept: TButton read FBtnAccept write FBtnAccept;
    property BtnClose: TButton read FBtnClose write FBtnClose;
    property BtnDelete: TButton read FBtnDelete write FBtnDelete;

    property AfterDeleteEvent: TNotifyEvent read FAfterDeleteEvent write FAfterDeleteEvent;

    constructor Create(
      AOwner: TComponent; AService: TS; ATable: TE;
      AFormMode: TInputFormMode;
      ARefreshGridEvent: TAfterCrudRefreshGrid;
      AFormViewMode: TInputFormViewMode = ivmNormal); reintroduce; overload;
    destructor Destroy; override;

    //***form***
    procedure FormCreate(Sender: TObject); virtual;
    procedure FormDestroy(Sender: TObject); virtual;
    procedure FormShow(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure ApplyLocalization; virtual;
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
  end;

implementation

uses Logger, EntityAttributes;

procedure TfrmInputSimpleDB<TE, TS>.BindEntityToControls(AEntity: TObject; AForm: TForm; Meta: TEntityMeta);
var
  propMeta: TPropertyMeta;
  ctrl: TControl;
  lblCtrl: TComponent;
begin
  if Meta = nil then Exit;

  for propMeta in Meta.Properties.Values do
  begin
    ctrl := AForm.FindComponent('edt' + propMeta.ColumnName) as TControl;
    if not Assigned(ctrl) then
      ctrl := AForm.FindComponent('edt' + propMeta.Name) as TControl;

    lblCtrl := AForm.FindComponent('lbl' + propMeta.ColumnName);
    if not Assigned(lblCtrl) then
      lblCtrl := AForm.FindComponent('lbl' + propMeta.Name);

    if Assigned(lblCtrl) and (lblCtrl is TLabel) then
      (lblCtrl as TLabel).Caption := propMeta.DisplayLabel;

    if Assigned(ctrl) and (ctrl is TEdit) then
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

      if propMeta.Required then
        (ctrl as Ths.Helper.Edit.TEdit).thsRequiredData := True;

      if ctrl is Ths.Helper.Edit.TEdit then
      begin
        case propMeta.PropertyType.TypeKind of
          tkInteger, tkInt64:
            Ths.Helper.Edit.TEdit(ctrl).thsInputDataType := itInteger;
          tkFloat:
            begin
              if SameText(propMeta.PropertyType.Name, 'TDate') then
                Ths.Helper.Edit.TEdit(ctrl).thsInputDataType := itDate
              else if SameText(propMeta.PropertyType.Name, 'TTime') then
                Ths.Helper.Edit.TEdit(ctrl).thsInputDataType := itTime
              else
                Ths.Helper.Edit.TEdit(ctrl).thsInputDataType := itFloat;
            end;
          tkUString, tkString, tkLString, tkWString:
            Ths.Helper.Edit.TEdit(ctrl).thsInputDataType := itString;
        end;
      end;
    end;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BuildTranslationControls(AContainer : TWinControl;
  const AFieldName, ALabel: string; ARefLabel  : TLabel = nil);
var
  LLocales  : TArray<TLanguageInfo>;
  LInfo     : TLanguageInfo;
  LLbl      : TLabel;
  LEdit     : Ths.Helper.Edit.TEdit;
  LTop      : Integer;
  LLblRight : Integer;
  LPrefix   : string;
  i         : Integer;
  LToDelete : TList<TComponent>;
  LComp     : TComponent;
begin
  if not TLanguageCache.IsLoaded then Exit;

  LPrefix := 'edt' + AFieldName + '_';

  LToDelete := TList<TComponent>.Create;
  try
    for i := AContainer.ComponentCount - 1 downto 0 do
    begin
      LComp := AContainer.Components[i];
      if StartsText('edt' + AFieldName + '_', LComp.Name)
      or StartsText('lbl' + AFieldName + '_', LComp.Name)
      then
        LToDelete.Add(LComp);
    end;
    for LComp in LToDelete do
      LComp.Free;
  finally
    LToDelete.Free;
  end;

  LLocales := TLanguageCache.GetLocales;
  LTop     := 4;

  if Assigned(ARefLabel) then
    LLblRight := (ARefLabel.Left - AContainer.Left) + ARefLabel.Width
  else
    LLblRight := 168;


  for LInfo in LLocales do
  begin
    LLbl              := TLabel.Create(AContainer);
    LLbl.Parent       := AContainer;
    LLbl.Name         := 'lbl' + AFieldName + '_' + StringReplace(LInfo.Locale, '-', '_', [rfReplaceAll]);
    LLbl.Caption      := ALabel + ' (' + LInfo.Locale + ')';

    LLbl.Font.Size    := 8;
    LLbl.Font.Style   := [fsBold];
    LLbl.Alignment    := taRightJustify;

    LLbl.AutoSize     := False;
    LLbl.Width        := LLblRight;
    LLbl.Left         := 0;
    LLbl.Top          := LTop + 2;
    LLbl.Height       := 13;

    LEdit             := Ths.Helper.Edit.TEdit.Create(AContainer);
    LEdit.Parent      := AContainer;
    LEdit.Name        := LPrefix + StringReplace(LInfo.Locale, '-', '_', [rfReplaceAll]);
    LEdit.thsLocale   := LInfo.Locale;
    LEdit.Top         := LTop;
    LEdit.Left        := LLblRight + 4;
    LEdit.Width       := AContainer.ClientWidth - LLblRight - 8;
    LEdit.Anchors     := [akLeft, akTop, akRight];
    LEdit.Text        := '';

    Inc(LTop, 22);
  end;

  AContainer.Height := LTop + 2;
end;

procedure TfrmInputSimpleDB<TE, TS>.UpdateTranslationLabels(AContainer : TWinControl; const AFieldName, ALabel: string);
var
  i        : Integer;
  LComp    : TComponent;
  LLblName : string;
  LLocale  : string;
begin
  for i := 0 to AContainer.ComponentCount - 1 do
  begin
    LComp := AContainer.Components[i];
    if not (LComp is TLabel) then Continue;

    if not StartsText('lbl' + AFieldName + '_', LComp.Name) then Continue;

    LLblName := LComp.Name;
    LLocale  := Copy(LLblName, Length('lbl' + AFieldName + '_') + 1, MaxInt);
    LLocale  := StringReplace(LLocale, '_', '-', [rfReplaceAll]);

    TLabel(LComp).Caption := ALabel + ' (' + LLocale + ')';
  end;
end;

function TfrmInputSimpleDB<TE, TS>.CollectTranslationValues(
  AContainer : TWinControl;
  const AFieldName: string): TTranslationMap;
var
  i    : Integer;
  LCtrl: TControl;
  LEdit: Ths.Helper.Edit.TEdit;
  LName: string;
begin
  Result := TTranslationMap.Create;

  for i := 0 to AContainer.ControlCount - 1 do
  begin
    LCtrl := AContainer.Controls[i];
    if not (LCtrl is Ths.Helper.Edit.TEdit) then Continue;

    LEdit := LCtrl as Ths.Helper.Edit.TEdit;
    if LEdit.thsLocale = '' then Continue;

    if AFieldName <> '' then
    begin
      LName := 'edt' + AFieldName + '_';
      if not StartsText(LName, LEdit.Name) then Continue;
    end;

    Result.AddOrSetValue(LEdit.thsLocale, LEdit.Text);
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.FillTranslationControls(AContainer: TWinControl; AValues: TTranslationMap);
var
  i    : Integer;
  LCtrl: TControl;
  LEdit: Ths.Helper.Edit.TEdit;
  LVal : string;
begin
  if not Assigned(AValues) then Exit;

  for i := 0 to AContainer.ControlCount - 1 do
  begin
    LCtrl := AContainer.Controls[i];
    if not (LCtrl is Ths.Helper.Edit.TEdit) then Continue;

    LEdit := LCtrl as Ths.Helper.Edit.TEdit;
    if LEdit.thsLocale = '' then Continue;

    if AValues.TryGetValue(LEdit.thsLocale, LVal) then
      LEdit.Text := LVal;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnAcceptClick(Sender: TObject);
var
  LId: Int64;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if not ValidateInput(PanelMain) then
      Exit;
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    try
      Service.BusinessInsert(Self.Table, True, True, False);
      RefreshParentGrid(True);
      ModalResult := mrOK;
      Close;
    except
      ModalResult := mrNone;
      raise;
    end;
  end
  else if (FormMode = ifmUpdate) then
  begin
    if TThsDialogHelper.CustomMsgDlg(
      TLocalizationManager.Translate(TLangKeys.TMessage.ConfirmUpdate, 'Are you sure you want to update the record?'),
      TMsgDlgType.mtConfirmation,
      [mbYes, mbNo],
      [
        TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'),
        TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')
      ],
      mbNo,
      TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')
    ) = mrYes then
    begin
      SetControlsDisabledOrEnabled(PanelMain, True);
      try
        Service.BusinessUpdate(Table, not Service.UoW.InTransaction, Service.UoW.InTransaction, True);
        RefreshParentGrid(True);
        ModalResult := mrOK;
        Close;
      except
        ModalResult := mrNone;
        Repaint;
        raise;
      end;
    end;
  end
  else if (FormMode = ifmRewiev) then
  begin
    SetControlsDisabledOrEnabled(PanelMain, False);

    if (Service.UoW.InTransaction) then
      CustomMsgDlg(
        TLocalizationManager.Translate(TLangKeys.TMessage.ActiveTransactionExist, 'You have an active record update. Please complete your current operation first!'),
        mtError,
        [mbOK],
        [TLocalizationManager.Translate(TLangKeys.TGeneral.OK, 'Ok')],
        mbOK,
        TLocalizationManager.Translate(TLangKeys.TMessage.InformationTitle, 'Information')
      );

    LId := Table.Id;
    FreeAndNil(Table);
    Table := Service.BusinessFindById(LId, (not Service.UoW.InTransaction), True, True);

    if (Table = nil) then
      raise Exception.Create(TLocalizationManager.Translate(TLangKeys.TMessage.RecordDeletedWhileReview, 'The record was deleted by another user while you were on the review screen.' + AddLBs(2) + 'Check the record again!'));

    FormMode := ifmUpdate;

    btnSpin.Visible := false;

    btnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Confirm');
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
    if Service.IsAuthorized(ptUpdate, True)
    then  btnAccept.Enabled := True
    else  btnAccept.Enabled := False;

    btnDelete.Visible := True;
    btnDelete.OnClick := btnDeleteClick;

    RefreshData;

    Repaint;

//    FocusFirstControl;

    btnDelete.Left := btnAccept.Left-btnDelete.Width;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnCloseClick(Sender: TObject);
begin

  if (FormMode = ifmRewiev)
  or (FormMode = ifmReadOnly)
  then
  begin
    Self.Close;
  end
  else
  if (CustomMsgDlg(
    TLocalizationManager.Translate(TLangKeys.TMessage.ConfirmCloseWindow, 'Are you sure you want to close the screen? Any changes you have made will be lost.'),
    mtConfirmation,
    mbYesNo,
    [
      TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'),
      TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')
    ],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')
  ) = mrYes)
  then
    Self.Close;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnDeleteClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate)then
  begin
    if CustomMsgDlg(
      TLocalizationManager.Translate(TLangKeys.TMessage.ConfirmDelete, 'Are you sure you want to delete the record?'),
      mtConfirmation,
      mbYesNo,
      [
        TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'),
        TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')
      ],
      mbNo,
      TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')
    ) = mrYes then
    begin
      try
        Service.BusinessDelete(Table, not Service.Uow.InTransaction, True, False);
        DoAfterDeleteEvent(Sender);

        RefreshParentGrid(False);
        ModalResult := mrOK;
        Close;
      except
        ModalResult := mrNone;
//        FormMode := ifmRewiev;
//        btnSpin.Visible := True;
//        btnDelete.Visible := False;
//        btnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Update, 'Güncelle');
//        btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
//        btnAccept.Width := Max(100, btnAccept.Width);

        Repaint;raise;
      end;
    end;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnSpinDownClick(Sender: TObject);
var
  LContext : TRttiContext;
  LType    : TRttiType;
  LMethod  : TRttiMethod;
  LProp    : TRttiProperty;
  LNewId   : Int64;
begin
  if not Assigned(Owner) then Exit;

  LContext := TRttiContext.Create;
  try
    LType   := LContext.GetType(Owner.ClassType);
    LMethod := LType.GetMethod('MoveDown');
    if Assigned(LMethod) then
      LMethod.Invoke(Owner, []);

    LProp := LType.GetProperty('Table');
    if Assigned(LProp) then
    begin
      LNewId := (LProp.GetValue(Owner).AsObject as TEntity).Id;
      if (LNewId > 0) and (LNewId <> Table.Id) then
      begin
        FreeAndNil(FTable);
        FTable := Service.FindById(LNewId, False, True);
        RefreshData;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.BtnSpinUpClick(Sender: TObject);
var
  LContext : TRttiContext;
  LType    : TRttiType;
  LMethod  : TRttiMethod;
  LProp    : TRttiProperty;
  LNewId   : Int64;
begin
  if not Assigned(Owner) then Exit;

  LContext := TRttiContext.Create;
  try
    LType   := LContext.GetType(Owner.ClassType);
    LMethod := LType.GetMethod('MoveUp');
    if Assigned(LMethod) then
      LMethod.Invoke(Owner, []);

    LProp := LType.GetProperty('Table');
    if Assigned(LProp) then
    begin
      LNewId := (LProp.GetValue(Owner).AsObject as TEntity).Id;
      if (LNewId > 0) and (LNewId <> Table.Id) then
      begin
        FreeAndNil(FTable);
        FTable := Service.FindById(LNewId, False, True);
        RefreshData;
      end;
    end;
  finally
    LContext.Free;
  end;
end;

constructor TfrmInputSimpleDB<TE, TS>.Create(
  AOwner: TComponent; AService: TS; ATable: TE;
  AFormMode: TInputFormMode;
  ARefreshGridEvent: TAfterCrudRefreshGrid;
  AFormViewMode: TInputFormViewMode
);

var LModeStr: string;
begin
  Create(AOwner);

  case AFormMode of
    ifmNone: LModeStr := 'None';
    ifmNewRecord: LModeStr := 'New Record';
    ifmRewiev: LModeStr := 'Review';
    ifmUpdate: LModeStr := 'Update';
    ifmReadOnly: LModeStr := 'Read Only';
    ifmCopyNewRecord: LModeStr := 'Copy with New Record';
  end;

  GLogger.InfoFmt('Open Input Form: %s %s "%s"', [Self.ClassName, ATable.ClassName, LModeStr]);

  SetService(AService);
  SetTable(ATable);

  FFormMode := AFormMode;
  FFormViewMode := AFormViewMode;

  FRefreshGridEvent := ARefreshGridEvent;

  Self.Caption := 'Base Title';

  PrepareForm();

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    BtnAccept.Visible := True;
    BtnClose.Visible := True;
    BtnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Confirm');
    BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
    BtnAccept.Width := Max(100, BtnAccept.Width);
  end
  else if FormMode = ifmRewiev then
  begin
    BtnAccept.Visible := True;
    BtnClose.Visible := True;

    BtnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Update, 'Update');
    BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
    BtnAccept.Width := Max(100, BtnAccept.Width);
    BtnDelete.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.DeleteRecord, 'Delete');
    BtnDelete.Width := Canvas.TextWidth(BtnDelete.Caption) + 56;
    BtnDelete.Width := Max(100, BtnDelete.Width);
  end;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreateBtnAccept;
begin
  BtnAccept := TButton.Create(PanelFooter);
  BtnAccept.Parent := PanelFooter;
  BtnAccept.ScaleForPPI(Self.CurrentPPI);
  BtnAccept.ParentFont := True;
  BtnAccept.AlignWithMargins := True;
  BtnAccept.Margins.Left := MulDiv(4, Self.CurrentPPI, 96);
  BtnAccept.Margins.Right := MulDiv(4, Self.CurrentPPI, 96);
  BtnAccept.TabOrder := 1;
  BtnAccept.Caption := '&' + TLocalizationManager.Translate(TLangKeys.TGeneral.Save, 'Save');
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
  BtnClose.Caption := '&' + TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');
  BtnClose.OnClick := BtnCloseClick;
  BtnClose.Align := alRight;
  BtnClose.Left := PanelFooter.Left + PanelFooter.Width - BtnClose.Width - 2;
end;

procedure TfrmInputSimpleDB<TE, TS>.CreateBtnDelete;
begin
  BtnDelete := TButton.Create(PanelFooter);
  BtnDelete.Parent := PanelFooter;
  BtnDelete.AlignWithMargins := True;
  BtnDelete.Padding.Left := 4;
  BtnDelete.Padding.Right := 4;
  BtnDelete.TabOrder := 3;
  BtnDelete.Caption := '&' + TLocalizationManager.Translate(TLangKeys.TGeneral.Delete, 'Delete');
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
  FreeAndNil(FTable);
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
  GLogger.InfoFmt('Close Input Form: %s %s', [Self.ClassName, Table.ClassName]);

  if FormMode = ifmUpdate then
  begin
    if Service.Uow.InTransaction then
    begin
      Service.Uow.Rollback;
    end;
  end;

  Action := caFree;
end;

procedure TfrmInputSimpleDB<TE, TS>.ApplyLocalization;
var
  meta: TEntityMeta;
begin
  inherited;
  if Assigned(Table) then
  begin
    TMetaProviderManager.SetConnection(Service.Uow.Connection);
    meta := TMetaProviderManager.GetMeta(Table.ClassType);
    BindEntityToControls(Table, Self, meta);
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    if Assigned(BtnAccept) then
    begin
      BtnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Confirm');
      BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
      BtnAccept.Width := Max(100, BtnAccept.Width);
    end;
  end
  else if FormMode = ifmRewiev then
  begin
    if Assigned(BtnAccept) then
    begin
      BtnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Update, 'Update');
      BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
      BtnAccept.Width := Max(100, BtnAccept.Width);
    end;
    if Assigned(BtnDelete) then
    begin
      BtnDelete.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.DeleteRecord, 'Delete');
      BtnDelete.Width := Canvas.TextWidth(BtnDelete.Caption) + 56;
      BtnDelete.Width := Max(100, BtnDelete.Width);
    end;
  end
  else if FormMode = ifmUpdate then
  begin
    if Assigned(BtnAccept) then
    begin
      BtnAccept.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Confirm, 'Confirm');
      BtnAccept.Width := Canvas.TextWidth(BtnAccept.Caption) + 56;
      BtnAccept.Width := Max(100, BtnAccept.Width);
    end;
    if Assigned(BtnDelete) then
    begin
      BtnDelete.Caption := TLocalizationManager.Translate(TLangKeys.TGeneral.Delete, 'Delete');
      BtnDelete.Width := Canvas.TextWidth(BtnDelete.Caption) + 56;
      BtnDelete.Width := Max(100, BtnDelete.Width);
    end;
  end;

  if Assigned(BtnClose) then
    BtnClose.Caption := '&' + TLocalizationManager.Translate(TLangKeys.TGeneral.Close, 'Close');

  RefreshData;
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
  if Assigned(BtnSpin) and BtnSpin.Visible then
  begin
    if Key = VK_PRIOR then
    begin
      Key := 0;
      BtnSpinUpClick(BtnSpin);
      Exit;
    end;

    if Key = VK_NEXT then
    begin
      Key := 0;
      BtnSpinDownClick(BtnSpin);
      Exit;
    end;
  end;

  inherited;
end;

procedure TfrmInputSimpleDB<TE, TS>.FormKeyPress(Sender: TObject; var Key: Char);
var
  LPrevKey: SmallInt;
begin
  case Key of
    Char(VK_ESCAPE):
      begin
        Key := #0;
        BtnCloseClick(Sender);
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
  BtnAccept.Visible := True;

  TMetaProviderManager.SetConnection(Service.UoW.Connection);
  meta := TMetaProviderManager.GetMeta(Table.ClassType);
  BindEntityToControls(Table, Self, meta);

  InitializeInputCase;

  case FormMode of
    ifmNone: ;

    ifmNewRecord:
    begin
      BtnSpin.Visible   := False;
      BtnDelete.Visible := False;
      BtnDelete.OnClick := nil;
    end;

    ifmRewiev:
    begin
//      RefreshData;
      BtnDelete.Visible := False;
      BtnDelete.OnClick := nil;
    end;

    ifmUpdate:
    begin
//      RefreshData;
      BtnDelete.Visible := True;
      BtnDelete.OnClick := BtnDeleteClick;
    end;

    ifmReadOnly:
    begin
//      RefreshData;
      BtnDelete.Visible := False;
      BtnDelete.OnClick := nil;
    end;

    ifmCopyNewRecord:
    begin
      BtnSpin.Visible   := False;
      BtnDelete.Visible := False;
      BtnDelete.OnClick := nil;
    end;
  end;

  if (FormMode = ifmRewiev) or (FormMode = ifmReadOnly) then
    SetControlsDisabledOrEnabled(PgcBase, True);

  Repaint;

  ApplyLocalization;
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
    CreateBtnDelete;
    CreateBtnClose;
    CreateBtnAccept;

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
  LContainer  : TWinControl;
  LControlName: string;
  n1, n2      : Integer;
begin
  Result     := True;
  LContainer := nil;

  if AContainerControl = nil then
    LContainer := PanelMain
  else if AContainerControl is TPanel then
    LContainer := AContainerControl
  else if AContainerControl is TGroupBox then
    LContainer := AContainerControl
  else if AContainerControl is TPageControl then
    LContainer := AContainerControl
  else if AContainerControl is TTabSheet then
    LContainer := AContainerControl;

  if not Assigned(LContainer) then Exit;

  if not (FormMode in [ifmUpdate, ifmNewRecord, ifmCopyNewRecord]) then
    Exit;

  for n1 := 0 to LContainer.ControlCount - 1 do
  begin
    if LContainer.Controls[n1] is TPageControl then
    begin
      for n2 := 0 to (LContainer.Controls[n1] as TPageControl).PageCount - 1 do
      begin
        Result := ValidateSubControls(
          (LContainer.Controls[n1] as TPageControl).Pages[n2],
          LControlName);
        if not Result then Break;
      end;
    end
    else if LContainer.Controls[n1] is TWinControl then
    begin
      Result := ValidateSubControls(
        LContainer.Controls[n1] as TWinControl, LControlName);
    end;

    if not Result then Break;
  end;

  Repaint;

  // FIX: En dış çağrıda (nil parametre) hata mesajı göster
  if not Result and (AContainerControl = nil) then
    raise Exception.Create(
      TLocalizationManager.Translate(
        TLangKeys.TValidation.RequiredFieldsEmpty,
        'Required fields cannot be left blank.') + AddLBs(3) + LControlName);
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
