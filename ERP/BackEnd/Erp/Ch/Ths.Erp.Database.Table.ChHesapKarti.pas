unit Ths.Erp.Database.Table.ChHesapKarti;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Variants,
  Data.DB,
  FireDAC.Stan.Param,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetChGrup,
  Ths.Erp.Database.Table.SetChHesapTipi,
  Ths.Erp.Database.Table.SetChHesapPlani,
  Ths.Erp.Database.Table.ChBolge,
  Ths.Erp.Database.Table.SysMukellefTipi,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysAdres,
  Ths.Erp.Database.Table.PrsPersonel,
  Ths.Erp.Database.Table.SysParaBirimi;

type
  TChHesapKarti = class(TTable)
  private
    FHesapKodu: TFieldDB;
    FHesapIsmi: TFieldDB;
    FMuhasebeKodu: TFieldDB;
    FHesapTipiID: TFieldDB;
    FHesapTipi: TFieldDB;
    FHesapGrubuID: TFieldDB;
    FHesapGrubu: TFieldDB;
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
    FMukellefTipiID: TFieldDB;
    FMukellefTipi: TFieldDB;
    FMukellefAdi: TFieldDB;
    FMukellefIkinciAdi: TFieldDB;
    FMukellefSoyadi: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FParaBirimi: TFieldDB;
    FIban: TFieldDB;
    FIbanPara: TFieldDB;
    FNaceKodu: TFieldDB;
    FYetkili1: TFieldDB;
    FYetkili1Tel: TFieldDB;
    FYetkili2: TFieldDB;
    FYetkili2Tel: TFieldDB;
    FYetkili3: TFieldDB;
    FYetkili3Tel: TFieldDB;
    FFaks: TFieldDB;
    FMuhasebeTelefon: TFieldDB;
    FMuhasebeEPosta: TFieldDB;
    FMuhasebeYetkili: TFieldDB;
    FOzelBilgi: TFieldDB;
    FKokHesapKodu: TFieldDB;
    FAraHesapKodu: TFieldDB;
    FHesapIskonto: TFieldDB;
    FIsEFaturaHesabi: TFieldDB;
    FEFaturaPKName: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB;
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
    FIlce: TFieldDB;
    FMahalle: TFieldDB;
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FPostaKutusu: TFieldDB;
    FPostaKodu: TFieldDB;
    FWebSite: TFieldDB;
    FEMail: TFieldDB;
    FSeviyeSayisi: TFieldDB;
  protected
    FHesapGruplari: TSetChGrup;
    FSetChHesapTipi: TSetChHesapTipi;
    FEmpCard: TPrsPersonel;
    FBolgeler: TChBolge;
    FSetChHesapPlani: TSetChHesapPlani;
    FSysMukellef: TSysMukellefTipi;
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;
    FPara: TSysParaBirimi;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure Validate;

    Property HesapKodu: TFieldDB read FHesapKodu write FHesapKodu;
    Property HesapIsmi: TFieldDB read FHesapIsmi write FHesapIsmi;
    Property MuhasebeKodu: TFieldDB read FMuhasebeKodu write FMuhasebeKodu;
    Property HesapTipiID: TFieldDB read FHesapTipiID write FHesapTipiID;
    Property HesapTipi: TFieldDB read FHesapTipi write FHesapTipi;
    Property HesapGrubuID: TFieldDB read FHesapGrubuID write FHesapGrubuID;
    Property HesapGrubu: TFieldDB read FHesapGrubu write FHesapGrubu;
    Property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    Property Bolge: TFieldDB read FBolge write FBolge;
    Property MukellefTipiID: TFieldDB read FMukellefTipiID write FMukellefTipiID;
    Property MukellefTipi: TFieldDB read FMukellefTipi write FMukellefTipi;
    Property MukellefAdi: TFieldDB read FMukellefAdi write FMukellefAdi;
    Property MukellefIkinciAdi: TFieldDB read FMukellefIkinciAdi write FMukellefIkinciAdi;
    Property MukellefSoyadi: TFieldDB read FMukellefSoyadi write FMukellefSoyadi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    Property Iban: TFieldDB read FIban write FIban;
    Property IbanPara: TFieldDB read FIbanPara write FIbanPara;
    Property NaceKodu: TFieldDB read FNaceKodu write FNaceKodu;
    Property Yetkili1: TFieldDB read FYetkili1 write FYetkili1;
    Property Yetkili1Tel: TFieldDB read FYetkili1Tel write FYetkili1Tel;
    Property Yetkili2: TFieldDB read FYetkili2 write FYetkili2;
    Property Yetkili2Tel: TFieldDB read FYetkili2Tel write FYetkili2Tel;
    Property Yetkili3: TFieldDB read FYetkili3 write FYetkili3;
    Property Yetkili3Tel: TFieldDB read FYetkili3Tel write FYetkili3Tel;
    Property Faks: TFieldDB read FFaks write FFaks;
    Property MuhasebeTelefon: TFieldDB read FMuhasebeTelefon write FMuhasebeTelefon;
    Property MuhasebeEPosta: TFieldDB read FMuhasebeEPosta write FMuhasebeEPosta;
    Property MuhasebeYetkili: TFieldDB read FMuhasebeYetkili write FMuhasebeYetkili;
    Property OzelBilgi: TFieldDB read FOzelBilgi write FOzelBilgi;
    Property KokHesapKodu: TFieldDB read FKokHesapKodu write FKokHesapKodu;
    Property AraHesapKodu: TFieldDB read FAraHesapKodu write FAraHesapKodu;
    Property HesapIskonto: TFieldDB read FHesapIskonto write FHesapIskonto;
    Property IsEFaturaHesabi: TFieldDB read FIsEFaturaHesabi write FIsEFaturaHesabi;
    Property EFaturaPKName: TFieldDB read FEFaturaPKName write FEFaturaPKName;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property Ilce: TFieldDB read FIlce write FIlce;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property PostaKutusu: TFieldDB read FPostaKutusu write FPostaKutusu;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property WebSite: TFieldDB read FWebSite write FWebSite;
    Property EMail: TFieldDB read FEMail write FEMail;
    Property SeviyeSayisi: TFieldDB read FSeviyeSayisi write FSeviyeSayisi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TChHesapKarti.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesap_karti';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FHesapGruplari := TSetChGrup.Create(Database);
  FSetChHesapTipi := TSetChHesapTipi.Create(Database);
  FEmpCard := TPrsPersonel.Create(Database);
  FBolgeler := TChBolge.Create(Database);
  FSetChHesapPlani := TSetChHesapPlani.Create(Database);
  FSysMukellef := TSysMukellefTipi.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSysSehir := TSysSehir.Create(Database);
  FPara := TSysParaBirimi.Create(Database);

  FHesapKodu := TFieldDB.Create('hesap_kodu', ftString, '', Self, 'Hesap Kodu');
  FHesapIsmi := TFieldDB.Create('hesap_ismi', ftString, '', Self, 'Hesap Ýsmi');
  FMuhasebeKodu := TFieldDB.Create('muhasebe_kodu', ftString, '', Self, 'Muhasebe Kodu');
  FHesapTipiID := TFieldDB.Create('hesap_tipi_id', ftInteger, 0, Self, 'Hesap Tipi ID');
  FHesapTipi := TFieldDB.Create(FSetChHesapTipi.HesapTipi.FieldName, FSetChHesapTipi.HesapTipi.DataType, '', Self, 'Hesap Tipi');
  FHesapGrubuID := TFieldDB.Create('hesap_grubu_id', ftInteger, 0, Self, 'Hesap Grubu ID');
  FHesapGrubu := TFieldDB.Create(FHesapGruplari.Grup.FieldName, FHesapGruplari.Grup.DataType, '', Self, 'Hesap Grubu');
  FBolgeID := TFieldDB.Create('bolge_id', ftInteger, 0, Self, 'Bölge ID');
  FBolge := TFieldDB.Create(FBolgeler.Bolge.FieldName, FBolgeler.Bolge.DataType, '', Self, 'Bölge');
  FMukellefTipiID := TFieldDB.Create('mukellef_tipi_id', ftInteger, 0, Self, 'Mükellef Tipi ID');
  FMukellefTipi := TFieldDB.Create(FSysMukellef.MukellefTipi.FieldName, FSysMukellef.MukellefTipi.DataType, '', Self, 'Mükellef Tipi');
  FMukellefAdi := TFieldDB.Create('mukellef_adi', ftString, '', Self, 'Mükellef Adý');
  FMukellefIkinciAdi := TFieldDB.Create('mukellef_ikinci_adi', ftString, '', Self, 'Mükellef Adý 2');
  FMukellefSoyadi := TFieldDB.Create('mukellef_soyadi', ftString, '', Self, 'Mükellef Soyadý');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, 'Vergi Dairesi');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, 'Vergi No');
  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, 'Para Birimi');
  FIban := TFieldDB.Create('iban', ftString, '', Self, 'IBAN');
  FIbanPara := TFieldDB.Create('iban_para', ftString, '', Self, 'IBAN Birim');
  FNaceKodu := TFieldDB.Create('nace_kodu', ftString, '', Self, 'Nace Kodu');
  FYetkili1 := TFieldDB.Create('yetkili1', ftString, '', Self, 'Yetkili 1');
  FYetkili1Tel := TFieldDB.Create('yetkili1_tel', ftString, '', Self, 'Yetkili 1 Tel');
  FYetkili2 := TFieldDB.Create('yetkili2', ftString, '', Self, 'Yetkili 2');
  FYetkili2Tel := TFieldDB.Create('yetkili2_tel', ftString, '', Self, 'Yetkili 2 Tel');
  FYetkili3 := TFieldDB.Create('yetkili3', ftString, '', Self, 'Yetkili 3');
  FYetkili3Tel := TFieldDB.Create('yetkili3_tel', ftString, '', Self, 'Yetkili 3 Telefon');
  FFaks := TFieldDB.Create('faks', ftString, '', Self, 'Faks');
  FMuhasebeTelefon := TFieldDB.Create('muhasebe_telefon', ftString, '', Self, 'Muhasebe Telefon');
  FMuhasebeEPosta := TFieldDB.Create('muhasebe_eposta', ftString, '', Self, 'Muhasebe E-Posta');
  FMuhasebeYetkili := TFieldDB.Create('muhasebe_yetkili', ftString, '', Self, 'Muhasebe Yetkili');
  FOzelBilgi := TFieldDB.Create('ozel_bilgi', ftString, '', Self, 'Özel Bilgi');
  FKokHesapKodu := TFieldDB.Create('kok_hesap_kodu', ftString, '', Self, 'Kök Hesap Kodu');
  FAraHesapKodu := TFieldDB.Create('ara_hesap_kodu', ftString, '', Self, 'Ara Hesap Kodu');
  FHesapIskonto := TFieldDB.Create('hesap_iskonto', ftFloat, 0, Self, 'Hesap Ýskonto');
  FIsEFaturaHesabi := TFieldDB.Create('is_efatura_hesabi', ftBoolean, False, Self, 'E-Fatura?');
  FEFaturaPKName := TFieldDB.Create('efatura_pk_name', ftString, '', Self, 'E-Fatura PK Adý');
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self, 'Ülke ID');
  FUlke := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self, 'Ülke');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'Þehir ID');
  FSehir := TFieldDB.Create(FSysSehir.SehirAdi.FieldName, FSysSehir.SehirAdi.DataType, '', Self, 'Þehir');
  FIlce := TFieldDB.Create('ilce', ftString, '', Self, 'Ýlçe');
  FMahalle := TFieldDB.Create('mahalle', ftString, '', Self, 'Mahalle');
  FCadde := TFieldDB.Create('cadde', ftString, '', Self, 'Cadde');
  FSokak := TFieldDB.Create('sokak', ftString, '', Self, 'Sokak');
  FBinaAdi := TFieldDB.Create('bina_adi', ftString, '', Self, 'Bina Adý');
  FKapiNo := TFieldDB.Create('kapi_no', ftString, '', Self, 'Kapý No');
  FPostaKutusu := TFieldDB.Create('posta_kutusu', ftString, '', Self, 'Posta Kutusu');
  FPostaKodu := TFieldDB.Create('posta_kodu', ftString, '', Self, 'Posta Kodu');
  FWebSite := TFieldDB.Create('web_site', ftString, '', Self, 'Web Sitesi');
  FEMail := TFieldDB.Create('email', ftString, '', Self, 'E-Mail');
  FSeviyeSayisi := TFieldDB.Create(FSetChHesapPlani.SeviyeSayisi.FieldName, FSetChHesapPlani.SeviyeSayisi.DataType, 0, Self, 'Seviye Sayýsý');
