unit ufrmInputSimpleDBDesign;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Math, System.SysUtils,
  System.StrUtils, System.Generics.Collections,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.Grids, Vcl.ExtCtrls, Vcl.Clipbrd,
  Vcl.DBGrids, Vcl.Samples.Spin, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  Ths.DialogHelper, Ths.Globals, SysViewColumn, Entity, Service, SharedFormTypes;

type
  TDBHelper<TE: TEntity; TS: TCrudService<TE>, constructor> = class
  private
    FSvc: TS;
    FEntity: TE;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(AId: Int64);
    procedure Save(AEntity: TE);

    property Entity: TE read FEntity write FEntity;
    property Svc: TS read FSvc write FSvc;
  end;

  TfrmInputSimpleDBDesign = class(TForm)
    pnlMain: TPanel;
    pnlBottom: TPanel;
    btnSpin: TSpinButton;
    btnAccept: TButton;
    btnClose: TButton;
    btnDelete: TButton;
    statBase: TStatusBar;
  private
    FFormMode: TInputFormMode;
    FDefaultSelectFilter: string;
    FRefreshGridEvent: TAfterCrudRefreshGrid;
    FAfterDeleteEvent: TNotifyEvent;

    procedure DoAfterDeleteEvent(Sender: TObject);
    function ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
  protected
    procedure SetControlsDisabledOrEnabled(AContainerControl: TWinControl = nil; ADisable: Boolean = True);
    procedure SubSetControlProperty(AControl: TControl; AColumn: TSysViewColumn; AIsOnlyRepaint: Boolean);
    procedure SetControlDBProperty(AIsOnlyRepaint: Boolean = False);
  public
    FHelper: TDBHelper<TEntity, TCrudService<TEntity>>;

    property FormMode: TInputFormMode read FFormMode write FFormMode;
    property DefaultSelectFilter: string read FDefaultSelectFilter write FDefaultSelectFilter;

    constructor Create(AOwner: TComponent; AFormMode: TInputFormMode; ARefreshGridEvent: TAfterCrudRefreshGrid); reintroduce; overload;
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
    procedure statBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
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
  published
    property AfterDeleteEvent: TNotifyEvent read FAfterDeleteEvent write FAfterDeleteEvent;
  end;

implementation

{$R *.dfm}

constructor TDBHelper<TE, TS>.Create;
begin
  inherited;
  FEntity := TE.Create;
  FSvc := TS.Create;
end;

destructor TDBHelper<TE, TS>.Destroy;
begin
  FEntity.Free;
  FSvc.Free;
  inherited;
end;

procedure TDBHelper<TE, TS>.Load(AId: Int64);
begin
  FEntity := FSvc.FindById(AId, False);
end;

procedure TDBHelper<TE, TS>.Save(AEntity: TE);
begin
  FSvc.Add(FEntity);
end;

procedure TfrmInputSimpleDBDesign.BtnAcceptClick(Sender: TObject);
var
  n1: Integer;
  LId: Int64;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    ValidateInput(pnlMain);

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    try
      FHelper.Svc.BusinessInsert(FHelper.FEntity, True, True, False);//WithCommitTransaction
      RefreshParentGrid(True);
      ModalResult := mrOK;
      Close;
    except
      ModalResult := mrNone;//hata durumunda pencere kapanmas�n

      //eger begin transaction demiyorsa insert pencere kapansin cunku rollback yapildi artik insert etmemeli
      //Onceki islemler geri alindigi icin
      if (FHelper.FSvc.UoW.InTransaction) then
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
    SetControlsDisabledOrEnabled(PnlMain, False);

    if (not FHelper.FSvc.UoW.InTransaction) then
    begin
      //varsa kaydi kilitle
//      LId := Table.Id.Value;
//      for n1 := 0 to Table.Fields.Count-1 do
//        Table.Fields.Items[n1].OwnerEntity := nil;

      FHelper.FEntity := FHelper.FSvc.BusinessFindById(LId, (not FHelper.FSvc.UoW.InTransaction), True, True);

      //eger aranan kayit baska bir kullanici tarafindan silinmisse count 0 kalir
      if (FHelper.FEntity = nil) then
        raise Exception.Create('Siz inceleme ekranındayken kayıt başka kullanıcı tarafından silinmiş.' + AddLBs(2) + 'Kaydı tekrar kontrol edin!');

      FormMode := ifmUpdate;

      btnSpin.Visible := false;

      btnAccept.Caption := 'Onayla';
      btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
      btnAccept.Width := Max(100, btnAccept.Width);
      if FHelper.FSvc.Uow.IsAuthorized(ptUpdate, True, False)
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
      CustomMsgDlg('Aktif bir kay�t g�ncellemeniz var. �nce a��k olan i�leminizi bitirin!', mtError, [mbOK], ['Tamam'], mbOK, 'Bilgilendirme');

  end;
end;

