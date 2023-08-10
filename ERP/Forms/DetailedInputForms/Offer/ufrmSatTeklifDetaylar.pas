unit ufrmSatTeklifDetaylar;

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
  Ths.Database.Table.SatTeklif;

const
  ST_MAL_KODU            = 1;
  ST_MAL_ADI             = 2;
  ST_MIKTAR              = 3;
  ST_BIRIM               = 4;
  ST_KDV_ORANI           = 5;
  ST_FIYAT               = 6;
  ST_ISKONTO_ORANI       = 7;
  ST_NET_FIYAT           = 8;
  ST_TUTAR               = 9;
  ST_NET_TUTAR           = 10;
  ST_REFERANS            = 11;

type
  TfrmSatTeklifDetaylar = class(TfrmBaseDetaylar)
    lblProformaNo: TLabel;
    lblSonrakiAksiyonTarihi: TLabel;
    lblSonrakiAksiyon: TLabel;
    lblArayanKisi: TLabel;
    lblAramaTarihi: TLabel;
    lblSonGecerlilikTarihi: TLabel;
    lblGenelIskontoYuzdesiTutari: TLabel;
    lblGenelIskontoAyrac: TLabel;
    lblIhracKayitKodu: TLabel;
    lblTevkifatKodu: TLabel;
    lblTevkifatOrani: TLabel;
    lblTevkifatBolme: TLabel;
    edtProformaNo: TEdit;
    edtSonrakiAksiyonTarihi: TEdit;
    mmoSonrakiAksiyon: TMemo;
    edtGenelIskontoYuzdesi: TEdit;
    edtGenelIskontoTutar: TEdit;
    cbbArayanKisi: TComboBox;
    edtAramaTarihi: TEdit;
    edtSonGecerlilikTarihi: TEdit;
    cbbIhracKayitKodu: TComboBox;
    cbbTevkifatKodu: TComboBox;
    cbbTevkifatPay: TComboBox;
    cbbTevkifatPayda: TComboBox;
    lblteklif_no: TLabel;
    lblteklif_tarihi: TLabel;
    lblmusteri_kodu: TLabel;
    lblmusteri_adi: TLabel;
    lblvergi_dairesi: TLabel;
    lblvergi_no: TLabel;
    lblpara_birimi: TLabel;
    lbldoviz_kuru_usd: TLabel;
    lblmusteri_temsilcisi_id: TLabel;
    lblteslim_sekli_id: TLabel;
    lblodeme_sekli_id: TLabel;
    lblreferans: TLabel;
    lblmuhattap_ad: TLabel;
    lblgecerlilik_tarihi: TLabel;
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
    edtteklif_no: TEdit;
    edtteklif_tarihi: TEdit;
    edtgecerlilik_tarihi: TEdit;
    edtdoviz_kuru_usd: TEdit;
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
    lbldoviz_kuru_eur: TLabel;
    edtdoviz_kuru_eur: TEdit;
    procedure btnAddDetailClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject); override;
    procedure edtpara_birimiChange(Sender: TObject);
    procedure edtdoviz_kuruExit(Sender: TObject);
    procedure edtdoviz_kuruEnter(Sender: TObject);
  private
    FOldDovizKuru: Double;

    function getTeklifNo: string;
    procedure FillLabels;
    procedure CalculateNewPrice(const AOldKur, ANewKur: Double);
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject); override;
  public
    function GetDovizKuru(APara: string): Double;
    procedure RefreshData; override;
    function CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    procedure GridReset; override;
    procedure GridFill; override;
    procedure Repaint; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  ufrmSatTeklifDetay,
  Ths.Database.Table.ChHesapKarti, ufrmChHesapKartlari,
  Ths.Database.Table.SysSehirler, ufrmSysSehirler,
  Ths.Database.Table.SetEInvFaturaTipi,
  Ths.Database.Table.EmpEmployee, ufrmEmpEmployees,
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

function TfrmSatTeklifDetaylar.getTeklifNo: string;
begin
  with GDataBase.NewQuery do
  try
    SQL.Clear;
    SQL.Text := 'SELECT max(teklif_no::::integer) as numara FROM ' + Self.Table.TableName;
    Open;

    if (FieldByName('numara').Value = Null) or (FieldByName('numara').AsString = '')
    then  Result := '1'
    else  Result := (FieldByName('numara').AsInteger+1).ToString;
  finally
    Free;
  end;
