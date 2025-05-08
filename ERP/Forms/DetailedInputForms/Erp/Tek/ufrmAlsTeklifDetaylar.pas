unit ufrmAlsTeklifDetaylar;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.DateUtils, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Menus, Vcl.Buttons, Vcl.AppEvnts, Vcl.Samples.Spin,
  Vcl.Grids, Vcl.ActnList, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, Ths.Helper.StringGrid, ufrmBase,
  ufrmBaseDetaylar, Ths.Database.Table, Ths.Database.Table.AlsTeklifler;

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
  TfrmAlsTeklifDetaylar = class(TfrmBaseDetaylar)
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
    edtpara_birimi: TEdit;
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

function TfrmAlsTeklifDetaylar.getTeklifNo: string;
begin
  with GDataBase.NewQuery do
  try
    SQL.Clear;
    SQL.Text := 'SELECT max(cast(teklif_no as integer)) as numara FROM ' + Self.Table.TableName;
    Open;

    if (FieldByName('numara').Value = Null) or (FieldByName('numara').AsString = '')
    then  Result := '1'
    else  Result := (FieldByName('numara').AsInteger+1).ToString;
  finally
    Free;
  end;
end;

procedure TfrmAlsTeklifDetaylar.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput(pgcHeader)) then
    begin
      TAlsTeklif(Table).SiparisID.Value := 0;
      TAlsTeklif(Table).IrsaliyeID.Value := 0;
      TAlsTeklif(Table).FaturaID.Value := 0;
      TAlsTeklif(Table).IsSiparislesti.Value := False;

      TAlsTeklif(Table).IslemTipiID.Value := TEinvFaturaTipi.Satis;

      TAlsTeklif(Table).MusteriKodu.Value := edtmusteri_kodu.Text;
      TAlsTeklif(Table).MusteriAdi.Value := edtmusteri_adi.Text;
      TAlsTeklif(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TAlsTeklif(Table).VergiNo.Value := edtvergi_no.Text;
      TAlsTeklif(Table).Ilce.Value := edtilce.Text;
      TAlsTeklif(Table).Mahalle.Value := edtmahalle.Text;
      TAlsTeklif(Table).Cadde.Value := edtcadde.Text;
      TAlsTeklif(Table).Sokak.Value := edtsokak.Text;
      TAlsTeklif(Table).BinaAdi.Value := edtbina_adi.Text;
      TAlsTeklif(Table).KapiNo.Value := edtkapi_no.Text;
      TAlsTeklif(Table).PostaKodu.Value := edtposta_kodu.Text;

      TAlsTeklif(Table).TeklifNo.Value := edtteklif_no.Text;
      TAlsTeklif(Table).TeklifTarihi.Value := StrToDateDef(edtteklif_tarihi.Text, 0);
      TAlsTeklif(Table).GecerlilikTarihi.Value := StrToDateDef(edtgecerlilik_tarihi.Text, 0);
      TAlsTeklif(Table).ParaBirimi.Value := edtpara_birimi.Text;
      TAlsTeklif(Table).DovizKuruUsd.Value := StrToFloatDef(edtdoviz_kuru_usd.Text, 1);
      TAlsTeklif(Table).DovizKuruEur.Value := StrToFloatDef(edtdoviz_kuru_eur.Text, 1);

      TAlsTeklif(Table).MusteriTemsilcisi.Value := edtmusteri_temsilcisi_id.Text;
      TAlsTeklif(Table).MuhattapAd.Value := edtmuhattap_ad.Text;
      TAlsTeklif(Table).MuhattapTelefon.Value := edtmuhattap_telefon.Text;

      TAlsTeklif(Table).Referans.Value := edtreferans.Text;
      TAlsTeklif(Table).Aciklama.Value := mmoaciklama.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmAlsTeklifDetaylar.btnAddDetailClick(Sender: TObject);
begin
  inherited;
  CreateDetailInputForm1(ifmNewRecord, strngrd1).Show
end;

procedure TfrmAlsTeklifDetaylar.CalculateNewPrice(const AOldKur, ANewKur: Double);
var
  n1: Integer;
  LTotal: TTotal;
begin
  for n1 := 0 to TAlsTeklif(Table).ListDetay.Count-1 do
  begin
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).Fiyat.Value := TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).Fiyat.AsFloat * AOldKur / ANewKur;
    LTotal := CalculateTotalValues(
      TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).Fiyat.AsFloat,
      TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).Miktar.AsFloat,
      TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).IskontoOrani.AsFloat,
      TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).KdvOrani.AsFloat
    );
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).Tutar.Value := LTotal.Tutar;
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).NetFiyat.Value := LTotal.NetFiyat;
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).NetTutar.Value := LTotal.NetTutar;
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).IskontoTutar.Value := LTotal.IskontoTutar;
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).KDVTutar.Value := LTotal.KDVTutar;
    TAlsTeklifDetay(TAlsTeklif(Table).ListDetay[n1]).ToplamTutar.Value := LTotal.ToplamTutar;
  end;

  TAlsTeklif(Table).PubRefreshHeader;
  GridFill;
