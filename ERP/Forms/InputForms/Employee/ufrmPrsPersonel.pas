unit ufrmPrsPersonel;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Math,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.Mask,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,

  ufrmSetPrsPersonelTipleri,
  ufrmSetPrsBolumler,
  ufrmSetPrsBirimler,
  ufrmSetPrsGorevler,
  ufrmSetPrsCinsiyetler,
  ufrmSetPrsMedeniDurumlar,
  ufrmSetPrsAskerlikDurumlari,
  ufrmSetPrsServisAraclari,
  ufrmSysUlkeler,
  ufrmSysSehirler,
  Ths.Erp.Database.Table.SetPrsPersonelTipi,
  Ths.Erp.Database.Table.SetPrsBolum,
  Ths.Erp.Database.Table.SetPrsBirim,
  Ths.Erp.Database.Table.SetPrsGorev,
  Ths.Erp.Database.Table.SetPrsCinsiyet,
  Ths.Erp.Database.Table.SetPrsAskerlikDurumu,
  Ths.Erp.Database.Table.SetPrsMedeniDurum,
  Ths.Erp.Database.Table.SetPrsGecisSistemiKarti,
  Ths.Erp.Database.Table.SetPrsAyrilmaNedeni,
  Ths.Erp.Database.Table.SetPrsServisAraci,
  Ths.Erp.Database.Table.SysAdres,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.PrsEhliyetBilgisi,
  Ths.Erp.Database.Table.PrsLisanBilgisi,
  Ths.Erp.Database.Table.PrsSrcBilgisi,
  Ths.Erp.Database.Table.SetPrsEhliyet;

type
  TfrmPrsPersonel = class(TfrmBaseInputDB)
    tsDetail: TTabSheet;
    tsSpecial: TTabSheet;
    lblis_active: TLabel;
    lblsalary: TLabel;
    lblspecial_note: TLabel;
    lblbonus: TLabel;
    lblbonus_amount: TLabel;
    lblpostal_box: TLabel;
    lblbuilding_name: TLabel;
    lblstreet: TLabel;
    lblroad: TLabel;
    lbldistrict: TLabel;
    lbltown: TLabel;
    lblcity_id: TLabel;
    lblcountry_id: TLabel;
    lblpostal_code: TLabel;
    lbldoor_no: TLabel;
    lblphone1: TLabel;
    lblphone2: TLabel;
    lblclose_phone: TLabel;
    lblclose_name: TLabel;
    lblemail: TLabel;
    lblshoe_no: TLabel;
    lbldress_size: TLabel;
    lblemp_goverment_id: TLabel;
    lblbirth_date: TLabel;
    lblblood: TLabel;
    lblemp_gender_id: TLabel;
    lblemp_marital_kind_id: TLabel;
    lblemp_military_kind_id: TLabel;
    lblchild: TLabel;
    chkis_active: TCheckBox;
    edtphone1: TEdit;
    edtphone2: TEdit;
    edtemail: TEdit;
    edtclose_name: TEdit;
    edtclose_phone: TEdit;
    edtshoe_no: TEdit;
    edtdress_size: TEdit;
    edtemp_goverment_id: TEdit;
    edtbirth_date: TEdit;
    cbbblood: TComboBox;
    cbbemp_gender_id: TComboBox;
    cbbemp_marital_kind_id: TComboBox;
    edtchild: TEdit;
    cbbemp_military_kind_id: TComboBox;
    edtsalary: TEdit;
    edtbonus: TEdit;
    edtbonus_amount: TEdit;
    mmospecial_note: TMemo;
    edttown: TEdit;
    edtdistrict: TEdit;
    edtroad: TEdit;
    edtstreet: TEdit;
    edtbuilding_name: TEdit;
    edtdoor_no: TEdit;
    edtpostal_box: TEdit;
    edtpostal_code: TEdit;
    lblemp_name: TLabel;
    edtemp_name: TEdit;
    lblemp_surname: TLabel;
    edtemp_surname: TEdit;
    lblemp_type_id: TLabel;
    cbbemp_type_id: TComboBox;
    lblemp_section_id: TLabel;
    lblemp_unit_id: TLabel;
    lblemp_task_id: TLabel;
    lblemp_transport_id: TLabel;
    cbbemp_transport_id: TComboBox;
    lblgeneral_note: TLabel;
    mmogeneral_note: TMemo;
    imgPersonelResim: TImage;
    tsAbility: TTabSheet;
    strngrdDriverLicenseAbility: TStringGrid;
    strngrdSrcAbility: TStringGrid;
    strngrdLangAbility: TStringGrid;
    btnDriverLicenseAdd: TButton;
    btnDriverLicenseEdit: TButton;
    btnDriverLicenseRemove: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    edtemp_section_id: TEdit;
    edtemp_unit_id: TEdit;
    edtemp_task_id: TEdit;
    edtcountry_id: TEdit;
    edtcity_id: TEdit;
    procedure pgcMainChange(Sender: TObject);
    procedure cbbemp_gender_idChange(Sender: TObject);
    procedure cbbemp_marital_kind_idChange(Sender: TObject);
    procedure btnDriverLicenseAddClick(Sender: TObject);
  private
    FSetEmpWorkerType: TSetPrsPersonelTipi;
    FSetEmpSection: TSetPrsBolum;
    FSetEmpUnit: TSetPrsBirim;
    FSetEmpTask: TSetPrsGorev;
    FSetEmpGender: TSetPrsCinsiyet;
    FSetEmpMilitaryState: TSetPrsAskerlikDurumu;
    FSetEmpMaritalType: TSetPrsMedeniDurum;
    FSetEmpTransportVehicle: TSetPrsServisAraci;
    FSysCountry: TSysUlke;
    FSysCity: TSysSehir;

    procedure resizeGrid(pGrid: TStringGrid; pCols: Array of Integer);
