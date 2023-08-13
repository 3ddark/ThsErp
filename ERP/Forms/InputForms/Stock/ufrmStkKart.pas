unit ufrmStkKart;

interface

{$I Ths.inc}

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  StrUtils,
  Vcl.Grids,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  Vcl.Samples.Spin,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.Buttons,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  udm,
  Ths.Database.Table;

type
  TfrmStkKart = class(TfrmBaseInputDB)
    lblortalama_maliyet_brm: TLabel;
    lblstok_kodu: TLabel;
    lblstok_adi: TLabel;
    lblstok_grubu_id: TLabel;
    lblolcu_birimi_id: TLabel;
    lblen_az_stok_seviyesi: TLabel;
    lblalis_iskonto: TLabel;
    lblsatis_iskonto: TLabel;
    lblsatis_fiyat: TLabel;
    lblihrac_fiyat: TLabel;
    lblortalama_maliyet: TLabel;
    lblis_satilabilir: TLabel;
    lblozel_kod: TLabel;
    lbltanim: TLabel;
    tsCinsOzelligi: TTabSheet;
    lbld3: TLabel;
    lbld2: TLabel;
    lbld1: TLabel;
    lbli3: TLabel;
    lbli2: TLabel;
    lbli1: TLabel;
    lbls6: TLabel;
    lbls5: TLabel;
    lbls4: TLabel;
    lbls3: TLabel;
    lbls2: TLabel;
    lbls1: TLabel;
    lblcins_id: TLabel;
    tsOzetler: TTabSheet;
    pnlOzetHeader: TPanel;
    pnlOzetTop: TPanel;
    lblserbest_stok_toplam_brm: TLabel;
    lblserbest_stok_toplam: TLabel;
    lblblokaj_toplam_brm: TLabel;
    lblblokaj_toplam: TLabel;
    lbldonem_basi_miktar_brm: TLabel;
    lblgiren_toplam_brm: TLabel;
    lblcikan_toplam_brm: TLabel;
    lblstok_miktari_brm: TLabel;
    lblstok_miktari: TLabel;
    lblcikan_toplam: TLabel;
    lblgiren_toplam: TLabel;
    lbldonem_basi_miktar: TLabel;
    edtdonem_basi_miktar: TEdit;
    edtgiren_toplam: TEdit;
    edtcikan_toplam: TEdit;
    edtstok_miktari: TEdit;
    edtblokaj_toplam: TEdit;
    edtserbest_stok_toplam: TEdit;
    pnlOzetMiddle: TPanel;
    lblstok_degeri_ort_brm: TLabel;
    lblstok_degeri_son_brm: TLabel;
    lbldonem_basi_deger_brm: TLabel;
    lblstok_degeri_son: TLabel;
    lblstok_degeri_ort: TLabel;
    lbldonem_basi_deger: TLabel;
    lbldonem_basi_fiyat_brm: TLabel;
    lbltoplam_alis_brm: TLabel;
    lbltoplam_satis_brm: TLabel;
    lbltoplam_satis: TLabel;
    lbltoplam_alis: TLabel;
    lbldonem_basi_fiyat: TLabel;
    edtdonem_basi_fiyat: TEdit;
    edtdonem_basi_deger: TEdit;
    edtstok_degeri_ort: TEdit;
    edtstok_degeri_son: TEdit;
    edttoplam_alis: TEdit;
    edttoplam_satis: TEdit;
    pnlOzetBottom: TPanel;
    lblozet_son_alis_brm: TLabel;
    lblozet_alis_brm: TLabel;
    lblozet_ortalama_maliyet_brm: TLabel;
    lblozet_satis_brm: TLabel;
    lblozet_son_alis: TLabel;
    lblozet_ortalama_maliyet: TLabel;
    lblozet_alis: TLabel;
    lblozet_satis: TLabel;
    edtozet_satis: TEdit;
    edtozet_alis: TEdit;
    edtozet_ortalama_maliyet: TEdit;
    edtozet_son_alis: TEdit;
    tsGrupOzellikleri: TTabSheet;
    pnlGrupHeader: TPanel;
    pnlGrupOzellikleri: TPanel;
    lblgrup_hammadde: TLabel;
    lblgrup_mamul: TLabel;
    lblgrup_hammadde_val: TLabel;
    lblgrup_mamul_val: TLabel;
    lblgrup_adi_val: TLabel;
    lblgrup_kdv_orani: TLabel;
    lblgrup_kdv_orani_val: TLabel;
    pnlAmbar: TPanel;
    lblAmbarlar: TLabel;
    strngrdAmbar: TStringGrid;
    edtcins_id: TEdit;
    edts1: TEdit;
    edts2: TEdit;
    edts3: TEdit;
    edts4: TEdit;
    edts5: TEdit;
    edts6: TEdit;
    edti1: TEdit;
    edti2: TEdit;
    edti3: TEdit;
    edtd1: TEdit;
    edtd2: TEdit;
    edtd3: TEdit;
    lblurun_tipi: TLabel;
    lblen: TLabel;
    lblboy: TLabel;
    lblyukseklik: TLabel;
    lblhacim: TLabel;
    lblvalue_hacim: TLabel;
    lblen_boy_yuseklik_brm: TLabel;
    lblmarka: TLabel;
    lblagirlik: TLabel;
    lbldiib_urun_tanimi: TLabel;
    lblmensei_id: TLabel;
    lblgtip_no: TLabel;
    lbltemin_suresi: TLabel;
    lblalis_fiyat: TLabel;
    lblagirlik_birim: TLabel;
    edtstok_kodu: TEdit;
    edtstok_adi: TEdit;
    edtstok_grubu_id: TEdit;
    edtolcu_birimi_id: TEdit;
    edtalis_iskonto: TEdit;
    edtsatis_iskonto: TEdit;
    edtalis_fiyat: TEdit;
    edtsatis_fiyat: TEdit;
    edtihrac_fiyat: TEdit;
    edtortalama_maliyet: TEdit;
    edttemin_suresi: TEdit;
    edtozel_kod: TEdit;
    edtmarka: TEdit;
    edtmensei_id: TEdit;
    edtgtip_no: TEdit;
    edten: TEdit;
    edtboy: TEdit;
    edtyukseklik: TEdit;
    edtagirlik: TEdit;
    edten_az_stok_seviyesi: TEdit;
    edtdiib_urun_tanimi: TEdit;
    mmotanim: TMemo;
    chkis_satilabilir: TCheckBox;
    btnstok_resim: TBitBtn;
    pnlstok_resim: TPanel;
    imgstok_resim: TImage;
    lbls8: TLabel;
    lbls7: TLabel;
    edts7: TEdit;
    edts8: TEdit;
    lbli4: TLabel;
    edti4: TEdit;
    lbld4: TLabel;
    edtd4: TEdit;
    lblgrup_alis_iade_kodu: TLabel;
    lblgrup_alis_kodu: TLabel;
    lblgrup_satis_iade_kodu: TLabel;
    lblgrup_satis_kodu: TLabel;
    lblgrup_alis_kodu_val: TLabel;
    lblgrup_satis_iade_kodu_val: TLabel;
    lblgrup_satis_kodu_val: TLabel;
    lblgrup_alis_iade_kodu_val: TLabel;
    pnlCinsHeader: TPanel;
    lbltemin_suresi_brm: TLabel;
    edtalis_para: TEdit;
    edtsatis_para: TEdit;
    edtihrac_para: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cbburun_tipi: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure edtcins_idChange(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
    procedure btnstok_resimClick(Sender: TObject);
    procedure edtenChange(Sender: TObject);
  public
    procedure Repaint; override;
  published
    procedure FormDestroy(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.StkKartlar, ufrmStkKartlar,
  Ths.Database.Table.SysOlcuBirimleri, ufrmSysOlcuBirimleri,
  Ths.Database.Table.StkGruplar, ufrmStkGruplar,
  Ths.Database.Table.SysParaBirimleri, ufrmSysParaBirimleri,
  Ths.Database.Table.StkCinsOzellikleri, ufrmStkCinsOzellikleri,
  Ths.Database.Table.SysUlkeler, ufrmSysUlkeler;

{$R *.dfm}

procedure TfrmStkKart.btnstok_resimClick(Sender: TObject);
var
  LFilter, LFileName: string;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    LFilter := 'Image File *.(' + FILE_EXT_PNG + ',' + FILE_EXT_JPG + ',' + FILE_EXT_BMP + ')|' +
                           '*.' + FILE_EXT_PNG+';*.' + FILE_EXT_JPG+';*.' + FILE_EXT_BMP;
    GetDialogOpen(LFilter, LFileName);
    if (LFileName <> '') and FileExists(LFileName) then
    begin
      if GetFileSize(LFileName) > 500000 then
        CreateExceptionByLang('Dosya botutu 500 KB �zerinde olamaz', '999999');
      imgstok_resim.Picture.LoadFromFile(LFileName);
    end;
  end;
end;

procedure TfrmStkKart.edtcins_idChange(Sender: TObject);
var
  LCins: TStkCinsOzelligi;
begin
  lbls1.Visible := False;
  lbls2.Visible := False;
  lbls3.Visible := False;
  lbls4.Visible := False;
  lbls5.Visible := False;
  lbls6.Visible := False;
  lbls7.Visible := False;
  lbls8.Visible := False;
  lbli1.Visible := False;
  lbli2.Visible := False;
  lbli3.Visible := False;
  lbli4.Visible := False;
  lbld1.Visible := False;
  lbld2.Visible := False;
  lbld3.Visible := False;
  lbld4.Visible := False;

  edts1.Visible := False;
  edts2.Visible := False;
  edts3.Visible := False;
  edts4.Visible := False;
  edts5.Visible := False;
  edts6.Visible := False;
  edts7.Visible := False;
  edts8.Visible := False;
  edti1.Visible := False;
  edti2.Visible := False;
  edti3.Visible := False;
  edti4.Visible := False;
  edtd1.Visible := False;
  edtd2.Visible := False;
  edtd3.Visible := False;
  edtd4.Visible := False;

  if TStkKart(Table).CinsID.AsInt64 > 0 then
  begin
    LCins := TStkCinsOzelligi.Create(Table.Database);
    try
      LCins.SelectToList(' AND ' + LCins.TableName + '.' + LCins.Id.FieldName + '=' + IntToStr(TStkKart(Table).CinsID.Value), False, False);
      if LCins.List.Count = 1 then
      begin
        if LCins.S1.Value <> '' then
        begin
          lbls1.Visible := True;
          edts1.Visible := True;
        end;
        if LCins.S2.Value <> '' then
        begin
          lbls2.Visible := True;
          edts2.Visible := True;
        end;
        if LCins.S3.Value <> '' then
        begin
          lbls3.Visible := True;
          edts3.Visible := True;
        end;
        if LCins.S4.Value <> '' then
        begin
          lbls4.Visible := True;
          edts4.Visible := True;
        end;
        if LCins.S5.Value <> '' then
        begin
          lbls5.Visible := True;
          edts5.Visible := True;
        end;
        if LCins.S6.Value <> '' then
        begin
          lbls6.Visible := True;
          edts6.Visible := True;
        end;
        if LCins.S7.Value <> '' then
        begin
          lbls7.Visible := True;
          edts7.Visible := True;
        end;
        if LCins.S8.Value <> '' then
        begin
          lbls8.Visible := True;
          edts8.Visible := True;
        end;

        if LCins.I1.AsString <> '' then
        begin
          lbli1.Visible := True;
          edti1.Visible := True;
        end;
        if LCins.I2.AsString <> '' then
        begin
          lbli2.Visible := True;
          edti2.Visible := True;
        end;
        if LCins.I3.AsString <> '' then
        begin
          lbli3.Visible := True;
          edti3.Visible := True;
        end;
        if LCins.I4.AsString <> '' then
        begin
          lbli4.Visible := True;
          edti4.Visible := True;
        end;

        if LCins.D1.AsString <> '' then
        begin
          lbld1.Visible := True;
          edtd1.Visible := True;
        end;
        if LCins.D2.AsString <> '' then
        begin
          lbld2.Visible := True;
          edtd2.Visible := True;
        end;
        if LCins.D3.AsString <> '' then
        begin
          lbld3.Visible := True;
          edtd3.Visible := True;
        end;
        if LCins.D4.AsString <> '' then
        begin
          lbld4.Visible := True;
          edtd4.Visible := True;
        end;

        lbls1.Caption := LCins.S1.AsString;
        lbls2.Caption := LCins.S2.AsString;
        lbls3.Caption := LCins.S3.AsString;
        lbls4.Caption := LCins.S4.AsString;
        lbls5.Caption := LCins.S5.AsString;
        lbls6.Caption := LCins.S6.AsString;
        lbls7.Caption := LCins.S7.AsString;
        lbls8.Caption := LCins.S8.AsString;
        lbli1.Caption := LCins.I1.AsString;
        lbli2.Caption := LCins.I2.AsString;
        lbli3.Caption := LCins.I3.AsString;
        lbli4.Caption := LCins.I4.AsString;
        lbld1.Caption := LCins.D1.AsString;
        lbld2.Caption := LCins.D2.AsString;
        lbld3.Caption := LCins.D3.AsString;
        lbld4.Caption := LCins.D4.AsString;
      end;
    finally
      LCins.Free;
    end;
  end;
end;

procedure TfrmStkKart.edtenChange(Sender: TObject);
begin
  lblvalue_hacim.Caption :=
    FormatFloat('0.0000',
      (StrToFloatDef(edten.Text, 0) *
       StrToFloatDef(edtboy.Text, 0) *
       StrToFloatDef(edtyukseklik.Text, 0)) / 1000000
    );
end;

procedure TfrmStkKart.FormCreate(Sender: TObject);
begin
  inherited;

  lblortalama_maliyet_brm.Caption := GSysApplicationSetting.Para.AsString;

  dm.il16.GetBitmap(IMG_IMAGE, btnstok_resim.Glyph);
end;

procedure TfrmStkKart.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmStkKart.FormShow(Sender: TObject);
begin
  edtstok_grubu_id.OnHelperProcess := HelperProcess;
  edtolcu_birimi_id.OnHelperProcess := HelperProcess;
  edtcins_id.OnHelperProcess := HelperProcess;
  edtmensei_id.OnHelperProcess := HelperProcess;
  edtalis_para.OnHelperProcess := HelperProcess;
  edtsatis_para.OnHelperProcess := HelperProcess;
  edtihrac_para.OnHelperProcess := HelperProcess;

  mmotanim.CharCase := ecNormal;

  inherited;

  edtortalama_maliyet.thsRequiredData := False;
  edtortalama_maliyet.ReadOnly := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    chkis_satilabilir.Checked := True;
    edtalis_iskonto.Text := '0.00';
    edtsatis_iskonto.Text := '0.00';

    edtalis_fiyat.Text := '0.00';
    edtsatis_fiyat.Text := '0.00';
    edtihrac_fiyat.Text := '0.00';
    edtortalama_maliyet.Text := '0.00';

    edten.Text := '0.00';
    edtboy.Text := '0.00';
    edtyukseklik.Text := '0.00';
    edtagirlik.Text := '0.00';
    edten_az_stok_seviyesi.Text := '0.00';

    if (FormMode = ifmCopyNewRecord) then
    begin
      lblgrup_kdv_orani_val.Caption := '';
      lblgrup_hammadde_val.Caption := '';
      lblgrup_mamul_val.Caption := '';
      Label1.Caption := '';
      lblgrup_alis_kodu_val.Caption := '';
      lblgrup_satis_iade_kodu_val.Caption := '';
      lblgrup_satis_kodu_val.Caption := '';
      lblgrup_alis_iade_kodu_val.Caption := '';
    end;
  end;
end;

procedure TfrmStkKart.HelperProcess(Sender: TObject);
var
  LFrmGrup: TfrmStkGruplar;
  LFrmOlcuBirimi: TfrmSysOlcuBirimleri;
  LFrmKind: TfrmStkCinsOzellikleri;
  LFrmCountry: TfrmSysUlkeler;
  LFrmMoney: TfrmSysParaBirimleri;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtstok_grubu_id.Name then
      begin
        LFrmGrup := TfrmStkGruplar.Create(TEdit(Sender), Self, TStkGruplar.Create(Table.Database), fomNormal, True);
        try
          LFrmGrup.ShowModal;
          if LFrmGrup.DataAktar then
          begin
            if LFrmGrup.CleanAndClose then
            begin
              TEdit(Sender).Clear;
            end else begin
              TEdit(Sender).Text := TStkGruplar(LFrmGrup.Table).Grup.AsString;
              TStkKart(Table).StokGrubuID.Value := LFrmGrup.Table.Id.Value;

              lblgrup_satis_kodu_val.Caption := TStkGruplar(LFrmGrup.Table).SatisHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).SatisHesapAdi.AsString;
              lblgrup_satis_iade_kodu_val.Caption := TStkGruplar(LFrmGrup.Table).SatisIadeHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).SatisIadeHesapAdi.AsString;
              lblgrup_alis_kodu_val.Caption := TStkGruplar(LFrmGrup.Table).AlisHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).AlisHesapAdi.AsString;
              lblgrup_alis_iade_kodu_val.Caption := TStkGruplar(LFrmGrup.Table).AlisIadeHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).AlisIadeHesapAdi.AsString;
              Label1.Caption := TStkGruplar(LFrmGrup.Table).IhracatHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).IhracatHesapAdi.AsString;
              lblgrup_hammadde_val.Caption := TStkGruplar(LFrmGrup.Table).HammaddeHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).HammaddeHesapAdi.AsString;
              lblgrup_mamul_val.Caption := TStkGruplar(LFrmGrup.Table).MamulHesapKodu.AsString + ' ' + TStkGruplar(LFrmGrup.Table).MamulHesapAdi.AsString;
              lblgrup_kdv_orani_val.Caption := TStkGruplar(LFrmGrup.Table).KDVOrani.AsString;
            end;
          end;
        finally
          LFrmGrup.Free;
        end;
      end
      else if TEdit(Sender).Name = edtolcu_birimi_id.Name then
      begin
        LFrmOlcuBirimi := TfrmSysOlcuBirimleri.Create(TEdit(Sender), Self, TSysOlcuBirimi.Create(Table.Database), fomNormal, True);
        try
          LFrmOlcuBirimi.ShowModal;
          if LFrmOlcuBirimi.DataAktar then
          begin
            if LFrmOlcuBirimi.CleanAndClose then
            begin
              TEdit(Sender).Clear;
            end else begin
              TEdit(Sender).Text := TSysOlcuBirimi(LFrmOlcuBirimi.Table).Birim.AsString;
              TStkKart(Table).OlcuBirimiID.Value := LFrmOlcuBirimi.Table.Id.Value;
            end;
          end;
        finally
          LFrmOlcuBirimi.Free;
        end;
      end
      else if TEdit(Sender).Name = edtcins_id.Name then
      begin
        LFrmKind := TfrmStkCinsOzellikleri.Create(TEdit(Sender), Self, TStkCinsOzelligi.Create(Table.Database), fomNormal, True);
        try
          LFrmKind.ShowModal;
          if LFrmKind.DataAktar then
          begin
            if LFrmKind.CleanAndClose then
            begin
              edtcins_id.Clear;
              TStkKart(Table).CinsID.Value := 0;
            end else begin
              edtcins_id.Text := TStkCinsOzelligi(LFrmKind.Table).Cins.AsString;
              TStkKart(Table).CinsID.Value := LFrmKind.Table.Id.Value;
            end;
            edtcins_idChange(edtcins_id);
          end;
        finally
          LFrmKind.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmensei_id.Name then
      begin
        LFrmCountry := TfrmSysUlkeler.Create(TEdit(Sender), Self, TSysUlke.Create(Table.Database), fomNormal, True);
        try
          LFrmCountry.ShowModal;
          if LFrmCountry.DataAktar then
          begin
            if LFrmCountry.CleanAndClose then
            begin
              edtmensei_id.Clear;
            end else begin
              edtmensei_id.Text := TSysUlke(LFrmCountry.Table).UlkeAdi.AsString;
              TStkKart(Table).MenseiID.Value := LFrmCountry.Table.Id.AsInt64;
            end;
          end;
        finally
          LFrmCountry.Free;
        end;
      end
      else
      if (TEdit(Sender).Name = edtalis_para.Name)
      or (TEdit(Sender).Name = edtsatis_para.Name)
      or (TEdit(Sender).Name = edtihrac_para.Name)
      then
      begin
        LFrmMoney := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, TSysParaBirimi.Create(GDataBase), fomNormal, True);
        try
          LFrmMoney.ShowModal;
          if LFrmMoney.DataAktar then
          begin
            if LFrmMoney.CleanAndClose
            then  TEdit(Sender).Clear
            else  TEdit(Sender).Text := TSysParaBirimi(LFrmMoney.Table).Para.AsString;
          end;
        finally
          LFrmMoney.Free;
        end;
      end
    end;
  end
