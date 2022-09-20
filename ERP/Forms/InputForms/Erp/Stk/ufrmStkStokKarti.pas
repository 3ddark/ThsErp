unit ufrmStkStokKarti;

interface

{$I ThsERP.inc}

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
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  udm,
  Ths.Erp.Database.Table;

type
  TfrmStkStokKarti = class(TfrmBaseInputDB)
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
    lblurun_tipi_id: TLabel;
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
    edturun_tipi_id: TEdit;
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
    lblgrup_ihracat: TLabel;
    lblgrup_ihracat_val: TLabel;
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
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.StkStokKarti, ufrmStkStokKartlari,
  Ths.Erp.Database.Table.SysOlcuBirimi, ufrmSysOlcuBirimleri,
  Ths.Erp.Database.Table.StkStokGrubu, ufrmStkStokGruplari,
  Ths.Erp.Database.Table.SetStkUrunTipi, ufrmSetStkUrunTipleri,
  Ths.Erp.Database.Table.SysParaBirimi, ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.StkCinsOzelligi, ufrmStkCinsOzellikleri,
  Ths.Erp.Database.Table.SysUlke, ufrmSysUlkeler;

{$R *.dfm}

procedure TfrmStkStokKarti.btnstok_resimClick(Sender: TObject);
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
        CreateExceptionByLang('Dosya botutu 500 KB üzerinde olamaz', '999999');
      imgstok_resim.Picture.LoadFromFile(LFileName);
    end;
  end;
end;

procedure TfrmStkStokKarti.edtcins_idChange(Sender: TObject);
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

  if StrToIntDef(VarToStr(FormatedVariantVal(TStkStokKarti(Table).CinsID)), 0) > 0 then
  begin
    LCins := TStkCinsOzelligi.Create(Table.Database);
    try
      LCins.SelectToList(' AND ' + LCins.TableName + '.' + LCins.Id.FieldName + '=' + IntToStr(TStkStokKarti(Table).CinsID.Value), False, False);
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

procedure TfrmStkStokKarti.edtenChange(Sender: TObject);
begin
  lblvalue_hacim.Caption :=
    FormatFloat('0.0000',
      (StrToFloatDef(edten.Text, 0) *
       StrToFloatDef(edtboy.Text, 0) *
       StrToFloatDef(edtyukseklik.Text, 0)) / 1000000
    );
end;

procedure TfrmStkStokKarti.FormCreate(Sender: TObject);
begin
  inherited;

  lblortalama_maliyet_brm.Caption := GDataBase.getVarsayilanParaBirimi;

  dm.il16.GetBitmap(IMG_IMAGE, btnstok_resim.Glyph);
end;

procedure TfrmStkStokKarti.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmStkStokKarti.FormShow(Sender: TObject);
begin
  edtstok_grubu_id.OnHelperProcess := HelperProcess;
  edtolcu_birimi_id.OnHelperProcess := HelperProcess;
  edturun_tipi_id.OnHelperProcess := HelperProcess;
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
      lblgrup_ihracat_val.Caption := '';
      lblgrup_alis_kodu_val.Caption := '';
      lblgrup_satis_iade_kodu_val.Caption := '';
      lblgrup_satis_kodu_val.Caption := '';
      lblgrup_alis_iade_kodu_val.Caption := '';
    end;
  end;
end;

