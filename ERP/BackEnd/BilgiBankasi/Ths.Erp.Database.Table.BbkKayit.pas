unit Ths.Erp.Database.Table.BbkKayit;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetBbkFirmaTipi,
  Ths.Erp.Database.Table.SetBbkCalismaDurumu,
  Ths.Erp.Database.Table.SetBbkFinansDurumu,
  Ths.Erp.Database.Table.SetBbkKayitTipi,
  Ths.Erp.Database.Table.SetBbkBolge,
  Ths.Erp.Database.Table.BbkBolgeSehir,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysUlke;

type
  TBbkKayit = class(TTable)
  private
    FKayitTipiID: TFieldDB;
    FKayitTipi: TFieldDB;
    FFirmaAdi: TFieldDB;
    FTel1: TFieldDB;
    FTel2: TFieldDB;
    FTel3: TFieldDB;
    FFax: TFieldDB;
    FEmail: TFieldDB;
    FWebAdres: TFieldDB;
    FYetkili1: TFieldDB;
    FYetkili1Tel: TFieldDB;
    FYetkili1Email: TFieldDB;
    FYetkili2: TFieldDB;
    FYetkili2Tel: TFieldDB;
    FYetkili2Email: TFieldDB;
    FAdres: TFieldDB;
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB;
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
    FNot1: TFieldDB;
    FNot2: TFieldDB;
    FNot3: TFieldDB;
    FFirmaTipiID: TFieldDB;
    FFirmaTipi: TFieldDb;
    FVergiDairesi: TFieldDB;
    FVergiNumarasi: TFieldDB;
    FKacYillikFirma: TFieldDB;
    FYillikAsansorSayisi: TFieldDB;
    FIsZiyaretEdilmesin: TFieldDB;
    FCalismaDurumuId: TFieldDB;
    FCalismaDurumu: TFieldDB;
    FCalistigiTedarikciler: TFieldDB;
    FFinansDurumuID: TFieldDB;
    FFinansDurumu: TFieldDB;
    FSevkiyatYetkilisi: TFieldDB;
    FSevkiyatYetkilisiTel: TFieldDB;
  protected
    FSetBbkFirmaTipi: TSetBbkFirmaTipi;
    FSetBbkKayitTipi: TSetBbkKayitTipi;
    FSetBbkCalismaDurumu: TSetBbkCalismaDurumu;
    FSetBbkFinansDurumu: TSetBbkFinansDurumu;
    FBBkBolge: TSetBbkBolge;
    FBolgeSehir: TBbkBolgeSehir;
    FCity: TSysSehir;
    FCountry: TSysUlke;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property KayitTipiID: TFieldDB read FKayitTipiID write FKayitTipiID;
    Property KayitTipi: TFieldDB read FKayitTipi write FKayitTipi;
    Property FirmaAdi: TFieldDB read FFirmaAdi write FFirmaAdi;
    Property Tel1: TFieldDB read FTel1 write FTel1;
    Property Tel2: TFieldDB read FTel2 write FTel2;
    Property Tel3: TFieldDB read FTel3 write FTel3;
    Property Fax: TFieldDB read FFax write FFax;
    Property Email: TFieldDB read FEmail write FEmail;
    Property WebAdres: TFieldDB read FWebAdres write FWebAdres;
    Property Yetkili1: TFieldDB read FYetkili1 write FYetkili1;
    Property Yetkili1Tel: TFieldDB read FYetkili1Tel write FYetkili1Tel;
    Property Yetkili1Email: TFieldDB read FYetkili1Email write FYetkili1Email;
    Property Yetkili2: TFieldDB read FYetkili2 write FYetkili2;
    Property Yetkili2Tel: TFieldDB read FYetkili2Tel write FYetkili2Tel;
    Property Yetkili2Email: TFieldDB read FYetkili2Email write FYetkili2Email;
    Property Adres: TFieldDB read FAdres write FAdres;
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;
    Property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    Property Bolge: TFieldDB read FBolge write FBolge;
    Property Not1: TFieldDB read FNot1 write FNot1;
    Property Not2: TFieldDB read FNot2 write FNot2;
    Property Not3: TFieldDB read FNot3 write FNot3;
    Property FirmaTipiID: TFieldDB read FFirmaTipiID write FFirmaTipiID;
    Property FirmaTipi: TFieldDB read FFirmaTipi write FFirmaTipi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNumarasi: TFieldDB read FVergiNumarasi write FVergiNumarasi;
    Property KacYillikFirma: TFieldDB read FKacYillikFirma write FKacYillikFirma;
    Property YillikAsansorSayisi: TFieldDB read FYillikAsansorSayisi write FYillikAsansorSayisi;
    Property IsZiyaretEdilmesin: TFieldDB read FIsZiyaretEdilmesin write FIsZiyaretEdilmesin;
    Property CalismaDurumuId: TFieldDB read FCalismaDurumuId write FCalismaDurumuId;
    Property CalismaDurumu: TFieldDB read FCalismaDurumu write FCalismaDurumu;
    Property CalistigiTedarikciler: TFieldDB read FCalistigiTedarikciler write FCalistigiTedarikciler;
    Property FinansDurumuID: TFieldDB read FFinansDurumuID write FFinansDurumuID;
    Property FinansDurumu: TFieldDB read FFinansDurumu write FFinansDurumu;
    Property SevkiyatYetkilisi: TFieldDB read FSevkiyatYetkilisi write FSevkiyatYetkilisi;
    Property SevkiyatYetkilisiTel: TFieldDB read FSevkiyatYetkilisiTel write FSevkiyatYetkilisiTel;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TBbkKayit.Create(ADatabase: TDatabase);
