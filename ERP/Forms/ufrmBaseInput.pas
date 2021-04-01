unit ufrmBaseInput;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Classes
  , System.Math
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.ComCtrls
  , Dialogs
  , System.Variants
  , Vcl.Samples.Spin
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.Graphics
  , Vcl.AppEvnts
  , Vcl.Menus
  , System.StrUtils
  , System.Rtti
  , Data.DB

  , FireDAC.Stan.Option
  , FireDAC.Stan.Intf
  , FireDAC.Comp.Client
  , FireDAC.Stan.Error
  , FireDAC.UI.Intf
  , FireDAC.Stan.Def
  , FireDAC.Stan.Pool
  , FireDAC.Stan.Async
  , FireDAC.Phys
  , FireDAC.VCLUI.Wait

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.Memo
  , Ths.Erp.Helper.ComboBox

  , udm
  , ufrmBase
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.View.SysViewColumns
  ;

type
  TfrmBaseInput = class(TfrmBase)
    pmLabels: TPopupMenu;
    mniAddLanguageContent: TMenuItem;
    mniEditFormTitleByLang: TMenuItem;
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    procedure btnCloseClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure mniAddLanguageContentClick(Sender: TObject);
    procedure RefreshData(); virtual;
    procedure mniEditFormTitleByLangClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); override;

    /// <summary>
    ///  InputDB formlarýndaki Edit Memo ComboBox gibi kontrollerin zorunlu alan, maks leng, charcase gibi özelliklerini form ilk açýlýþta ayarlýyor.
    /// </summary>
    ///  <remarks>
    ///  NOT: Bu kontroller direkt olarak pnlMain üzerinde veya pgcMain içindeki TabSheet ler içinde olmalý
    ///  </remarks>
    procedure SetControlDBProperty(pIsOnlyRepaint: Boolean = False; AParent: TControl = nil);

    procedure OnCalculate(Sender: TObject);
  private
    FSysTableInfo: TSysViewColumns;
  published
    function getContainTable(pTable: TTable): TTable;
  protected
  public
    procedure SetControlsDisabledOrEnabled(pPanelGroupboxPagecontrolTabsheet: TWinControl = nil; pIsDisable: Boolean = True);
    procedure SetCaptionFromLangContent();
    procedure SetLabelPopup(Sender: TControl = nil);

    /// <summary>
    ///  Table sýnýfýndaki field özelliklerini almak için kullanýlýyor.
    /// </summary>
    property SysTableInfo: TSysViewColumns read FSysTableInfo write FSysTableInfo;
  published
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Constants
  , Ths.Erp.Database.Table.SysLisanGuiIcerik
  , Ths.Erp.Database.Table.SysKaliteFormTipi
  , ufrmSysLisanGuiIcerik
  , ufrmCalculator
  ;

{$R *.dfm}

procedure TfrmBaseInput.btnCloseClick(Sender: TObject);
begin
  if (FormMode = ifmRewiev) then
    inherited
  else
  begin
    if (CustomMsgDlg(
      TranslateText('Are you sure you want to exit?   All changes will be canceled!!!', FrameworkLang.MessageCloseWindow, LngMsgData, LngSystem),
      mtConfirmation, mbYesNo, [TranslateText('Yes', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem),
                                TranslateText('No', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)], mbNo,
                                TranslateText('Confirmation', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem)) = mrYes)
    then
      inherited;
  end;
end;

procedure TfrmBaseInput.FormCreate(Sender: TObject);
begin
  inherited;

  if Assigned(Table) then
  begin
    FSysTableInfo := TSysViewColumns.Create(Table.Database);
    FSysTableInfo.SelectToList(' AND ' + FSysTableInfo.TableName + '.' + FSysTableInfo.OrjTableName.FieldName + '=' + QuotedStr(Table.TableName), False, False);
  end;

  pmLabels.Images := dm.il16;
  mniAddLanguageContent.ImageIndex := IMG_ADD_DATA;

  if Assigned(Table) then
    GSysOndalikHane.SelectToList('', False, False);

  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;
end;

procedure TfrmBaseInput.FormDestroy(Sender: TObject);
begin
  FSysTableInfo.Free;
  inherited;
end;