end;

function TfrmAlsTeklifDetaylar.CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm;
begin
  Result := inherited;
  if (AFormMode = ifmNewRecord) or (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSatisTeklifDetay.Create(Application, AGrid, Self, TAlsTeklifDetay.Create(Table.Database, TAlsTeklif(Table)), AFormMode)
  else if (AFormMode = ifmRewiev) or (AFormMode = ifmUpdate) then
  begin
    if Assigned(AGrid.Objects[COLUMN_GRID_OBJECT, AGrid.Row]) then
      Result := TfrmSatisTeklifDetay.Create(Application, AGrid, Self, TAlsTeklifDetay(AGrid.Objects[COLUMN_GRID_OBJECT, strngrd1.Row]), AFormMode);
  end;
end;

procedure TfrmAlsTeklifDetaylar.edtdoviz_kuruExit(Sender: TObject);
begin
  if Sender is TEdit then
  begin
    if ((TEdit(Sender).Name = edtdoviz_kuru_usd.Name) and (edtpara_birimi.Text = ParaUSD) and (TEdit(Sender).moneyToDouble <> FOldDovizKuru))
    or ((TEdit(Sender).Name = edtdoviz_kuru_eur.Name) and (edtpara_birimi.Text = ParaEUR) and (TEdit(Sender).moneyToDouble <> FOldDovizKuru))
    then
      CalculateNewPrice(FOldDovizKuru, TEdit(Sender).moneyToDouble);
  end;
end;

procedure TfrmAlsTeklifDetaylar.edtdoviz_kuruEnter(Sender: TObject);
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

procedure TfrmAlsTeklifDetaylar.edtpara_birimiChange(Sender: TObject);
begin
  GridFill();
end;

procedure TfrmAlsTeklifDetaylar.GridFill();
var
  n1: Integer;
  ATek: TAlsTeklif;
begin
  strngrd1.Perform(WM_SETREDRAW, 0, 0);
  ATek := TAlsTeklif(Table);
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

        strngrd1.Objects[COLUMN_GRID_OBJECT, strngrd1.Row] := TAlsTeklifDetay(ATek.ListDetay[n1]);

        strngrd1.Cells[ST_MAL_KODU, strngrd1.Row] := TAlsTeklifDetay(ATek.ListDetay[n1]).StokKodu.AsString;
        strngrd1.Cells[ST_MAL_ADI, strngrd1.Row] := TAlsTeklifDetay(ATek.ListDetay[n1]).StokAciklama.AsString;
        strngrd1.Cells[ST_MIKTAR, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).Miktar.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_BIRIM, strngrd1.Row] := TAlsTeklifDetay(ATek.ListDetay[n1]).OlcuBirimi.AsString;
        strngrd1.Cells[ST_KDV_ORANI, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).KdvOrani.AsFloat, ffFixed, 5, 2);
        strngrd1.Cells[ST_FIYAT, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).Fiyat.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_ISKONTO_ORANI, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).IskontoOrani.AsFloat, ffFixed, 5, 2);
        strngrd1.Cells[ST_NET_FIYAT, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).NetFiyat.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_TUTAR, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).Tutar.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_NET_TUTAR, strngrd1.Row] := FloatToStrF(TAlsTeklifDetay(ATek.ListDetay[n1]).NetTutar.AsFloat, ffFixed, 12, 2);
        strngrd1.Cells[ST_REFERANS, strngrd1.Row] := TAlsTeklifDetay(ATek.ListDetay[n1]).Referans.AsString;
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

