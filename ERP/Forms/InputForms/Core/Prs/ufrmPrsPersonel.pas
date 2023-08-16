unit ufrmPrsPersonel;

interface

{$I Ths.inc}

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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB,

  ufrmSetPrsPersonelTipleri,
  ufrmSetEmpSections,
  ufrmSetPrsBirimler,
  ufrmSetEmpTasks,
  ufrmSetEmpTransportServices,
  ufrmSysUlkeler,
  ufrmSysSehirler,
  Ths.Database.Table.SetPrsPersonelTipleri,
  Ths.Database.Table.SetPrsBolumler,
  Ths.Database.Table.SetPrsBirimler,
  Ths.Database.Table.SetPrsGorevler,
  Ths.Database.Table.SetPrsTasimaServisleri,
  Ths.Database.Table.SysAdresler,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.PrsPersonelEhliyetleri,
  Ths.Database.Table.PrsLisanBilgileri,
  Ths.Database.Table.SetPrsEhliyetler;

type
  TfrmPrsPersonel = class(TfrmBaseInputDB)
    tsDetail: TTabSheet;
    tsSpecial: TTabSheet;
    lblis_aktif: TLabel;
    lblmaas: TLabel;
    lblozel_not: TLabel;
    lblikramiye_sayisi: TLabel;
    lblikramiye_tutar: TLabel;
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
    edtbolum_id: TEdit;
    edtbirim_id: TEdit;
    edtgorev_id: TEdit;
    lblbina_adi: TLabel;
    lblsokak: TLabel;
    lblcadde: TLabel;
    lblmahalle: TLabel;
    lblilce: TLabel;
    lblsehir_id: TLabel;
    lblulke_id: TLabel;
    lblkapi_no: TLabel;
    edtilce: TEdit;
    edtmahalle: TEdit;
    edtcadde: TEdit;
    edtsokak: TEdit;
    edtbina_adi: TEdit;
    edtkapi_no: TEdit;
    edtulke_id: TEdit;
    edtsehir_id: TEdit;
    lblsemt: TLabel;
    edtsemt: TEdit;
    edtposta_kodu: TEdit;
    lblposta_kodu: TLabel;
    procedure pgcMainChange(Sender: TObject);
    procedure cbbcinsiyet_idChange(Sender: TObject);
    procedure cbbmedeni_durumu_idChange(Sender: TObject);
    procedure btnDriverLicenseAddClick(Sender: TObject);
  private
    FSetPrsPersonelTipi: TSetPrsPersonelTipi;
    FSetPrsTasimaServisi: TSetPrsTasimaServisi;

    procedure resizeGrid(AGrid: TStringGrid; ACols: Array of Integer);
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
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.PrsPersoneller;

{$R *.dfm}

procedure TfrmPrsPersonel.btnDriverLicenseAddClick(Sender: TObject);
begin
//
end;

procedure TfrmPrsPersonel.cbbcinsiyet_idChange(Sender: TObject);
begin
  if cbbcinsiyet_id.ItemIndex < 0 then
    Exit;

  if Assigned(cbbcinsiyet_id.Items.Objects[cbbcinsiyet_id.ItemIndex]) then
  begin
    if cbbcinsiyet_id.ItemIndex = Ord(TGender.Erkek) then
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
    if cbbmedeni_durumu_id.ItemIndex = Ord(TMaritalStatus.Evli) then
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

procedure TfrmPrsPersonel.resizeGrid(AGrid: TStringGrid; ACols: Array of Integer);
var
  n1, vWidth: Integer;
begin
  AGrid.FixedCols := 1;
  AGrid.FixedRows := 1;
  AGrid.ColCount := Length(ACols);
  AGrid.RowCount := 2;

  AGrid.DefaultColWidth := 24;
  AGrid.DefaultRowHeight := 18;
  for n1 := 0 to Length(ACols)-1 do
    AGrid.ColWidths[n1] := ACols[n1];

  vWidth := 0;
  for n1 := 0 to AGrid.ColCount-1 do
    vWidth := vWidth + AGrid.ColWidths[n1] + AGrid.GridLineWidth;
  AGrid.Width := vWidth + 28;
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


  FSetPrsPersonelTipi := TSetPrsPersonelTipi.Create(Table.Database);
  FSetPrsTasimaServisi := TSetPrsTasimaServisi.Create(Table.Database);

  FSetPrsPersonelTipi.SelectToList('', False, False);
  cbbpersonel_tipi_id.Clear;
  for n1 := 0 to FSetPrsPersonelTipi.List.Count-1 do
    cbbpersonel_tipi_id.Items.AddObject(TSetPrsPersonelTipi(FSetPrsPersonelTipi.List[n1]).PersonelTipi.AsString, TSetPrsPersonelTipi(FSetPrsPersonelTipi.List[n1]));
  cbbpersonel_tipi_id.ItemIndex := -1;

  FSetPrsTasimaServisi.SelectToList('', False, False);
  cbbtasima_servisi_id.Clear;
  for n1 := 0 to FSetPrsTasimaServisi.List.Count-1 do
    cbbtasima_servisi_id.Items.AddObject(TSetPrsTasimaServisi(FSetPrsTasimaServisi.List[n1]).AracAdi.AsString, TSetPrsTasimaServisi(FSetPrsTasimaServisi.List[n1]));
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

  cbbcinsiyet_id.Clear;
  cbbcinsiyet_id.Items.Add(Ord(TGender.Erkek).ToString);
  cbbcinsiyet_id.Items.Add(Ord(TGender.Kadin).ToString);
  cbbcinsiyet_id.ItemIndex := -1;

  cbbmedeni_durumu_id.Clear;
  cbbmedeni_durumu_id.Items.Add(Ord(TMaritalStatus.Bekar).ToString);
  cbbmedeni_durumu_id.Items.Add(Ord(TMaritalStatus.Evli).ToString);
  cbbmedeni_durumu_id.ItemIndex := -1;

  cbbaskerlik_durumu_id.Clear;
  cbbaskerlik_durumu_id.Items.Add(Ord(TMilitaryState.Yapti).ToString);
  cbbaskerlik_durumu_id.ItemIndex := -1;
