unit ufrmChHesapKarti;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Vcl.Menus, System.StrUtils,
  System.Types, Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.ComboBox,
  Ths.Erp.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SetChHesapTipi,
  ufrmSetChHesapPlanlari,
  Ths.Erp.Database.Table.SetChHesapPlani,
  Ths.Erp.Constants;

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
    lblposta_kutusu: TLabel;
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
    lblweb_site: TLabel;
    lblemail: TLabel;
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
    edtweb_site: TEdit;
    edtmuhasebe_telefon: TEdit;
    edtemail: TEdit;
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
    edtposta_kutusu: TEdit;
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
    procedure FormCreate(Sender: TObject);override;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormShow(Sender: TObject);override;
    procedure edtkok_hesap_koduExit(Sender: TObject);
    procedure cbbara_hesap_koduExit(Sender: TObject);
    procedure cbbson_hesap_koduExit(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
  private
    FSetChHesapPlani: TSetChHesapPlani;

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
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.ChHesapKarti, ufrmChHesapKartlari,
  Ths.Erp.Database.Table.ChHesapKartiAra, ufrmChHesapKartlariAra,
  Ths.Erp.Database.Table.SetChGrup, ufrmSetChGruplar,
  Ths.Erp.Database.Table.PrsPersonel, ufrmPrsPersoneller,
  Ths.Erp.Database.Table.ChBolge, ufrmChBolgeler,
  Ths.Erp.Database.Table.SysMukellefTipi, ufrmSysMukellefTipleri,
  Ths.Erp.Database.Table.SysUlke, ufrmSysUlkeler,
  Ths.Erp.Database.Table.SysSehir, ufrmSysSehirler,
  Ths.Erp.Database.Table.SysParaBirimi, ufrmSysParaBirimleri,
  Ths.Erp.Database.Table.SysAdres;

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
  vSP: TFDStoredProc;
begin
  cbbara_hesap_kodu.Clear;
  vSP := GDataBase.NewStoredProcedure();
  try
    cbbara_hesap_kodu.Items.BeginUpdate;
    for n1 := 1 to 100 do
      cbbara_hesap_kodu.Items.Add(n1.ToString);

    vSP.ResourceOptions.DirectExecute := False;
    vSP.StoredProcName := 'spget_hesap_kodu_ara_kodlar';
    vSP.Prepare;
    vSP.ParamByName('pkok_kod').Text := edtkok_hesap_kodu.Text;
    vSP.ParamByName('para_kod').Text := '';
    vSP.ParamByName('pis_update').AsBoolean := False;
    if (FormMode = ifmUpdate) OR (FormMode = ifmRewiev) OR (FormMode = ifmReadOnly) then
    begin
      vSP.ParamByName('para_kod').Text := TChHesapKarti(Table).KokHesapKodu.Value;
      vSP.ParamByName('pis_update').AsBoolean := True;
    end;
    vSP.Open();
    vSP.First;
    while not vSP.Eof do
    begin
      if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) then
        cbbara_hesap_kodu.Items.Delete(cbbara_hesap_kodu.Items.IndexOf(vSP.Fields.Fields[0].AsString));
      vSP.Next;
    end;
  finally
    vSP.Free;
    cbbara_hesap_kodu.Items.EndUpdate;
  end;
end;

procedure TfrmHesapKarti.fillSonHesapNumbers(pKokHesap, pAraHesapKodu: string);
var
  vHesapKarti: TChHesapKarti;
  n1: Integer;
  vFilter, LNo: string;
  vSP: TFDStoredProc;
