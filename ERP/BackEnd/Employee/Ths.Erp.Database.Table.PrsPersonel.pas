unit Ths.Erp.Database.Table.PrsPersonel;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetPrsPersonelTipi,
  Ths.Erp.Database.Table.SetPrsBolum,
  Ths.Erp.Database.Table.SetPrsBirim,
  Ths.Erp.Database.Table.SetPrsGorev,
  Ths.Erp.Database.Table.SetPrsCinsiyet,
  Ths.Erp.Database.Table.SetPrsAskerlikDurumu,
  Ths.Erp.Database.Table.SetPrsMedeniDurum,
  Ths.Erp.Database.Table.SetPrsServisAraci,
  Ths.Erp.Database.Table.SysAdres,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.PrsEhliyetBilgisi;

type
  TPrsPersonel = class(TTable)
  private
    FIsAktif: TFieldDB;
    FAd: TFieldDB;
    FSoyad: TFieldDB;
    FAdSoyad: TFieldDB;
    FTel1: TFieldDB;
    FTel2: TFieldDB;
    FPersonelTipiID: TFieldDB;
    FPersonelTipi: TFieldDB;
    FBolumID: TFieldDB;
    FBolum: TFieldDB;
    FBirimID: TFieldDB;
    FBirim: TFieldDB;
    FGorevID: TFieldDB;
    FGorev: TFieldDB;
    FEMail: TFieldDB;
    FDogumTarihi: TFieldDB;
    FKanGrubu: TFieldDB;
    FCinsiyetID: TFieldDB;
    FCinsiyet: TFieldDB;
    FAskerlikDurumuID: TFieldDB;
    FAskerlikDurumu: TFieldDB;
    FMedeniDurumuID: TFieldDB;
    FMedeniDurumu: TFieldDB;
    FCocukSayisi: TFieldDB;
    FYakinAdi: TFieldDB;
    FYakinTelefon: TFieldDB;
    FAyakkabiNo: TFieldDB;
    FElbiseBedeni: TFieldDB;
    FGenelNot: TFieldDB;
    FTasimaServisiID: TFieldDB;
    FTasimaServisi: TFieldDB;
    FOzelNot: TFieldDB;
    FMaas: TFieldDB;
    FIkramiyeSayisi: TFieldDB;
    FIkramiyeTutar: TFieldDB;
    FKimlikNo: TFieldDB;
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

    FSetPersonelTipi: TSetPrsPersonelTipi;
    FSetBolum: TSetPrsBolum;
    FSetBirim: TSetPrsBirim;
    FSetGorev: TSetPrsGorev;
    FSetCinsiyet: TSetPrsCinsiyet;
    FSetAskerlik: TSetPrsAskerlikDurumu;
    FSetMedeniDurum: TSetPrsMedeniDurum;
    FSetServis: TSetPrsServisAraci;
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    Property Ad: TFieldDB read FAd write FAd;
    Property Soyad: TFieldDB read FSoyad write FSoyad;
    Property AdSoyad: TFieldDB read FAdSoyad write FAdSoyad;
    Property Tel1: TFieldDB read FTel1 write FTel1;
    Property Tel2: TFieldDB read FTel2 write FTel2;
    Property PersonelTipiID: TFieldDB read FPersonelTipiID write FPersonelTipiID;
    Property PersonelTipi: TFieldDB read FPersonelTipi write FPersonelTipi;
    Property BolumID: TFieldDB read FBolumID write FBolumID;
    Property Bolum: TFieldDB read FBolum write FBolum;
    Property BirimID: TFieldDB read FBirimID write FBirimID;
    Property Birim: TFieldDB read FBirim write FBirim;
    Property GorevID: TFieldDB read FGorevID write FGorevID;
    Property Gorev: TFieldDB read FGorev write FGorev;
    Property EMail: TFieldDB read FEMail write FEMail;
    Property DogumTarihi: TFieldDB read FDogumTarihi write FDogumTarihi;
    Property KanGrubu: TFieldDB read FKanGrubu write FKanGrubu;
    Property CinsiyetID: TFieldDB read FCinsiyetID write FCinsiyetID;
    Property Cinsiyet: TFieldDB read FCinsiyet write FCinsiyet;
    Property AskerlikDurumuID: TFieldDB read FAskerlikDurumuID write FAskerlikDurumuID;
    Property AskerlikDurumu: TFieldDB read FAskerlikDurumu write FAskerlikDurumu;
    Property MedeniDurumuID: TFieldDB read FMedeniDurumuID write FMedeniDurumuID;
    Property MedeniDurumu: TFieldDB read FMedeniDurumu write FMedeniDurumu;
    Property CocukSayisi: TFieldDB read FCocukSayisi write FCocukSayisi;
    Property YakinAdi: TFieldDB read FYakinAdi write FYakinAdi;
    Property YakinTelefon: TFieldDB read FYakinTelefon write FYakinTelefon;
    Property AyakkabiNo: TFieldDB read FAyakkabiNo write FAyakkabiNo;
    Property ElbiseBedeni: TFieldDB read FElbiseBedeni write FElbiseBedeni;
    Property GenelNot: TFieldDB read FGenelNot write FGenelNot;
    Property TasimaServisiID: TFieldDB read FTasimaServisiID write FTasimaServisiID;
    Property TasimaServisi: TFieldDB read FTasimaServisi write FTasimaServisi;
    Property OzelNot: TFieldDB read FOzelNot write FOzelNot;
    property Maas: TFieldDB read FMaas write FMaas;
    property IkramiyeSayisi: TFieldDB read FIkramiyeSayisi write FIkramiyeSayisi;
    property IkramiyeTutar: TFieldDB read FIkramiyeTutar write FIkramiyeTutar;
    property KimlikNo: TFieldDB read FKimlikNo write FKimlikNo;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;  //veri tabaný alaný deðil not a database field
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir; //veri tabaný alaný deðil not a database field
    Property Ilce: TFieldDB read FIlce write FIlce;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property PostaKutusu: TFieldDB read FPostaKutusu write FPostaKutusu;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property WebSite: TFieldDB read FWebSite write FWebSite;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.PrsPersonelGecmisi;

