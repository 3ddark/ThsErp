unit ufrmSatTeklifler;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.StrUtils,
  System.Types,
  System.Classes,
  System.Math,
  System.UITypes,
  System.Rtti,
  System.Actions,
  Vcl.Menus,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  Vcl.ActnList,
  Vcl.Grids,
  Vcl.DBGrids,
  Data.DB,

  frxClass, frxExportPDF, frxExportBaseDialog, frxDBSet,

  ufrmBase,
  ufrmBaseDBGrid,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.UI.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  udm;

type
  TfrmSatTeklifler = class(TfrmBaseDBGrid)
    mniSipariseAktar: TMenuItem;
    rgFiltre: TRadioGroup;
    procedure mniSipariseAktarClick(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure HizliFiltre(Sender: TObject);
    procedure mniPrintClick(Sender: TObject);
    procedure pmDBPopup(Sender: TObject); override;
  private
    FHizliFilterActive: Boolean;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

const
  FILTRE_BEKLEYEN     = 0;
  FILTRE_SIPARIS_OLAN = 1;
  FILTRE_TUMU         = 2;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database,
  Ths.Erp.Database.Table.SatTeklif, ufrmSatTeklifDetaylar,
  Ths.Erp.Database.Table.SatSiparis, ufrmSatSiparisDetaylar,
  Ths.Erp.Database.Table.ChHesapKarti,
  Ths.Erp.Database.Table.SysParaBirimi,
  Ths.Erp.Database.Table.SysErisimHakki;

{$R *.dfm}

function TfrmSatTeklifler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSatTeklifDetaylar.Create(Application, Self, TSatTeklif(Table.List[0]).Clone, pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSatTeklifDetaylar.Create(Application, Self, TSatTeklif.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSatTeklifDetaylar.Create(Application, Self, TSatTeklif(Table.List[0]).Clone, pFormMode);
end;

procedure TfrmSatTeklifler.mniPrintClick(Sender: TObject);
var
  LObj: TfrxMemoView;
  LReportFileName: string;
  LTitle: string;
  LDump: string;
  Detay: TSatTeklifDetay;
  LCH: TChHesapKarti;
  n1: Integer;

  procedure SetControlField(AFieldName: string);
  begin
    LObj := frxrprtBase.FindObject('mmo' + AFieldName + '_val') as TfrxMemoView;
    if Assigned(LObj) then
    begin
      LObj.DataSet := frxdbdtstBase;
      LObj.DataField := AFieldName;
    end;
  end;

  procedure SetControlValue(AFieldName, AValue: string);
  begin
    LObj := frxrprtBase.FindObject('mmo' + AFieldName + '_val') as TfrxMemoView;
    if Assigned(LObj) then
      LObj.Text := AValue;
  end;

begin
  if TSatTeklif(Table).TeklifNo.Value = '' then
    Exit;

  if Sender is TMenuItem then
  begin
    LReportFileName := GUygulamaAnaDizin + 'Reports\sat_teklif_single.' + FILE_EXT_FR3;
    LTitle := 'TEKLİF FORMU';
  end;

  if frxrprtBase.LoadFromFile(LReportFileName, True) then
  begin
    Detay := TSatTeklifDetay.Create(Table.Database, TSatTeklif(Table));
    LCH := TChHesapKarti.Create(Table.Database);
    try
      Detay.SelectToDatasource(' AND header_id=' + IntToStr(Table.Id.Value), False);
      LCH.SelectToList(' AND ' + LCH.HesapKodu.FieldName + '=' + QuotedStr(TSatTeklif(Table).MusteriKodu.Value), False ,False);

      frxdbdtstBase.DataSet := Detay.QueryOfDS;

      SetControlField('stok_kodu');
      SetControlField('stok_aciklama');
      SetControlField('miktar');
      SetControlField('olcu_birimi');
      SetControlField('fiyat');
      SetControlField('iskonto_orani');
      SetControlField('iskonto_tutar');
      SetControlField('tutar');
      SetControlField('net_tutar');

      SetControlValue('teklif_no', TSatTeklif(Table).TeklifNo.Value);
      SetControlValue('teklif_tarihi', TSatTeklif(Table).TeklifTarihi.Value);

      SetControlValue('musteri_adi', TSatTeklif(Table).MusteriAdi.Value);
      SetControlValue('adres', TSatTeklif(Table).GetAddress);
      SetControlValue('muhattap_ad', TSatTeklif(Table).MuhattapAd.Value);
      SetControlValue('telefon', LCH.Yetkili1Tel.Value);
      SetControlValue('faks', LCH.Faks.Value);
      SetControlValue('vergi_dairesi', TSatTeklif(Table).VergiDairesi.Value + ' / ' + TSatTeklif(Table).VergiNo.Value);
      SetControlValue('email', LCH.eMail.Value);

      SetControlValue('musteri_temsilcisi', TSatTeklif(Table).MusteriTemsilcisi.Value);
      SetControlValue('aciklama', TSatTeklif(Table).Aciklama.Value);
      SetControlValue('odeme_sekli', TSatTeklif(Table).OdemeSekli.Value);
      SetControlValue('gecerlilik_tarihi', TSatTeklif(Table).GecerlilikTarihi.Value);
      SetControlValue('teslim_sekli', TSatTeklif(Table).TeslimSekli.Value);
      SetControlValue('paket_tipi', TSatTeklif(Table).PaketTipi.Value);
      SetControlValue('tasima_ucreti', TSatTeklif(Table).TasimaUcreti.Value);


      SetControlValue('buyer_tel', GSysUygulamaAyari.Tel1.Value);
      SetControlValue('buyer_faks', GSysUygulamaAyari.Faks1.Value);
      SetControlValue('buyer_adres', GSysUygulamaAyari.GetAddress + AddLBs + GSysUygulamaAyari.Ilce.Value + ' / ' + GSysUygulamaAyari.Sehir.Value + ' / ' + GSysUygulamaAyari.Ulke.Value);
      SetControlValue('buyer_vergi_dairesi', GSysUygulamaAyari.VergiDairesi.Value + ' / ' + GSysUygulamaAyari.VergiNo.Value);
      SetControlValue('buyer_web', GSysUygulamaAyari.EMail.Value + AddLBs + GSysUygulamaAyari.WebSite.Value);


      LDump := FormatSettings.CurrencyString;
      for n1 := 0 to GParaBirimi.List.Count-1 do
        if TSatTeklif(Table).ParaBirimi.Value = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.Value then
        begin
          FormatSettings.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;
          Break;
        end;

      frxrprtBase.ShowReport;

    finally
      FormatSettings.CurrencyString := LDump;
      frxdbdtstBase.DataSet := nil;
      Detay.Free;
      LCH.Free;
    end;
  end;
end;

procedure TfrmSatTeklifler.mniSipariseAktarClick(Sender: TObject);
var
  LSatSip, ASiparis: TSatSiparis;
  LTeklif: TSatTeklif;
begin
  LSatSip := TSatSiparis.Create(GDataBase);
  LTeklif := TSatTeklif.Create(GDataBase);
  try
    if LSatSip.IsAuthorized(ptAddRecord, True, False) then
    begin
      LTeklif.SelectToList(' AND ' + LTeklif.Id.QryName + '=' + VarToStr(Table.Id.AsString) , False, False);
      ASiparis := TSatSiparis(LTeklif.ToSiparis);
      TfrmSatSiparisDetaylar.Create(Application, Self, ASiparis, TInputFormMode.ifmCopyNewRecord).Show;
    end
    else
      CustomMsgDlg(
        '"Sipariş Kayıt Hakkı" nız olmadığı için "Sipariş Kaydı yapamazsınız".',
        mtWarning,
        [mbOK],
        ['Tamam'],
        mbNo,
        'Erişim Hakkı Uyarı');
  finally
    LSatSip.Free;
    LTeklif.Free;
  end;
end;

procedure TfrmSatTeklifler.pmDBPopup(Sender: TObject);
begin
  inherited;
  mniSipariseAktar.Enabled := not TSatTeklif(Table).IsSiparislesti.AsBoolean;
end;

procedure TfrmSatTeklifler.FormShow(Sender: TObject);
begin
  inherited;

  mniPrint.Visible := True;

  FHizliFilterActive := False;
  rgFiltre.ItemIndex := 0;
  FHizliFilterActive := True;
  HizliFiltre(nil);
end;

procedure TfrmSatTeklifler.HizliFiltre(Sender: TObject);
begin
  if not IsHelper then
  begin
    if FHizliFilterActive then
    begin
//      grd.DataSource.DataSet.DisableControls;
//      try
        if rgFiltre.ItemIndex = FILTRE_BEKLEYEN then
          QryFiltreVarsayilan := ' AND ' + TSatTeklif(Table).IsSiparislesti.FieldName + '=False'
        else if rgFiltre.ItemIndex = FILTRE_SIPARIS_OLAN then
          QryFiltreVarsayilan := ' AND ' + TSatTeklif(Table).IsSiparislesti.FieldName + '=True'
        else if rgFiltre.ItemIndex = FILTRE_TUMU then
          QryFiltreVarsayilan := '';
        RefreshDataFirst;
//      finally
//        grd.DataSource.DataSet.EnableControls;
//      end;
    end;
  end;
end;

end.