//    procedure setTitleDriverLicenseAbility(pAbility: TEmpDriverLicenseAbility);
    procedure addRowDriverLicenseAbility(pRowNo: Integer; pAbility: TPrsEhliyetBilgisi; pLastRecord: Boolean);
    procedure fillDriverLicenseAbility();
  public
    procedure Repaint; override;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  ufrmPrsEhliyetBilgisi,
  Ths.Erp.Database.Table.PrsPersonel;

{$R *.dfm}

procedure TfrmPrsPersonel.btnDriverLicenseAddClick(Sender: TObject);
var
  vDriverLicense: TPrsEhliyetBilgisi;
begin
  vDriverLicense := TPrsEhliyetBilgisi.Create(Table.Database);
  vDriverLicense.PersonelID.Value := TPrsPersonel(Table).Id.Value;
  if TfrmEmpDriverLicenseAbility.Create(nil, nil, vDriverLicense, ifmNewRecord).ShowModal = mrOk then
  begin
    addRowDriverLicenseAbility(strngrdDriverLicenseAbility.RowCount, vDriverLicense, False);
  end;
end;

procedure TfrmPrsPersonel.cbbemp_gender_idChange(Sender: TObject);
begin
  if Assigned(cbbemp_gender_id.Items.Objects[cbbemp_gender_id.ItemIndex]) then
  begin
    if TSetPrsCinsiyet(cbbemp_gender_id.Items.Objects[cbbemp_gender_id.ItemIndex]).IsErkek.Value then
    begin
      lblemp_military_kind_id.Visible := True;
      cbbemp_military_kind_id.Visible := True;
    end
    else
    begin
      lblemp_military_kind_id.Visible := False;
      cbbemp_military_kind_id.Visible := False;
      cbbemp_military_kind_id.ItemIndex := -1;
    end;
  end;
end;

procedure TfrmPrsPersonel.cbbemp_marital_kind_idChange(Sender: TObject);
begin
  if Assigned(cbbemp_marital_kind_id.Items.Objects[cbbemp_marital_kind_id.ItemIndex]) then
  begin
    if TSetPrsMedeniDurum(cbbemp_marital_kind_id.Items.Objects[cbbemp_marital_kind_id.ItemIndex]).IsEvli.Value then
    begin
      lblchild.Visible := True;
      edtchild.Visible := True;
    end
    else
    begin
      lblchild.Visible := False;
      edtchild.Visible := False;
      edtchild.Clear;
    end;
  end;
