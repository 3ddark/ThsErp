unit ufrmSatSiparisDetaylar;

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
  System.Actions,
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
  Vcl.Grids,
  Vcl.ActnList,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  Ths.Helper.StringGrid,
  ufrmBase,
  ufrmBaseDetaylar,
  Ths.Database.Table,
  Ths.Database.Table.SatSiparis,
  Ths.Database.Table.SetSatSiparisDurum;

const
  SS_MAL_KODU            = 1;
  SS_MAL_ADI             = 2;
  SS_MIKTAR              = 3;
  SS_BIRIM               = 4;
  SS_KDV_ORANI           = 5;
  SS_FIYAT               = 6;
  SS_ISKONTO_ORANI       = 7;
  SS_NET_FIYAT           = 8;
  SS_TUTAR               = 9;
  SS_NET_TUTAR           = 10;
  SS_REFERANS            = 11;

type
  TfrmSatSiparisDetaylar = class(TfrmBaseDetaylar)
    lblsiparis_no: TLabel;
    lblsiparis_tarihi: TLabel;
    lblsiparis_durum_id: TLabel;
    cbbsiparis_durum_id: TComboBox;
    edtsiparis_no: TEdit;
    edtsiparis_tarihi: TEdit;
    lblmusteri_kodu: TLabel;
    lblmusteri_adi: TLabel;
    lblvergi_dairesi: TLabel;
    lblvergi_no: TLabel;
    lblpara_birimi: TLabel;
    lblmusteri_temsilcisi_id: TLabel;
    lblteslim_sekli_id: TLabel;
    lblodeme_sekli_id: TLabel;
    lblreferans: TLabel;
    lblmuhattap_ad: TLabel;
    lblteslim_tarihi: TLabel;
    lblkapi_no: TLabel;
    lblposta_kodu: TLabel;
    lblulke_id: TLabel;
    lblsehir_id: TLabel;
    lblilce: TLabel;
    lblmahalle: TLabel;
    lblcadde: TLabel;
    lblsokak: TLabel;
    lblbina_adi: TLabel;
    lblpaket_tipi_id: TLabel;
    lbltasima_ucreti_id: TLabel;
    lblaciklama: TLabel;
    lblproforma_no: TLabel;
    lblmuhattap_telefon: TLabel;
    edtmusteri_kodu: TEdit;
    edtmusteri_adi: TEdit;
    edtvergi_dairesi: TEdit;
    edtvergi_no: TEdit;
    edtulke_id: TEdit;
    edtsehir_id: TEdit;
    edtilce: TEdit;
    edtmahalle: TEdit;
    edtcadde: TEdit;
    edtsokak: TEdit;
    edtbina_adi: TEdit;
    edtkapi_no: TEdit;
    edtposta_kodu: TEdit;
    edtteslim_tarihi: TEdit;
    edtmusteri_temsilcisi_id: TEdit;
    edtmuhattap_ad: TEdit;
    edtreferans: TEdit;
    mmoaciklama: TMemo;
    edtproforma_no: TEdit;
    edtmuhattap_telefon: TEdit;
    edtpaket_tipi_id: TEdit;
    edttasima_ucreti_id: TEdit;
    edtpara_birimi: TEdit;
    edtodeme_sekli_id: TEdit;
    edtteslim_sekli_id: TEdit;
    lbldoviz_kuru_usd: TLabel;
    lbldoviz_kuru_eur: TLabel;
    edtdoviz_kuru_usd: TEdit;
    edtdoviz_kuru_eur: TEdit;
    procedure btnAddDetailClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);override;
    procedure edtpara_birimiChange(Sender: TObject);
    procedure edtdoviz_kuruEnter(Sender: TObject);
    procedure edtdoviz_kuruExit(Sender: TObject);
  private
    FSiparisDurum: TSetSatSiparisDurum;
    FOldDovizKuru: Double;

    procedure FillLabels();
    procedure CalculateNewPrice(const AOldKur, ANewKur: Double);
  public
    function GetDovizKuru(APara: string): Double;
    procedure RefreshData; override;
    function CreateDetailInputForm1(pFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    procedure GridReset(); override;
    procedure GridFill(); override;
    procedure Repaint; override;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  ufrmSatSiparisDetay,
  Ths.Database.Table.ChHesapKarti, ufrmChHesapKartlari,
  Ths.Database.Table.SysSehirler, ufrmSysSehirler,
  Ths.Database.Table.SetEInvFaturaTipleri,
  Ths.Database.Table.PrsPersoneller, ufrmPrsPersoneller,
  Ths.Database.Table.SetSatTeklifDurum,
  Ths.Database.Table.SetOdemeBaslangicDonemi,
  Ths.Database.Table.SysParaBirimleri, ufrmSysParaBirimleri,
  Ths.Database.Table.SetChHesapTipi, ufrmSetChHesapTipleri,
  Ths.Database.Table.SetEinvPaketTipi, ufrmSetEinvPaketTipleri,
  Ths.Database.Table.SetEinvTasimaUcreti, ufrmSetEinvTasimaUcretleri,
  Ths.Database.Table.SetEinvOdemeSekli, ufrmSetEinvOdemeSekilleri,
  Ths.Database.Table.SetEinvTeslimSekli, ufrmSetEinvTeslimSekilleri,
  Ths.Database.Table.ChDovizKurlari;

{$R *.dfm}

procedure TfrmSatSiparisDetaylar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput(pgcHeader)) then
    begin
