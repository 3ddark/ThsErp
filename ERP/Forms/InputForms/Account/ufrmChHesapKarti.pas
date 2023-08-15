unit ufrmChHesapKarti;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, System.UITypes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus, Vcl.Samples.Spin, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  ufrmBase, ufrmBaseInputDB, Ths.Database.Table.ChHesapPlanlari, Ths.Constants;

type
  TfrmHesapKarti = class(TfrmBaseInputDB)
    lblhesap_kodu: TLabel;
    lblhesap_ismi: TLabel;
    lblhesap_grubu_id: TLabel;
    lblmukellef_tipi_id: TLabel;
    lblmukellef_adi: TLabel;
    lblmukellef_ikinci_adi: TLabel;
    lblmukellef_soyadi: TLabel;
    lblvergi_dairesi: TLabel;
    lblvergi_no: TLabel;
    lblnace_kodu: TLabel;
    lblpara_birimi: TLabel;
    lblbolge_id: TLabel;
    lbliban: TLabel;
    lblis_efatura_hesabi: TLabel;
    lblmuhasebe_kodu: TLabel;
    lblefatura_pk_name: TLabel;
    tsAdres: TTabSheet;
    lblbina_adi: TLabel;
    lblsokak: TLabel;
    lblcadde: TLabel;
    lblmahalle: TLabel;
    lblilce: TLabel;
    lblsehir_id: TLabel;
    lblulke_id: TLabel;
    lblposta_kodu: TLabel;
    lblkapi_no: TLabel;
    tsIletisim: TTabSheet;
    lblyetkili2: TLabel;
    lblyetkili1: TLabel;
    lblfaks: TLabel;
    lblmuhasebe_telefon: TLabel;
    lblmuhasebe_eposta: TLabel;
    lblyetkili2_tel: TLabel;
    lblyetkili1_tel: TLabel;
    lblozel_bilgi: TLabel;
    lblmuhasebe_yetkili: TLabel;
    lblyetkili3: TLabel;
    lblyetkili3_tel: TLabel;
    edtyetkili1: TEdit;
    edtyetkili1_tel: TEdit;
    edtyetkili2: TEdit;
    edtyetkili2_tel: TEdit;
    edtyetkili3: TEdit;
    edtyetkili3_tel: TEdit;
    edtfaks: TEdit;
    edtmuhasebe_telefon: TEdit;
    edtmuhasebe_eposta: TEdit;
    edtmuhasebe_yetkili: TEdit;
    mmoozel_bilgi: TMemo;
    edtkok_hesap_kodu: TEdit;
    lblspl1: TLabel;
    lblspl2: TLabel;
    cbbara_hesap_kodu: TComboBox;
    cbbson_hesap_kodu: TComboBox;
    edthesap_kodu: TEdit;
    edthesap_ismi: TEdit;
    edtvergi_dairesi: TEdit;
    edtvergi_no: TEdit;
    edtmukellef_adi: TEdit;
    edtmukellef_ikinci_adi: TEdit;
    edtmukellef_soyadi: TEdit;
    edtiban: TEdit;
    chkis_efatura_hesabi: TCheckBox;
    edtnace_kodu: TEdit;
    edtefatura_pk_name: TEdit;
    edtilce: TEdit;
    edtmahalle: TEdit;
    edtcadde: TEdit;
    edtsokak: TEdit;
    edtbina_adi: TEdit;
    edtkapi_no: TEdit;
    edtposta_kodu: TEdit;
    lblis_pasif: TLabel;
    chkis_pasif: TCheckBox;
    lblhesap_iskonto: TLabel;
    edthesap_iskonto: TEdit;
    edthesap_grubu_id: TEdit;
    edtbolge_id: TEdit;
    edtpara_birimi: TEdit;
    edtiban_para: TEdit;
    edtmukellef_tipi_id: TEdit;
    edtulke_id: TEdit;
    edtsehir_id: TEdit;
    lblsemt: TLabel;
    edtsemt: TEdit;
    lblweb_site: TLabel;
    lblemail: TLabel;
    edtweb_site: TEdit;
    edtemail: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData(); override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure edtkok_hesap_koduExit(Sender: TObject);
    procedure cbbara_hesap_koduExit(Sender: TObject);
    procedure cbbson_hesap_koduExit(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
  private
    FSetChHesapPlani: TChHesapPlani;

    function getHesapKodu: string;
    function getAraHesapKodu: string;
    procedure fillAraHesapNumbers;
    procedure fillSonHesapNumbers(pKokHesap, pAraHesapKodu: string);
    procedure ShowHideMukellefTipi;
  public
    procedure Repaint; override;
  protected
    procedure HelperProcess(Sender: TObject); override;
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table, Ths.Database.Table.ChHesapKarti,
  Ths.Database.Table.ChHesapKartiAra, ufrmChHesapKartlariAra,
  Ths.Database.Table.ChGruplar, ufrmChGruplar, Ths.Database.Table.EmpEmployee,
  Ths.Database.Table.ChBolgeler, ufrmChBolgeler,
  Ths.Database.Table.SysVergiMukellefTipleri, ufrmSysVergiMukellefTipleri,
  Ths.Database.Table.SysUlkeler, ufrmSysUlkeler, Ths.Database.Table.SysSehirler,
  ufrmSysSehirler, Ths.Database.Table.SysParaBirimleri, ufrmSysParaBirimleri,
  Ths.Database.Table.SysAdresler;

{$R *.dfm}

procedure TfrmHesapKarti.cbbara_hesap_koduExit(Sender: TObject);
begin
  inherited;
  edthesap_kodu.Text := getHesapKodu;
end;

procedure TfrmHesapKarti.cbbson_hesap_koduExit(Sender: TObject);
begin
  inherited;
  edthesap_kodu.Text := getHesapKodu;
end;

procedure TfrmHesapKarti.edtkok_hesap_koduExit(Sender: TObject);
begin
  inherited;
  edthesap_kodu.Text := getHesapKodu;
end;

procedure TfrmHesapKarti.fillAraHesapNumbers;
var
  n1: Integer;
  LAraKodlar: TStringList;
begin
  cbbara_hesap_kodu.Clear;
  try
    cbbara_hesap_kodu.Items.BeginUpdate;
    for n1 := 1 to 250 do
      cbbara_hesap_kodu.Items.Add(Format('%.*d', [3, n1]));

    if (FormMode = ifmUpdate) or (FormMode = ifmRewiev) or (FormMode = ifmReadOnly) then
      LAraKodlar := TChHesapKarti(Table).GetAraHesapKodlari(edtkok_hesap_kodu.Text, TChHesapKarti(Table).KokKod.AsString, True)
    else
      LAraKodlar := TChHesapKarti(Table).GetAraHesapKodlari(edtkok_hesap_kodu.Text, '', False);
    try
      for n1 := 0 to LAraKodlar.Count - 1 do
      begin
        if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
          cbbara_hesap_kodu.Items.Delete(cbbara_hesap_kodu.Items.IndexOf(LAraKodlar.Strings[0]));
      end;
    finally
      LAraKodlar.DisposeOf;
    end;
  finally
    cbbara_hesap_kodu.Items.EndUpdate;
  end;
end;

procedure TfrmHesapKarti.fillSonHesapNumbers(pKokHesap, pAraHesapKodu: string);
var
  LHesapKarti: TChHesapKarti;
  n1: Integer;
  LFilter, LNo: string;
  LSonHesapKodlari: TStringList;
begin
  LNo := '';
  for n1 := 1 to 2500 do
    LNo := LNo + Format('%.*d', [3, n1]) + AddLBs;

  cbbara_hesap_kodu.Clear;
  cbbara_hesap_kodu.Items.Add(pAraHesapKodu);
  cbbara_hesap_kodu.ItemIndex := 0;

  cbbson_hesap_kodu.Items.BeginUpdate;
  cbbson_hesap_kodu.Items.Text := LNo;
  cbbson_hesap_kodu.Items.EndUpdate;

  LHesapKarti := TChHesapKarti.Create(Table.Database);
  try
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
      LFilter := ' AND ' + LHesapKarti.KokKod.QryName + '=' + QuotedStr(pKokHesap) + ' AND ' + LHesapKarti.AraKod.QryName + '=' + QuotedStr(pKokHesap + '-' + pAraHesapKodu) + ' AND ' + LHesapKarti.HesapTipiID.QryName + '=' + IntToStr(Ord(htSon))
    else if (FormMode = ifmUpdate) or (FormMode = ifmRewiev) or (FormMode = ifmReadOnly) then
      LFilter := ' AND ' + LHesapKarti.KokKod.QryName + '=' + QuotedStr(pKokHesap) + ' AND ' + LHesapKarti.AraKod.QryName + '=' + QuotedStr(pKokHesap + '-' + pAraHesapKodu) + ' AND ' + LHesapKarti.HesapTipiID.QryName + '=' + IntToStr(Ord(htSon)) + ' AND ' + LHesapKarti.HesapKodu.QryName + '<>' + QuotedStr(TChHesapKarti(Table).HesapKodu.Value);

    LSonHesapKodlari := LHesapKarti.GetSonHesapKodlari(LFilter);
    try
      for n1 := 0 to LSonHesapKodlari.Count - 1 do
      begin
        LNo := Format('%.*d', [3, StrToIntDef(LSonHesapKodlari.Strings[n1], 0)]);
        cbbson_hesap_kodu.Items.Delete(cbbson_hesap_kodu.Items.IndexOf(LNo));
      end;
    finally
      LSonHesapKodlari.Free;
    end;
  finally
    LHesapKarti.Free;
    cbbson_hesap_kodu.Items.EndUpdate;
  end;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
    cbbson_hesap_kodu.ItemIndex := 0;
end;

procedure TfrmHesapKarti.FormCreate(Sender: TObject);
begin
  inherited;

  edtefatura_pk_name.CharCase := ecLowerCase;
  edtweb_site.CharCase := ecLowerCase;
  edtemail.CharCase := ecLowerCase;
  edtmuhasebe_eposta.CharCase := ecLowerCase;

  FSetChHesapPlani := TChHesapPlani.Create(Table.Database);

  edthesap_iskonto.MaxLength := 6;
end;

procedure TfrmHesapKarti.FormDestroy(Sender: TObject);
begin
  FSetChHesapPlani.Free;
  inherited;
end;

procedure TfrmHesapKarti.FormShow(Sender: TObject);
begin
  edtkok_hesap_kodu.OnHelperProcess := HelperProcess;
  edthesap_grubu_id.OnHelperProcess := HelperProcess;
  edtbolge_id.OnHelperProcess := HelperProcess;
  edtmukellef_tipi_id.OnHelperProcess := HelperProcess;
  edtpara_birimi.OnHelperProcess := HelperProcess;
  edtiban_para.OnHelperProcess := HelperProcess;
//  edtulke_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;

  inherited;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
  begin
    lblis_pasif.Visible := False;
    chkis_pasif.Visible := False;
  end;
  edtkok_hesap_kodu.SetFocus;
end;

function TfrmHesapKarti.getHesapKodu: string;
begin
  Result := edtkok_hesap_kodu.Text + '-' + cbbara_hesap_kodu.Text + '-' + cbbson_hesap_kodu.Text;
  if not cbbson_hesap_kodu.Visible then
    Result := edtkok_hesap_kodu.Text + '-' + cbbara_hesap_kodu.Text;
  if not cbbara_hesap_kodu.Visible then
    Result := edtkok_hesap_kodu.Text;
end;

function TfrmHesapKarti.getAraHesapKodu: string;
begin
  Result := '';
  if cbbson_hesap_kodu.Visible then
    Result := edtkok_hesap_kodu.Text + '-' + cbbara_hesap_kodu.Text;
end;

procedure TfrmHesapKarti.HelperProcess(Sender: TObject);
var
  LFrmHesapKarti: TfrmHesapKartlariAra;
  LHesapKarti: TChHesapKartiAra;
  vKod: TStringDynArray;
  LFrmGrup: TfrmChGruplar;
  LFrmBolge: TfrmChBolgeler;
  LFrmMukellef: TfrmSysVergiMukellefTipleri;
  LFrmPara: TfrmSysParaBirimleri;
  LFrmSehir: TfrmSysSehirler;
  LSehir: TSysSehir;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtkok_hesap_kodu.Name then
      begin
        //Son hesap hane sayısı > 2 olanlarla işlem yap.
        LHesapKarti := TChHesapKartiAra.Create(Table.Database);
        LFrmHesapKarti := TfrmHesapKartlariAra.Create(TEdit(Sender), Self, LHesapKarti, fomNormal, True);
        try
          LFrmHesapKarti.ShowModal;

          if LFrmHesapKarti.DataAktar then
          begin
            if LFrmHesapKarti.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              cbbara_hesap_kodu.Clear;
              cbbson_hesap_kodu.Clear;
              edthesap_kodu.Clear;
            end
            else
            begin
              TEdit(Sender).Text := LHesapKarti.KokKod.Value;

              vKod := SplitString(LHesapKarti.HesapKodu.Value, ACC_DELIM);
              if Length(vKod) = 1 then
              begin
                lblspl2.Visible := False;
                cbbson_hesap_kodu.Visible := False;
                fillAraHesapNumbers;
                cbbara_hesap_kodu.ItemIndex := 0;
                cbbara_hesap_kodu.SetFocus;
              end
              else if Length(vKod) = 2 then
              begin
                lblspl2.Visible := True;
                cbbson_hesap_kodu.Visible := True;
                fillSonHesapNumbers(TEdit(Sender).Text, vKod[1]);
                cbbson_hesap_kodu.SetFocus;
              end;
            end;
          end;
        finally
          LFrmHesapKarti.Free;
        end;
      end
      else if TEdit(Sender).Name = edthesap_grubu_id.Name then
      begin
        LFrmGrup := TfrmChGruplar.Create(TEdit(Sender), Self, TChGrup.Create(Table.Database), fomNormal, True);
        try
          LFrmGrup.ShowModal;

          if LFrmGrup.DataAktar then
          begin
            if LFrmGrup.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TChHesapKarti(Table).GrupID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TChGrup(LFrmGrup.Table).Grup.AsString;
              TChHesapKarti(Table).GrupID.Value := LFrmGrup.Table.Id.Value;
            end;
          end;
        finally
          LFrmGrup.Free;
        end;
      end
      else if TEdit(Sender).Name = edtbolge_id.Name then
      begin
        LFrmBolge := TfrmChBolgeler.Create(TEdit(Sender), Self, TChBolge.Create(Table.Database), fomNormal, True);
        try
          LFrmBolge.ShowModal;

          if LFrmBolge.DataAktar then
          begin
            if LFrmBolge.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TChHesapKarti(Table).BolgeID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TChBolge(LFrmBolge.Table).Bolge.AsString;
              TChHesapKarti(Table).BolgeID.Value := LFrmBolge.Table.Id.Value;
            end;
          end;
        finally
          LFrmBolge.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmukellef_tipi_id.Name then
      begin
        LFrmMukellef := TfrmSysVergiMukellefTipleri.Create(TEdit(Sender), Self, TSysVergiMukellefTipi.Create(Table.Database), fomNormal, True);
        try
          LFrmMukellef.ShowModal;

          if LFrmMukellef.DataAktar then
          begin
            if LFrmMukellef.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TChHesapKarti(Table).MukellefTipiID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := TSysVergiMukellefTipi(LFrmMukellef.Table).MukellefTipi.AsString;
              TChHesapKarti(Table).MukellefTipiID.Value := LFrmMukellef.Table.Id.Value;

              ShowHideMukellefTipi;
            end
          end;
        finally
          LFrmMukellef.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtpara_birimi.Name) or (TEdit(Sender).Name = edtiban_para.Name) then
      begin
        LFrmPara := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, TSysParaBirimi.Create(Table.Database), fomNormal, True);
        try
          LFrmPara.ShowModal;

          if LFrmPara.DataAktar then
          begin
            if LFrmPara.CleanAndClose then
              TEdit(Sender).Clear
            else
              TEdit(Sender).Text := TSysParaBirimi(LFrmPara.Table).Para.AsString;
          end;
        finally
          LFrmPara.Free;
        end;
      end
      else if (TEdit(Sender).Name = edtsehir_id.Name) then
      begin
        LSehir := TSysSehir.Create(Table.Database);
        LFrmSehir := TfrmSysSehirler.Create(TEdit(Sender), Self, LSehir, fomNormal, True);
        try
          LFrmSehir.ShowModal;
          if LFrmSehir.DataAktar then
          begin
            if LFrmSehir.CleanAndClose then
            begin
              edtulke_id.Clear;
              TEdit(Sender).Clear;
              edtilce.Clear;
              edtmahalle.Clear;
              edtposta_kodu.Clear;
            end
            else
            begin
              if TChHesapKarti(Table).Adres.SehirId.AsInteger <> LFrmSehir.Table.Id.AsInteger then
              begin
                edtilce.Clear;
                edtmahalle.Clear;
                edtposta_kodu.Clear;
              end;
              edtulke_id.Text := LSehir.UlkeAdi.AsString;
              TChHesapKarti(Table).Adres.SehirId.Value := LFrmSehir.Table.Id.AsInteger;
              TEdit(Sender).Text := LSehir.Sehir.AsString;
            end;
          end;
        finally
          LFrmSehir.Free;
        end;
      end
    end;
  end