end;

procedure TfrmPrsPersonel.resizeGrid(pGrid: TStringGrid; pCols: Array of Integer);
var
  n1, vWidth: Integer;
begin
  pGrid.FixedCols := 1;
  pGrid.FixedRows := 1;
  pGrid.ColCount := Length(pCols);
  pGrid.RowCount := 2;

  pGrid.DefaultColWidth := 24;
  pGrid.DefaultRowHeight := 18;
  for n1 := 0 to Length(pCols)-1 do
    pGrid.ColWidths[n1] := pCols[n1];

  vWidth := 0;
  for n1 := 0 to pGrid.ColCount-1 do
    vWidth := vWidth + pGrid.ColWidths[n1] + pGrid.GridLineWidth;
  pGrid.Width := vWidth + 28;
end;

//procedure TfrmEmpCard.setTitleDriverLicenseAbility(pAbility: TEmpDriverLicenseAbility);
//begin
//  pAbility.SelectToDatasource(' AND 1=2 ', False);
//  strngrdDriverLicenseAbility.Cells[0, 0] := 'No';
//  strngrdDriverLicenseAbility.Cells[1, 0] := pAbility.QueryOfDS.FieldByName(pAbility.EmpDriverLicense.FieldName).DisplayLabel;
//  strngrdDriverLicenseAbility.Cells[2, 0] := pAbility.QueryOfDS.FieldByName(pAbility.IsActive.FieldName).DisplayLabel;
//  pAbility.QueryOfDS.Close;
//end;

procedure TfrmPrsPersonel.addRowDriverLicenseAbility(pRowNo: Integer; pAbility: TPrsEhliyetBilgisi; pLastRecord: Boolean);
begin
  strngrdDriverLicenseAbility.Objects[0, pRowNo+1] := pAbility;
  strngrdDriverLicenseAbility.Cells[0, pRowNo+1] := (pRowNo+1).ToString;
  strngrdDriverLicenseAbility.Cells[1, pRowNo+1] := pAbility.Ehliyet.Value;
  strngrdDriverLicenseAbility.Cells[2, pRowNo+1] := pAbility.IsAktif.Value;

  if not pLastRecord then
  begin
    strngrdDriverLicenseAbility.RowCount := strngrdDriverLicenseAbility.RowCount + 1;
    strngrdDriverLicenseAbility.Row := strngrdDriverLicenseAbility.Row + 1;
  end;
end;

procedure TfrmPrsPersonel.fillDriverLicenseAbility;
//var
//  n1: Integer;
begin
  resizeGrid(strngrdDriverLicenseAbility, [24, 90, 50]);

//  setTitleDriverLicenseAbility(TEmpCard(Table).DriverLicenseAbility);
//
//  TEmpCard(Table).DriverLicenseAbility.SelectToList('', False, False);
//  strngrdDriverLicenseAbility.Row := 1;
//  for n1 := 0 to TEmpCard(Table).DriverLicenseAbility.List.Count-1 do
//    addRowDriverLicenseAbility(n1, TEmpDriverLicenseAbility(TEmpCard(Table).DriverLicenseAbility.List[n1]), (n1 = TEmpCard(Table).DriverLicenseAbility.List.Count-1));
end;

