unit ufrmEmpEmployee;

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
  ufrmSetEmpUnits,
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
  TfrmEmpEmployee = class(TfrmBaseInputDB)
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
  Ths.Database.Table.EmpEmployee;

{$R *.dfm}

procedure TfrmEmpEmployee.btnDriverLicenseAddClick(Sender: TObject);
begin
//
end;

procedure TfrmEmpEmployee.cbbcinsiyet_idChange(Sender: TObject);
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

procedure TfrmEmpEmployee.cbbmedeni_durumu_idChange(Sender: TObject);
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

procedure TfrmEmpEmployee.resizeGrid(AGrid: TStringGrid; ACols: Array of Integer);
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

procedure TfrmEmpEmployee.FormCreate(Sender: TObject);
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

procedure TfrmEmpEmployee.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetPrsPersonelTipi) then
    FSetPrsPersonelTipi.Free;
  if Assigned(FSetPrsTasimaServisi) then
    FSetPrsTasimaServisi.Free;
  inherited;
end;

procedure TfrmEmpEmployee.FormShow(Sender: TObject);
begin
  edtbolum_id.OnHelperProcess := HelperProcess;
  edtbirim_id.OnHelperProcess := HelperProcess;
  edtgorev_id.OnHelperProcess := HelperProcess;
  edtulke_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;

  inherited;
end;

procedure TfrmEmpEmployee.HelperProcess(Sender: TObject);
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
            TEmpEmployee(Table).GorevID.Value := LFrmGorev.Table.Id.Value;
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
              if TEmpEmployee(Table).Adres.SehirId.AsInteger <> LFrmCity.Table.Id.AsInteger then
              begin
                edtilce.Clear;
                edtmahalle.Clear;
                edtposta_kodu.Clear;
              end;
            end;

            TEmpEmployee(Table).Adres.SehirId.Value := LFrmCity.Table.Id.AsInteger;
            TEdit(Sender).Text := LCity.Sehir.AsString;
          end;
        finally
          LFrmCity.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmEmpEmployee.pgcMainChange(Sender: TObject);
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

procedure TfrmEmpEmployee.RefreshData;
begin
  edtad.Text := TEmpEmployee(Table).Ad.Value;
  edtsoyad.Text := TEmpEmployee(Table).Soyad.Value;
  cbbpersonel_tipi_id.ItemIndex := cbbpersonel_tipi_id.Items.IndexOf(TEmpEmployee(Table).PersonelTipi.Value);

  edtbirim_id.Text := TEmpEmployee(Table).Birim.Value;
  edtgorev_id.Text := TEmpEmployee(Table).Gorev.Value;

  mmogenel_not.Text := TEmpEmployee(Table).GenelNot.Value;
  cbbtasima_servisi_id.ItemIndex := cbbtasima_servisi_id.Items.IndexOf(TEmpEmployee(Table).TasimaServis.Value);

  edtsehir_id.Text := TEmpEmployee(Table).Adres.Sehir.Value;

  edtmahalle.Text := TEmpEmployee(Table).Adres.Mahalle.Value;
  edtcadde.Text := TEmpEmployee(Table).Adres.Cadde.Value;
  edtsokak.Text := TEmpEmployee(Table).Adres.Sokak.Value;
  edtbina_adi.Text := TEmpEmployee(Table).Adres.BinaAdi.Value;
  edtkapi_no.Text := TEmpEmployee(Table).Adres.KapiNo.Value;
  edtposta_kutusu.Text := TEmpEmployee(Table).Adres.PostaKutusu.Value;
  edtposta_kodu.Text := TEmpEmployee(Table).Adres.PostaKodu.Value;
  edtemail.Text := TEmpEmployee(Table).Adres.Email.Value;

  edttel1.Text := TEmpEmployee(Table).Tel1.Value;
  edttel2.Text := TEmpEmployee(Table).Tel2.Value;
  edtyakin_adi.Text := TEmpEmployee(Table).YakinAdi.Value;
  edtyakin_telefon.Text := TEmpEmployee(Table).YakinTelefon.Value;
  edtayakkabi_no.Text := TEmpEmployee(Table).AyakkabiNo.Value;
  edtelbise_bedeni.Text := TEmpEmployee(Table).ElbiseBedeni.Value;
  if FormMode = ifmUpdate then
    edtkimlik_no.Text := DecryptStr(TEmpEmployee(Table).Identification.Value, GSysApplicationSetting.CryptKey.Value)
  else
    edtkimlik_no.Text := TEmpEmployee(Table).Identification.Value;
  edtdogum_tarihi.Text := TEmpEmployee(Table).DogumTarihi.Value;
  cbbkan_grubu.ItemIndex := cbbkan_grubu.Items.IndexOf(TEmpEmployee(Table).KanGrubu.Value);
  cbbcinsiyet_id.ItemIndex := cbbcinsiyet_id.Items.IndexOf(TEmpEmployee(Table).Cinsiyet.Value);
  cbbcinsiyet_idChange(cbbcinsiyet_id);
  cbbmedeni_durumu_id.ItemIndex := cbbmedeni_durumu_id.Items.IndexOf(TEmpEmployee(Table).MedeniDurum.Value);
  cbbmedeni_durumu_idChange(cbbmedeni_durumu_id);
  edtcocuk_sayisi.Text := TEmpEmployee(Table).CocukSayisi.Value;
  cbbaskerlik_durumu_id.ItemIndex := cbbaskerlik_durumu_id.Items.IndexOf(TEmpEmployee(Table).AskerlikDurumu.Value);
  edtmaas.Text := TEmpEmployee(Table).Maas.Value;
  edtikramiye_sayisi.Text := TEmpEmployee(Table).IkramiyeSayisi.Value;
  edtikramiye_tutar.Text := TEmpEmployee(Table).IkramiyeTutari.Value;
  mmoozel_not.Text := TEmpEmployee(Table).OzelNot.Value;