constructor TPrsPersonel.Create(ADatabase: TDatabase);
begin
  TableName := 'prs_personel';
  TableSourceCode := MODULE_PRS_KAYIT;
  inherited Create(ADatabase);

  FSetPersonelTipi := TSetPrsPersonelTipi.Create(Database);
  FSetBolum := TSetPrsBolum.Create(Database);
  FSetBirim := TSetPrsBirim.Create(Database);
  FSetGorev := TSetPrsGorev.Create(Database);
  FSetCinsiyet := TSetPrsCinsiyet.Create(Database);
  FSetAskerlik := TSetPrsAskerlikDurumu.Create(Database);
  FSetMedeniDurum := TSetPrsMedeniDurum.Create(Database);
  FSetServis := TSetPrsServisAraci.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSysSehir := TSysSehir.Create(Database);

  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, True, Self, 'Aktif?');
  FAd := TFieldDB.Create('ad', ftString, '', Self, 'Ad');
  FSoyad := TFieldDB.Create('soyad', ftString, '', Self, 'Soyad');
  FAdSoyad := TFieldDB.Create('ad_soyad', ftString, '', Self, 'Ad Soyad');
  FTel1 := TFieldDB.Create('tel1', ftString, '', Self, 'Telefon 1');
  FTel2 := TFieldDB.Create('tel2', ftString, '', Self, 'Telefon 2');
  FPersonelTipiID := TFieldDB.Create('personel_tipi_id', ftInteger, 0, Self, 'Personel Tipi ID');
  FPersonelTipi := TFieldDB.Create(FSetPersonelTipi.PersonelTipi.FieldName, FSetPersonelTipi.PersonelTipi.DataType, '', Self, 'Personel Tipi');
  FBolumID := TFieldDB.Create('bolum_id', ftInteger, 0, Self, 'Bölüm ID');
  FBolum := TFieldDB.Create(FSetBolum.Bolum.FieldName, FSetBolum.Bolum.DataType, '', Self, 'Bölüm');
  FBirimID := TFieldDB.Create('birim_id', ftInteger, 0, Self, 'Birim ID');
  FBirim := TFieldDB.Create(FSetBirim.Birim.FieldName, FSetBirim.Birim.DataType, '', Self, 'Birim');
  FGorevID := TFieldDB.Create('gorev_id', ftInteger, 0, Self, 'Görev ID');
  FGorev := TFieldDB.Create(FSetGorev.Gorev.FieldName, FSetGorev.Gorev.DataType, 0, Self, 'Görev');
  FEMail := TFieldDB.Create('email', ftString, '', Self, 'E-Posta');
  FDogumTarihi := TFieldDB.Create('dogum_tarihi', ftDate, 0, Self, 'Doðum Tarihi');
  FKanGrubu := TFieldDB.Create('kan_grubu', ftString, '', Self, 'Kan Grubu');
  FCinsiyetID := TFieldDB.Create('cinsiyet_id', ftInteger, 0, Self, 'Cinsiyet ID');
  FCinsiyet := TFieldDB.Create(FSetCinsiyet.Cinsiyet.FieldName, FSetCinsiyet.Cinsiyet.DataType, 0, Self, 'Cinsiyet');
  FAskerlikDurumuID := TFieldDB.Create('askerlik_durumu_id', ftInteger, 0, Self, 'Askerlik Durumu ID');
  FAskerlikDurumu := TFieldDB.Create(FSetAskerlik.AskerlikDurumu.FieldName, FSetAskerlik.AskerlikDurumu.DataType, '', Self, 'Askerlik Durumu');
  FMedeniDurumuID := TFieldDB.Create('medeni_durumu_id', ftInteger, 0, Self, 'Medeni Durum ID');
  FMedeniDurumu := TFieldDB.Create(FSetMedeniDurum.MedeniDurum.FieldName, FSetMedeniDurum.MedeniDurum.DataType, '', Self, 'Medeni Durum');
  FCocukSayisi := TFieldDB.Create('cocuk_sayisi', ftInteger, 0, Self, 'Çocuk Sayýsý');
  FYakinAdi := TFieldDB.Create('yakin_adi', ftString, '', Self, 'Yakýn Adý');
  FYakinTelefon := TFieldDB.Create('yakin_telefon', ftString, '', Self, 'Yakýn Telefon');
  FAyakkabiNo := TFieldDB.Create('ayakkabi_no', ftInteger, 0, Self, 'Ayakkabý No');
  FElbiseBedeni := TFieldDB.Create('elbise_bedeni', ftString, '', Self, 'Elbise Bedeni');
  FGenelNot := TFieldDB.Create('genel_not', ftString, '', Self, 'Genel Not');
  FTasimaServisiID := TFieldDB.Create('tasima_servisi_id', ftInteger, 0, Self, 'Personel Servis ID');
  FTasimaServisi := TFieldDB.Create(FSetServis.AracAdi.FieldName, FSetServis.AracAdi.DataType, '', Self, 'Personel Servisi');
  FOzelNot := TFieldDB.Create('ozel_not', ftString, '', Self, 'Özel Note');
  FMaas := TFieldDB.Create('maas', ftFMTBcd, 0, Self, 'Maaþ');
  FIkramiyeSayisi := TFieldDB.Create('ikramiye_sayisi', ftInteger, 0, Self, 'Ýkramiye Sayýsý');
  FIkramiyeTutar := TFieldDB.Create('ikramiye_tutar', ftFMTBcd, 0, Self, 'Ýkramiye Tutar');
  FKimlikNo := TFieldDB.Create('kimlik_no', ftString, '', Self, 'TC No');
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
  FWebSite := TFieldDB.Create('web_site', ftString, '', Self, 'Web Sistesi');
