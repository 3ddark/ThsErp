unit Ths.Database.Table.BbkKayit;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetBbkFirmaTipi,
  Ths.Database.Table.SetBbkCalismaDurumu,
  Ths.Database.Table.SetBbkFinansDurumu,
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysBolgeler;

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
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB;
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
    FNot1: TFieldDB;
    FNot2: TFieldDB;
    FFirmaTipiID: TFieldDB;
    FFirmaTipi: TFieldDb;
    FVergiDairesi: TFieldDB;
    FVergiNumarasi: TFieldDB;
    FKacYillikFirma: TFieldDB;
    FCalismaDurumuId: TFieldDB;
    FCalismaDurumu: TFieldDB;
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
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

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
    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;
    Property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    Property Bolge: TFieldDB read FBolge write FBolge;
    Property Not1: TFieldDB read FNot1 write FNot1;
    Property Not2: TFieldDB read FNot2 write FNot2;
    Property FirmaTipiID: TFieldDB read FFirmaTipiID write FFirmaTipiID;
    Property FirmaTipi: TFieldDB read FFirmaTipi write FFirmaTipi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNumarasi: TFieldDB read FVergiNumarasi write FVergiNumarasi;
    Property KacYillikFirma: TFieldDB read FKacYillikFirma write FKacYillikFirma;
    Property CalismaDurumuId: TFieldDB read FCalismaDurumuId write FCalismaDurumuId;
    Property CalismaDurumu: TFieldDB read FCalismaDurumu write FCalismaDurumu;
    Property FinansDurumuID: TFieldDB read FFinansDurumuID write FFinansDurumuID;
    Property FinansDurumu: TFieldDB read FFinansDurumu write FFinansDurumu;
    Property SevkiyatYetkilisi: TFieldDB read FSevkiyatYetkilisi write FSevkiyatYetkilisi;
    Property SevkiyatYetkilisiTel: TFieldDB read FSevkiyatYetkilisiTel write FSevkiyatYetkilisiTel;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TBbkKayit.Create(ADatabase: TDatabase);