procedure TfrmAlsTeklifDetaylar.FillLabels;
var
  n1: Integer;
  LKDV: Double;
  LFmt: TFormatSettings;
begin
  LKDV := 0;
  LKDV := LKDV + TAlsTeklif(Table).KDVTutar1.AsFloat;
  LKDV := LKDV + TAlsTeklif(Table).KDVTutar2.AsFloat;
  LKDV := LKDV + TAlsTeklif(Table).KDVTutar3.AsFloat;
  LKDV := LKDV + TAlsTeklif(Table).KDVTutar4.AsFloat;
  LKDV := LKDV + TAlsTeklif(Table).KDVTutar5.AsFloat;

  LFmt := FormatSettings;

  for n1 := 0 to GParaBirimi.List.Count-1 do
    if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = edtpara_birimi.Text then
      LFmt.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.AsString;

  lblValToplamTutar.Caption := FloatToStrF(TAlsTeklif(Table).Tutar.AsFloat, ffCurrency, 10, 2, LFmt);
  lblValToplamIskontoTutar.Caption := FloatToStrF(TAlsTeklif(Table).IskontoTutar.AsFloat, ffCurrency, 10, 2, LFmt);
  lblValAraToplam.Caption := FloatToStrF(TAlsTeklif(Table).AraToplam.AsFloat, ffCurrency, 10, 2, LFmt);
  lblValToplamKDVTutar.Caption := FloatToStrF(LKDV, TFloatFormat.ffCurrency, 10, 2, LFmt);
  lblValGenelToplam.Caption := FloatToStrF(TAlsTeklif(Table).GenelToplam.AsFloat, ffCurrency, 10, 2, LFmt);
end;

procedure TfrmAlsTeklifDetaylar.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;

  edtmusteri_kodu.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;
  edtpara_birimi.OnHelperProcess := HelperProcess;

  for n1 := 0 to GParaBirimi.List.Count-1 do
  begin
    if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString then
    begin
      edtpara_birimi.Text := TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString;
      Break;
    end;
  end;

  ts1.Caption := 'Teklif Detayları';
end;

procedure TfrmAlsTeklifDetaylar.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmAlsTeklifDetaylar.FormShow(Sender: TObject);
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

  btnAccept.Visible := not TAlsTeklif(Table).IsSiparislesti.Value;

  grpGenelToplam.Visible := True;

  if (FormMode = ifmNewRecord) then
    FillLabels;
end;

function TfrmAlsTeklifDetaylar.GetDovizKuru(APara: string): Double;
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

procedure TfrmAlsTeklifDetaylar.GridReset();
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
  strngrd1.Cells[ST_MIKTAR, 0] := 'MİKTAR';
  strngrd1.Cells[ST_BIRIM, 0] := 'BİRİM';
  strngrd1.Cells[ST_KDV_ORANI, 0] := 'KDV%';
  strngrd1.Cells[ST_FIYAT, 0] := 'FİYAT';
  strngrd1.Cells[ST_ISKONTO_ORANI, 0] := 'İSK%';
  strngrd1.Cells[ST_NET_FIYAT, 0] := 'NET FİYAT';
  strngrd1.Cells[ST_TUTAR, 0] := 'TUTAR';
  strngrd1.Cells[ST_NET_TUTAR, 0] := 'NET TUTAR';
end;

