unit ufrmBaseInputDB;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes,
  System.Variants, System.Math, System.Rtti, Vcl.Controls, Vcl.Forms,
  Vcl.ComCtrls, Vcl.Dialogs, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Graphics, Vcl.AppEvnts, Vcl.ImgList, Vcl.Menus, Data.DB, Data.FmtBcd,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  udm, ufrmBase, ufrmBaseInput, Ths.Database, Ths.Database.Table;

type
  TfrmBaseInputDB = class(TfrmBaseInput)
    procedure btnSpinDownClick(Sender: TObject); override;
    procedure btnSpinUpClick(Sender: TObject); override;
    procedure btnDeleteClick(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure FormKeyPress(Sender: TObject; var Key: Char); override;
    procedure FormResize(Sender: TObject); override;
    procedure FormPaint(Sender: TObject); override;
  private
    FAfterDeleteEvent: TNotifyEvent;
    procedure DoAfterDeleteEvent(Sender: TObject);
    procedure RefreshParentGrid(AFocusSelectedItem: Boolean);
    procedure FocusFirstControl;
  protected
    procedure ResetSession();virtual;
    function SetSession():Boolean;virtual;
    procedure HelperProcess(Sender: TObject);virtual;
    procedure OnCalculate(Sender: TObject);
  published
    property AfterDeleteEvent: TNotifyEvent read FAfterDeleteEvent write FAfterDeleteEvent;
//    FRefresher: ThreadRefresh;

/// <summary>
///  InputDB formlarındaki Edit Memo ComboBox gibi kontrollerin zorunlu alan, maks leng, charcase gibi özelliklerini form ilk açılışta ayarlıyor.
/// </summary>
///  <remarks>
///  NOT: Bu kontroller direkt olarak pnlMain üzerinde veya pgcMain içindeki TabSheet ler içinde olmalı
///  </remarks>
    procedure SetControlDBProperty(pIsOnlyRepaint: Boolean = False);

/// <summary>
///  Table sınıfı içindeki değerleri açılan formda bulunan kontrollere otomatik olarak yüklüyor.
///  Yapılan işlemin gösterimsel örneği aşağıdadır.
///  <example>
///   <code lang="Delphi">edtcontrol_name_like_db_field_name.Text := Table.PersonelAd.Value</code>
///  </example>
/// </summary>
///  <remarks>
///  NOT: Bu kontroller direkt olarak pnlMain üzerinde veya pgcMain içindeki TabSheet ler içinde olmalı
///  </remarks>
    procedure RefreshDataAuto; virtual;

    procedure stbBaseDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect); override;
    procedure RefreshData; override;
  end;

implementation

uses
  ufrmCalculator, ufrmBaseDBGrid, Ths.Constants, Ths.Globals;

{$R *.dfm}

procedure TfrmBaseInputDB.btnSpinDownClick(Sender: TObject);
begin
  if (Self.ParentForm = nil) then
    Exit;

  if TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecNo < TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecordCount then
  begin
    TfrmBaseDBGrid(ParentForm).MoveUp;

    Table.LogicalSelect(' and ' + Table.Id.QryName + '=' + IntToStr(TfrmBaseDBGrid(ParentForm).Table.Id.Value), False, False, False);
    DefaultSelectFilter := ' and ' + Table.Id.QryName + '=' + IntToStr(Table.Id.Value);
    RefreshData;
  end;
end;

procedure TfrmBaseInputDB.btnSpinUpClick(Sender: TObject);
begin
  if (Self.ParentForm = nil) then
    Exit;

  if TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.RecNo > 1 then
  begin
    TfrmBaseDBGrid(ParentForm).MoveDown;

    Table.LogicalSelect(' and ' + Table.Id.QryName + '=' + IntToStr(TfrmBaseDBGrid(ParentForm).Table.Id.Value), false, false, False);
    DefaultSelectFilter := ' and ' + Table.Id.QryName + '=' + IntToStr(Table.Id.Value);
    RefreshData;
  end;
end;

procedure TfrmBaseInputDB.DoAfterDeleteEvent(Sender: TObject);
begin
  if Assigned(FAfterDeleteEvent) then
    FAfterDeleteEvent(Sender);
end;

