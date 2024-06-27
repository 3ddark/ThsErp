unit ufrmBaseInput;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math,
  System.StrUtils, System.Rtti, System.Variants, Vcl.Controls, Vcl.Forms,
  Vcl.ComCtrls, Dialogs, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Graphics, Vcl.AppEvnts, Vcl.Menus, Data.DB, udm, ufrmBase,
  Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox, Ths.Helper.BaseTypes,
  Ths.Database, Ths.Database.Table, Ths.Database.Table.View.SysViewColumns;

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
    ///  InputDB formlarındaki Edit Memo ComboBox gibi kontrollerin zorunlu alan, maks leng, charcase gibi özelliklerini form ilk açılışta ayarlıyor.
    /// </summary>
    ///  <remarks>
    ///  NOT: Bu kontroller direkt olarak pnlMain üzerinde veya pgcMain içindeki TabSheet ler içinde olmalı
    ///  </remarks>
    procedure SetControlDBProperty(pIsOnlyRepaint: Boolean = False; AParent: TControl = nil);

    procedure OnCalculate(Sender: TObject);
  published
    function getContainTable(pTable: TTable): TTable;
  protected
  public
    procedure SetControlsDisabledOrEnabled(pPanelGroupboxPagecontrolTabsheet: TWinControl = nil; pIsDisable: Boolean = True);
    procedure SetCaptionFromLangContent();
    procedure SetLabelPopup(Sender: TControl = nil);
  published
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SysGuiIcerikler,
  ufrmSysGuiIcerik,
  ufrmCalculator;

{$R *.dfm}

procedure TfrmBaseInput.btnCloseClick(Sender: TObject);
begin
  if (FormMode = ifmRewiev) then
    inherited
  else
  begin
    if CustomMsgDlg('Çıkmak istediğinden emin misin?' + AddLBs(2) +
                    'Yapılan tüm değişiklikler kaybolacaktır',
                    mtConfirmation,
                    mbYesNo, ['Evet', 'Hayır'], mbNo, 'Kullanıcı Onayı'
    ) = mrYes
    then
      inherited;
  end;
end;

procedure TfrmBaseInput.FormCreate(Sender: TObject);
begin
  inherited;

  pmLabels.Images := dm.il16;
  mniAddLanguageContent.ImageIndex := IMG_ADD_DATA;

  pnlBottom.Visible := False;
  stbBase.Visible := True;
  pnlBottom.Visible := True;
end;

procedure TfrmBaseInput.FormDestroy(Sender: TObject);
begin
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

  //form ve page control page 0 caption bilgisini dil dosyasına göre doldur
  //page control page 0 için isternise miras alan formda değişiklik yapılabilir.
  if Assigned(Table) then
  begin
    Self.Caption := getFormCaptionByLang(Self.Name, Self.Caption);
    //pgcMain.Pages[0].Caption := Self.Caption;
  end;

  //burası yukarıdaki caption doldurma kodundan sonra gelmeli pagecontrol tablardaki başlıkları düzenliyor.
  SetCaptionFromLangContent();

  if Self.FormMode = ifmRewiev then
  begin
    //eğer başka pencerede açık transaction varsa güncelleme moduna hiç girilmemli
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
    //yeni kayıtta transactionlardan dolayı sorun oluyor. Düzeltmek için uğraşılmadı
    SetLabelPopup();
    mniAddLanguageContent.Visible := True;
  end;

//  if (FormMode <> ifmNewRecord ) then
//    RefreshData;
//ferhat buraya bak normal input db formlarda iki kere refreshdata yapıyor. Bunu engelle
//detaylı formlarda da refresh yapmalı fakat input db formlarından gelmediği için burada yapıldı.
//yapıyı gözden geçir

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
  LLangGuiContent: TSysGuiIcerik;
  LCode, LValue, LContentType, LTableName: string;
