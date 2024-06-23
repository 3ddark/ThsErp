unit ufrmBbkKayit;

interface

{$I Ths.inc}

uses
  Windows,
  System.Classes,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.Samples.Spin,
  Vcl.ExtCtrls,
  Ths.Helper.Edit,
  ufrmBase,
  ufrmBaseInputDB;

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
    lblweb: TLabel;
    edtweb: TEdit;
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
    lblsehir_adi_id: TLabel;
    edtsehir_adi_id: TEdit;
    lblulke_adi_id: TLabel;
    edtulke_adi_id: TEdit;
    lblsevkiyat_yetkilisi: TLabel;
    edtsevkiyat_yetkilisi: TEdit;
    lblsevkiyat_yetkilisi_tel: TLabel;
    edtsevkiyat_yetkilisi_telefon: TEdit;
    lblcalisma_durumu_id: TLabel;
    lblfinans_durumu_id: TLabel;
    edtfinans_durumu_id: TEdit;
    lblkac_yillik_firma: TLabel;
    edtkac_yillik_firma: TEdit;
    lblnot1: TLabel;
    mmonot1: TMemo;
    lblnot2: TLabel;
    mmonot2: TMemo;
    lblbolge_adi_id: TLabel;
    edtbolge_adi_id: TEdit;
    edtcalisma_durumu_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  public
    procedure Repaint; override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

uses
  Ths.Globals,
  Ths.Database.Table.BbkKayit,
  Ths.Database.Table.SysSehirler, ufrmSysSehirler,
  Ths.Database.Table.SetBbkFirmaTipi, ufrmSetBbkFirmaTipleri,
  Ths.Database.Table.SetBbkCalismaDurumu, ufrmSetBbkCalismaDurumlari,
  Ths.Database.Table.SetBbkFinansDurumu, ufrmSetBbkFinansDurumlari;

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
      TBbkKayit(Table).Web.Value := edtweb.Text;

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
      TBbkKayit(Table).Sehir.Value := edtsehir_adi_id.Text;
      TBbkKayit(Table).Ulke.Value := edtulke_adi_id.Text;
      TBbkKayit(Table).Bolge.Value := edtbolge_adi_id.Text;

      TBbkKayit(Table).SevkiyatYetkilisi.Value := edtsevkiyat_yetkilisi.Text;
      TBbkKayit(Table).SevkiyatYetkilisiTel.Value := edtsevkiyat_yetkilisi_telefon.Text;

      TBbkKayit(Table).CalismaDurumu.Value := edtcalisma_durumu_id.Text;

      TBbkKayit(Table).FinansDurumu.Value := edtfinans_durumu_id.Text;
      TBbkKayit(Table).KacYillikFirma.Value := edtkac_yillik_firma.Text;

      TBbkKayit(Table).Not1.Value := mmonot1.Lines.Text;
      TBbkKayit(Table).Not2.Value := mmonot2.Lines.Text;
      
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
  edtsehir_adi_id.OnHelperProcess := HelperProcess;
  edtcalisma_durumu_id.OnHelperProcess := HelperProcess;
  edtfinans_durumu_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmBbkKayit.HelperProcess(Sender: TObject);
