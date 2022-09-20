unit Ths.Erp.Database.Table.RctRecete;

interface

{$I ThsERP.inc}

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Data.DB,
  System.Generics.Collections,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.TableDetailed,
  Ths.Erp.Database.Table.StkStokKarti,
  Ths.Erp.Database.Table.SysOlcuBirimi,
  Ths.Erp.Database.Table.RctIscilikGideri;

type
  TRctRecete = class;

  TReceteTotals = record
    MaliyetHam: Double;
    MaliyetIsc: Double;
    MaliyetYan: Double;
    HammaddeCount: SmallInt;
    IscilikCount: SmallInt;
    YanUrunCount: SmallInt;
  end;

  TRctReceteHammadde = class(TTable)
  private
    FHeaderID: TFieldDB;
    FReceteID: TFieldDB;
    FStokKodu: TFieldDB;
    FMiktar: TFieldDB;
    FFireOrani: TFieldDB;
    //veri tabaný alaný deðil join
    FReceteKodu: TFieldDB;
    FStokAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FStkStokKarti: TStkStokKarti;
    FSysOlcuBirimi: TSysOlcuBirimi;
    FRctRecete: TRctRecete;

    constructor Create(ADatabase: TDatabase; ARecete: TRctRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TRctRecete;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property ReceteID: TFieldDB read FReceteID write FReceteID;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property FireOrani: TFieldDB read FFireOrani write FFireOrani;
    //veri tabaný alaný deðil join
    Property ReceteKodu: TFieldDB read FReceteKodu write FReceteKodu;
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TRctReceteIscilik = class(TTable)
  private
    FHeaderID: TFieldDB;
    FGiderKodu: TFieldDB;
    FMiktar: TFieldDB;
    //veri tabaný alaný deðil join
    FGiderAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FRctIscilikGideri: TRctIscilikGideri;
    FSysOlcuBirimi: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ARecete: TRctRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TRctRecete;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property GiderKodu: TFieldDB read FGiderKodu write FGiderKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    //veri tabaný alaný deðil join
    Property GiderAdi: TFieldDB read FGiderAdi write FGiderAdi;
    Property Birim: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TRctReceteYanUrun = class(TTable)
  private
    FHeaderID: TFieldDB;
    FStokKodu: TFieldDB;
    FMiktar: TFieldDB;
    FFireOrani: TFieldDB;
    //veri tabaný alaný deðil join
    FStokAdi: TFieldDB;
    FOlcuBirimi: TFieldDB;
    FFiyat: TFieldDB;
  published
    FStkStokKarti: TStkStokKarti;
    FSysOlcuBirimi: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ARecete: TRctRecete = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Recete: TRctRecete;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderID: TFieldDB read FHeaderID write FHeaderID;
    Property StokKodu: TFieldDB read FStokKodu write FStokKodu;
    Property Miktar: TFieldDB read FMiktar write FMiktar;
    Property FireOrani: TFieldDB read FFireOrani write FFireOrani;
    //veri tabaný alaný deðil join
    Property StokAdi: TFieldDB read FStokAdi write FStokAdi;
    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property Fiyat: TFieldDB read FFiyat write FFiyat;
  end;

  TRctRecete = class(TTableDetailed)
  private
    FReceteKodu: TFieldDB;
    FReceteAdi: TFieldDB;
    FOrnekUretimMiktari: TFieldDB;
    FAciklama: TFieldDB;
    FMaliyet: TFieldDB;
    FHammaddeMaliyet: TFieldDB;
    FIscilikMaliyet: TFieldDB;
    FYanUrunMaliyet: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
    function ValidateDetay(ATable: TTable): Boolean; override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    ReceteMaliyet: TReceteTotals;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property ReceteKodu: TFieldDB read FReceteKodu write FReceteKodu;
    Property ReceteAdi: TFieldDB read FReceteAdi write FReceteAdi;
    Property OrnekUretimMiktari: TFieldDB read FOrnekUretimMiktari write FOrnekUretimMiktari;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    property Maliyet: TFieldDB read FMaliyet write FMaliyet;
    property HammaddeMaliyet: TFieldDB read FHammaddeMaliyet write FHammaddeMaliyet;
    property IscilikMaliyet: TFieldDB read FIscilikMaliyet write FIscilikMaliyet;
    property YanUrunMaliyet: TFieldDB read FYanUrunMaliyet write FYanUrunMaliyet;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TRctReceteHammadde.Create(ADatabase: TDatabase; ARecete: TRctRecete);
begin
  TableName := 'rct_recete_hammadde';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FStkStokKarti := TStkStokKarti.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);
  FRctRecete := TRctRecete.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FReceteID := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FReceteKodu := TFieldDB.Create(FRctRecete.FReceteKodu.FieldName, FRctRecete.ReceteKodu.DataType, '', Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.OlcuBirimi.FieldName, FSysOlcuBirimi.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TRctReceteHammadde.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FSysOlcuBirimi);
  FreeAndNil(FRctRecete);
  inherited;
