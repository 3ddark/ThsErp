unit Ths.Erp.Database.Table.StkStokKarti;

interface

{$I ThsERP.inc}

uses
  System.Variants,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.StkStokGrubu,
  Ths.Erp.Database.Table.SysOlcuBirimi,
  Ths.Erp.Database.Table.StkCinsOzelligi,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SetStkUrunTipi;

type
  TStkStokKarti = class(TTable)
  private
    FIsSatilabilir: TFieldDB;
    FStokKodu: TFieldDB;
    FStokAdi: TFieldDB;
    FStokGrubuID: TFieldDB;
    FStokGrubu: TFieldDB;
    FOlcuBirimiID: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FUrunTipiID: TFieldDB;
    FUrunTipi: TFieldDB;
    FAlisIskonto: TFieldDB;
    FSatisIskonto: TFieldDB;
    FAlisFiyat: TFieldDB;
    FAlisPara: TFieldDB;
    FSatisFiyat: TFieldDB;
    FSatisPara: TFieldDB;
    FIhracFiyat: TFieldDB;
    FIhracPara: TFieldDB;
    FOrtalamaMaliyet: TFieldDB;
    FEn: TFieldDB;
    FBoy: TFieldDB;
    FYukseklik: TFieldDB;
    FAgirlik: TFieldDB;
    FTeminSuresi: TFieldDB;
    FOzelKod: TFieldDB;
    FMarka: TFieldDB;
    FMenseiID: TFieldDB;
    FMensei: TFieldDB;
    FGtipNo: TFieldDB;
    FDiibUrunTanimi: TFieldDB;
    FEnAzStokSeviyesi: TFieldDB;
    FTanim: TFieldDB;
    FStokResim: TFieldDB;
    FCinsID: TFieldDB;
    FCins: TFieldDB;
    FS1: TFieldDB;
    FS2: TFieldDB;
    FS3: TFieldDB;
    FS4: TFieldDB;
    FS5: TFieldDB;
    FS6: TFieldDB;
    FS7: TFieldDB;
    FS8: TFieldDB;
    FI1: TFieldDB;
    FI2: TFieldDB;
    FI3: TFieldDB;
    FI4: TFieldDB;
    FD1: TFieldDB;
    FD2: TFieldDB;
    FD3: TFieldDB;
    FD4: TFieldDB;
  protected
    FStkStokGrubu: TStkStokGrubu;
    FSysBirim: TSysOlcuBirimi;
    FCinsOzelligi: TStkCinsOzelligi;
    FSysUlke: TSysUlke;
    FSetStkUrunTipi: TSetStkUrunTipi;
  published
    constructor Create(ADatabase: TDatabase); override;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    destructor Destroy; override;

    Property IsSatilabilir: TFieldDB read FIsSatilabilir write FIsSatilabilir;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property StokGrubuID: TFieldDB read FStokGrubuID write FStokGrubuID;
    Property StokGrubu: TFieldDB read FStokGrubu write FStokGrubu;
    Property OlcuBirimiID: TFieldDB read FOlcuBirimiID write FOlcuBirimiID;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property UrunTipiID: TFieldDB read FUrunTipiID write FUrunTipiID;
    Property UrunTipi: TFieldDB read FUrunTipi write FUrunTipi;
    Property AlisIskonto: TFieldDB read FAlisIskonto write FAlisIskonto;
    Property SatisIskonto: TFieldDB read FSatisIskonto write FSatisIskonto;
    Property AlisFiyat: TFieldDB read FAlisFiyat write FAlisFiyat;
    Property AlisPara: TFieldDB read FAlisPara write FAlisPara;
    Property SatisFiyat: TFieldDB read FSatisFiyat write FSatisFiyat;
    Property SatisPara: TFieldDB read FSatisPara write FSatisPara;
    Property IhracFiyat: TFieldDB read FIhracFiyat write FIhracFiyat;
    Property IhracPara: TFieldDB read FIhracPara write FIhracPara;
    Property OrtalamaMaliyet: TFieldDB read FOrtalamaMaliyet write FOrtalamaMaliyet;
    Property En: TFieldDB read FEn write FEn;
    Property Boy: TFieldDB read FBoy write FBoy;
    Property Yukseklik: TFieldDB read FYukseklik write FYukseklik;
    Property Agirlik: TFieldDB read FAgirlik write FAgirlik;
    Property TeminSuresi: TFieldDB read FTeminSuresi write FTeminSuresi;
    Property OzelKod: TFieldDB read FOzelKod write FOzelKod;
    Property Marka: TFieldDB read FMarka write FMarka;
    Property MenseiID: TFieldDB read FMenseiID write FMenseiID;
    Property Mensei: TFieldDB read FMensei write FMensei;
    Property GtipNo: TFieldDB read FGtipNo write FGtipNo;
    Property DiibUrunTanimi: TFieldDB read FDiibUrunTanimi write FDiibUrunTanimi;
    Property EnAzStokSeviyesi: TFieldDB read FEnAzStokSeviyesi write FEnAzStokSeviyesi;
    Property Tanim: TFieldDB read FTanim write FTanim;
    Property StokResim: TFieldDB read FStokResim write FStokResim;
    Property CinsID: TFieldDB read FCinsID write FCinsID;
    Property Cins: TFieldDB read FCins write FCins;
    Property S1: TFieldDB read FS1 write FS1;
    Property S2: TFieldDB read FS2 write FS2;
    Property S3: TFieldDB read FS3 write FS3;
    Property S4: TFieldDB read FS4 write FS4;
    Property S5: TFieldDB read FS5 write FS5;
    Property S6: TFieldDB read FS6 write FS6;
    Property S7: TFieldDB read FS7 write FS7;
    Property S8: TFieldDB read FS8 write FS8;
    Property I1: TFieldDB read FI1 write FI1;
    Property I2: TFieldDB read FI2 write FI2;
    Property I3: TFieldDB read FI3 write FI3;
    Property I4: TFieldDB read FI4 write FI4;
    Property D1: TFieldDB read FD1 write FD1;
    Property D2: TFieldDB read FD2 write FD2;
    Property D3: TFieldDB read FD3 write FD3;
    Property D4: TFieldDB read FD4 write FD4;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TStkStokKarti.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_stok_karti';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkStokGrubu := TStkStokGrubu.Create(Database);
  FSysBirim := TSysOlcuBirimi.Create(Database);
  FCinsOzelligi := TStkCinsOzelligi.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSetStkUrunTipi := TSetStkUrunTipi.Create(Database);

  FIsSatilabilir := TFieldDB.Create('is_satilabilir', ftBoolean, False, Self, 'Satýlabilir?');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, 'Stok Kodu');
  FStokAdi := TFieldDB.Create('stok_adi', ftString, '', Self, 'Stok Adý');
  FStokGrubuID := TFieldDB.Create('stok_grubu_id', ftInteger, 0, Self, 'Stok Grubu ID');
  FStokGrubu := TFieldDB.Create(FStkStokGrubu.StokGrubu.FieldName, FStkStokGrubu.StokGrubu.DataType, '', Self, 'Stok Grubu');
  FOlcuBirimiID := TFieldDB.Create('olcu_birimi_id', ftInteger, 0, Self, 'Ölçü Birimi ID');
  FOlcuBirimi := TFieldDB.Create(FSysBirim.OlcuBirimi.FieldName, FSysBirim.OlcuBirimi.DataType, '', Self, 'Ölçü Birimi');
  FUrunTipiID := TFieldDB.Create('urun_tipi_id', ftInteger, 0, Self, 'Ürün Tipi ID');
  FUrunTipi := TFieldDB.Create(FSetStkUrunTipi.UrunTipi.FieldName, FSetStkUrunTipi.UrunTipi.DataType, '', Self, 'Ürün Tipi');
  FAlisIskonto := TFieldDB.Create('alis_iskonto', ftFloat, 0, Self, 'Alýþ Ýskonto');
  FSatisIskonto := TFieldDB.Create('satis_iskonto', ftFloat, 0, Self, 'Satýþ Ýskonto');
  FAlisFiyat := TFieldDB.Create('alis_fiyat', ftFloat, 0, Self, 'Alýþ Fiyat');
  FAlisPara := TFieldDB.Create('alis_para', ftString, '', Self, 'Alýþ Para');
  FSatisFiyat := TFieldDB.Create('satis_fiyat', ftFloat, 0, Self, 'Satýþ Fiyat');
  FSatisPara := TFieldDB.Create('satis_para', ftString, '', Self, 'Satýþ Para');
  FIhracFiyat := TFieldDB.Create('ihrac_fiyat', ftFloat, 0, Self, 'Ýhraç Fiyatý');
  FIhracPara := TFieldDB.Create('ihrac_para', ftString, '', Self, 'Ýhraç Para');
  FOrtalamaMaliyet := TFieldDB.Create('ortalama_maliyet', ftFloat, 0, Self, 'Ortalama Maliyet');
  FEn := TFieldDB.Create('en', ftFloat, 0, Self, 'En');
  FBoy := TFieldDB.Create('boy', ftFloat, 0, Self, 'Boy');
  FYukseklik := TFieldDB.Create('yukseklik', ftFloat, 0, Self, 'Yükseklik');
  FAgirlik := TFieldDB.Create('agirlik', ftFloat, 0, Self, 'Aðýrlýk');
  FTeminSuresi := TFieldDB.Create('temin_suresi', ftInteger, 0, Self, 'Temin Süresi');
  FOzelKod := TFieldDB.Create('ozel_kod', ftString, '', Self, 'Özel Kod');
  FMarka := TFieldDB.Create('marka', ftString, '', Self, 'Marka');
  FMenseiID := TFieldDB.Create('mensei_id', ftInteger, 0, Self, 'Menþei ID');
  FMensei := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self, 'Menþei');
  FGtipNo := TFieldDB.Create('gtip_no', ftString, '', Self, 'GTIP No');
  FDiibUrunTanimi := TFieldDB.Create('diib_urun_tanimi', ftString, '', Self, 'DÝÝB Ürün Tanýmý');
  FEnAzStokSeviyesi := TFieldDB.Create('en_az_stok_seviyesi', ftFloat, 0, Self, 'En Az Stok Seviyesi');
  FTanim := TFieldDB.Create('tanim', ftString, '', Self, 'Taným');
  FStokResim := TFieldDB.Create('stok_resim', ftBytes, 0, Self, 'Stok Resim');
  FCinsID := TFieldDB.Create('cins_id', ftInteger, 0, Self, 'Cins ID');
  FCins := TFieldDB.Create(FCinsOzelligi.Cins.FieldName, FCinsOzelligi.Cins.DataType, '', Self, 'Cins');
  FS1 := TFieldDB.Create('s1', ftString, '', Self, 'S1');
  FS2 := TFieldDB.Create('s2', ftString, '', Self, 'S2');
  FS3 := TFieldDB.Create('s3', ftString, '', Self, 'S3');
  FS4 := TFieldDB.Create('s4', ftString, '', Self, 'S4');
  FS5 := TFieldDB.Create('s5', ftString, '', Self, 'S5');
  FS6 := TFieldDB.Create('s6', ftString, '', Self, 'S6');
  FS7 := TFieldDB.Create('s7', ftString, '', Self, 'S7');
  FS8 := TFieldDB.Create('s8', ftString, '', Self, 'S8');
  FI1 := TFieldDB.Create('i1', ftInteger, 0, Self, 'I1');
  FI2 := TFieldDB.Create('i2', ftInteger, 0, Self, 'I2');
  FI3 := TFieldDB.Create('i3', ftInteger, 0, Self, 'I3');
  FI4 := TFieldDB.Create('i4', ftInteger, 0, Self, 'I4');
  FD1 := TFieldDB.Create('d1', ftFloat, 0, Self, 'D1');
  FD2 := TFieldDB.Create('d2', ftFloat, 0, Self, 'D2');
  FD3 := TFieldDB.Create('d3', ftFloat, 0, Self, 'D3');
  FD4 := TFieldDB.Create('d4', ftFloat, 0, Self, 'D4');