procedure TfrmBaseInputDB.btnDeleteClick(Sender: TObject);
begin
  if (FormMode = ifmUpdate)then
  begin
    if CustomMsgDlg('Kaydı silmek istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      if (Table.LogicalDelete(True, False)) then
      begin
        DoAfterDeleteEvent(Sender);

        RefreshParentGrid(False);
        ModalResult := mrOK;
        Close;
      end
      else
      begin
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

procedure TfrmBaseInputDB.btnAcceptClick(Sender: TObject);
var
  LTable: TTable;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
//    if (Table.Database.Connection.InTransaction) then
    begin
      if AcceptBtnDoAction then
      begin
        if (Table.LogicalInsert(True, WithCommitTransaction, False)) then
        begin
          RefreshParentGrid(True);
          ModalResult := mrOK;
          Close;
        end
        else
        begin
          ModalResult := mrNone;//hata durumunda pencere kapanmasın

          //eüer begin transaction demiyosa insert pencere kapansın çünkü rollback yapıld artık insert etmemeli
          //Önceki işlemler geri alındığı için
          if (Table.Database.Connection.InTransaction) then
            Close;
        end;
      end
      else
        ModalResult := mrOK;
    end;
  end
  else if (FormMode = ifmUpdate) then
  begin
    if CustomMsgDlg('Kaydı güncelleme istediğinden emin misin?', TMsgDlgType.mtConfirmation, [mbYes, mbNo], ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
    begin
      //Burada yeni kayıt veya güncelleme modunda olduüu için bütün kontrolleri açmak gerekiyor.
      SetControlsDisabledOrEnabled(pnlMain, True);
      if AcceptBtnDoAction then
      begin
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
          btnAccept.Caption := 'Güncelle';
          btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
          btnAccept.Width := Max(100, btnAccept.Width);
          btnDelete.Visible := false;
          Repaint;
        end;
      end;

    end;
  end
  else if (FormMode = ifmRewiev) then
  begin
    //burada güncelleme modunda olduğu için bütün kontrolleri açmak gerekiyor.
    SetControlsDisabledOrEnabled(pnlMain, False);

    if (not Table.Database.Connection.InTransaction) then
    begin
      //varsa kaydı kilitle
      if (Table.LogicalSelect(DefaultSelectFilter, True, ( not Table.Database.Connection.InTransaction), True)) then
      begin
        //eğer aranan kayıt başka bir kullanıcı tarafından silinmişse count 0 kalır
        if (Table.List.Count = 0) then
        begin
          raise Exception.Create('Siz inceleme ekranındayken kayıt başka kullanıcı tarafından silinmiş.' + AddLBs(2) + 'Kaydı tekrar kontrol edin!');
        end
        else
        begin
          LTable := TTable(Table.List[0]).Clone;
          Table.Destroy;
          Table := LTable;
        end;

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
      CustomMsgDlg('Aktif bir kayıt güncellemeniz var. Önce açık olan işleminizi bitirin!', mtError, [mbOK], ['Tamam'], mbOK, 'Bilgilendirme');
  end;
end;

procedure TfrmBaseInputDB.FormCreate(Sender: TObject);
begin
  inherited;

  if Assigned(Table) then
  begin
//    FRefresher := ThreadRefresh.Create(Self, True);

    Table.SetFieldDBPropsFromDbInfo;

    ResetSession();

    SetControlDBProperty();
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    btnAccept.Visible := True;
    btnClose.Visible := True;
    btnAccept.Caption := 'Onayla';
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
  end
  else if FormMode = ifmRewiev then
  begin
    btnAccept.Visible := True;
    btnClose.Visible := True;

    btnAccept.Caption := 'Güncelle';
    btnAccept.Width := Canvas.TextWidth(btnAccept.Caption) + 56;
    btnAccept.Width := Max(100, btnAccept.Width);
    btnDelete.Caption := 'Kayıt Sil';
    btnDelete.Width := Canvas.TextWidth(btnDelete.Caption) + 56;
    btnDelete.Width := Max(100, btnDelete.Width);
  end;
end;

procedure TfrmBaseInputDB.FormShow(Sender: TObject);
begin
  inherited;

  if pgcMain.Visible and pgcMain.Enabled and tsMain.TabVisible and tsMain.Enabled then
    pgcMain.ActivePageIndex := tsMain.TabIndex;

  if (FormMode <> ifmNewRecord ) then
    RefreshData;

  //sadece sayısal alanların gösterim şeklini (basamaklı ve ondalıklı) düzeltmek için yazıldı
  if Assigned(Table) then
  begin
//    FRefresher.Start;
    SetControlDBProperty(True);
  end;
  Repaint;
end;

procedure TfrmBaseInputDB.HelperProcess(Sender: TObject);
begin
  //override eden dolduracak
end;

procedure TfrmBaseInputDB.OnCalculate(Sender: TObject);
var
  AEdit: TEdit;
begin
  if Sender is TEdit then
  begin
    AEdit := TEdit(Sender);
    if not AEdit.ReadOnly and AEdit.Enabled then
    begin
      TfrmCalculator.Create(Self, AEdit).ShowModal;
    end;
  end;
end;

procedure TfrmBaseInputDB.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //ferhat burası doğru çalışmıyor parent kapatıldığı halde burada parent varmış gibi işlem yapıyor.
  //parentform bir şekilde kapatıltığında buradan da nil yapılmalı.
//  ShowMessage(Self.ParentForm.Name + ' ' + Self.ParentForm.Parent.Name);

//  if  ((self.FormMode = ifmNewRecord) or (self.FormMode = ifmUpdate))
//  and (Self.ParentForm <> nil)
//  then
//    TfrmBaseDBGrid(Self.ParentForm).RefreshData;

  if Table.Database.Connection.InTransaction then
    Table.Database.Connection.Rollback;

  if Assigned(ParentForm) and ParentForm.HandleAllocated then
  begin
    BringWindowToTop(ParentForm.Handle);
    if ParentForm is TfrmBaseDBGrid then
      TfrmBaseDBGrid(ParentForm).grd.SetFocus;
  end;

  inherited;
end;

procedure TfrmBaseInputDB.FormDestroy(Sender: TObject);
begin
//  if ParentForm = nil then
//    Table.Unlisten;
//  FRefresher.Terminate;
  if Table.Database.Connection.InTransaction then
    Table.Database.Connection.Rollback;
  inherited;
end;

procedure TfrmBaseInputDB.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (btnSpin.Visible) and (Key = VK_NEXT) then  //page_down
    btnSpinDownClick(btnSpin)
  else if (btnSpin.Visible) and (Key = VK_PRIOR) then  //page_up
    btnSpinUpClick(btnSpin)
  else if  (Key = Ord('T')) then
  begin
    if Shift = [ssCtrl, ssShift, ssAlt] then
    begin
      Key := 0;
      if FormViewMode = ivmSort then
        FormViewMode := ivmNormal
      else if FormViewMode = ivmNormal then
        FormViewMode := ivmSort;
      RefreshData;
    end;
  end
  else
    inherited;
end;

procedure TfrmBaseInputDB.FormKeyPress(Sender: TObject; var Key: Char);
begin
  //ESC key Close action
  if Key = #27 then
  begin
    Key := #0;
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if CustomMsgDlg('Çıkmak istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı') = mrYes then
        Close;
    end
    else
    if (FormMode = ifmRewiev) then
      Close;
  end
  else
    inherited;
end;

procedure TfrmBaseInputDB.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  //
end;

procedure TfrmBaseInputDB.FormResize(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseInputDB.FormPaint(Sender: TObject);
begin
  inherited;
  //
end;

procedure TfrmBaseInputDB.RefreshData;
begin
  RefreshDataAuto;
end;

procedure TfrmBaseInputDB.FocusFirstControl;
var
  n1: Integer;
begin
  for n1 := 0 to pgcMain.ActivePage.ControlCount - 1 do
  begin
    if TControl(pgcMain.ActivePage.Controls[n1]) is TWinControl then
    begin
      if TWinControl(pgcMain.ActivePage.Controls[n1]).Visible and TWinControl(pgcMain.ActivePage.Controls[n1]).Enabled and ((TWinControl(pgcMain.ActivePage.Controls[n1]).ClassType = TEdit) or (TWinControl(pgcMain.ActivePage.Controls[n1]).ClassType = TCombobox) or (TWinControl(pgcMain.ActivePage.Controls[n1]).ClassType = TCheckBox)) then
      begin
        TWinControl(pgcMain.ActivePage.Controls[n1]).SetFocus;
        break;
      end;
    end;
  end;
end;

procedure TfrmBaseInputDB.RefreshParentGrid(AFocusSelectedItem: Boolean);
begin
  if ParentForm <> nil then
  begin
    if ParentForm is TfrmBaseDBGrid then
    begin
      (ParentForm as TfrmBaseDBGrid).grd.DataSource.DataSet.Refresh;
      if AFocusSelectedItem then
      begin
        TfrmBaseDBGrid(ParentForm).Table.Id.Value := Table.Id.Value;
        TfrmBaseDBGrid(ParentForm).grd.DataSource.DataSet.Locate(Table.Id.FieldName, Table.Id.AsInteger, [loCaseInsensitive]);
      end;
    end;
  end;
end;

procedure TfrmBaseInputDB.RefreshDataAuto;
var
  vTable: TTable;
  nx: Integer;

  procedure SubSetControlValue(pParent: TControl; pFieldDB: TFieldDB);
  var
    vControl: TControl;
    n1, nVal: Integer;
  begin
    vControl := TWinControl(pParent).FindChildControl(PRX_EDIT + pFieldDB.FieldName);
    if Assigned(vControl) then
    begin
      if ((pFieldDB.DataType = ftDate)
      or (pFieldDB.DataType = ftDateTime))
      and (pFieldDB.Value = 0)
      then
        TEdit(vControl).Text := ''
      else
        TEdit(vControl).Text := pFieldDB.AsString;
      TEdit(vControl).thsDBFieldName := pFieldDB.FieldName;
      if pFieldDB.DataType = ftBCD then
        TEdit(vControl).Repaint;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_MEMO + pFieldDB.FieldName);
    if Assigned(vControl) then
    begin
      TMemo(vControl).Lines.Text := pFieldDB.AsString;
      TMemo(vControl).thsDBFieldName := pFieldDB.FieldName;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_COMBOBOX + pFieldDB.OtherFieldName);
    if Assigned(vControl) then
    begin
      for n1 := 0 to TCombobox(vControl).Items.Count-1 do
        if Assigned(TCombobox(vControl).Items.Objects[n1]) then
          if (TObject(TCombobox(vControl).Items.Objects[n1]).ClassType = TTable)
          or (TObject(TCombobox(vControl).Items.Objects[n1]).ClassParent = TTable)
          then
            if TryStrToInt(pFieldDB.Value, nVal) then
              if TTable(TCombobox(vControl).Items.Objects[n1]).Id.Value = pFieldDB.AsInt64 then
              begin
                TCombobox(vControl).ItemIndex := n1;
                TCombobox(vControl).thsDBFieldName := pFieldDB.FieldName;
                Break;
              end;

      if TCombobox(vControl).ItemIndex = -1 then
      begin
        TCombobox(vControl).ItemIndex := TCombobox(vControl).Items.IndexOf(pFieldDB.AsString);
        TCombobox(vControl).thsDBFieldName := pFieldDB.FieldName;
      end;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_CHECKBOX + pFieldDB.FieldName);
    if Assigned(vControl) then
    begin
      TCheckBox(vControl).Checked := pFieldDB.AsBoolean;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_RADIOGROUP + pFieldDB.FieldName);
    if Assigned(vControl) then
    begin
      TRadioGroup(vControl).ItemIndex := TRadioGroup(vControl).Items.IndexOf(pFieldDB.AsString);
    end;
  end;

  procedure SubSetControlValues(ATable: TTable);
  var
    LPgc, LParent: TControl;
    n1, n2: Integer;
  begin
    for n1 := 0 to Length(ATable.Fields)-1 do
    begin
      LPgc := pnlMain.FindChildControl(pgcMain.Name);
      if Assigned(LPgc) then
      begin
        for n2 := 0 to TPageControl(LPgc).PageCount-1 do
        begin
          LParent := TPageControl(LPgc).Pages[n2];
          SubSetControlValue(LParent, ATable.Fields[n1]);
        end;
      end
      else
      begin
        LParent := pnlMain;
        SubSetControlValue(LParent, ATable.Fields[n1]);
      end;
    end;
  end;