procedure TfrmPrsPersonel.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  mmogeneral_note.CharCase := ecNormal;
  mmospecial_note.CharCase := ecNormal;
  edtemail.CharCase := ecNormal;

  chkis_active.Visible := False;
  lblis_active.Visible := False;


  FSetEmpWorkerType := TSetPrsPersonelTipi.Create(Table.Database);
  FSetEmpSection := TSetPrsBolum.Create(Table.Database);
  FSetEmpUnit := TSetPrsBirim.Create(Table.Database);
  FSetEmpTask := TSetPrsGorev.Create(Table.Database);
  FSetEmpGender := TSetPrsCinsiyet.Create(Table.Database);
  FSetEmpMilitaryState := TSetPrsAskerlikDurumu.Create(Table.Database);
  FSetEmpMaritalType := TSetPrsMedeniDurum.Create(Table.Database);
  FSetEmpTransportVehicle := TSetPrsServisAraci.Create(Table.Database);
  FSysCountry := TSysUlke.Create(Table.Database);
  FSysCity := TSysSehir.Create(Table.Database);

  FSetEmpWorkerType.SelectToList('', False, False);
  cbbemp_type_id.Clear;
  for n1 := 0 to FSetEmpWorkerType.List.Count-1 do
    cbbemp_type_id.Items.AddObject(TSetPrsPersonelTipi(FSetEmpWorkerType.List[n1]).PersonelTipi.Value, TSetPrsPersonelTipi(FSetEmpWorkerType.List[n1]));
  cbbemp_type_id.ItemIndex := -1;

  FSetEmpTransportVehicle.SelectToList('', False, False);
  cbbemp_transport_id.Clear;
  for n1 := 0 to FSetEmpTransportVehicle.List.Count-1 do
    cbbemp_transport_id.Items.AddObject(TSetPrsServisAraci(FSetEmpTransportVehicle.List[n1]).AracAdi.Value, TSetPrsServisAraci(FSetEmpTransportVehicle.List[n1]));
  cbbemp_transport_id.ItemIndex := -1;

  cbbblood.Clear;
  cbbblood.Items.Add('A RH+');
  cbbblood.Items.Add('B RH+');
  cbbblood.Items.Add('AB RH+');
  cbbblood.Items.Add('0 RH+');
  cbbblood.Items.Add('A RH-');
  cbbblood.Items.Add('B RH-');
  cbbblood.Items.Add('AB RH-');
  cbbblood.Items.Add('0 RH-');

  FSetEmpGender.SelectToList('', False, False);
  cbbemp_gender_id.Clear;
  for n1 := 0 to FSetEmpGender.List.Count-1 do
    cbbemp_gender_id.Items.AddObject(TSetPrsCinsiyet(FSetEmpGender.List[n1]).Cinsiyet.Value, TSetPrsCinsiyet(FSetEmpGender.List[n1]));
  cbbemp_gender_id.ItemIndex := -1;

  FSetEmpMaritalType.SelectToList('', False, False);
  cbbemp_marital_kind_id.Clear;
  for n1 := 0 to FSetEmpMaritalType.List.Count-1 do
    cbbemp_marital_kind_id.Items.AddObject(TSetPrsMedeniDurum(FSetEmpMaritalType.List[n1]).MedeniDurum.Value, TSetPrsMedeniDurum(FSetEmpMaritalType.List[n1]));
  cbbemp_marital_kind_id.ItemIndex := -1;

  FSetEmpMilitaryState.SelectToList('', False, False);
  cbbemp_military_kind_id.Clear;
  for n1 := 0 to FSetEmpMilitaryState.List.Count-1 do
    cbbemp_military_kind_id.Items.AddObject(TSetPrsAskerlikDurumu(FSetEmpMilitaryState.List[n1]).AskerlikDurumu.Value, TSetPrsAskerlikDurumu(FSetEmpMilitaryState.List[n1]));
  cbbemp_military_kind_id.ItemIndex := -1;
end;

procedure TfrmPrsPersonel.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetEmpWorkerType) then
    FSetEmpWorkerType.Free;
  if Assigned(FSetEmpSection) then
    FSetEmpSection.Free;
  if Assigned(FSetEmpUnit) then
    FSetEmpUnit.Free;
  if Assigned(FSetEmpTask) then
    FSetEmpTask.Free;
  if Assigned(FSetEmpGender) then
    FSetEmpGender.Free;
  if Assigned(FSetEmpMilitaryState) then
    FSetEmpMilitaryState.Free;
  if Assigned(FSetEmpMaritalType) then
    FSetEmpMaritalType.Free;
  if Assigned(FSetEmpTransportVehicle) then
    FSetEmpTransportVehicle.Free;
  if Assigned(FSysCountry) then
    FSysCountry.Free;
  if Assigned(FSysCity) then
    FSysCity.Free;
  inherited;