begin
  LNo := '';
  for n1 := 1 to 1500 do
    LNo := LNo + n1.ToString + AddLBs;

  cbbara_hesap_kodu.Clear;
  cbbara_hesap_kodu.Items.Add(pAraHesapKodu);
  cbbara_hesap_kodu.ItemIndex := 0;

  cbbson_hesap_kodu.Items.BeginUpdate;
  cbbson_hesap_kodu.Items.Text := LNo;
  cbbson_hesap_kodu.Items.EndUpdate;

  vSP := GDataBase.NewStoredProcedure();
  vHesapKarti := TChHesapKarti.Create(Table.Database);
  try
    if (FormMode = ifmNewRecord) OR (FormMode = ifmCopyNewRecord) then
      vFilter :=
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.KokHesapKodu.FieldName + '=' + QuotedStr(pKokHesap) +
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.AraHesapKodu.FieldName + '=' + QuotedStr(pKokHesap + '-' + pAraHesapKodu) +
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.HesapTipiID.FieldName + '=' + IntToStr(getSetChHesapTipiID(htSon))
    else if (FormMode = ifmUpdate) OR (FormMode = ifmRewiev) OR (FormMode = ifmReadOnly) then
      vFilter :=
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.KokHesapKodu.FieldName + '=' + QuotedStr(pKokHesap) +
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.AraHesapKodu.FieldName + '=' + QuotedStr(pKokHesap + '-' + pAraHesapKodu) +
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.HesapTipiID.FieldName + '=' + IntToStr(getSetChHesapTipiID(htSon)) +
        ' AND ' + vHesapKarti.TableName + '.' + vHesapKarti.HesapKodu.FieldName + '!=' + QuotedStr(TChHesapKarti(Table).HesapKodu.Value);

    vSP.ResourceOptions.DirectExecute := False;
    vSP.StoredProcName := 'spget_hesap_kodu_son_kodlar';
    vSP.Prepare;
    vSP.ParamByName('pfilter').Text := vFilter;
    vSP.Open();
    vSP.First;
    while not vSP.Eof do
    begin
      cbbson_hesap_kodu.Items.Delete(cbbson_hesap_kodu.Items.IndexOf(vSP.Fields.Fields[0].AsString));
      vSP.Next;
    end;
  finally
    vSP.Free;
    vHesapKarti.Free;
    cbbson_hesap_kodu.Items.EndUpdate;
  end;

  if (FormMode = ifmNewRecord) OR (FormMode = ifmCopyNewRecord) then
    cbbson_hesap_kodu.ItemIndex := 0;
end;