//      TSatSiparis(Table).TeklifID.Value := 0;
//      TSatSiparis(Table).IrsaliyeID.Value := 0;
//      TSatSiparis(Table).FaturaID.Value := 0;

      TSatSiparis(Table).IslemTipiID.Value := TEinvFaturaTipi.Satis;

      TSatSiparis(Table).MusteriKodu.Value := edtmusteri_kodu.Text;
      TSatSiparis(Table).MusteriAdi.Value := edtmusteri_adi.Text;
      TSatSiparis(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TSatSiparis(Table).VergiNo.Value := edtvergi_no.Text;
      TSatSiparis(Table).Ilce.Value := edtilce.Text;
      TSatSiparis(Table).Mahalle.Value := edtmahalle.Text;
      TSatSiparis(Table).Cadde.Value := edtcadde.Text;
      TSatSiparis(Table).Sokak.Value := edtsokak.Text;
      TSatSiparis(Table).BinaAdi.Value := edtbina_adi.Text;
      TSatSiparis(Table).KapiNo.Value := edtkapi_no.Text;
      TSatSiparis(Table).PostaKodu.Value := edtposta_kodu.Text;
      TSatSiparis(Table).SiparisDurumID.Value := TSetSatSiparisDurum(cbbsiparis_durum_id.Items.Objects[cbbsiparis_durum_id.ItemIndex]).Id.Value;

      TSatSiparis(Table).SiparisNo.Value := edtsiparis_no.Text;
      TSatSiparis(Table).SiparisTarihi.Value := StrToDateDef(edtsiparis_tarihi.Text, 0);
      TSatSiparis(Table).TeslimTarihi.Value := StrToDateDef(edtteslim_tarihi.Text, 0);
      TSatSiparis(Table).ParaBirimi.Value := edtpara_birimi.Text;
      TSatSiparis(Table).DovizKuruUsd.Value := StrToFloatDef(edtdoviz_kuru_usd.Text, 1);
      TSatSiparis(Table).DovizKuruEur.Value := StrToFloatDef(edtdoviz_kuru_eur.Text, 1);

      TSatSiparis(Table).MusteriTemsilcisi.Value := edtmusteri_temsilcisi_id.Text;
      TSatSiparis(Table).MusteriTemsilcisiID.Value := GSysKullanici.PersonelID.Value;
      TSatSiparis(Table).MuhattapAd.Value := edtmuhattap_ad.Text;

      TSatSiparis(Table).PaketTipi.Value := edtpaket_tipi_id.Text;
      TSatSiparis(Table).NakliyeUcreti.Value := edttasima_ucreti_id.Text;
      TSatSiparis(Table).OdemeSekli.Value := edtodeme_sekli_id.Text;
      TSatSiparis(Table).TeslimSekli.Value := edtteslim_sekli_id.Text;

      TSatSiparis(Table).Referans.Value := edtreferans.Text;
      TSatSiparis(Table).Aciklama.Value := mmoaciklama.Text;
      TSatSiparis(Table).ProformaNo.Value := edtproforma_no.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSatSiparisDetaylar.btnAddDetailClick(Sender: TObject);
begin
  inherited;
  CreateDetailInputForm1(ifmNewRecord, strngrd1).Show
end;

procedure TfrmSatSiparisDetaylar.CalculateNewPrice(const AOldKur, ANewKur: Double);
var
  n1: Integer;
  LTotal: TTotal;
begin
  for n1 := 0 to TSatSiparis(Table).ListDetay.Count-1 do
  begin
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).Fiyat.Value := TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).Fiyat.AsFloat * AOldKur / ANewKur;
    LTotal := CalculateTotalValues(
      TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).Fiyat.AsFloat,
      TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).Miktar.AsFloat,
      TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).IskontoOrani.AsFloat,
      TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).KdvOrani.AsFloat
    );
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).Tutar.Value := LTotal.Tutar;
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).NetFiyat.Value := LTotal.NetFiyat;
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).NetTutar.Value := LTotal.NetTutar;
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).IskontoTutar.Value := LTotal.IskontoTutar;
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).KDVTutar.Value := LTotal.KDVTutar;
    TSatSiparisDetay(TSatSiparis(Table).ListDetay[n1]).ToplamTutar.Value := LTotal.ToplamTutar;
  end;

  TSatSiparis(Table).PubRefreshHeader;