end;

procedure TRctReceteHammadde.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FHeaderID.QryName,
        FReceteID.QryName,
        FStokKodu.QryName,
        FMiktar.QryName,
        FFireOrani.QryName
      ], [
        ' WHERE 1=1 ' + AFilter
      ]);
      Open;
    end;
  end;
end;

procedure TRctReceteHammadde.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FHeaderID.QryName,
        FReceteID.QryName,
        FStokKodu.QryName,
        FMiktar.QryName,
        FFireOrani.QryName,
        addField(FRctRecete.TableName, FRctRecete.FReceteKodu.FieldName, FReceteKodu.FieldName),
        addField(FStkStokKarti.TableName, FStkStokKarti.StokAdi.FieldName, FStokAdi.FieldName),
        addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        addField(FStkStokKarti.TableName, FStkStokKarti.AlisFiyat.FieldName, FFiyat.FieldName)
      ], [
        AddJoin(jtLeft, FRctRecete.TableName, FRctRecete.Id.FieldName, TableName, ReceteID.FieldName),
        AddJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
        AddJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FStkStokKarti.TableName, FStkStokKarti.OlcuBirimiID.FieldName),
        ' WHERE 1=1 ' + AFilter
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

procedure TRctReceteHammadde.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHeaderID.FieldName,
        FReceteID.FieldName,
        FStokKodu.FieldName,
        FMiktar.FieldName,
        FFireOrani.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TRctReceteHammadde.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHeaderID.FieldName,
        FReceteID.FieldName,
        FStokKodu.FieldName,
        FMiktar.FieldName,
        FFireOrani.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TRctReceteHammadde.Clone: TTable;
begin
  Result := TRctReceteHammadde.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TRctReceteIscilik.Create(ADatabase: TDatabase; ARecete: TRctRecete);
begin
  TableName := 'rct_recete_iscilik';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FRctIscilikGideri := TRctIscilikGideri.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FGiderKodu := TFieldDB.Create('gider_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FGiderAdi := TFieldDB.Create(FRctIscilikGideri.GiderAdi.FieldName, FRctIscilikGideri.GiderAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.OlcuBirimi.FieldName, FSysOlcuBirimi.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create(FRctIscilikGideri.Fiyat.FieldName, FRctIscilikGideri.Fiyat.DataType, 0, Self, '');
end;

destructor TRctReceteIscilik.Destroy;
begin
  FreeAndNil(FRctIscilikGideri);
  FreeAndNil(FSysOlcuBirimi);
  inherited;
end;

procedure TRctReceteIscilik.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FHeaderID.QryName,
        FGiderKodu.QryName,
        addField(FRctIscilikGideri.TableName, FRctIscilikGideri.GiderAdi.FieldName, FGiderAdi.FieldName),
        FMiktar.QryName,
        addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        addField(FRctIscilikGideri.TableName, FRctIscilikGideri.Fiyat.FieldName, FFiyat.FieldName)
      ], [
        addJoin(jtLeft, FRctIscilikGideri.TableName, FRctIscilikGideri.GiderKodu.FieldName, TableName, FGiderKodu.FieldName),
        addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FRctIscilikGideri.TableName, FRctIscilikGideri.OlcuBirimiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
    end;
  end;
end;

procedure TRctReceteIscilik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FHeaderID.QryName,
        FGiderKodu.QryName,
        addField(FRctIscilikGideri.TableName, FRctIscilikGideri.GiderAdi.FieldName, FGiderAdi.FieldName),
        FMiktar.QryName,
        addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        addField(FRctIscilikGideri.TableName, FRctIscilikGideri.Fiyat.FieldName, FFiyat.FieldName)
      ], [
        addJoin(jtLeft, FRctIscilikGideri.TableName, FRctIscilikGideri.GiderKodu.FieldName, TableName, FGiderKodu.FieldName),
        addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FRctIscilikGideri.TableName, FRctIscilikGideri.OlcuBirimiID.FieldName),
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