end;

destructor TStkStokKarti.Destroy;
begin
  FStkStokGrubu.Free;
  FSysBirim.Free;
  FCinsOzelligi.Free;
  FSysUlke.Free;
  FSetStkUrunTipi.Free;
  inherited;
end;

procedure TStkStokKarti.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIsSatilabilir.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FStokAdi.FieldName,
        TableName + '.' + FStokGrubuID.FieldName,
        addField(FStkStokGrubu.TableName, FStkStokGrubu.StokGrubu.FieldName, FStokGrubu.FieldName),
        TableName + '.' + FOlcuBirimiID.FieldName,
        addField(FSysBirim.TableName, FSysBirim.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        TableName + '.' + FUrunTipiID.FieldName,
        addField(FSetStkUrunTipi.TableName, FSetStkUrunTipi.UrunTipi.FieldName, FUrunTipi.FieldName),
        TableName + '.' + FAlisIskonto.FieldName,
        TableName + '.' + FSatisIskonto.FieldName,
        TableName + '.' + FAlisFiyat.FieldName,
        TableName + '.' + FAlisPara.FieldName,
        TableName + '.' + FSatisFiyat.FieldName,
        TableName + '.' + FSatisPara.FieldName,
        TableName + '.' + FIhracFiyat.FieldName,
        TableName + '.' + FIhracPara.FieldName,
        TableName + '.' + FOrtalamaMaliyet.FieldName,
        TableName + '.' + FEn.FieldName,
        TableName + '.' + FBoy.FieldName,
        TableName + '.' + FYukseklik.FieldName,
        TableName + '.' + FAgirlik.FieldName,
        TableName + '.' + FTeminSuresi.FieldName,
        TableName + '.' + FOzelKod.FieldName,
        TableName + '.' + FMarka.FieldName,
        TableName + '.' + FMenseiID.FieldName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FMensei.FieldName),
        TableName + '.' + FGtipNo.FieldName,
        TableName + '.' + FDiibUrunTanimi.FieldName,
        TableName + '.' + FEnAzStokSeviyesi.FieldName,
        TableName + '.' + FTanim.FieldName,
        TableName + '.' + FStokResim.FieldName,
        TableName + '.' + FCinsID.FieldName,
        addField(FCinsOzelligi.TableName, FCinsOzelligi.Cins.FieldName, FCins.FieldName),
        TableName + '.' + FS1.FieldName,
        TableName + '.' + FS2.FieldName,
        TableName + '.' + FS3.FieldName,
        TableName + '.' + FS4.FieldName,
        TableName + '.' + FS5.FieldName,
        TableName + '.' + FS6.FieldName,
        TableName + '.' + FS7.FieldName,
        TableName + '.' + FS8.FieldName,
        TableName + '.' + FI1.FieldName,
        TableName + '.' + FI2.FieldName,
        TableName + '.' + FI3.FieldName,
        TableName + '.' + FI4.FieldName,
        TableName + '.' + FD1.FieldName,
        TableName + '.' + FD2.FieldName,
        TableName + '.' + FD3.FieldName,
        TableName + '.' + FD4.FieldName
      ], [
        addJoin(jtLeft, FStkStokGrubu.TableName, FStkStokGrubu.Id.FieldName, TableName, FStokGrubuID.FieldName),
        addJoin(jtLeft, FSysBirim.TableName, FSysBirim.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
        addJoin(jtLeft, FSetStkUrunTipi.TableName, FSetStkUrunTipi.Id.FieldName, TableName, FUrunTipiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FMenseiID.FieldName),
        addJoin(jtLeft, FCinsOzelligi.TableName, FCinsOzelligi.Id.FieldName, TableName, FCinsID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TStkStokKarti.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
        TableName + '.' + FIsSatilabilir.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FStokAdi.FieldName,
        TableName + '.' + FStokGrubuID.FieldName,
        addField(FStkStokGrubu.TableName, FStkStokGrubu.StokGrubu.FieldName, FStokGrubu.FieldName),
        TableName + '.' + FOlcuBirimiID.FieldName,
        addField(FSysBirim.TableName, FSysBirim.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        TableName + '.' + FUrunTipiID.FieldName,
        addField(FSetStkUrunTipi.TableName, FSetStkUrunTipi.UrunTipi.FieldName, FUrunTipi.FieldName),
        TableName + '.' + FAlisIskonto.FieldName,
        TableName + '.' + FSatisIskonto.FieldName,
        TableName + '.' + FAlisFiyat.FieldName,
        TableName + '.' + FAlisPara.FieldName,
        TableName + '.' + FSatisFiyat.FieldName,
        TableName + '.' + FSatisPara.FieldName,
        TableName + '.' + FIhracFiyat.FieldName,
        TableName + '.' + FIhracPara.FieldName,
        TableName + '.' + FOrtalamaMaliyet.FieldName,
        TableName + '.' + FEn.FieldName,
        TableName + '.' + FBoy.FieldName,
        TableName + '.' + FYukseklik.FieldName,
        TableName + '.' + FAgirlik.FieldName,
        TableName + '.' + FTeminSuresi.FieldName,
        TableName + '.' + FOzelKod.FieldName,
        TableName + '.' + FMarka.FieldName,
        TableName + '.' + FMenseiID.FieldName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FMensei.FieldName),
        TableName + '.' + FGtipNo.FieldName,
        TableName + '.' + FDiibUrunTanimi.FieldName,
        TableName + '.' + FEnAzStokSeviyesi.FieldName,
        TableName + '.' + FTanim.FieldName,
        TableName + '.' + FStokResim.FieldName,
        TableName + '.' + FCinsID.FieldName,
        addField(FCinsOzelligi.TableName, FCinsOzelligi.Cins.FieldName, FCins.FieldName),
        TableName + '.' + FS1.FieldName,
        TableName + '.' + FS2.FieldName,
        TableName + '.' + FS3.FieldName,
        TableName + '.' + FS4.FieldName,
        TableName + '.' + FS5.FieldName,
        TableName + '.' + FS6.FieldName,
        TableName + '.' + FS7.FieldName,
        TableName + '.' + FS8.FieldName,
        TableName + '.' + FI1.FieldName,
        TableName + '.' + FI2.FieldName,
        TableName + '.' + FI3.FieldName,
        TableName + '.' + FI4.FieldName,
        TableName + '.' + FD1.FieldName,
        TableName + '.' + FD2.FieldName,
        TableName + '.' + FD3.FieldName,
        TableName + '.' + FD4.FieldName
      ], [
        addJoin(jtLeft, FStkStokGrubu.TableName, FStkStokGrubu.Id.FieldName, TableName, FStokGrubuID.FieldName),
        addJoin(jtLeft, FSysBirim.TableName, FSysBirim.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
        addJoin(jtLeft, FSetStkUrunTipi.TableName, FSetStkUrunTipi.Id.FieldName, TableName, FUrunTipiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FMenseiID.FieldName),
        addJoin(jtLeft, FCinsOzelligi.TableName, FCinsOzelligi.Id.FieldName, TableName, FCinsID.FieldName),
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

procedure TStkStokKarti.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIsSatilabilir.FieldName,
        FStokKodu.FieldName,
        FStokAdi.FieldName,
        FStokGrubuID.FieldName,
        FOlcuBirimiID.FieldName,
        FUrunTipiID.FieldName,
        FAlisIskonto.FieldName,
        FSatisIskonto.FieldName,
        FAlisFiyat.FieldName,
        FAlisPara.FieldName,
        FSatisFiyat.FieldName,
        FSatisPara.FieldName,
        FIhracFiyat.FieldName,
        FIhracPara.FieldName,
        FOrtalamaMaliyet.FieldName,
        FEn.FieldName,
        FBoy.FieldName,
        FYukseklik.FieldName,
        FAgirlik.FieldName,
        FTeminSuresi.FieldName,
        FOzelKod.FieldName,
        FMarka.FieldName,
        FMenseiID.FieldName,
        FGtipNo.FieldName,
        FDiibUrunTanimi.FieldName,
        FEnAzStokSeviyesi.FieldName,
        FTanim.FieldName,
        FStokResim.FieldName,
        FCinsID.FieldName,
        FS1.FieldName,
        FS2.FieldName,
        FS3.FieldName,
        FS4.FieldName,
        FS5.FieldName,
        FS6.FieldName,
        FS7.FieldName,
        FS8.FieldName,
        FI1.FieldName,
        FI2.FieldName,
        FI3.FieldName,
        FI4.FieldName,
        FD1.FieldName,
        FD2.FieldName,
        FD3.FieldName,
        FD4.FieldName
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

procedure TStkStokKarti.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIsSatilabilir.FieldName,
        FStokKodu.FieldName,
        FStokAdi.FieldName,
        FStokGrubuID.FieldName,
        FOlcuBirimiID.FieldName,
        FUrunTipiID.FieldName,
        FAlisIskonto.FieldName,
        FSatisIskonto.FieldName,
        FAlisFiyat.FieldName,
        FAlisPara.FieldName,
        FSatisFiyat.FieldName,
        FSatisPara.FieldName,
        FIhracFiyat.FieldName,
        FIhracPara.FieldName,
        FOrtalamaMaliyet.FieldName,
        FEn.FieldName,
        FBoy.FieldName,
        FYukseklik.FieldName,
        FAgirlik.FieldName,
        FTeminSuresi.FieldName,
        FOzelKod.FieldName,
        FMarka.FieldName,
        FMenseiID.FieldName,
        FGtipNo.FieldName,
        FDiibUrunTanimi.FieldName,
        FEnAzStokSeviyesi.FieldName,
        FTanim.FieldName,
        FStokResim.FieldName,
        FCinsID.FieldName,
        FS1.FieldName,
        FS2.FieldName,
        FS3.FieldName,
        FS4.FieldName,
        FS5.FieldName,
        FS6.FieldName,
        FS7.FieldName,
        FS8.FieldName,
        FI1.FieldName,
        FI2.FieldName,
        FI3.FieldName,
        FI4.FieldName,
        FD1.FieldName,
        FD2.FieldName,
        FD3.FieldName,
        FD4.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TStkStokKarti.Clone: TTable;
begin
  Result := TStkStokKarti.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
