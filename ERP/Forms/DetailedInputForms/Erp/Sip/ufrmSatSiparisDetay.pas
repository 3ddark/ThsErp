unit ufrmSatSiparisDetay;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.DateUtils,
  System.NetEncoding,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Buttons,
  Vcl.AppEvnts,
  Vcl.Samples.Spin,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage,
  FireDAC.Comp.Client,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Erp.Database.Table;

type
  TfrmSatSiparisDetay = class(TfrmBaseDetaylarDetay)
    lblstok_kodu: TLabel;
    lblstok_aciklama: TLabel;
    lblkullanici_aciklama: TLabel;
    lblfiyat: TLabel;
    lbliskonto_orani: TLabel;
    lblkdv_orani: TLabel;
    lblmiktar: TLabel;
    lblolcu_birimi: TLabel;
    lblgtip_no: TLabel;
    edtstok_kodu: TEdit;
    edtstok_aciklama: TEdit;
    edtfiyat: TEdit;
    edtmiktar: TEdit;
    edtiskonto_orani: TEdit;
    edtgtip_no: TEdit;
    edtkullanici_aciklama: TEdit;
    PanelBilgilendirme: TPanel;
    lbltutar: TLabel;
    lbltutar_val: TLabel;
    lbltutar_brm: TLabel;
    lbliskonto_tutar: TLabel;
    lbliskonto_tutar_val: TLabel;
    lbliskonto_tutar_brm: TLabel;
    lblkdv_tutar: TLabel;
    lblkdv_tutar_val: TLabel;
    lblkdv_tutar_brm: TLabel;
    lbltoplam_tutar: TLabel;
    lbltoplam_tutar_val: TLabel;
    lbltoplam_tutar_brm: TLabel;
    lblnet_fiyat: TLabel;
    lblnet_fiyat_val: TLabel;
    lblnet_fiyat_brm: TLabel;
    lblnet_tutar: TLabel;
    lblnet_tutar_val: TLabel;
    lblnet_tutar_brm: TLabel;
    imgstok_resim: TImage;
    lblnet_agirlik_brm: TLabel;
    lblnet_agirlik: TLabel;
    lblhacim_brm: TLabel;
    lblyukseklik_brm: TLabel;
    lblboy_brm: TLabel;
    lblen_brm: TLabel;
    lblhacim_val: TLabel;
    lblhacim: TLabel;
    lblen: TLabel;
    lblboy: TLabel;
    lblyukseklik: TLabel;
    lblbrut_agirlik_brm: TLabel;
    lblbrut_agirlik: TLabel;
    lblkab_brm: TLabel;
    lblkab: TLabel;
    edtolcu_birimi: TEdit;
    edtkdv_orani: TEdit;
    edten: TEdit;
    edtboy: TEdit;
    edtyukseklik: TEdit;
    edtnet_agirlik: TEdit;
    edtbrut_agirlik: TEdit;
    edtkab: TEdit;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormShow(Sender: TObject); override;
    procedure edtenChange(Sender: TObject);
    procedure edtboyChange(Sender: TObject);
    procedure edtyukseklikChange(Sender: TObject);
    procedure edtfiyatChange(Sender: TObject);
    procedure edtfiyatExit(Sender: TObject);
    procedure edtmiktarChange(Sender: TObject);
    procedure edtmiktarExit(Sender: TObject);
    procedure edtiskonto_oraniChange(Sender: TObject);
    procedure edtiskonto_oraniExit(Sender: TObject);
    procedure edtkdv_oraniChange(Sender: TObject);
    procedure edtkdv_oraniExit(Sender: TObject);
  private
    FNetFiyat,
    FTutar,
    FNetTutar,
    FIskontoTutar,
    FKDVTutar,
    FToplamTutar: Double;

    procedure CalculateTotals();
    procedure CalculateHacim();
  public
    procedure ClearTotalLabels;
    procedure ClearHacimLabels;
  published
    procedure HelperProcess(Sender: TObject);
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SatSiparis, ufrmSatSiparisDetaylar,
  Ths.Erp.Database.Table.SysOlcuBirimi, ufrmSysOlcuBirimleri,
  Ths.Erp.Database.Table.SysParaBirimi, ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.SetChVergiOrani, ufrmSetChVergiOranlari,
  Ths.Erp.Database.Table.StkStokKarti, ufrmStkStokKartlari;

{$R *.dfm}