begin
  TableName := 'bbk_kayit';
  TableSourceCode := '6521';
  inherited Create(ADatabase);

  FSetBbkFirmaTipi := TSetBbkFirmaTipi.Create(Database);
  FSetBbkKayitTipi := TSetBbkKayitTipi.Create(Database);
  FSetBbkCalismaDurumu := TSetBbkCalismaDurumu.Create(Database);
  FSetBbkFinansDurumu := TSetBbkFinansDurumu.Create(Database);
  FBBkBolge := TSetBbkBolge.Create(Database);
  FBolgeSehir := TBbkBolgeSehir.Create(Database);
  FCity := TSysSehir.Create(Database);
  FCountry := TSysUlke.Create(Database);

  FKayitTipiID := TFieldDB.Create('kayit_tipi_id', ftInteger, 0, Self, '');
  FKayitTipi := TFieldDB.Create(FSetBbkKayitTipi.KayitTipi.FieldName, FSetBbkKayitTipi.KayitTipi.DataType, '', Self, '');
  FFirmaAdi := TFieldDB.Create('firma_adi', ftString, '', Self, '');
  FTel1 := TFieldDB.Create('tel1', ftString, '', Self, '');
  FTel2 := TFieldDB.Create('tel2', ftString, '', Self, '');
  FTel3 := TFieldDB.Create('tel3', ftString, '', Self, '');
  FFax := TFieldDB.Create('fax', ftString, '', Self, '');
  FEmail := TFieldDB.Create('email', ftString, '', Self, '');
  FWebAdres := TFieldDB.Create('web_adres', ftString, '', Self, '');
  FYetkili1 := TFieldDB.Create('yetkili1', ftString, '', Self, '');
  FYetkili1Tel := TFieldDB.Create('yetkili1_tel', ftString, '', Self, '');
  FYetkili1Email := TFieldDB.Create('yetkili1_email', ftString, '', Self, '');
  FYetkili2 := TFieldDB.Create('yetkili2', ftString, '', Self, '');
  FYetkili2Tel := TFieldDB.Create('yetkili2_tel', ftString, '', Self, '');
  FYetkili2Email := TFieldDB.Create('yetkili2_email', ftString, '', Self, '');
  FAdres := TFieldDB.Create('adres', ftString, '', Self, '');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, '');
  FSehir := TFieldDB.Create(FCity.SehirAdi.FieldName, FCity.SehirAdi.DataType, '', Self, '');
  FUlkeID := TFieldDB.Create(FCity.UlkeID.FieldName, FCity.UlkeID.DataType, 0, Self, '');
  FUlke := TFieldDB.Create(FCountry.UlkeAdi.FieldName, FCountry.UlkeAdi.DataType, '', Self, '');
  FBolgeID := TFieldDB.Create(FBolgeSehir.BolgeID.FieldName, FBolgeSehir.BolgeID.DataType, 0, Self, '');
  FBolge := TFieldDB.Create(FBolgeSehir.Bolge.FieldName, FBolgeSehir.Bolge.DataType, '', Self, '');
  FNot1 := TFieldDB.Create('not1', ftString, '', Self, '');
  FNot2 := TFieldDB.Create('not2', ftString, '', Self, '');
  FNot3 := TFieldDB.Create('not3', ftString, '', Self, '');
  FFirmaTipiID := TFieldDB.Create('firma_tipi_id', ftInteger, 0, Self, '');
  FFirmaTipi := TFieldDB.Create(FSetBbkFirmaTipi.FirmaTipi.FieldName, FSetBbkFirmaTipi.FirmaTipi.DataType, '', Self, '');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, '');
  FVergiNumarasi := TFieldDB.Create('vergi_numarasi', ftString, '', Self, '');
  FKacYillikFirma := TFieldDB.Create('kac_yillik_firma', ftInteger, 0, Self, '');
  FYillikAsansorSayisi := TFieldDB.Create('yillik_asansor_sayisi', ftInteger, 0, Self, '');
  FIsZiyaretEdilmesin := TFieldDB.Create('is_ziyaret_edilmesin', ftBoolean, False, Self, '');
  FCalismaDurumuId := TFieldDB.Create('calisma_durumu_id', ftInteger, 0, Self, '');
  FCalismaDurumu := TFieldDB.Create(FSetBbkCalismaDurumu.CalismaDurumu.FieldName, FSetBbkCalismaDurumu.CalismaDurumu.DataType, '', Self, '');
  FCalistigiTedarikciler := TFieldDB.Create('calistigi_tedarikciler', ftString, '', Self, '');
  FFinansDurumuID := TFieldDB.Create('finans_durumu_id', ftInteger, 0, Self, '');
  FFinansDurumu := TFieldDB.Create(FSetBbkFinansDurumu.FinansDurumu.FieldName, FSetBbkFinansDurumu.FinansDurumu.DataType, '', Self, '');
  FSevkiyatYetkilisi := TFieldDB.Create('sevkiyat_yetkilisi', ftString, '', Self, '');
  FSevkiyatYetkilisiTel := TFieldDB.Create('sevkiyat_yetkilisi_tel', ftString, '', Self, '');
