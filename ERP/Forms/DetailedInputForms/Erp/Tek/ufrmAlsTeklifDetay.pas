unit ufrmAlsTeklifDetay;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.DateUtils, System.NetEncoding,
  System.Math, System.Types, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.Buttons, Vcl.AppEvnts,
  Vcl.Samples.Spin, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo, ufrmBase,
  ufrmBaseDetaylarDetay, Ths.Database.Table, Ths.Globals;

type
  TfrmAlsTeklifDetay = class(TfrmBaseDetaylarDetay)
    lblstok_kodu: TLabel;
    lblstok_aciklama: TLabel;
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
    PanelBilgilendirme: TPanel;
    lbltutar: TLabel;
    lbltutar_val: TLabel;
    lbliskonto_tutar: TLabel;
    lbliskonto_tutar_val: TLabel;
    lblkdv_tutar: TLabel;
    lblkdv_tutar_val: TLabel;
    lbltoplam_tutar: TLabel;
    lbltoplam_tutar_val: TLabel;
    lblnet_fiyat: TLabel;
    lblnet_fiyat_val: TLabel;
    lblnet_tutar: TLabel;
    lblnet_tutar_val: TLabel;
    edtkdv_orani: TEdit;
    edtolcu_birimi: TEdit;
    lblkullanici_aciklama: TLabel;
    edtkullanici_aciklama: TEdit;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure edtiskonto_oraniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbbkdv_oraniChange(Sender: TObject);
    procedure FormShow(Sender: TObject); override;
    procedure edtfiyatExit(Sender: TObject);
    procedure edtmiktarExit(Sender: TObject);
    procedure edtiskonto_oraniExit(Sender: TObject);
    procedure edtkdv_oraniExit(Sender: TObject);
    procedure edtfiyatChange(Sender: TObject);
    procedure edtmiktarChange(Sender: TObject);
    procedure edtiskonto_oraniChange(Sender: TObject);
    procedure edtkdv_oraniChange(Sender: TObject);      
  private
    FTotal: TTotal;

    procedure CalculateTotals;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean;
      override;
  public
    procedure ClearTotalLabels;
  published
    procedure HelperProcess(Sender: TObject);
  end;

implementation

uses
  Ths.Constants, Ths.Utils.Images,
  Ths.Database.Table.AlsTeklifler, ufrmAlsTeklifDetaylar,
  Ths.Database.Table.SysOlcuBirimleri, ufrmSysOlcuBirimleri,
  Ths.Database.Table.SysParaBirimleri, ufrmSysParaBirimleri,
  Ths.Database.Table.SetChVergiOranlari, ufrmSetChVergiOranlari,
  Ths.Database.Table.StkKartlar, ufrmStkKartlar;

{$R *.dfm}

procedure TfrmAlsTeklifDetay.CalculateTotals();
var
  LFiyat, LMiktar, LIskontoOrani, LKDVOrani: Double;
begin
  LFiyat := 0;
  LMiktar := 0;
  LIskontoOrani := 0;
  LKDVOrani := 0;

  if edtFiyat.Text <> '' then
    LFiyat := edtFiyat.moneyToDouble;

  if edtMiktar.Text <> '' then
    LMiktar := edtMiktar.moneyToDouble;

  if edtiskonto_orani.Text <> '' then
    LIskontoOrani  := StrToFloatDef(edtiskonto_orani.Text, 0);

  if edtkdv_orani.Text <> '' then
    LKDVOrani := StrToFloatDef(edtkdv_orani.Text, 0);

  if ((edtFiyat.Text <> '') and (edtMiktar.Text <> '') ) then
  begin
    FTotal := CalculateTotalValues(LFiyat, LMiktar, LIskontoOrani, LKDVOrani);
    lblnet_fiyat_val.Caption := FloatToStrF(FTotal.NetFiyat, ffCurrency, 10, GSysOndalikHane.Miktar.AsInteger);
    lbltutar_val.Caption := FloatToStrF(FTotal.Tutar, ffCurrency, 10, GSysOndalikHane.Miktar.AsInteger);
    lbliskonto_tutar_val.Caption := FloatToStrF(FTotal.IskontoTutar, ffCurrency, 10, GSysOndalikHane.Miktar.AsInteger);
    lblnet_tutar_val.Caption := FloatToStrF(FTotal.NetTutar, ffCurrency, 10, GSysOndalikHane.Miktar.AsInteger);
    lblkdv_tutar_val.Caption := FloatToStrF(FTotal.KDVTutar, ffCurrency, 10, GSysOndalikHane.Miktar.AsInteger);
    lbltoplam_tutar_val.Caption := FloatToStrF(FTotal.ToplamTutar, ffCurrency, 10, GSysOndalikHane.Miktar.AsInteger);
  end;
