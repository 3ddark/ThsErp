unit ufrmSatSiparisDetay;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.DateUtils
  , System.NetEncoding
  , System.Math
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin
  , Vcl.Imaging.jpeg
  , Vcl.Imaging.pngimage

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseDetaylarDetay

  , Ths.Erp.Database.Table.SysOlcuBirimi
  , Ths.Erp.Database.Table.SetChVergiOrani
  , Ths.Erp.Database.Table.StkStokKarti
  ;

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
    cbbolcu_birimi: TComboBox;
    edtiskonto_orani: TEdit;
    cbbkdv_orani: TComboBox;
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
    edten: TEdit;
    edtboy: TEdit;
    edtyukseklik: TEdit;
    edtnet_agirlik: TEdit;
    lblbrut_agirlik_brm: TLabel;
    lblbrut_agirlik: TLabel;
    edtbrut_agirlik: TEdit;
    lblkab_brm: TLabel;
    lblkab: TLabel;
    edtkab: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure edtfiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtmiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtiskonto_oraniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbbkdv_oraniChange(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure edtenChange(Sender: TObject);
    procedure edtboyChange(Sender: TObject);
    procedure edtyukseklikChange(Sender: TObject);
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
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SysParaBirimi
  , ufrmSatSiparisDetaylar
  , Ths.Erp.Database.Table.SatSiparis
  , ufrmStkStokKartlari
  ;

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
    vFiyat := StrToFloatDef(edtFiyat.Text, 0);

  if edtMiktar.Text <> '' then
    vMiktar := StrToFloatDef(edtMiktar.Text, 0);

  if edtiskonto_orani.Text <> '' then
    vIskontoOrani  := StrToFloatDef(edtiskonto_orani.Text, 0);

  if cbbkdv_orani.Text <> '' then
    vKDVOrani := StrToFloatDef(cbbkdv_orani.Text, 0);

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

procedure TfrmSatSiparisDetay.cbbkdv_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.ClearHacimLabels;
begin
  lblhacim_val.Caption := '0.00';
end;

procedure TfrmSatSiparisDetay.ClearTotalLabels;
var
  LMoneySign: WideString;
begin
  lblnet_fiyat_val.Caption := '0.00';
  lbltutar_val.Caption := '0.00';
  lbliskonto_tutar_val.Caption := '0.00';
  lblnet_tutar_val.Caption := '0.00';
  lblkdv_tutar_val.Caption := '0.00';
  lbltoplam_tutar_val.Caption := '0.00';

//  LMoneySign := '';
//  for n1 := 0 to GParaBirimi.List.Count-1 do
//    if (TfrmSatSiparisDetaylar(ParentForm).Table as TSatSiparis).ParaBirimi.Value = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.Value then
//    begin
//      LMoneySign := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.Value;
//      Break;
//    end;

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

procedure TfrmSatSiparisDetay.edtfiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtiskonto_oraniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtmiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatSiparisDetay.edtyukseklikChange(Sender: TObject);
begin
  CalculateHacim;
end;

procedure TfrmSatSiparisDetay.FormCreate(Sender: TObject);
var
  n1: Integer;
  LVergiOrani: TSetChVergiOrani;
  LOlcuBirimi: TSysOlcuBirimi;
begin
  inherited;

  ClearTotalLabels;
  ClearHacimLabels;

  LVergiOrani := TSetChVergiOrani.Create(Table.Database);
  LOlcuBirimi := TSysOlcuBirimi.Create(Table.Database);
  try
    LOlcuBirimi.SelectToList('', False, False);
    cbbolcu_birimi.Clear;
    for n1 := 0 to LOlcuBirimi.List.Count-1 do
      cbbolcu_birimi.Items.Add(TSysOlcuBirimi(LOlcuBirimi.List[n1]).OlcuBirimi.Value);

    LVergiOrani.SelectToList('', False, False);
    cbbkdv_orani.Clear;
    for n1 := 0 to LVergiOrani.List.Count-1 do
      cbbkdv_orani.Items.Add(TSetChVergiOrani(LVergiOrani.List[n1]).VergiOrani.Value);
    cbbkdv_orani.ItemIndex := 0;
  finally
    LVergiOrani.Free;
    LOlcuBirimi.Free;
  end;
end;

procedure TfrmSatSiparisDetay.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    cbbkdv_orani.ItemIndex := 0;
  end;

  cbbolcu_birimi.Enabled := False;
end;

procedure TfrmSatSiparisDetay.HelperProcess(Sender: TObject);
var
  LFrmStokKarti: TfrmStkStokKartlari;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LFrmStokKarti := TfrmStkStokKartlari.Create(edtstok_kodu, Self, TStkStokKarti.Create(Table.Database), fomNormal, True);
        try
          LFrmStokKarti.ShowModal;

          if LFrmStokKarti.DataAktar then
          begin
            edtstok_kodu.Text := TStkStokKarti(LFrmStokKarti.Table).StokKodu.Value;
            edtstok_aciklama.Text := TStkStokKarti(LFrmStokKarti.Table).StokAdi.Value;
            edtFiyat.Text := TStkStokKarti(LFrmStokKarti.Table).SatisFiyat.Value;
            cbbolcu_birimi.ItemIndex := cbbolcu_birimi.Items.IndexOf( TStkStokKarti(LFrmStokKarti.Table).OlcuBirimi.Value );
            if Trim(edtiskonto_orani.Text) = '' then
              edtiskonto_orani.Text := '0';
//            imgstok_resim.Picture.Assign(LFrmStokKarti.Table.QueryOfDS.FieldByName(TStkStokKarti(LFrmStokKarti.Table).StokResim.FieldName));

            edtgtip_no.Text := TStkStokKarti(LFrmStokKarti.Table).GtipNo.Value;
            edten.Text := TStkStokKarti(LFrmStokKarti.Table).En.Value;
            edtboy.Text := TStkStokKarti(LFrmStokKarti.Table).Boy.Value;
            edtyukseklik.Text := TStkStokKarti(LFrmStokKarti.Table).Yukseklik.Value;
            edtnet_agirlik.Text := TStkStokKarti(LFrmStokKarti.Table).Agirlik.Value;
            edtbrut_agirlik.Text := TStkStokKarti(LFrmStokKarti.Table).Agirlik.Value;
          end;
        finally
          LFrmStokKarti.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmSatSiparisDetay.RefreshData();
var
  LQry: TFDQuery;
  LStok: TStkStokKarti;
begin
  cbbkdv_orani.ItemIndex := cbbkdv_orani.Items.IndexOf(TSatSiparisDetay(Table).KdvOrani.Value);

  edtstok_kodu.Text := FormatedVariantVal(TSatSiparisDetay(Table).StokKodu.DataType, TSatSiparisDetay(Table).StokKodu.Value);
  edtstok_aciklama.Text := FormatedVariantVal(TSatSiparisDetay(Table).StokAciklama.DataType, TSatSiparisDetay(Table).StokAciklama.Value);
  edtfiyat.Text := FormatedVariantVal(TSatSiparisDetay(Table).Fiyat.DataType, TSatSiparisDetay(Table).Fiyat.Value);
  edtmiktar.Text := FormatedVariantVal(TSatSiparisDetay(Table).Miktar.DataType, TSatSiparisDetay(Table).Miktar.Value);
  cbbolcu_birimi.ItemIndex := cbbolcu_birimi.Items.IndexOf(FormatedVariantVal(TSatSiparisDetay(Table).OlcuBirimi.DataType, TSatSiparisDetay(Table).OlcuBirimi.Value));
  edtiskonto_orani.Text := FormatedVariantVal(TSatSiparisDetay(Table).IskontoOrani.DataType, TSatSiparisDetay(Table).IskontoOrani.Value);
  cbbkdv_orani.Text := FormatedVariantVal(TSatSiparisDetay(Table).KdvOrani.DataType, TSatSiparisDetay(Table).KdvOrani.Value);
  edtgtip_no.Text := FormatedVariantVal(TSatSiparisDetay(Table).GtipNo.DataType, TSatSiparisDetay(Table).GtipNo.Value);
  edtkullanici_aciklama.Text := FormatedVariantVal(TSatSiparisDetay(Table).KullaniciAciklama.DataType, TSatSiparisDetay(Table).KullaniciAciklama.Value);

  CalculateTotals;

  edten.Text := TSatSiparisDetay(Table).En.Value;
  edtboy.Text := TSatSiparisDetay(Table).Boy.Value;
  edtyukseklik.Text := TSatSiparisDetay(Table).Yukseklik.Value;
  lblhacim_val.Caption := TSatSiparisDetay(Table).Hacim.Value;

  CalculateHacim;

  edtnet_agirlik.Text := TSatSiparisDetay(Table).NetAgirlik.Value;
  edtbrut_agirlik.Text := TSatSiparisDetay(Table).BrutAgirlik.Value;

  edtkab.Text := TSatSiparisDetay(Table).Kab.Value;

  LQry := GDataBase.NewQuery();
  LStok := TStkStokKarti.Create(GDataBase);
  try
    LQry.SQL.Text :=
      'SELECT ' + LStok.StokResim.FieldName + ' FROM ' + LStok.TableName + ' ' +
      'WHERE ' + LStok.StokKodu.FieldName + '=' + QuotedStr(edtstok_kodu.Text);
    LQry.Open;
    if not LQry.Fields.Fields[0].IsNull then
      imgstok_resim.Picture.Assign(LQry.Fields.Fields[0]);
    LQry.Close;
  finally
    LQry.Free;
    LStok.Free;
  end;
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
      TSatSiparisDetay(Table).OlcuBirimi.Value := cbbolcu_birimi.Text;

      TSatSiparisDetay(Table).IskontoOrani.Value := edtiskonto_orani.Text;
      TSatSiparisDetay(Table).KdvOrani.Value := cbbkdv_orani.Text;
      TSatSiparisDetay(Table).Fiyat.Value := edtFiyat.Text;
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

      inherited;
    end;
  end
  else
    inherited;
end;

end.