end;

procedure TfrmHesapKarti.pgcMainChange(Sender: TObject);
begin
  inherited;
  if pgcMain.ActivePage.Name = tsMain.Name then
  begin
    lblhesap_kodu.Parent := tsMain;
    edthesap_kodu.Parent := tsMain;
    lblhesap_ismi.Parent := tsMain;
    edthesap_ismi.Parent := tsMain;
    edthesap_kodu.TabOrder := 4;
    edthesap_ismi.TabOrder := 5;
  end
  else if pgcMain.ActivePage.Name = tsAdres.Name then
  begin
    lblhesap_kodu.Parent := tsAdres;
    edthesap_kodu.Parent := tsAdres;
    lblhesap_ismi.Parent := tsAdres;
    edthesap_ismi.Parent := tsAdres;
    edthesap_kodu.TabOrder := 0;
    edthesap_ismi.TabOrder := 1;
  end
  else if pgcMain.ActivePage.Name = tsIletisim.Name then
  begin
    lblhesap_kodu.Parent := tsIletisim;
    edthesap_kodu.Parent := tsIletisim;
    lblhesap_ismi.Parent := tsIletisim;
    edthesap_ismi.Parent := tsIletisim;
    edthesap_kodu.TabOrder := 0;
    edthesap_ismi.TabOrder := 1;
  end