procedure TfrmStkStokKarti.HelperProcess(Sender: TObject);
var
  LFrmGrup: TfrmStkStokGruplari;
  LFrmOlcuBirimi: TfrmSysOlcuBirimleri;
  LFrmUrunTipi: TfrmSetStkUrunTipleri;
  LFrmCins: TfrmStkCinsOzellikleri;
  LFrmUlke: TfrmSysUlkeler;
  LFrmPara: TfrmSysParaBirimleri;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtstok_grubu_id.Name then
      begin
        LFrmGrup := TfrmStkStokGruplari.Create(TEdit(Sender), Self, TStkStokGrubu.Create(Table.Database), fomNormal, True);
        try
          LFrmGrup.ShowModal;
          if LFrmGrup.DataAktar then
          begin
            if LFrmGrup.CleanAndClose then
            begin
              TEdit(Sender).Clear;
            end else begin
              TEdit(Sender).Text := FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).StokGrubu);
              TStkStokKarti(Table).StokGrubuID.Value := LFrmGrup.Table.Id.Value;

              lblgrup_satis_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).SatisKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).SatisAdi));
              lblgrup_satis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).SatisIadeKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).SatisIadeAdi));
              lblgrup_alis_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).AlisKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).AlisAdi));
              lblgrup_alis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).AlisIadeKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).AlisIadeAdi));
              lblgrup_ihracat_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).IhracatKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).IhracatAdi));
              lblgrup_hammadde_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).HammaddeKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).HammaddeAdi));
              lblgrup_mamul_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).MamulKodu)) + ' ' + VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).MamulAdi));
              lblgrup_kdv_orani_val.Caption := VarToStr(FormatedVariantVal(TStkStokGrubu(LFrmGrup.Table).KDVOrani));
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
              TEdit(Sender).Text := FormatedVariantVal(TSysOlcuBirimi(LFrmOlcuBirimi.Table).OlcuBirimi);
              TStkStokKarti(Table).OlcuBirimiID.Value := LFrmOlcuBirimi.Table.Id.Value;
            end;
          end;
        finally
          LFrmOlcuBirimi.Free;
        end;
      end
      else if TEdit(Sender).Name = edturun_tipi_id.Name then
      begin
        LFrmUrunTipi := TfrmSetStkUrunTipleri.Create(TEdit(Sender), Self, TSetStkUrunTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmUrunTipi.ShowModal;
          if LFrmUrunTipi.DataAktar then
          begin
            if LFrmUrunTipi.CleanAndClose then
            begin
              TEdit(Sender).Clear;
            end else begin
              TEdit(Sender).Text := FormatedVariantVal(TSetStkUrunTipi(LFrmUrunTipi.Table).UrunTipi);
              TStkStokKarti(Table).UrunTipiID.Value := LFrmUrunTipi.Table.Id.Value;
            end;
          end;
        finally
          LFrmUrunTipi.Free;
        end;
      end
      else if TEdit(Sender).Name = edtcins_id.Name then
      begin
        LFrmCins := TfrmStkCinsOzellikleri.Create(TEdit(Sender), Self, TStkCinsOzelligi.Create(Table.Database), fomNormal, True);
        try
          LFrmCins.ShowModal;
          if LFrmCins.DataAktar then
          begin
            if LFrmCins.CleanAndClose then
            begin
              edtcins_id.Clear;
              TStkStokKarti(Table).CinsID.Value := 0;
            end else begin
              edtcins_id.Text := FormatedVariantVal(TStkCinsOzelligi(LFrmCins.Table).Cins);
              TStkStokKarti(Table).CinsID.Value := LFrmCins.Table.Id.Value;
            end;
            edtcins_idChange(edtcins_id);
          end;
        finally
          LFrmCins.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmensei_id.Name then
      begin
        LFrmUlke := TfrmSysUlkeler.Create(TEdit(Sender), Self, TSysUlke.Create(Table.Database), fomNormal, True);
        try
          LFrmUlke.ShowModal;
          if LFrmUlke.DataAktar then
          begin
            if LFrmUlke.CleanAndClose then
            begin
              edtmensei_id.Clear;
            end else begin
              edtmensei_id.Text := FormatedVariantVal(TSysUlke(LFrmUlke.Table).UlkeAdi);
              TStkStokKarti(Table).MenseiID.Value := LFrmUlke.Table.Id.Value;
            end;
          end;
        finally
          LFrmUlke.Free;
        end;
      end
      else
      if (TEdit(Sender).Name = edtalis_para.Name)
      or (TEdit(Sender).Name = edtsatis_para.Name)
      or (TEdit(Sender).Name = edtihrac_para.Name)
      then
      begin
        LFrmPara := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, TSysParaBirimi.Create(GDataBase), fomNormal, True);
        try
          LFrmPara.ShowModal;
          if LFrmPara.DataAktar then
          begin
            if LFrmPara.CleanAndClose
            then  TEdit(Sender).Clear
            else  TEdit(Sender).Text := FormatedVariantVal(TSysParaBirimi(LFrmPara.Table).ParaBirimi);
          end;
        finally
          LFrmPara.Free;
        end;
      end
    end;
  end
end;

procedure TfrmStkStokKarti.pgcMainChange(Sender: TObject);
var
  LGrup: TStkStokGrubu;
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
      LGrup := TStkStokGrubu.Create(Table.Database);
      try
        LGrup.SelectToList(' AND ' + LGrup.TableName + '.' + LGrup.StokGrubu.FieldName + '=' + QuotedStr(edtstok_grubu_id.Text), False, False);
        if LGrup.List.Count = 1 then
        begin
          lblgrup_satis_kodu_val.Caption := VarToStr(FormatedVariantVal(LGrup.SatisKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.SatisAdi));
          lblgrup_satis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(LGrup.SatisIadeKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.SatisIadeAdi));
          lblgrup_alis_kodu_val.Caption := VarToStr(FormatedVariantVal(LGrup.AlisKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.AlisAdi));
          lblgrup_alis_iade_kodu_val.Caption := VarToStr(FormatedVariantVal(LGrup.AlisIadeKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.AlisIadeAdi));
          lblgrup_ihracat_val.Caption := VarToStr(FormatedVariantVal(LGrup.IhracatKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.IhracatAdi));
          lblgrup_hammadde_val.Caption := VarToStr(FormatedVariantVal(LGrup.HammaddeKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.HammaddeAdi));
          lblgrup_mamul_val.Caption := VarToStr(FormatedVariantVal(LGrup.MamulKodu)) + ' ' + VarToStr(FormatedVariantVal(LGrup.MamulAdi));
          lblgrup_kdv_orani_val.Caption := VarToStr(FormatedVariantVal(LGrup.KDVOrani));
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