end;

procedure TfrmStkKart.pgcMainChange(Sender: TObject);
var
  LGrup: TStkGruplar;
begin
  if pgcMain.ActivePage.Name = tsCinsOzelligi.Name then
  begin
    lblstok_kodu.Parent := pnlCinsHeader;
    edtstok_kodu.Parent := pnlCinsHeader;
    lblstok_adi.Parent := pnlCinsHeader;
    edtstok_adi.Parent := pnlCinsHeader;
  end
  else if pgcMain.ActivePage.Name = tsOzetler.Name then
  begin
    lblstok_kodu.Parent := pnlOzetHeader;
    edtstok_kodu.Parent := pnlOzetHeader;
    lblstok_adi.Parent := pnlOzetHeader;
    edtstok_adi.Parent := pnlOzetHeader;

    lbldonem_basi_miktar_brm.Caption := edtolcu_birimi_id.Text;
    lblgiren_toplam_brm.Caption := edtolcu_birimi_id.Text;
    lblcikan_toplam_brm.Caption := edtolcu_birimi_id.Text;
    lblstok_miktari_brm.Caption := edtolcu_birimi_id.Text;
    lblblokaj_toplam_brm.Caption := edtolcu_birimi_id.Text;
    lblserbest_stok_toplam_brm.Caption := edtolcu_birimi_id.Text;

    lbldonem_basi_fiyat_brm.Caption := lblortalama_maliyet_brm.Caption;
    lbldonem_basi_deger_brm.Caption := lblortalama_maliyet_brm.Caption;
    lblstok_degeri_ort_brm.Caption := lblortalama_maliyet_brm.Caption;
    lblstok_degeri_son_brm.Caption := lblortalama_maliyet_brm.Caption;
    lbltoplam_alis_brm.Caption := lblortalama_maliyet_brm.Caption;
    lbltoplam_satis_brm.Caption := lblortalama_maliyet_brm.Caption;

    lblozet_satis_brm.Caption := edtsatis_para.Text;
    lblozet_alis_brm.Caption := edtalis_para.Text;
    lblozet_ortalama_maliyet_brm.Caption := lblortalama_maliyet_brm.Caption;
    lblozet_son_alis_brm.Caption := edtalis_para.Text;
  end
  else
  if pgcMain.ActivePage.Name = tsGrupOzellikleri.Name then
  begin
    lblstok_kodu.Parent := pnlGrupHeader;
    edtstok_kodu.Parent := pnlGrupHeader;
    lblstok_adi.Parent := pnlGrupHeader;
    edtstok_adi.Parent := pnlGrupHeader;

    lblgrup_adi_val.Caption := edtstok_grubu_id.Text;
    if (FormMode <> ifmNewRecord) and (FormMode <> ifmCopyNewRecord) then
    begin
      LGrup := TStkGruplar.Create(Table.Database);
      try
        LGrup.SelectToList(' AND ' + LGrup.Grup.QryName + '=' + QuotedStr(edtstok_grubu_id.Text), False, False);
        if LGrup.List.Count = 1 then
        begin
          lblgrup_satis_kodu_val.Caption := LGrup.SatisHesapKodu.AsString + ' ' + LGrup.SatisHesapAdi.AsString;
          lblgrup_satis_iade_kodu_val.Caption := LGrup.SatisIadeHesapKodu.AsString + ' ' + LGrup.SatisIadeHesapAdi.AsString;
          lblgrup_alis_kodu_val.Caption := LGrup.AlisHesapKodu.AsString + ' ' + LGrup.AlisHesapAdi.AsString;
          lblgrup_alis_iade_kodu_val.Caption := LGrup.AlisIadeHesapKodu.AsString + ' ' + LGrup.AlisIadeHesapAdi.AsString;
          Label1.Caption := LGrup.IhracatHesapKodu.AsString + ' ' + LGrup.IhracatHesapAdi.AsString;
          lblgrup_hammadde_val.Caption := LGrup.HammaddeHesapKodu.AsString + ' ' + LGrup.HammaddeHesapAdi.AsString;
          lblgrup_mamul_val.Caption := LGrup.MamulHesapKodu.AsString + ' ' + LGrup.MamulHesapAdi.AsString;
          lblgrup_kdv_orani_val.Caption := LGrup.KDVOrani.AsString;
        end;
      finally
        LGrup.Free;
      end;
    end;
  end
  else
  begin
    lblstok_kodu.Parent := pgcMain.ActivePage;
    edtstok_kodu.Parent := pgcMain.ActivePage;
    lblstok_adi.Parent := pgcMain.ActivePage;
    edtstok_adi.Parent := pgcMain.ActivePage;
  end;

  if pgcMain.ActivePage.Name = tsMain.Name then
  begin
    edtstok_kodu.ReadOnly := False;
    edtstok_kodu.TabStop := True;
    edtstok_adi.ReadOnly := False;
    edtstok_adi.TabStop := True;

    edtstok_kodu.TabOrder := 0;
    edtstok_adi.TabOrder := 1;
    edtstok_kodu.SetFocus;
  end
  else
  begin
    edtstok_kodu.ReadOnly := True;
    edtstok_kodu.TabStop := False;
    edtstok_adi.ReadOnly := True;
    edtstok_adi.TabStop := False;
  end;