end;

function TfrmSatSiparisDetaylar.CreateDetailInputForm1(pFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (pFormMode = ifmNewRecord) or (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSatSiparisDetay.Create(Application, AGrid, Self, TSatSiparisDetay.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmRewiev) or (pFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmSatSiparisDetay.Create(Application, AGrid, Self, TSatSiparisDetay(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd1.Row]), pFormMode);
  end;
end;

procedure TfrmSatSiparisDetaylar.edtdoviz_kuruEnter(Sender: TObject);
var
  LTemp: string;
begin
  if Sender is TEdit then
  begin
    LTemp := TEdit(Sender).Text;
    if (TEdit(Sender).Name = edtdoviz_kuru_usd.Name)
    or (TEdit(Sender).Name = edtdoviz_kuru_eur.Name)
    then
      FOldDovizKuru := TEdit(Sender).moneyToDouble
  end;
end;

procedure TfrmSatSiparisDetaylar.edtdoviz_kuruExit(Sender: TObject);
begin
  if Sender is TEdit then
  begin
    if ((TEdit(Sender).Name = edtdoviz_kuru_usd.Name) and (edtpara_birimi.Text = ParaUSD) and (TEdit(Sender).moneyToDouble <> FOldDovizKuru))
    or ((TEdit(Sender).Name = edtdoviz_kuru_eur.Name) and (edtpara_birimi.Text = ParaEUR) and (TEdit(Sender).moneyToDouble <> FOldDovizKuru))
    then
      CalculateNewPrice(FOldDovizKuru, TEdit(Sender).moneyToDouble);
  end;
end;

procedure TfrmSatSiparisDetaylar.edtpara_birimiChange(Sender: TObject);
begin
  edtdoviz_kuru_usd.Text := GetDovizKuru(ParaUSD).ToString;
  edtdoviz_kuru_eur.Text := GetDovizKuru(ParaEUR).ToString;
end;

function TfrmSatSiparisDetaylar.GetDovizKuru(APara: string): Double;
var
  LKur: TChDovizKuru;
  n1: Integer;
begin
  Result := 1;

  LKur := TChDovizKuru.Create(GDataBase);
  try
    LKur.SelectToList(' AND ' + LKur.KurTarihi.QryName + '=' + QuotedStr(DateToStr(StrToDateDef(edtsiparis_tarihi.Text, GDataBase.DateDB))), False, False);
    for n1 := 0 to LKur.List.Count-1 do
      if TChDovizKuru(LKur.List[n1]).Para.Value = APara then
      begin
        Result := TChDovizKuru(LKur.List[n1]).Kur.AsFloat;
        Break;
      end;
  finally
    LKur.Free;
  end;
end;

procedure TfrmSatSiparisDetaylar.GridFill();
var
  n1: Integer;
  ASip: TSatSiparis;
begin
  strngrd1.Perform(WM_SETREDRAW, 0, 0);
  try
    GridReset();

    if not Assigned(Table) then
      Exit;

    ASip := TSatSiparis(Table);
    if ASip.ListDetay.Count > 0 then
    begin
      strngrd1.RowCount := ASip.ListDetay.Count + strngrd1.FixedRows;

      strngrd1.ColStyleDouble(SS_MIKTAR);
      strngrd1.ColStyleDouble(SS_KDV_ORANI);
      strngrd1.ColStyleDouble(SS_ISKONTO_ORANI);

      strngrd1.ColStyleMoney(SS_FIYAT);
      strngrd1.ColStyleMoney(SS_NET_FIYAT);
      strngrd1.ColStyleMoney(SS_TUTAR);
      strngrd1.ColStyleMoney(SS_NET_TUTAR);

      for n1 := 0 to ASip.ListDetay.Count-1 do
      begin
        if n1 > 0 then
          strngrd1.Row := strngrd1.Row + 1;

        strngrd1.Objects[COLUMN_GRID_OBJECT, strngrd1.Row] := TSatSiparisDetay(ASip.ListDetay[n1]);

        strngrd1.Cells[SS_MAL_KODU, strngrd1.Row] := TSatSiparisDetay(ASip.ListDetay[n1]).StokKodu.Value;
        strngrd1.Cells[SS_MAL_ADI, strngrd1.Row] := TSatSiparisDetay(ASip.ListDetay[n1]).StokAciklama.Value;
        strngrd1.Cells[SS_MIKTAR, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).Miktar.Value, ffFixed, 12, 2);
        strngrd1.Cells[SS_BIRIM, strngrd1.Row] := TSatSiparisDetay(ASip.ListDetay[n1]).OlcuBirimi.Value;
        strngrd1.Cells[SS_KDV_ORANI, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).KdvOrani.Value, ffFixed, 5, 2);
        strngrd1.Cells[SS_FIYAT, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).Fiyat.Value, ffFixed, 12, 2);
        strngrd1.Cells[SS_ISKONTO_ORANI, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).IskontoOrani.Value, ffFixed, 5, 2);
        strngrd1.Cells[SS_NET_FIYAT, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).NetFiyat.Value, ffFixed, 12, 2);
        strngrd1.Cells[SS_TUTAR, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).Tutar.Value, ffFixed, 12, 2);
        strngrd1.Cells[SS_NET_TUTAR, strngrd1.Row] := FloatToStrF(TSatSiparisDetay(ASip.ListDetay[n1]).NetTutar.Value, ffFixed, 12, 2);
        strngrd1.Cells[SS_REFERANS, strngrd1.Row] := TSatSiparisDetay(ASip.ListDetay[n1]).Referans.Value;
      end;
    end;

    FillLabels;
  finally
    strngrd1.Perform(WM_SETREDRAW, 1, 0);
    strngrd1.Invalidate;

    strngrd1.Row := 1;
    strngrd1.Col := 1;
  end;