procedure TfrmStkStokKarti.RefreshData();
begin
  chkis_satilabilir.Checked := FormatedVariantVal(TStkStokKarti(Table).IsSatilabilir);
  edtstok_kodu.Text := FormatedVariantVal(TStkStokKarti(Table).StokKodu);
  edtstok_adi.Text := FormatedVariantVal(TStkStokKarti(Table).StokAdi);
  edtstok_grubu_id.Text := VarToStr(FormatedVariantVal(TStkStokKarti(Table).StokGrubu));
  edtolcu_birimi_id.Text := VarToStr(FormatedVariantVal(TStkStokKarti(Table).OlcuBirimi));
  edturun_tipi_id.Text := VarToStr(FormatedVariantVal(TStkStokKarti(Table).UrunTipi));
  edtalis_iskonto.Text := FormatedVariantVal(TStkStokKarti(Table).AlisIskonto);
  edtsatis_iskonto.Text := FormatedVariantVal(TStkStokKarti(Table).SatisIskonto);
  edtalis_fiyat.Text := FormatedVariantVal(TStkStokKarti(Table).AlisFiyat);
  edtalis_para.Text := FormatedVariantVal(TStkStokKarti(Table).AlisPara);
  edtsatis_fiyat.Text := FormatedVariantVal(TStkStokKarti(Table).SatisFiyat);
  edtsatis_para.Text := FormatedVariantVal(TStkStokKarti(Table).SatisPara);
  edtihrac_fiyat.Text := FormatedVariantVal(TStkStokKarti(Table).IhracFiyat);
  edtihrac_para.Text := FormatedVariantVal(TStkStokKarti(Table).IhracPara);
  edtEn.Text := FormatedVariantVal(TStkStokKarti(Table).En);
  edtBoy.Text := FormatedVariantVal(TStkStokKarti(Table).Boy);
  edtYukseklik.Text := FormatedVariantVal(TStkStokKarti(Table).Yukseklik);
  edtagirlik.Text := FormatedVariantVal(TStkStokKarti(Table).Agirlik);
  edttemin_suresi.Text := FormatedVariantVal(TStkStokKarti(Table).TeminSuresi);
  edtozel_kod.Text := FormatedVariantVal(TStkStokKarti(Table).OzelKod);
  edtmarka.Text := FormatedVariantVal(TStkStokKarti(Table).Marka);
  edtmensei_id.Text := FormatedVariantVal(TStkStokKarti(Table).Mensei);
  edtgtip_no.Text := FormatedVariantVal(TStkStokKarti(Table).GtipNo);
  edtdiib_urun_tanimi.Text := FormatedVariantVal(TStkStokKarti(Table).DiibUrunTanimi);
  edten_az_stok_seviyesi.Text := FormatedVariantVal(TStkStokKarti(Table).EnAzStokSeviyesi);
  mmotanim.Text := FormatedVariantVal(TStkStokKarti(Table).Tanim);
  LoadImageFromDB(TStkStokKarti(Table).StokResim, imgstok_resim);
  edtcins_id.Text := FormatedVariantVal(TStkStokKarti(Table).Cins);
  edtcins_idChange(edtcins_id);
  edts1.Text := FormatedVariantVal(TStkStokKarti(Table).S1);
  edts2.Text := FormatedVariantVal(TStkStokKarti(Table).S2);
  edts3.Text := FormatedVariantVal(TStkStokKarti(Table).S3);
  edts4.Text := FormatedVariantVal(TStkStokKarti(Table).S4);
  edts5.Text := FormatedVariantVal(TStkStokKarti(Table).S5);
  edts6.Text := FormatedVariantVal(TStkStokKarti(Table).S6);
  edts7.Text := FormatedVariantVal(TStkStokKarti(Table).S7);
  edts8.Text := FormatedVariantVal(TStkStokKarti(Table).S8);
  edti1.Text := FormatedVariantVal(TStkStokKarti(Table).I1);
  edti2.Text := FormatedVariantVal(TStkStokKarti(Table).I2);
  edti3.Text := FormatedVariantVal(TStkStokKarti(Table).I3);
  edti4.Text := FormatedVariantVal(TStkStokKarti(Table).I4);
  edtd1.Text := FormatedVariantVal(TStkStokKarti(Table).D1);
  edtd2.Text := FormatedVariantVal(TStkStokKarti(Table).D2);
  edtd3.Text := FormatedVariantVal(TStkStokKarti(Table).D3);
  edtd4.Text := FormatedVariantVal(TStkStokKarti(Table).D4);