begin
  SubSetControlValues(Table);

  for nx := 0 to Length(Table.Fields)-1 do
  begin
    if (Table <> Table.Fields[nx].OwnerTable) and (Table.Fields[nx].OwnerTable <> nil) then
    begin
      vTable := Table.Fields[nx].OwnerTable;
      if Assigned(vTable) then
        SubSetControlValues(vTable);
    end;
  end;
end;

procedure TfrmBaseInputDB.ResetSession();
begin
  btnAccept.Enabled := false;
  btnDelete.Enabled := false;
  if not SetSession() then
  begin
    Self.Close;
    raise Exception.Create('Kullanıcı Erişim Hakkı hatası!');
  end;
end;

procedure TfrmBaseInputDB.SetControlDBProperty(pIsOnlyRepaint: Boolean);
var
  n1, n2, n3, nx: Integer;
  vPageControl, vParent: TControl;
  vTable: TTable;

  procedure SubSetControlProperty(AControl: TControl; pColumns: TFieldDB);
  begin
    if (pColumns = nil) or not Assigned(AControl) then
      Exit;

    if (AControl is TEdit) then
    begin
      with TEdit(AControl) do
      begin
        if pIsOnlyRepaint then
          Repaint
        else
        begin
          CharCase := VCL.StdCtrls.ecUpperCase;
          MaxLength := pColumns.Size;
          thsDBFieldName := pColumns.FieldName;
          thsRequiredData := not pColumns.IsNullable;
          thsActiveYear4Digit := GSysApplicationSetting.Donem.Value;
          OnCalculatorProcess := nil;

          if (pColumns.DataType = ftString) then
            thsInputDataType := itString
          else if (pColumns.DataType = ftByte) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 3;
          end
          else if (pColumns.DataType = ftSmallint) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 5;
          end
          else if (pColumns.DataType = ftInteger) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 10;
          end
          else if (pColumns.DataType = ftLargeint) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 19;
          end
          else if (pColumns.DataType = ftDate) then
          begin
            thsInputDataType := itDate;
            MaxLength := 10
          end
          else if (pColumns.DataType = ftTime) then
          begin
            thsInputDataType := itTime;
            MaxLength := 5
          end
          else if (pColumns.DataType = ftDateTime) then
          begin
            thsInputDataType := itDate;
            MaxLength := 19;
          end
          else if (pColumns.DataType = ftFloat) then
          begin
            thsInputDataType := itFloat;
          end
          else if (pColumns.DataType = ftBCD) then
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
        if pIsOnlyRepaint then
          Repaint
        else
        begin
          CharCase := VCL.StdCtrls.ecUpperCase;
          MaxLength := pColumns.Size;
          thsDBFieldName := pColumns.FieldName;
          thsRequiredData := not pColumns.IsNullable;

          if (pColumns.DataType = ftString) then
            thsInputDataType := itString
          else if (pColumns.DataType = ftByte) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 3;
          end
          else if (pColumns.DataType = ftSmallint) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 5;
          end
          else if (pColumns.DataType = ftInteger) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 10;
          end
          else if (pColumns.DataType = ftLargeint) then
          begin
            thsInputDataType := itInteger;
            MaxLength := 19;
          end
          else if (pColumns.DataType = ftDate) then
          begin
            thsInputDataType := itDate;
            MaxLength := 10
          end
          else if (pColumns.DataType = ftTime) then
          begin
            thsInputDataType := itTime;
            MaxLength := 5
          end
          else if (pColumns.DataType = ftDateTime) then
          begin
            thsInputDataType := itDate;
            MaxLength := 19;
          end
          else if (pColumns.DataType = ftFloat) then
          begin
            thsInputDataType := itFloat;
          end
          else if (pColumns.DataType = ftBCD) then
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
        if pIsOnlyRepaint then
          Repaint
        else
        begin
          CharCase := VCL.StdCtrls.ecUpperCase;
          MaxLength := pColumns.Size;
          thsDBFieldName := pColumns.FieldName;
          thsRequiredData := not pColumns.IsNullable;

          thsInputDataType := itString;
          if (pColumns.DataType = ftString) then
            thsInputDataType := itString
          else if (pColumns.DataType = ftByte) then
          begin
            thsInputDataType := itInteger;
          end
          else if (pColumns.DataType = ftSmallint) then
          begin
            thsInputDataType := itInteger;
          end
          else if (pColumns.DataType = ftInteger) then
          begin
            thsInputDataType := itInteger;
          end
          else if (pColumns.DataType = ftLargeint) then
          begin
            thsInputDataType := itInteger;
          end

          else if (pColumns.DataType = ftDate) then
          begin
            thsInputDataType := itDate;
          end
          else if (pColumns.DataType = ftTime) then
          begin
            thsInputDataType := itTime;
          end
          else if (pColumns.DataType = ftDateTime) then
          begin
            thsInputDataType := itDate;
          end
          else if (pColumns.DataType = ftFloat) then
          begin
            thsInputDataType := itFloat;
          end
          else if (pColumns.DataType = ftBCD) then
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

