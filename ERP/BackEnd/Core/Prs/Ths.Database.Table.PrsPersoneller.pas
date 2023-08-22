unit Ths.Database.Table.PrsPersoneller;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetPrsPersonelTipleri,
  Ths.Database.Table.SetPrsBolumler,
  Ths.Database.Table.SetPrsBirimler,
  Ths.Database.Table.SetPrsGorevler,
  Ths.Database.Table.SetPrsTasimaServisleri,
  Ths.Database.Table.SysAdresler,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.PrsEhliyetler;

type
  TGender = (Erkek=0, Kadin=1);
  TMaritalStatus = (Bekar=0, Evli=1);
  TMilitaryState = (Yapti=0, Muaf=1);

  TPrsPersonel = class(TTable)
  private
    FAd: TFieldDB;
    FSoyad: TFieldDB;
    FAdSoyad: TFieldDB;
    FTel1: TFieldDB;
    FTel2: TFieldDB;
    FPersonelTipiID: TFieldDB;
    FPersonelTipi: TFieldDB;
    FBolum: TFieldDB;
    FBirimID: TFieldDB;
    FBirim: TFieldDB;
    FGorevID: TFieldDB;
    FGorev: TFieldDB;
    FDogumTarihi: TFieldDB;
    FKanGrubu: TFieldDB;
    FCinsiyet: TFieldDB;
    FAskerlikDurumu: TFieldDB;
    FMedeniDurum: TFieldDB;
    FCocukSayisi: TFieldDB;
    FYakinAdi: TFieldDB;
    FYakinTelefon: TFieldDB;
    FAyakkabiNo: TFieldDB;
    FElbiseBedeni: TFieldDB;
    FGenelNot: TFieldDB;
    FTasimaServisID: TFieldDB;
    FTasimaServis: TFieldDB;
    FOzelNot: TFieldDB;
    FMaas: TFieldDB;
    FIkramiyeSayisi: TFieldDB;
    FIkramiyeTutari: TFieldDB;
    FIdentification: TFieldDB;
    FAdresID: TFieldDB;

    FSetPrsPersonelTipi: TSetPrsPersonelTipi;
    FSetPrsBolum: TSetPrsBolum;
    FSetPrsBirim: TSetPrsBirim;
    FSetPrsGorev: TSetPrsGorev;
    FSetPrsServisAraci: TSetPrsTasimaServisi;
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    Adres: TSysAdres;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Ad: TFieldDB read FAd write FAd;
    Property Soyad: TFieldDB read FSoyad write FSoyad;
    Property AdSoyad: TFieldDB read FAdSoyad write FAdSoyad;
    Property Tel1: TFieldDB read FTel1 write FTel1;
    Property Tel2: TFieldDB read FTel2 write FTel2;
    Property PersonelTipiID: TFieldDB read FPersonelTipiID write FPersonelTipiID;
    Property PersonelTipi: TFieldDB read FPersonelTipi write FPersonelTipi;
    Property Bolum: TFieldDB read FBolum write FBolum;
    Property BirimID: TFieldDB read FBirimID write FBirimID;
    Property Birim: TFieldDB read FBirim write FBirim;
    Property GorevID: TFieldDB read FGorevID write FGorevID;
    Property Gorev: TFieldDB read FGorev write FGorev;
    Property DogumTarihi: TFieldDB read FDogumTarihi write FDogumTarihi;
    Property KanGrubu: TFieldDB read FKanGrubu write FKanGrubu;
    Property Cinsiyet: TFieldDB read FCinsiyet write FCinsiyet;
    Property AskerlikDurumu: TFieldDB read FAskerlikDurumu write FAskerlikDurumu;
    Property MedeniDurum: TFieldDB read FMedeniDurum write FMedeniDurum;
    Property CocukSayisi: TFieldDB read FCocukSayisi write FCocukSayisi;
    Property YakinAdi: TFieldDB read FYakinAdi write FYakinAdi;
    Property YakinTelefon: TFieldDB read FYakinTelefon write FYakinTelefon;
    Property AyakkabiNo: TFieldDB read FAyakkabiNo write FAyakkabiNo;
    Property ElbiseBedeni: TFieldDB read FElbiseBedeni write FElbiseBedeni;
    Property GenelNot: TFieldDB read FGenelNot write FGenelNot;
    Property TasimaServisID: TFieldDB read FTasimaServisID write FTasimaServisID;
    Property TasimaServis: TFieldDB read FTasimaServis write FTasimaServis;
    Property OzelNot: TFieldDB read FOzelNot write FOzelNot;
    property Maas: TFieldDB read FMaas write FMaas;
    property IkramiyeSayisi: TFieldDB read FIkramiyeSayisi write FIkramiyeSayisi;
    property IkramiyeTutari: TFieldDB read FIkramiyeTutari write FIkramiyeTutari;
    property Identification: TFieldDB read FIdentification write FIdentification;
    Property AdresID: TFieldDB read FAdresID write FAdresID;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TPrsPersonel.Create(ADatabase: TDatabase);