end;

procedure TfrmStkStokKarti.Repaint;
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

procedure TfrmStkStokKarti.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkStokKarti(Table).IsSatilabilir.Value := chkis_satilabilir.Checked;
      TStkStokKarti(Table).StokKodu.Value := edtstok_kodu.Text;
      TStkStokKarti(Table).StokAdi.Value := edtstok_adi.Text;
      TStkStokKarti(Table).StokGrubu.Value := edtstok_grubu_id.Text;
      TStkStokKarti(Table).OlcuBirimi.Value := edtolcu_birimi_id.Text;
      TStkStokKarti(Table).UrunTipi.Value := edturun_tipi_id.Text;
      TStkStokKarti(Table).AlisIskonto.Value := StrToFloatDef(edtalis_iskonto.Text, 0);
      TStkStokKarti(Table).SatisIskonto.Value := StrToFloatDef(edtsatis_iskonto.Text, 0);
      TStkStokKarti(Table).AlisFiyat.Value := edtalis_fiyat.moneyToDouble;
      TStkStokKarti(Table).AlisPara.Value := edtalis_para.Text;
      TStkStokKarti(Table).SatisFiyat.Value := edtsatis_fiyat.moneyToDouble;
      TStkStokKarti(Table).SatisPara.Value := edtsatis_para.Text;
      TStkStokKarti(Table).IhracFiyat.Value := edtihrac_fiyat.moneyToDouble;
      TStkStokKarti(Table).IhracPara.Value := edtihrac_para.Text;
      TStkStokKarti(Table).En.Value := StrToFloatDef(edten.Text, 0);
      TStkStokKarti(Table).Boy.Value := StrToFloatDef(edtboy.Text, 0);
      TStkStokKarti(Table).Yukseklik.Value := StrToFloatDef(edtyukseklik.Text, 0);
      TStkStokKarti(Table).Agirlik.Value := StrToFloatDef(edtagirlik.Text, 0);
      TStkStokKarti(Table).TeminSuresi.Value := StrToFloatDef(edttemin_suresi.Text, 0);
      TStkStokKarti(Table).OzelKod.Value := edtozel_kod.Text;
      TStkStokKarti(Table).Marka.Value := edtmarka.Text;
      TStkStokKarti(Table).Mensei.Value := edtmensei_id.Text;
      TStkStokKarti(Table).GtipNo.Value := edtgtip_no.Text;
      TStkStokKarti(Table).DiibUrunTanimi.Value := edtdiib_urun_tanimi.Text;
      TStkStokKarti(Table).EnAzStokSeviyesi.Value := StrToFloatDef(edten_az_stok_seviyesi.Text, 0);
      TStkStokKarti(Table).Tanim.Value := mmotanim.Text;
      setValueFromImage(TStkStokKarti(Table).StokResim, imgstok_resim);
      TStkStokKarti(Table).Cins.Value := edtcins_id.Text;
      TStkStokKarti(Table).S1.Value := edts1.Text;
      TStkStokKarti(Table).S2.Value := edts2.Text;
      TStkStokKarti(Table).S3.Value := edts3.Text;
      TStkStokKarti(Table).S4.Value := edts4.Text;
      TStkStokKarti(Table).S5.Value := edts5.Text;
      TStkStokKarti(Table).S6.Value := edts6.Text;
      TStkStokKarti(Table).S7.Value := edts7.Text;
      TStkStokKarti(Table).S8.Value := edts8.Text;
      TStkStokKarti(Table).I1.Value := StrToIntDef(edti1.Text, 0);
      TStkStokKarti(Table).I2.Value := StrToIntDef(edti2.Text, 0);
      TStkStokKarti(Table).I3.Value := StrToIntDef(edti3.Text, 0);
      TStkStokKarti(Table).I4.Value := StrToIntDef(edti4.Text, 0);
      TStkStokKarti(Table).D1.Value := StrToFloatDef(edtd1.Text, 0);
      TStkStokKarti(Table).D2.Value := StrToFloatDef(edtd2.Text, 0);
      TStkStokKarti(Table).D3.Value := StrToFloatDef(edtd3.Text, 0);
      TStkStokKarti(Table).D4.Value := StrToFloatDef(edtd4.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

end.