procedure TRctReceteIscilik.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHeaderID.FieldName,
        FGiderKodu.FieldName,
        FMiktar.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TRctReceteIscilik.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHeaderID.FieldName,
        FGiderKodu.FieldName,
        FMiktar.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TRctReceteIscilik.Clone: TTable;
begin
  Result := TRctReceteIscilik.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TRctReceteYanUrun.Create(ADatabase: TDatabase; ARecete: TRctRecete);
begin
  TableName := 'rct_recete_yan_urun';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ARecete <> nil then
    Recete := ARecete;

  FStkStokKarti := TStkStokKarti.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.OlcuBirimi.FieldName, FSysOlcuBirimi.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TRctReceteYanUrun.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FSysOlcuBirimi);
  inherited;
end;

procedure TRctReceteYanUrun.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FHeaderID.QryName,
        FStokKodu.QryName,
        FMiktar.QryName,
        FFireOrani.QryName
      ], [
        ' WHERE 1=1 ' + AFilter
      ]);
      Open;
    end;
  end;
end;

procedure TRctReceteYanUrun.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FHeaderID.QryName,
        FStokKodu.QryName,
        FMiktar.QryName,
        FFireOrani.QryName,
        addField(FStkStokKarti.TableName, FStkStokKarti.StokAdi.FieldName, FStokAdi.FieldName),
        addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.FieldName),
        addField(FStkStokKarti.TableName, FStkStokKarti.AlisFiyat.FieldName, FFiyat.FieldName)
      ], [
        addJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
        addJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FStkStokKarti.TableName, FStkStokKarti.OlcuBirimiID.FieldName),
        ' WHERE 1=1 ' + AFilter
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

procedure TRctReceteYanUrun.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHeaderID.FieldName,
        FStokKodu.FieldName,
        FMiktar.FieldName,
        FFireOrani.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TRctReceteYanUrun.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHeaderID.FieldName,
        FStokKodu.FieldName,
        FMiktar.FieldName,
        FFireOrani.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TRctReceteYanUrun.Clone: TTable;
begin
  Result := TRctReceteYanUrun.Create(Database, Self.Recete);
  CloneClassContent(Self, Result);
end;

constructor TRctRecete.Create(ADatabase: TDatabase);
begin
  TableName := 'rct_recete';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  ReceteMaliyet.HammaddeCount := 0;
  ReceteMaliyet.IscilikCount := 0;
  ReceteMaliyet.YanUrunCount := 0;

  FReceteKodu := TFieldDB.Create('recete_kodu', ftWideString, '', Self, 'Reçete Kodu');
  FReceteAdi := TFieldDB.Create('recete_adi', ftWideString, '', Self, 'Reçete Adý');
  FOrnekUretimMiktari := TFieldDB.Create('ornek_uretim_miktari', ftFloat, 0, Self, 'Örnek Üretim Miktarý');
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self, 'Açýklama');
  FMaliyet := TFieldDB.Create('maliyet', ftBCD, 0, Self, 'Maliyet');
  FHammaddeMaliyet := TFieldDB.Create('hammadde_maliyet', ftBCD, 0, Self, 'Hammadde Maliyet');
  FIscilikMaliyet := TFieldDB.Create('iscilik_maliyet', ftBCD, 0, Self, 'Ýþçilik Maliyet');
  FYanUrunMaliyet := TFieldDB.Create('yan_urun_maliyet', ftBCD, 0, Self, 'Yan Ürün Maliyet');
end;