procedure TfrmHesapKarti.FormCreate(Sender: TObject);
begin
  inherited;

  edtefatura_pk_name.CharCase := ecLowerCase;
  edtweb_site.CharCase := ecLowerCase;
  edtemail.CharCase := ecLowerCase;
  edtmuhasebe_eposta.CharCase := ecLowerCase;

  FSetChHesapPlani := TSetChHesapPlani.Create(Table.Database);

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
  edtsehir_id.OnHelperProcess := HelperProcess;

  inherited;

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
  LFrmGrup: TfrmSetChGruplar;
  LFrmBolge: TfrmChBolgeler;
  LFrmMukellef: TfrmSysMukellefTipleri;
  LFrmPara: TfrmSysParaBirimleri;
  LFrmSehir: TfrmSysSehirler;
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
              TEdit(Sender).Text := LHesapKarti.KokHesapKodu.Value;

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
        LFrmGrup := TfrmSetChGruplar.Create(TEdit(Sender), Self, TSetChGrup.Create(Table.Database), fomNormal, True);
        try
          LFrmGrup.ShowModal;

          if LFrmGrup.DataAktar then
          begin
            if LFrmGrup.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TChHesapKarti(Table).HesapGrubuID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TSetChGrup(LFrmGrup.Table).Grup));
              TChHesapKarti(Table).HesapGrubuID.Value := LFrmGrup.Table.Id.Value;
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
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TChBolge(LFrmBolge.Table).Bolge));
              TChHesapKarti(Table).BolgeID.Value := LFrmBolge.Table.Id.Value;
            end;
          end;
        finally
          LFrmBolge.Free;
        end;
      end
      else if TEdit(Sender).Name = edtmukellef_tipi_id.Name then
      begin
        LFrmMukellef := TfrmSysMukellefTipleri.Create(TEdit(Sender), Self, TSysMukellefTipi.Create(Table.Database), fomNormal, True);
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
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TSysMukellefTipi(LFrmMukellef.Table).MukellefTipi));
              TChHesapKarti(Table).MukellefTipiID.Value := LFrmMukellef.Table.Id.Value;

              ShowHideMukellefTipi;
            end
          end;
        finally
          LFrmMukellef.Free;
        end;
      end
      else
      if (TEdit(Sender).Name = edtpara_birimi.Name)
      or (TEdit(Sender).Name = edtiban_para.Name)
      then
      begin
        LFrmPara := TfrmSysParaBirimleri.Create(TEdit(Sender), Self, TSysParaBirimi.Create(Table.Database), fomNormal, True);
        try
          LFrmPara.ShowModal;

          if LFrmPara.DataAktar then
          begin
            if LFrmPara.CleanAndClose then
              TEdit(Sender).Clear
            else
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TSysParaBirimi(LFrmPara.Table).ParaBirimi));
          end;
        finally
          LFrmPara.Free;
        end;
      end
      else if TEdit(Sender).Name = edtsehir_id.Name then
      begin
        LFrmSehir := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmSehir.ShowModal;

          if LFrmSehir.DataAktar then
          begin
            if LFrmSehir.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              edtulke_id.Clear;
            end
            else
            begin
              TEdit(Sender).Text := VarToStr(FormatedVariantVal(TSysSehir(LFrmSehir.Table).SehirAdi));
              TChHesapKarti(Table).SehirID.Value := LFrmSehir.Table.Id.Value;
              edtulke_id.Text := VarToStr(FormatedVariantVal(TSysSehir(LFrmSehir.Table).UlkeAdi));
              TChHesapKarti(Table).UlkeID.Value := TSysSehir(LFrmSehir.Table).UlkeAdiID.Value;
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
  edtkok_hesap_kodu.Text := TChHesapKarti(Table).KokHesapKodu.Value;

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
    fillSonHesapNumbers(TChHesapKarti(Table).KokHesapKodu.Value, LSplit[1]);
    cbbson_hesap_kodu.ItemIndex := cbbson_hesap_kodu.Items.IndexOf(LSplit[2]);
    cbbson_hesap_koduExit(cbbson_hesap_kodu);
  end;
  SetLength(LSplit, 0);
  edthesap_kodu.Text := TChHesapKarti(Table).HesapKodu.Value;

  edthesap_ismi.Text := TChHesapKarti(Table).HesapIsmi.Value;
  edthesap_grubu_id.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).HesapGrubu));
  edtbolge_id.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).Bolge));
  edtmukellef_tipi_id.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).MukellefTipi));
  edtvergi_dairesi.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).VergiDairesi));
  edtvergi_no.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).VergiNo));
  edtpara_birimi.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).ParaBirimi));

  ShowHideMukellefTipi;

  edtmukellef_adi.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).MukellefAdi));
  edtmukellef_ikinci_adi.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).MukellefIkinciAdi));
  edtmukellef_soyadi.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).MukellefSoyadi));

  edtiban.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).Iban));
  edtiban_para.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).IbanPara));
  edtnace_kodu.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).NaceKodu));
  edtefatura_pk_name.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).EFaturaPKName));
  chkis_efatura_hesabi.Checked := TChHesapKarti(Table).IsEFaturaHesabi.Value;

  edtulke_id.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).Ulke));
  edtsehir_id.Text := VarToStr(FormatedVariantVal(TChHesapKarti(Table).Sehir));
  edtilce.Text := TChHesapKarti(Table).Ilce.Value;
  edtmahalle.Text := TChHesapKarti(Table).Mahalle.Value;
  edtcadde.Text := TChHesapKarti(Table).Cadde.Value;
  edtsokak.Text := TChHesapKarti(Table).Sokak.Value;
  edtbina_adi.Text := TChHesapKarti(Table).BinaAdi.Value;
  edtkapi_no.Text := TChHesapKarti(Table).KapiNo.Value;
  edtposta_kutusu.Text := TChHesapKarti(Table).PostaKutusu.Value;
  edtposta_kodu.Text := TChHesapKarti(Table).PostaKodu.Value;

  edtyetkili1.Text := TChHesapKarti(Table).Yetkili1.Value;
  edtyetkili1_tel.Text := TChHesapKarti(Table).Yetkili1Tel.Value;
  edtyetkili2.Text := TChHesapKarti(Table).Yetkili2.Value;
  edtyetkili2_tel.Text := TChHesapKarti(Table).Yetkili2Tel.Value;
  edtyetkili3.Text := TChHesapKarti(Table).Yetkili3.Value;
  edtyetkili3_tel.Text := TChHesapKarti(Table).Yetkili3Tel.Value;
  edtfaks.Text := TChHesapKarti(Table).Faks.Value;
  edtweb_site.Text := TChHesapKarti(Table).WebSite.Value;
  edtemail.Text := TChHesapKarti(Table).EMail.Value;
  edtmuhasebe_telefon.Text := TChHesapKarti(Table).MuhasebeTelefon.Value;
  edtmuhasebe_eposta.Text := TChHesapKarti(Table).MuhasebeEPosta.Value;
  edtmuhasebe_yetkili.Text := TChHesapKarti(Table).MuhasebeYetkili.Value;
  mmoozel_bilgi.Text := TChHesapKarti(Table).OzelBilgi.Value;
  edthesap_iskonto.Text := TChHesapKarti(Table).HesapIskonto.Value;