end;

procedure TfrmPrsPersonel.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetPrsPersonelTipi) then
    FSetPrsPersonelTipi.Free;
  if Assigned(FSetPrsTasimaServisi) then
    FSetPrsTasimaServisi.Free;
  inherited;
end;

procedure TfrmPrsPersonel.FormShow(Sender: TObject);
begin
  edtbolum_id.OnHelperProcess := HelperProcess;
  edtbirim_id.OnHelperProcess := HelperProcess;
  edtgorev_id.OnHelperProcess := HelperProcess;
  edtulke_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;

  inherited;
end;

procedure TfrmPrsPersonel.HelperProcess(Sender: TObject);
var
  LFrmGorev: TfrmSetEmpTasks;
  LGorev: TSetPrsGorev;
  LFrmCity: TfrmSysSehirler;
  LCity: TSysSehir;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if (TEdit(Sender).Name = edtgorev_id.Name) then
      begin
        LGorev := TSetPrsGorev.Create(Table.Database);
        LFrmGorev := TfrmSetEmpTasks.Create(TEdit(Sender), Self, LGorev, fomNormal, True);
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
      end else if (TEdit(Sender).Name = edtsehir_id.Name) then
      begin
        LCity := TSysSehir.Create(Table.Database);
        LFrmCity := TfrmSysSehirler.Create(TEdit(Sender), Self, LCity, fomNormal, True);
        try
          LFrmCity.ShowModal;
          if LFrmCity.DataAktar then
          begin
            if LFrmCity.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              edtilce.Clear;
              edtmahalle.Clear;
              edtposta_kodu.Clear;
            end
            else
            begin
              if TPrsPersonel(Table).Adres.SehirId.AsInteger <> LFrmCity.Table.Id.AsInteger then
              begin
                edtilce.Clear;
                edtmahalle.Clear;
                edtposta_kodu.Clear;
              end;
            end;

            TPrsPersonel(Table).Adres.SehirId.Value := LFrmCity.Table.Id.AsInteger;
            TEdit(Sender).Text := LCity.Sehir.AsString;
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
  edtad.Text := TPrsPersonel(Table).Ad.Value;
  edtsoyad.Text := TPrsPersonel(Table).Soyad.Value;
  cbbpersonel_tipi_id.ItemIndex := cbbpersonel_tipi_id.Items.IndexOf(TPrsPersonel(Table).PersonelTipi.Value);

  edtbirim_id.Text := TPrsPersonel(Table).Birim.Value;
  edtgorev_id.Text := TPrsPersonel(Table).Gorev.Value;

  mmogenel_not.Text := TPrsPersonel(Table).GenelNot.Value;
  cbbtasima_servisi_id.ItemIndex := cbbtasima_servisi_id.Items.IndexOf(TPrsPersonel(Table).TasimaServis.Value);

  edtsehir_id.Text := TPrsPersonel(Table).Adres.Sehir.Value;

  edtilce.Text := TPrsPersonel(Table).Adres.Ilce.AsString;
  edtmahalle.Text := TPrsPersonel(Table).Adres.Mahalle.AsString;
  edtsemt.Text := TPrsPersonel(Table).Adres.Semt.AsString;
  edtcadde.Text := TPrsPersonel(Table).Adres.Cadde.AsString;
  edtsokak.Text := TPrsPersonel(Table).Adres.Sokak.AsString;
  edtbina_adi.Text := TPrsPersonel(Table).Adres.BinaAdi.AsString;
  edtkapi_no.Text := TPrsPersonel(Table).Adres.KapiNo.AsString;
  edtposta_kodu.Text := TPrsPersonel(Table).Adres.PostaKodu.AsString;
  edtemail.Text := TPrsPersonel(Table).Adres.Email.AsString;

  edttel1.Text := TPrsPersonel(Table).Tel1.Value;
  edttel2.Text := TPrsPersonel(Table).Tel2.Value;
  edtyakin_adi.Text := TPrsPersonel(Table).YakinAdi.Value;
  edtyakin_telefon.Text := TPrsPersonel(Table).YakinTelefon.Value;
  edtayakkabi_no.Text := TPrsPersonel(Table).AyakkabiNo.Value;
  edtelbise_bedeni.Text := TPrsPersonel(Table).ElbiseBedeni.Value;
  if FormMode = ifmUpdate then
    edtkimlik_no.Text := DecryptStr(TPrsPersonel(Table).Identification.Value, GSysApplicationSetting.CryptKey.Value)
  else
    edtkimlik_no.Text := TPrsPersonel(Table).Identification.Value;
  edtdogum_tarihi.Text := TPrsPersonel(Table).DogumTarihi.Value;
  cbbkan_grubu.ItemIndex := cbbkan_grubu.Items.IndexOf(TPrsPersonel(Table).KanGrubu.Value);
  cbbcinsiyet_id.ItemIndex := cbbcinsiyet_id.Items.IndexOf(TPrsPersonel(Table).Cinsiyet.Value);
  cbbcinsiyet_idChange(cbbcinsiyet_id);
  cbbmedeni_durumu_id.ItemIndex := cbbmedeni_durumu_id.Items.IndexOf(TPrsPersonel(Table).MedeniDurum.Value);
  cbbmedeni_durumu_idChange(cbbmedeni_durumu_id);
  edtcocuk_sayisi.Text := TPrsPersonel(Table).CocukSayisi.Value;
  cbbaskerlik_durumu_id.ItemIndex := cbbaskerlik_durumu_id.Items.IndexOf(TPrsPersonel(Table).AskerlikDurumu.Value);
  edtmaas.Text := TPrsPersonel(Table).Maas.Value;
  edtikramiye_sayisi.Text := TPrsPersonel(Table).IkramiyeSayisi.Value;
  edtikramiye_tutar.Text := TPrsPersonel(Table).IkramiyeTutari.Value;
  mmoozel_not.Text := TPrsPersonel(Table).OzelNot.Value;

