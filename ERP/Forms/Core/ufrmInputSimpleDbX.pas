unit ufrmInputSimpleDbX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Math, System.SysUtils,
  System.StrUtils,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  Ths.DialogHelper, Ths.Globals, SysViewColumn,
  BaseEntity, BaseService, EntityMetaProvider, SharedFormTypes;

type
  TfrmInputSimpleDbX<TE: TEntity; TS: TBaseService<TE>> = class(TForm)
  private
    FService: TS;
    FTable: TE;

    FFormMode: TInputFormMode;
    FDefaultSelectFilter: string;

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
    function ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
  protected
    procedure SetControlsDisabledOrEnabled(AContainerControl: TWinControl = nil; ADisable: Boolean = True);
    procedure SubSetControlProperty(AControl: TControl; AColumn: TSysViewColumn; AIsOnlyRepaint: Boolean);
    procedure SetControlDBProperty(AIsOnlyRepaint: Boolean = False);
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
var
  n1: Integer;
  LId: Int64;
//var
//  LTable: TEntity;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    ValidateInput(PanelMain);

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
      if (Service.UoW.InTransaction) then
        Close;
      raise;
    end;
  end
  else if (FormMode = ifmUpdate) then
  begin
    if TThsDialogHelper.CustomMsgDlg('Kaydı güncellemek istediğinden emin misin?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], ['Evet', 'Hay�r'], mbNo, 'Kullan�c� Onay�') = mrYes then
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
    //burada guncelleme modunda oldugu icin butun kontrolleri acmak gerekiyor.
    SetControlsDisabledOrEnabled(PanelMain, False);

    if (not Service.UoW.InTransaction) then
    begin
      //varsa kaydi kilitle
      LId := Table.Id.Value;
      for n1 := 0 to Table.Fields.Count-1 do
        Table.Fields.Items[n1].OwnerEntity := nil;

      Table := Service.BusinessFindById(LId, (not Service.UoW.InTransaction), True, True);

      //eger aranan kayit baska bir kullanici tarafindan silinmisse count 0 kalir
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

      RefreshData;

      Repaint;

//      FocusFirstControl;

      btnDelete.Left := btnAccept.Left-btnDelete.Width;
    end
    else
      CustomMsgDlg('Aktif bir kay�t g�ncellemeniz var. �nce a��k olan i�leminizi bitirin!', mtError, [mbOK], ['Tamam'], mbOK, 'Bilgilendirme');

  end;
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnDeleteClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnSpinDownClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
end;

procedure TfrmInputSimpleDbX<TE, TS>.BtnSpinUpClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
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
  BtnDelete.OnClick := BtnDeleteClick;
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
var
  LPrevKey: SmallInt;
begin
  case Key of
    Char(VK_ESCAPE): Self.Close;
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
    Char(VK_F4):
      begin
        if btnDelete.Visible and btnDelete.Enabled and Self.Visible then
          btnDelete.Click;
      end;
    Char(VK_F5):
      begin
        if btnAccept.Visible and btnAccept.Enabled and Self.Visible then
          btnAccept.Click
      end;
    Char(VK_F6):
      begin
        if btnClose.Visible and btnClose.Enabled and Self.Visible then
          btnClose.Click;
      end;
    Char(VK_F11):
      begin
        Self.AlphaBlend := not Self.AlphaBlend;
        Self.AlphaBlendValue := 50;
      end;
  else
    inherited;
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

  SetControlDBProperty();

  if (FormMode <> ifmNewRecord ) then
  begin
    RefreshData;
  end;

  if (Self.FormMode = ifmRewiev)
  or (Self.FormMode = ifmReadOnly)
  then
  begin
    BtnDelete.Visible := False;
    BtnDelete.OnClick := nil;
    SetControlsDisabledOrEnabled(PgcBase, True);
  end;

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

procedure TfrmInputSimpleDbX<TE, TS>.SetControlDBProperty(AIsOnlyRepaint: Boolean);
var
  MetaProvider: TArray<TSysViewColumn>;
  n1, n2, n3: Integer;
  LContainerCtrl, LParentCtrl: TControl;
//  nx: Integer;
//  LSubTable: IEntity;
begin
  MetaProvider := TEntityMetaProvider.GetFieldMeta(Table.TableName);

  if PgcBase = nil then
    LContainerCtrl := PanelMain.FindChildControl('')
  else
  LContainerCtrl := PanelMain.FindChildControl(PgcBase.Name);
  //Main panel içindeki pagecontrol içinde sekme olarak kullanılan kontroller
  if Assigned(LContainerCtrl) then
  begin
    for n1 := 0 to TPageControl(LContainerCtrl).PageCount-1 do
    begin
      LParentCtrl := TPageControl(LContainerCtrl).Pages[n1];
      for n2 := 0 to TTabSheet(LParentCtrl).ControlCount-1 do
      begin
        if (TTabSheet(LParentCtrl).Controls[n2].ClassType = TEdit)
        or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TMemo)
        or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TCombobox)
        or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TCheckBox)
        or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TRadioGroup)
        then
        begin
          for n3 := 0 to Length(MetaProvider)-1 do
          begin
            if MetaProvider[n3].OrjColumnName.Value = RightStr(TTabSheet(LParentCtrl).Controls[n2].Name, Length(TTabSheet(LParentCtrl).Controls[n2].Name)- 3) then
            begin
              SubSetControlProperty(TTabSheet(LParentCtrl).Controls[n2], MetaProvider[n3], AIsOnlyRepaint);
              Break;
            end;
          end;
        end;
      end;
    end;
{
    for nx := 0 to Length(Table.Fields)-1 do
    begin
      if (Table <> Table.Fields[nx].OwnerEntity) and (Table.Fields[nx].OwnerEntity <> nil) then
      begin
        LSubTable := Table.Fields[nx].OwnerEntity;
        if Assigned(LSubTable) and (LSubTable <> nil) then
        begin
          for n1 := 0 to TPageControl(LContainerCtrl).PageCount-1 do
          begin
            LParentCtrl := TPageControl(LContainerCtrl).Pages[n1];
            for n2 := 0 to TTabSheet(LParentCtrl).ControlCount-1 do
            begin
              if (TTabSheet(LParentCtrl).Controls[n2].ClassType = TEdit)
              or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TMemo)
              or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TCombobox)
              or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TCheckBox)
              or (TTabSheet(LParentCtrl).Controls[n2].ClassType = TRadioGroup)
              then
              begin
                for n3 := 0 to Length(LSubTable.Fields)-1 do
                begin
                  if LSubTable.Fields[n3].FieldName = RightStr(TTabSheet(LParentCtrl).Controls[n2].Name, Length(TTabSheet(LParentCtrl).Controls[n2].Name)- 3) then
                  begin
                    SubSetControlProperty(TTabSheet(LParentCtrl).Controls[n2], LSubTable.Fields[n3]);
                    Break;
                  end;
                end;
              end;
            end;
          end;

        end;
      end;
    end;
}
  end;