var
  LFrmSehir: TfrmSysSehirler;
  LFrmFirma: TfrmSetBbkFirmaTipleri;
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
          LFrmFirma.ShowModal;
          if LFrmFirma.DataAktar then
          begin
            if LFrmFirma.CleanAndClose then
            begin
              TBbkKayit(Table).FirmaTipiID.Value := 0;
              TEdit(Sender).Clear;
            end
            else
            begin
              TBbkKayit(Table).FirmaTipiID.Value := TSetBbkFirmaTipi(LFrmFirma.Table).Id.Value;
              TEdit(Sender).Text := TSetBbkFirmaTipi(LFrmFirma.Table).FirmaTipi.AsString;
            end;
          end;
        finally
          LFrmFirma.Free;
        end;
      end
      else
      if TEdit(Sender).Name = edtsehir_adi_id.Name then
      begin
        LFrmSehir := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmSehir.ShowModal;
          if LFrmSehir.DataAktar then
          begin
            if LFrmSehir.CleanAndClose then
            begin
              TBbkKayit(Table).SehirID.Value := 0;
              TBbkKayit(Table).UlkeID.Value := 0;
              TBbkKayit(Table).BolgeID.Value := 0;
              TEdit(Sender).Clear;
              edtulke_adi_id.Clear;
              edtbolge_adi_id.Clear;
            end
            else
            begin
              TEdit(Sender).Text := TSysSehir(LFrmSehir.Table).Sehir.AsString;
              edtulke_adi_id.Text := TSysSehir(LFrmSehir.Table).UlkeAdi.AsString;
              edtbolge_adi_id.Text := TSysSehir(LFrmSehir.Table).Bolge.AsString;
              TBbkKayit(Table).SehirID.Value := TSysSehir(LFrmSehir.Table).Id.Value;
              TBbkKayit(Table).UlkeID.Value := TSysSehir(LFrmSehir.Table).UlkeID.Value;
              TBbkKayit(Table).BolgeID.Value := TSysSehir(LFrmSehir.Table).BolgeID.Value;
            end;
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
          if LFrmCalisma.DataAktar then
          begin
            if LFrmCalisma.CleanAndClose then
            begin
              TBbkKayit(Table).CalismaDurumuId.Value := 0;
              TEdit(Sender).Clear;
            end
            else
            begin
              TBbkKayit(Table).CalismaDurumuId.Value := TSetBbkCalismaDurumu(LFrmCalisma.Table).Id.Value;
              TEdit(Sender).Text := TSetBbkCalismaDurumu(LFrmCalisma.Table).CalismaDurumu.AsString;
            end;
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
          if LFrmFinans.DataAktar then
          begin
            if LFrmFinans.CleanAndClose then
            begin
              TBbkKayit(Table).FinansDurumuID.Value := 0;
              TEdit(Sender).Clear;
            end
            else
            begin
              TBbkKayit(Table).FinansDurumuID.Value := TSetBbkFinansDurumu(LFrmFinans.Table).Id.Value;
              TEdit(Sender).Text := TSetBbkFinansDurumu(LFrmFinans.Table).FinansDurumu.AsString;
            end;
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
  edtfirma_adi.Text := TBbkKayit(Table).FirmaAdi.AsString;
  edttel1.Text := TBbkKayit(Table).Tel1.AsString;
  edttel2.Text := TBbkKayit(Table).Tel2.AsString;
  edttel3.Text := TBbkKayit(Table).Tel3.AsString;
  edtfax.Text := TBbkKayit(Table).Fax.AsString;
  edtemail.Text := TBbkKayit(Table).Email.AsString;
  edtweb.Text := TBbkKayit(Table).Web.AsString;

  edtyetkili1.Text:= TBbkKayit(Table).Yetkili1.AsString;
  edtyetkili1_tel.Text := TBbkKayit(Table).Yetkili1Tel.AsString;
  edtyetkili1_email.Text := TBbkKayit(Table).Yetkili1Email.AsString;

  edtyetkili2.Text := TBbkKayit(Table).Yetkili2.AsString;
  edtyetkili2_tel.Text := TBbkKayit(Table).Yetkili2Tel.AsString;
  edtyetkili2_email.Text := TBbkKayit(Table).Yetkili2Email.AsString;

  edtfirma_tipi_id.Text := TBbkKayit(Table).FirmaTipi.AsString;
  edtvergi_dairesi.Text := TBbkKayit(Table).VergiDairesi.AsString;
  edtvergi_numarasi.Text := TBbkKayit(Table).VergiNumarasi.AsString;

  edtadres.Text := TBbkKayit(Table).Adres.AsString;
  edtsehir_adi_id.Text := TBbkKayit(Table).Sehir.AsString;
  edtulke_adi_id.Text := TBbkKayit(Table).Ulke.AsString;
  edtbolge_adi_id.Text := TBbkKayit(Table).Bolge.AsString;

  edtsevkiyat_yetkilisi.Text := TBbkKayit(Table).SevkiyatYetkilisi.AsString;
  edtsevkiyat_yetkilisi_telefon.Text := TBbkKayit(Table).SevkiyatYetkilisiTel.AsString;
  edtcalisma_durumu_id.Text := TBbkKayit(Table).CalismaDurumu.AsString;

  edtfinans_durumu_id.Text := TBbkKayit(Table).FinansDurumu.AsString;
  edtkac_yillik_firma.Text := TBbkKayit(Table).KacYillikFirma.AsString;

  mmonot1.Lines.Text := TBbkKayit(Table).Not1.AsString;
  mmonot2.Lines.Text := TBbkKayit(Table).Not2.AsString;
end;

procedure TfrmBbkKayit.Repaint;
begin
  inherited;
  edtulke_adi_id.ReadOnly := True;
  edtbolge_adi_id.ReadOnly := True;

  edtemail.CharCase := ecLowerCase;
  edtweb.CharCase := ecLowerCase;
  edtyetkili1_email.CharCase := ecLowerCase;
  edtyetkili2_email.CharCase := ecLowerCase;
  mmonot1.CharCase := ecNormal;
  mmonot1.CharCase := ecNormal;
  mmonot2.CharCase := ecNormal;
end;

end.