end;

destructor TBbkKayit.Destroy;
begin
  FreeAndNil(FSetBbkFirmaTipi);
  FreeAndNil(FSetBbkKayitTipi);
  FreeAndNil(FSetBbkCalismaDurumu);
  FreeAndNil(FSetBbkFinansDurumu);
  FreeAndNil(FBBkBolge);
  FreeAndNil(FBolgeSehir);
  FreeAndNil(FCity);
  FreeAndNil(FCountry);

  inherited;
end;

procedure TBbkKayit.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKayitTipiID.FieldName,
        addField(FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.KayitTipi.FieldName, FKayitTipi.FieldName),
        TableName + '.' + FFirmaAdi.FieldName,
        TableName + '.' + FTel1.FieldName,
        TableName + '.' + FTel2.FieldName,
        TableName + '.' + FTel3.FieldName,
        TableName + '.' + FFax.FieldName,
        TableName + '.' + FEmail.FieldName,
        TableName + '.' + FWebAdres.FieldName,
        TableName + '.' + FYetkili1.FieldName,
        TableName + '.' + FYetkili1Tel.FieldName,
        TableName + '.' + FYetkili1Email.FieldName,
        TableName + '.' + FYetkili2.FieldName,
        TableName + '.' + FYetkili2Tel.FieldName,
        TableName + '.' + FYetkili2Email.FieldName,
        TableName + '.' + FAdres.FieldName,
        TableName + '.' + FSehirID.FieldName,
        addField(FCity.TableName, FCity.SehirAdi.FieldName, FSehir.FieldName),
        addField(FCity.TableName, FCity.UlkeID.FieldName, FUlkeID.FieldName),
        addField(FCountry.TableName, FCountry.UlkeAdi.FieldName, FUlke.FieldName),
        addField(FBBkBolge.TableName, FBBkBolge.Id.FieldName, FBolgeID.FieldName),
        addField(FBBkBolge.TableName, FBBkBolge.Bolge.FieldName, FBolge.FieldName),
        TableName + '.' + FNot1.FieldName,
        TableName + '.' + FNot2.FieldName,
        TableName + '.' + FNot3.FieldName,
        TableName + '.' + FFirmaTipiID.FieldName,
        addField(FSetBbkFirmaTipi.TableName, FSetBbkFirmaTipi.FirmaTipi.FieldName, FFirmaTipi.FieldName),
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNumarasi.FieldName,
        TableName + '.' + FKacYillikFirma.FieldName,
        TableName + '.' + FYillikAsansorSayisi.FieldName,
        TableName + '.' + FIsZiyaretEdilmesin.FieldName,
        TableName + '.' + FCalismaDurumuId.FieldName,
        addField(FSetBbkCalismaDurumu.TableName, FSetBbkCalismaDurumu.CalismaDurumu.FieldName, FCalismaDurumu.FieldName),
        TableName + '.' + FCalistigiTedarikciler.FieldName,
        TableName + '.' + FFinansDurumuID.FieldName,
        addField(FSetBbkFinansDurumu.TableName, FSetBbkFinansDurumu.FinansDurumu.FieldName, FFinansDurumu.FieldName),
        TableName + '.' + FSevkiyatYetkilisi.FieldName,
        TableName + '.' + FSevkiyatYetkilisiTel.FieldName
      ], [
        addJoin(jtLeft, FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.Id.FieldName, TableName, FKayitTipiID.FieldName),
        addJoin(jtLeft, FSetBbkFirmaTipi.TableName, FSetBbkFirmaTipi.Id.FieldName, TableName, FFirmaTipiID.FieldName),
        addJoin(jtLeft, FSetBbkCalismaDurumu.TableName, FSetBbkCalismaDurumu.Id.FieldName, TableName, FCalismaDurumuId.FieldName, 'cda'),
        addJoin(jtLeft, FSetBbkFinansDurumu.TableName, FSetBbkFinansDurumu.Id.FieldName, TableName, FFinansDurumuID.FieldName),
        addJoin(jtLeft, FCity.TableName, FCity.Id.FieldName, TableName, FSehirID.FieldName),
        addJoin(jtLeft, FCountry.TableName, FCountry.Id.FieldName, FCity.TableName, FCity.UlkeID.FieldName),
        addJoin(jtLeft, FBolgeSehir.TableName, FBolgeSehir.SehirID.FieldName, TableName, FSehirID.FieldName),
        addJoin(jtLeft, FBBkBolge.TableName, FBBkBolge.Id.FieldName, FBolgeSehir.TableName, FBolgeSehir.BolgeID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FKayitTipiID, 'Kayit Tipi ID', QueryOfDS);
      setFieldTitle(FKayitTipi, 'Kayýt Tipi', QueryOfDS);
      setFieldTitle(FFirmaAdi, 'Firma Adi', QueryOfDS);
      setFieldTitle(FTel1, 'Tel 1', QueryOfDS);
      setFieldTitle(FTel2, 'Tel 2', QueryOfDS);
      setFieldTitle(FTel3, 'Tel 3', QueryOfDS);
      setFieldTitle(FFax, 'Fax', QueryOfDS);
      setFieldTitle(FEmail, 'Email', QueryOfDS);
      setFieldTitle(FWebAdres, 'Web Adres', QueryOfDS);
      setFieldTitle(FYetkili1, 'Yetkili 1', QueryOfDS);
      setFieldTitle(FYetkili1Tel, 'Yetkili 1 Telefon', QueryOfDS);
      setFieldTitle(FYetkili1Email, 'Yetkili 1 Email', QueryOfDS);
      setFieldTitle(FYetkili2, 'Yetkili 2', QueryOfDS);
      setFieldTitle(FYetkili2Tel, 'Yetkili 2 Telefon', QueryOfDS);
      setFieldTitle(FYetkili2Email, 'Yetkili 2 Email', QueryOfDS);
      setFieldTitle(FAdres, 'Adres', QueryOfDS);
      setFieldTitle(FSehirID, 'Þehir ID', QueryOfDS);
      setFieldTitle(FSehir, 'Þehir', QueryOfDS);
      setFieldTitle(FUlkeID, 'Ülke ID', QueryOfDS);
      setFieldTitle(FUlke, 'Ülke', QueryOfDS);
      setFieldTitle(FBolgeID, 'Bölge ID', QueryOfDS);
      setFieldTitle(FBolge, 'Bölge', QueryOfDS);
      setFieldTitle(FNot1, 'Not 1', QueryOfDS);
      setFieldTitle(FNot2, 'Not 2', QueryOfDS);
      setFieldTitle(FNot3, 'Not 3', QueryOfDS);
      setFieldTitle(FFirmaTipiID, 'Firma Tipi ID', QueryOfDS);
      setFieldTitle(FFirmaTipi, 'Firma Tipi', QueryOfDS);
      setFieldTitle(FVergiDairesi, 'Vergi Dairesi', QueryOfDS);
      setFieldTitle(FVergiNumarasi, 'Vergi No', QueryOfDS);
      setFieldTitle(FKacYillikFirma, 'Kayýt Tipi', QueryOfDS);
      setFieldTitle(FYillikAsansorSayisi, 'Yillik Asansor Sayisi', QueryOfDS);
      setFieldTitle(FIsZiyaretEdilmesin, 'Is Ziyaret Edilmesin', QueryOfDS);
      setFieldTitle(FCalismaDurumuId, 'Calisma Durumu ID', QueryOfDS);
      setFieldTitle(FCalismaDurumu, 'Calisma Durumu', QueryOfDS);
      setFieldTitle(FCalistigiTedarikciler, 'Kayýt Tipi ID', QueryOfDS);
      setFieldTitle(FFinansDurumuID, 'Kayýt Tipi', QueryOfDS);
      setFieldTitle(FFinansDurumu, 'Firma Tipi', QueryOfDS);
      setFieldTitle(FSevkiyatYetkilisi, 'Kayýt Tipi ID', QueryOfDS);
      setFieldTitle(FSevkiyatYetkilisiTel, 'Kayýt Tipi', QueryOfDS);
    end;
  end;
end;

procedure TBbkKayit.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FKayitTipiID.FieldName,
        addField(FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.KayitTipi.FieldName, FKayitTipi.FieldName),
        TableName + '.' + FFirmaAdi.FieldName,
        TableName + '.' + FTel1.FieldName,
        TableName + '.' + FTel2.FieldName,
        TableName + '.' + FTel3.FieldName,
        TableName + '.' + FFax.FieldName,
        TableName + '.' + FEmail.FieldName,
        TableName + '.' + FWebAdres.FieldName,
        TableName + '.' + FYetkili1.FieldName,
        TableName + '.' + FYetkili1Tel.FieldName,
        TableName + '.' + FYetkili1Email.FieldName,
        TableName + '.' + FYetkili2.FieldName,
        TableName + '.' + FYetkili2Tel.FieldName,
        TableName + '.' + FYetkili2Email.FieldName,
        TableName + '.' + FAdres.FieldName,
        TableName + '.' + FSehirID.FieldName,
        addField(FCity.TableName, FCity.SehirAdi.FieldName, FSehir.FieldName),
        addField(FCity.TableName, FCity.UlkeID.FieldName, FUlkeID.FieldName),
        addField(FCountry.TableName, FCountry.UlkeAdi.FieldName, FUlke.FieldName),
        addField(FBBkBolge.TableName, FBBkBolge.Id.FieldName, FBolgeID.FieldName),
        addField(FBBkBolge.TableName, FBBkBolge.Bolge.FieldName, FBolge.FieldName),
        TableName + '.' + FNot1.FieldName,
        TableName + '.' + FNot2.FieldName,
        TableName + '.' + FNot3.FieldName,
        TableName + '.' + FFirmaTipiID.FieldName,
        addField(FSetBbkFirmaTipi.TableName, FSetBbkFirmaTipi.FirmaTipi.FieldName, FFirmaTipi.FieldName),
        TableName + '.' + FVergiDairesi.FieldName,
        TableName + '.' + FVergiNumarasi.FieldName,
        TableName + '.' + FKacYillikFirma.FieldName,
        TableName + '.' + FYillikAsansorSayisi.FieldName,
        TableName + '.' + FIsZiyaretEdilmesin.FieldName,
        TableName + '.' + FCalismaDurumuId.FieldName,
        addField(FSetBbkCalismaDurumu.TableName, FSetBbkCalismaDurumu.CalismaDurumu.FieldName, FCalismaDurumu.FieldName),
        TableName + '.' + FCalistigiTedarikciler.FieldName,
        TableName + '.' + FFinansDurumuID.FieldName,
        addField(FSetBbkFinansDurumu.TableName, FSetBbkFinansDurumu.FinansDurumu.FieldName, FFinansDurumu.FieldName),
        TableName + '.' + FSevkiyatYetkilisi.FieldName,
        TableName + '.' + FSevkiyatYetkilisiTel.FieldName
      ], [
        addJoin(jtLeft, FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.Id.FieldName, TableName, FKayitTipiID.FieldName),
        addJoin(jtLeft, FSetBbkFirmaTipi.TableName, FSetBbkFirmaTipi.Id.FieldName, TableName, FFirmaTipiID.FieldName),
        addJoin(jtLeft, FSetBbkCalismaDurumu.TableName, FSetBbkCalismaDurumu.Id.FieldName, TableName, FCalismaDurumuId.FieldName),
        addJoin(jtLeft, FSetBbkFinansDurumu.TableName, FSetBbkFinansDurumu.Id.FieldName, TableName, FFinansDurumuID.FieldName),
        addJoin(jtLeft, FCity.TableName, FCity.Id.FieldName, TableName, FSehirID.FieldName),
        addJoin(jtLeft, FCountry.TableName, FCountry.Id.FieldName, FCity.TableName, FCity.UlkeID.FieldName),
        addJoin(jtLeft, FBolgeSehir.TableName, FBolgeSehir.SehirID.FieldName, TableName, FSehirID.FieldName),
        addJoin(jtLeft, FBBkBolge.TableName, FBBkBolge.Id.FieldName, FBolgeSehir.TableName, FBolgeSehir.BolgeID.FieldName),
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

procedure TBbkKayit.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpInsert.ExecProc;
      AID := SpInsert.ParamByName('result').AsInteger;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfInsert do
      begin
        Close;
        SQL.Clear;

        SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
          FKayitTipiID.FieldName,
          FFirmaAdi.FieldName,
          FTel1.FieldName,
          FTel2.FieldName,
          FTel3.FieldName,
          FFax.FieldName,
          FEmail.FieldName,
          FWebAdres.FieldName,
          FYetkili1.FieldName,
          FYetkili1Tel.FieldName,
          FYetkili1Email.FieldName,
          FYetkili2.FieldName,
          FYetkili2Tel.FieldName,
          FYetkili2Email.FieldName,
          FAdres.FieldName,
          FSehirID.FieldName,
          FNot1.FieldName,
          FNot2.FieldName,
          FNot3.FieldName,
          FFirmaTipiID.FieldName,
          FVergiDairesi.FieldName,
          FVergiNumarasi.FieldName,
          FKacYillikFirma.FieldName,
          FYillikAsansorSayisi.FieldName,
          FIsZiyaretEdilmesin.FieldName,
          FCalismaDurumuId.FieldName,
          FCalistigiTedarikciler.FieldName,
          FFinansDurumuID.FieldName,
          FSevkiyatYetkilisi.FieldName,
          FSevkiyatYetkilisiTel.FieldName
        ]);

        PrepareInsertQueryParams;

        Open;
        if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
        then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
        else  AID := 0;

        EmptyDataSet;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