end;

procedure TfrmStkKart.RefreshData();
begin
  chkis_satilabilir.Checked := TStkKart(Table).IsSatilabilir.AsBoolean;
  edtstok_kodu.Text := TStkKart(Table).StokKodu.AsString;
  edtstok_adi.Text := TStkKart(Table).StokAdi.AsString;
  edtstok_grubu_id.Text := TStkKart(Table).StokGrubu.AsString;
  edtolcu_birimi_id.Text := TStkKart(Table).OlcuBirimi.AsString;
  cbburun_tipi.ItemIndex := TStkKart(Table).UrunTipi.AsInteger;
  edtalis_iskonto.Text := TStkKart(Table).AlisIskonto.AsString;
  edtsatis_iskonto.Text := TStkKart(Table).SatisIskonto.AsString;
  edtalis_fiyat.Text := TStkKart(Table).AlisFiyat.AsString;
  edtalis_para.Text := TStkKart(Table).AlisPara.AsString;
  edtsatis_fiyat.Text := TStkKart(Table).SatisFiyat.AsString;
  edtsatis_para.Text := TStkKart(Table).SatisPara.AsString;
  edtihrac_fiyat.Text := TStkKart(Table).IhracFiyat.AsString;
  edtihrac_para.Text := TStkKart(Table).IhracPara.AsString;
  edtEn.Text := TStkKart(Table).En.AsString;
  edtBoy.Text := TStkKart(Table).Boy.AsString;
  edtYukseklik.Text := TStkKart(Table).Yukseklik.AsString;
  edtagirlik.Text := TStkKart(Table).Agirlik.AsString;
  edttemin_suresi.Text := TStkKart(Table).TeminSuresi.AsString;
  edtozel_kod.Text := TStkKart(Table).OzelKod.AsString;
  edtmarka.Text := TStkKart(Table).Marka.AsString;
  edtmensei_id.Text := TStkKart(Table).Mensei.AsString;
  edtgtip_no.Text := TStkKart(Table).GtipNo.AsString;
  edtdiib_urun_tanimi.Text := TStkKart(Table).DiibUrunTanimi.AsString;
  edten_az_stok_seviyesi.Text := TStkKart(Table).EnAzStokSeviyesi.AsString;
  mmotanim.Text := TStkKart(Table).Tanim.AsString;
  LoadImageFromDB(TStkKart(Table).Resim, imgstok_resim);
  edtcins_id.Text := TStkKart(Table).Cins.AsString;
  edtcins_idChange(edtcins_id);
  edts1.Text := TStkKart(Table).S1.AsString;
  edts2.Text := TStkKart(Table).S2.AsString;
  edts3.Text := TStkKart(Table).S3.AsString;
  edts4.Text := TStkKart(Table).S4.AsString;
  edts5.Text := TStkKart(Table).S5.AsString;
  edts6.Text := TStkKart(Table).S6.AsString;
  edts7.Text := TStkKart(Table).S7.AsString;
  edts8.Text := TStkKart(Table).S8.AsString;
  edti1.Text := TStkKart(Table).I1.AsString;
  edti2.Text := TStkKart(Table).I2.AsString;
  edti3.Text := TStkKart(Table).I3.AsString;
  edti4.Text := TStkKart(Table).I4.AsString;
  edtd1.Text := TStkKart(Table).D1.AsString;
  edtd2.Text := TStkKart(Table).D2.AsString;
  edtd3.Text := TStkKart(Table).D3.AsString;
  edtd4.Text := TStkKart(Table).D4.AsString;

  pgcMainChange(pgcMain);