//  cbbsection_id.Enabled := True;
//  cbbcountry_id.Enabled := True;
  //imgPersonelResim.Picture.LoadFromFile(FApplicationMainPath + 'PathForPersonel+PersonelID.jpg');
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
        TPrsPersonel(Table).TasimaServisID.Value := TSetPrsTasimaServisi(cbbtasima_servisi_id.Items.Objects[cbbtasima_servisi_id.ItemIndex]).Id.Value
      else
        TPrsPersonel(Table).TasimaServisID.Value := 0;

      //country and city data take from helper form
      TPrsPersonel(Table).Adres.Ilce.Value := edtilce.Text;
      TPrsPersonel(Table).Adres.Mahalle.Value := edtmahalle.Text;
      TPrsPersonel(Table).Adres.Semt.Value := edtsemt.Text;
      TPrsPersonel(Table).Adres.Cadde.Value := edtcadde.Text;
      TPrsPersonel(Table).Adres.Sokak.Value := edtsokak.Text;
      TPrsPersonel(Table).Adres.BinaAdi.Value := edtbina_adi.Text;
      TPrsPersonel(Table).Adres.KapiNo.Value := edtkapi_no.Text;
      TPrsPersonel(Table).Adres.PostaKodu.Value := edtposta_kodu.Text;
      TPrsPersonel(Table).Adres.Email.Value := edtemail.Text;

      TPrsPersonel(Table).Tel1.Value := edttel1.Text;
      TPrsPersonel(Table).Tel2.Value := edttel2.Text;
      TPrsPersonel(Table).YakinAdi.Value := edtyakin_adi.Text;
      TPrsPersonel(Table).YakinTelefon.Value := edtyakin_telefon.Text;
      TPrsPersonel(Table).AyakkabiNo.Value := edtayakkabi_no.Text;
      TPrsPersonel(Table).ElbiseBedeni.Value := edtelbise_bedeni.Text;
      TPrsPersonel(Table).Identification.Value := EncryptStr(edtkimlik_no.Text, GSysApplicationSetting.CryptKey.Value);
      TPrsPersonel(Table).DogumTarihi.Value := edtdogum_tarihi.Text;
      TPrsPersonel(Table).KanGrubu.Value := cbbkan_grubu.Text;

      TPrsPersonel(Table).Cinsiyet.Value := cbbcinsiyet_id.ItemIndex;
      TPrsPersonel(Table).MedeniDurum.Value := cbbmedeni_durumu_id.ItemIndex;
      TPrsPersonel(Table).CocukSayisi.Value := StrToIntDef(edtcocuk_sayisi.Text, 0);
      TPrsPersonel(Table).AskerlikDurumu.Value := cbbaskerlik_durumu_id.ItemIndex;

      TPrsPersonel(Table).Maas.Value := edtmaas.moneyToDouble;
      TPrsPersonel(Table).IkramiyeSayisi.Value := edtikramiye_sayisi.Text;
      TPrsPersonel(Table).IkramiyeTutari.Value := edtikramiye_tutar.moneyToDouble;
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