end;

procedure TfrmSatTeklifDetaylar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput(pgcHeader)) then
    begin
      TSatTeklif(Table).SiparisID.Value := 0;
      TSatTeklif(Table).IrsaliyeID.Value := 0;
      TSatTeklif(Table).FaturaID.Value := 0;
      TSatTeklif(Table).IsSiparislesti.Value := False;

      TSatTeklif(Table).IslemTipiID.Value := TEinvFaturaTipi.Satis;

      TSatTeklif(Table).MusteriKodu.Value := edtmusteri_kodu.Text;
      TSatTeklif(Table).MusteriAdi.Value := edtmusteri_adi.Text;
      TSatTeklif(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TSatTeklif(Table).VergiNo.Value := edtvergi_no.Text;
      TSatTeklif(Table).Ilce.Value := edtilce.Text;
      TSatTeklif(Table).Mahalle.Value := edtmahalle.Text;
      TSatTeklif(Table).Cadde.Value := edtcadde.Text;
      TSatTeklif(Table).Sokak.Value := edtsokak.Text;
      TSatTeklif(Table).BinaAdi.Value := edtbina_adi.Text;
      TSatTeklif(Table).KapiNo.Value := edtkapi_no.Text;
      TSatTeklif(Table).PostaKodu.Value := edtposta_kodu.Text;

      TSatTeklif(Table).TeklifNo.Value := edtteklif_no.Text;
      TSatTeklif(Table).TeklifTarihi.Value := StrToDateDef(edtteklif_tarihi.Text, 0);
      TSatTeklif(Table).GecerlilikTarihi.Value := StrToDateDef(edtgecerlilik_tarihi.Text, 0);
      TSatTeklif(Table).ParaBirimi.Value := edtpara_birimi.Text;
      TSatTeklif(Table).DovizKuruUsd.Value := StrToFloatDef(edtdoviz_kuru_usd.Text, 1);
      TSatTeklif(Table).DovizKuruEur.Value := StrToFloatDef(edtdoviz_kuru_eur.Text, 1);

      TSatTeklif(Table).MusteriTemsilcisi.Value := edtmusteri_temsilcisi_id.Text;
      TSatTeklif(Table).MusteriTemsilcisiID.Value := GSysKullanici.PersonelID.Value;
      TSatTeklif(Table).MuhattapAd.Value := edtmuhattap_ad.Text;
      TSatTeklif(Table).MuhattapTelefon.Value := edtmuhattap_telefon.Text;

      TSatTeklif(Table).PaketTipi.Value := edtpaket_tipi_id.Text;
      TSatTeklif(Table).TasimaUcreti.Value := edttasima_ucreti_id.Text;
      TSatTeklif(Table).OdemeSekli.Value := edtodeme_sekli_id.Text;
      TSatTeklif(Table).TeslimSekli.Value := edtteslim_sekli_id.Text;

      TSatTeklif(Table).Referans.Value := edtreferans.Text;
      TSatTeklif(Table).Aciklama.Value := mmoaciklama.Text;
      TSatTeklif(Table).ProformaNo.Value := edtproforma_no.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSatTeklifDetaylar.btnAddDetailClick(Sender: TObject);
begin
  inherited;
  CreateDetailInputForm1(ifmNewRecord, strngrd1).Show
end;

procedure TfrmSatTeklifDetaylar.CalculateNewPrice(const AOldKur, ANewKur: Double);
var
  n1: Integer;
  LTotal: TTotal;
begin
  for n1 := 0 to TSatTeklif(Table).ListDetay.Count-1 do
  begin
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).Fiyat.Value := TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).Fiyat.AsFloat * AOldKur / ANewKur;
    LTotal := CalculateTotalValues(
      TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).Fiyat.AsFloat,
      TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).Miktar.AsFloat,
      TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).IskontoOrani.AsFloat,
      TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).KdvOrani.AsFloat
    );
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).Tutar.Value := LTotal.Tutar;
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).NetFiyat.Value := LTotal.NetFiyat;
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).NetTutar.Value := LTotal.NetTutar;
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).IskontoTutar.Value := LTotal.IskontoTutar;
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).KDVTutar.Value := LTotal.KDVTutar;
    TSatTeklifDetay(TSatTeklif(Table).ListDetay[n1]).ToplamTutar.Value := LTotal.ToplamTutar;
  end;

  TSatTeklif(Table).PubRefreshHeader;
  GridFill;