end;

procedure TfrmAlsTeklifDetay.cbbkdv_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.ClearTotalLabels;
var
  n1: Integer;
  LFmt: TFormatSettings;
begin
  LFmt := FormatSettings;
  for n1 := 0 to GParaBirimi.List.Count-1 do
    if TfrmAlsTeklifDetaylar(ParentForm).edtpara_birimi.Text = TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString then
    begin
      LFmt.CurrencyString := TSysParaBirimi(GParaBirimi.List[n1]).Sembol.AsString;
      Break;
    end;

  lblnet_fiyat_val.Caption := FloatToStrF(0, ffCurrency, 10, 2, LFmt);
  lbltutar_val.Caption := FloatToStrF(0, ffCurrency, 10, 2, LFmt);
  lbliskonto_tutar_val.Caption := FloatToStrF(0, ffCurrency, 10, 2, LFmt);
  lblnet_tutar_val.Caption := FloatToStrF(0, ffCurrency, 10, 2, LFmt);
  lblkdv_tutar_val.Caption := FloatToStrF(0, ffCurrency, 10, 2, LFmt);
  lbltoplam_tutar_val.Caption := FloatToStrF(0, ffCurrency, 10, 2, LFmt);
end;

procedure TfrmAlsTeklifDetay.edtfiyatChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtfiyatExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtiskonto_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtiskonto_oraniExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtiskonto_oraniKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtkdv_oraniChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtkdv_oraniExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtmiktarChange(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.edtmiktarExit(Sender: TObject);
begin
  inherited;
  CalculateTotals;
end;

procedure TfrmAlsTeklifDetay.FormShow(Sender: TObject);
begin
  edtstok_kodu.OnHelperProcess := HelperProcess;
  edtkdv_orani.OnHelperProcess := HelperProcess;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    ClearTotalLabels;
    edtkdv_orani.Text := '18';
  end;
end;

procedure TfrmAlsTeklifDetay.HelperProcess(Sender: TObject);
var
  LFrmStk: TfrmStkKartlar;
  LStk: TStkKart;
  LFrmVergi: TfrmSetChVergiOranlari;
  LStokParaVarsayilan: Boolean;
  n1: Integer;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtstok_kodu.Name then
      begin
        LStk := TStkKart.Create(GDataBase);
        LFrmStk := TfrmStkKartlar.Create(TEdit(Sender), Self, LStk, fomNormal, True);
        try
          LFrmStk.QryFiltreVarsayilan := ' AND ' + LStk.IsSatilabilir.FieldName + '=True';
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
              edtstok_kodu.Text := TStkKart(LFrmStk.Table).StokKodu.AsString;
              edtstok_aciklama.Text := TStkKart(LFrmStk.Table).StokAdi.AsString;

              LStokParaVarsayilan := False;

              for n1 := 0 to GParaBirimi.List.Count-1 do
                if  (TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = TStkKart(LFrmStk.Table).SatisPara.AsString)
                and (TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString)
                then
                begin
                  LStokParaVarsayilan := True;
                  Break;
                end;

              for n1 := 0 to GParaBirimi.List.Count-1 do
                if TfrmAlsTeklifDetaylar(ParentForm).edtpara_birimi.Text = TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString then
                begin
                  if TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString then
                  begin
                    if LStokParaVarsayilan then
                      edtfiyat.Text := TStkKart(LFrmStk.Table).SatisFiyat.AsString
                    else
                      edtfiyat.Text := FloatToStr(TStkKart(LFrmStk.Table).SatisFiyat.AsFloat * TfrmAlsTeklifDetaylar(ParentForm).edtdoviz_kuru_usd.moneyToDouble);
                  end
                  else
                  begin
                    if LStokParaVarsayilan then
                      edtfiyat.Text := FloatToStr(TStkKart(LFrmStk.Table).SatisFiyat.AsFloat / TfrmAlsTeklifDetaylar(ParentForm).edtdoviz_kuru_usd.moneyToDouble)
                    else
                      edtfiyat.Text := FloatToStr(TStkKart(LFrmStk.Table).SatisFiyat.AsFloat * TfrmAlsTeklifDetaylar(ParentForm).edtdoviz_kuru_usd.moneyToDouble);
                  end;

                  break;
                end;

              edtolcu_birimi.Text := TStkKart(LFrmStk.Table).OlcuBirimi.AsString;

              if (Trim(edtiskonto_orani.Text) = '') then  edtiskonto_orani.Text := '0';

              TAlsTeklifDetay(Table).StokResim.Value := TStkKart(LFrmStk.Table).Resim.Value;
              TImageProcess.LoadImageFromDB(TStkKart(LFrmStk.Table).Resim, imgstok_resim);
              edtgtip_no.Text := TStkKart(LFrmStk.Table).GtipNo.AsString;
            end;
          end;
        finally
          LFrmStk.Free;
        end;
      end
      else if TEdit(Sender).Name = edtkdv_orani.Name then
      begin
        LFrmVergi := TfrmSetChVergiOranlari.Create(TEdit(Sender), Self, TSetChVergiOrani.Create(Table.Database), fomNormal, True);
        try
          LFrmVergi.ShowModal;
          if LFrmVergi.DataAktar then
          begin
            if LFrmVergi.CleanAndClose
            then  TEdit(Sender).Clear
            else  TEdit(Sender).Text := TSetChVergiOrani(LFrmVergi.Table).VergiOrani.AsString;
          end;
        finally
          LFrmVergi.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmAlsTeklifDetay.RefreshData();
begin
  edtstok_kodu.Text := TAlsTeklifDetay(Table).StokKodu.AsString;
  edtstok_aciklama.Text := TAlsTeklifDetay(Table).StokAciklama.AsString;
  edtfiyat.Text := TAlsTeklifDetay(Table).Fiyat.AsString;
  edtmiktar.Text := TAlsTeklifDetay(Table).Miktar.AsString;
  edtolcu_birimi.Text := TAlsTeklifDetay(Table).OlcuBirimi.AsString;
  edtiskonto_orani.Text := TAlsTeklifDetay(Table).IskontoOrani.AsString;
  edtkdv_orani.Text := TAlsTeklifDetay(Table).KdvOrani.AsString;
  edtgtip_no.Text := TAlsTeklifDetay(Table).GtipNo.AsString;
  edtkullanici_aciklama.Text := TAlsTeklifDetay(Table).KullaniciAciklama.AsString;

  CalculateTotals;

  if Length(TAlsTeklifDetay(Table).StokResim.AsString) > 10 then
    TImageProcess.LoadImageFromDB(TAlsTeklifDetay(Table).StokResim, imgstok_resim);
end;

function TfrmAlsTeklifDetay.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);
end;

