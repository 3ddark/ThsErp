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
  ufrmSysIlceler,
  ufrmSysMahalleler,
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
  Ths.Erp.Database.Table.SysIlce,
  Ths.Erp.Database.Table.SysMahalle,
  Ths.Erp.Database.Table.PrsEhliyetBilgisi,
  Ths.Erp.Database.Table.PrsLisanBilgisi,
  Ths.Erp.Database.Table.PrsSrcBilgisi,
  Ths.Erp.Database.Table.SetPrsEhliyet;

type
  TfrmPrsPersonel = class(TfrmBaseInputDB)
    tsDetail: TTabSheet;
    tsSpecial: TTabSheet;
    lblis_aktif: TLabel;
    lblmaas: TLabel;
    lblozel_not: TLabel;
    lblikramiye_sayisi: TLabel;
    lblikramiye_tutar: TLabel;
    lblbina_adi: TLabel;
    lblsokak: TLabel;
    lblcadde: TLabel;
    lblmahalle: TLabel;
    lblilce: TLabel;
    lblsehir_id: TLabel;
    lblulke_id: TLabel;
    lblposta_kodu: TLabel;
    lblkapi_no: TLabel;
    lbltel1: TLabel;
    lbltel2: TLabel;
    lblyakin_telefon: TLabel;
    lblyakin_adi: TLabel;
    lblemail: TLabel;
    lblayakkabi_no: TLabel;
    lblelbise_bedeni: TLabel;
    lblkimlik_no: TLabel;
    lbldogum_tarihi: TLabel;
    lblkan_grubu: TLabel;
    lblcinsiyet_id: TLabel;
    lblmedeni_durumu_id: TLabel;
    lblaskerlik_durumu_id: TLabel;
    lblcocuk_sayisi: TLabel;
    chkis_aktif: TCheckBox;
    edttel1: TEdit;
    edttel2: TEdit;
    edtemail: TEdit;
    edtyakin_adi: TEdit;
    edtyakin_telefon: TEdit;
    edtayakkabi_no: TEdit;
    edtelbise_bedeni: TEdit;
    edtkimlik_no: TEdit;
    edtdogum_tarihi: TEdit;
    cbbkan_grubu: TComboBox;
    cbbcinsiyet_id: TComboBox;
    cbbmedeni_durumu_id: TComboBox;
    edtcocuk_sayisi: TEdit;
    cbbaskerlik_durumu_id: TComboBox;
    edtmaas: TEdit;
    edtikramiye_sayisi: TEdit;
    edtikramiye_tutar: TEdit;
    mmoozel_not: TMemo;
    edtilce: TEdit;
    edtmahalle: TEdit;
    edtcadde: TEdit;
    edtsokak: TEdit;
    edtbina_adi: TEdit;
    edtkapi_no: TEdit;
    edtposta_kodu: TEdit;
    lblad: TLabel;
    edtad: TEdit;
    lblsoyad: TLabel;
    edtsoyad: TEdit;
    lblpersonel_tipi_id: TLabel;
    cbbpersonel_tipi_id: TComboBox;
    lblbolum_id: TLabel;
    lblbirim_id: TLabel;
    lblgorev_id: TLabel;
    lbltasima_servisi_id: TLabel;
    cbbtasima_servisi_id: TComboBox;
    lblgenel_not: TLabel;
    mmogenel_not: TMemo;
    imgpersonel_resim: TImage;
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
    edtbolum_id: TEdit;
    edtbirim_id: TEdit;
    edtgorev_id: TEdit;
    edtulke_id: TEdit;
    edtsehir_id: TEdit;
    lblposta_kutusu: TLabel;
    edtposta_kutusu: TEdit;
    procedure pgcMainChange(Sender: TObject);
    procedure cbbcinsiyet_idChange(Sender: TObject);
    procedure cbbmedeni_durumu_idChange(Sender: TObject);
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

procedure TfrmPrsPersonel.cbbcinsiyet_idChange(Sender: TObject);
begin
  if cbbcinsiyet_id.ItemIndex < 0 then
    Exit;

  if Assigned(cbbcinsiyet_id.Items.Objects[cbbcinsiyet_id.ItemIndex]) then
  begin
    if TSetPrsCinsiyet(cbbcinsiyet_id.Items.Objects[cbbcinsiyet_id.ItemIndex]).Id.AsInteger = Ord(TPrsCinsiyet.Erkek) then
    begin
      lblaskerlik_durumu_id.Visible := True;
      cbbaskerlik_durumu_id.Visible := True;
    end
    else
    begin
      lblaskerlik_durumu_id.Visible := False;
      cbbaskerlik_durumu_id.Visible := False;
      cbbaskerlik_durumu_id.ItemIndex := -1;
    end;
  end;
