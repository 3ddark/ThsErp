unit ufrmSatTeklifDetaylar;

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

  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.StringGrid,

  ufrmBase,
  ufrmBaseDetaylar,

  frxClass, frxExportBaseDialog, frxExportPDF, frxDBSet,

  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SatTeklif;

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
    lblkur_dolar: TLabel;
    lblkur_euro: TLabel;
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
    edtkur_dolar: TEdit;
    edtkur_euro: TEdit;
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
    procedure btnAddDetailClick(Sender: TObject);
    procedure cbbpara_birimiChange(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject); override;
  private
    function getTeklifNo: string;
    procedure FillLabels;
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject); override;
  public
    procedure RefreshData; override;
    function CreateDetailInputForm1(AFormMode: TInputFormMode; AGrid: TStringGrid): TForm; override;
    procedure GridReset; override;
    procedure GridFill; override;
    procedure Repaint; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  ufrmSatTeklifDetay,
  Ths.Erp.Database.Table.ChHesapKarti, ufrmChHesapKartlari,
  Ths.Erp.Database.Table.SysSehir, ufrmSysSehirler,
  Ths.Erp.Database.Table.SetEInvFaturaTipi,
  Ths.Erp.Database.Table.PrsPersonel, ufrmPrsPersoneller,
  Ths.Erp.Database.Table.SetSatTeklifDurum,
  Ths.Erp.Database.Table.SetOdemeBaslangicDonemi,
  Ths.Erp.Database.Table.SysParaBirimi, ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.SetChHesapTipi, ufrmSetChHesapTipleri,
  Ths.Erp.Database.Table.SetEinvPaketTipi, ufrmSetEinvPaketTipleri,
  Ths.Erp.Database.Table.SetEinvTasimaUcreti, ufrmSetEinvTasimaUcretleri,
  Ths.Erp.Database.Table.SetEinvOdemeSekli, ufrmSetEinvOdemeSekilleri,
  Ths.Erp.Database.Table.SetEinvTeslimSekli, ufrmSetEinvTeslimSekilleri;

{$R *.dfm}

function TfrmSatTeklifDetaylar.getTeklifNo: string;
begin
  with GDataBase.NewQuery do
  try
    SQL.Clear;
    SQL.Text := 'SELECT max(teklif_no::integer) as numara FROM ' + Self.Table.TableName;
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
    if (ValidateInput) then
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
      TSatTeklif(Table).DolarKur.Value := StrToFloatDef(edtkur_dolar.Text, 1);
      TSatTeklif(Table).EuroKur.Value := StrToFloatDef(edtkur_euro.Text, 1);

      TSatTeklif(Table).MusteriTemsilcisi.Value := edtmusteri_temsilcisi_id.Text;
      TSatTeklif(Table).MusteriTemsilcisiID.Value := GSysKullanici.PersonelKartiID.Value;
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

procedure TfrmSatTeklifDetaylar.cbbpara_birimiChange(Sender: TObject);
begin
  GridFill();
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

procedure TfrmSatTeklifDetaylar.GridFill();
var
  n1: Integer;
  ATek: TSatTeklif;
begin
  strngrd1.Perform(WM_SETREDRAW, 0, 0);
  try
    GridReset();

    if not Assigned(Table) then
      Exit;

    ATek := TSatTeklif(Table);
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

        strngrd1.Cells[ST_MAL_KODU, strngrd1.Row] := FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).StokKodu);
        strngrd1.Cells[ST_MAL_ADI, strngrd1.Row] := FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).StokAciklama);
        strngrd1.Cells[ST_MIKTAR, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).Miktar), ffFixed, 12, 2);
        strngrd1.Cells[ST_BIRIM, strngrd1.Row] := FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).OlcuBirimi);
        strngrd1.Cells[ST_KDV_ORANI, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).KdvOrani), ffFixed, 5, 2);
        strngrd1.Cells[ST_FIYAT, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).Fiyat), ffFixed, 12, 2);
        strngrd1.Cells[ST_ISKONTO_ORANI, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).IskontoOrani), ffFixed, 5, 2);
        strngrd1.Cells[ST_NET_FIYAT, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).NetFiyat), ffFixed, 12, 2);
        strngrd1.Cells[ST_TUTAR, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).Tutar), ffFixed, 12, 2);
        strngrd1.Cells[ST_NET_TUTAR, strngrd1.Row] := FloatToStrF(FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).NetTutar), ffFixed, 12, 2);
        strngrd1.Cells[ST_REFERANS, strngrd1.Row] := FormatedVariantVal(TSatTeklifDetay(ATek.ListDetay[n1]).Referans);
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

procedure TfrmSatTeklifDetaylar.FillLabels;
var
  n1: Integer;
  LKDV: Double;
  LFmt: TFormatSettings;