end;

procedure TfrmSatSiparisDetaylar.FillLabels;
var
  n1: Integer;
  LKDV: Double;
  LFmt: TFormatSettings;
begin
  LKDV := 0;
  LKDV := LKDV + TSatSiparis(Table).KDVTutar1.Value;
  LKDV := LKDV + TSatSiparis(Table).KDVTutar2.Value;
  LKDV := LKDV + TSatSiparis(Table).KDVTutar3.Value;
  LKDV := LKDV + TSatSiparis(Table).KDVTutar4.Value;
  LKDV := LKDV + TSatSiparis(Table).KDVTutar5.Value;

  LFmt := FormatSettings;

  for n1 := 0 to GParaBirimi.List.Count-1 do
    if TSysParaBirimi(GParaBirimi.List[n1]).Para.Value = edtpara_birimi.Text then
      LFmt.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;

  lblValToplamTutar.Caption := FloatToStrF(TSatSiparis(Table).Tutar.Value, ffCurrency, 10, 2, LFmt);
  lblValToplamIskontoTutar.Caption := FloatToStrF(TSatSiparis(Table).IskontoTutar.Value, ffCurrency, 10, 2, LFmt);
  lblValAraToplam.Caption := FloatToStrF(TSatSiparis(Table).AraToplam.Value, ffCurrency, 10, 2, LFmt);
  lblValToplamKDVTutar.Caption := FloatToStrF(LKDV, TFloatFormat.ffCurrency, 10, 2, LFmt);
  lblValGenelToplam.Caption := FloatToStrF(TSatSiparis(Table).GenelToplam.Value, ffCurrency, 10, 2, LFmt);
