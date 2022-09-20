unit Ths.Erp.Database.Table.StkStokKarti;

interface

{$I ThsERP.inc}

uses
  System.Variants,
  System.SysUtils,
  System.Math,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.StkStokGrubu,
  Ths.Erp.Database.Table.SysOlcuBirimi,
  Ths.Erp.Database.Table.StkCinsOzelligi,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SetStkUrunTipi,
  Ths.Erp.Database.Table.SysParaBirimi,
  Ths.Erp.Database.Table.MhsDovizKuru;

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
    FSysOlcuBirimi: TSysOlcuBirimi;
    FStkCinsOzelligi: TStkCinsOzelligi;
    FSysUlke: TSysUlke;
    FSetStkUrunTipi: TSetStkUrunTipi;
  public
    function GetSatisFiyatiByDoviz(AParaBirimi: string; ADovizKuru: Double; AKurTarihi: TDateTime): Double;
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
  Ths.Erp.Constants;

constructor TStkStokKarti.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_stok_karti';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkStokGrubu := TStkStokGrubu.Create(Database);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(Database);
  FStkCinsOzelligi := TStkCinsOzelligi.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FSetStkUrunTipi := TSetStkUrunTipi.Create(Database);

  FIsSatilabilir := TFieldDB.Create('is_satilabilir', ftBoolean, False, Self, 'Satýlabilir?');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, 'Stok Kodu');
  FStokAdi := TFieldDB.Create('stok_adi', ftString, '', Self, 'Stok Adý');
  FStokGrubuID := TFieldDB.Create('stok_grubu_id', ftInteger, 0, Self, 'Stok Grubu ID');
  FStokGrubu := TFieldDB.Create(FStkStokGrubu.StokGrubu.FieldName, FStkStokGrubu.StokGrubu.DataType, '', Self, 'Stok Grubu');
  FOlcuBirimiID := TFieldDB.Create('olcu_birimi_id', ftInteger, 0, Self, 'Ölçü Birimi ID');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.OlcuBirimi.FieldName, FSysOlcuBirimi.OlcuBirimi.DataType, '', Self, 'Ölçü Birimi');
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
  FCins := TFieldDB.Create(FStkCinsOzelligi.Cins.FieldName, FStkCinsOzelligi.Cins.DataType, '', Self, 'Cins');
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
  FSysOlcuBirimi.Free;
  FStkCinsOzelligi.Free;
  FSysUlke.Free;
  FSetStkUrunTipi.Free;
  inherited;
end;

function TStkStokKarti.GetSatisFiyatiByDoviz(AParaBirimi: string; ADovizKuru: Double; AKurTarihi: TDateTime): Double;
var
  n1, n2: Integer;
  LDovizKuru: TMhsDovizKuru;
begin
  if AKurTarihi=0 then
    CreateExceptionByLang('Verilen Kur tarihi "Sýfýr" olamaz!!', '888888');

  Result := 0;
  if SatisPara.AsString = AParaBirimi then
    Result := Self.SatisFiyat.AsFloat
  else
  begin
    for n1 := 0 to GParaBirimi.List.Count-1 do
    begin
      if (AParaBirimi = TSysParaBirimi(GParaBirimi.List[n1]).ParaBirimi.AsString) then
      begin
        if(TSysParaBirimi(GParaBirimi.List[n1]).IsVarsayilan.AsBoolean) then
          Result := SatisPara.AsFloat
        else
        begin
          LDovizKuru := TMhsDovizKuru.Create(Database);
          try
            LDovizKuru.SelectToList(' AND ' + LDovizKuru.Tarih.QryName + '=' + QuotedStr(DateToStr(AKurTarihi)), False, False);
            for n2 := 0 to LDovizKuru.List.Count-1 do
              if TMhsDovizKuru(LDovizKuru.List[n2]).ParaBirimi.AsString = SatisPara.AsString then
              begin
                Result := SimpleRoundTo(SatisFiyat.AsFloat * TMhsDovizKuru(LDovizKuru.List[n2]).Kur.AsFloat / ADovizKuru);
                Break;
              end;
          finally
            FreeAndNil(LDovizKuru);
          end;
        end;
          Break;
      end;
    end;
  end;
end;