procedure TfrmBaseInput.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = VK_F12 then
  begin
    if Sender.ClassType = Self.ClassType then
      TfrmCalculator.Create(Owner).ShowModal;
  end

end;

procedure TfrmBaseInput.FormShow(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  stbBase.Panels.Add;
  for n1 := 0 to stbBase.Panels.Count - 1 do
    stbBase.Panels.Items[n1].Style := psOwnerDraw;

  //Kalite standartlarýna göre uygulama pencerelerinde Form Numarasý
  //olmasý isteniyorsa bu durumda
  //
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
end;

function TfrmBaseInput.getContainTable(pTable: TTable): TTable;
var
  ctx: TRttiContext;
  typ: TRttiType;
//  fld: TRttiField;
  prp: TRttiProperty;
  AValue: TValue;
  AObject: TObject;
begin
  Result := nil;
  typ := ctx.GetType(pTable.ClassType);
  if Assigned(typ) then
    for prp in typ.GetProperties do
      if Assigned(prp) then
        if prp.PropertyType is TRttiInstanceType then
          if TRttiInstanceType(prp.PropertyType).MetaclassType.InheritsFrom(TTable) then
          begin
            AValue := prp.GetValue(pTable);
            AObject := nil;
            if not AValue.IsEmpty then
              AObject := AValue.AsObject;

            if Assigned(AObject) then
              if AObject.InheritsFrom(TTable) then
                if Assigned(TTable(TFieldDB(AObject))) then
                  Result := TTable(TFieldDB(AObject));
          end;

              {
    for fld in typ.GetFields do
      if Assigned(fld) then
        if fld.FieldType is TRttiInstanceType then
          if TRttiInstanceType(fld.FieldType).MetaclassType.InheritsFrom(TTable) then
          begin
            AValue := fld.GetValue(pTable);
            AObject := nil;
            if not AValue.IsEmpty then
              AObject := AValue.AsObject;

            if Assigned(AObject) then
              if AObject.InheritsFrom(TTable) then
                if Assigned(TTable(TFieldDB(AObject))) then
                  Result := TTable(TFieldDB(AObject));
          end;    }
end;

procedure TfrmBaseInput.mniAddLanguageContentClick(Sender: TObject);
var
  vSysLangGuiContent: TSysLisanGuiIcerik;
  vCode, vValue, vContentType, vTableName: string;
begin
  if pmLabels.PopupComponent.ClassType = TLabel then
  begin
    vCode := StringReplace(pmLabels.PopupComponent.Name, PRX_LABEL, '', [rfReplaceAll]);
    vContentType := LngLabelCaption;
    vTableName := ReplaceRealColOrTableNameTo(Table.TableName);
    vValue := TLabel(pmLabels.PopupComponent).Caption;
  end
  else
  if pmLabels.PopupComponent.ClassType = TTabSheet then
  begin
    vCode := StringReplace(pmLabels.PopupComponent.Name, PRX_TABSHEET, '', [rfReplaceAll]);
    vContentType := LngTab;
    vTableName := ReplaceRealColOrTableNameTo(Table.TableName);
    vTableName := Self.Name;
    vValue := TTabSheet(pmLabels.PopupComponent).Caption;
  end;


  vSysLangGuiContent := TSysLisanGuiIcerik.Create(GDataBase);

  vSysLangGuiContent.Lisan.Value := GDataBase.ConnSetting.Language;
  vSysLangGuiContent.Kod.Value := vCode;
  vSysLangGuiContent.IcerikTipi.Value := vContentType;
  vSysLangGuiContent.TabloAdi.Value := vTableName;
  vSysLangGuiContent.Deger.Value := vValue;

  TfrmSysLisanGuiIcerik.Create(Self, nil, vSysLangGuiContent, ifmCopyNewRecord, fomNormal, ivmSort).ShowModal;

  SetCaptionFromLangContent();
end;

procedure TfrmBaseInput.mniEditFormTitleByLangClick(Sender: TObject);
begin
  CreateLangGuiContentFormforFormCaption;
end;

procedure TfrmBaseInput.OnCalculate(Sender: TObject);
begin
  TfrmCalculator.Create(Application).ShowModal;
end;

procedure TfrmBaseInput.RefreshData;
begin
  //
end;

procedure TfrmBaseInput.SetLabelPopup(Sender: TControl);
var
  n1: Integer;
  n2: Integer;
begin
  if Sender = nil then
  begin
    Sender := pnlMain;
    SetLabelPopup(Sender);
  end;


  for n1 := 0 to TWinControl(Sender).ControlCount-1 do
  begin
    if TWinControl(Sender).Controls[n1].ClassType = TPageControl then
    begin
      for n2 := 0 to TPageControl(TWinControl(Sender).Controls[n1]).PageCount-1 do
      begin
        TPageControl(TWinControl(Sender).Controls[n1]).Pages[n2].PopupMenu := pmLabels;
      end;
      SetLabelPopup(TWinControl(Sender).Controls[n1]);
    end
    else if TWinControl(Sender).Controls[n1].ClassType = TTabSheet then
    begin
      TTabSheet(TWinControl(Sender).Controls[n1]).PopupMenu := pmLabels;
      SetLabelPopup(TWinControl(Sender).Controls[n1]);
    end
    else if TWinControl(Sender).Controls[n1].ClassType = TLabel then
    begin
      TLabel(TWinControl(Sender).Controls[n1]).PopupMenu := pmLabels;
    end;
  end;

end;

procedure TfrmBaseInput.WmAfterShow(var Msg: TMessage);
begin
  inherited;
  //
end;

procedure TfrmBaseInput.SetCaptionFromLangContent;

  procedure SubSetLabelCaption();
  var
    vCtx1: TRttiContext;
    vRtf1: TRttiField;
    vRtt1: TRttiType;
    vLabel: TLabel;
    n1: Integer;
    vLabelNames, vLabelName, vFilter: string;
    vSysLangGuiContent: TSysLisanGuiIcerik;
  begin
    //label component isimleri lbl + db_field_name olacak þekilde verileceði varsayýlarak bu kod yazildi. örnek: lblcountry_code
    vLabelNames := '';
    vCtx1 := TRttiContext.Create;
    vRtt1 := vCtx1.GetType(Self.ClassType);
    for vRtf1 in vRtt1.GetFields do
      if vRtf1.FieldType.Name = TLabel.ClassName then
      begin
        vLabel := TLabel(FindComponent(vRtf1.Name));
        if Assigned(vLabel) then
          vLabelNames := vLabelNames + QuotedStr(StringReplace(TLabel(vLabel).Name, PRX_LABEL, '', [rfReplaceAll])) + ', ';
      end;

    vLabelNames := Trim(vLabelNames);
    if Length(vLabelNames) > 0 then
      vLabelNames := LeftStr(vLabelNames, Length(vLabelNames)-1);

    vSysLangGuiContent := TSysLisanGuiIcerik.Create(GDataBase);
    try
      if Assigned(Table) then
        vFilter :=  ' AND ' + vSysLangGuiContent.TableName + '.' + vSysLangGuiContent.TabloAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(Table.TableName))
      else
        vFilter :=  ' AND ' + vSysLangGuiContent.TableName + '.' + vSysLangGuiContent.FormAdi.FieldName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(Self.Name));
      vSysLangGuiContent.SelectToList(
          ' AND ' + vSysLangGuiContent.TableName + '.' + vSysLangGuiContent.Lisan.FieldName + '=' + QuotedStr(GDataBase.ConnSetting.Language) +
          ' AND ' + vSysLangGuiContent.TableName + '.' + vSysLangGuiContent.Kod.FieldName + ' IN (' +  vLabelNames + ')' +
          ' AND ' + vSysLangGuiContent.TableName + '.' + vSysLangGuiContent.IcerikTipi.FieldName + '=' + QuotedStr(LngLabelCaption) +
          vFilter, False, False);
      for n1 := 0 to vSysLangGuiContent.List.Count-1 do
      begin
        if not VarIsNull(TSysLisanGuiIcerik(vSysLangGuiContent.List[n1]).Kod.Value) then
        begin
          vLabelName := VarToStr(TSysLisanGuiIcerik(vSysLangGuiContent.List[n1]).Kod.Value);
          vLabel := TLabel(FindComponent(PRX_LABEL + vLabelName));
          if not VarIsNull(TSysLisanGuiIcerik(vSysLangGuiContent.List[n1]).Deger.Value) then
            TLabel(vLabel).Caption := VarToStr(TSysLisanGuiIcerik(vSysLangGuiContent.List[n1]).Deger.Value);
        end;
      end;
    finally
      vSysLangGuiContent.Free;
    end;
  end;

  procedure SubSetTabSheetCaption();
  var
    vCtx1: TRttiContext;
    vRtf1: TRttiField;
    vRtt1: TRttiType;
    vTabSheet: TTabSheet;
  begin
    if Assigned(Table) then
    begin
      //TAB SHEET Captionlarý düzenle
      vCtx1 := TRttiContext.Create;
      vRtt1 := vCtx1.GetType(Self.ClassType);
      for vRtf1 in vRtt1.GetFields do
        if vRtf1.FieldType.Name = TTabSheet.ClassName then
        begin
          vTabSheet := TTabSheet(FindComponent(vRtf1.Name));
          if Assigned(vTabSheet) then
            TTabSheet(vTabSheet).Caption :=
                TranslateText(TTabSheet(vTabSheet).Caption,
                StringReplace(TTabSheet(vTabSheet).Name, PRX_TABSHEET, '', [rfReplaceAll]),
                LngTab,
                {ReplaceRealColOrTableNameTo(Table.TableName)}Self.Name
                );
        end;
    end;
  end;
