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
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysBolge;

type
  TBbkKayit = class(TTable)
  private
    FFirmaAdi: TFieldDB;
    FTel1: TFieldDB;
    FTel2: TFieldDB;
    FTel3: TFieldDB;
    FFax: TFieldDB;
    FEmail: TFieldDB;
    FWeb: TFieldDB;
    FYetkili1: TFieldDB;
    FYetkili1Tel: TFieldDB;
    FYetkili1Email: TFieldDB;
    FYetkili2: TFieldDB;
    FYetkili2Tel: TFieldDB;
    FYetkili2Email: TFieldDB;
    FAdres: TFieldDB;
    FSehirAdiID: TFieldDB;
    FSehirAdi: TFieldDB;
    FUlkeAdiID: TFieldDB;
    FUlkeAdi: TFieldDB;
    FBolgeAdiID: TFieldDB;
    FBolgeAdi: TFieldDB;
    FNot1: TFieldDB;
    FNot2: TFieldDB;
    FNot3: TFieldDB;
    FFirmaTipiID: TFieldDB;
    FFirmaTipi: TFieldDb;
    FVergiDairesi: TFieldDB;
    FVergiNumarasi: TFieldDB;
    FKacYillikFirma: TFieldDB;
    FCalismaDurumuId: TFieldDB;
    FCalismaDurumu: TFieldDB;
    FCalistigiTedarikciler: TFieldDB;
    FFinansDurumuID: TFieldDB;
    FFinansDurumu: TFieldDB;
    FSevkiyatYetkilisi: TFieldDB;
    FSevkiyatYetkilisiTel: TFieldDB;
  protected
    FBbkFirmaTipi: TSetBbkFirmaTipi;
    FBbkCalismaDurumu: TSetBbkCalismaDurumu;
    FBbkFinansDurumu: TSetBbkFinansDurumu;
    FSysSehir: TSysSehir;
    FSysUlke: TSysUlke;
    FSysBolge: TSysBolge;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FirmaAdi: TFieldDB read FFirmaAdi write FFirmaAdi;
    Property Tel1: TFieldDB read FTel1 write FTel1;
    Property Tel2: TFieldDB read FTel2 write FTel2;
    Property Tel3: TFieldDB read FTel3 write FTel3;
    Property Fax: TFieldDB read FFax write FFax;
    Property Email: TFieldDB read FEmail write FEmail;
    Property Web: TFieldDB read FWeb write FWeb;
    Property Yetkili1: TFieldDB read FYetkili1 write FYetkili1;
    Property Yetkili1Tel: TFieldDB read FYetkili1Tel write FYetkili1Tel;
    Property Yetkili1Email: TFieldDB read FYetkili1Email write FYetkili1Email;
    Property Yetkili2: TFieldDB read FYetkili2 write FYetkili2;
    Property Yetkili2Tel: TFieldDB read FYetkili2Tel write FYetkili2Tel;
    Property Yetkili2Email: TFieldDB read FYetkili2Email write FYetkili2Email;
    Property Adres: TFieldDB read FAdres write FAdres;
    Property SehirAdiID: TFieldDB read FSehirAdiID write FSehirAdiID;
    Property SehirAdi: TFieldDB read FSehirAdi write FSehirAdi;
    Property UlkeAdiID: TFieldDB read FUlkeAdiID write FUlkeAdiID;
    Property UlkeAdi: TFieldDB read FUlkeAdi write FUlkeAdi;
    Property BolgeAdiID: TFieldDB read FBolgeAdiID write FBolgeAdiID;
    Property BolgeAdi: TFieldDB read FBolgeAdi write FBolgeAdi;
    Property Not1: TFieldDB read FNot1 write FNot1;
    Property Not2: TFieldDB read FNot2 write FNot2;
    Property Not3: TFieldDB read FNot3 write FNot3;
    Property FirmaTipiID: TFieldDB read FFirmaTipiID write FFirmaTipiID;
    Property FirmaTipi: TFieldDB read FFirmaTipi write FFirmaTipi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNumarasi: TFieldDB read FVergiNumarasi write FVergiNumarasi;
    Property KacYillikFirma: TFieldDB read FKacYillikFirma write FKacYillikFirma;
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
  TableSourceCode := MODULE_BBK_KAYIT;
  inherited Create(ADatabase);

  FBbkFirmaTipi := TSetBbkFirmaTipi.Create(Database);
  FBbkCalismaDurumu := TSetBbkCalismaDurumu.Create(Database);
  FBbkFinansDurumu := TSetBbkFinansDurumu.Create(Database);
  FSysSehir := TSysSehir.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSysBolge := TSysBolge.Create(Database);

  FFirmaAdi := TFieldDB.Create('firma_adi', ftString, '', Self, 'Firma Adý');
  FTel1 := TFieldDB.Create('tel1', ftString, '', Self, 'Tel1');
  FTel2 := TFieldDB.Create('tel2', ftString, '', Self, 'Tel2');
  FTel3 := TFieldDB.Create('tel3', ftString, '', Self, 'Tel3');
  FFax := TFieldDB.Create('fax', ftString, '', Self, 'Faks');
  FEmail := TFieldDB.Create('email', ftString, '', Self, 'E-Mail');
  FWeb := TFieldDB.Create('web', ftString, '', Self, 'Web');
  FYetkili1 := TFieldDB.Create('yetkili1', ftString, '', Self, 'Yetkili 1');
  FYetkili1Tel := TFieldDB.Create('yetkili1_tel', ftString, '', Self, 'Yetkili 1 Tel');
  FYetkili1Email := TFieldDB.Create('yetkili1_email', ftString, '', Self, 'Yetkili 1 Mail');
  FYetkili2 := TFieldDB.Create('yetkili2', ftString, '', Self, 'Yetkili 2');
  FYetkili2Tel := TFieldDB.Create('yetkili2_tel', ftString, '', Self, 'Yetkili 2 Tel');
  FYetkili2Email := TFieldDB.Create('yetkili2_email', ftString, '', Self, 'Yetkili 2 Mail');
  FAdres := TFieldDB.Create('adres', ftString, '', Self, 'Adres');
  FSehirAdiID := TFieldDB.Create('sehir_adi_id', ftInteger, 0, Self, 'Þehir ID');
  FSehirAdi := TFieldDB.Create(FSysSehir.SehirAdi.FieldName, FSysSehir.SehirAdi.DataType, '', Self, 'Þehir');
  FUlkeAdiID := TFieldDB.Create(FSysSehir.UlkeAdiID.FieldName, FSysSehir.UlkeAdiID.DataType, 0, Self, 'Ülke Adý ID');
  FUlkeAdi := TFieldDB.Create(FSysSehir.UlkeAdi.FieldName, FSysSehir.UlkeAdi.DataType, '', Self, 'Ülke');
  FBolgeAdiID := TFieldDB.Create(FSysSehir.BolgeAdiID.FieldName, FSysSehir.BolgeAdiID.DataType, 0, Self, 'Bölge Adý ID');
  FBolgeAdi := TFieldDB.Create(FSysSehir.BolgeAdi.FieldName, FSysSehir.BolgeAdi.DataType, '', Self, 'Bölge');
  FNot1 := TFieldDB.Create('not1', ftString, '', Self, 'Not 1');
  FNot2 := TFieldDB.Create('not2', ftString, '', Self, 'Not 2');
  FNot3 := TFieldDB.Create('not3', ftString, '', Self, 'Not 3');
  FFirmaTipiID := TFieldDB.Create('firma_tipi_id', ftInteger, 0, Self, 'Firma Tipi ID');
  FFirmaTipi := TFieldDB.Create(FBbkFirmaTipi.FirmaTipi.FieldName, FBbkFirmaTipi.FirmaTipi.DataType, '', Self, 'Firma Tipi');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, 'Vergi D.');
  FVergiNumarasi := TFieldDB.Create('vergi_numarasi', ftString, '', Self, 'Vergi No');
  FKacYillikFirma := TFieldDB.Create('kac_yillik_firma', ftInteger, 0, Self, 'Kaç Yýllýk Firma');
  FCalismaDurumuId := TFieldDB.Create('calisma_durumu_id', ftInteger, 0, Self, 'Çalýþma Durumu ID');
  FCalismaDurumu := TFieldDB.Create(FBbkCalismaDurumu.CalismaDurumu.FieldName, FBbkCalismaDurumu.CalismaDurumu.DataType, '', Self, 'Çalýþma Durumu');
  FCalistigiTedarikciler := TFieldDB.Create('calistigi_tedarikciler', ftString, '', Self, 'Çalýþtýðý Tedarikçiler');
  FFinansDurumuID := TFieldDB.Create('finans_durumu_id', ftInteger, 0, Self, 'Finans Durumu ID');
  FFinansDurumu := TFieldDB.Create(FBbkFinansDurumu.FinansDurumu.FieldName, FBbkFinansDurumu.FinansDurumu.DataType, '', Self, 'Finans Durumu');
  FSevkiyatYetkilisi := TFieldDB.Create('sevkiyat_yetkilisi', ftString, '', Self, 'Sevkiyat Yetkilisi');
  FSevkiyatYetkilisiTel := TFieldDB.Create('sevkiyat_yetkilisi_tel', ftString, '', Self, 'Sevkiyat Yetkilisi Tel');