begin
  TableName := 'bbk_kayitlar';
  TableSourceCode := MODULE_BBK_KAYIT;
  inherited Create(ADatabase);

  FBbkFirmaTipi := TSetBbkFirmaTipi.Create(Database);
  FBbkCalismaDurumu := TSetBbkCalismaDurumu.Create(Database);
  FBbkFinansDurumu := TSetBbkFinansDurumu.Create(Database);
  FSysSehir := TSysSehir.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSysBolge := TSysBolge.Create(Database);

  FFirmaAdi := TFieldDB.Create('firma_adi', ftWideString, '', Self, 'Firma Adý');
  FTel1 := TFieldDB.Create('tel1', ftWideString, '', Self, 'Tel1');
  FTel2 := TFieldDB.Create('tel2', ftWideString, '', Self, 'Tel2');
  FTel3 := TFieldDB.Create('tel3', ftWideString, '', Self, 'Tel3');
  FFax := TFieldDB.Create('fax', ftWideString, '', Self, 'Faks');
  FEmail := TFieldDB.Create('email', ftWideString, '', Self, 'E-Mail');
  FWeb := TFieldDB.Create('web', ftWideString, '', Self, 'Web');
  FYetkili1 := TFieldDB.Create('yetkili1', ftWideString, '', Self, 'Yetkili 1');
  FYetkili1Tel := TFieldDB.Create('yetkili1_tel', ftWideString, '', Self, 'Yetkili 1 Tel');
  FYetkili1Email := TFieldDB.Create('yetkili1_email', ftWideString, '', Self, 'Yetkili 1 Mail');
  FYetkili2 := TFieldDB.Create('yetkili2', ftWideString, '', Self, 'Yetkili 2');
  FYetkili2Tel := TFieldDB.Create('yetkili2_tel', ftWideString, '', Self, 'Yetkili 2 Tel');
  FYetkili2Email := TFieldDB.Create('yetkili2_email', ftWideString, '', Self, 'Yetkili 2 Mail');
  FAdres := TFieldDB.Create('adres', ftWideString, '', Self, 'Adres');
  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'Þehir ID');
  FSehir := TFieldDB.Create(FSysSehir.Sehir.FieldName, FSysSehir.Sehir.DataType, '', Self, 'Þehir');
  FUlkeID := TFieldDB.Create('ulke_id', FSysSehir.UlkeID.DataType, 0, Self, 'Ülke Adý ID');
  FUlke := TFieldDB.Create(FSysSehir.UlkeAdi.FieldName, FSysSehir.UlkeAdi.DataType, '', Self, 'Ülke');
  FBolgeID := TFieldDB.Create('bolge_id', FSysSehir.BolgeID.DataType, 0, Self, 'Bölge Adý ID');
  FBolge := TFieldDB.Create(FSysSehir.Bolge.FieldName, FSysSehir.Bolge.DataType, '', Self, 'Bölge');
  FNot1 := TFieldDB.Create('not1', ftWideString, '', Self, 'Not 1');
  FNot2 := TFieldDB.Create('not2', ftWideString, '', Self, 'Not 2');
  FFirmaTipiID := TFieldDB.Create('firma_tipi_id', ftInteger, 0, Self, 'Firma Tipi ID');
  FFirmaTipi := TFieldDB.Create(FBbkFirmaTipi.FirmaTipi.FieldName, FBbkFirmaTipi.FirmaTipi.DataType, '', Self, 'Firma Tipi');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftWideString, '', Self, 'Vergi D.');
  FVergiNumarasi := TFieldDB.Create('vergi_numarasi', ftWideString, '', Self, 'Vergi No');
  FKacYillikFirma := TFieldDB.Create('kac_yillik_firma', ftInteger, 0, Self, 'Kaç Yýllýk Firma');
  FCalismaDurumuId := TFieldDB.Create('calisma_durumu_id', ftInteger, 0, Self, 'Çalýþma Durumu ID');
  FCalismaDurumu := TFieldDB.Create(FBbkCalismaDurumu.CalismaDurumu.FieldName, FBbkCalismaDurumu.CalismaDurumu.DataType, '', Self, 'Çalýþma Durumu');
  FFinansDurumuID := TFieldDB.Create('finans_durumu_id', ftInteger, 0, Self, 'Finans Durumu ID');
  FFinansDurumu := TFieldDB.Create(FBbkFinansDurumu.FinansDurumu.FieldName, FBbkFinansDurumu.FinansDurumu.DataType, '', Self, 'Finans Durumu');
  FSevkiyatYetkilisi := TFieldDB.Create('sevkiyat_yetkilisi', ftWideString, '', Self, 'Sevkiyat Yetkilisi');
  FSevkiyatYetkilisiTel := TFieldDB.Create('sevkiyat_yetkilisi_tel', ftWideString, '', Self, 'Sevkiyat Yetkilisi Tel');
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
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
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
      FSehirID.QryName,
      addField(FSysSehir.TableName, FSysSehir.Sehir.FieldName, FSehir.FieldName),
      addField(FSysSehir.TableName, FSysSehir.UlkeID.FieldName, FUlkeID.FieldName),
      addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlke.FieldName),
      addField(FSysSehir.TableName, FSysSehir.BolgeID.FieldName, FBolgeID.FieldName),
      addField(FSysBolge.TableName, FSysBolge.Bolge.FieldName, FBolge.FieldName),
      FNot1.QryName,
      FNot2.QryName,
      FFirmaTipiID.QryName,
      addField(FBbkFirmaTipi.TableName, FBbkFirmaTipi.FirmaTipi.FieldName, FFirmaTipi.FieldName),
      FVergiDairesi.QryName,
      FVergiNumarasi.QryName,
      FKacYillikFirma.QryName,
      FCalismaDurumuId.QryName,
      addField(FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.CalismaDurumu.FieldName, FCalismaDurumu.FieldName),
      FFinansDurumuID.QryName,
      addField(FBbkFinansDurumu.TableName, FBbkFinansDurumu.FinansDurumu.FieldName, FFinansDurumu.FieldName),
      FSevkiyatYetkilisi.QryName,
      FSevkiyatYetkilisiTel.QryName
    ], [
      addJoin(jtLeft, FBbkFirmaTipi.TableName, FBbkFirmaTipi.Id.FieldName, TableName, FFirmaTipiID.FieldName),
      addJoin(jtLeft, FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.Id.FieldName, TableName, FCalismaDurumuId.FieldName),
      addJoin(jtLeft, FBbkFinansDurumu.TableName, FBbkFinansDurumu.Id.FieldName, TableName, FFinansDurumuID.FieldName),
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
      addJoin(jtLeft, FSysBolge.TableName, FSysBolge.Id.FieldName, TableName, FBolgeID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TBbkKayit.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
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
      FSehirID.QryName,
      addField(FSysSehir.TableName, FSysSehir.Sehir.FieldName, FSehir.FieldName),
      addField(FSysSehir.TableName, FSysSehir.UlkeID.FieldName, FUlkeID.FieldName),
      addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlke.FieldName),
      addField(FSysSehir.TableName, FSysSehir.BolgeID.FieldName, FBolgeID.FieldName),
      addField(FSysBolge.TableName, FSysBolge.Bolge.FieldName, FBolge.FieldName),
      FNot1.QryName,
      FNot2.QryName,
      FFirmaTipiID.QryName,
      addField(FBbkFirmaTipi.TableName, FBbkFirmaTipi.FirmaTipi.FieldName, FFirmaTipi.FieldName),
      FVergiDairesi.QryName,
      FVergiNumarasi.QryName,
      FKacYillikFirma.QryName,
      FCalismaDurumuId.QryName,
      addField(FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.CalismaDurumu.FieldName, FCalismaDurumu.FieldName),
      FFinansDurumuID.QryName,
      addField(FBbkFinansDurumu.TableName, FBbkFinansDurumu.FinansDurumu.FieldName, FFinansDurumu.FieldName),
      FSevkiyatYetkilisi.QryName,
      FSevkiyatYetkilisiTel.QryName
    ], [
      addJoin(jtLeft, FBbkFirmaTipi.TableName, FBbkFirmaTipi.Id.FieldName, TableName, FFirmaTipiID.FieldName),
      addJoin(jtLeft, FBbkCalismaDurumu.TableName, FBbkCalismaDurumu.Id.FieldName, TableName, FCalismaDurumuId.FieldName),
      addJoin(jtLeft, FBbkFinansDurumu.TableName, FBbkFinansDurumu.Id.FieldName, TableName, FFinansDurumuID.FieldName),
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirID.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, FSysSehir.TableName, FSysSehir.UlkeID.FieldName),
      addJoin(jtLeft, FSysBolge.TableName, FSysBolge.Id.FieldName, FSysSehir.TableName, FBolgeID.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
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

procedure TBbkKayit.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
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
      FSehirID.FieldName,
      FNot1.FieldName,
      FNot2.FieldName,
      FFirmaTipiID.FieldName,
      FVergiDairesi.FieldName,
      FVergiNumarasi.FieldName,
      FKacYillikFirma.FieldName,
      FCalismaDurumuId.FieldName,
      FFinansDurumuID.FieldName,
      FSevkiyatYetkilisi.FieldName,
      FSevkiyatYetkilisiTel.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TBbkKayit.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
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
      FSehirID.FieldName,
      FNot1.FieldName,
      FNot2.FieldName,
      FFirmaTipiID.FieldName,
      FVergiDairesi.FieldName,
      FVergiNumarasi.FieldName,
      FKacYillikFirma.FieldName,
      FCalismaDurumuId.FieldName,
      FFinansDurumuID.FieldName,
      FSevkiyatYetkilisi.FieldName,
      FSevkiyatYetkilisiTel.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;

end;

function TBbkKayit.Clone: TTable;
begin
  Result := TBbkKayit.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