end;

procedure TfrmPrsPersonel.FormShow(Sender: TObject);
begin
  edtemp_section_id.OnHelperProcess := HelperProcess;
  edtemp_unit_id.OnHelperProcess := HelperProcess;
  edtemp_task_id.OnHelperProcess := HelperProcess;
  edtcountry_id.OnHelperProcess := HelperProcess;
  edtcity_id.OnHelperProcess := HelperProcess;

  inherited;

  SetButtonImages16(btnDriverLicenseAdd, IMG_ADD);
  SetButtonImages16(btnDriverLicenseEdit, IMG_RECORD);
  SetButtonImages16(btnDriverLicenseRemove, IMG_REMOVE);
end;

procedure TfrmPrsPersonel.HelperProcess(Sender: TObject);
var
  LFrmSection: TfrmSetPrsBolumler;
  LSection: TSetPrsBolum;
  LFrmUnit: TfrmSetPrsBirimler;
  LUnit: TSetPrsBirim;
  LFrmTask: TfrmSetPrsGorevler;
  LTask: TSetPrsGorev;
  LFrmCountry: TfrmSysUlkeler;
  LCountry: TSysUlke;
  LFrmCity: TfrmSysSehirler;
  LCity: TSysSehir;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtemp_section_id.Name then
      begin
        LSection := TSetPrsBolum.Create(Table.Database);
        LFrmSection := TfrmSetPrsBolumler.Create(TEdit(Sender), Self, LSection, fomNormal, True);
        try
          LFrmSection.ShowModal;
          if LFrmSection.DataAktar then
          begin
            TPrsPersonel(Table).BolumID.Value := LFrmSection.Table.Id.Value;
            edtemp_section_id.Text := LSection.Bolum.Value;

            TPrsPersonel(Table).BirimID.Value := 0;
            edtemp_unit_id.Clear;
          end;
        finally
          LFrmSection.Free;
        end;
      end else if (TEdit(Sender).Name = edtemp_unit_id.Name) and (StrToIntDef(VarToStr(TPrsPersonel(Table).BolumID.Value), 0) <> 0) then
      begin
        LUnit := TSetPrsBirim.Create(Table.Database);
        LFrmUnit := TfrmSetPrsBirimler.Create(TEdit(Sender), Self, LUnit, fomNormal, True);
        try
          LFrmUnit.QryFiltreVarsayilan := ' AND ' + LUnit.TableName + '.' + LUnit.BolumID.FieldName + '=' + VarToStr(TPrsPersonel(Table).BolumID.Value);
          LFrmUnit.ShowModal;
          if LFrmUnit.DataAktar then
          begin
            TPrsPersonel(Table).BirimID.Value := LFrmUnit.Table.Id.Value;
            edtemp_unit_id.Text := LUnit.Birim.Value;
          end;
        finally
          LFrmUnit.Free;
        end;
      end else if (TEdit(Sender).Name = edtemp_task_id.Name) then
      begin
        LTask := TSetPrsGorev.Create(Table.Database);
        LFrmTask := TfrmSetPrsGorevler.Create(TEdit(Sender), Self, LTask, fomNormal, True);
        try
          LFrmTask.ShowModal;
          if LFrmTask.DataAktar then
          begin
            TPrsPersonel(Table).GorevID.Value := LFrmTask.Table.Id.Value;
            edtemp_task_id.Text := LTask.Gorev.Value;
          end;
        finally
          LFrmTask.Free;
        end;
      end else if (TEdit(Sender).Name = edtcountry_id.Name) then
      begin
        LCountry := TSysUlke.Create(Table.Database);
        LFrmCountry := TfrmSysUlkeler.Create(TEdit(Sender), Self, LCountry, fomNormal, True);
        try
          LFrmCountry.ShowModal;
          if LFrmCountry.DataAktar then
          begin
            TPrsPersonel(Table).UlkeID.Value := LFrmCountry.Table.Id.Value;
            edtcountry_id.Text := LCountry.UlkeAdi.Value;
          end;
        finally
          LFrmCountry.Free;
        end;
      end else if (TEdit(Sender).Name = edtcity_id.Name) then
      begin
        LCity := TSysSehir.Create(Table.Database);
        LFrmCity := TfrmSysSehirler.Create(TEdit(Sender), Self, LCity, fomNormal, True);
        try
          LFrmCity.QryFiltreVarsayilan := ' AND ' + LCity.TableName + '.' + LCity.UlkeID.FieldName + '=' + VarToStr(TPrsPersonel(Table).UlkeID.Value);
          LFrmCity.ShowModal;
          if LFrmCity.DataAktar then
          begin
            TPrsPersonel(Table).SehirID.Value := LFrmCity.Table.Id.Value;
            edtcity_id.Text := LCity.SehirAdi.Value;
          end;
        finally
          LFrmCity.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmPrsPersonel.pgcMainChange(Sender: TObject);