end;

procedure TfrmHesapKarti.RefreshData();
var
  LSplit: TStringDynArray;
begin
  edtkok_hesap_kodu.Text := TChHesapKarti(Table).KokKod.Value;

  LSplit := SplitString(TChHesapKarti(Table).HesapKodu.Value, ACC_DELIM);
  if Length(LSplit) = 1 then  //1 seviyeli son hesap
  begin
    lblspl1.Visible := False;
    cbbara_hesap_kodu.Visible := False;
    lblspl2.Visible := False;
    cbbson_hesap_kodu.Visible := False;
  end
  else if Length(LSplit) = 2 then //2 seviyeli son hesap
  begin
    lblspl1.Visible := True;
    cbbara_hesap_kodu.Visible := True;
    lblspl2.Visible := False;
    cbbson_hesap_kodu.Visible := False;

    fillAraHesapNumbers;
    cbbara_hesap_kodu.ItemIndex := cbbara_hesap_kodu.Items.IndexOf(LSplit[1]);
    cbbara_hesap_koduExit(cbbara_hesap_kodu);
  end
  else if Length(LSplit) = 3 then //3 seviyeli son hesap
  begin
    lblspl1.Visible := True;
    cbbara_hesap_kodu.Visible := True;
    lblspl2.Visible := True;
    cbbson_hesap_kodu.Visible := True;

    fillAraHesapNumbers;
    fillSonHesapNumbers(TChHesapKarti(Table).KokKod.Value, LSplit[1]);
    cbbson_hesap_kodu.ItemIndex := cbbson_hesap_kodu.Items.IndexOf(LSplit[2]);
    cbbson_hesap_koduExit(cbbson_hesap_kodu);
  end;
  SetLength(LSplit, 0);
  edthesap_kodu.Text := TChHesapKarti(Table).HesapKodu.Value;

  edthesap_ismi.Text := TChHesapKarti(Table).HesapIsmi.Value;
  edthesap_grubu_id.Text := TChHesapKarti(Table).Grup.AsString;
  edtbolge_id.Text := TChHesapKarti(Table).Bolge.AsString;
  edtmukellef_tipi_id.Text := TChHesapKarti(Table).MukellefTipi.AsString;
  edtvergi_dairesi.Text := TChHesapKarti(Table).VergiDairesi.AsString;
  edtvergi_no.Text := TChHesapKarti(Table).VergiNo.AsString;

  ShowHideMukellefTipi;

  edtmukellef_adi.Text := TChHesapKarti(Table).MukellefAdi.AsString;
  edtmukellef_ikinci_adi.Text := TChHesapKarti(Table).MukellefAdi2.AsString;
  edtmukellef_soyadi.Text := TChHesapKarti(Table).MukellefSoyadi.AsString;

  edtiban.Text := TChHesapKarti(Table).Iban.AsString;
  edtiban_para.Text := TChHesapKarti(Table).IbanPara.AsString;
  edtnace_kodu.Text := TChHesapKarti(Table).Nace.AsString;
  edtefatura_pk_name.Text := TChHesapKarti(Table).EFaturaPBName.AsString;
  chkis_efatura_hesabi.Checked := TChHesapKarti(Table).EFaturaKullaniyor.Value;

  edtweb_site.Text := TChHesapKarti(Table).Adres.Web.Value;
  edtemail.Text := TChHesapKarti(Table).Adres.EMail.Value;
  edtulke_id.Text := TChHesapKarti(Table).Adres.UlkeAdi.AsString;
  edtsehir_id.Text := TChHesapKarti(Table).Adres.Sehir.AsString;
  edtilce.Text := TChHesapKarti(Table).Adres.Ilce.AsString;
  edtmahalle.Text := TChHesapKarti(Table).Adres.Mahalle.AsString;
  edtsemt.Text := TChHesapKarti(Table).Adres.Semt.AsString;
  edtcadde.Text := TChHesapKarti(Table).Adres.Cadde.AsString;
  edtsokak.Text := TChHesapKarti(Table).Adres.Sokak.AsString;
  edtbina_adi.Text := TChHesapKarti(Table).Adres.BinaAdi.AsString;
  edtkapi_no.Text := TChHesapKarti(Table).Adres.KapiNo.AsString;
  edtposta_kodu.Text := TChHesapKarti(Table).Adres.PostaKodu.AsString;

  edtyetkili1.Text := TChHesapKarti(Table).Yetkili1.Value;
  edtyetkili1_tel.Text := TChHesapKarti(Table).Yetkili1Tel.Value;
  edtyetkili2.Text := TChHesapKarti(Table).Yetkili2.Value;
  edtyetkili2_tel.Text := TChHesapKarti(Table).Yetkili2Tel.Value;
  edtyetkili3.Text := TChHesapKarti(Table).Yetkili3.Value;
  edtyetkili3_tel.Text := TChHesapKarti(Table).Yetkili3Tel.Value;
  edtfaks.Text := TChHesapKarti(Table).Faks.Value;
  edtmuhasebe_telefon.Text := TChHesapKarti(Table).MuhasebeTelefon.Value;
  edtmuhasebe_eposta.Text := TChHesapKarti(Table).MuhasebeEPosta.Value;
  edtmuhasebe_yetkili.Text := TChHesapKarti(Table).MuhasebeYetkili.Value;
  mmoozel_bilgi.Text := TChHesapKarti(Table).OzelNot.Value;
  edthesap_iskonto.Text := TChHesapKarti(Table).Iskonto.Value;