end;

procedure TfrmSatSiparisDetaylar.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  edtmusteri_kodu.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;
  edtpaket_tipi_id.OnHelperProcess := HelperProcess;
  edttasima_ucreti_id.OnHelperProcess := HelperProcess;
  edtodeme_sekli_id.OnHelperProcess := HelperProcess;
  edtteslim_sekli_id.OnHelperProcess := HelperProcess;
  edtpara_birimi.OnHelperProcess := HelperProcess;

  for n1 := 0 to GParaBirimi.List.Count-1 do
  begin
    if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString then
    begin
      edtpara_birimi.Text :=  TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString;
      Break;
    end;
  end;

  FSiparisDurum := TSetSatSiparisDurum.Create(Table.Database);

  fillComboBoxData(cbbsiparis_durum_id, FSiparisDurum, [FSiparisDurum.SiparisDurum.FieldName], '', True);
  cbbsiparis_durum_id.ItemIndex := 1;

  ts1.Caption := 'Sipariş Detayları';

  GridReset;
end;

procedure TfrmSatSiparisDetaylar.FormDestroy(Sender: TObject);
begin
  FSiparisDurum.Free;
  inherited;
end;

procedure TfrmSatSiparisDetaylar.FormShow(Sender: TObject);
begin
  inherited;
  splHeader.Visible := False;
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    cbbsiparis_durum_id.ItemIndex := 0;  //bekliyor
    cbbsiparis_durum_id.Enabled := False;

    edtmusteri_temsilcisi_id.Text := GSysKullanici.AdSoyad.Value;
    edtsiparis_tarihi.Text := DateToStr(GDataBase.DateDB);
    edtdoviz_kuru_usd.Text := GetDovizKuru(ParaUSD).ToString;
    edtdoviz_kuru_eur.Text := GetDovizKuru(ParaEUR).ToString;
    edtsiparis_no.Text := TSatSiparis(Table).getNewSiparisNo;
  end
  else
    btnHeaderShowHide.Click;

  if  (TSatSiparis(Table).SiparisDurumID.Value <> Ord(TSatSiparisDurum.Beklemede))
  and (TSatSiparis(Table).TeklifID.AsInteger > 0)
  then
    btnAccept.Visible := False;

  grpGenelToplam.Visible := True;

  if (FormMode = ifmNewRecord) then
    FillLabels;

  edtdoviz_kuru_usd.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.Value;
  edtdoviz_kuru_usd.MaxLength := 7;

  edtdoviz_kuru_eur.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.Value;
  edtdoviz_kuru_eur.MaxLength := 7;
end;

procedure TfrmSatSiparisDetaylar.GridReset();
begin
  inherited;
  strngrd1.RowCount := 2;
  strngrd1.ColCount := 11;
  strngrd1.Rows[0].Text := '';
  strngrd1.Rows[1].Text := '';

  GridColWidth(strngrd1, 100, SS_MAL_KODU);
  GridColWidth(strngrd1, 230, SS_MAL_ADI);
  GridColWidth(strngrd1, 50, SS_MIKTAR);
  GridColWidth(strngrd1, 40, SS_BIRIM);
  GridColWidth(strngrd1, 40, SS_KDV_ORANI);
  GridColWidth(strngrd1, 80, SS_FIYAT);
  GridColWidth(strngrd1, 40, SS_ISKONTO_ORANI);
  GridColWidth(strngrd1, 80, SS_NET_FIYAT);
  GridColWidth(strngrd1, 80, SS_TUTAR);
  GridColWidth(strngrd1, 80, SS_NET_TUTAR);

  strngrd1.Cells[SS_MAL_KODU, 0] := 'STOK KODU';
  strngrd1.Cells[SS_MAL_ADI, 0] := 'AÇIKLAMA';
  strngrd1.Cells[SS_MIKTAR, 0] := 'MİKTAR';
  strngrd1.Cells[SS_BIRIM, 0] := 'BİRİM';
  strngrd1.Cells[SS_KDV_ORANI, 0] := 'KDV%';
  strngrd1.Cells[SS_FIYAT, 0] := 'FİYAT';
  strngrd1.Cells[SS_ISKONTO_ORANI, 0] := 'İSK%';
  strngrd1.Cells[SS_NET_FIYAT, 0] := 'NET FİYAT';
  strngrd1.Cells[SS_TUTAR, 0] := 'TUTAR';
  strngrd1.Cells[SS_NET_TUTAR, 0] := 'NET TUTAR';