end;

destructor TChHesapKarti.Destroy;
begin
  FHesapGruplari.Free;
  FSetChHesapTipi.Free;
  FEmpCard.Free;
  FBolgeler.Free;
  FSetChHesapPlani.Free;
  FSysMukellef.Free;
  FSysUlke.Free;
  FSysSehir.Free;
  FPara.Free;
  
  inherited;
end;

procedure TChHesapKarti.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHesapKodu.FieldName,
        TableName + '.' + FHesapIsmi.FieldName,
        TableName + '.' + FMuhasebeKodu.FieldName,
        TableName + '.' + FHesapTipiID.FieldName,
        addLangField(FHesapTipi.FieldName),
        TableName + '.' + FHesapGrubuID.FieldName,
        addLangField(FHesapGrubu.FieldName),
        TableName + '.' + FBolgeID.FieldName,
        addLangField(FBolge.FieldName),
        TableName + '.' + FMukellefTipiID.FieldName,
        addLangField(FMukellefTipi.FieldName),
        TableName + '.' + FMukellefAdi.FieldName,
        TableName + '.' + FMukellefIkinciAdi.FieldName,
        TableName + '.' + FMukellefSoyadi.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNo.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FIban.FieldName,
        TableName + '.' + FIbanPara.FieldName,
        TableName + '.' + FNaceKodu.FieldName,
        TableName + '.' + FYetkili1.FieldName,
        TableName + '.' + FYetkili1Tel.FieldName,
        TableName + '.' + FYetkili2.FieldName,
        TableName + '.' + FYetkili2Tel.FieldName,
        TableName + '.' + FYetkili3.FieldName,
        TableName + '.' + FYetkili3Tel.FieldName,
        TableName + '.' + FFaks.FieldName,
        TableName + '.' + FMuhasebeTelefon.FieldName,
        TableName + '.' + FMuhasebeEPosta.FieldName,
        TableName + '.' + FMuhasebeYetkili.FieldName,
        TableName + '.' + FOzelBilgi.FieldName,
        TableName + '.' + FKokHesapKodu.FieldName,
        TableName + '.' + FAraHesapKodu.FieldName,
        TableName + '.' + FHesapIskonto.FieldName,
        TableName + '.' + FIsEFaturaHesabi.FieldName,
        TableName + '.' + FEFaturaPKName.FieldName,
        TableName + '.' + UlkeID.FieldName,
        addLangField(FUlke.FieldName),
        TableName + '.' + SehirID.FieldName,
        addLangField(FSehir.FieldName),
        TableName + '.' + Ilce.FieldName,
        TableName + '.' + Mahalle.FieldName,
        TableName + '.' + Cadde.FieldName,
        TableName + '.' + Sokak.FieldName,
        TableName + '.' + BinaAdi.FieldName,
        TableName + '.' + KapiNo.FieldName,
        TableName + '.' + PostaKutusu.FieldName,
        TableName + '.' + PostaKodu.FieldName,
        TableName + '.' + WebSite.FieldName,
        TableName + '.' + EMail.FieldName,
        FSetChHesapPlani.TableName + '.' + FSeviyeSayisi.FieldName
      ], [
        addLeftJoin(FHesapTipi.FieldName, FHesapTipiID.FieldName, FSetChHesapTipi.TableName),
        addLeftJoin(FHesapGrubu.FieldName, FHesapGrubuID.FieldName, FHesapGruplari.TableName),
        addLeftJoin(FBolge.FieldName, FBolgeID.FieldName, FBolgeler.TableName),
        addLeftJoin(FMukellefTipi.FieldName, FMukellefTipiID.FieldName, FSysMukellef.TableName),
        addLeftJoin(FUlke.FieldName, FUlkeID.FieldName, FSysUlke.TableName),
        addLeftJoin(FSehir.FieldName, FSehirID.FieldName, FSysSehir.TableName),
        addJoin(jtLeft, FSetChHesapPlani.TableName, FSetChHesapPlani.TekDuzenKodu.FieldName, TableName, FKokHesapKodu.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TChHesapKarti.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHesapKodu.FieldName,
        TableName + '.' + FHesapIsmi.FieldName,
        TableName + '.' + FMuhasebeKodu.FieldName,
        TableName + '.' + FHesapTipiID.FieldName,
        addLangField(FHesapTipi.FieldName),
        TableName + '.' + FHesapGrubuID.FieldName,
        addLangField(FHesapGrubu.FieldName),
        TableName + '.' + FBolgeID.FieldName,
        addLangField(FBolge.FieldName),
        TableName + '.' + FMukellefTipiID.FieldName,
        addLangField(FMukellefTipi.FieldName),
        TableName + '.' + FMukellefAdi.FieldName,
        TableName + '.' + FMukellefIkinciAdi.FieldName,
        TableName + '.' + FMukellefSoyadi.FieldName,
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNo.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FIban.FieldName,
        TableName + '.' + FIbanPara.FieldName,
        TableName + '.' + FNaceKodu.FieldName,
        TableName + '.' + FYetkili1.FieldName,
        TableName + '.' + FYetkili1Tel.FieldName,
        TableName + '.' + FYetkili2.FieldName,
        TableName + '.' + FYetkili2Tel.FieldName,
        TableName + '.' + FYetkili3.FieldName,
        TableName + '.' + FYetkili3Tel.FieldName,
        TableName + '.' + FFaks.FieldName,
        TableName + '.' + FMuhasebeTelefon.FieldName,
        TableName + '.' + FMuhasebeEPosta.FieldName,
        TableName + '.' + FMuhasebeYetkili.FieldName,
        TableName + '.' + FOzelBilgi.FieldName,
        TableName + '.' + FKokHesapKodu.FieldName,
        TableName + '.' + FAraHesapKodu.FieldName,
        TableName + '.' + FHesapIskonto.FieldName,
        TableName + '.' + FIsEFaturaHesabi.FieldName,
        TableName + '.' + FEFaturaPKName.FieldName,
        TableName + '.' + UlkeID.FieldName,
        addLangField(FUlke.FieldName),
        TableName + '.' + SehirID.FieldName,
        addLangField(FSehir.FieldName),
        TableName + '.' + Ilce.FieldName,
        TableName + '.' + Mahalle.FieldName,
        TableName + '.' + Cadde.FieldName,
        TableName + '.' + Sokak.FieldName,
        TableName + '.' + BinaAdi.FieldName,
        TableName + '.' + KapiNo.FieldName,
        TableName + '.' + PostaKutusu.FieldName,
        TableName + '.' + PostaKodu.FieldName,
        TableName + '.' + WebSite.FieldName,
        TableName + '.' + EMail.FieldName,
        FSetChHesapPlani.TableName + '.' + FSeviyeSayisi.FieldName
      ], [
        addLeftJoin(FHesapTipi.FieldName, FHesapTipiID.FieldName, FSetChHesapTipi.TableName),
        addLeftJoin(FHesapGrubu.FieldName, FHesapGrubuID.FieldName, FHesapGruplari.TableName),
        addLeftJoin(FBolge.FieldName, FBolgeID.FieldName, FBolgeler.TableName),
        addLeftJoin(FMukellefTipi.FieldName, FMukellefTipiID.FieldName, FSysMukellef.TableName),
        addLeftJoin(FUlke.FieldName, FUlkeID.FieldName, FSysUlke.TableName),
        addLeftJoin(FSehir.FieldName, FSehirID.FieldName, FSysSehir.TableName),
        addJoin(jtLeft, FSetChHesapPlani.TableName, FSetChHesapPlani.TekDuzenKodu.FieldName, TableName, FKokHesapKodu.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TChHesapKarti.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHesapKodu.FieldName,
        FHesapIsmi.FieldName,
        FMuhasebeKodu.FieldName,
        FHesapTipiID.FieldName,
        FHesapGrubuID.FieldName,
        FBolgeID.FieldName,
        FMukellefTipiID.FieldName,
        FMukellefAdi.FieldName,
        FMukellefIkinciAdi.FieldName,
        FMukellefSoyadi.FieldName,
        FVergiDairesi.FieldName,
        FVergiNo.FieldName,
        FParaBirimi.FieldName,
        FIban.FieldName,
        FIbanPara.FieldName,
        FNaceKodu.FieldName,
        FYetkili1.FieldName,
        FYetkili1Tel.FieldName,
        FYetkili2.FieldName,
        FYetkili2Tel.FieldName,
        FYetkili3.FieldName,
        FYetkili3Tel.FieldName,
        FFaks.FieldName,
        FMuhasebeTelefon.FieldName,
        FMuhasebeEPosta.FieldName,
        FMuhasebeYetkili.FieldName,
        FOzelBilgi.FieldName,
        FKokHesapKodu.FieldName,
        FAraHesapKodu.FieldName,
        FHesapIskonto.FieldName,
        FIsEFaturaHesabi.FieldName,
        FEFaturaPKName.FieldName,
        FUlkeID.FieldName,
        FSehirID.FieldName,
        FIlce.FieldName,
        FMahalle.FieldName,
        FCadde.FieldName,
        FSokak.FieldName,
        FBinaAdi.FieldName,
        FKapiNo.FieldName,
        FPostaKutusu.FieldName,
        FPostaKodu.FieldName,
        FWebSite.FieldName,
        FEMail.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TChHesapKarti.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHesapKodu.FieldName,
        FHesapIsmi.FieldName,
        FMuhasebeKodu.FieldName,
        FHesapTipiID.FieldName,
        FHesapGrubuID.FieldName,
        FBolgeID.FieldName,
        FMukellefTipiID.FieldName,
        FMukellefAdi.FieldName,
        FMukellefIkinciAdi.FieldName,
        FMukellefSoyadi.FieldName,
        FVergiDairesi.FieldName,
        FVergiNo.FieldName,
        FParaBirimi.FieldName,
        FIban.FieldName,
        FIbanPara.FieldName,
        FNaceKodu.FieldName,
        FYetkili1.FieldName,
        FYetkili1Tel.FieldName,
        FYetkili2.FieldName,
        FYetkili2Tel.FieldName,
        FYetkili3.FieldName,
        FYetkili3Tel.FieldName,
        FFaks.FieldName,
        FMuhasebeTelefon.FieldName,
        FMuhasebeEPosta.FieldName,
        FMuhasebeYetkili.FieldName,
        FOzelBilgi.FieldName,
        FKokHesapKodu.FieldName,
        FAraHesapKodu.FieldName,
        FIsEFaturaHesabi.FieldName,
        FEFaturaPKName.FieldName,
        FHesapIskonto.FieldName,
        FUlkeID.FieldName,
        FSehirID.FieldName,
        FIlce.FieldName,
        FMahalle.FieldName,
        FCadde.FieldName,
        FSokak.FieldName,
        FBinaAdi.FieldName,
        FKapiNo.FieldName,
        FPostaKutusu.FieldName,
        FPostaKodu.FieldName,
        FWebSite.FieldName,
        FEMail.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TChHesapKarti.Validate;
var
  LIsk: Double;
  LStr, LVergiNo: string;
begin
  LIsk := StrToFloatDef(VarToStr(FormatedVariantVal(FHesapIskonto)), 0);
  if (LIsk > 100.00) or (LIsk < 0) then
    CreateExceptionByLang('"Ýskonto Oraný > 100" veya "Ýskonto Oraný < 0" olamaz!', '999999');

  LStr := VarToStr(FormatedVariantVal(MukellefTipi));
  LVergiNo := VarToStr(FormatedVariantVal(VergiNo));
  if (LStr = 'TCKN') and (LVergiNo.Length <> 11) then
    CreateExceptionByLang('TCKN seçildiðinde Vergi Kimlik No 11 haneli olmak zorunda!', '999999');

  if (LStr = 'VKN') and (LVergiNo.Length <> 10) then
    CreateExceptionByLang('VKN seçildiðinde Vergi Kimlik No 10 haneli olmak zorunda!', '999999');

//  if Self.SeviyeSayisi.Value = 3 then
//  begin
//    if (KokHesapKodu.Value = '') or (AraHesapKodu.Value = '') then
//      CreateExceptionByLang('Son Hesap Kodu seçilmeden devam edilemez!', '999999');
//  end
//  else
//  begin
//    LStr :=
//    if (KokHesapKodu.Value = '')
//    or (AraHesapKodu.Value = '').
//    then
//      CreateExceptionByLang('Son Hesap Kodu seçilmeden devam edilemez!', '999999');
//  end;
end;

function TChHesapKarti.Clone: TTable;
begin
  Result := TChHesapKarti.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