end;

procedure TfrmPrsPersonel.cbbmedeni_durumu_idChange(Sender: TObject);
begin
  if cbbmedeni_durumu_id.ItemIndex < 0 then
    Exit;

  if Assigned(cbbmedeni_durumu_id.Items.Objects[cbbmedeni_durumu_id.ItemIndex]) then
  begin
    if TSetPrsMedeniDurum(cbbmedeni_durumu_id.Items.Objects[cbbmedeni_durumu_id.ItemIndex]).Id.AsInteger = Ord(TPrsMedeniDurum.Evli) then
    begin
      lblcocuk_sayisi.Visible := True;
      edtcocuk_sayisi.Visible := True;
    end
    else
    begin
      lblcocuk_sayisi.Visible := False;
      edtcocuk_sayisi.Visible := False;
      edtcocuk_sayisi.Clear;
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
//  strngrdDriverLicenseAbility.Cells[2, 0] := pAbility.QueryOfDS.FieldByName(pAbility.IsAktif.FieldName).DisplayLabel;
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

  mmogenel_not.CharCase := ecNormal;
  mmoozel_not.CharCase := ecNormal;
  edtemail.CharCase := ecNormal;

  chkis_aktif.Visible := False;
  lblis_aktif.Visible := False;


  FSetEmpWorkerType := TSetPrsPersonelTipi.Create(Table.Database);
  FSetEmpSection := TSetPrsBolum.Create(Table.Database);
  FSetEmpUnit := TSetPrsBirim.Create(Table.Database);
  FSetEmpTask := TSetPrsGorev.Create(Table.Database);
  FSetEmpGender := TSetPrsCinsiyet.Create(Table.Database);
  FSetEmpMilitaryState := TSetPrsAskerlikDurumu.Create(Table.Database);
  FSetEmpMaritalType := TSetPrsMedeniDurum.Create(Table.Database);
  FSetEmpTransportVehicle := TSetPrsServisAraci.Create(Table.Database);

  FSetEmpWorkerType.SelectToList('', False, False);
  cbbpersonel_tipi_id.Clear;
  for n1 := 0 to FSetEmpWorkerType.List.Count-1 do
    cbbpersonel_tipi_id.Items.AddObject(TSetPrsPersonelTipi(FSetEmpWorkerType.List[n1]).PersonelTipi.AsString, TSetPrsPersonelTipi(FSetEmpWorkerType.List[n1]));
  cbbpersonel_tipi_id.ItemIndex := -1;

  FSetEmpTransportVehicle.SelectToList('', False, False);
  cbbtasima_servisi_id.Clear;
  for n1 := 0 to FSetEmpTransportVehicle.List.Count-1 do
    cbbtasima_servisi_id.Items.AddObject(TSetPrsServisAraci(FSetEmpTransportVehicle.List[n1]).AracAdi.AsString, TSetPrsServisAraci(FSetEmpTransportVehicle.List[n1]));
  cbbtasima_servisi_id.ItemIndex := -1;

  cbbkan_grubu.Clear;
  cbbkan_grubu.Items.Add('A RH+');
  cbbkan_grubu.Items.Add('B RH+');
  cbbkan_grubu.Items.Add('AB RH+');
  cbbkan_grubu.Items.Add('0 RH+');
  cbbkan_grubu.Items.Add('A RH-');
  cbbkan_grubu.Items.Add('B RH-');
  cbbkan_grubu.Items.Add('AB RH-');
  cbbkan_grubu.Items.Add('0 RH-');

  FSetEmpGender.SelectToList('', False, False);
  cbbcinsiyet_id.Clear;
  for n1 := 0 to FSetEmpGender.List.Count-1 do
    cbbcinsiyet_id.Items.AddObject(TSetPrsCinsiyet(FSetEmpGender.List[n1]).Cinsiyet.Value, TSetPrsCinsiyet(FSetEmpGender.List[n1]));
  cbbcinsiyet_id.ItemIndex := -1;

  FSetEmpMaritalType.SelectToList('', False, False);
  cbbmedeni_durumu_id.Clear;
  for n1 := 0 to FSetEmpMaritalType.List.Count-1 do
    cbbmedeni_durumu_id.Items.AddObject(TSetPrsMedeniDurum(FSetEmpMaritalType.List[n1]).MedeniDurum.Value, TSetPrsMedeniDurum(FSetEmpMaritalType.List[n1]));
  cbbmedeni_durumu_id.ItemIndex := -1;

  FSetEmpMilitaryState.SelectToList('', False, False);
  cbbaskerlik_durumu_id.Clear;
  for n1 := 0 to FSetEmpMilitaryState.List.Count-1 do
    cbbaskerlik_durumu_id.Items.AddObject(TSetPrsAskerlikDurumu(FSetEmpMilitaryState.List[n1]).AskerlikDurumu.Value, TSetPrsAskerlikDurumu(FSetEmpMilitaryState.List[n1]));
  cbbaskerlik_durumu_id.ItemIndex := -1;
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
  inherited;