end;

procedure TfrmInputSimpleDbX<TE, TS>.SetControlsDisabledOrEnabled(AContainerControl: TWinControl; ADisable: Boolean);
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

procedure TfrmInputSimpleDbX<TE, TS>.SubSetControlProperty(AControl: TControl; AColumn: TSysViewColumn; AIsOnlyRepaint: Boolean);
begin
  if (AColumn = nil) or not Assigned(AControl) then
    Exit;

  if (AControl is TEdit) then
  begin
    with TEdit(AControl) do
    begin
      if AIsOnlyRepaint then
        Repaint
      else
      begin
        CharCase := VCL.StdCtrls.ecUpperCase;
        MaxLength := AColumn.CharacterMaximumLength.Value;
        thsDBFieldName := AColumn.OrjColumnName.Value;
        thsRequiredData := not AColumn.IsNullable.Value;
        thsActiveYear4Digit := GSysApplicationSetting.Donem.Value;
        OnCalculatorProcess := nil;


        if (AColumn.GetFieldType = ftString) then
          thsInputDataType := itString
        else if (AColumn.GetFieldType = ftByte) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 3;
        end
        else if (AColumn.GetFieldType = ftSmallint) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 5;
        end
        else if (AColumn.GetFieldType = ftInteger) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 10;
        end
        else if (AColumn.GetFieldType = ftLargeint) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 19;
        end
        else if (AColumn.GetFieldType = ftDate) then
        begin
          thsInputDataType := itDate;
          MaxLength := 10
        end
        else if (AColumn.GetFieldType = ftTime) then
        begin
          thsInputDataType := itTime;
          MaxLength := 5
        end
        else if (AColumn.GetFieldType = ftDateTime) then
        begin
          thsInputDataType := itDate;
          MaxLength := 19;
        end
        else if (AColumn.GetFieldType = ftFloat) then
        begin
          thsInputDataType := itFloat;
        end
        else if (AColumn.GetFieldType = ftBCD) then
        begin
          thsInputDataType := itMoney;
          Alignment := taRightJustify;
        end;
      end;
    end;
  end
  else if (AControl is TMemo) then
  begin
    with TMemo(AControl) do
    begin
      if AIsOnlyRepaint then
        Repaint
      else
      begin
        CharCase := VCL.StdCtrls.ecUpperCase;
        MaxLength := AColumn.CharacterMaximumLength.Value;
        thsDBFieldName := AColumn.OrjColumnName.Value;
        thsRequiredData := not AColumn.IsNullable.Value;

        if (AColumn.GetFieldType = ftString) then
          thsInputDataType := itString
        else if (AColumn.GetFieldType = ftByte) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 3;
        end
        else if (AColumn.GetFieldType = ftSmallint) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 5;
        end
        else if (AColumn.GetFieldType = ftInteger) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 10;
        end
        else if (AColumn.GetFieldType = ftLargeint) then
        begin
          thsInputDataType := itInteger;
          MaxLength := 19;
        end
        else if (AColumn.GetFieldType = ftDate) then
        begin
          thsInputDataType := itDate;
          MaxLength := 10
        end
        else if (AColumn.GetFieldType = ftTime) then
        begin
          thsInputDataType := itTime;
          MaxLength := 5
        end
        else if (AColumn.GetFieldType = ftDateTime) then
        begin
          thsInputDataType := itDate;
          MaxLength := 19;
        end
        else if (AColumn.GetFieldType = ftFloat) then
        begin
          thsInputDataType := itFloat;
        end
        else if (AColumn.GetFieldType = ftBCD) then
        begin
          thsInputDataType := itMoney;
          Alignment := taRightJustify;
        end;
      end;
    end;
  end
  else if (AControl is TCombobox) then
  begin
    with TCombobox(AControl) do
    begin
      if AIsOnlyRepaint then
        Repaint
      else
      begin
        CharCase := VCL.StdCtrls.ecUpperCase;
        MaxLength := AColumn.CharacterMaximumLength.Value;
        thsDBFieldName := AColumn.OrjColumnName.Value;
        thsRequiredData := not AColumn.IsNullable.Value;

        thsInputDataType := itString;
        if (AColumn.GetFieldType = ftString) then
          thsInputDataType := itString
        else if (AColumn.GetFieldType = ftByte) then
        begin
          thsInputDataType := itInteger;
        end
        else if (AColumn.GetFieldType = ftSmallint) then
        begin
          thsInputDataType := itInteger;
        end
        else if (AColumn.GetFieldType = ftInteger) then
        begin
          thsInputDataType := itInteger;
        end
        else if (AColumn.GetFieldType = ftLargeint) then
        begin
          thsInputDataType := itInteger;
        end

        else if (AColumn.GetFieldType = ftDate) then
        begin
          thsInputDataType := itDate;
        end
        else if (AColumn.GetFieldType = ftTime) then
        begin
          thsInputDataType := itTime;
        end
        else if (AColumn.GetFieldType = ftDateTime) then
        begin
          thsInputDataType := itDate;
        end
        else if (AColumn.GetFieldType = ftFloat) then
        begin
          thsInputDataType := itFloat;
        end
        else if (AColumn.GetFieldType = ftBCD) then
        begin
          thsInputDataType := itMoney;
        end;
      end;
    end;
  end
  else if (AControl is TCheckBox) then
  begin
  end
  else if (AControl is TRadioGroup) then
  begin
  end;
end;

function TfrmInputSimpleDbX<TE, TS>.ValidateInput(AContainerControl: TWinControl): Boolean;
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

function TfrmInputSimpleDbX<TE, TS>.ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
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