begin
  LKDV := 0;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar1.Value;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar2.Value;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar3.Value;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar4.Value;
  LKDV := LKDV + TSatTeklif(Table).KDVTutar5.Value;

  LFmt := FormatSettings;

  for n1 := 0 to GParaBirimi.List.Count-1 do
    if TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.Value = edtpara_birimi.Text then
      LFmt.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;

  lblValToplamTutar.Caption := FloatToStrF(TSatTeklif(Table).Tutar.Value, ffCurrency, 10, 2, LFmt);
  lblValToplamIskontoTutar.Caption := FloatToStrF(TSatTeklif(Table).IskontoTutar.Value, ffCurrency, 10, 2, LFmt);
  lblValAraToplam.Caption := FloatToStrF(TSatTeklif(Table).AraToplam.Value, ffCurrency, 10, 2, LFmt);
  lblValToplamKDVTutar.Caption := FloatToStrF(LKDV, TFloatFormat.ffCurrency, 10, 2, LFmt);
  lblValGenelToplam.Caption := FloatToStrF(TSatTeklif(Table).GenelToplam.Value, ffCurrency, 10, 2, LFmt);
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

  edtkur_dolar.thsDecimalDigitCount := 6;
  edtkur_euro.thsDecimalDigitCount := 6;

  for n1 := 0 to GParaBirimi.List.Count-1 do
  begin
    if TSysParaBirimi(GParaBirimi.List[n1]).IsVarsayilan.Value then
    begin
      edtpara_birimi.Text :=  FormatedVariantVal(TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi);
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
  splHeader.Visible := False;
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    edtmusteri_temsilcisi_id.Text := GSysKullanici.PersonelAdSoyad.Value;
    edtteklif_tarihi.Text := DateToStr(GDataBase.DateDB);
    edtgecerlilik_tarihi.Text := DateToStr(IncDay(GDataBase.DateDB, 30));
    edtteklif_no.Text := getTeklifNo;
    edtkur_euro.Text := '1';
    edtkur_dolar.Text := '1';
  end
  else
    btnHeaderShowHide.Click;

  btnAccept.Visible := not TSatTeklif(Table).IsSiparislesti.Value;

  grpGenelToplam.Visible := True;

  if (FormMode = ifmNewRecord) then
    FillLabels;

  edtkur_dolar.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.Value;
  edtkur_euro.thsDecimalDigitCount := GSysOndalikHane.DovizKuru.Value;
  edtkur_dolar.MaxLength := 7;
  edtkur_euro.MaxLength := 7;
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

  edtmusteri_kodu.Text := FormatedVariantVal(TSatTeklif(Table).MusteriKodu);
  edtmusteri_adi.Text := FormatedVariantVal(TSatTeklif(Table).MusteriAdi);
  edtvergi_dairesi.Text := FormatedVariantVal(TSatTeklif(Table).VergiDairesi);
  edtvergi_no.Text := FormatedVariantVal(TSatTeklif(Table).VergiNo);
  edtulke_id.Text := FormatedVariantVal(TSatTeklif(Table).Ulke);
  edtsehir_id.Text := FormatedVariantVal(TSatTeklif(Table).Sehir);
  edtilce.Text := FormatedVariantVal(TSatTeklif(Table).Ilce);
  edtmahalle.Text := FormatedVariantVal(TSatTeklif(Table).Mahalle);
  edtcadde.Text := FormatedVariantVal(TSatTeklif(Table).Cadde);
  edtsokak.Text := FormatedVariantVal(TSatTeklif(Table).Sokak);
  edtbina_adi.Text := FormatedVariantVal(TSatTeklif(Table).BinaAdi);
  edtkapi_no.Text := FormatedVariantVal(TSatTeklif(Table).KapiNo);
  edtposta_kodu.Text := FormatedVariantVal(TSatTeklif(Table).PostaKodu);

  edtteklif_no.Text := FormatedVariantVal(TSatTeklif(Table).TeklifNo);
  if FormatedVariantVal(TSatTeklif(Table).TeklifTarihi) > 0
  then  edtteklif_tarihi.Text := DateToStr(FormatedVariantVal(TSatTeklif(Table).TeklifTarihi))
  else  edtteklif_tarihi.Clear;
  if FormatedVariantVal(TSatTeklif(Table).GecerlilikTarihi) > 0
  then  edtgecerlilik_tarihi.Text := DateToStr(FormatedVariantVal(TSatTeklif(Table).GecerlilikTarihi))
  else  edtgecerlilik_tarihi.Clear;
  edtpara_birimi.Text := FormatedVariantVal(TSatTeklif(Table).ParaBirimi);
  edtkur_dolar.Text := FloatToStr(FormatedVariantVal(TSatTeklif(Table).DolarKur));
  edtkur_euro.Text := FloatToStr(FormatedVariantVal(TSatTeklif(Table).EuroKur));

  edtmusteri_temsilcisi_id.Text := FormatedVariantVal(TSatTeklif(Table).MusteriTemsilcisi);
  edtmuhattap_ad.Text := FormatedVariantVal(TSatTeklif(Table).MuhattapAd);
  edtmuhattap_telefon.Text := FormatedVariantVal(TSatTeklif(Table).MuhattapTelefon);
  edtpaket_tipi_id.Text := FormatedVariantVal(TSatTeklif(Table).PaketTipi);
  edttasima_ucreti_id.Text := FormatedVariantVal(TSatTeklif(Table).TasimaUcreti);
  edtodeme_sekli_id.Text := FormatedVariantVal(TSatTeklif(Table).OdemeSekli);
  edtteslim_sekli_id.Text := FormatedVariantVal(TSatTeklif(Table).TeslimSekli);
  edtreferans.Text := FormatedVariantVal(TSatTeklif(Table).Referans);
  mmoaciklama.Text := FormatedVariantVal(TSatTeklif(Table).Aciklama);
  edtproforma_no.Text := FormatedVariantVal(TSatTeklif(Table).ProformaNo);

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
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtmusteri_kodu.Name then
      begin
        LCH := TChHesapKarti.Create(Table.Database);
        LFrmCH := TfrmHesapKartlari.Create(TEdit(Sender), Self, LCH, fomNormal, True);
        LFrmCH.QryFiltreVarsayilanKullanici := ' AND ' + LCH.TableName + '.' + LCH.HesapTipiID.FieldName + '=' + Ord(TChHesapTipi.Son).ToString;
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
              TEdit(Sender).Text := FormatedVariantVal(LCH.HesapKodu);
              edtmusteri_adi.Text := FormatedVariantVal(LCH.HesapIsmi);
              edtvergi_dairesi.Text := FormatedVariantVal(LCH.VergiDairesi);
              edtvergi_no.Text := FormatedVariantVal(LCH.VergiNo);
              edtulke_id.Text := FormatedVariantVal(LCH.Ulke);
              edtsehir_id.Text := FormatedVariantVal(LCH.Sehir);
              edtilce.Text := FormatedVariantVal(LCH.Ilce);
              edtmahalle.Text := FormatedVariantVal(LCH.Mahalle);
              edtcadde.Text := FormatedVariantVal(LCH.Cadde);
              edtsokak.Text := FormatedVariantVal(LCH.Sokak);
              edtbina_adi.Text := FormatedVariantVal(LCH.BinaAdi);
              edtkapi_no.Text := FormatedVariantVal(LCH.KapiNo);
              edtposta_kodu.Text := FormatedVariantVal(LCH.PostaKodu);
              edtmuhattap_ad.Text := FormatedVariantVal(LCH.Yetkili1);
              edtmuhattap_telefon.Text := FormatedVariantVal(LCH.Yetkili1Tel);

              TSatTeklif(Table).UlkeID.Value := FormatedVariantVal(LCH.UlkeID);
              TSatTeklif(Table).SehirID.Value := FormatedVariantVal(LCH.SehirID);
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
            if LFrmPara.CleanAndClose
            then  TEdit(Sender).Clear
            else  TEdit(Sender).Text := FormatedVariantVal(TSysParaBirimi(LFrmPara.Table).ParaBirimi);
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
              TEdit(Sender).Text := FormatedVariantVal(TSetEinvPaketTipi(LFrmPaket.Table).PaketTipi);
              TSatTeklif(Table).PaketTipiID.Value := LFrmPaket.Table.Id.Value;
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
              TEdit(Sender).Text := FormatedVariantVal(TSetEinvTasimaUcreti(LFrmTasima.Table).TasimaUcreti);
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
              TEdit(Sender).Text := FormatedVariantVal(TSetEinvOdemeSekli(LFrmOdeme.Table).OdemeSekli);
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
        LFrmTeslim.QryFiltreVarsayilanKullanici := ' AND ' + LTeslim.IsActive.QryName + '=True';
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
              TEdit(Sender).Text := FormatedVariantVal(LTeslim.TeslimSekli);
              TSatTeklif(Table).TeslimSekliID.Value := LTeslim.Id.Value;
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

          TEdit(Sender).Text := TSysSehir(LFrmSehir.Table).SehirAdi.Value;
          TSatTeklif(Table).SehirID.Value := FormatedVariantVal(TSysSehir(LFrmSehir.Table).Id);

          edtulke_id.Text := FormatedVariantVal(TSysSehir(LFrmSehir.Table).UlkeAdi);
          TSatTeklif(Table).UlkeID.Value := FormatedVariantVal(TSysSehir(LFrmSehir.Table).UlkeID);
        finally
          LFrmSehir.Free;
        end;
      end
    end;
  end;
end;

end.