end;

procedure TfrmPrsPersonel.FormShow(Sender: TObject);
begin
  edtbolum_id.OnHelperProcess := HelperProcess;
  edtbirim_id.OnHelperProcess := HelperProcess;
  edtgorev_id.OnHelperProcess := HelperProcess;
  edtulke_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;
  edtmahalle.OnHelperProcess := HelperProcess;

  inherited;

  SetButtonImages16(btnDriverLicenseAdd, IMG_ADD);
  SetButtonImages16(btnDriverLicenseEdit, IMG_RECORD);
  SetButtonImages16(btnDriverLicenseRemove, IMG_REMOVE);
end;

procedure TfrmPrsPersonel.HelperProcess(Sender: TObject);
var
  LFrmBolum: TfrmSetPrsBolumler;
  LBolum: TSetPrsBolum;
  LFrmBirim: TfrmSetPrsBirimler;
  LBirim: TSetPrsBirim;
  LFrmGorev: TfrmSetPrsGorevler;
  LGorev: TSetPrsGorev;
  LFrmUlke: TfrmSysUlkeler;
  LUlke: TSysUlke;
  LFrmSehir: TfrmSysSehirler;
  LSehir: TSysSehir;
  LFrmMahalle: TfrmSysMahalleler;
  LMahlle: TSysMahalle;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtbolum_id.Name then
      begin
        LBolum := TSetPrsBolum.Create(Table.Database);
        LFrmBolum := TfrmSetPrsBolumler.Create(TEdit(Sender), Self, LBolum, fomNormal, True);
        try
          LFrmBolum.ShowModal;
          if LFrmBolum.DataAktar then
          begin
            TPrsPersonel(Table).BolumID.Value := LFrmBolum.Table.Id.Value;
            TEdit(Sender).Text := LBolum.Bolum.Value;

            TPrsPersonel(Table).BirimID.Value := 0;
            edtbirim_id.Clear;
          end;
        finally
          LFrmBolum.Free;
        end;
      end else if (TEdit(Sender).Name = edtbirim_id.Name) and (StrToIntDef(VarToStr(TPrsPersonel(Table).BolumID.Value), 0) <> 0) then
      begin
        LBirim := TSetPrsBirim.Create(Table.Database);
        LFrmBirim := TfrmSetPrsBirimler.Create(TEdit(Sender), Self, LBirim, fomNormal, True);
        try
          LFrmBirim.QryFiltreVarsayilan := ' AND ' + LBirim.TableName + '.' + LBirim.BolumID.FieldName + '=' + VarToStr(TPrsPersonel(Table).BolumID.Value);
          LFrmBirim.ShowModal;
          if LFrmBirim.DataAktar then
          begin
            TPrsPersonel(Table).BirimID.Value := LFrmBirim.Table.Id.Value;
            TEdit(Sender).Text := LBirim.Birim.Value;
          end;
        finally
          LFrmBirim.Free;
        end;
      end else if (TEdit(Sender).Name = edtgorev_id.Name) then
      begin
        LGorev := TSetPrsGorev.Create(Table.Database);
        LFrmGorev := TfrmSetPrsGorevler.Create(TEdit(Sender), Self, LGorev, fomNormal, True);
        try
          LFrmGorev.ShowModal;
          if LFrmGorev.DataAktar then
          begin
            TPrsPersonel(Table).GorevID.Value := LFrmGorev.Table.Id.Value;
            TEdit(Sender).Text := LGorev.Gorev.Value;
          end;
        finally
          LFrmGorev.Free;
        end;
      end else if (TEdit(Sender).Name = edtulke_id.Name) then
      begin
        LUlke := TSysUlke.Create(Table.Database);
        LFrmUlke := TfrmSysUlkeler.Create(TEdit(Sender), Self, LUlke, fomNormal, True);
        try
          LFrmUlke.ShowModal;
          if LFrmUlke.DataAktar then
          begin
            if LFrmUlke.CleanAndClose then
            begin
              TPrsPersonel(Table).UlkeID.Value := 0;
              TPrsPersonel(Table).SehirID.Value := 0;
              TEdit(Sender).Clear;
              edtsehir_id.Clear;
              edtilce.Clear;
              edtmahalle.Clear;
              edtposta_kodu.Clear;
            end
            else
            begin
              if TPrsPersonel(Table).UlkeID.AsInteger <> LFrmUlke.Table.Id.AsInteger then
              begin
                TPrsPersonel(Table).SehirID.Value := 0;
                edtsehir_id.Clear;
                edtilce.Clear;
                edtmahalle.Clear;
                edtposta_kodu.Clear;
              end;

              TPrsPersonel(Table).UlkeID.Value := LFrmUlke.Table.Id.AsInteger;
              TEdit(Sender).Text := LUlke.UlkeAdi.AsString;
            end;
          end;
        finally
          LFrmUlke.Free;
        end;
      end else if (TEdit(Sender).Name = edtsehir_id.Name) then
      begin
        LSehir := TSysSehir.Create(Table.Database);
        LFrmSehir := TfrmSysSehirler.Create(TEdit(Sender), Self, LSehir, fomNormal, True);
        try
          LFrmSehir.QryFiltreVarsayilan := ' AND ' + LSehir.TableName + '.' + LSehir.UlkeAdiID.FieldName + '=' + VarToStr(TPrsPersonel(Table).UlkeID.Value);
          LFrmSehir.ShowModal;
          if LFrmSehir.DataAktar then
          begin
            if LFrmSehir.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              edtilce.Clear;
              edtmahalle.Clear;
              edtposta_kodu.Clear;
            end
            else
            begin
              if TPrsPersonel(Table).SehirID.AsInteger <> LFrmSehir.Table.Id.AsInteger then
              begin
                edtilce.Clear;
                edtmahalle.Clear;
                edtposta_kodu.Clear;
              end;
            end;

            TPrsPersonel(Table).SehirID.Value := LFrmSehir.Table.Id.AsInteger;
            TEdit(Sender).Text := LSehir.SehirAdi.AsString;
          end;
        finally
          LFrmSehir.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtmahalle.Name) then
      begin
        LMahlle := TSysMahalle.Create(Table.Database);
        LFrmMahalle := TfrmSysMahalleler.Create(TEdit(Sender), Self, LMahlle, fomNormal, True);
        try
          LFrmMahalle.QryFiltreVarsayilan := ' AND ' + LMahlle.SehirAdi.FieldName + '=' + QuotedStr(edtsehir_id.Text);
          LFrmMahalle.ShowModal;
          if LFrmMahalle.DataAktar then
          begin
            if LFrmMahalle.CleanAndClose then
            begin
              edtilce.Clear;
              TEdit(Sender).Clear;
              edtposta_kodu.Clear;
            end
            else
            begin
              edtilce.Text := LMahlle.IlceAdi.AsString;
              TEdit(Sender).Text := LMahlle.MahalleAdi.AsString;
              edtposta_kodu.Text := LMahlle.PostaKodu.AsString;
            end;
          end;
        finally
          LFrmMahalle.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmPrsPersonel.pgcMainChange(Sender: TObject);