procedure TfrmSatSiparisDetay.CalculateHacim;
var
  LHacim, LEn, LBoy, LYukseklik: Double;
begin
  if (edten.Text <> '') and (edtboy.Text <> '') and (edtboy.Text <> '') then
  begin
    LEn := StrToFloatDef(edten.Text, 0);
    LBoy := StrToFloatDef(edtboy.Text, 0);
    LYukseklik := StrToFloatDef(edtyukseklik.Text, 0);
    //en boy yükseklik mm birimleri olduğu için m3 bulmak için
    //1 000 000 000 sayısına bölüyoruz.
    LHacim := RoundTo( (LEn * LBoy * LYukseklik) / 1000000000, -4);

    lblhacim_val.Caption := FloatToStrF(LHacim, TFloatFormat.ffFixed, 8, 4);
  end;
end;

procedure TfrmSatSiparisDetay.CalculateTotals();
var
  vFiyat, vMiktar, vIskontoOrani, vKDVOrani: Double;
begin
  vFiyat := 0;
  vMiktar := 0;
  vIskontoOrani := 0;
  vKDVOrani := 0;

  if edtFiyat.Text <> '' then
    vFiyat := edtFiyat.moneyToDouble;

  if edtMiktar.Text <> '' then
    vMiktar := edtMiktar.moneyToDouble;

  if edtiskonto_orani.Text <> '' then
    vIskontoOrani  := StrToFloatDef(edtiskonto_orani.Text, 0);

  if edtkdv_orani.Text <> '' then
    vKDVOrani := StrToFloatDef(edtkdv_orani.Text, 0);

  if ((edtFiyat.Text <> '') and (edtMiktar.Text <> '') ) then
  begin
    FTutar := vFiyat * vMiktar;
    FNetFiyat := vFiyat * ((100-vIskontoOrani)/100);
    FNetTutar := FNetFiyat * vMiktar;
    FIskontoTutar := FTutar - FNetTutar;
    FKDVTutar := FNetTutar * (vKDVOrani)/100;
    FToplamTutar := FNetTutar + FKDVTutar;

    lblnet_fiyat_val.Caption := FloatToStrF(FNetFiyat, TFloatFormat.ffFixed, 7, GSysOndalikHane.SatisMiktar.Value);
    lbltutar_val.Caption := FloatToStrF(FTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.SatisMiktar.Value);
    lbliskonto_tutar_val.Caption := FloatToStrF(FIskontoTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.SatisMiktar.Value);
    lblnet_tutar_val.Caption := FloatToStrF(FNetTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.SatisMiktar.Value);
    lblkdv_tutar_val.Caption := FloatToStrF(FKDVTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.SatisMiktar.Value);
    lbltoplam_tutar_val.Caption := FloatToStrF(FToplamTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.SatisMiktar.Value);
  end;
end;

procedure TfrmSatSiparisDetay.ClearHacimLabels;
begin
  lblhacim_val.Caption := '0.00';
end;

procedure TfrmSatSiparisDetay.ClearTotalLabels;
var
  n1: Integer;
  LMoneySign: WideString;
begin
  lblnet_fiyat_val.Caption := '0.00';
  lbltutar_val.Caption := '0.00';
  lbliskonto_tutar_val.Caption := '0.00';
  lblnet_tutar_val.Caption := '0.00';
  lblkdv_tutar_val.Caption := '0.00';
  lbltoplam_tutar_val.Caption := '0.00';

  LMoneySign := '';
  for n1 := 0 to GParaBirimi.List.Count-1 do
    if TfrmSatSiparisDetaylar(ParentForm).edtpara_birimi.Text = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.AsString then
    begin
      LMoneySign := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;
      Break;
    end;

  lblnet_fiyat_brm.Caption := LMoneySign;
  lbltutar_brm.Caption := LMoneySign;
  lbliskonto_tutar_brm.Caption := LMoneySign;
  lblnet_tutar_brm.Caption := LMoneySign;
  lblkdv_tutar_brm.Caption := LMoneySign;
  lbltoplam_tutar_brm.Caption := LMoneySign;
end;

procedure TfrmSatSiparisDetay.edtboyChange(Sender: TObject);
begin
  CalculateHacim;
end;

procedure TfrmSatSiparisDetay.edtenChange(Sender: TObject);
begin
  CalculateHacim;
end;

procedure TfrmSatSiparisDetay.edtfiyatChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtfiyatExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtiskonto_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtiskonto_oraniExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtkdv_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtkdv_oraniExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtmiktarChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtmiktarExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtyukseklikChange(Sender: TObject);
begin
  CalculateHacim;
