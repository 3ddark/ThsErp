unit Ths.Database.Table.StkKartlar;

interface

{$I Ths.inc}

uses
  System.Variants,
  System.SysUtils,
  System.Classes,
  System.Math,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.StkGruplar,
  Ths.Database.Table.SysOlcuBirimleri,
  Ths.Database.Table.StkCinsOzellikleri,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysParaBirimleri,
  Ths.Database.Table.ChDovizKurlari,
  Ths.Database.Table.StkResimler,
  Ths.Database.Table.StkKartCinsBilgileri;

type
  TStkUrunTipi = (sutHammadde=1, sutYariMamul, sutMamul, sutHizmet);

  TStkKart = class(TTable)
  private
    FIsSatilabilir: TFieldDB;
    FStokKodu: TFieldDB;
    FStokAdi: TFieldDB;
    FStokGrubuID: TFieldDB;
    FStokGrubu: TFieldDB;
    FOlcuBirimiID: TFieldDB;
    FOlcuBirimi: TFieldDB;
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
    //db alanı değil
    FCins: TFieldDB;
    FResim: TFieldDB;
    FCinsBilgisi: TStkKartCinsBilgisi;
  protected
    FStkStokGrubu: TStkGruplar;
    FSysOlcuBirimi: TSysOlcuBirimi;
    FStkCinsOzelligi: TStkCinsOzelligi;
    FSysUlke: TSysUlke;
    FStkResim: TStkResim;

    procedure BusinessSelect(AFilter: string; ALock: Boolean; APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  public
    function GetSatisFiyatiByDoviz(AParaBirimi: string; ADovizKuru: Double; AKurTarihi: TDateTime): Double;
  published
    constructor Create(ADatabase: TDatabase); override;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    destructor Destroy; override;

    Property IsSatilabilir: TFieldDB read FIsSatilabilir write FIsSatilabilir;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property StokGrubuID: TFieldDB read FStokGrubuID write FStokGrubuID;
    Property StokGrubu: TFieldDB read FStokGrubu write FStokGrubu;
    Property OlcuBirimiID: TFieldDB read FOlcuBirimiID write FOlcuBirimiID;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
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
    Property Cins: TFieldDB read FCins write FCins;
    Property Resim: TFieldDB read FResim write FResim;
    Property CinsBilgisi: TStkKartCinsBilgisi read FCinsBilgisi write FCinsBilgisi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkKart.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_kartlar';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FStkStokGrubu := TStkGruplar.Create(Database);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(Database);
  FStkCinsOzelligi := TStkCinsOzelligi.Create(Database);
  FSysUlke := TSysUlke.Create(Database);
  FStkResim := TStkResim.Create(Database);

  FIsSatilabilir := TFieldDB.Create('is_satilabilir', ftBoolean, False, Self, 'Satılabilir?');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, 'Stok Kodu');
  FStokAdi := TFieldDB.Create('stok_adi', ftString, '', Self, 'Stok Adı');
  FStokGrubuID := TFieldDB.Create('stok_grubu_id', ftInteger, 0, Self, 'Stok Grubu ID');
  FStokGrubu := TFieldDB.Create(FStkStokGrubu.Grup.FieldName, FStkStokGrubu.Grup.DataType, '', Self, 'Stok Grubu');
  FOlcuBirimiID := TFieldDB.Create('olcu_birimi_id', ftInteger, 0, Self, 'Ölçü Birimi ID');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.Birim.FieldName, FSysOlcuBirimi.Birim.DataType, '', Self, 'Ölçü Birimi');
  FUrunTipi := TFieldDB.Create('urun_tipi', ftSmallInt, 0, Self, 'Ürün Tipi');
  FAlisIskonto := TFieldDB.Create('alis_iskonto', ftFloat, 0, Self, 'Alış İskonto');
  FSatisIskonto := TFieldDB.Create('satis_iskonto', ftFloat, 0, Self, 'Satış İskonto');
  FAlisFiyat := TFieldDB.Create('alis_fiyat', ftFloat, 0, Self, 'Alış Fiyat');
  FAlisPara := TFieldDB.Create('alis_para', ftString, '', Self, 'Alış Para');
  FSatisFiyat := TFieldDB.Create('satis_fiyat', ftFloat, 0, Self, 'Satış Fiyat');
  FSatisPara := TFieldDB.Create('satis_para', ftString, '', Self, 'Satış Para');
  FIhracFiyat := TFieldDB.Create('ihrac_fiyat', ftFloat, 0, Self, 'İhraç Fiyatı');
  FIhracPara := TFieldDB.Create('ihrac_para', ftString, '', Self, 'İhraç Para');
  FOrtalamaMaliyet := TFieldDB.Create('ortalama_maliyet', ftFloat, 0, Self, 'Ortalama Maliyet');
  FEn := TFieldDB.Create('en', ftFloat, 0, Self, 'En');
  FBoy := TFieldDB.Create('boy', ftFloat, 0, Self, 'Boy');
  FYukseklik := TFieldDB.Create('yukseklik', ftFloat, 0, Self, 'Yükseklik');
  FAgirlik := TFieldDB.Create('agirlik', ftFloat, 0, Self, 'Ağırlık');
  FTeminSuresi := TFieldDB.Create('temin_suresi', ftInteger, 0, Self, 'Temin Süresi');
  FOzelKod := TFieldDB.Create('ozel_kod', ftString, '', Self, 'Özel Kod');
  FMarka := TFieldDB.Create('marka', ftString, '', Self, 'Marka');
  FMenseiID := TFieldDB.Create('mensei_id', ftInteger, 0, Self, 'Menşei ID');
  FMensei := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self, 'Menşei');
  FGtipNo := TFieldDB.Create('gtip_no', ftString, '', Self, 'GTIP No');
  FDiibUrunTanimi := TFieldDB.Create('diib_urun_tanimi', ftString, '', Self, 'DİİB Ürün Tanımı');
  FEnAzStokSeviyesi := TFieldDB.Create('en_az_stok_seviyesi', ftFloat, 0, Self, 'En Az Stok Seviyesi');
  FTanim := TFieldDB.Create('tanim', ftString, '', Self, 'Tanım');
  FCins := TFieldDB.Create(FStkCinsOzelligi.Cins.FieldName, FStkCinsOzelligi.Cins.DataType, '', Self, 'Cins');
  FResim := TFieldDB.Create(FStkResim.Resim.FieldName, FStkResim.Resim.DataType, FStkResim.Resim.Value, Self, FStkResim.Resim.Title);

  FCinsBilgisi := TStkKartCinsBilgisi.Create(GDatabase);