end;

function TfrmSatTeklifDetaylar.CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (AFormMode = ifmNewRecord) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSatisTeklifDetay.Create(Application, AGrid, Self, TSatTeklifDetay.Create(Table.Database, TSatTeklif(Table)), AFormMode)
  else if (AFormMode = ifmRewiev) or (AFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmSatisTeklifDetay.Create(Application, AGrid, Self, TSatTeklifDetay(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd1.Row]), AFormMode);
  end;
end;

procedure TfrmSatTeklifDetaylar.edtdoviz_kuruExit(Sender: TObject);
begin
  if Sender is TEdit then
  begin
    if ((TEdit(Sender).Name = edtdoviz_kuru_usd.Name) and (edtpara_birimi.Text = ParaUSD) and (TEdit(Sender).moneyToDouble <> FOldDovizKuru))
    or ((TEdit(Sender).Name = edtdoviz_kuru_eur.Name) and (edtpara_birimi.Text = ParaEUR) and (TEdit(Sender).moneyToDouble <> FOldDovizKuru))
    then
      CalculateNewPrice(FOldDovizKuru, TEdit(Sender).moneyToDouble);
  end;
end;

procedure TfrmSatTeklifDetaylar.edtdoviz_kuruEnter(Sender: TObject);
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

procedure TfrmSatTeklifDetaylar.edtpara_birimiChange(Sender: TObject);
begin
  GridFill();
end;

procedure TfrmSatTeklifDetaylar.GridFill();
var
  n1: Integer;
  ATek: TSatTeklif;
begin
  strngrd1.Perform(WM_SETREDRAW, 0, 0);
  ATek := TSatTeklif(Table);
  try
    GridReset();

    if not Assigned(Table) then
      Exit;

    if ATek.ListDetay.Count > 0 then
    begin
      strngrd1.RowCount := ATek.ListDetay.Count + strngrd1.FixedRows;

      strngrd1.ColStyleDouble(ST_MIKTAR);
      strngrd1.ColStyleDouble(ST_KDV_ORANI);
      strngrd1.ColStyleDouble(ST_ISKONTO_ORANI);
      strngrd1.ColStyleMoney(ST_FIYAT);
      strngrd1.ColStyleMoney(ST_NET_FIYAT);
      strngrd1.ColStyleMoney(ST_TUTAR);
      strngrd1.ColStyleMoney(ST_NET_TUTAR);

      for n1 := 0 to ATek.ListDetay.Count-1 do
      begin
        if n1 > 0 then
          strngrd1.Row := strngrd1.Row + 1;

        strngrd1.Objects[COLUMN_GRID_OBJECT, strngrd1.Row] := TSatTeklifDetay(ATek.ListDetay[n1]);

        strngrd1.Cells[ST_MAL_KODU, strngrd1.Row] := TSatTeklifDetay(ATek.ListDetay[n1]).StokKodu.AsString;
        strngrd1.Cells[ST_MAL_ADI, strngrd1.Row] := TSatTeklifDetay(ATek.ListDetay[n1]).StokAciklama.AsString;
        strngrd1.Cells[ST_MIKTAR, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).Miktar.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_BIRIM, strngrd1.Row] := TSatTeklifDetay(ATek.ListDetay[n1]).OlcuBirimi.AsString;
        strngrd1.Cells[ST_KDV_ORANI, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).KdvOrani.AsFloat, ffFixed, 5, 2);
        strngrd1.Cells[ST_FIYAT, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).Fiyat.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_ISKONTO_ORANI, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).IskontoOrani.AsFloat, ffFixed, 5, 2);
        strngrd1.Cells[ST_NET_FIYAT, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).NetFiyat.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_TUTAR, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).Tutar.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_NET_TUTAR, strngrd1.Row] := FloatToStrF(TSatTeklifDetay(ATek.ListDetay[n1]).NetTutar.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_REFERANS, strngrd1.Row] := TSatTeklifDetay(ATek.ListDetay[n1]).Referans.AsString;
      end;
    end;

    FillLabels;
  finally
    if ATek.ListDetay.Count = 1 then
      strngrd1.DrawFixedRowNumbers;

    strngrd1.Perform(WM_SETREDRAW, 1, 0);
    strngrd1.Invalidate;

    strngrd1.Row := 1;
    strngrd1.Col := 1;
  end;
