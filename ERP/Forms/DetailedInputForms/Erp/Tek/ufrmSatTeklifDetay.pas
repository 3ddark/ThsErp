unit ufrmSatTeklifDetay;

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
  FireDAC.Comp.Client,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseDetaylarDetay,
  Ths.Erp.Database.Table;

type
  TfrmSatisTeklifDetay = class(TfrmBaseDetaylarDetay)
    lblstok_kodu: TLabel;
    lblstok_aciklama: TLabel;
    lblkullanici_aciklama: TLabel;
    lblfiyat: TLabel;
    lbliskonto_orani: TLabel;
    lblkdv_orani: TLabel;
    lblmiktar: TLabel;
    lblolcu_birimi: TLabel;
    lblgtip_no: TLabel;
    imgstok_resim: TImage;
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
    edtkdv_orani: TEdit;
    edtolcu_birimi: TEdit;
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure edtfiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtmiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtiskonto_oraniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbbkdv_oraniChange(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
  private
    FNetFiyat,
    FTutar,
    FNetTutar,
    FIskontoTutar,
    FKDVTutar,
    FToplamTutar: Double;

    procedure CalculateTotals();
  public
    procedure ClearTotalLabels;
  published
    procedure HelperProcess(Sender: TObject);
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SatTeklif, ufrmSatTeklifDetaylar,
  Ths.Erp.Database.Table.SysOlcuBirimi, ufrmSysOlcuBirimleri,
  Ths.Erp.Database.Table.SysParaBirimi, ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.SetChVergiOrani, ufrmSetChVergiOranlari,
  Ths.Erp.Database.Table.StkStokKarti, ufrmStkStokKartlari;

{$R *.dfm}

procedure TfrmSatisTeklifDetay.CalculateTotals();
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

  if edtkdv_orani.Text <> '' then
    vKDVOrani := StrToFloatDef(edtkdv_orani.Text, 0);

  if ((edtFiyat.Text <> '') and (edtMiktar.Text <> '') ) then
  begin
    FTutar := vFiyat * vMiktar;
    FNetFiyat := vFiyat * ((100-vIskontoOrani)/100);
    FNetTutar := FNetFiyat * vMiktar;
    FIskontoTutar := FTutar - FNetTutar;
    FKDVTutar := FNetTutar * (vKDVOrani)/100;
    FToplamTutar := FNetTutar + FKDVTutar;

    lblnet_fiyat_val.Caption := FloatToStrF(FNetFiyat, TFloatFormat.ffFixed, 10, GSysOndalikHane.SatisMiktar.Value);
    lbltutar_val.Caption := FloatToStrF(FTutar, TFloatFormat.ffFixed, 10, GSysOndalikHane.SatisMiktar.Value);
    lbliskonto_tutar_val.Caption := FloatToStrF(FIskontoTutar, TFloatFormat.ffFixed, 10, GSysOndalikHane.SatisMiktar.Value);
    lblnet_tutar_val.Caption := FloatToStrF(FNetTutar, TFloatFormat.ffFixed, 10, GSysOndalikHane.SatisMiktar.Value);
    lblkdv_tutar_val.Caption := FloatToStrF(FKDVTutar, TFloatFormat.ffFixed, 10, GSysOndalikHane.SatisMiktar.Value);
    lbltoplam_tutar_val.Caption := FloatToStrF(FToplamTutar, TFloatFormat.ffFixed, 10, GSysOndalikHane.SatisMiktar.Value);
  end;
end;

procedure TfrmSatisTeklifDetay.cbbkdv_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatisTeklifDetay.ClearTotalLabels;
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
    if (TfrmSatTeklifDetaylar(ParentForm).Table as TSatTeklif).ParaBirimi.Value = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.Value then
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

procedure TfrmSatisTeklifDetay.edtfiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatisTeklifDetay.edtiskonto_oraniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatisTeklifDetay.edtmiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmSatisTeklifDetay.FormCreate(Sender: TObject);
begin
  inherited;

  ClearTotalLabels;
end;

procedure TfrmSatisTeklifDetay.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;
  edtkdv_orani.OnHelperProcess := HelperProcess;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    edtkdv_orani.Text := '18';
  end;
end;

procedure TfrmSatisTeklifDetay.HelperProcess(Sender: TObject);
var
  LFrmStk: TfrmStkStokKartlari;
  LFrmVergi: TfrmSetChVergiOranlari;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LFrmStk := TfrmStkStokKartlari.Create(edtstok_kodu, Self, TStkStokKarti.Create(Table.Database), fomNormal, True);
        try
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
              edtstok_kodu.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).StokKodu);
              edtstok_aciklama.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).StokAdi);
              edtfiyat.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).SatisFiyat);
              edtolcu_birimi.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).OlcuBirimi);

              if (Trim(edtiskonto_orani.Text) = '') then  edtiskonto_orani.Text := '0';

              TSatTeklifDetay(Table).StokResim.Value := TStkStokKarti(LFrmStk.Table).StokResim.Value;
              LoadImageFromDB(TStkStokKarti(LFrmStk.Table).StokResim, imgstok_resim);
              edtgtip_no.Text := FormatedVariantVal(TStkStokKarti(LFrmStk.Table).GtipNo);
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
            else  TEdit(Sender).Text := FormatedVariantVal(TSetChVergiOrani(LFrmVergi.Table).VergiOrani);
          end;
        finally
          LFrmVergi.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmSatisTeklifDetay.RefreshData();
