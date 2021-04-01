unit ufrmBbkKayit;

interface

{$I ThsERP.inc}

uses
    Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , Dialogs
  , StdCtrls
  , ExtCtrls
  , ComCtrls
  , StrUtils
  , DateUtils
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin
  , Vcl.ExtDlgs

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  ;

type
  TfrmBbkKayit = class(TfrmBaseInputDB)
    lblfirma_adi: TLabel;
    edtfirma_adi: TEdit;
    lbltel1: TLabel;
    edttel1: TEdit;
    lbltel2: TLabel;
    edttel2: TEdit;
    lbltel3: TLabel;
    edttel3: TEdit;
    lblfax: TLabel;
    edtfax: TEdit;
    lblemail: TLabel;
    edtemail: TEdit;
    lblweb_adres: TLabel;
    edtweb_adres: TEdit;
    lblyetkili1: TLabel;
    edtyetkili1: TEdit;
    lblyetkili1_tel: TLabel;
    edtyetkili1_tel: TEdit;
    lblyetkili1_email: TLabel;
    edtyetkili1_email: TEdit;
    lblyetkili2: TLabel;
    edtyetkili2: TEdit;
    lblyetkili2_tel: TLabel;
    edtyetkili2_tel: TEdit;
    lblyetkili2_email: TLabel;
    edtyetkili2_email: TEdit;
    lblfirma_tipi_id: TLabel;
    edtfirma_tipi_id: TEdit;
    lblvergi_dairesi: TLabel;
    edtvergi_dairesi: TEdit;
    lblvergi_numarasi: TLabel;
    edtvergi_numarasi: TEdit;
    lbladres: TLabel;
    edtadres: TEdit;
    lblsehir_id: TLabel;
    edtsehir_id: TEdit;
    lblulke_id: TLabel;
    edtulke_id: TEdit;
    lblsevkiyat_yetkilisi: TLabel;
    edtsevkiyat_yetkilisi: TEdit;
    lblsevkiyat_yetkilisi_tel: TLabel;
    edtsevkiyat_yetkilisi_telefon: TEdit;
    lblcalisma_durumu_id: TLabel;
    lblis_ziyaret_edilmesin: TLabel;
    chkis_ziyaret_edilmesin: TCheckBox;
    lblcalistigi_tedarikciler: TLabel;
    mmocalistigi_tedarikciler: TMemo;
    lblfinans_durumu_id: TLabel;
    edtfinans_durumu_id: TEdit;
    lblkac_yillik_firma: TLabel;
    edtkac_yillik_firma: TEdit;
    lblyillik_asansor_sayisi: TLabel;
    edtyillik_asansor_sayisi: TEdit;
    lblnot1: TLabel;
    mmonot1: TMemo;
    lblnot2: TLabel;
    mmonot2: TMemo;
    lbl88: TLabel;
    mmonot3: TMemo;
    lblbolge_id: TLabel;
    edtbolge_id: TEdit;
    edtcalisma_durumu_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  public
    procedure Repaint; override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.BbkKayit
  , Ths.Erp.Database.Table.SetBbkFirmaTipi
  , ufrmSetBbkFirmaTipleri
  , ufrmSetBbkCalismaDurumlari
  , Ths.Erp.Database.Table.SetBbkCalismaDurumu
  , ufrmSetBbkFinansDurumlari
  , Ths.Erp.Database.Table.SetBbkFinansDurumu
  , ufrmBbkBolgeSehirler
  , Ths.Erp.Database.Table.BbkBolgeSehir
  ;