end;

procedure TfrmSatTeklifDetaylar.FillLabels;
var
  n1: Integer;
  LKDV: Double;
  LFmt: TFormatSettings;
begin
  LKDV := 0;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar1.AsFloat;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar2.AsFloat;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar3.AsFloat;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar4.AsFloat;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar5.AsFloat;

  LFmt := FormatSettings;

  for n1 := 0 to GParaBirimi.List.Count-1 do
    if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = edtpara_birimi.Text then
      LFmt.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.AsString;

  lblValToplamTutar.Caption := FloatToStrF(TSatTeklif(Table).Tutar.AsFloat, ffCurrency, 10, 2, LFmt);
  lblValToplamIskontoTutar.Caption := FloatToStrF(TSatTeklif(Table).IskontoTutar.AsFloat, ffCurrency, 10, 2, LFmt);
  lblValAraToplam.Caption := FloatToStrF(TSatTeklif(Table).AraToplam.AsFloat, ffCurrency, 10, 2, LFmt);
  lblValToplamKDVTutar.Caption := FloatToStrF(LKDV, TFloatFormat.ffCurrency, 10, 2, LFmt);
  lblValGenelToplam.Caption := FloatToStrF(TSatTeklif(Table).GenelToplam.AsFloat, ffCurrency, 10, 2, LFmt);
end;

procedure TfrmSatTeklifDetaylar.FormCreate(Sender: TObject);
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
      edtpara_birimi.Text := TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString;
      Break;
    end;
  end;

  ts1.Caption := 'Teklif Detaylarý';
end;

procedure TfrmSatTeklifDetaylar.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSatTeklifDetaylar.FormShow(Sender: TObject);
begin
  inherited;
  edtdoviz_kuru_usd.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.Value;
  edtdoviz_kuru_usd.MaxLength := 7;

  edtdoviz_kuru_eur.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.Value;
  edtdoviz_kuru_eur.MaxLength := 7;

  splHeader.Visible := False;
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    edtmusteri_temsilcisi_id.Text := GSysKullanici.AdSoyad.Value;
    edtteklif_tarihi.Text := DateToStr(GDataBase.DateDB);
    edtgecerlilik_tarihi.Text := DateToStr(IncDay(GDataBase.DateDB, 30));
    edtdoviz_kuru_usd.Text := GetDovizKuru(ParaUSD).ToString;
    edtdoviz_kuru_eur.Text := GetDovizKuru(ParaEUR).ToString;
    edtteklif_no.Text := getTeklifNo;
  end
  else
    btnHeaderShowHide.Click;

  btnAccept.Visible := not TSatTeklif(Table).IsSiparislesti.Value;

  grpGenelToplam.Visible := True;

  if (FormMode = ifmNewRecord) then
    FillLabels;
end;

function TfrmSatTeklifDetaylar.GetDovizKuru(APara: string): Double;
var
  LKur: TChDovizKuru;
  n1: Integer;
begin
  Result := 1;

  LKur := TChDovizKuru.Create(GDataBase);
  try
    LKur.SelectToList(' AND ' + LKur.KurTarihi.QryName + '=' + QuotedStr(DateToStr( StrToDateDef(edtteklif_tarihi.Text, GDataBase.DateDB))), False, False);
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