end;

procedure TfrmSatSiparisDetaylar.RefreshData;
begin
  inherited;

  edtmusteri_kodu.Text := TSatSiparis(Table).MusteriKodu.Value;
  edtmusteri_adi.Text := TSatSiparis(Table).MusteriAdi.Value;
  edtvergi_dairesi.Text := TSatSiparis(Table).VergiDairesi.Value;
  edtvergi_no.Text := TSatSiparis(Table).VergiNo.Value;
  edtulke_id.Text := TSatSiparis(Table).Ulke.Value;
  edtsehir_id.Text := TSatSiparis(Table).Sehir.Value;
  edtilce.Text := TSatSiparis(Table).Ilce.Value;
  edtmahalle.Text := TSatSiparis(Table).Mahalle.Value;
  edtcadde.Text := TSatSiparis(Table).Cadde.Value;
  edtsokak.Text := TSatSiparis(Table).Sokak.Value;
  edtbina_adi.Text := TSatSiparis(Table).BinaAdi.Value;
  edtkapi_no.Text := TSatSiparis(Table).KapiNo.Value;
  edtposta_kodu.Text := TSatSiparis(Table).PostaKodu.Value;
  cbbsiparis_durum_id.ItemIndex := cbbsiparis_durum_id.Items.IndexOf(TSatSiparis(Table).SiparisDurum.Value);

  edtsiparis_no.Text := TSatSiparis(Table).SiparisNo.Value;
  if TSatSiparis(Table).SiparisTarihi.Value > 0
  then  edtsiparis_tarihi.Text := DateToStr(TSatSiparis(Table).SiparisTarihi.Value)
  else  edtsiparis_tarihi.Clear;
  if TSatSiparis(Table).TeslimTarihi.Value > 0
  then  edtteslim_tarihi.Text := DateToStr(TSatSiparis(Table).TeslimTarihi.Value)
  else  edtteslim_tarihi.Clear;
  edtpara_birimi.Text := TSatSiparis(Table).ParaBirimi.AsString;
  edtdoviz_kuru_usd.Text := TSatSiparis(Table).DovizKuruUsd.AsString;
  edtdoviz_kuru_eur.Text := TSatSiparis(Table).DovizKuruEur.AsString;

  edtmusteri_temsilcisi_id.Text := TSatSiparis(Table).MusteriTemsilcisi.Value;
  edtmuhattap_ad.Text := TSatSiparis(Table).MuhattapAd.Value;
  edtpaket_tipi_id.Text := TSatSiparis(Table).PaketTipi.AsString;
  edttasima_ucreti_id.Text := TSatSiparis(Table).NakliyeUcreti.AsString;
  edtodeme_sekli_id.Text := TSatSiparis(Table).OdemeSekli.AsString;
  edtteslim_sekli_id.Text := TSatSiparis(Table).TeslimSekli.AsString;
  edtreferans.Text := TSatSiparis(Table).Referans.Value;
  mmoaciklama.Text := TSatSiparis(Table).Aciklama.Value;
  edtproforma_no.Text := TSatSiparis(Table).ProformaNo.Value;

  GridFill();
end;

procedure TfrmSatSiparisDetaylar.Repaint;
begin
  inherited;
  edtulke_id.ReadOnly := True;
  edtmusteri_temsilcisi_id.ReadOnly := True;
  edtsiparis_no.ReadOnly := True;
end;