begin
  vPageControl := pnlMain.FindChildControl(pgcMain.Name);
  //Main panel içindeki pagecontrol içinde sekme olarak kullanılan kontroller
  if Assigned(vPageControl) then
  begin
    for n1 := 0 to TPageControl(vPageControl).PageCount-1 do
    begin
      vParent := TPageControl(vPageControl).Pages[n1];
      for n2 := 0 to TTabSheet(vParent).ControlCount-1 do
      begin
        if (TTabSheet(vParent).Controls[n2].ClassType = TEdit)
        or (TTabSheet(vParent).Controls[n2].ClassType = TMemo)
        or (TTabSheet(vParent).Controls[n2].ClassType = TCombobox)
        or (TTabSheet(vParent).Controls[n2].ClassType = TCheckBox)
        or (TTabSheet(vParent).Controls[n2].ClassType = TRadioGroup)
        then
        begin
          for n3 := 0 to Length(Table.Fields)-1 do
          begin
            if Table.Fields[n3].FieldName = RightStr(TTabSheet(vParent).Controls[n2].Name, Length(TTabSheet(vParent).Controls[n2].Name)- 3{prefix length edtstok_kodu > stok_kodu}) then
            begin
              SubSetControlProperty(TTabSheet(vParent).Controls[n2], Table.Fields[n3]);
              Break;
            end;
          end;
        end;
      end;
    end;

    for nx := 0 to Length(Table.Fields)-1 do
    begin
      if (Table <> Table.Fields[nx].OwnerTable) and (Table.Fields[nx].OwnerTable <> nil) then
      begin
        vTable := Table.Fields[nx].OwnerTable;
        if Assigned(vTable) and (vTable <> nil) then
        begin
          for n1 := 0 to TPageControl(vPageControl).PageCount-1 do
          begin
            vParent := TPageControl(vPageControl).Pages[n1];
            for n2 := 0 to TTabSheet(vParent).ControlCount-1 do
            begin
              if (TTabSheet(vParent).Controls[n2].ClassType = TEdit)
              or (TTabSheet(vParent).Controls[n2].ClassType = TMemo)
              or (TTabSheet(vParent).Controls[n2].ClassType = TCombobox)
              or (TTabSheet(vParent).Controls[n2].ClassType = TCheckBox)
              or (TTabSheet(vParent).Controls[n2].ClassType = TRadioGroup)
              then
              begin
                for n3 := 0 to Length(vTable.Fields)-1 do
                begin
                  if vTable.Fields[n3].FieldName = RightStr(TTabSheet(vParent).Controls[n2].Name, Length(TTabSheet(vParent).Controls[n2].Name)- 3{prefix length edtstok_kodu > stok_kodu}) then
                  begin
                    SubSetControlProperty(TTabSheet(vParent).Controls[n2], vTable.Fields[n3]);
                    Break;
                  end;
                end;
              end;
            end;
          end;

        end;
      end;
    end;

  end
  else  //Main panel içinde kullanılan kontroller
  begin
    //ilk önce sınıfa ait tüm kontrolleri düzenle
    //daha sonra table sınıfı taranacak ve içinde ttable tipinden bir field varsa
    //table sınıfı bulunup buradan bilgileri çekilecek.
    //Bu çekilen column bilgilerine uyan kontrol varmı diye tüm hepsi taranacak ve bulunanlar için bilgiler set edilecek
    vParent := pnlMain;
    for n2 := 0 to TPanel(vParent).ControlCount-1 do
    begin
      if (TPanel(vParent).Controls[n2].ClassType = TEdit)
      or (TPanel(vParent).Controls[n2].ClassType = TMemo)
      or (TPanel(vParent).Controls[n2].ClassType = TCombobox)
      or (TPanel(vParent).Controls[n2].ClassType = TCheckBox)
      or (TPanel(vParent).Controls[n2].ClassType = TRadioGroup)
      then
      begin
        for n3 := 0 to Length(Table.Fields)-1 do
        begin
          if Table.Fields[n3].FieldName = RightStr(TPanel(vParent).Controls[n2].Name, Length(TPanel(vParent).Controls[n2].Name)- 3{prefix length edtstok_kodu > stok_kodu}) then
          begin
            SubSetControlProperty(TPanel(vParent).Controls[n2], Table.Fields[n3]);
            Break;  //n3 dögüsünü kır n2 den devam et
          end;
        end;
      end;
    end;

    for nx := 0 to Length(Table.Fields)-1 do
    begin
      if (Table <> Table.Fields[nx].OwnerTable) and (Table.Fields[nx].OwnerTable <> nil) then
      begin
        vTable := Table.Fields[nx].OwnerTable;
        if Assigned(vTable) and (vTable <> nil) then
        begin
          for n2 := 0 to TPanel(vParent).ControlCount-1 do
          begin
            if (TPanel(vParent).Controls[n2].ClassType = TEdit)
            or (TPanel(vParent).Controls[n2].ClassType = TMemo)
            or (TPanel(vParent).Controls[n2].ClassType = TCombobox)
            or (TPanel(vParent).Controls[n2].ClassType = TCheckBox)
            or (TPanel(vParent).Controls[n2].ClassType = TRadioGroup)
            then
            begin
              for n3 := 0 to Length(vTable.Fields)-1 do
              begin
                if vTable.Fields[n3].FieldName = RightStr(TPanel(vParent).Controls[n2].Name, Length(TPanel(vParent).Controls[n2].Name)- 3{prefix length edtstok_kodu > stok_kodu}) then
                begin
                  SubSetControlProperty(TPanel(vParent).Controls[n2], vTable.Fields[n3]);
                  Break;  //n3 dögüsünü kır n2 den devam et
                end;
              end;
            end;
          end;

        end;
      end;
    end;

  end;