end;

procedure TfrmStkKart.Repaint;
begin
  inherited;
  edtdonem_basi_miktar.ReadOnly := True;
  edtgiren_toplam.ReadOnly := True;
  edtcikan_toplam.ReadOnly := True;
  edtstok_miktari.ReadOnly := True;
  edtblokaj_toplam.ReadOnly := True;
  edtserbest_stok_toplam.ReadOnly := True;

  edtdonem_basi_fiyat.ReadOnly := True;
  edtdonem_basi_deger.ReadOnly := True;
  edtstok_degeri_ort.ReadOnly := True;
  edtstok_degeri_son.ReadOnly := True;
  edttoplam_alis.ReadOnly := True;
  edttoplam_satis.ReadOnly := True;

  edtozet_satis.ReadOnly := True;
  edtozet_alis.ReadOnly := True;
  edtozet_ortalama_maliyet.ReadOnly := True;
  edtozet_son_alis.ReadOnly := True;
end;

procedure TfrmStkKart.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkKart(Table).IsSatilabilir.Value := chkis_satilabilir.Checked;
      TStkKart(Table).StokKodu.Value := edtstok_kodu.Text;
      TStkKart(Table).StokAdi.Value := edtstok_adi.Text;
      TStkKart(Table).StokGrubu.Value := edtstok_grubu_id.Text;
      TStkKart(Table).OlcuBirimi.Value := edtolcu_birimi_id.Text;
      TStkKart(Table).UrunTipi.Value := cbburun_tipi.ItemIndex;
      TStkKart(Table).AlisIskonto.Value := StrToFloatDef(edtalis_iskonto.Text, 0);
      TStkKart(Table).SatisIskonto.Value := StrToFloatDef(edtsatis_iskonto.Text, 0);
      TStkKart(Table).AlisFiyat.Value := edtalis_fiyat.moneyToDouble;
      TStkKart(Table).AlisPara.Value := edtalis_para.Text;
      TStkKart(Table).SatisFiyat.Value := edtsatis_fiyat.moneyToDouble;
      TStkKart(Table).SatisPara.Value := edtsatis_para.Text;
      TStkKart(Table).IhracFiyat.Value := edtihrac_fiyat.moneyToDouble;
      TStkKart(Table).IhracPara.Value := edtihrac_para.Text;
      TStkKart(Table).En.Value := StrToFloatDef(edten.Text, 0);
      TStkKart(Table).Boy.Value := StrToFloatDef(edtboy.Text, 0);
      TStkKart(Table).Yukseklik.Value := StrToFloatDef(edtyukseklik.Text, 0);
      TStkKart(Table).Agirlik.Value := StrToFloatDef(edtagirlik.Text, 0);
      TStkKart(Table).TeminSuresi.Value := StrToFloatDef(edttemin_suresi.Text, 0);
      TStkKart(Table).OzelKod.Value := edtozel_kod.Text;
      TStkKart(Table).Marka.Value := edtmarka.Text;
      TStkKart(Table).Mensei.Value := edtmensei_id.Text;
      TStkKart(Table).GtipNo.Value := edtgtip_no.Text;
      TStkKart(Table).DiibUrunTanimi.Value := edtdiib_urun_tanimi.Text;
      TStkKart(Table).EnAzStokSeviyesi.Value := StrToFloatDef(edten_az_stok_seviyesi.Text, 0);
      TStkKart(Table).Tanim.Value := mmotanim.Text;
      setValueFromImage(TStkKart(Table).Resim, imgstok_resim);
      TStkKart(Table).Cins.Value := edtcins_id.Text;
      TStkKart(Table).S1.Value := edts1.Text;
      TStkKart(Table).S2.Value := edts2.Text;
      TStkKart(Table).S3.Value := edts3.Text;
      TStkKart(Table).S4.Value := edts4.Text;
      TStkKart(Table).S5.Value := edts5.Text;
      TStkKart(Table).S6.Value := edts6.Text;
      TStkKart(Table).S7.Value := edts7.Text;
      TStkKart(Table).S8.Value := edts8.Text;
      TStkKart(Table).I1.Value := StrToIntDef(edti1.Text, 0);
      TStkKart(Table).I2.Value := StrToIntDef(edti2.Text, 0);
      TStkKart(Table).I3.Value := StrToIntDef(edti3.Text, 0);
      TStkKart(Table).I4.Value := StrToIntDef(edti4.Text, 0);
      TStkKart(Table).D1.Value := StrToFloatDef(edtd1.Text, 0);
      TStkKart(Table).D2.Value := StrToFloatDef(edtd2.Text, 0);
      TStkKart(Table).D3.Value := StrToFloatDef(edtd3.Text, 0);
      TStkKart(Table).D4.Value := StrToFloatDef(edtd4.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

end.