//  cbbsection_id.Enabled := True;
//  cbbcountry_id.Enabled := True;
  //imgPersonelResim.Picture.LoadFromFile(FApplicationMainPath + 'PathForPersonel+PersonelID.jpg');
end;

procedure TfrmEmpEmployee.Repaint;
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

procedure TfrmEmpEmployee.btnAcceptClick(Sender: TObject);
//var
//  n1: Integer;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //auto accept kodunu çaðýrmýyoruz helper kullanan bilgileri siliyor daha sonra autoaccept düzenlenecek
      TEmpEmployee(Table).Ad.Value := edtad.Text;
      TEmpEmployee(Table).Soyad.Value := edtsoyad.Text;
      TEmpEmployee(Table).AdSoyad.Value := TEmpEmployee(Table).Ad.Value + ' ' + TEmpEmployee(Table).Soyad.Value;

      if (cbbpersonel_tipi_id.ItemIndex > -1) and Assigned(cbbpersonel_tipi_id.Items.Objects[cbbpersonel_tipi_id.ItemIndex]) then
        TEmpEmployee(Table).PersonelTipiID.Value := TSetPrsPersonelTipi(cbbpersonel_tipi_id.Items.Objects[cbbpersonel_tipi_id.ItemIndex]).Id.Value
      else
        TEmpEmployee(Table).PersonelTipiID.Value := 0;

      //section, unit, task data take from helper form
      TEmpEmployee(Table).GenelNot.Value := mmogenel_not.Text;
      if (cbbtasima_servisi_id.ItemIndex > -1) and Assigned(cbbtasima_servisi_id.Items.Objects[cbbtasima_servisi_id.ItemIndex]) then
        TEmpEmployee(Table).TasimaServisID.Value := TSetPrsTasimaServisi(cbbtasima_servisi_id.Items.Objects[cbbtasima_servisi_id.ItemIndex]).Id.Value
      else
        TEmpEmployee(Table).TasimaServisID.Value := 0;

      //country and city data take from helper form
      TEmpEmployee(Table).Adres.Mahalle.Value := edtmahalle.Text;
      TEmpEmployee(Table).Adres.Cadde.Value := edtcadde.Text;
      TEmpEmployee(Table).Adres.Sokak.Value := edtsokak.Text;
      TEmpEmployee(Table).Adres.BinaAdi.Value := edtbina_adi.Text;
      TEmpEmployee(Table).Adres.KapiNo.Value := edtkapi_no.Text;
      TEmpEmployee(Table).Adres.PostaKutusu.Value := edtposta_kutusu.Text;
      TEmpEmployee(Table).Adres.PostaKodu.Value := edtposta_kodu.Text;
      TEmpEmployee(Table).Adres.Email.Value := edtemail.Text;

      TEmpEmployee(Table).Tel1.Value := edttel1.Text;
      TEmpEmployee(Table).Tel2.Value := edttel2.Text;
      TEmpEmployee(Table).YakinAdi.Value := edtyakin_adi.Text;
      TEmpEmployee(Table).YakinTelefon.Value := edtyakin_telefon.Text;
      TEmpEmployee(Table).AyakkabiNo.Value := edtayakkabi_no.Text;
      TEmpEmployee(Table).ElbiseBedeni.Value := edtelbise_bedeni.Text;
      TEmpEmployee(Table).Identification.Value := EncryptStr(edtkimlik_no.Text, GSysApplicationSetting.CryptKey.Value);
      TEmpEmployee(Table).DogumTarihi.Value := edtdogum_tarihi.Text;
      TEmpEmployee(Table).KanGrubu.Value := cbbkan_grubu.Text;

      TEmpEmployee(Table).Cinsiyet.Value := cbbcinsiyet_id.ItemIndex;
      TEmpEmployee(Table).MedeniDurum.Value := cbbmedeni_durumu_id.ItemIndex;
      TEmpEmployee(Table).CocukSayisi.Value := StrToIntDef(edtcocuk_sayisi.Text, 0);
      TEmpEmployee(Table).AskerlikDurumu.Value := cbbaskerlik_durumu_id.ItemIndex;

      TEmpEmployee(Table).Maas.Value := edtmaas.moneyToDouble;
      TEmpEmployee(Table).IkramiyeSayisi.Value := edtikramiye_sayisi.Text;
      TEmpEmployee(Table).IkramiyeTutari.Value := edtikramiye_tutar.moneyToDouble;
      TEmpEmployee(Table).OzelNot.Value := mmoozel_not.Text;

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