begin
  if GDataBase.Connection.Connected then
  begin
    SubSetTabSheetCaption;
    SubSetLabelCaption;
  end;
end;

procedure TfrmBaseInput.SetControlDBProperty(pIsOnlyRepaint: Boolean; AParent: TControl);
var
  n1, I1, I2: Integer;
  vControl, vPageControl, vParent, LContainer: TControl;

  AEdit: TEdit;
  ACombo: TComboBox;
  AMemo: TMemo;

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
      AEdit := TEdit(vControl);
      if pIsOnlyRepaint then
        AEdit.Repaint
      else begin
        AEdit.CharCase := VCL.StdCtrls.ecUpperCase;
        AEdit.MaxLength := pColumns.CharacterMaximumLength.Value;
        AEdit.thsDBFieldName := pColumns.OrjColumnName.Value;
        AEdit.thsRequiredData := pColumns.IsNullable.Value = 'NO';
        AEdit.thsActiveYear4Digit := GSysUygulamaAyari.Donem.Value;
        AEdit.OnCalculatorProcess := nil;

        if (pColumns.DataType.Value = 'text')
        or (pColumns.DataType.Value = 'character varying')
        then
          AEdit.thsInputDataType := itString
        else
        if (pColumns.DataType.Value = 'smallint')
        or (pColumns.DataType.Value = 'integer')
        or (pColumns.DataType.Value = 'bigint')
        then begin
          AEdit.thsInputDataType := itInteger;
          AEdit.OnCalculatorProcess := OnCalculate;

          if (pColumns.DataType.Value = 'smallint') then
            AEdit.MaxLength := 5
          else if (pColumns.DataType.Value = 'integer') then
            AEdit.MaxLength := 10
          else if (pColumns.DataType.Value = 'bigint') then
            AEdit.MaxLength := 19;
        end
        else
        if (pColumns.DataType.Value = 'date')
        or (pColumns.DataType.Value = 'timestamp without time zone')
        then begin
          AEdit.thsInputDataType := itDate;

          if (pColumns.DataType.Value = 'date') then
            AEdit.MaxLength := 10
          else if (pColumns.DataType.Value = 'timestamp without time zone') then
            AEdit.MaxLength := 19;
        end
        else if (pColumns.DataType.Value = 'double precision')
        then begin
          AEdit.thsInputDataType := itFloat;
          AEdit.OnCalculatorProcess := OnCalculate;
        end
        else if (pColumns.DataType.Value = 'numeric')
        then begin
          AEdit.thsInputDataType := itMoney;
          AEdit.Alignment := taRightJustify;
          AEdit.OnCalculatorProcess := OnCalculate;
        end;
      end;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_MEMO + vColName);
    if Assigned(vControl) then
    begin
      AMemo := TMemo(vControl);
      if pIsOnlyRepaint then
        AMemo.Repaint
      else begin
        AMemo.CharCase := VCL.StdCtrls.ecUpperCase;
        AMemo.MaxLength := pColumns.CharacterMaximumLength.Value;
        AMemo.thsDBFieldName := pColumns.OrjColumnName.Value;
        AMemo.thsRequiredData := pColumns.IsNullable.Value = 'NO';

        if (pColumns.DataType.Value = 'text')
        or (pColumns.DataType.Value = 'character varying') then
          AMemo.thsInputDataType := itString
        else
        if (pColumns.DataType.Value = 'smallint')
        or (pColumns.DataType.Value = 'integer')
        or (pColumns.DataType.Value = 'bigint')
        then begin
          AMemo.thsInputDataType := itInteger;

          if (pColumns.DataType.Value = 'smallint') then
            AMemo.MaxLength := 5
          else if (pColumns.DataType.Value = 'integer') then
            AMemo.MaxLength := 10
          else if (pColumns.DataType.Value = 'bigint') then
            AMemo.MaxLength := 19;
        end
        else
        if (pColumns.DataType.Value = 'date')
        or (pColumns.DataType.Value = 'timestamp without time zone')
        then begin
          AMemo.thsInputDataType := itDate;

          if (pColumns.DataType.Value = 'date')
          then  AMemo.MaxLength := 10
          else if (pColumns.DataType.Value = 'timestamp without time zone')
          then  AMemo.MaxLength := 19;
        end
        else if (pColumns.DataType.Value = 'double precision')
        then  AMemo.thsInputDataType := itFloat
        else if (pColumns.DataType.Value = 'numeric') then begin
          AMemo.thsInputDataType := itMoney;
          AMemo.Alignment := taRightJustify;
        end;
      end;
    end;
    vControl := TWinControl(pParent).FindChildControl(PRX_COMBOBOX + vColName);
    if Assigned(vControl) then
    begin
      ACombo := TCombobox(vControl);
      if pIsOnlyRepaint then
        ACombo.Repaint
      else begin
        ACombo.CharCase := VCL.StdCtrls.ecUpperCase;
        if (pColumns.DataType.Value = 'smallint') then
          ACombo.MaxLength := IfThen(pColumns.CharacterMaximumLength.Value > 5, 5, pColumns.CharacterMaximumLength.Value);
        ACombo.thsDBFieldName := pColumns.OrjColumnName.Value;
        ACombo.thsRequiredData := pColumns.IsNullable.Value = 'NO';

        ACombo.thsInputDataType := itString;

        if (pColumns.DataType.Value = 'text')
        or (pColumns.DataType.Value = 'character varying')
        then  ACombo.thsInputDataType := itString
        else
        if (pColumns.DataType.Value = 'integer')
        or (pColumns.DataType.Value = 'bigint')
        or (pColumns.DataType.Value = 'smallint')
        then  ACombo.thsInputDataType := itInteger
        else
        if (pColumns.DataType.Value = 'date')
        or (pColumns.DataType.Value = 'timestamp without time zone')
        then  ACombo.thsInputDataType := itDate
        else if (pColumns.DataType.Value = 'double precision')
        then  ACombo.thsInputDataType := itFloat
        else if (pColumns.DataType.Value = 'numeric')
        then  ACombo.thsInputDataType := itMoney;
      end;
    end;
  end;