begin
  edtstok_kodu.Text := FormatedVariantVal(TSatTeklifDetay(Table).StokKodu);
  edtstok_aciklama.Text := FormatedVariantVal(TSatTeklifDetay(Table).StokAciklama);
  edtfiyat.Text := FormatedVariantVal(TSatTeklifDetay(Table).Fiyat);
  edtmiktar.Text := FormatedVariantVal(TSatTeklifDetay(Table).Miktar);
  edtolcu_birimi.Text := FormatedVariantVal(TSatTeklifDetay(Table).OlcuBirimi);
  edtiskonto_orani.Text := FormatedVariantVal(TSatTeklifDetay(Table).IskontoOrani);
  edtkdv_orani.Text := FormatedVariantVal(TSatTeklifDetay(Table).KdvOrani);
  edtgtip_no.Text := FormatedVariantVal(TSatTeklifDetay(Table).GtipNo);
  edtkullanici_aciklama.Text := FormatedVariantVal(TSatTeklifDetay(Table).KullaniciAciklama);

  CalculateTotals;

  if Length(FormatedVariantVal(TSatTeklifDetay(Table).StokResim)) > 10 then
    LoadImageFromDB(TSatTeklifDetay(Table).StokResim, imgstok_resim);
end;

procedure TfrmSatisTeklifDetay.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSatTeklifDetay(Table).SiparisDetayID.Value := 0;
      TSatTeklifDetay(Table).IrsaliyeDetayID.Value := 0;
      TSatTeklifDetay(Table).FaturaDetayID.Value := 0;

      TSatTeklifDetay(Table).StokKodu.Value := edtstok_kodu.Text;
      TSatTeklifDetay(Table).StokAciklama.Value := edtstok_aciklama.Text;
      TSatTeklifDetay(Table).KullaniciAciklama.Value := edtkullanici_aciklama.Text;
      TSatTeklifDetay(Table).Referans.Value := '';
      TSatTeklifDetay(Table).Miktar.Value := edtMiktar.Text;
      TSatTeklifDetay(Table).OlcuBirimi.Value := edtolcu_birimi.Text;

      TSatTeklifDetay(Table).IskontoOrani.Value := edtiskonto_orani.Text;
      TSatTeklifDetay(Table).KdvOrani.Value := edtkdv_orani.Text;
      TSatTeklifDetay(Table).Fiyat.Value := edtFiyat.Text;
      TSatTeklifDetay(Table).NetFiyat.Value := FNetFiyat;
      TSatTeklifDetay(Table).Tutar.Value := FTutar;
      TSatTeklifDetay(Table).IskontoTutar.Value := FIskontoTutar;
      TSatTeklifDetay(Table).NetTutar.Value := FNetTutar;
      TSatTeklifDetay(Table).KdvTutar.Value := FKDVTutar;
      TSatTeklifDetay(Table).ToplamTutar.Value := FToplamTutar;

      TSatTeklifDetay(Table).IsAnaUrun.Value := False;
      TSatTeklifDetay(Table).AnaUrunID.Value := 0;
      TSatTeklifDetay(Table).ReferansAnaUrunID.Value := 0;

      TSatTeklifDetay(Table).VergiKodu.Value := '';
      TSatTeklifDetay(Table).VergiMuafiyetKodu.Value := '';
      TSatTeklifDetay(Table).DigerVergiKodu.Value := '';
      TSatTeklifDetay(Table).GtipNo.Value := edtgtip_no.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