end;

procedure TfrmHesapKarti.Repaint;
begin
  inherited;
  edthesap_kodu.ReadOnly := True;
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    edthesap_iskonto.ReadOnly := False;

  edtilce.ReadOnly := True;
  edtposta_kodu.ReadOnly := True;
end;

procedure TfrmHesapKarti.ShowHideMukellefTipi;
begin
  if edtmukellef_tipi_id.Text = 'TCKN' then
  begin
//    lblvergi_dairesi.Visible := False;
//    edtvergi_dairesi.Visible := False;
//    lblvergi_no.Visible := False;
//    edtvergi_no.Visible := False;
    edtvergi_no.MaxLength := 11;

    lblmukellef_adi.Visible := True;
    edtmukellef_adi.Visible := True;
    lblmukellef_ikinci_adi.Visible := True;
    edtmukellef_ikinci_adi.Visible := True;
    lblmukellef_soyadi.Visible := True;
    edtmukellef_soyadi.Visible := True;
  end
  else
  begin
//    lblvergi_dairesi.Visible := True;
//    edtvergi_dairesi.Visible := True;
//    lblvergi_no.Visible := True;
//    edtvergi_no.Visible := True;
    edtvergi_no.MaxLength := 10;

    lblmukellef_adi.Visible := False;
    edtmukellef_adi.Visible := False;
    lblmukellef_ikinci_adi.Visible := False;
    edtmukellef_ikinci_adi.Visible := False;
    lblmukellef_soyadi.Visible := False;
    edtmukellef_soyadi.Visible := False;

    edtmukellef_adi.Clear;
    edtmukellef_ikinci_adi.Clear;
    edtmukellef_soyadi.Clear;
  end;
