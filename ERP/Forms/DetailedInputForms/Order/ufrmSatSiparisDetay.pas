unit ufrmSatSiparisDetay;

interface

{$I Ths.inc}

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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,
  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Database.Table,
  Ths.Globals;

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
    FTotal: TTotal;

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
  Ths.Constants,
  Ths.Database.Table.SatSiparis, ufrmSatSiparisDetaylar,
  Ths.Database.Table.SysOlcuBirimleri, ufrmSysOlcuBirimleri,
  Ths.Database.Table.SysParaBirimleri, ufrmSysParaBirimleri,
  Ths.Database.Table.SetChVergiOrani, ufrmSetChVergiOranlari,
  Ths.Database.Table.StkKartlar, ufrmStkKartlar;

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
  LFiyat, LMiktar, LIskontoOrani, LKDVOrani: Double;
begin
  LFiyat := 0;
  LMiktar := 0;
  LIskontoOrani := 0;
  LKDVOrani := 0;

  if edtFiyat.Text <> '' then
    LFiyat := edtFiyat.moneyToDouble;

  if edtMiktar.Text <> '' then
    LMiktar := edtMiktar.moneyToDouble;

  if edtiskonto_orani.Text <> '' then
    LIskontoOrani  := StrToFloatDef(edtiskonto_orani.Text, 0);

  if edtkdv_orani.Text <> '' then
    LKDVOrani := StrToFloatDef(edtkdv_orani.Text, 0);

  if ((edtFiyat.Text <> '') and (edtMiktar.Text <> '') ) then
  begin
    FTotal := CalculateTotalValues(LFiyat, LMiktar, LIskontoOrani, LKDVOrani);
    lblnet_fiyat_val.Caption := FloatToStrF(FTotal.NetFiyat, TFloatFormat.ffFixed, 7, GSysOndalikHane.Miktar.Value);
    lbltutar_val.Caption := FloatToStrF(FTotal.Tutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.Miktar.Value);
    lbliskonto_tutar_val.Caption := FloatToStrF(FTotal.IskontoTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.Miktar.Value);
    lblnet_tutar_val.Caption := FloatToStrF(FTotal.NetTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.Miktar.Value);
    lblkdv_tutar_val.Caption := FloatToStrF(FTotal.KDVTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.Miktar.Value);
    lbltoplam_tutar_val.Caption := FloatToStrF(FTotal.ToplamTutar, TFloatFormat.ffFixed, 7, GSysOndalikHane.Miktar.Value);
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
    if TfrmSatSiparisDetaylar(ParentForm).edtpara_birimi.Text = TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString then
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
  LFrmStk: TfrmStkKartlar;
  LStk: TStkKart;
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
        LStk := TStkKart.Create(GDataBase);
        LFrmStk := TfrmStkKartlar.Create(edtstok_kodu, Self, LStk, fomNormal, True);
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
              edtstok_kodu.Text := TStkKart(LFrmStk.Table).StokKodu.AsString;
              edtstok_aciklama.Text := TStkKart(LFrmStk.Table).StokAdi.AsString;

              for n1 := 0 to GParaBirimi.List.Count-1 do
                if TfrmSatSiparisDetaylar(ParentForm).edtpara_birimi.Text = TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString then
                begin
                  if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString then
                    LKur := 1
                  else
                    LKur := TfrmSatSiparisDetaylar(ParentForm).edtdoviz_kuru_usd.moneyToDouble;

                  edtfiyat.Text := FloatToStr(TStkKart(LFrmStk.Table).GetSatisFiyatiByDoviz(
                    TfrmSatSiparisDetaylar(ParentForm).edtpara_birimi.Text,
                    LKur,
                    StrToDateDef(TfrmSatSiparisDetaylar(ParentForm).edtsiparis_tarihi.Text, 0)
                  ));
                  Break;
                end;
              edtolcu_birimi.Text := TStkKart(LFrmStk.Table).OlcuBirimi.AsString;

              if (Trim(edtiskonto_orani.Text) = '') then  edtiskonto_orani.Text := '0';

              TSatSiparisDetay(Table).StokResim.Value := TStkKart(LFrmStk.Table).Resim.Value;
              LoadImageFromDB(TStkKart(LFrmStk.Table).Resim, imgstok_resim);
              edtgtip_no.Text := TStkKart(LFrmStk.Table).GtipNo.AsString;

              edten.Text := TStkKart(LFrmStk.Table).En.AsString;
              edtboy.Text := TStkKart(LFrmStk.Table).Boy.AsString;
              edtyukseklik.Text := TStkKart(LFrmStk.Table).Yukseklik.AsString;
              edtnet_agirlik.Text := TStkKart(LFrmStk.Table).Agirlik.AsString;
              edtbrut_agirlik.Text := TStkKart(LFrmStk.Table).Agirlik.AsString;
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
            else  TEdit(Sender).Text := TSetChVergiOrani(LFrmVergi.Table).VergiOrani.AsString;
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

  if Length(TSatSiparisDetay(Table).StokResim.AsString) > 10 then
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
      TSatSiparisDetay(Table).NetFiyat.Value := FTotal.NetFiyat;
      TSatSiparisDetay(Table).Tutar.Value := FTotal.Tutar;
      TSatSiparisDetay(Table).IskontoTutar.Value := FTotal.IskontoTutar;
      TSatSiparisDetay(Table).NetTutar.Value := FTotal.NetTutar;
      TSatSiparisDetay(Table).KdvTutar.Value := FTotal.KDVTutar;
      TSatSiparisDetay(Table).ToplamTutar.Value := FTotal.ToplamTutar;

      TSatSiparisDetay(Table).IsAnaUrun.Value := False;
      TSatSiparisDetay(Table).ReferansAnaUrunID.Value := 0;

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