procedure TRctRecete.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      SQL.Clear;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FReceteKodu.QryName,
        FReceteAdi.QryName,
        FOrnekUretimMiktari.QryName,
        FAciklama.QryName,
        'spget_rct_toplam('           + Id.QryName + '::bigint) ' + FMaliyet.FieldName,
        'spget_rct_hammadde_maliyet(' + Id.QryName + '::bigint) ' + FHammaddeMaliyet.FieldName,
        'spget_rct_iscilik_maliyet('  + Id.QryName + '::bigint) ' + FIscilikMaliyet.FieldName,
        'spget_rct_yan_urun_maliyet(' + Id.QryName + '::bigint) ' + FYanUrunMaliyet.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
    end;
  end;
end;

procedure TRctRecete.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
      AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT; ';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Self.Id.QryName,
        FReceteKodu.QryName,
        FReceteAdi.QryName,
        FOrnekUretimMiktari.QryName,
        FAciklama.QryName,
        'spget_rct_toplam('           + Self.Id.QryName + '::bigint) ' + FMaliyet.FieldName,
        'spget_rct_hammadde_maliyet(' + Self.Id.QryName + '::bigint) ' + FHammaddeMaliyet.FieldName,
        'spget_rct_iscilik_maliyet('  + Self.Id.QryName + '::bigint) ' + FIscilikMaliyet.FieldName,
        'spget_rct_yan_urun_maliyet(' + Self.Id.QryName + '::bigint) ' + FYanUrunMaliyet.FieldName
      ], [
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

procedure TRctRecete.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FReceteKodu.FieldName,
        FReceteAdi.FieldName,
        FOrnekUretimMiktari.FieldName,
        FAciklama.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TRctRecete.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FReceteKodu.FieldName,
        FReceteAdi.FieldName,
        FOrnekUretimMiktari.FieldName,
        FAciklama.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

procedure TRctRecete.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if (TObject(ListDetay[n1]).ClassType = TRctReceteHammadde) and (ATable.ClassType = TRctReceteHammadde) then
    begin
      TRctReceteHammadde(ATable).Recete := Self;
      if TRctReceteHammadde(ListDetay[n1]).FStokKodu.AsString = TRctReceteHammadde(ATable).FStokKodu.AsString then
      begin
        TRctReceteHammadde(ListDetay[n1]).FMiktar.Value := TRctReceteHammadde(ListDetay[n1]).FMiktar.AsFloat + TRctReceteHammadde(ATable).Miktar.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TRctReceteIscilik) and (ATable.ClassType = TRctReceteIscilik) then
    begin
      TRctReceteIscilik(ATable).Recete := Self;
      if TRctReceteIscilik(ListDetay[n1]).FGiderKodu.AsString = TRctReceteIscilik(ATable).FGiderKodu.AsString then
      begin
        TRctReceteIscilik(ListDetay[n1]).FMiktar.Value := TRctReceteIscilik(ListDetay[n1]).FMiktar.AsFloat + TRctReceteIscilik(ATable).FMiktar.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun) and (ATable.ClassType = TRctReceteYanUrun) then
    begin
      TRctReceteYanUrun(ATable).Recete := Self;
      if TRctReceteYanUrun(ListDetay[n1]).FStokKodu.AsString = TRctReceteYanUrun(ATable).FStokKodu.AsString then
      begin
        TRctReceteYanUrun(ListDetay[n1]).FMiktar.Value := TRctReceteYanUrun(ListDetay[n1]).FMiktar.AsFloat + TRctReceteYanUrun(ATable).FMiktar.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end;
  end;

  if not LExistsSameCode then
    ListDetay.Add(ATable);

  if ALastItem then RefreshHeader;
end;

procedure TRctRecete.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TRctRecete.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TRctRecete.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable.Clone);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

procedure TRctRecete.RefreshHeader;
var
  n1: Integer;