begin
  inherited;
  lblad.Parent := pgcMain.ActivePage;
  edtad.Parent := pgcMain.ActivePage;
  lblsoyad.Parent := pgcMain.ActivePage;
  edtsoyad.Parent := pgcMain.ActivePage;

  if pgcMain.ActivePage.Name = tsMain.Name then
  begin
    edtad.ReadOnly := False;
    edtad.TabStop := True;
    edtsoyad.ReadOnly := False;
    edtsoyad.TabStop := True;

    edtad.TabOrder := 0;
    edtsoyad.TabOrder := 1;

    edtad.SetFocus;
  end
  else
  begin
    edtad.TabOrder := 0;
    edtsoyad.TabOrder := 1;

    edtad.ReadOnly := True;
    edtad.TabStop := False;
    edtad.ReadOnly := True;
    edtsoyad.TabStop := False;
  end;
end;

procedure TfrmPrsPersonel.RefreshData;
begin
  chkis_aktif.Checked := TPrsPersonel(Table).IsAktif.Value;
  edtad.Text := TPrsPersonel(Table).Ad.Value;
  edtsoyad.Text := TPrsPersonel(Table).Soyad.Value;
  cbbpersonel_tipi_id.ItemIndex := cbbpersonel_tipi_id.Items.IndexOf(TPrsPersonel(Table).PersonelTipi.Value);

  edtbolum_id.Text := TPrsPersonel(Table).Bolum.Value;
  edtbirim_id.Text := TPrsPersonel(Table).Birim.Value;
  edtgorev_id.Text := TPrsPersonel(Table).Gorev.Value;

  mmogenel_not.Text := TPrsPersonel(Table).GenelNot.Value;
  cbbtasima_servisi_id.ItemIndex := cbbtasima_servisi_id.Items.IndexOf(TPrsPersonel(Table).TasimaServisi.Value);

  edtulke_id.Text := TPrsPersonel(Table).Ulke.Value;
  edtsehir_id.Text := TPrsPersonel(Table).Sehir.Value;

  edtilce.Text := TPrsPersonel(Table).Ilce.Value;
  edtmahalle.Text := TPrsPersonel(Table).Mahalle.Value;
  edtcadde.Text := TPrsPersonel(Table).Cadde.Value;
  edtsokak.Text := TPrsPersonel(Table).Sokak.Value;
  edtbina_adi.Text := TPrsPersonel(Table).BinaAdi.Value;
  edtkapi_no.Text := TPrsPersonel(Table).KapiNo.Value;
  edtposta_kutusu.Text := TPrsPersonel(Table).PostaKutusu.Value;
  edtposta_kodu.Text := TPrsPersonel(Table).PostaKodu.Value;

  edttel1.Text := TPrsPersonel(Table).Tel1.Value;
  edttel2.Text := TPrsPersonel(Table).Tel2.Value;
  edtemail.Text := TPrsPersonel(Table).EMail.Value;
  edtyakin_adi.Text := TPrsPersonel(Table).YakinAdi.Value;
  edtyakin_telefon.Text := TPrsPersonel(Table).YakinTelefon.Value;
  edtayakkabi_no.Text := TPrsPersonel(Table).AyakkabiNo.Value;
  edtelbise_bedeni.Text := TPrsPersonel(Table).ElbiseBedeni.Value;
  if FormMode = ifmUpdate then
    edtkimlik_no.Text := DecryptStr(TPrsPersonel(Table).KimlikNo.Value, GSysUygulamaAyari.CryptKey.Value)
  else
    edtkimlik_no.Text := TPrsPersonel(Table).KimlikNo.Value;
  edtdogum_tarihi.Text := TPrsPersonel(Table).DogumTarihi.Value;
  cbbkan_grubu.ItemIndex := cbbkan_grubu.Items.IndexOf(TPrsPersonel(Table).KanGrubu.Value);
  cbbcinsiyet_id.ItemIndex := cbbcinsiyet_id.Items.IndexOf(TPrsPersonel(Table).Cinsiyet.Value);
  cbbcinsiyet_idChange(cbbcinsiyet_id);
  cbbmedeni_durumu_id.ItemIndex := cbbmedeni_durumu_id.Items.IndexOf(TPrsPersonel(Table).MedeniDurumu.Value);
  cbbmedeni_durumu_idChange(cbbmedeni_durumu_id);
  edtcocuk_sayisi.Text := TPrsPersonel(Table).CocukSayisi.Value;
  cbbaskerlik_durumu_id.ItemIndex := cbbaskerlik_durumu_id.Items.IndexOf(TPrsPersonel(Table).AskerlikDurumu.Value);
  edtmaas.Text := TPrsPersonel(Table).Maas.Value;
  edtikramiye_sayisi.Text := TPrsPersonel(Table).IkramiyeSayisi.Value;
  edtikramiye_tutar.Text := TPrsPersonel(Table).IkramiyeTutar.Value;
  mmoozel_not.Text := TPrsPersonel(Table).OzelNot.Value;

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
    chkis_aktif.Visible := True;
    lblis_aktif.Visible := True;
  end;

  edtilce.ReadOnly := True;
  edtposta_kodu.ReadOnly := True;
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
        TPrsPersonel(Table).IsAktif.Value := chkis_aktif.Checked;

      TPrsPersonel(Table).Ad.Value := edtad.Text;
      TPrsPersonel(Table).Soyad.Value := edtsoyad.Text;
      TPrsPersonel(Table).AdSoyad.Value := TPrsPersonel(Table).Ad.Value + ' ' + TPrsPersonel(Table).Soyad.Value;

      if (cbbpersonel_tipi_id.ItemIndex > -1) and Assigned(cbbpersonel_tipi_id.Items.Objects[cbbpersonel_tipi_id.ItemIndex]) then
        TPrsPersonel(Table).PersonelTipiID.Value := TSetPrsPersonelTipi(cbbpersonel_tipi_id.Items.Objects[cbbpersonel_tipi_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).PersonelTipiID.Value := 0;

      //section, unit, task data take from helper form
      TPrsPersonel(Table).GenelNot.Value := mmogenel_not.Text;
      if (cbbtasima_servisi_id.ItemIndex > -1) and Assigned(cbbtasima_servisi_id.Items.Objects[cbbtasima_servisi_id.ItemIndex]) then
        TPrsPersonel(Table).TasimaServisiID.Value := TSetPrsServisAraci(cbbtasima_servisi_id.Items.Objects[cbbtasima_servisi_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).TasimaServisiID.Value := 0;

      //country and city data take from helper form
      TPrsPersonel(Table).Ilce.Value := edtilce.Text;
      TPrsPersonel(Table).Mahalle.Value := edtmahalle.Text;
      TPrsPersonel(Table).Cadde.Value := edtcadde.Text;
      TPrsPersonel(Table).Sokak.Value := edtsokak.Text;
      TPrsPersonel(Table).BinaAdi.Value := edtbina_adi.Text;
      TPrsPersonel(Table).KapiNo.Value := edtkapi_no.Text;
      TPrsPersonel(Table).PostaKutusu.Value := edtposta_kutusu.Text;
      TPrsPersonel(Table).PostaKodu.Value := edtposta_kodu.Text;

      TPrsPersonel(Table).Tel1.Value := edttel1.Text;
      TPrsPersonel(Table).Tel2.Value := edttel2.Text;
      TPrsPersonel(Table).EMail.Value := edtemail.Text;
      TPrsPersonel(Table).YakinAdi.Value := edtyakin_adi.Text;
      TPrsPersonel(Table).YakinTelefon.Value := edtyakin_telefon.Text;
      TPrsPersonel(Table).AyakkabiNo.Value := edtayakkabi_no.Text;
      TPrsPersonel(Table).ElbiseBedeni.Value := edtelbise_bedeni.Text;
      TPrsPersonel(Table).KimlikNo.Value := EncryptStr(edtkimlik_no.Text, GSysUygulamaAyari.CryptKey.Value);
      TPrsPersonel(Table).DogumTarihi.Value := edtdogum_tarihi.Text;
      TPrsPersonel(Table).KanGrubu.Value := cbbkan_grubu.Text;

      if (cbbcinsiyet_id.ItemIndex > -1) and Assigned(cbbcinsiyet_id.Items.Objects[cbbcinsiyet_id.ItemIndex]) then
        TPrsPersonel(Table).CinsiyetID.Value := TSetPrsCinsiyet(cbbcinsiyet_id.Items.Objects[cbbcinsiyet_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).CinsiyetID.Value := 0;

      if (cbbmedeni_durumu_id.ItemIndex > -1) and Assigned(cbbmedeni_durumu_id.Items.Objects[cbbmedeni_durumu_id.ItemIndex]) then
        TPrsPersonel(Table).MedeniDurumuID.Value := TSetPrsMedeniDurum(cbbmedeni_durumu_id.Items.Objects[cbbmedeni_durumu_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).MedeniDurumuID.Value := 0;

      TPrsPersonel(Table).CocukSayisi.Value := StrToIntDef(edtcocuk_sayisi.Text, 0);

      if (cbbaskerlik_durumu_id.ItemIndex > -1) and Assigned(cbbaskerlik_durumu_id.Items.Objects[cbbaskerlik_durumu_id.ItemIndex]) then
        TPrsPersonel(Table).AskerlikDurumuID.Value := TSetPrsAskerlikDurumu(cbbaskerlik_durumu_id.Items.Objects[cbbaskerlik_durumu_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).AskerlikDurumuID.Value := 0;

      TPrsPersonel(Table).Maas.Value := edtmaas.moneyToDouble;
      TPrsPersonel(Table).IkramiyeSayisi.Value := edtikramiye_sayisi.Text;
      TPrsPersonel(Table).IkramiyeTutar.Value := edtikramiye_tutar.moneyToDouble;
      TPrsPersonel(Table).OzelNot.Value := mmoozel_not.Text;

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