begin
  if pmLabels.PopupComponent.ClassType = TLabel then
  begin
    LCode := StringReplace(pmLabels.PopupComponent.Name, PRX_LABEL, '', [rfReplaceAll]);
    LContentType := LngLabelCaption;
    LTableName := ReplaceRealColOrTableNameTo(Table.TableName);
    LValue := TLabel(pmLabels.PopupComponent).Caption;
  end
  else if pmLabels.PopupComponent.ClassType = TTabSheet then
  begin
    LCode := StringReplace(pmLabels.PopupComponent.Name, PRX_TABSHEET, '', [rfReplaceAll]);
    LContentType := LngTab;
    LTableName := ReplaceRealColOrTableNameTo(Table.TableName);
    LTableName := Self.Name;
    LValue := TTabSheet(pmLabels.PopupComponent).Caption;
  end;


  LLangGuiContent := TSysGuiIcerik.Create(GDataBase);

  LLangGuiContent.Kod.Value := LCode;
  LLangGuiContent.IcerikTipi.Value := LContentType;
  LLangGuiContent.TabloAdi.Value := LTableName;
  LLangGuiContent.Deger.Value := LValue;

  TfrmSysGuiIcerik.Create(Self, nil, LLangGuiContent, ifmCopyNewRecord, fomNormal, ivmSort).ShowModal;

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
    LC: TRttiContext;
    LF: TRttiField;
    LT: TRttiType;
    LLabel: TLabel;
    n1: Integer;
    LLabelNames, LLabelName, LFilter: string;
    LLangGuiContent: TSysGuiIcerik;
  begin
    //label component isimleri lbl + db_field_name olacak şekilde verileceği varsayılarak bu kod yazildi. Örnek: lblcountry_code
    LLabelNames := '';
    LC := TRttiContext.Create;
    LT := LC.GetType(Self.ClassType);
    for LF in LT.GetFields do
      if LF.FieldType.Name = TLabel.ClassName then
      begin
        LLabel := TLabel(FindComponent(LF.Name));
        if Assigned(LLabel) then
          LLabelNames := LLabelNames + QuotedStr(StringReplace(TLabel(LLabel).Name, PRX_LABEL, '', [rfReplaceAll])) + ', ';
      end;

    LLabelNames := Trim(LLabelNames);
    if Length(LLabelNames) > 0 then
      LLabelNames := LeftStr(LLabelNames, Length(LLabelNames)-1);

    LLangGuiContent := TSysGuiIcerik.Create(GDataBase);
    try
      if Assigned(Table) then
        LFilter :=  ' AND ' + LLangGuiContent.TabloAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(Table.TableName))
      else
        LFilter :=  ' AND ' + LLangGuiContent.FormAdi.QryName + '=' + QuotedStr(ReplaceRealColOrTableNameTo(Self.Name));
      LLangGuiContent.SelectToList(
          ' AND ' + LLangGuiContent.Kod.QryName + ' IN (' +  LLabelNames + ')' +
          ' AND ' + LLangGuiContent.IcerikTipi.QryName + '=' + QuotedStr(LngLabelCaption) +
          LFilter, False, False);
      for n1 := 0 to LLangGuiContent.List.Count-1 do
      begin
        if not VarIsNull(TSysGuiIcerik(LLangGuiContent.List[n1]).Kod.Value) then
        begin
          LLabelName := VarToStr(TSysGuiIcerik(LLangGuiContent.List[n1]).Kod.Value);
          LLabel := TLabel(FindComponent(PRX_LABEL + LLabelName));
          if not VarIsNull(TSysGuiIcerik(LLangGuiContent.List[n1]).Deger.Value) then
            TLabel(LLabel).Caption := VarToStr(TSysGuiIcerik(LLangGuiContent.List[n1]).Deger.Value);
        end;
      end;
    finally
      LLangGuiContent.Free;
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
      //TAB SHEET Captionları düzenle
      vCtx1 := TRttiContext.Create;
      vRtt1 := vCtx1.GetType(Self.ClassType);
      for vRtf1 in vRtt1.GetFields do
        if vRtf1.FieldType.Name = TTabSheet.ClassName then
        begin
          vTabSheet := TTabSheet(FindComponent(vRtf1.Name));
          if Assigned(vTabSheet) then
            TTabSheet(vTabSheet).Caption :=
                TranslateText(TTabSheet(vTabSheet).Caption,
                TTabSheet(vTabSheet).Name + ' ' + Name,// + StringReplace(TTabSheet(vTabSheet).Name, PRX_TABSHEET, '', [rfReplaceAll]),
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
        AEdit.thsRequiredData := not pColumns.IsNullable.Value;
        AEdit.thsActiveYear4Digit := GSysApplicationSetting.Donem.Value;
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
        AMemo.thsRequiredData := not pColumns.IsNullable.Value;

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
        ACombo.thsRequiredData := not pColumns.IsNullable.Value;

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
          for n1 := 0 to GSysTableInfo.List.Count-1 do
            SubSetControlProperty(vParent, TSysViewColumns(GSysTableInfo.List[n1]));
        end;
      end;
    end;


    //is_contain_table(Table) evet ise control set yap hayır ise çık
    //burası tablo içinde alt tablo varsa bunu buluyor ve kontrol düzenlemesi yapıyor.
    //şu anda bir tane alt tablo bulacak şekilde çalşıyor. Burası düzenlenecek.
    //Örn. Hesap Kartı içinde Adres tablosunu buluyor
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
    for n1 := 0 to SysTableInfo.List.Count-1 do
      SubSetControlProperty(vParent, TSysViewColumns(SysTableInfo.List[n1]));
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