end;

destructor TStkKart.Destroy;
begin
  FStkStokGrubu.Free;
  FSysOlcuBirimi.Free;
  FStkCinsOzelligi.Free;
  FSysUlke.Free;
  FStkResim.Free;

  FCinsBilgisi.Free;
  inherited;
end;

function TStkKart.GetSatisFiyatiByDoviz(AParaBirimi: string; ADovizKuru: Double; AKurTarihi: TDateTime): Double;
var
  n1, n2: Integer;
  LDovizKuru: TChDovizKuru;
begin
  if AKurTarihi=0 then
    CreateExceptionByLang('Verilen Kur tarihi "Sıfır" olamaz!!', '888888');

  Result := 0;
  if SatisPara.AsString = AParaBirimi then
    Result := Self.SatisFiyat.AsFloat
  else
  begin
    for n1 := 0 to GParaBirimi.List.Count-1 do
    begin
      if (AParaBirimi = TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString) then
      begin
        if (TSysParaBirimi(GParaBirimi.List[n1]).Para.AsString = GSysApplicationSetting.Para.AsString) then
          Result := SatisPara.AsFloat
        else
        begin
          LDovizKuru := TChDovizKuru.Create(Database);
          try
            LDovizKuru.SelectToList(' AND ' + LDovizKuru.KurTarihi.QryName + '=' + QuotedStr(DateToStr(AKurTarihi)), False, False);
            for n2 := 0 to LDovizKuru.List.Count-1 do
              if TChDovizKuru(LDovizKuru.List[n2]).Para.AsString = SatisPara.AsString then
              begin
                Result := SimpleRoundTo(SatisFiyat.AsFloat * TChDovizKuru(LDovizKuru.List[n2]).Kur.AsFloat / ADovizKuru);
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