procedure TfrmSatSiparisDetaylar.HelperProcess(Sender: TObject);
var
  LFrmCH: TfrmHesapKartlari;
  LCH: TChHesapKarti;
  LFrmSehir: TfrmSysSehirler;
  LFrmPara: TfrmSysParaBirimleri;
  LFrmPaket: TfrmSetEinvPaketTipleri;
  LFrmTasima: TfrmSetEinvTasimaUcretleri;
  LFrmOdeme: TfrmSetEinvOdemeSekilleri;
  LFrmTeslim: TfrmSetEinvTeslimSekilleri;

  LOldPara: string;
  LKullanilanKur, LOldKur: Double;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtmusteri_kodu.Name then
      begin
        LCH := TChHesapKarti.Create(Table.Database);
        LFrmCH := TfrmHesapKartlari.Create(TEdit(Sender), Self, LCH, fomNormal, True);
        LFrmCH.QryFiltreVarsayilanKullanici :=
          ' AND ' + LCH.HesapTipiID.QryName + '=' + Ord(TAccAccountType.Son).ToString +
          ' AND (' + LCH.HesapKodu.QryName + ' LIKE ' + QuotedStr('120%') + ' OR ' +
                     LCH.HesapKodu.QryName + ' LIKE ' + QuotedStr('159%') +
                ')';
        try
          LFrmCH.ShowModal;
          if LFrmCH.DataAktar then
          begin
            if LFrmCH.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              edtmusteri_adi.Clear;
              edtvergi_dairesi.Clear;
              edtvergi_no.Clear;
              edtulke_id.Clear;
              edtsehir_id.Clear;
              edtilce.Clear;
              edtmahalle.Clear;
              edtcadde.Clear;
              edtsokak.Clear;
              edtbina_adi.Clear;
              edtkapi_no.Clear;
              edtposta_kodu.Clear;
              edtmuhattap_ad.Clear;
              edtmuhattap_telefon.Clear;

              TSatSiparis(Table).UlkeID.Value := 0;
              TSatSiparis(Table).SehirID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := LCH.HesapKodu.AsString;
              edtmusteri_adi.Text := LCH.HesapIsmi.AsString;
              edtvergi_dairesi.Text := LCH.VergiDairesi.AsString;
              edtvergi_no.Text := LCH.VergiNo.AsString;
              edtulke_id.Text := LCH.Adres.UlkeAdi.AsString;
              edtsehir_id.Text := LCH.Adres.Sehir.AsString;
              edtmahalle.Text := LCH.Adres.Mahalle.AsString;
              edtcadde.Text := LCH.Adres.Cadde.AsString;
              edtsokak.Text := LCH.Adres.Sokak.AsString;
              edtbina_adi.Text := LCH.Adres.BinaAdi.AsString;
              edtkapi_no.Text := LCH.Adres.KapiNo.AsString;
              edtposta_kodu.Text := LCH.Adres.PostaKodu.AsString;
              edtmuhattap_ad.Text := LCH.Yetkili1.AsString;
              edtmuhattap_telefon.Text := LCH.Yetkili1Tel.AsString;