end;

procedure TfrmHesapKarti.Repaint;
begin
  inherited;
  edthesap_kodu.ReadOnly := True;
  if (FormMode = ifmNewRecord)
  or (FormMode = ifmCopyNewRecord)
  or (FormMode = ifmUpdate)
  then
    edthesap_iskonto.ReadOnly := False;
end;

procedure TfrmHesapKarti.ShowHideMukellefTipi;
begin
  if edtmukellef_tipi_id.Text = 'TCKN' then
  begin
    lblvergi_dairesi.Visible := False;
    edtvergi_dairesi.Visible := False;
    lblvergi_no.Visible := False;
    edtvergi_no.Visible := False;

    lblmukellef_adi.Visible := True;
    edtmukellef_adi.Visible := True;
    lblmukellef_ikinci_adi.Visible := True;
    edtmukellef_ikinci_adi.Visible := True;
    lblmukellef_soyadi.Visible := True;
    edtmukellef_soyadi.Visible := True;
  end
  else
  begin
    lblvergi_dairesi.Visible := True;
    edtvergi_dairesi.Visible := True;
    lblvergi_no.Visible := True;
    edtvergi_no.Visible := True;

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
      raise Exception.Create( TranslateText('Listede olmayan bir Tablo Adı giremezsiniz!', '#1', LngMsgError, LngSystem) );
    end;
  end;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

  if (edtkok_hesap_kodu.Visible and (edtkok_hesap_kodu.Text = ''))
  or (cbbara_hesap_kodu.Visible and (cbbara_hesap_kodu.Text = ''))
  or (cbbson_hesap_kodu.Visible and (cbbson_hesap_kodu.Text = ''))
  then
    raise Exception.Create('Son Hesap Kodu seçilmeden devam edilemez!');

  if cbbson_hesap_kodu.Visible then checkComboBoxItems(cbbson_hesap_kodu);
end;