end;

destructor TBbkKayit.Destroy;
begin
  FreeAndNil(FBbkFirmaTipi);
  FreeAndNil(FBbkCalismaDurumu);
  FreeAndNil(FBbkFinansDurumu);
  FreeAndNil(FSysSehir);
  FreeAndNil(FSysUlke);
  FreeAndNil(FSysBolge);

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
        Self.Id.QryName,
        FFirmaAdi.QryName,
        FTel1.QryName,
        FTel2.QryName,
        FTel3.QryName,
        FFax.QryName,
        FEmail.QryName,
        FWeb.QryName,
        FYetkili1.QryName,
        FYetkili1Tel.QryName,
        FYetkili1Email.QryName,
        FYetkili2.QryName,
        FYetkili2Tel.QryName,
        FYetkili2Email.QryName,
        FAdres.QryName,
        FSehirAdiID.QryName,
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehirAdi.FieldName),
        addField(FSysSehir.TableName, FSysSehir.UlkeAdiID.FieldName, FUlkeAdiID.FieldName),
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
        addField(FSysSehir.TableName, FSysSehir.BolgeAdiID.FieldName, FBolgeAdiID.FieldName),
        addField(FSysBolge.TableName, FSysBolge.BolgeAdi.FieldName, FBolgeAdi.FieldName),
        FNot1.QryName,
        FNot2.QryName,
        FNot3.QryName,
        FFirmaTipiID.QryName,
        addField(FBbkFirmaTipi.TableName, FBbkFirmaTipi.FirmaTipi.FieldName, FFirmaTipi.FieldName),
        FVergiDairesi.QryName,
        FVergiNumarasi.QryName,
        FKacYillikFirma.QryName,
        FCalismaDurumuId.QryName,
        addField(FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.CalismaDurumu.FieldName, FCalismaDurumu.FieldName),
        FCalistigiTedarikciler.QryName,
        FFinansDurumuID.QryName,
        addField(FBbkFinansDurumu.TableName, FBbkFinansDurumu.FinansDurumu.FieldName, FFinansDurumu.FieldName),
        FSevkiyatYetkilisi.QryName,
        FSevkiyatYetkilisiTel.QryName
      ], [
        addJoin(jtLeft, FBbkFirmaTipi.TableName, FBbkFirmaTipi.Id.FieldName, TableName, FFirmaTipiID.FieldName),
        addJoin(jtLeft, FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.Id.FieldName, TableName, FCalismaDurumuId.FieldName),
        addJoin(jtLeft, FBbkFinansDurumu.TableName, FBbkFinansDurumu.Id.FieldName, TableName, FFinansDurumuID.FieldName),
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirAdiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, FSysSehir.TableName, FSysSehir.UlkeAdiID.FieldName),
        addJoin(jtLeft, FSysBolge.TableName, FSysBolge.Id.FieldName, FSysSehir.TableName, FBolgeAdiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
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
        Self.Id.QryName,
        FFirmaAdi.QryName,
        FTel1.QryName,
        FTel2.QryName,
        FTel3.QryName,
        FFax.QryName,
        FEmail.QryName,
        FWeb.QryName,
        FYetkili1.QryName,
        FYetkili1Tel.QryName,
        FYetkili1Email.QryName,
        FYetkili2.QryName,
        FYetkili2Tel.QryName,
        FYetkili2Email.QryName,
        FAdres.QryName,
        FSehirAdiID.QryName,
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehirAdi.FieldName),
        addField(FSysSehir.TableName, FSysSehir.UlkeAdiID.FieldName, FUlkeAdiID.FieldName),
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
        addField(FSysSehir.TableName, FSysSehir.BolgeAdiID.FieldName, FBolgeAdiID.FieldName),
        addField(FSysBolge.TableName, FSysBolge.BolgeAdi.FieldName, FBolgeAdi.FieldName),
        FNot1.QryName,
        FNot2.QryName,
        FNot3.QryName,
        FFirmaTipiID.QryName,
        addField(FBbkFirmaTipi.TableName, FBbkFirmaTipi.FirmaTipi.FieldName, FFirmaTipi.FieldName),
        FVergiDairesi.QryName,
        FVergiNumarasi.QryName,
        FKacYillikFirma.QryName,
        FCalismaDurumuId.QryName,
        addField(FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.CalismaDurumu.FieldName, FCalismaDurumu.FieldName),
        FCalistigiTedarikciler.QryName,
        FFinansDurumuID.QryName,
        addField(FBbkFinansDurumu.TableName, FBbkFinansDurumu.FinansDurumu.FieldName, FFinansDurumu.FieldName),
        FSevkiyatYetkilisi.QryName,
        FSevkiyatYetkilisiTel.QryName
      ], [
        addJoin(jtLeft, FBbkFirmaTipi.TableName, FBbkFirmaTipi.Id.FieldName, TableName, FFirmaTipiID.FieldName),
        addJoin(jtLeft, FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.Id.FieldName, TableName, FCalismaDurumuId.FieldName),
        addJoin(jtLeft, FBbkFinansDurumu.TableName, FBbkFinansDurumu.Id.FieldName, TableName, FFinansDurumuID.FieldName),
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirAdiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, FSysSehir.TableName, FSysSehir.UlkeAdiID.FieldName),
        addJoin(jtLeft, FSysBolge.TableName, FSysBolge.Id.FieldName, FSysSehir.TableName, FBolgeAdiID.FieldName),
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
          FFirmaAdi.FieldName,
          FTel1.FieldName,
          FTel2.FieldName,
          FTel3.FieldName,
          FFax.FieldName,
          FEmail.FieldName,
          FWeb.FieldName,
          FYetkili1.FieldName,
          FYetkili1Tel.FieldName,
          FYetkili1Email.FieldName,
          FYetkili2.FieldName,
          FYetkili2Tel.FieldName,
          FYetkili2Email.FieldName,
          FAdres.FieldName,
          FSehirAdiID.FieldName,
          FNot1.FieldName,
          FNot2.FieldName,
          FNot3.FieldName,
          FFirmaTipiID.FieldName,
          FVergiDairesi.FieldName,
          FVergiNumarasi.FieldName,
          FKacYillikFirma.FieldName,
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
          FFirmaAdi.FieldName,
          FTel1.FieldName,
          FTel2.FieldName,
          FTel3.FieldName,
          FFax.FieldName,
          FEmail.FieldName,
          FWeb.FieldName,
          FYetkili1.FieldName,
          FYetkili1Tel.FieldName,
          FYetkili1Email.FieldName,
          FYetkili2.FieldName,
          FYetkili2Tel.FieldName,
          FYetkili2Email.FieldName,
          FAdres.FieldName,
          FSehirAdiID.FieldName,
          FNot1.FieldName,
          FNot2.FieldName,
          FNot3.FieldName,
          FFirmaTipiID.FieldName,
          FVergiDairesi.FieldName,
          FVergiNumarasi.FieldName,
          FKacYillikFirma.FieldName,
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