begin
  inherited;
  lblemp_name.Parent := pgcMain.ActivePage;
  edtemp_name.Parent := pgcMain.ActivePage;
  lblemp_surname.Parent := pgcMain.ActivePage;
  edtemp_surname.Parent := pgcMain.ActivePage;

  if pgcMain.ActivePage.Name = tsMain.Name then
  begin
    edtemp_name.ReadOnly := False;
    edtemp_name.TabStop := True;
    edtemp_surname.ReadOnly := False;
    edtemp_surname.TabStop := True;

    edtemp_name.TabOrder := 0;
    edtemp_surname.TabOrder := 1;

    edtemp_name.SetFocus;
  end
  else
  begin
    edtemp_name.TabOrder := 0;
    edtemp_surname.TabOrder := 1;

    edtemp_name.ReadOnly := True;
    edtemp_name.TabStop := False;
    edtemp_name.ReadOnly := True;
    edtemp_surname.TabStop := False;
  end;
end;

procedure TfrmPrsPersonel.RefreshData;
begin
  chkis_active.Checked := TPrsPersonel(Table).IsAktif.Value;
  edtemp_name.Text := TPrsPersonel(Table).Ad.Value;
  edtemp_surname.Text := TPrsPersonel(Table).Soyad.Value;
  cbbemp_type_id.ItemIndex := cbbemp_type_id.Items.IndexOf(TPrsPersonel(Table).PersonelTipi.Value);

  edtemp_section_id.Text := TPrsPersonel(Table).Bolum.Value;
  edtemp_unit_id.Text := TPrsPersonel(Table).Birim.Value;
  edtemp_task_id.Text := TPrsPersonel(Table).Gorev.Value;

  mmogeneral_note.Text := TPrsPersonel(Table).GenelNot.Value;
  cbbemp_transport_id.ItemIndex := cbbemp_transport_id.Items.IndexOf(TPrsPersonel(Table).TasimaServisi.Value);

  edtcountry_id.Text := TPrsPersonel(Table).Ulke.Value;
  edtcity_id.Text := TPrsPersonel(Table).Sehir.Value;

  edttown.Text := TPrsPersonel(Table).Ilce.Value;
  edtdistrict.Text := TPrsPersonel(Table).Mahalle.Value;
  edtroad.Text := TPrsPersonel(Table).Cadde.Value;
  edtstreet.Text := TPrsPersonel(Table).Sokak.Value;
  edtbuilding_name.Text := TPrsPersonel(Table).BinaAdi.Value;
  edtdoor_no.Text := TPrsPersonel(Table).KapiNo.Value;
  edtpostal_box.Text := TPrsPersonel(Table).PostaKutusu.Value;
  edtpostal_code.Text := TPrsPersonel(Table).PostaKodu.Value;

  edtphone1.Text := TPrsPersonel(Table).Tel1.Value;
  edtphone2.Text := TPrsPersonel(Table).Tel2.Value;
  edtemail.Text := TPrsPersonel(Table).EMail.Value;
  edtclose_name.Text := TPrsPersonel(Table).YakinAdi.Value;
  edtclose_phone.Text := TPrsPersonel(Table).YakinTelefon.Value;
  edtshoe_no.Text := TPrsPersonel(Table).AyakkabiNo.Value;
  edtdress_size.Text := TPrsPersonel(Table).ElbiseBedeni.Value;
  if FormMode = ifmUpdate then
    edtemp_goverment_id.Text := DecryptStr(TPrsPersonel(Table).KimlikNo.Value, GSysUygulamaAyari.CryptKey.Value)
  else
    edtemp_goverment_id.Text := TPrsPersonel(Table).KimlikNo.Value;
  edtbirth_date.Text := TPrsPersonel(Table).DogumTarihi.Value;
  cbbblood.ItemIndex := cbbblood.Items.IndexOf(TPrsPersonel(Table).KanGrubu.Value);
  cbbemp_gender_id.ItemIndex := cbbemp_gender_id.Items.IndexOf(TPrsPersonel(Table).Cinsiyet.Value);
  cbbemp_gender_idChange(cbbemp_gender_id);
  cbbemp_marital_kind_id.ItemIndex := cbbemp_marital_kind_id.Items.IndexOf(TPrsPersonel(Table).MedeniDurumu.Value);
  cbbemp_marital_kind_idChange(cbbemp_marital_kind_id);
  edtchild.Text := TPrsPersonel(Table).CocukSayisi.Value;
  cbbemp_military_kind_id.ItemIndex := cbbemp_military_kind_id.Items.IndexOf(TPrsPersonel(Table).AskerlikDurumu.Value);
  edtsalary.Text := TPrsPersonel(Table).Maas.Value;
  edtbonus.Text := TPrsPersonel(Table).IkramiyeSayisi.Value;
  edtbonus_amount.Text := TPrsPersonel(Table).IkramiyeTutar.Value;
  mmospecial_note.Text := TPrsPersonel(Table).OzelNot.Value;