procedure TStkKart.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FIsSatilabilir.QryName,
      FStokKodu.QryName,
      FStokAdi.QryName,
      FStokGrubuID.QryName,
      addField(FStkStokGrubu.TableName, FStkStokGrubu.Grup.FieldName, FStokGrubu.FieldName),
      FOlcuBirimiID.QryName,
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      FUrunTipi.QryName,
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
      addField(FStkCinsOzelligi.TableName, FStkCinsOzelligi.Cins.FieldName, FCins.FieldName),
      FResim.FieldName
    ], [
      addJoin(jtLeft, FStkStokGrubu.TableName, FStkStokGrubu.Id.FieldName, TableName, FStokGrubuID.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FMenseiID.FieldName),
      addJoin(jtLeft, FStkResim.TableName, FStkResim.StkKartId.FieldName, TableName, Id.FieldName),
      addJoin(jtLeft, FCinsBilgisi.TableName, FCinsBilgisi.StkKartId.FieldName, TableName, Id.FieldName),
      addJoin(jtLeft, FStkCinsOzelligi.TableName, FStkCinsOzelligi.Id.FieldName, FCinsBilgisi.TableName, FCinsBilgisi.CinsID.FieldName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TStkKart.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FIsSatilabilir.QryName,
      FStokKodu.QryName,
      FStokAdi.QryName,
      FStokGrubuID.QryName,
      addField(FStkStokGrubu.TableName, FStkStokGrubu.Grup.FieldName, FStokGrubu.FieldName),
      FOlcuBirimiID.QryName,
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      FUrunTipi.QryName,
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
      addField(FStkCinsOzelligi.TableName, FStkCinsOzelligi.Cins.FieldName, FCins.FieldName),
      FResim.FieldName
    ], [
      addJoin(jtLeft, FStkStokGrubu.TableName, FStkStokGrubu.Id.FieldName, TableName, FStokGrubuID.FieldName),
      addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, TableName, FOlcuBirimiID.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FMenseiID.FieldName),
      addJoin(jtLeft, FCinsBilgisi.TableName, FCinsBilgisi.StkKartID.FieldName, TableName, Id.FieldName),
      addJoin(jtLeft, FStkCinsOzelligi.TableName, FStkCinsOzelligi.Id.FieldName, FCinsBilgisi.TableName, FCinsBilgisi.CinsID.FieldName),
      addJoin(jtLeft, FStkResim.TableName, FStkResim.StkKartId.FieldName, TableName, Id.FieldName),
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

procedure TStkKart.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FIsSatilabilir.FieldName,
      FStokKodu.FieldName,
      FStokAdi.FieldName,
      FStokGrubuID.FieldName,
      FOlcuBirimiID.FieldName,
      FUrunTipi.FieldName,
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
      FTanim.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TStkKart.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FIsSatilabilir.FieldName,
      FStokKodu.FieldName,
      FStokAdi.FieldName,
      FStokGrubuID.FieldName,
      FOlcuBirimiID.FieldName,
      FUrunTipi.FieldName,
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
      FTanim.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

procedure TStkKart.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    TStkKart(Self.List[n1]).FCinsBilgisi.Clear;
    TStkKart(Self.List[n1]).FCinsBilgisi.SelectToList(' AND ' + TStkKart(Self.List[n1]).CinsBilgisi.StkKartID.QryName + '=' + TStkKart(Self.List[n1]).Id.AsString, ALock, False);
    TStkKart(Self.List[n1]).FStkResim.Clear;
    TStkKart(Self.List[n1]).FStkResim.SelectToList(' AND ' + TStkKart(Self.List[n1]).FStkResim.StkKartID.QryName + '=' + TStkKart(Self.List[n1]).Id.AsString, ALock, False);
  end;
end;

procedure TStkKart.BusinessInsert(APermissionControl: Boolean);
var
  LResim: TStkResim;
begin
  Self.Insert(APermissionControl);
  Self.FCinsBilgisi.StkKartID.Value := Self.Id.AsInt64;
  Self.FCinsBilgisi.Insert(False);

  if Length(Self.Resim.Value) > 0 then
  begin
    LResim := TStkResim.Create(Database);
    try
      LResim.SelectToList(' AND ' + LResim.StkKartID.QryName + '=' + Self.Id.AsString, False, False);
      if LResim.List.Count=1 then
      begin
        LResim.Resim.Value := Self.Resim.AsString;
        LResim.Update(False);
      end
    finally
      LResim.Free;
    end;
  end;
end;

procedure TStkKart.BusinessUpdate(APermissionControl: Boolean);
var
  LResim: TStkResim;
begin
  Self.Update(APermissionControl);
  if Self.FCinsBilgisi.Id.AsInt64 > 0 then
  begin
    Self.FCinsBilgisi.Update(False);
  end
  else
  begin
    Self.FCinsBilgisi.StkKartID.Value := Self.Id.AsInt64;
    Self.FCinsBilgisi.Insert(False);
  end;

  LResim := TStkResim.Create(Database);
  try
    if Self.Resim.AsString = '' then
    begin
      LResim.SelectToList(' AND ' + LResim.StkKartID.QryName + '=' + Self.Id.AsString, False, False);
      LResim.Delete(False);
    end
    else
    begin
      LResim.SelectToList(' AND ' + LResim.StkKartID.QryName + '=' + Self.Id.AsString, False, False);
      if LResim.List.Count=1 then
      begin
        LResim.Resim.Value := Self.Resim.AsString;
        LResim.Update(False);
      end
      else
      begin
        LResim.StkKartID.Value := Self.Id.AsInt64;
        LResim.Resim.Value := Self.Resim.AsString;
        LResim.Insert(False);
      end;
    end;
  finally
    LResim.Free;
  end;
end;

function TStkKart.Clone: TTable;
begin
  Result := TStkKart.Create(Database);
  CloneClassContent(Self, Result);
  CloneClassContent(Self.FCinsBilgisi, TStkKart(Result).FCinsBilgisi);
  CloneClassContent(Self.FStkResim, TStkKart(Result).FStkResim);
end;

end.