end;

function TfrmHesapKarti.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;

  procedure checkComboBoxItems(AComboBox: TCombobox);
  begin
    if AComboBox.Items.IndexOf(AComboBox.Text) = -1 then
    begin
      AComboBox.SetFocus;
      raise Exception.Create('Listede olmayan bir Tablo Adı giremezsiniz!' + AddLBs + AComboBox.Text);
    end;
  end;

begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

  if (edtkok_hesap_kodu.Visible and (edtkok_hesap_kodu.Text = '')) or (cbbara_hesap_kodu.Visible and (cbbara_hesap_kodu.Text = '')) or (cbbson_hesap_kodu.Visible and (cbbson_hesap_kodu.Text = '')) then
    raise Exception.Create('Son Hesap Kodu seçilmeden devam edilemez!');

  if cbbson_hesap_kodu.Visible then
    checkComboBoxItems(cbbson_hesap_kodu);
end;

procedure TfrmHesapKarti.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChHesapKarti(Table).HesapKodu.Value := edthesap_kodu.Text;
      TChHesapKarti(Table).HesapIsmi.Value := edthesap_ismi.Text;

      TChHesapKarti(Table).HesapTipiID.Value := Ord(htSon);
      TChHesapKarti(Table).KokKod.Value := edtkok_hesap_kodu.Text;
      TChHesapKarti(Table).AraKod.Value := getAraHesapKodu;
      TChHesapKarti(Table).Grup.Value := edthesap_grubu_id.Text;
      TChHesapKarti(Table).Bolge.Value := edtbolge_id.Text;
      TChHesapKarti(Table).MukellefTipi.Value := edtmukellef_tipi_id.Text;
      TChHesapKarti(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TChHesapKarti(Table).VergiNo.Value := edtvergi_no.Text;
      TChHesapKarti(Table).MukellefAdi.Value := edtmukellef_adi.Text;
      TChHesapKarti(Table).MukellefAdi2.Value := edtmukellef_ikinci_adi.Text;
      TChHesapKarti(Table).MukellefSoyadi.Value := edtmukellef_soyadi.Text;
      TChHesapKarti(Table).Iban.Value := edtiban.Text;
      TChHesapKarti(Table).IbanPara.Value := edtiban_para.Text;
      TChHesapKarti(Table).Nace.Value := edtnace_kodu.Text;
      TChHesapKarti(Table).EFaturaKullaniyor.Value := chkis_efatura_hesabi.Checked;
      TChHesapKarti(Table).EFaturaPBName.Value := edtefatura_pk_name.Text;

      TChHesapKarti(Table).Adres.Web.Value := edtweb_site.Text;
      TChHesapKarti(Table).Adres.EMail.Value := edtemail.Text;
      TChHesapKarti(Table).Adres.UlkeAdi.Value := edtulke_id.Text;
      TChHesapKarti(Table).Adres.Sehir.Value := edtsehir_id.Text;
      TChHesapKarti(Table).Adres.Ilce.Value := edtilce.Text;
      TChHesapKarti(Table).Adres.Mahalle.Value := edtmahalle.Text;
      TChHesapKarti(Table).Adres.Semt.Value := edtsemt.Text;
      TChHesapKarti(Table).Adres.Cadde.Value := edtcadde.Text;
      TChHesapKarti(Table).Adres.Sokak.Value := edtsokak.Text;
      TChHesapKarti(Table).Adres.BinaAdi.Value := edtbina_adi.Text;
      TChHesapKarti(Table).Adres.KapiNo.Value := edtkapi_no.Text;
      TChHesapKarti(Table).Adres.PostaKodu.Value := edtposta_kodu.Text;

      TChHesapKarti(Table).Yetkili1.Value := edtyetkili1.Text;
      TChHesapKarti(Table).Yetkili1Tel.Value := edtyetkili1_tel.Text;
      TChHesapKarti(Table).Yetkili2.Value := edtyetkili2.Text;
      TChHesapKarti(Table).Yetkili2Tel.Value := edtyetkili2_tel.Text;
      TChHesapKarti(Table).Yetkili3.Value := edtyetkili3.Text;
      TChHesapKarti(Table).Yetkili3Tel.Value := edtyetkili3_tel.Text;
      TChHesapKarti(Table).Faks.Value := edtfaks.Text;
      TChHesapKarti(Table).MuhasebeTelefon.Value := edtmuhasebe_telefon.Text;
      TChHesapKarti(Table).MuhasebeEPosta.Value := edtmuhasebe_eposta.Text;
      TChHesapKarti(Table).MuhasebeYetkili.Value := edtmuhasebe_yetkili.Text;
      TChHesapKarti(Table).OzelNot.Value := mmoozel_bilgi.Text;

      TChHesapKarti(Table).Iskonto.Value := StrToFloatDef(edthesap_iskonto.Text, 0);

      if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
      begin
        TChHesapKarti(Table).Pasif.Value := False;
      end
      else
        TChHesapKarti(Table).Pasif.Value := chkis_pasif.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