begin
  if AParent = nil then
    LContainer := pnlMain
  else
    LContainer := AParent;

//  if LContainer is TPanel then
    for I1 := 0 to TPanel(LContainer).ControlCount-1 do
    begin
      if TPanel(LContainer).Controls[I1] is TPanel then
        SetControlDBProperty(pIsOnlyRepaint, TPanel(LContainer).Controls[I1]);

      if TPanel(LContainer).Controls[I1] is TPageControl then
      begin
        vPageControl := TPageControl(TPanel(LContainer).Controls[I1]);
        for I2 := 0 to TPageControl(vPageControl).PageCount-1 do
        begin
          vParent := TPageControl(vPageControl).Pages[I2];
          for n1 := 0 to FSysTableInfo.List.Count-1 do
            SubSetControlProperty(vParent, TSysViewColumns(FSysTableInfo.List[n1]));
        end;
      end;
    end;


    //is_contain_table(Table) evet ise control set yap hayýr ise çýk
    //burasý tablo içinde alt tablo varsa bunu buluyor ve kontrol düzenlemesi yapýyor.
    //þu anda bir tane alt tablo bulacak þekilde çalýþýyor. Burasý düzenlenecek.
    //Örn. Hesap Kartý içinde Adres tablosunu buluyor
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
                      for I1 := 0 to pnlMain.ControlCount-1 do
                      begin
                        if pnlMain.Controls[I1] is TPageControl then
                        begin
                          vPageControl := pnlMain.Controls[I1];
                          for I2 := 0 to TPageControl(vPageControl).PageCount-1 do
                          begin
                            vParent := TPageControl(vPageControl).Pages[I2];
                            for n1 := 0 to vSysTableInfo.List.Count-1 do
                              SubSetControlProperty(vParent, TSysViewColumns(vSysTableInfo.List[n1]));
                          end;
                        end;
                      end;
                end
      finally
        vSysTableInfo.Free;
      end;
    end;