end;

function TfrmBaseInputDB.SetSession():Boolean;
var
  vUpdate, vDelete: Boolean;
begin
  vUpdate := False;
  vDelete := False;

  Result := False;

  if Assigned(Table) then
  begin
    if Table.IsAuthorized(ptUpdate, True, False) then
    begin
      Result := True;
      vUpdate := True;
    end;

    if Table.IsAuthorized(ptDelete, True, False) then
    begin
      //if you have the right to delete, enable accept button
      btnDelete.Enabled := True;
      Result := True;
      vDelete := True;
    end;

    if Table.IsAuthorized(ptSpecial, True, False) then
    begin
      //enable special property
      Result := True;
    end;
  end;

  //if you have the right to update or delete, enable accept button
  //for the delete or update confirmation
  if vUpdate or vDelete then
    btnAccept.Enabled := True;
end;

procedure TfrmBaseInputDB.stbBaseDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  vIco: Integer;
begin
  stbBase.Canvas.Font.Name := DefaultFontName;
  stbBase.Canvas.Font.Style := [fsBold];

  stbBase.Canvas.TextRect(Rect,
    Rect.Left + dm.il16.Width + 4,
    Rect.Top + (stbBase.Height-Canvas.TextHeight(Panel.Text)) div 2 - 2,
    Panel.Text);

  vIco := -1;
  case Panel.Index of
    STATUS_SQL_SERVER:
    begin
      if Panel.Text <> '' then
        vIco := IMG_QUALITY
      else
        vIco := -1;
    end;
  end;

  if vIco > -1 then
  begin
    dm.il16.Draw(StatusBar.Canvas, Rect.Left, Rect.Top, vIco);
    Panel.Width := stbBase.Width;
  end;
end;

end.