begin
  TableName := 'prs_personeller';
  TableSourceCode := MODULE_PRS_KAYIT;
  inherited Create(ADatabase);

  Adres := TSysAdres.Create(Database);

  FSetPrsPersonelTipi := TSetPrsPersonelTipi.Create(Database);
  FSetPrsBolum := TSetPrsBolum.Create(Database);
  FSetPrsBirim := TSetPrsBirim.Create(Database);
  FSetPrsGorev := TSetPrsGorev.Create(Database);
  FSetPrsServisAraci := TSetPrsTasimaServisi.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSysSehir := TSysSehir.Create(Database);

  FAd := TFieldDB.Create('ad', ftWideString, '', Self, 'Ad');
  FSoyad := TFieldDB.Create('soyad', ftWideString, '', Self, 'Soyad');
  FAdSoyad := TFieldDB.Create('ad_soyad', ftWideString, '', Self, 'Ad Soyad');
  FTel1 := TFieldDB.Create('tel1', ftWideString, '', Self, 'Telefon 1');
  FTel2 := TFieldDB.Create('tel2', ftWideString, '', Self, 'Telefon 2');
  FPersonelTipiID := TFieldDB.Create('personel_tipi_id', ftInteger, 0, Self, 'Personel Tipi ID');
  FPersonelTipi := TFieldDB.Create(FSetPrsPersonelTipi.PersonelTipi.FieldName, FSetPrsPersonelTipi.PersonelTipi.DataType, '', Self, 'Personel Tipi');
  FBolum := TFieldDB.Create(FSetPrsBolum.Bolum.FieldName, FSetPrsBolum.Bolum.DataType, FSetPrsBolum.Bolum.Value, Self, FSetPrsBolum.Bolum.Title);
  FBirimID := TFieldDB.Create('birim_id', ftInteger, 0, Self, 'Birim ID');
  FBirim := TFieldDB.Create(FSetPrsBirim.Birim.FieldName, FSetPrsBirim.Birim.DataType, '', Self, 'Birim');
  FGorevID := TFieldDB.Create('gorev_id', ftInteger, 0, Self, 'Görev ID');
  FGorev := TFieldDB.Create(FSetPrsGorev.Gorev.FieldName, FSetPrsGorev.Gorev.DataType, 0, Self, 'Görev');
  FDogumTarihi := TFieldDB.Create('dogum_tarihi', ftDate, 0, Self, 'Doðum Tarihi');
  FKanGrubu := TFieldDB.Create('kan_grubu', ftWideString, '', Self, 'Kan Grubu');
  FCinsiyet := TFieldDB.Create('cinsiyet', ftSmallInt, 0, Self, 'Cinsiyet');
  FAskerlikDurumu := TFieldDB.Create('askerlik_durumu', ftSmallInt, 0, Self, 'Askerlik Durumu');
  FMedeniDurum := TFieldDB.Create('medeni_durum', ftSmallInt, 0, Self, 'Medeni Durum');
  FCocukSayisi := TFieldDB.Create('cocuk_sayisi', ftInteger, 0, Self, 'Çocuk Sayýsý');
  FYakinAdi := TFieldDB.Create('yakin_adi', ftWideString, '', Self, 'Yakýn Adý');
  FYakinTelefon := TFieldDB.Create('yakin_telefon', ftWideString, '', Self, 'Yakýn Telefon');
  FAyakkabiNo := TFieldDB.Create('ayakkabi_no', ftInteger, 0, Self, 'Ayakkabý No');
  FElbiseBedeni := TFieldDB.Create('elbise_bedeni', ftWideString, '', Self, 'Elbise Bedeni');
  FGenelNot := TFieldDB.Create('genel_not', ftWideString, '', Self, 'Genel Not');
  FTasimaServisID := TFieldDB.Create('tasima_servis_id', ftInteger, 0, Self, 'Personel Servis ID');
  FTasimaServis := TFieldDB.Create(FSetPrsServisAraci.AracAdi.FieldName, FSetPrsServisAraci.AracAdi.DataType, '', Self, 'Personel Servisi');
  FOzelNot := TFieldDB.Create('ozel_not', ftWideString, '', Self, 'Özel Note');
  FMaas := TFieldDB.Create('maas', ftFMTBcd, 0, Self, 'Maaþ');
  FIkramiyeSayisi := TFieldDB.Create('ikramiye_sayisi', ftInteger, 0, Self, 'Ýkramiye Sayýsý');
  FIkramiyeTutari := TFieldDB.Create('ikramiye_tutar', ftFMTBcd, 0, Self, 'Ýkramiye Tutar');
  FIdentification := TFieldDB.Create('identification', ftWideString, '', Self, 'TC No');
  FAdresID := TFieldDB.Create('adres_id', ftLargeint, 0, Self, '');