{
  vPageControl := pnlMain.FindChildControl(pgcMain.Name);
  if Assigned(vPageControl) then
  begin
    for n1 := 0 to TPageControl(vPageControl).PageCount-1 do
    begin
      vParent := TPageControl(vPageControl).Pages[n1];
      for n2 := 0 to SysTableInfo.List.Count-1 do
        SubSetControlProperty(vParent, TSysViewColumns(SysTableInfo.List[n2]));
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
    for n1 := 0 to SysTableInfo.List.Count-1 do
      SubSetControlProperty(vParent, TSysViewColumns(SysTableInfo.List[n1]));
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
}
end;

procedure TfrmBaseInput.SetControlsDisabledOrEnabled(pPanelGroupboxPagecontrolTabsheet: TWinControl; pIsDisable: Boolean);
var
  nIndex: Integer;
  PanelContainer: TWinControl;
begin
  PanelContainer := nil;

  if pPanelGroupboxPagecontrolTabsheet = nil then
    PanelContainer := pnlMain
  else
  begin
    if pPanelGroupboxPagecontrolTabsheet.ClassType = TPanel then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TPanel
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TGroupBox then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TGroupBox
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TPageControl then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TPageControl
    else if pPanelGroupboxPagecontrolTabsheet.ClassType = TTabSheet then
      PanelContainer := pPanelGroupboxPagecontrolTabsheet as TTabSheet;
  end;

  for nIndex := 0 to PanelContainer.ControlCount-1 do
  begin
    if PanelContainer.Controls[nIndex].ClassType = TPanel then
      SetControlsDisabledOrEnabled(PanelContainer.Controls[nIndex] as TPanel, pIsDisable)
    else if PanelContainer.Controls[nIndex].ClassType = TGroupBox then
      SetControlsDisabledOrEnabled(PanelContainer.Controls[nIndex] as TGroupBox, pIsDisable)
    else if PanelContainer.Controls[nIndex].ClassType = TPageControl then
      SetControlsDisabledOrEnabled(PanelContainer.Controls[nIndex] as TPageControl, pIsDisable)
    else if PanelContainer.Controls[nIndex].ClassType = TTabSheet then
      SetControlsDisabledOrEnabled(PanelContainer.Controls[nIndex] as TTabSheet, pIsDisable)
    else if (TControl(PanelContainer.Controls[nIndex]).ClassType = TEdit) then
      TEdit(PanelContainer.Controls[nIndex]).ReadOnly := pIsDisable
    else if (TControl(PanelContainer.Controls[nIndex]).ClassType = TComboBox) then
      TComboBox(PanelContainer.Controls[nIndex]).Enabled := (pIsDisable = False)
    else if (TControl(PanelContainer.Controls[nIndex]).ClassType = TMemo) then
      TMemo(PanelContainer.Controls[nIndex]).ReadOnly := pIsDisable
    else if (TControl(PanelContainer.Controls[nIndex]).ClassType = TCheckBox) then
      TCheckBox(PanelContainer.Controls[nIndex]).Enabled := (pIsDisable = False)
    else if (TControl(PanelContainer.Controls[nIndex]).ClassType = TRadioGroup) then
      TRadioGroup(PanelContainer.Controls[nIndex]).Enabled := (pIsDisable = False)
    else if (TControl(PanelContainer.Controls[nIndex]).ClassType = TRadioButton) then
      TRadioButton(PanelContainer.Controls[nIndex]).Enabled := (pIsDisable = False);
  end;
end;

end.