procedure TfrmAlsTeklifDetay.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TAlsTeklifDetay(Table).SiparisDetayID.Value := 0;
      TAlsTeklifDetay(Table).IrsaliyeDetayID.Value := 0;
      TAlsTeklifDetay(Table).FaturaDetayID.Value := 0;

      TAlsTeklifDetay(Table).StokKodu.Value := edtstok_kodu.Text;
      TAlsTeklifDetay(Table).StokAciklama.Value := edtstok_aciklama.Text;
      TAlsTeklifDetay(Table).Referans.Value := '';
      TAlsTeklifDetay(Table).Miktar.Value := edtMiktar.Text;
      TAlsTeklifDetay(Table).OlcuBirimi.Value := edtolcu_birimi.Text;

      TAlsTeklifDetay(Table).IskontoOrani.Value := edtiskonto_orani.Text;
      TAlsTeklifDetay(Table).KdvOrani.Value := edtkdv_orani.Text;
      TAlsTeklifDetay(Table).Fiyat.Value := edtFiyat.moneyToDouble;
      TAlsTeklifDetay(Table).NetFiyat.Value := FTotal.NetFiyat;
      TAlsTeklifDetay(Table).Tutar.Value := FTotal.Tutar;
      TAlsTeklifDetay(Table).IskontoTutar.Value := FTotal.IskontoTutar;
      TAlsTeklifDetay(Table).NetTutar.Value := FTotal.NetTutar;
      TAlsTeklifDetay(Table).KdvTutar.Value := FTotal.KDVTutar;
      TAlsTeklifDetay(Table).ToplamTutar.Value := FTotal.ToplamTutar;

      TAlsTeklifDetay(Table).IsAnaUrun.Value := False;
      TAlsTeklifDetay(Table).ReferansAnaUrunID.Value := 0;

      TAlsTeklifDetay(Table).GtipNo.Value := edtgtip_no.Text;
      TAlsTeklifDetay(Table).KullaniciAciklama.Value := edtkullanici_aciklama.Text;

      (TfrmAlsTeklifDetaylar(ParentForm).Table as TAlsTeklif).ValidateDetay(TAlsTeklifDetay(Table));

      inherited;
    end;
  end
  else
    inherited;
end;

end.