procedure TfrmInputSimpleDBDesign.BtnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmInputSimpleDBDesign.BtnDeleteClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate)then
  begin
    if CustomMsgDlg('Kaydı silmek istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      try
        FHelper.FSvc.BusinessDelete(FHelper.FEntity, not FHelper.FSvc.Uow.InTransaction, True, False);
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

procedure TfrmInputSimpleDBDesign.BtnSpinDownClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
end;

procedure TfrmInputSimpleDBDesign.BtnSpinUpClick(Sender: TObject);
begin
  ShowMessage('not implemented yet');
end;

constructor TfrmInputSimpleDBDesign.Create(AOwner: TComponent; AFormMode: TInputFormMode; ARefreshGridEvent: TAfterCrudRefreshGrid);
begin
  Create(Owner);
  Self.Caption := 'Base Title';
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

  FHelper := TDBHelper<TEntity, TCrudService<TEntity>>.Create;

  FFormMode := AFormMode;

  FRefreshGridEvent := ARefreshGridEvent;


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

destructor TfrmInputSimpleDBDesign.Destroy;
var
  n1: Integer;
begin
  FHelper.Free;
  inherited;
end;

procedure TfrmInputSimpleDBDesign.DoAfterDeleteEvent(Sender: TObject);
begin
  if Assigned(FAfterDeleteEvent) then
    FAfterDeleteEvent(Sender);
end;

procedure TfrmInputSimpleDBDesign.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FormMode = ifmUpdate then
  begin
    if FHelper.FSvc.Uow.InTransaction then
    begin
      FHelper.FSvc.Uow.Rollback;
    end;
  end;

  Action := caFree;
end;

procedure TfrmInputSimpleDBDesign.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDBDesign.FormDestroy(Sender: TObject);
begin
//
end;

procedure TfrmInputSimpleDBDesign.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//
end;

procedure TfrmInputSimpleDBDesign.FormKeyPress(Sender: TObject; var Key: Char);
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

procedure TfrmInputSimpleDBDesign.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TfrmInputSimpleDBDesign.FormShow(Sender: TObject);
begin
  BtnAccept.Visible := False;
  BtnAccept.Visible := True;

  SetControlDBProperty();
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

//  if (Self.FormMode = ifmRewiev)
//  or (Self.FormMode = ifmReadOnly)
//  then
//  begin
//    SetControlsDisabledOrEnabled(PgcBase, True);
//  end;

  Repaint;
end;

procedure TfrmInputSimpleDBDesign.InitializeInputCase;
begin
//
end;

procedure TfrmInputSimpleDBDesign.RefreshData;
begin
  RefreshDataAuto;
end;

procedure TfrmInputSimpleDBDesign.RefreshDataAuto;
begin
//
end;

procedure TfrmInputSimpleDBDesign.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  if Assigned(FRefreshGridEvent) then
    FRefreshGridEvent(AFocusSelectedItem);
end;

procedure TfrmInputSimpleDBDesign.SetControlDBProperty(AIsOnlyRepaint: Boolean);
var
  MetaProvider: TArray<TSysViewColumn>;
  n1, n2, n3: Integer;
  LContainerCtrl, LParentCtrl: TControl;
begin
{
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
            if MetaProvider[n3].OrjColumnName = RightStr(TTabSheet(LParentCtrl).Controls[n2].Name, Length(TTabSheet(LParentCtrl).Controls[n2].Name)- 3) then
            begin
              SubSetControlProperty(TTabSheet(LParentCtrl).Controls[n2], MetaProvider[n3], AIsOnlyRepaint);
              Break;
            end;
          end;
        end;
      end;
    end;
}
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
//  end;
end;

procedure TfrmInputSimpleDBDesign.SetControlsDisabledOrEnabled(AContainerControl: TWinControl; ADisable: Boolean);
var
  n1: Integer;
  LPanelContainer: TWinControl;
begin
  LPanelContainer := nil;

  if AContainerControl = nil then
    LPanelContainer := pnlMain
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

procedure TfrmInputSimpleDBDesign.StatusBarAddPanel(AWidth: Integer; AStyle: TStatusPanelStyle);
begin
//
end;

procedure TfrmInputSimpleDBDesign.statBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
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

procedure TfrmInputSimpleDBDesign.SubSetControlProperty(AControl: TControl; AColumn: TSysViewColumn; AIsOnlyRepaint: Boolean);
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
        MaxLength := AColumn.CharacterMaximumLength;
        thsDBFieldName := AColumn.OrjColumnName;
        thsRequiredData := not AColumn.IsNullable;
//        thsActiveYear4Digit := GSysApplicationSetting.Donem;
        OnCalculatorProcess := nil;

(*
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
        end;*)
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
        MaxLength := AColumn.CharacterMaximumLength;
        thsDBFieldName := AColumn.OrjColumnName;
        thsRequiredData := not AColumn.IsNullable;
(*
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
        end;*)
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
        MaxLength := AColumn.CharacterMaximumLength;
        thsDBFieldName := AColumn.OrjColumnName;
        thsRequiredData := not AColumn.IsNullable;
(*
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
        end;*)
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

function TfrmInputSimpleDBDesign.ValidateInput(AContainerControl: TWinControl): Boolean;
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
    LPanelContainer := pnlMain
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

function TfrmInputSimpleDBDesign.ValidateSubControls(Sender: TWinControl; out AControlName: string): Boolean;
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