procedure TBbkKayit.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpUpdate.ExecProc;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfUpdate do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
          FKayitTipiID.FieldName,
          FFirmaAdi.FieldName,
          FTel1.FieldName,
          FTel2.FieldName,
          FTel3.FieldName,
          FFax.FieldName,
          FEmail.FieldName,
          FWebAdres.FieldName,
          FYetkili1.FieldName,
          FYetkili1Tel.FieldName,
          FYetkili1Email.FieldName,
          FYetkili2.FieldName,
          FYetkili2Tel.FieldName,
          FYetkili2Email.FieldName,
          FAdres.FieldName,
          FSehirID.FieldName,
          FNot1.FieldName,
          FNot2.FieldName,
          FNot3.FieldName,
          FFirmaTipiID.FieldName,
          FVergiDairesi.FieldName,
          FVergiNumarasi.FieldName,
          FKacYillikFirma.FieldName,
          FYillikAsansorSayisi.FieldName,
          FIsZiyaretEdilmesin.FieldName,
          FCalismaDurumuId.FieldName,
          FCalistigiTedarikciler.FieldName,
          FFinansDurumuID.FieldName,
          FSevkiyatYetkilisi.FieldName,
          FSevkiyatYetkilisiTel.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

function TBbkKayit.Clone: TTable;
begin
  Result := TBbkKayit.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
