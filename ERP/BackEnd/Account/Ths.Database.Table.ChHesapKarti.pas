unit Ths.Database.Table.ChHesapKarti;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Variants, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, Ths.Database, Ths.Database.Table,
  Ths.Database.Table.ChGruplar, Ths.Database.Table.SetChHesapTipi,
  Ths.Database.Table.ChHesapPlanlari, Ths.Database.Table.ChBolgeler,
  Ths.Database.Table.SysUlkeler, Ths.Database.Table.SysSehirler,
  Ths.Database.Table.SysAdresler, Ths.Database.Table.PrsPersoneller,
  Ths.Database.Table.SysParaBirimleri;

type
  THesapTipi = (htAna=1, htAra, htSon);

  TChHesapKarti = class(TTable)
  private
    FHesapKodu: TFieldDB;
    FHesapIsmi: TFieldDB;
    FHesapTipiID: TFieldDB;
    FHesapTipi: TFieldDB;
    FGrupID: TFieldDB;
    FGrup: TFieldDB;
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
    FMukellefTipi: TFieldDB;
    FMukellefAdi: TFieldDB;
    FMukellefAdi2: TFieldDB;
    FMukellefSoyadi: TFieldDB;
    FVergiDairesi: TFieldDB;
    FVergiNo: TFieldDB;
    FIban: TFieldDB;
    FIbanPara: TFieldDB;
    FNace: TFieldDB;
    FYetkili1: TFieldDB;
    FYetkili1Tel: TFieldDB;
    FYetkili2: TFieldDB;
    FYetkili2Tel: TFieldDB;
    FYetkili3: TFieldDB;
    FYetkili3Tel: TFieldDB;
    FFaks: TFieldDB;
    FMuhasebeTelefon: TFieldDB;
    FMuhasebeEmail: TFieldDB;
    FMuhasebeYetkili: TFieldDB;
    FOzelNot: TFieldDB;
    FKokKod: TFieldDB;
    FAraKod: TFieldDB;
    FIskonto: TFieldDB;
    FEFaturaKullaniyor: TFieldDB;
    FEFaturaPBName: TFieldDB;
    FAdresID: TFieldDB;
    FPasif: TFieldDB;
    //db alan� de�il
    FSeviyeSayisi: TFieldDB;

    FAdres: TSysAdres;
  protected
    FChGrup: TChGrup;
    FSetChHesapTipi: TSetChHesapTipi;
    FChBolge: TChBolge;
    FChHesapPlani: TChHesapPlani;
    FSysParaBirimi: TSysParaBirimi;

    procedure BusinessSelect(AFilter: string; ALock: Boolean; APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function GetAraHesapKodlari(AKokKod, AAraKod: string; AIsUpdate: Boolean): TStringList;
    function GetSonHesapKodlari(AFilter: string): TStringList;

    function Clone: TTable; override;

    procedure Validate;

    Property HesapKodu: TFieldDB read FHesapKodu write FHesapKodu;
    Property HesapIsmi: TFieldDB read FHesapIsmi write FHesapIsmi;
    Property HesapTipiID: TFieldDB read FHesapTipiID write FHesapTipiID;
    Property HesapTipi: TFieldDB read FHesapTipi write FHesapTipi;
    Property GrupID: TFieldDB read FGrupID write FGrupID;
    Property Grup: TFieldDB read FGrup write FGrup;
    Property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    Property Bolge: TFieldDB read FBolge write FBolge;
    Property MukellefTipi: TFieldDB read FMukellefTipi write FMukellefTipi;
    Property MukellefAdi: TFieldDB read FMukellefAdi write FMukellefAdi;
    Property MukellefAdi2: TFieldDB read FMukellefAdi2 write FMukellefAdi2;
    Property MukellefSoyadi: TFieldDB read FMukellefSoyadi write FMukellefSoyadi;
    Property VergiDairesi: TFieldDB read FVergiDairesi write FVergiDairesi;
    Property VergiNo: TFieldDB read FVergiNo write FVergiNo;
    Property Iban: TFieldDB read FIban write FIban;
    Property IbanPara: TFieldDB read FIbanPara write FIbanPara;
    Property Nace: TFieldDB read FNace write FNace;
    Property Yetkili1: TFieldDB read FYetkili1 write FYetkili1;
    Property Yetkili1Tel: TFieldDB read FYetkili1Tel write FYetkili1Tel;
    Property Yetkili2: TFieldDB read FYetkili2 write FYetkili2;
    Property Yetkili2Tel: TFieldDB read FYetkili2Tel write FYetkili2Tel;
    Property Yetkili3: TFieldDB read FYetkili3 write FYetkili3;
    Property Yetkili3Tel: TFieldDB read FYetkili3Tel write FYetkili3Tel;
    Property Faks: TFieldDB read FFaks write FFaks;
    Property MuhasebeTelefon: TFieldDB read FMuhasebeTelefon write FMuhasebeTelefon;
    Property MuhasebeEPosta: TFieldDB read FMuhasebeEmail write FMuhasebeEmail;
    Property MuhasebeYetkili: TFieldDB read FMuhasebeYetkili write FMuhasebeYetkili;
    Property OzelNot: TFieldDB read FOzelNot write FOzelNot;
    Property KokKod: TFieldDB read FKokKod write FKokKod;
    Property AraKod: TFieldDB read FAraKod write FAraKod;
    Property Iskonto: TFieldDB read FIskonto write FIskonto;
    Property EFaturaKullaniyor: TFieldDB read FEFaturaKullaniyor write FEFaturaKullaniyor;
    Property EFaturaPBName: TFieldDB read FEFaturaPBName write FEFaturaPBName;
    Property AdresID: TFieldDB read FAdresID write FAdresID;
    Property Pasif: TFieldDB read FPasif write FPasif;
    //db alan� de�il
    Property SeviyeSayisi: TFieldDB read FSeviyeSayisi write FSeviyeSayisi;

    Property Adres: TSysAdres read FAdres write FAdres;
  end;

implementation

uses Ths.Globals, Ths.Constants;

constructor TChHesapKarti.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesaplar';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FChGrup := TChGrup.Create(Database);
  FSetChHesapTipi := TSetChHesapTipi.Create(Database);
  FChBolge := TChBolge.Create(Database);
  FChHesapPlani := TChHesapPlani.Create(Database);
  FSysParaBirimi := TSysParaBirimi.Create(Database);

  FHesapKodu := TFieldDB.Create('hesap_kodu', ftString, '', Self, 'Hesap Kodu');
  FHesapIsmi := TFieldDB.Create('hesap_ismi', ftString, '', Self, 'Hesap �smi');
  FHesapTipiID := TFieldDB.Create('hesap_tipi_id', ftInteger, 0, Self, 'Hesap Tipi ID');
  FHesapTipi := TFieldDB.Create(FSetChHesapTipi.HesapTipi.FieldName, FSetChHesapTipi.HesapTipi.DataType, FSetChHesapTipi.HesapTipi.Value, Self, FSetChHesapTipi.HesapTipi.Title);
  FGrupID := TFieldDB.Create('grup_id', ftInteger, 0, Self, 'Grup ID');
  FGrup := TFieldDB.Create(FChGrup.Grup.FieldName, FChGrup.Grup.DataType, FChGrup.Grup.Value, Self, FChGrup.Grup.Title);
  FBolgeID := TFieldDB.Create('bolge_id', ftInteger, 0, Self, 'B�lge ID');
  FBolge := TFieldDB.Create(FChBolge.Bolge.FieldName, FChBolge.Bolge.DataType, FChBolge.Bolge.Value, Self, FChBolge.Bolge.Title);
  FMukellefTipi := TFieldDB.Create('mukellef_tipi', ftSmallint, 0, Self, 'M�kellef Tipi');
  FMukellefAdi := TFieldDB.Create('mukellef_adi', ftString, '', Self, 'M�kellef Ad�');
  FMukellefAdi2 := TFieldDB.Create('mukellef_adi2', ftString, '', Self, 'M�kellef Ad� 2');
  FMukellefSoyadi := TFieldDB.Create('mukellef_soyadi', ftString, '', Self, 'M�kellef Soyad�');
  FVergiDairesi := TFieldDB.Create('vergi_dairesi', ftString, '', Self, 'Vergi Dairesi');
  FVergiNo := TFieldDB.Create('vergi_no', ftString, '', Self, 'Vergi No');
  FIban := TFieldDB.Create('iban', ftString, '', Self, 'IBAN');
  FIbanPara := TFieldDB.Create('iban_para', ftString, '', Self, 'IBAN Birim');
  FNace := TFieldDB.Create('nace', ftString, '', Self, 'Nace Kodu');
  FYetkili1 := TFieldDB.Create('yetkili1', ftString, '', Self, 'Yetkili 1');
  FYetkili1Tel := TFieldDB.Create('yetkili1_tel', ftString, '', Self, 'Yetkili 1 Tel');
  FYetkili2 := TFieldDB.Create('yetkili2', ftString, '', Self, 'Yetkili 2');
  FYetkili2Tel := TFieldDB.Create('yetkili2_tel', ftString, '', Self, 'Yetkili 2 Tel');
  FYetkili3 := TFieldDB.Create('yetkili3', ftString, '', Self, 'Yetkili 3');
  FYetkili3Tel := TFieldDB.Create('yetkili3_tel', ftString, '', Self, 'Yetkili 3 Telefon');
  FFaks := TFieldDB.Create('faks', ftString, '', Self, 'Faks');
  FMuhasebeTelefon := TFieldDB.Create('muhasebe_telefon', ftString, '', Self, 'Muhasebe Telefon');
  FMuhasebeEmail := TFieldDB.Create('muhasebe_email', ftString, '', Self, 'Muhasebe Email');
  FMuhasebeYetkili := TFieldDB.Create('muhasebe_yetkili', ftString, '', Self, 'Muhasebe Yetkili');
  FOzelNot := TFieldDB.Create('ozel_not', ftString, '', Self, '�zel Bilgi');
  FKokKod := TFieldDB.Create('kok_kod', ftString, '', Self, 'K�k Kodu');
  FAraKod := TFieldDB.Create('ara_kod', ftString, '', Self, 'Ara Kodu');
  FIskonto := TFieldDB.Create('iskonto', ftFloat, 0, Self, '�skonto');
  FEFaturaKullaniyor := TFieldDB.Create('efatura_kullaniyor', ftBoolean, False, Self, 'E-Fatura?');
  FEFaturaPBName := TFieldDB.Create('efatura_pb_name', ftString, '', Self, 'E-Fatura PK Ad�');
  FAdresID := TFieldDB.Create('adres_id', ftInteger, 0, Self, 'Adres ID');
  FPasif := TFieldDB.Create('pasif', ftBoolean, False, Self, 'Pasif?');
  FSeviyeSayisi := TFieldDB.Create(FChHesapPlani.Seviye.FieldName, FChHesapPlani.Seviye.DataType, FChHesapPlani.Seviye.Value, Self, FChHesapPlani.Seviye.Title);

  FAdres := TSysAdres.Create(Database);
end;

destructor TChHesapKarti.Destroy;
begin
  FChGrup.Free;
  FSetChHesapTipi.Free;
  FChBolge.Free;
  FChHesapPlani.Free;
  FSysParaBirimi.Free;

  FAdres.Free;
  inherited;
end;

procedure TChHesapKarti.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Self.Id.QryName,
      FHesapKodu.QryName,
      FHesapIsmi.QryName,
      FHesapTipiID.QryName,
      addLangField(FHesapTipi.FieldName),
      FGrupID.QryName,
      addLangField(FGrup.FieldName),
      FBolgeID.QryName,
      addLangField(FBolge.FieldName),
      FMukellefTipi.QryName,
      FMukellefAdi.QryName,
      FMukellefAdi2.QryName,
      FMukellefSoyadi.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FIban.QryName,
      FIbanPara.QryName,
      FNace.QryName,
      FYetkili1.QryName,
      FYetkili1Tel.QryName,
      FYetkili2.QryName,
      FYetkili2Tel.QryName,
      FYetkili3.QryName,
      FYetkili3Tel.QryName,
      FFaks.QryName,
      FMuhasebeTelefon.QryName,
      FMuhasebeEmail.QryName,
      FMuhasebeYetkili.QryName,
      FOzelNot.QryName,
      FKokKod.QryName,
      FAraKod.QryName,
      FIskonto.QryName,
      FEFaturaKullaniyor.QryName,
      FEFaturaPBName.QryName,
      FAdresID.QryName,
      FPasif.QryName,
      FChHesapPlani.Seviye.QryName
    ], [
      addLeftJoin(FHesapTipi.FieldName, FHesapTipiID.FieldName, FSetChHesapTipi.TableName),
      addLeftJoin(FGrup.FieldName, FGrupID.FieldName, FChGrup.TableName),
      addLeftJoin(FBolge.FieldName, FBolgeID.FieldName, FChBolge.TableName),
      addJoin(jtLeft, FChHesapPlani.TableName, FChHesapPlani.PlanKodu.FieldName, TableName, FKokKod.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TChHesapKarti.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FHesapKodu.QryName,
      FHesapIsmi.QryName,
      FHesapTipiID.QryName,
      addLangField(FHesapTipi.FieldName),
      FGrupID.QryName,
      addLangField(FGrup.FieldName),
      FBolgeID.QryName,
      addLangField(FBolge.FieldName),
      FMukellefTipi.QryName,
      FMukellefAdi.QryName,
      FMukellefAdi2.QryName,
      FMukellefSoyadi.QryName,
      FVergiDairesi.QryName,
      FVergiNo.QryName,
      FIban.QryName,
      FIbanPara.QryName,
      FNace.QryName,
      FYetkili1.QryName,
      FYetkili1Tel.QryName,
      FYetkili2.QryName,
      FYetkili2Tel.QryName,
      FYetkili3.QryName,
      FYetkili3Tel.QryName,
      FFaks.QryName,
      FMuhasebeTelefon.QryName,
      FMuhasebeEmail.QryName,
      FMuhasebeYetkili.QryName,
      FOzelNot.QryName,
      FKokKod.QryName,
      FAraKod.QryName,
      FIskonto.QryName,
      FEFaturaKullaniyor.QryName,
      FEFaturaPBName.QryName,
      FAdresID.QryName,
      FPasif.QryName,
      FChHesapPlani.Seviye.QryName
    ], [
      addLeftJoin(FHesapTipi.FieldName, FHesapTipiID.FieldName, FSetChHesapTipi.TableName),
      addLeftJoin(FGrup.FieldName, FGrupID.FieldName, FChGrup.TableName),
      addLeftJoin(FBolge.FieldName, FBolgeID.FieldName, FChBolge.TableName),
      addJoin(jtLeft, FChHesapPlani.TableName, FChHesapPlani.PlanKodu.FieldName, TableName, FKokKod.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Self.Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TChHesapKarti.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHesapKodu.FieldName,
      FHesapIsmi.FieldName,
      FHesapTipiID.FieldName,
      FGrupID.FieldName,
      FBolgeID.FieldName,
      FMukellefTipi.FieldName,
      FMukellefAdi.FieldName,
      FMukellefAdi2.FieldName,
      FMukellefSoyadi.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FIban.FieldName,
      FIbanPara.FieldName,
      FNace.FieldName,
      FYetkili1.FieldName,
      FYetkili1Tel.FieldName,
      FYetkili2.FieldName,
      FYetkili2Tel.FieldName,
      FYetkili3.FieldName,
      FYetkili3Tel.FieldName,
      FFaks.FieldName,
      FMuhasebeTelefon.FieldName,
      FMuhasebeEmail.FieldName,
      FMuhasebeYetkili.FieldName,
      FOzelNot.FieldName,
      FKokKod.FieldName,
      FAraKod.FieldName,
      FIskonto.FieldName,
      FEFaturaKullaniyor.FieldName,
      FEFaturaPBName.FieldName,
      FAdresID.FieldName,
      FPasif.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapKarti.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHesapKodu.FieldName,
      FHesapIsmi.FieldName,
      FHesapTipiID.FieldName,
      FGrupID.FieldName,
      FBolgeID.FieldName,
      FMukellefTipi.FieldName,
      FMukellefAdi.FieldName,
      FMukellefAdi2.FieldName,
      FMukellefSoyadi.FieldName,
      FVergiDairesi.FieldName,
      FVergiNo.FieldName,
      FIban.FieldName,
      FIbanPara.FieldName,
      FNace.FieldName,
      FYetkili1.FieldName,
      FYetkili1Tel.FieldName,
      FYetkili2.FieldName,
      FYetkili2Tel.FieldName,
      FYetkili3.FieldName,
      FYetkili3Tel.FieldName,
      FFaks.FieldName,
      FMuhasebeTelefon.FieldName,
      FMuhasebeEmail.FieldName,
      FMuhasebeYetkili.FieldName,
      FOzelNot.FieldName,
      FKokKod.FieldName,
      FAraKod.FieldName,
      FEFaturaKullaniyor.FieldName,
      FEFaturaPBName.FieldName,
      FIskonto.FieldName,
      FAdresID.FieldName,
      FPasif.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TChHesapKarti.GetAraHesapKodlari(AKokKod, AAraKod: string; AIsUpdate: Boolean): TStringList;
var
  LQry: TFDQuery;
  LSQL, LFilter: string;
begin
	if AIsUpdate then
		LFilter := ' AND ' + Self.KokKod.FieldName + '=' + QuotedStr(AKokKod) + ' AND ' + Self.HesapKodu.FieldName + '!=' + QuotedStr(AAraKod)
	else
		LFilter := ' AND ' + Self.KokKod.FieldName + '=' + QuotedStr(AKokKod);

//	--Ara Hesap Tipi Id bilgisi 2
  Result := TStringList.Create;
  LSQL := 'SELECT cast(right(' + Self.HesapKodu.QryName + ', length(' + Self.HesapKodu.QryName + ')-4) as Integer) FROM ' + Self.TableName +
          ' WHERE ' + Self.HesapTipiID.QryName + '=' + Ord(THesapTipi.htAra).ToString + LFilter + ' ORDER BY 1 ASC';
  LQry := Database.NewQuery();
  try
    LQry.SQL.Text := LSQL;
    LQry.Open;
    LQry.First;
    while not LQry.Eof do
    begin
      Result.Add(LQry.Fields.Fields[0].AsString);
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

function TChHesapKarti.GetSonHesapKodlari(AFilter: string): TStringList;
var
  LQry: TFDQuery;
  LSQL: string;
begin
  Result := TStringList.Create;
  LSQL := 'SELECT cast(split_part(' + Self.FHesapKodu.FieldName + ',' +
                                 QuotedStr('-') + ',' +
                                 '(CHAR_LENGTH(' + Self.FHesapKodu.FieldName + ') - ' +
                                 ' CHAR_LENGTH(REPLACE('+ Self.FHesapKodu.FieldName + ', '+ QuotedStr('-') + ',' + QuotedStr('') + '))) / CHAR_LENGTH(' + QuotedStr('-') + ') + 1) as integer) FROM ' + Self.TableName + ' WHERE 1=1 ' + AFilter;
  LQry := Database.NewQuery();
  try
    LQry.SQL.Text := LSQL;
    LQry.Open;
    LQry.First;
    while not LQry.Eof do
    begin
      Result.Add(LQry.Fields.Fields[0].AsString);
      LQry.Next;
    end;
  finally
    LQry.Free;
  end;
end;

procedure TChHesapKarti.Validate;
var
  LIsk: Double;
  LStr, LVergiNo: string;
begin
  LIsk := FIskonto.AsFloat;
  if (LIsk > 100.00) or (LIsk < 0) then
    raise Exception.Create(Trim('"İskonto Oranı > 100" veya "İskonto Oranı < 0" olamaz! + 999999'));

  LStr := FMukellefTipi.AsString;
  LVergiNo := FVergiNo.AsString;
  if (LStr = 'TCKN') and (LVergiNo.Length <> 11) then
    raise Exception.Create(Trim('TCKN seçildiğinde Kimlik No 11 haneli olmak zorunda! + 999999'));

  if (LStr = 'VKN') and (LVergiNo.Length <> 10) then
    raise Exception.Create(Trim('VKN seçildiğinde Vergi Kimlik No 10 haneli olmak zorunda! + 999999'));
end;

procedure TChHesapKarti.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    if TChHesapKarti(Self.List[n1]).AdresID.AsInt64 > 0 then
      TChHesapKarti(Self.List[n1]).Adres.SelectToList(' AND ' + TChHesapKarti(Self.List[n1]).Adres.Id.QryName + '=' + TChHesapKarti(Self.List[n1]).AdresID.AsString, ALock, False)
    else
      TChHesapKarti(Self.List[n1]).Adres.Clear;
  end;
end;

procedure TChHesapKarti.BusinessInsert(APermissionControl: Boolean);
begin
  Self.Adres.Insert(False);
  Self.AdresID.Value := Self.Adres.Id.Value;
  Self.Insert(APermissionControl);
end;

procedure TChHesapKarti.BusinessUpdate(APermissionControl: Boolean);
begin
  if Self.Adres.Id.AsInt64 > 0 then
    Self.Adres.Update(False)
  else
    Self.Adres.Insert(False);
  Self.AdresID.Value := Self.Adres.Id.AsInt64;
  Self.Update(APermissionControl);
end;

procedure TChHesapKarti.BusinessDelete(APermissionControl: Boolean);
begin
  inherited;
//
end;

function TChHesapKarti.Clone: TTable;
begin
  Result := TChHesapKarti.Create(Database);
  CloneClassContent(Self, Result);
  CloneClassContent(Self.Adres, TChHesapKarti(Result).Adres);
end;

end.