//              TSatSiparis(Table).UlkeID.Value := LCH.UlkeID.AsInteger;
              TSatSiparis(Table).SehirID.Value := LCH.Adres.SehirID.AsInteger;
            end;
          end;
        finally
          LFrmCH.Free;
        end;
      end
      else if TEdit(Sender).Name = edtpara_birimi.Name then
      begin
        LFrmPara := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, TSysParaBirimi.Create(GDataBase), fomNormal, True);
        try
          LFrmPara.ShowModal;
          if LFrmPara.DataAktar then
          begin
            LOldPara := TEdit(Sender).Text;
            if LFrmPara.CleanAndClose then
              TEdit(Sender).Clear
            else
              TEdit(Sender).Text := TSysParaBirimi(LFrmPara.Table).Para.AsString;

            if LOldPara = TEdit(Sender).Text then
              Exit;

            LOldKur := 1;
            LKullanilanKur := 1;

            if TEdit(Sender).Text = ParaTL then
              LKullanilanKur := 1
            else if TEdit(Sender).Text = ParaUSD then
              LKullanilanKur := StrToFloatDef(edtdoviz_kuru_usd.Text, 0)
            else if TEdit(Sender).Text = ParaEUR then
              LKullanilanKur := StrToFloatDef(edtdoviz_kuru_eur.Text, 0);

            if LOldPara = ParaTL then
              LOldKur := 1
            else if LOldPara = ParaUSD then
              LOldKur := StrToFloatDef(edtdoviz_kuru_usd.Text, 0)
            else if LOldPara = ParaEUR then
              LOldKur := StrToFloatDef(edtdoviz_kuru_eur.Text, 0);

            CalculateNewPrice(LOldKur, LKullanilanKur);
          end;

        finally
          LFrmPara.Free;
        end;
      end
      else if TEdit(Sender).Name = edtpaket_tipi_id.Name then
      begin
        LFrmPaket := TfrmSetEinvPaketTipleri.Create(TEdit(Sender), Self, TSetEinvPaketTipi.Create(GDataBase), fomNormal, True);
        try
          LFrmPaket.ShowModal;
          if LFrmPaket.DataAktar then
          begin
            if LFrmPaket.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSatSiparis(Table).PaketTipiID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvPaketTipi(LFrmPaket.Table).PaketTipi.AsString;
              TSatSiparis(Table).PaketTipiID.Value := LFrmPaket.Table.Id.Value;
            end;
          end;
        finally
          LFrmPaket.Free;
        end;
      end
      else if TEdit(Sender).Name = edttasima_ucreti_id.Name then
      begin
        LFrmTasima := TfrmSetEinvTasimaUcretleri.Create(TEdit(Sender), Self, TSetEinvTasimaUcreti.Create(GDataBase), fomNormal, True);
        try
          LFrmTasima.ShowModal;
          if LFrmTasima.DataAktar then
          begin
            if LFrmTasima.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSatSiparis(Table).NakliyeUcretiID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvTasimaUcreti(LFrmTasima.Table).TasimaUcreti.AsString;
              TSatSiparis(Table).NakliyeUcretiID.Value := LFrmTasima.Table.Id.Value;
            end;
          end;
        finally
          LFrmTasima.Free;
        end;
      end
      else if TEdit(Sender).Name = edtodeme_sekli_id.Name then
      begin
        LFrmOdeme := TfrmSetEinvOdemeSekilleri.Create(TEdit(Sender), Self, TSetEinvOdemeSekli.Create(GDataBase), fomNormal, True);
        try
          LFrmOdeme.ShowModal;
          if LFrmOdeme.DataAktar then
          begin
            if LFrmOdeme.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSatSiparis(Table).OdemeSekliID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvOdemeSekli(LFrmOdeme.Table).OdemeSekli.AsString;
              TSatSiparis(Table).OdemeSekliID.Value := LFrmOdeme.Table.Id.Value;
            end;
          end;
        finally
          LFrmOdeme.Free;
        end;
      end
      else if TEdit(Sender).Name = edtteslim_sekli_id.Name then
      begin
        LFrmTeslim := TfrmSetEinvTeslimSekilleri.Create(TEdit(Sender), Self, TSetEinvTeslimSekli.Create(GDataBase), fomNormal, True);
        try
          LFrmTeslim.ShowModal;
          if LFrmTeslim.DataAktar then
          begin
            if LFrmTeslim.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSatSiparis(Table).TeslimSekliID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvTeslimSekli(LFrmTeslim.Table).TeslimSekli.AsString;
              TSatSiparis(Table).TeslimSekliID.Value := LFrmTeslim.Table.Id.Value;
            end;
          end;
        finally
          LFrmTeslim.Free;
        end;
      end
      else if TEdit(Sender).Name = edtsehir_id.Name then begin
        LFrmSehir := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmSehir.ShowModal;

          TEdit(Sender).Text := TSysSehir(LFrmSehir.Table).Sehir.Value;
          TSatSiparis(Table).SehirID.Value := TSysSehir(LFrmSehir.Table).Id.AsInt64;

          edtulke_id.Text := TSysSehir(LFrmSehir.Table).UlkeAdi.AsString;
          TSatSiparis(Table).UlkeID.Value := TSysSehir(LFrmSehir.Table).UlkeID.AsInteger;
        finally
          LFrmSehir.Free;
        end;
      end
    end;
  end;
end;

end.