begin
  ReceteMaliyet.MaliyetHam := 0;
  ReceteMaliyet.MaliyetIsc := 0;
  ReceteMaliyet.MaliyetYan := 0;
  ReceteMaliyet.HammaddeCount := 0;
  ReceteMaliyet.IscilikCount := 0;
  ReceteMaliyet.YanUrunCount := 0;

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TRctReceteHammadde then
    begin
      ReceteMaliyet.HammaddeCount := ReceteMaliyet.HammaddeCount + 1;
      ReceteMaliyet.MaliyetHam := ReceteMaliyet.MaliyetHam + TRctReceteHammadde(ListDetay[n1]).Fiyat.AsFloat * TRctReceteHammadde(ListDetay[n1]).Miktar.AsFloat
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteIscilik then
    begin
      ReceteMaliyet.IscilikCount := ReceteMaliyet.IscilikCount + 1;
      ReceteMaliyet.MaliyetIsc := ReceteMaliyet.MaliyetIsc + TRctReceteIscilik(ListDetay[n1]).Fiyat.AsFloat * TRctReceteIscilik(ListDetay[n1]).Miktar.AsFloat
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun then
    begin
      ReceteMaliyet.YanUrunCount := ReceteMaliyet.YanUrunCount + 1;
      ReceteMaliyet.MaliyetYan := ReceteMaliyet.MaliyetYan - TRctReceteYanUrun(ListDetay[n1]).Fiyat.AsFloat * TRctReceteYanUrun(ListDetay[n1]).Miktar.AsFloat
    end;
  end;
end;

procedure TRctRecete.BusinessDelete(APermissionControl: Boolean);
begin
  inherited;
  //
end;

procedure TRctRecete.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  n1, vID: Integer;
begin
  Self.Insert(vID, APermissionControl);
  Self.Id.Value := vID;
  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TRctReceteHammadde then
    begin
      TRctReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TRctReceteHammadde(ListDetay[n1]).Insert(vID, True);
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteIscilik then
    begin
      TRctReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TRctReceteIscilik(ListDetay[n1]).Insert(vID, True);
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun then
    begin
      TRctReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TRctReceteYanUrun(ListDetay[n1]).Insert(vID, True);
    end;
  end;
end;

procedure TRctRecete.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  ARecete: TRctRecete;
  LHam: TRctReceteHammadde;
  LIsc: TRctReceteIscilik;
  LYan: TRctReceteYanUrun;
  n2: Integer;
  n1: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    ARecete := TRctRecete(List[n1]);

    LHam := TRctReceteHammadde.Create(Database, ARecete);
    LIsc := TRctReceteIscilik.Create(Database, ARecete);
    LYan := TRctReceteYanUrun.Create(Database, ARecete);
    try
      LHam.SelectToList(' AND ' + LHam.HeaderID.QryName + '=' + ARecete.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LHam.List.Count - 1 do
        ARecete.AddDetay(TRctReceteHammadde(TRctReceteHammadde(LHam.List[n2]).Clone));

      LIsc.SelectToList(' AND ' + LIsc.HeaderID.QryName + '=' + ARecete.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LIsc.List.Count - 1 do
        ARecete.AddDetay(TRctReceteIscilik(TRctReceteIscilik(LIsc.List[n2]).Clone));

      LYan.SelectToList(' AND ' + LYan.HeaderID.QryName + '=' + ARecete.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LYan.List.Count - 1 do
        ARecete.AddDetay(TRctReceteYanUrun(TRctReceteYanUrun(LYan.List[n2]).Clone));

      RefreshHeader;
    finally
      FreeAndNil(LHam);
      FreeAndNil(LIsc);
      FreeAndNil(LYan);
    end;
  end;
end;

procedure TRctRecete.BusinessUpdate(APermissionControl: Boolean);
var
  n1, LID: Integer;
begin
  Update(APermissionControl);

  for n1 := 0 to ListSilinenDetay.Count - 1 do
    if TTable(ListSilinenDetay[n1]).Id.AsInteger > 0 then
      TTable(ListSilinenDetay[n1]).Delete(False);

  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TRctReceteHammadde then
      TRctReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger
    else if TObject(ListDetay[n1]).ClassType = TRctReceteIscilik then
      TRctReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger
    else if TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun then
      TRctReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;

    if TTable(ListDetay[n1]).Id.Value > 0 then
      TTable(ListDetay[n1]).Update(False)
    else
    begin
      TTable(ListDetay[n1]).Insert(LID, False);
      TTable(ListDetay[n1]).Id.Value := LID;
    end;
  end;
end;

function TRctRecete.Clone: TTable;
begin
  Result := TRctRecete.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
  TRctRecete(Result).RefreshHeader;
end;

end.