end;

procedure TfrmSatSiparisDetay.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;
  edtkdv_orani.OnHelperProcess := HelperProcess;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    ClearTotalLabels;
    ClearHacimLabels;
    edtkdv_orani.Text := '18';
  end;
end;

procedure TfrmSatSiparisDetay.HelperProcess(Sender: TObject);
var
  LFrmStk: TfrmStkStokKartlari;
  LStk: TStkStokKarti;
  LFrmVergi: TfrmSetChVergiOranlari;
  LKur: Double;
  n1: Integer;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LStk := TStkStokKarti.Create(GDataBase);
        LFrmStk := TfrmStkStokKartlari.Create(edtstok_kodu, Self, LStk, fomNormal, True);
        try
          LFrmStk.QryFiltreVarsayilan := ' AND ' + LStk.IsSatilabilir.FieldName + '=True';
          LFrmStk.ShowModal;

          if LFrmStk.DataAktar then
          begin
            if LFrmStk.CleanAndClose then
            begin
              edtstok_kodu.Clear;
              edtstok_aciklama.Clear;
              edtfiyat.Clear;
              edtolcu_birimi.Clear;
              edtiskonto_orani.Clear;
              imgstok_resim.Picture.Assign(nil);
              edtgtip_no.Clear;
            end
            else
            begin
              edtstok_kodu.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).StokKodu);
              edtstok_aciklama.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).StokAdi);

              for n1 := 0 to GParaBirimi.List.Count-1 do
                if TfrmSatSiparisDetaylar(ParentForm).edtpara_birimi.Text = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.AsString then
                begin
                  if TSysParaBirimi(GParaBirimi.List[n1]).IsVarsayilan.AsBoolean then
                    LKur := 1
                  else
                    LKur := TfrmSatSiparisDetaylar(ParentForm).edtdoviz_kuru.moneyToDouble;
                  edtfiyat.Text := FloatToStr(TStkStokKarti(LFrmStk.Table).SatisFiyat.AsFloat * LKur);
                  break;
                end;
              edtolcu_birimi.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).OlcuBirimi);

              if (Trim(edtiskonto_orani.Text) = '') then  edtiskonto_orani.Text := '0';

              TSatSiparisDetay(Table).StokResim.Value := TStkStokKarti(LFrmStk.Table).StokResim.Value;
              LoadImageFromDB(TStkStokKarti(LFrmStk.Table).StokResim, imgstok_resim);
              edtgtip_no.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).GtipNo);

              edten.Text := TStkStokKarti(LFrmStk.Table).En.Value;
              edtboy.Text := TStkStokKarti(LFrmStk.Table).Boy.Value;
              edtyukseklik.Text := TStkStokKarti(LFrmStk.Table).Yukseklik.Value;
              edtnet_agirlik.Text := TStkStokKarti(LFrmStk.Table).Agirlik.Value;
              edtbrut_agirlik.Text := TStkStokKarti(LFrmStk.Table).Agirlik.Value;
            end;
          end;
        finally
          LFrmStk.Free;
        end;
      end
      else if TEdit(Sender).Name = edtkdv_orani.Name then
      begin
        LFrmVergi := TfrmSetChVergiOranlari.Create(edtstok_kodu, Self, TSetChVergiOrani.Create(Table.Database), fomNormal, True);
        try
          LFrmVergi.ShowModal;
          if LFrmVergi.DataAktar then
          begin
            if LFrmVergi.CleanAndClose
            then  TEdit(Sender).Clear
            else  TEdit(Sender).Text := FormatedVariantVal(TSetChVergiOrani(LFrmVergi.Table).VergiOrani);
          end;
        finally
          LFrmVergi.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSatSiparisDetay.RefreshData();