procedure TStkStokKarti.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FIsSatilabilir.QryName,
        FStokKodu.QryName,
        FStokAdi.QryName,
        FStokGrubuID.QryName,
        addField(FStkStokGrubu.TableName, FStkStokGrubu.StokGrubu.FieldName, FStokGrubu.FieldName),
        FOlcuBirimiID.QryName,
        addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        FUrunTipiID.QryName,
        addField(FSetStkUrunTipi.TableName, FSetStkUrunTipi.UrunTipi.FieldName, FUrunTipi.FieldName),
        FAlisIskonto.QryName,
        FSatisIskonto.QryName,
        FAlisFiyat.QryName,
        FAlisPara.QryName,
        FSatisFiyat.QryName,
        FSatisPara.QryName,
        FIhracFiyat.QryName,
        FIhracPara.QryName,
        FOrtalamaMaliyet.QryName,
        FEn.QryName,
        FBoy.QryName,
        FYukseklik.QryName,
        FAgirlik.QryName,
        FTeminSuresi.QryName,
        FOzelKod.QryName,
        FMarka.QryName,
        FMenseiID.QryName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FMensei.FieldName),
        FGtipNo.QryName,
        FDiibUrunTanimi.QryName,
        FEnAzStokSeviyesi.QryName,
        FTanim.QryName,
        FStokResim.QryName,
        FCinsID.QryName,
        addField(FStkCinsOzelligi.TableName, FStkCinsOzelligi.Cins.FieldName, FCins.FieldName),
        FS1.QryName,
        FS2.QryName,
        FS3.QryName,
        FS4.QryName,
        FS5.QryName,
        FS6.QryName,
        FS7.QryName,
        FS8.QryName,
        FI1.QryName,
        FI2.QryName,
        FI3.QryName,
        FI4.QryName,
        FD1.QryName,
        FD2.QryName,
        FD3.QryName,
        FD4.QryName
      ], [
        addJoin(jtLeft, FStkStokGrubu.TableName, FStkStokGrubu.Id.FieldName, TableName, FStokGrubuID.FieldName),
        addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
        addJoin(jtLeft, FSetStkUrunTipi.TableName, FSetStkUrunTipi.Id.FieldName, TableName, FUrunTipiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FMenseiID.FieldName),
        addJoin(jtLeft, FStkCinsOzelligi.TableName, FStkCinsOzelligi.Id.FieldName, TableName, FCinsID.FieldName),
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
        Id.QryName,
        FIsSatilabilir.QryName,
        FStokKodu.QryName,
        FStokAdi.QryName,
        FStokGrubuID.QryName,
        addField(FStkStokGrubu.TableName, FStkStokGrubu.StokGrubu.FieldName, FStokGrubu.FieldName),
        FOlcuBirimiID.QryName,
        addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        FUrunTipiID.QryName,
        addField(FSetStkUrunTipi.TableName, FSetStkUrunTipi.UrunTipi.FieldName, FUrunTipi.FieldName),
        FAlisIskonto.QryName,
        FSatisIskonto.QryName,
        FAlisFiyat.QryName,
        FAlisPara.QryName,
        FSatisFiyat.QryName,
        FSatisPara.QryName,
        FIhracFiyat.QryName,
        FIhracPara.QryName,
        FOrtalamaMaliyet.QryName,
        FEn.QryName,
        FBoy.QryName,
        FYukseklik.QryName,
        FAgirlik.QryName,
        FTeminSuresi.QryName,
        FOzelKod.QryName,
        FMarka.QryName,
        FMenseiID.QryName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FMensei.FieldName),
        FGtipNo.QryName,
        FDiibUrunTanimi.QryName,
        FEnAzStokSeviyesi.QryName,
        FTanim.QryName,
        FStokResim.QryName,
        FCinsID.QryName,
        addField(FStkCinsOzelligi.TableName, FStkCinsOzelligi.Cins.FieldName, FCins.FieldName),
        FS1.QryName,
        FS2.QryName,
        FS3.QryName,
        FS4.QryName,
        FS5.QryName,
        FS6.QryName,
        FS7.QryName,
        FS8.QryName,
        FI1.QryName,
        FI2.QryName,
        FI3.QryName,
        FI4.QryName,
        FD1.QryName,
        FD2.QryName,
        FD3.QryName,
        FD4.QryName
      ], [
        addJoin(jtLeft, FStkStokGrubu.TableName, FStkStokGrubu.Id.FieldName, TableName, FStokGrubuID.FieldName),
        addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
        addJoin(jtLeft, FSetStkUrunTipi.TableName, FSetStkUrunTipi.Id.FieldName, TableName, FUrunTipiID.FieldName),
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FMenseiID.FieldName),
        addJoin(jtLeft, FStkCinsOzelligi.TableName, FStkCinsOzelligi.Id.FieldName, TableName, FCinsID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

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
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
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
  end;
end;

function TStkStokKarti.Clone: TTable;
begin
  Result := TStkStokKarti.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