procedure TfrmSatTeklifDetaylar.GridReset();
begin
  inherited;

  strngrd1.RowCount := 2;
  strngrd1.ColCount := 11;
  strngrd1.Rows[0].Text := '';
  strngrd1.Rows[1].Text := '';

  GridColWidth(strngrd1, 100, ST_MAL_KODU);
  GridColWidth(strngrd1, 230, ST_MAL_ADI);
  GridColWidth(strngrd1, 50, ST_MIKTAR);
  GridColWidth(strngrd1, 40, ST_BIRIM);
  GridColWidth(strngrd1, 40, ST_KDV_ORANI);
  GridColWidth(strngrd1, 80, ST_FIYAT);
  GridColWidth(strngrd1, 40, ST_ISKONTO_ORANI);
  GridColWidth(strngrd1, 80, ST_NET_FIYAT);
  GridColWidth(strngrd1, 80, ST_TUTAR);
  GridColWidth(strngrd1, 80, ST_NET_TUTAR);

  strngrd1.Cells[ST_MAL_KODU, 0] := 'STOK KODU';
  strngrd1.Cells[ST_MAL_ADI, 0] := 'AÇIKLAMA';
  strngrd1.Cells[ST_MIKTAR, 0] := 'MÝKTAR';
  strngrd1.Cells[ST_BIRIM, 0] := 'BÝRÝM';
  strngrd1.Cells[ST_KDV_ORANI, 0] := 'KDV%';
  strngrd1.Cells[ST_FIYAT, 0] := 'FÝYAT';
  strngrd1.Cells[ST_ISKONTO_ORANI, 0] := 'ÝSK%';
  strngrd1.Cells[ST_NET_FIYAT, 0] := 'NET FÝYAT';
  strngrd1.Cells[ST_TUTAR, 0] := 'TUTAR';
  strngrd1.Cells[ST_NET_TUTAR, 0] := 'NET TUTAR';
end;

procedure TfrmSatTeklifDetaylar.RefreshData;
begin
  inherited;

  edtmusteri_kodu.Text := TSatTeklif(Table).MusteriKodu.AsString;
  edtmusteri_adi.Text := TSatTeklif(Table).MusteriAdi.AsString;
  edtvergi_dairesi.Text := TSatTeklif(Table).VergiDairesi.AsString;
  edtvergi_no.Text := TSatTeklif(Table).VergiNo.AsString;
  edtulke_id.Text := TSatTeklif(Table).Ulke.AsString;
  edtsehir_id.Text := TSatTeklif(Table).Sehir.AsString;
  edtilce.Text := TSatTeklif(Table).Ilce.AsString;
  edtmahalle.Text := TSatTeklif(Table).Mahalle.AsString;
  edtcadde.Text := TSatTeklif(Table).Cadde.AsString;
  edtsokak.Text := TSatTeklif(Table).Sokak.AsString;
  edtbina_adi.Text := TSatTeklif(Table).BinaAdi.AsString;
  edtkapi_no.Text := TSatTeklif(Table).KapiNo.AsString;
  edtposta_kodu.Text := TSatTeklif(Table).PostaKodu.AsString;

  edtteklif_no.Text := TSatTeklif(Table).TeklifNo.AsString;
  if TSatTeklif(Table).TeklifTarihi.AsDate > 0
  then  edtteklif_tarihi.Text := DateToStr(TSatTeklif(Table).TeklifTarihi.AsDate)
  else  edtteklif_tarihi.Clear;
  if TSatTeklif(Table).GecerlilikTarihi.AsDate > 0
  then  edtgecerlilik_tarihi.Text := DateToStr(TSatTeklif(Table).GecerlilikTarihi.AsDate)
  else  edtgecerlilik_tarihi.Clear;
  edtpara_birimi.Text := TSatTeklif(Table).ParaBirimi.AsString;
  edtdoviz_kuru_usd.Text := TSatTeklif(Table).DovizKuruUsd.AsString;
  edtdoviz_kuru_eur.Text := TSatTeklif(Table).DovizKuruEur.AsString;

  edtmusteri_temsilcisi_id.Text := TSatTeklif(Table).MusteriTemsilcisi.AsString;
  edtmuhattap_ad.Text := TSatTeklif(Table).MuhattapAd.AsString;
  edtmuhattap_telefon.Text := TSatTeklif(Table).MuhattapTelefon.AsString;
  edtpaket_tipi_id.Text := TSatTeklif(Table).PaketTipi.AsString;
  edttasima_ucreti_id.Text := TSatTeklif(Table).TasimaUcreti.AsString;
  edtodeme_sekli_id.Text := TSatTeklif(Table).OdemeSekli.AsString;
  edtteslim_sekli_id.Text := TSatTeklif(Table).TeslimSekli.AsString;
  edtreferans.Text := TSatTeklif(Table).Referans.AsString;
  mmoaciklama.Text := TSatTeklif(Table).Aciklama.AsString;
  edtproforma_no.Text := TSatTeklif(Table).ProformaNo.AsString;

  GridFill;