begin
  edtstok_kodu.Text := TSatSiparisDetay(Table).StokKodu.AsString;
  edtstok_aciklama.Text := TSatSiparisDetay(Table).StokAciklama.AsString;
  edtfiyat.Text := TSatSiparisDetay(Table).Fiyat.AsString;
  edtmiktar.Text := TSatSiparisDetay(Table).Miktar.AsString;
  edtolcu_birimi.Text := TSatSiparisDetay(Table).OlcuBirimi.AsString;
  edtiskonto_orani.Text := TSatSiparisDetay(Table).IskontoOrani.AsString;
  edtkdv_orani.Text := TSatSiparisDetay(Table).KdvOrani.AsString;
  edtgtip_no.Text := TSatSiparisDetay(Table).GtipNo.AsString;
  edtkullanici_aciklama.Text := TSatSiparisDetay(Table).KullaniciAciklama.AsString;

  CalculateTotals;

  edten.Text := TSatSiparisDetay(Table).En.AsString;
  edtboy.Text := TSatSiparisDetay(Table).Boy.AsString;
  edtyukseklik.Text := TSatSiparisDetay(Table).Yukseklik.AsString;
  lblhacim_val.Caption := TSatSiparisDetay(Table).Hacim.AsString;

  CalculateHacim;

  edtnet_agirlik.Text := TSatSiparisDetay(Table).NetAgirlik.AsString;
  edtbrut_agirlik.Text := TSatSiparisDetay(Table).BrutAgirlik.AsString;
  edtkab.Text := TSatSiparisDetay(Table).Kab.AsString;

  if Length(FormatedVariantVal(TSatSiparisDetay(Table).StokResim)) > 10 then
    LoadImageFromDB(TSatSiparisDetay(Table).StokResim, imgstok_resim);
end;

procedure TfrmSatSiparisDetay.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSatSiparisDetay(Table).TeklifDetayID.Value := 0;
      TSatSiparisDetay(Table).IrsaliyeDetayID.Value := 0;
      TSatSiparisDetay(Table).FaturaDetayID.Value := 0;

      TSatSiparisDetay(Table).StokKodu.Value := edtstok_kodu.Text;
      TSatSiparisDetay(Table).StokAciklama.Value := edtstok_aciklama.Text;
      TSatSiparisDetay(Table).KullaniciAciklama.Value := edtkullanici_aciklama.Text;
      TSatSiparisDetay(Table).Referans.Value := '';
      TSatSiparisDetay(Table).Miktar.Value := edtMiktar.Text;
      TSatSiparisDetay(Table).OlcuBirimi.Value := edtolcu_birimi.Text;

      TSatSiparisDetay(Table).IskontoOrani.Value := edtiskonto_orani.Text;
      TSatSiparisDetay(Table).KdvOrani.Value := edtkdv_orani.Text;
      TSatSiparisDetay(Table).Fiyat.Value := edtFiyat.moneyToDouble;
      TSatSiparisDetay(Table).NetFiyat.Value := FNetFiyat;
      TSatSiparisDetay(Table).Tutar.Value := FTutar;
      TSatSiparisDetay(Table).IskontoTutar.Value := FIskontoTutar;
      TSatSiparisDetay(Table).NetTutar.Value := FNetTutar;
      TSatSiparisDetay(Table).KdvTutar.Value := FKDVTutar;
      TSatSiparisDetay(Table).ToplamTutar.Value := FToplamTutar;

      TSatSiparisDetay(Table).IsAnaUrun.Value := False;
      TSatSiparisDetay(Table).AnaUrunID.Value := 0;
      TSatSiparisDetay(Table).ReferansAnaUrunID.Value := 0;

      TSatSiparisDetay(Table).VergiKodu.Value := '';
      TSatSiparisDetay(Table).VergiMuafiyetKodu.Value := '';
      TSatSiparisDetay(Table).DigerVergiKodu.Value := '';
      TSatSiparisDetay(Table).GtipNo.Value := edtgtip_no.Text;

      TSatSiparisDetay(Table).En.Value := StrToFloatDef(edten.Text, 0);
      TSatSiparisDetay(Table).Boy.Value := StrToFloatDef(edtboy.Text, 0);
      TSatSiparisDetay(Table).Yukseklik.Value := StrToFloatDef(edtyukseklik.Text, 0);
      TSatSiparisDetay(Table).Hacim.Value := StrToFloatDef(lblhacim_val.Caption, 0);

      TSatSiparisDetay(Table).NetAgirlik.Value := StrToFloatDef(edtnet_agirlik.Text, 0);
      TSatSiparisDetay(Table).BrutAgirlik.Value := StrToFloatDef(edtbrut_agirlik.Text, 0);

      TSatSiparisDetay(Table).Kab.Value := StrToIntDef(edtkab.Text, 0);

      (TfrmSatSiparisDetaylar(ParentForm).Table as TSatSiparis).ValidateDetay(TSatSiparisDetay(Table));

      inherited;
    end;
  end
  else
    inherited;
end;

end.