procedure TfrmAlsTeklifDetaylar.RefreshData;
begin
  inherited;

  edtmusteri_kodu.Text := TAlsTeklif(Table).MusteriKodu.AsString;
  edtmusteri_adi.Text := TAlsTeklif(Table).MusteriAdi.AsString;
  edtvergi_dairesi.Text := TAlsTeklif(Table).VergiDairesi.AsString;
  edtvergi_no.Text := TAlsTeklif(Table).VergiNo.AsString;
  edtulke_id.Text := TAlsTeklif(Table).Ulke.AsString;
  edtsehir_id.Text := TAlsTeklif(Table).Sehir.AsString;
  edtilce.Text := TAlsTeklif(Table).Ilce.AsString;
  edtmahalle.Text := TAlsTeklif(Table).Mahalle.AsString;
  edtcadde.Text := TAlsTeklif(Table).Cadde.AsString;
  edtsokak.Text := TAlsTeklif(Table).Sokak.AsString;
  edtbina_adi.Text := TAlsTeklif(Table).BinaAdi.AsString;
  edtkapi_no.Text := TAlsTeklif(Table).KapiNo.AsString;
  edtposta_kodu.Text := TAlsTeklif(Table).PostaKodu.AsString;

  edtteklif_no.Text := TAlsTeklif(Table).TeklifNo.AsString;
  if TAlsTeklif(Table).TeklifTarihi.AsDate > 0
  then  edtteklif_tarihi.Text := DateToStr(TAlsTeklif(Table).TeklifTarihi.AsDate)
  else  edtteklif_tarihi.Clear;
  if TAlsTeklif(Table).GecerlilikTarihi.AsDate > 0
  then  edtgecerlilik_tarihi.Text := DateToStr(TAlsTeklif(Table).GecerlilikTarihi.AsDate)
  else  edtgecerlilik_tarihi.Clear;
  edtpara_birimi.Text := TAlsTeklif(Table).ParaBirimi.AsString;
  edtdoviz_kuru_usd.Text := TAlsTeklif(Table).DovizKuruUsd.AsString;
  edtdoviz_kuru_eur.Text := TAlsTeklif(Table).DovizKuruEur.AsString;

  edtmusteri_temsilcisi_id.Text := TAlsTeklif(Table).MusteriTemsilcisi.AsString;
  edtmuhattap_ad.Text := TAlsTeklif(Table).MuhattapAd.AsString;
  edtmuhattap_telefon.Text := TAlsTeklif(Table).MuhattapTelefon.AsString;
  edtreferans.Text := TAlsTeklif(Table).Referans.AsString;
  mmoaciklama.Text := TAlsTeklif(Table).Aciklama.AsString;

  GridFill;
end;

procedure TfrmAlsTeklifDetaylar.Repaint;
begin
  inherited;
  edtulke_id.ReadOnly := True;
  edtmusteri_temsilcisi_id.ReadOnly := True;
  edtteklif_no.ReadOnly := True;
end;

procedure TfrmAlsTeklifDetaylar.HelperProcess(Sender: TObject);
var
  LFrmCH: TfrmHesapKartlari;
  LCH: TChHesapKarti;
  LFrmSehir: TfrmSysSehirler;
  LFrmPara: TfrmSysParaBirimleri;

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

              TAlsTeklif(Table).UlkeID.Value := 0;
              TAlsTeklif(Table).SehirID.Value := 0;
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
              TAlsTeklif(Table).SehirID.Value := LCH.Adres.SehirID.AsInteger;
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
      else if TEdit(Sender).Name = edtsehir_id.Name then begin
        LFrmSehir := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmSehir.ShowModal;

          TEdit(Sender).Text := TSysSehir(LFrmSehir.Table).Sehir.AsString;
          TAlsTeklif(Table).SehirID.Value := TSysSehir(LFrmSehir.Table).Id.AsInteger;

          edtulke_id.Text := TSysSehir(LFrmSehir.Table).UlkeAdi.AsString;
          TAlsTeklif(Table).UlkeID.Value := TSysSehir(LFrmSehir.Table).UlkeID.AsInteger;
        finally
          LFrmSehir.Free;
        end;
      end
    end;
  end;
end;

end.