end;

destructor TPrsPersonel.Destroy;
begin
  FSetPersonelTipi.Free;
  FSetBolum.Free;
  FSetBirim.Free;
  FSetGorev.Free;
  FSetCinsiyet.Free;
  FSetAskerlik.Free;
  FSetMedeniDurum.Free;
  FSetServis.Free;
  FSysUlke.Free;
  FSysSehir.Free;

  inherited;
end;

procedure TPrsPersonel.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FAd.FieldName,
        TableName + '.' + FSoyad.FieldName,
        TableName + '.' + FAdSoyad.FieldName,
        TableName + '.' + FTel1.FieldName,
        TableName + '.' + FTel2.FieldName,
        TableName + '.' + FPersonelTipiID.FieldName,
        addField(FSetPersonelTipi.TableName, FSetPersonelTipi.PersonelTipi.FieldName, FPersonelTipi.FieldName),
        TableName + '.' + FBolumID.FieldName,
        addField(FSetBolum.TableName, FSetBolum.Bolum.FieldName, FBolum.FieldName),
        TableName + '.' + FBirimID.FieldName,
        addField(FSetBirim.TableName, FSetBirim.Birim.FieldName, FBirim.FieldName),
        TableName + '.' + FGorevID.FieldName,
        addField(FSetGorev.TableName, FSetGorev.Gorev.FieldName, FGorev.FieldName),
        TableName + '.' + FEMail.FieldName,
        TableName + '.' + FDogumTarihi.FieldName,
        TableName + '.' + FKanGrubu.FieldName,
        TableName + '.' + FCinsiyetID.FieldName,
        addField(FSetCinsiyet.TableName, FSetCinsiyet.Cinsiyet.FieldName, FCinsiyet.FieldName),
        TableName + '.' + FAskerlikDurumuID.FieldName,
        addField(FSetAskerlik.TableName, FSetAskerlik.AskerlikDurumu.FieldName, FAskerlikDurumu.FieldName),
        TableName + '.' + FMedeniDurumuID.FieldName,
        addField(FSetMedeniDurum.TableName, FSetMedeniDurum.MedeniDurum.FieldName, FMedeniDurumu.FieldName),
        TableName + '.' + FCocukSayisi.FieldName,
        TableName + '.' + FYakinAdi.FieldName,
        TableName + '.' + FYakinTelefon.FieldName,
        TableName + '.' + FAyakkabiNo.FieldName,
        TableName + '.' + FElbiseBedeni.FieldName,
        TableName + '.' + FGenelNot.FieldName,
        TableName + '.' + FTasimaServisiID.FieldName,
        addField(FSetServis.TableName, FSetServis.AracAdi.FieldName, FTasimaServisi.FieldName),
        TableName + '.' + FOzelNot.FieldName,
        TableName + '.' + FMaas.FieldName,
        TableName + '.' + FIkramiyeSayisi.FieldName,
        TableName + '.' + FIkramiyeTutar.FieldName,
        TableName + '.' + FKimlikNo.FieldName + '::varchar(32)',
        TableName + '.' + FUlkeID.FieldName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlke.FieldName),
        TableName + '.' + FSehirID.FieldName,
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehir.FieldName),
        TableName + '.' + FIlce.FieldName,
        TableName + '.' + FMahalle.FieldName,
        TableName + '.' + FCadde.FieldName,
        TableName + '.' + FSokak.FieldName,
        TableName + '.' + FBinaAdi.FieldName,
        TableName + '.' + FKapiNo.FieldName,
        TableName + '.' + FPostaKutusu.FieldName,
        TableName + '.' + FPostaKodu.FieldName,
        TableName + '.' + FWebSite.FieldName
      ], [
        addJoin(jtLeft, FSetPersonelTipi.TableName, FSetPersonelTipi.Id.FieldName, TableName, FPersonelTipiID.FieldName),
        addJoin(jtLeft, FSetBolum.TableName, FSetBolum.Id.FieldName, TableName, FBolumID.FieldName),
        addJoin(jtLeft, FSetBirim.TableName, FSetBirim.Id.FieldName, TableName, FBirimID.FieldName),
        addJoin(jtLeft, FSetGorev.TableName, FSetGorev.Id.FieldName, TableName, FGorevID.FieldName),
        addJoin(jtLeft, FSetCinsiyet.TableName, FSetCinsiyet.Id.FieldName, TableName, FCinsiyetID.FieldName),
        addJoin(jtLeft, FSetAskerlik.TableName, FSetAskerlik.Id.FieldName, TableName, FAskerlikDurumuID.FieldName),
        addJoin(jtLeft, FSetMedeniDurum.TableName, FSetMedeniDurum.Id.FieldName, TableName, FMedeniDurumuID.FieldName),
        addJoin(jtLeft, FSetServis.TableName, FSetServis.Id.FieldName, TableName, FTasimaServisiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TPrsPersonel.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FAd.FieldName,
        TableName + '.' + FSoyad.FieldName,
        TableName + '.' + FAdSoyad.FieldName,
        TableName + '.' + FTel1.FieldName,
        TableName + '.' + FTel2.FieldName,
        TableName + '.' + FPersonelTipiID.FieldName,
        addField(FSetPersonelTipi.TableName, FSetPersonelTipi.PersonelTipi.FieldName, FPersonelTipi.FieldName),
        TableName + '.' + FBolumID.FieldName,
        addField(FSetBolum.TableName, FSetBolum.Bolum.FieldName, FBolum.FieldName),
        TableName + '.' + FBirimID.FieldName,
        addField(FSetBirim.TableName, FSetBirim.Birim.FieldName, FBirim.FieldName),
        TableName + '.' + FGorevID.FieldName,
        addField(FSetGorev.TableName, FSetGorev.Gorev.FieldName, FGorev.FieldName),
        TableName + '.' + FEMail.FieldName,
        TableName + '.' + FDogumTarihi.FieldName,
        TableName + '.' + FKanGrubu.FieldName,
        TableName + '.' + FCinsiyetID.FieldName,
        addField(FSetCinsiyet.TableName, FSetCinsiyet.Cinsiyet.FieldName, FCinsiyet.FieldName),
        TableName + '.' + FAskerlikDurumuID.FieldName,
        addField(FSetAskerlik.TableName, FSetAskerlik.AskerlikDurumu.FieldName, FAskerlikDurumu.FieldName),
        TableName + '.' + FMedeniDurumuID.FieldName,
        addField(FSetMedeniDurum.TableName, FSetMedeniDurum.MedeniDurum.FieldName, FMedeniDurumu.FieldName),
        TableName + '.' + FCocukSayisi.FieldName,
        TableName + '.' + FYakinAdi.FieldName,
        TableName + '.' + FYakinTelefon.FieldName,
        TableName + '.' + FAyakkabiNo.FieldName,
        TableName + '.' + FElbiseBedeni.FieldName,
        TableName + '.' + FGenelNot.FieldName,
        TableName + '.' + FTasimaServisiID.FieldName,
        addField(FSetServis.TableName, FSetServis.AracAdi.FieldName, FTasimaServisi.FieldName),
        TableName + '.' + FOzelNot.FieldName,
        TableName + '.' + FMaas.FieldName,
        TableName + '.' + FIkramiyeSayisi.FieldName,
        TableName + '.' + FIkramiyeTutar.FieldName,
        TableName + '.' + FKimlikNo.FieldName + '::varchar(32)',
        TableName + '.' + FUlkeID.FieldName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlke.FieldName),
        TableName + '.' + FSehirID.FieldName,
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehir.FieldName),
        TableName + '.' + FIlce.FieldName,
        TableName + '.' + FMahalle.FieldName,
        TableName + '.' + FCadde.FieldName,
        TableName + '.' + FSokak.FieldName,
        TableName + '.' + FBinaAdi.FieldName,
        TableName + '.' + FKapiNo.FieldName,
        TableName + '.' + FPostaKutusu.FieldName,
        TableName + '.' + FPostaKodu.FieldName,
        TableName + '.' + FWebSite.FieldName
      ], [
        addJoin(jtLeft, FSetPersonelTipi.TableName, FSetPersonelTipi.Id.FieldName, TableName, FPersonelTipiID.FieldName),
        addJoin(jtLeft, FSetBolum.TableName, FSetBolum.Id.FieldName, TableName, FBolumID.FieldName),
        addJoin(jtLeft, FSetBirim.TableName, FSetBirim.Id.FieldName, TableName, FBirimID.FieldName),
        addJoin(jtLeft, FSetGorev.TableName, FSetGorev.Id.FieldName, TableName, FGorevID.FieldName),
        addJoin(jtLeft, FSetCinsiyet.TableName, FSetCinsiyet.Id.FieldName, TableName, FCinsiyetID.FieldName),
        addJoin(jtLeft, FSetAskerlik.TableName, FSetAskerlik.Id.FieldName, TableName, FAskerlikDurumuID.FieldName),
        addJoin(jtLeft, FSetMedeniDurum.TableName, FSetMedeniDurum.Id.FieldName, TableName, FMedeniDurumuID.FieldName),
        addJoin(jtLeft, FSetServis.TableName, FSetServis.Id.FieldName, TableName, FTasimaServisiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
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

procedure TPrsPersonel.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIsAktif.FieldName,
        FAd.FieldName,
        FSoyad.FieldName,
        FAdSoyad.FieldName,
        FTel1.FieldName,
        FTel2.FieldName,
        FPersonelTipiID.FieldName,
        FBolumID.FieldName,
        FBirimID.FieldName,
        FGorevID.FieldName,
        FEMail.FieldName,
        FDogumTarihi.FieldName,
        FKanGrubu.FieldName,
        FCinsiyetID.FieldName,
        FAskerlikDurumuID.FieldName,
        FMedeniDurumuID.FieldName,
        FCocukSayisi.FieldName,
        FYakinAdi.FieldName,
        FYakinTelefon.FieldName,
        FAyakkabiNo.FieldName,
        FElbiseBedeni.FieldName,
        FGenelNot.FieldName,
        FTasimaServisiID.FieldName,
        FOzelNot.FieldName,
        FMaas.FieldName,
        FIkramiyeSayisi.FieldName,
        FIkramiyeTutar.FieldName,
        FKimlikNo.FieldName,
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
        FWebSite.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TPrsPersonel.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIsAktif.FieldName,
        FAd.FieldName,
        FSoyad.FieldName,
        FAdSoyad.FieldName,
        FTel1.FieldName,
        FTel2.FieldName,
        FPersonelTipiID.FieldName,
        FBolumID.FieldName,
        FBirimID.FieldName,
        FGorevID.FieldName,
        FEMail.FieldName,
        FDogumTarihi.FieldName,
        FKanGrubu.FieldName,
        FCinsiyetID.FieldName,
        FAskerlikDurumuID.FieldName,
        FMedeniDurumuID.FieldName,
        FCocukSayisi.FieldName,
        FYakinAdi.FieldName,
        FYakinTelefon.FieldName,
        FAyakkabiNo.FieldName,
        FElbiseBedeni.FieldName,
        FGenelNot.FieldName,
        FTasimaServisiID.FieldName,
        FOzelNot.FieldName,
        FMaas.FieldName,
        FIkramiyeSayisi.FieldName,
        FIkramiyeTutar.FieldName,
        FKimlikNo.FieldName,
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
        FWebSite.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.Notify;
  end;
end;

procedure TPrsPersonel.BusinessDelete(APermissionControl: Boolean);
//var
//  n1: Integer;
begin
//  for n1 := 0 to FPrsEhliyet.List.Count-1 do
//  begin
//    if TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Deleted then
//      TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Delete(False);
//  end;
  Self.Delete(APermissionControl);
end;

procedure TPrsPersonel.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
//var
//  n1, nID: Integer;
begin
{$IFDEF CRUD_MODE_SP}
  Self.Adres.SpInsert.ExecProc;
  Self.AdresID.Value := Self.Adres.SpInsert.ParamByName('result').AsInteger;
  Self.SpInsert.ExecProc;
  AID := Self.SpInsert.ParamByName('result').AsInteger;
{$ELSE IFDEF CRUD_MODE_PURE_SQL}
//  for n1 := 0 to FPrsEhliyet.List.Count-1 do
//  begin
//    if TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Id.Value < 0 then
//      TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Insert(nID, False);
//  end;

  Self.Insert(AID, APermissionControl);
{$ENDIF}
end;

procedure TPrsPersonel.BusinessUpdate(APermissionControl: Boolean);
//var
//  n1, nID: Integer;
begin
//  for n1 := 0 to FPrsEhliyet.List.Count-1 do
//  begin
//    if TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Id.Value < 0 then
//      TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Insert(nID, False)
//    else
//      TPrsEhliyetBilgisi(FPrsEhliyet.List[n1]).Update(False);
//  end;
  Self.Update(APermissionControl);
end;

function TPrsPersonel.Clone():TTable;
begin
  Result := TPrsPersonel.Create(Database);
  CloneClassContent(Self, Result);
//  CloneClassContent(Self.FPrsEhliyet, TPrsPersonel(Result).FPrsEhliyet);
end;

end.