//  cbbsection_id.Enabled := True;
//  cbbcountry_id.Enabled := True;
  //imgPersonelResim.Picture.LoadFromFile(FApplicationMainPath + 'PathForPersonel+PersonelID.jpg');

  fillDriverLicenseAbility;
end;

procedure TfrmPrsPersonel.Repaint;
begin
  inherited;
  if (FormMode = ifmUpdate) then
  begin
    chkis_active.Visible := True;
    lblis_active.Visible := True;
  end;

  edtemp_section_id.ReadOnly := True;
  edtemp_unit_id.ReadOnly := True;
  edtemp_task_id.ReadOnly := True;
end;

procedure TfrmPrsPersonel.btnAcceptClick(Sender: TObject);
//var
//  n1: Integer;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //auto accept kodunu çaðýrmýyoruz helper kullanan bilgileri siliyor daha sonra autoaccept düzenlenecek

      if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
        TPrsPersonel(Table).IsAktif.Value := True
      else
        TPrsPersonel(Table).IsAktif.Value := chkis_active.Checked;

      TPrsPersonel(Table).Ad.Value := edtemp_name.Text;
      TPrsPersonel(Table).Soyad.Value := edtemp_surname.Text;
      TPrsPersonel(Table).AdSoyad.Value := TPrsPersonel(Table).Ad.Value + ' ' + TPrsPersonel(Table).Soyad.Value;

      if (cbbemp_type_id.ItemIndex > -1) and Assigned(cbbemp_type_id.Items.Objects[cbbemp_type_id.ItemIndex]) then
        TPrsPersonel(Table).PersonelTipiID.Value := TSetPrsPersonelTipi(cbbemp_type_id.Items.Objects[cbbemp_type_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).PersonelTipiID.Value := 0;

      //section, unit, task data take from helper form
      TPrsPersonel(Table).GenelNot.Value := mmogeneral_note.Text;
      if (cbbemp_transport_id.ItemIndex > -1) and Assigned(cbbemp_transport_id.Items.Objects[cbbemp_transport_id.ItemIndex]) then
        TPrsPersonel(Table).TasimaServisiID.Value := TSetPrsServisAraci(cbbemp_transport_id.Items.Objects[cbbemp_transport_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).TasimaServisiID.Value := 0;

      //country and city data take from helper form
      TPrsPersonel(Table).Ilce.Value := edttown.Text;
      TPrsPersonel(Table).Mahalle.Value := edtdistrict.Text;
      TPrsPersonel(Table).Cadde.Value := edtroad.Text;
      TPrsPersonel(Table).Sokak.Value := edtstreet.Text;
      TPrsPersonel(Table).BinaAdi.Value := edtbuilding_name.Text;
      TPrsPersonel(Table).KapiNo.Value := edtdoor_no.Text;
      TPrsPersonel(Table).PostaKutusu.Value := edtpostal_box.Text;
      TPrsPersonel(Table).PostaKodu.Value := edtpostal_code.Text;

      TPrsPersonel(Table).Tel1.Value := edtphone1.Text;
      TPrsPersonel(Table).Tel2.Value := edtphone2.Text;
      TPrsPersonel(Table).EMail.Value := edtemail.Text;
      TPrsPersonel(Table).YakinAdi.Value := edtclose_name.Text;
      TPrsPersonel(Table).YakinTelefon.Value := edtclose_phone.Text;
      TPrsPersonel(Table).AyakkabiNo.Value := edtshoe_no.Text;
      TPrsPersonel(Table).ElbiseBedeni.Value := edtdress_size.Text;
      TPrsPersonel(Table).KimlikNo.Value := EncryptStr(edtemp_goverment_id.Text, GSysUygulamaAyari.CryptKey.Value);
      TPrsPersonel(Table).DogumTarihi.Value := edtbirth_date.Text;
      TPrsPersonel(Table).KanGrubu.Value := cbbblood.Text;

      if (cbbemp_gender_id.ItemIndex > -1) and Assigned(cbbemp_gender_id.Items.Objects[cbbemp_gender_id.ItemIndex]) then
        TPrsPersonel(Table).CinsiyetID.Value := TSetPrsCinsiyet(cbbemp_gender_id.Items.Objects[cbbemp_gender_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).CinsiyetID.Value := 0;

      if (cbbemp_marital_kind_id.ItemIndex > -1) and Assigned(cbbemp_marital_kind_id.Items.Objects[cbbemp_marital_kind_id.ItemIndex]) then
        TPrsPersonel(Table).MedeniDurumuID.Value := TSetPrsMedeniDurum(cbbemp_marital_kind_id.Items.Objects[cbbemp_marital_kind_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).MedeniDurumuID.Value := 0;

      TPrsPersonel(Table).CocukSayisi.Value := StrToIntDef(edtchild.Text, 0);

      if (cbbemp_military_kind_id.ItemIndex > -1) and Assigned(cbbemp_military_kind_id.Items.Objects[cbbemp_military_kind_id.ItemIndex]) then
        TPrsPersonel(Table).AskerlikDurumuID.Value := TSetPrsAskerlikDurumu(cbbemp_military_kind_id.Items.Objects[cbbemp_military_kind_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).AskerlikDurumuID.Value := 0;

      TPrsPersonel(Table).Maas.Value := edtsalary.moneyToDouble;
      TPrsPersonel(Table).IkramiyeSayisi.Value := edtbonus.Text;
      TPrsPersonel(Table).IkramiyeTutar.Value := edtbonus_amount.moneyToDouble;
      TPrsPersonel(Table).OzelNot.Value := mmospecial_note.Text;

//      TEmpCard(Table).DriverLicenseAbility.List.Clear;
//      for n1 := 1 to strngrdDriverLicenseAbility.RowCount-1 do
//      begin
//        if Assigned(strngrdDriverLicenseAbility.Objects[0, n1]) then
//        begin
//          if TEmpDriverLicenseAbility(strngrdDriverLicenseAbility.Objects[0, n1]).Id.Value < 0 then
//            TEmpCard(Table).DriverLicenseAbility.List.Add( TEmpDriverLicenseAbility(strngrdDriverLicenseAbility.Objects[0, n1]).Clone )
//          else
//            TEmpCard(Table).DriverLicenseAbility.List.Add( TEmpDriverLicenseAbility(strngrdDriverLicenseAbility.Objects[0, n1]).Clone );
//        end
//        else
//        begin
//
//        end;
//      end;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
