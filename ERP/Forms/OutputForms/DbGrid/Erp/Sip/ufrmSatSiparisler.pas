unit ufrmSatSiparisler;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.StrUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Actions, Vcl.ActnList;

type
  TfrmSatSiparisler = class(TfrmBaseDBGrid)
    mniSiparisDurumGuncelle: TMenuItem;
    rgFiltre: TRadioGroup;
    mniPrintPackingList: TMenuItem;
    procedure mniSiparisDurumGuncelleClick(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure HizliFiltre(Sender: TObject);
    procedure mniPrintPackingListClick(Sender: TObject);
  private
    FHizliFilterActive: Boolean;
    FHizliFilter: string;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

const
  FILTRE_BEKLEYEN     = 0;
  FILTRE_HAZIR        = 1;
  FILTRE_GIDEN        = 2;
  FILTRE_TUMU         = 3;

implementation

uses
  ufrmSatSiparisDetaylar,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database,
  Ths.Erp.Database.Table.SysParaBirimi,
  Ths.Erp.Database.Table.SatSiparis,
  Ths.Erp.Database.Table.SetSatSiparisDurum,
  Ths.Erp.Database.Table.SysErisimHakki,
  Ths.Erp.Database.Table.ChHesapKarti;

{$R *.dfm}

function TfrmSatSiparisler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSatSiparisDetaylar.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSatSiparisDetaylar.Create(Application, Self, TSatsiparis.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSatSiparisDetaylar.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSatSiparisler.FormShow(Sender: TObject);
begin
  inherited;

  FHizliFilterActive := False;
  rgFiltre.ItemIndex := 0;
  FHizliFilterActive := True;
  HizliFiltre(nil);
end;

procedure TfrmSatSiparisler.HizliFiltre(Sender: TObject);
begin
  if not IsHelper then
  begin
    if FHizliFilterActive then
    begin
      grd.DataSource.DataSet.DisableControls;
      try
        FHizliFilterActive := False;
        grd.DataSource.DataSet.Filter := ReplaceStr(grd.DataSource.DataSet.Filter, FHizliFilter, '');

        FHizliFilter := '';

        if rgFiltre.ItemIndex = FILTRE_BEKLEYEN then
          FHizliFilter := TSatSiparis(Table).SiparisDurumID.FieldName + '=' + QuotedStr( Ord(TSatSiparisDurum.Beklemede).ToString )
        else if rgFiltre.ItemIndex = FILTRE_HAZIR then
          FHizliFilter := TSatSiparis(Table).SiparisDurumID.FieldName + '=' + QuotedStr( Ord(TSatSiparisDurum.Hazir).ToString )
        else if rgFiltre.ItemIndex = FILTRE_GIDEN then
          FHizliFilter := TSatSiparis(Table).SiparisDurumID.FieldName + '=' + QuotedStr( Ord(TSatSiparisDurum.Gitti).ToString )
        else if rgFiltre.ItemIndex = FILTRE_TUMU then
          FHizliFilter := '';


        if grd.DataSource.DataSet.Filter <> '' then
          FHizliFilter := ' AND ' + FHizliFilter;
        grd.DataSource.DataSet.Filter := FHizliFilter;
        if grd.DataSource.DataSet.Filter <> '' then
          grd.DataSource.DataSet.Filtered := True;

      finally
        FHizliFilterActive := True;
        grd.DataSource.DataSet.EnableControls;
      end;
    end;
  end;
end;

procedure TfrmSatSiparisler.mniPrintPackingListClick(Sender: TObject);
var
  LObj: TfrxMemoView;
  LDump: string;
  Detay: TSatSiparisDetay;
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
  if TSatSiparis(Table).SiparisNo.Value = '' then
    Exit;

  if frxrprtBase.LoadFromFile(GUygulamaAnaDizin + 'Reports\sat_siparis_packing.' + FILE_EXT_FR3, True) then
  begin
    Detay := TSatSiparisDetay.Create(Table.Database);
    LCH := TChHesapKarti.Create(Table.Database);
    try
      Detay.SelectToDatasource(' AND header_id=' + IntToStr(Table.Id.Value), False);
      LCH.SelectToList(' AND ' + LCH.HesapKodu.FieldName + '=' + QuotedStr(TSatSiparis(Table).MusteriKodu.Value), False ,False);

      frxdbdtstBase.DataSet := Detay.QueryOfDS;

      SetControlField('stok_kodu');
      SetControlField('stok_aciklama');
      SetControlField('gtip_no');
      SetControlField('miktar');
      SetControlField('net_agirlik');
      SetControlField('brut_agirlik');
      SetControlField('en');
      SetControlField('boy');
      SetControlField('yukseklik');
      SetControlField('hacim');
      SetControlField('kab');

      SetControlValue('tarih', DateToStr(Now));

      SetControlValue('gonderen', GSysUygulamaAyari.Unvan.Value);
      SetControlValue('gonderen_adres', GSysUygulamaAyari.GetAddress);
      SetControlValue('gonderen_tel', GSysUygulamaAyari.Tel1.Value);

      SetControlValue('alici', TSatSiparis(Table).MusteriAdi.Value);
      SetControlValue('alici_adres', TSatSiparis(Table).GetAddress);
      SetControlValue('alici_tel', LCH.Yetkili1Tel.Value);

      SetControlValue('buyer_tel', GSysUygulamaAyari.Tel1.Value);
      SetControlValue('buyer_faks', GSysUygulamaAyari.Faks1.Value);
      SetControlValue('buyer_adres', GSysUygulamaAyari.GetAddress + AddLBs + GSysUygulamaAyari.Ilce.Value + ' / ' + GSysUygulamaAyari.Sehir.Value + ' / ' + GSysUygulamaAyari.Ulke.Value);
      SetControlValue('buyer_vergi_dairesi', GSysUygulamaAyari.VergiDairesi.Value + ' / ' + GSysUygulamaAyari.VergiNo.Value);
      SetControlValue('buyer_web', GSysUygulamaAyari.EMail.Value + AddLBs + GSysUygulamaAyari.WebSite.Value);


      LDump := FormatSettings.CurrencyString;
      for n1 := 0 to GParaBirimi.List.Count-1 do
        if TSatSiparis(Table).ParaBirimi.Value = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.Value then
        begin
          FormatSettings.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;
          if TSysParaBirimi(GParaBirimi.List[n1]).IsVarsayilan.Value then
            FormatSettings.CurrencyString := ('TL');
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

procedure TfrmSatSiparisler.mniSiparisDurumGuncelleClick(Sender: TObject);
begin
  if Table.IsAuthorized(ptSpeacial, True, False) then
  begin
    SetSelectedItem;
    if isCtrlDown then
    begin
      if TSatSiparis(Table).SiparisDurumID.Value = Ord(TSatSiparisDurum.Hazir) then
      begin
        if CustomMsgDlg(
          'Sipariþ Durum "Hazýr" dan "Bekleme" ye geri alýnsýn mý?',
          mtConfirmation,
          mbYesNo,
          ['Evet', 'Hayýr'],
          mbNo,
          'Sipariþ Durum Geri Alma Onayý') = mrYes
        then
        begin
          TSatSiparis(Table).SiparisDurumID.Value := Ord(TSatSiparisDurum.Beklemede);
          TSatSiparis(Table).Update();
          TSatSiparis(Table).QueryOfDS.Refresh;
        end;
      end
      else if TSatSiparis(Table).SiparisDurumID.Value = Ord(TSatSiparisDurum.Gitti) then
      begin
        if CustomMsgDlg(
          'Sipariþ Durum "Gitti" den "Hazýr" a geri alýnsýn mý?',
          mtConfirmation,
          mbYesNo,
          ['Evet', 'Hayýr'],
          mbNo,
          'Sipariþ Durum Geri Alma Onayý') = mrYes
        then
        begin
          TSatSiparis(Table).SiparisDurumID.Value := Ord(TSatSiparisDurum.Hazir);
          TSatSiparis(Table).Update();
          TSatSiparis(Table).QueryOfDS.Refresh;
        end;
      end;
    end
    else
    begin
      if TSatSiparis(Table).SiparisDurumID.Value = Ord(TSatSiparisDurum.Beklemede) then
      begin
        if CustomMsgDlg(
          'Sipariþ Durum "Bekleme" den "Hazýr" a getirilsin mi?',
          mtConfirmation,
          mbYesNo,
          ['Evet', 'Hayýr'],
          mbNo,
          'Sipariþ Durum Deðiþiklik Onayý') = mrYes
        then
        begin
          TSatSiparis(Table).SiparisDurumID.Value := Ord(TSatSiparisDurum.Hazir);
          TSatSiparis(Table).Update();
          TSatSiparis(Table).QueryOfDS.Refresh;
        end;
      end
      else if TSatSiparis(Table).SiparisDurumID.Value = Ord(TSatSiparisDurum.Hazir) then
      begin
        if CustomMsgDlg(
          'Sipariþ Durum "Hazýr" dan "Gitti" ye getirilsin mi?',
          mtConfirmation,
          mbYesNo,
          ['Evet', 'Hayýr'],
          mbNo,
          'Sipariþ Durum Deðiþiklik Onayý') = mrYes
        then
        begin
          TSatSiparis(Table).SiparisDurumID.Value := Ord(TSatSiparisDurum.Gitti);
          TSatSiparis(Table).Update();
          TSatSiparis(Table).QueryOfDS.Refresh;
        end;
      end;
    end;
  end
  else
    CustomMsgDlg('Durum Güncelleme hakkýnýz olmadýðý için bu iþlemi yapamazsýnýz.', mtInformation, [mbOK], ['Tamam'], mbOK, 'Ýþlem Hakký Bilgilendirme');
end;

end.