procedure TfrmBbkKayit.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TBbkKayit(Table).FirmaAdi.Value := edtfirma_adi.Text;
      TBbkKayit(Table).Tel1.Value := edttel1.Text;
      TBbkKayit(Table).Tel2.Value := edttel2.Text;
      TBbkKayit(Table).Tel3.Value := edttel3.Text;
      TBbkKayit(Table).Fax.Value := edtfax.Text;
      TBbkKayit(Table).Email.Value := edtemail.Text;
      TBbkKayit(Table).WebAdres.Value := edtweb_adres.Text;

      TBbkKayit(Table).Yetkili1.Value := edtyetkili1.Text;
      TBbkKayit(Table).Yetkili1Tel.Value := edtyetkili1_tel.Text;
      TBbkKayit(Table).Yetkili1Email.Value := edtyetkili1_email.Text;

      TBbkKayit(Table).Yetkili2.Value := edtyetkili2.Text;
      TBbkKayit(Table).Yetkili2Tel.Value := edtyetkili2_tel.Text;
      TBbkKayit(Table).Yetkili2Email.Value := edtyetkili2_email.Text;

      TBbkKayit(Table).FirmaTipi.Value := edtfirma_tipi_id.Text;
      TBbkKayit(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TBbkKayit(Table).VergiNumarasi.Value := edtvergi_numarasi.Text;

      TBbkKayit(Table).Adres.Value := edtadres.Text;
      TBbkKayit(Table).Sehir.Value := edtsehir_id.Text;
      TBbkKayit(Table).Ulke.Value := edtulke_id.Text;
      TBbkKayit(Table).Bolge.Value := edtbolge_id.Text;

      TBbkKayit(Table).SevkiyatYetkilisi.Value := edtsevkiyat_yetkilisi.Text;
      TBbkKayit(Table).SevkiyatYetkilisiTel.Value := edtsevkiyat_yetkilisi_telefon.Text;

      TBbkKayit(Table).CalismaDurumu.Value := edtcalisma_durumu_id.Text;
      TBbkKayit(Table).IsZiyaretEdilmesin.Value := chkis_ziyaret_edilmesin.Checked;

      TBbkKayit(Table).CalistigiTedarikciler.Value := mmocalistigi_tedarikciler.Lines.Text;

      TBbkKayit(Table).FinansDurumu.Value := edtfinans_durumu_id.Text;
      TBbkKayit(Table).KacYillikFirma.Value := edtkac_yillik_firma.Text;
      TBbkKayit(Table).YillikAsansorSayisi.Value := edtyillik_asansor_sayisi.Text;

      TBbkKayit(Table).Not1.Value := mmonot1.Lines.Text;
      TBbkKayit(Table).Not2.Value := mmonot2.Lines.Text;
      TBbkKayit(Table).Not3.Value := mmonot3.Lines.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmBbkKayit.FormCreate(Sender: TObject);
begin
  inherited;
  edtfirma_tipi_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;
  edtcalisma_durumu_id.OnHelperProcess := HelperProcess;
  edtfinans_durumu_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmBbkKayit.HelperProcess(Sender: TObject);
var
  LFrmFirma: TfrmSetBbkFirmaTipleri;
  LFrmSehir: TfrmBbkBolgeSehirler;
  LFrmCalisma: TfrmSetBbkCalismaDurumlari;
  LFrmFinans: TfrmSetBbkFinansDurumlari;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtfirma_tipi_id.Name then
      begin
        LFrmFirma := TfrmSetBbkFirmaTipleri.Create(TEdit(Sender), Self, TSetBbkFirmaTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmFirma.QryFiltreVarsayilan := ' AND ' + LFrmFirma.Table.TableName + '.' + TSetBbkFirmaTipi(LFrmFirma.Table).KayitTipiID.FieldName + '=' + VarToStr(FormatedVariantVal(TBbkKayit(Table).KayitTipiID));
          LFrmFirma.ShowModal;
          if LFrmFirma.CleanAndClose then
          begin
            TBbkKayit(Table).FirmaTipiID.Value := 0;
            TEdit(Sender).Clear;
          end
          else
          begin
            TBbkKayit(Table).FirmaTipiID.Value := TSetBbkFirmaTipi(LFrmFirma.Table).Id.Value;
            TEdit(Sender).Text := FormatedVariantVal(TSetBbkFirmaTipi(LFrmFirma.Table).FirmaTipi);
          end;
        finally
          LFrmFirma.Free;
        end;
      end
      else
      if TEdit(Sender).Name = edtsehir_id.Name then
      begin
        LFrmSehir := TfrmBbkBolgeSehirler.Create(TEdit(Sender), Self, TBbkBolgeSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmSehir.ShowModal;
          if LFrmSehir.CleanAndClose then
          begin
            TBbkKayit(Table).SehirID.Value := 0;
            TEdit(Sender).Clear;
            edtulke_id.Clear;
            edtbolge_id.Clear;
          end
          else
          begin
            TBbkKayit(Table).SehirID.Value := TBbkBolgeSehir(LFrmSehir.Table).Id.Value;
            TEdit(Sender).Text := FormatedVariantVal(TBbkBolgeSehir(LFrmSehir.Table).Sehir);
            edtulke_id.Text := FormatedVariantVal(TBbkBolgeSehir(LFrmSehir.Table).Ulke);
            edtbolge_id.Text := FormatedVariantVal(TBbkBolgeSehir(LFrmSehir.Table).Bolge);
          end;
        finally
          LFrmSehir.Free;
        end;
      end
      else
      if TEdit(Sender).Name = edtcalisma_durumu_id.Name then
      begin
        LFrmCalisma := TfrmSetBbkCalismaDurumlari.Create(TEdit(Sender), Self, TSetBbkCalismaDurumu.Create(Table.Database), fomNormal, True);
        try
          LFrmCalisma.ShowModal;
          if LFrmCalisma.CleanAndClose then
          begin
            TBbkKayit(Table).CalismaDurumuId.Value := 0;
            TEdit(Sender).Clear;
          end
          else
          begin
            TBbkKayit(Table).CalismaDurumuId.Value := TSetBbkCalismaDurumu(LFrmCalisma.Table).Id.Value;
            TEdit(Sender).Text := FormatedVariantVal(TSetBbkCalismaDurumu(LFrmCalisma.Table).CalismaDurumu);
          end;
        finally
          LFrmCalisma.Free;
        end;
      end
      else
      if TEdit(Sender).Name = edtfinans_durumu_id.Name then
      begin
        LFrmFinans := TfrmSetBbkFinansDurumlari.Create(TEdit(Sender), Self, TSetBbkFinansDurumu.Create(Table.Database), fomNormal, True);
        try
          LFrmFinans.ShowModal;
          if LFrmFinans.CleanAndClose then
          begin
            TBbkKayit(Table).FinansDurumuID.Value := 0;
            TEdit(Sender).Clear;
          end
          else
          begin
            TBbkKayit(Table).FinansDurumuID.Value := TSetBbkFinansDurumu(LFrmFinans.Table).Id.Value;
            TEdit(Sender).Text := FormatedVariantVal(TSetBbkFinansDurumu(LFrmFinans.Table).FinansDurumu);
          end;
        finally
          LFrmFinans.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmBbkKayit.RefreshData;
begin
   edtfirma_adi.Text := FormatedVariantVal(TBbkKayit(Table).FirmaAdi);
   edttel1.Text := FormatedVariantVal(TBbkKayit(Table).Tel1);
   edttel2.Text := FormatedVariantVal(TBbkKayit(Table).Tel2);
   edttel3.Text := FormatedVariantVal(TBbkKayit(Table).Tel3);
   edtfax.Text := FormatedVariantVal(TBbkKayit(Table).Fax);
   edtemail.Text := FormatedVariantVal(TBbkKayit(Table).Email);
   edtweb_adres.Text := FormatedVariantVal(TBbkKayit(Table).WebAdres);

   edtyetkili1.Text:= FormatedVariantVal(TBbkKayit(Table).Yetkili1);
   edtyetkili1_tel.Text := FormatedVariantVal(TBbkKayit(Table).Yetkili1Tel);
   edtyetkili1_email.Text := FormatedVariantVal(TBbkKayit(Table).Yetkili1Email);

   edtyetkili2.Text := FormatedVariantVal(TBbkKayit(Table).Yetkili2);
   edtyetkili2_tel.Text := FormatedVariantVal(TBbkKayit(Table).Yetkili2Tel);
   edtyetkili2_email.Text := FormatedVariantVal(TBbkKayit(Table).Yetkili2Email);

   edtfirma_tipi_id.Text := FormatedVariantVal(TBbkKayit(Table).FirmaTipi);
   edtvergi_dairesi.Text := FormatedVariantVal(TBbkKayit(Table).VergiDairesi);
   edtvergi_numarasi.Text := FormatedVariantVal(TBbkKayit(Table).VergiNumarasi);

   edtadres.Text := FormatedVariantVal(TBbkKayit(Table).Adres);
   edtsehir_id.Text := FormatedVariantVal(TBbkKayit(Table).Sehir);
   edtulke_id.Text := FormatedVariantVal(TBbkKayit(Table).Ulke);
   edtbolge_id.Text := FormatedVariantVal(TBbkKayit(Table).Bolge);

   edtsevkiyat_yetkilisi.Text := FormatedVariantVal(TBbkKayit(Table).SevkiyatYetkilisi);
   edtsevkiyat_yetkilisi_telefon.Text := FormatedVariantVal(TBbkKayit(Table).SevkiyatYetkilisiTel);
   edtcalisma_durumu_id.Text := FormatedVariantVal(TBbkKayit(Table).CalismaDurumu);
   chkis_ziyaret_edilmesin.Checked := FormatedVariantVal(TBbkKayit(Table).IsZiyaretEdilmesin);

   mmocalistigi_tedarikciler.Lines.Text := FormatedVariantVal(TBbkKayit(Table).CalistigiTedarikciler);

   edtfinans_durumu_id.Text := FormatedVariantVal(TBbkKayit(Table).FinansDurumu);
   edtkac_yillik_firma.Text := FormatedVariantVal(TBbkKayit(Table).KacYillikFirma);
   edtyillik_asansor_sayisi.Text := FormatedVariantVal(TBbkKayit(Table).YillikAsansorSayisi);

   mmonot1.Lines.Text := FormatedVariantVal(TBbkKayit(Table).Not1);
   mmonot2.Lines.Text := FormatedVariantVal(TBbkKayit(Table).Not2);
   mmonot3.Lines.Text := FormatedVariantVal(TBbkKayit(Table).Not3);
end;

procedure TfrmBbkKayit.Repaint;
begin
  inherited;
  edtulke_id.ReadOnly := True;
  edtbolge_id.ReadOnly := True;

  edtemail.CharCase := ecLowerCase;
  edtweb_adres.CharCase := ecLowerCase;
  edtyetkili1_email.CharCase := ecLowerCase;
  edtyetkili2_email.CharCase := ecLowerCase;
  mmonot1.CharCase := ecNormal;
  mmonot1.CharCase := ecNormal;
  mmonot2.CharCase := ecNormal;
  mmonot3.CharCase := ecNormal;
end;

end.