procedure TfrmHesapKarti.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      //btnAcceptAuto;

      TChHesapKarti(Table).HesapKodu.Value := edthesap_kodu.Text;
      TChHesapKarti(Table).HesapIsmi.Value := edthesap_ismi.Text;
      TChHesapKarti(Table).MuhasebeKodu.Value := TChHesapKarti(Table).HesapKodu.Value;

      TChHesapKarti(Table).HesapTipiID.Value := getSetChHesapTipiID(htSon);
      TChHesapKarti(Table).KokHesapKodu.Value := edtkok_hesap_kodu.Text;
      TChHesapKarti(Table).AraHesapKodu.Value := getAraHesapKodu;
      TChHesapKarti(Table).HesapGrubu.Value := edthesap_grubu_id.Text;
      TChHesapKarti(Table).Bolge.Value := edtbolge_id.Text;
      TChHesapKarti(Table).MukellefTipi.Value := edtmukellef_tipi_id.Text;
      TChHesapKarti(Table).VergiDairesi.Value := edtvergi_dairesi.Text;
      TChHesapKarti(Table).VergiNo.Value := edtvergi_no.Text;
      TChHesapKarti(Table).MukellefAdi.Value := edtmukellef_adi.Text;
      TChHesapKarti(Table).MukellefIkinciAdi.Value := edtmukellef_ikinci_adi.Text;
      TChHesapKarti(Table).MukellefSoyadi.Value := edtmukellef_soyadi.Text;
      TChHesapKarti(Table).ParaBirimi.Value := edtpara_birimi.Text;
      TChHesapKarti(Table).Iban.Value := edtiban.Text;
      TChHesapKarti(Table).IbanPara.Value := edtiban_para.Text;
      TChHesapKarti(Table).NaceKodu.Value := edtnace_kodu.Text;
      TChHesapKarti(Table).IsEFaturaHesabi.Value := chkis_efatura_hesabi.Checked;
      TChHesapKarti(Table).EFaturaPKName.Value := edtefatura_pk_name.Text;

      TChHesapKarti(Table).Ulke.Value := edtulke_id.Text;
      TChHesapKarti(Table).Sehir.Value := edtsehir_id.Text;
      TChHesapKarti(Table).Ilce.Value := edtilce.Text;
      TChHesapKarti(Table).Mahalle.Value := edtmahalle.Text;
      TChHesapKarti(Table).Cadde.Value := edtcadde.Text;
      TChHesapKarti(Table).Sokak.Value := edtsokak.Text;
      TChHesapKarti(Table).BinaAdi.Value := edtbina_adi.Text;
      TChHesapKarti(Table).KapiNo.Value := edtkapi_no.Text;
      TChHesapKarti(Table).PostaKutusu.Value := edtposta_kutusu.Text;
      TChHesapKarti(Table).PostaKodu.Value := edtposta_kodu.Text;

      TChHesapKarti(Table).Yetkili1.Value := edtyetkili1.Text;
      TChHesapKarti(Table).Yetkili1Tel.Value := edtyetkili1_tel.Text;
      TChHesapKarti(Table).Yetkili2.Value := edtyetkili2.Text;
      TChHesapKarti(Table).Yetkili2Tel.Value := edtyetkili2_tel.Text;
      TChHesapKarti(Table).Yetkili3.Value := edtyetkili3.Text;
      TChHesapKarti(Table).Yetkili3Tel.Value := edtyetkili3_tel.Text;
      TChHesapKarti(Table).Faks.Value := edtfaks.Text;
      TChHesapKarti(Table).WebSite.Value := edtweb_site.Text;
      TChHesapKarti(Table).EMail.Value := edtemail.Text;
      TChHesapKarti(Table).MuhasebeTelefon.Value := edtmuhasebe_telefon.Text;
      TChHesapKarti(Table).MuhasebeEPosta.Value := edtmuhasebe_eposta.Text;
      TChHesapKarti(Table).MuhasebeYetkili.Value := edtmuhasebe_yetkili.Text;
      TChHesapKarti(Table).OzelBilgi.Value := mmoozel_bilgi.Text;

      TChHesapKarti(Table).HesapIskonto.Value := StrToFloatDef(edthesap_iskonto.Text, 0);

      inherited;
    end;
  end
  else
    inherited;
end;

end.