end;

procedure TfrmSatTeklifDetaylar.Repaint;
begin
  inherited;
  edtulke_id.ReadOnly := True;
  edtmusteri_temsilcisi_id.ReadOnly := True;
  edtteklif_no.ReadOnly := True;
end;

procedure TfrmSatTeklifDetaylar.HelperProcess(Sender: TObject);
var
  LFrmCH: TfrmHesapKartlari;
  LCH: TChHesapKarti;
  LFrmSehir: TfrmSysSehirler;
  LFrmPara: TfrmSysParaBirimleri;
  LFrmPaket: TfrmSetEinvPaketTipleri;
  LFrmTasima: TfrmSetEinvTasimaUcretleri;
  LFrmOdeme: TfrmSetEinvOdemeSekilleri;
  LFrmTeslim: TfrmSetEinvTeslimSekilleri;
  LTeslim: TSetEinvTeslimSekli;

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

              TSatTeklif(Table).UlkeID.Value := 0;
              TSatTeklif(Table).SehirID.Value := 0;
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

//              TSatTeklif(Table).UlkeID.Value := LCH.Adres.UlkeID.AsInteger;
              TSatTeklif(Table).SehirID.Value := LCH.Adres.SehirID.AsInteger;
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
            if LFrmPara.CleanAndClose then
              TEdit(Sender).Clear
            else
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
              TSatTeklif(Table).PaketTipiID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvPaketTipi(LFrmPaket.Table).PaketTipi.AsString;
              TSatTeklif(Table).PaketTipiID.Value := LFrmPaket.Table.Id.AsInteger;
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
              TSatTeklif(Table).TasimaUcretiID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvTasimaUcreti(LFrmTasima.Table).TasimaUcreti.AsString;
              TSatTeklif(Table).TasimaUcretiID.Value := LFrmTasima.Table.Id.Value;
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
              TSatTeklif(Table).OdemeSekliID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSetEinvOdemeSekli(LFrmOdeme.Table).OdemeSekli.AsString;
              TSatTeklif(Table).OdemeSekliID.Value := LFrmOdeme.Table.Id.Value;
            end;
          end;
        finally
          LFrmOdeme.Free;
        end;
      end
      else if TEdit(Sender).Name = edtteslim_sekli_id.Name then
      begin
        LTeslim := TSetEinvTeslimSekli.Create(GDataBase);
        LFrmTeslim := TfrmSetEinvTeslimSekilleri.Create(TEdit(Sender), Self, LTeslim, fomNormal, True);
        LFrmTeslim.QryFiltreVarsayilanKullanici := ' AND ' + LTeslim.IsAktif.QryName + '=True';
        try
          LFrmTeslim.ShowModal;
          if LFrmTeslim.DataAktar then
          begin
            if LFrmTeslim.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSatTeklif(Table).TeslimSekliID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := LTeslim.TeslimSekli.AsString;
              TSatTeklif(Table).TeslimSekliID.Value := LTeslim.Id.AsInteger;
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

          TEdit(Sender).Text := TSysSehir(LFrmSehir.Table).Sehir.AsString;
          TSatTeklif(Table).SehirID.Value := TSysSehir(LFrmSehir.Table).Id.AsInteger;

          edtulke_id.Text := TSysSehir(LFrmSehir.Table).UlkeAdi.AsString;
          TSatTeklif(Table).UlkeID.Value := TSysSehir(LFrmSehir.Table).UlkeID.AsInteger;
        finally
          LFrmSehir.Free;
        end;
      end
    end;
  end;
end;

end.