end;

destructor TPrsPersonel.Destroy;
begin
  Adres.Free;

  FSetPrsPersonelTipi.Free;
  FSetPrsBolum.Free;
  FSetPrsBirim.Free;
  FSetPrsGorev.Free;
  FSetPrsServisAraci.Free;
  FSysUlke.Free;
  FSysSehir.Free;

  inherited;
end;

procedure TPrsPersonel.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FAd.QryName,
      FSoyad.QryName,
      FAdSoyad.QryName,
      FTel1.QryName,
      FTel2.QryName,
      FPersonelTipiID.QryName,
      addField(FSetPrsPersonelTipi.TableName, FSetPrsPersonelTipi.PersonelTipi.FieldName, FPersonelTipi.FieldName),
      addField(FSetPrsBolum.TableName, FSetPrsBolum.Bolum.FieldName, FBolum.FieldName),
      FBirimID.QryName,
      addField(FSetPrsBirim.TableName, FSetPrsBirim.Birim.FieldName, FBirim.FieldName),
      FGorevID.QryName,
      addField(FSetPrsGorev.TableName, FSetPrsGorev.Gorev.FieldName, FGorev.FieldName),
      FDogumTarihi.QryName,
      FKanGrubu.QryName,
      FCinsiyet.QryName,
      FAskerlikDurumu.QryName,
      FMedeniDurum.QryName,
      FCocukSayisi.QryName,
      FYakinAdi.QryName,
      FYakinTelefon.QryName,
      FAyakkabiNo.QryName,
      FElbiseBedeni.QryName,
      FGenelNot.QryName,
      FTasimaServisID.QryName,
      addField(FSetPrsServisAraci.TableName, FSetPrsServisAraci.AracAdi.FieldName, FTasimaServis.FieldName),
      FOzelNot.QryName,
      FMaas.QryName,
      FIkramiyeSayisi.QryName,
      FIkramiyeTutari.QryName,
      FIdentification.QryName + '::::varchar(32)',
      FAdresID.QryName
    ], [
      addJoin(jtLeft, FSetPrsPersonelTipi.TableName, FSetPrsPersonelTipi.Id.FieldName, TableName, FPersonelTipiID.FieldName),
      addJoin(jtLeft, FSetPrsBirim.TableName, FSetPrsBirim.Id.FieldName, TableName, FBirimID.FieldName),
      addJoin(jtLeft, FSetPrsBolum.TableName, FSetPrsBolum.Id.FieldName, FSetPrsBirim.TableName, FSetPrsBirim.BolumID.FieldName),
      addJoin(jtLeft, FSetPrsGorev.TableName, FSetPrsGorev.Id.FieldName, TableName, FGorevID.FieldName),
      addJoin(jtLeft, FSetPrsServisAraci.TableName, FSetPrsServisAraci.Id.FieldName, TableName, FTasimaServisID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TPrsPersonel.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FAd.QryName,
      FSoyad.QryName,
      FAdSoyad.QryName,
      FTel1.QryName,
      FTel2.QryName,
      FPersonelTipiID.QryName,
      addField(FSetPrsPersonelTipi.TableName, FSetPrsPersonelTipi.PersonelTipi.FieldName, FPersonelTipi.FieldName),
      addField(FSetPrsBolum.TableName, FSetPrsBolum.Bolum.FieldName, FBolum.FieldName),
      FBirimID.QryName,
      addField(FSetPrsBirim.TableName, FSetPrsBirim.Birim.FieldName, FBirim.FieldName),
      FGorevID.QryName,
      addField(FSetPrsGorev.TableName, FSetPrsGorev.Gorev.FieldName, FGorev.FieldName),
      FDogumTarihi.QryName,
      FKanGrubu.QryName,
      FCinsiyet.QryName,
      FAskerlikDurumu.QryName,
      FMedeniDurum.QryName,
      FCocukSayisi.QryName,
      FYakinAdi.QryName,
      FYakinTelefon.QryName,
      FAyakkabiNo.QryName,
      FElbiseBedeni.QryName,
      FGenelNot.QryName,
      FTasimaServisID.QryName,
      addField(FSetPrsServisAraci.TableName, FSetPrsServisAraci.AracAdi.FieldName, FTasimaServis.FieldName),
      FOzelNot.QryName,
      FMaas.QryName,
      FIkramiyeSayisi.QryName,
      FIkramiyeTutari.QryName,
      'cast(' + FIdentification.QryName + ' as varchar(32)) ' + FIdentification.FieldName,
      FAdresID.QryName
    ], [
      addJoin(jtLeft, FSetPrsPersonelTipi.TableName, FSetPrsPersonelTipi.Id.FieldName, TableName, FPersonelTipiID.FieldName),
      addJoin(jtLeft, FSetPrsBirim.TableName, FSetPrsBirim.Id.FieldName, TableName, FBirimID.FieldName),
      addJoin(jtLeft, FSetPrsBolum.TableName, FSetPrsBolum.Id.FieldName, FSetPrsBirim.TableName, FSetPrsBirim.BolumID.FieldName),
      addJoin(jtLeft, FSetPrsGorev.TableName, FSetPrsGorev.Id.FieldName, TableName, FGorevID.FieldName),
      addJoin(jtLeft, FSetPrsServisAraci.TableName, FSetPrsServisAraci.Id.FieldName, TableName, FTasimaServisID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TPrsPersonel.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FAd.FieldName,
      FSoyad.FieldName,
      FAdSoyad.FieldName,
      FTel1.FieldName,
      FTel2.FieldName,
      FPersonelTipiID.FieldName,
      FBirimID.FieldName,
      FGorevID.FieldName,
      FDogumTarihi.FieldName,
      FKanGrubu.FieldName,
      FCinsiyet.FieldName,
      FAskerlikDurumu.FieldName,
      FMedeniDurum.FieldName,
      FCocukSayisi.FieldName,
      FYakinAdi.FieldName,
      FYakinTelefon.FieldName,
      FAyakkabiNo.FieldName,
      FElbiseBedeni.FieldName,
      FGenelNot.FieldName,
      FTasimaServisID.FieldName,
      FOzelNot.FieldName,
      FMaas.FieldName,
      FIkramiyeSayisi.FieldName,
      FIkramiyeTutari.FieldName,
      FIdentification.FieldName,
      FAdresID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TPrsPersonel.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FAd.FieldName,
      FSoyad.FieldName,
      FAdSoyad.FieldName,
      FTel1.FieldName,
      FTel2.FieldName,
      FPersonelTipiID.FieldName,
      FBirimID.FieldName,
      FGorevID.FieldName,
      FDogumTarihi.FieldName,
      FKanGrubu.FieldName,
      FCinsiyet.FieldName,
      FAskerlikDurumu.FieldName,
      FMedeniDurum.FieldName,
      FCocukSayisi.FieldName,
      FYakinAdi.FieldName,
      FYakinTelefon.FieldName,
      FAyakkabiNo.FieldName,
      FElbiseBedeni.FieldName,
      FGenelNot.FieldName,
      FTasimaServisID.FieldName,
      FOzelNot.FieldName,
      FMaas.FieldName,
      FIkramiyeSayisi.FieldName,
      FIkramiyeTutari.FieldName,
      FIdentification.FieldName,
      FAdresID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TPrsPersonel.Clone():TTable;
begin
  Result := TPrsPersonel.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
