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

const
  RH_MAL_KODU = 1;
  RH_MAL_ADI = 2;
  RH_MIKTAR = 3;
  RH_BIRIM = 4;
  RH_FIYAT = 5;
  RH_FIRE_ORANI = 6;

  RI_GIDER_KODU = 1;
  RI_GIDER_ADI = 2;
  RI_MIKTAR = 3;
  RI_BIRIM = 4;
  RI_FIYAT = 5;

  RY_MAL_KODU = 1;
  RY_MAL_ADI = 2;
  RY_MIKTAR = 3;
  RY_BIRIM = 4;
  RY_FIYAT = 5;
  RY_FIRE_ORANI = 6;

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
    FBirim: TSysOlcuBirimi;
    FRecete: TRctRecete;

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
    FBirim: TFieldDB;
    FFiyat: TFieldDB;
  published
    FIscilik: TRctIscilikGideri;
    FOlcuBirimi: TSysOlcuBirimi;

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
    Property Birim: TFieldDB read FBirim write FBirim;
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
    FBirim: TSysOlcuBirimi;

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
    destructor Destroy; override;
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
  FBirim := TSysOlcuBirimi.Create(ADatabase);
  FRecete := TRctRecete.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FReceteID := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FReceteKodu := TFieldDB.Create(FRecete.FReceteKodu.FieldName, FRecete.ReceteKodu.DataType, '', Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FBirim.OlcuBirimi.FieldName, FBirim.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TRctReceteHammadde.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FBirim);
  FreeAndNil(FRecete);
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FReceteID.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FFireOrani.FieldName
      ], [
        ' WHERE 1=1 ' + AFilter
      ]);
      Open;
      Active := True;
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FReceteID.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FFireOrani.FieldName,
        ' rct.' + FRecete.FReceteKodu.FieldName + ' ' + FReceteKodu.FieldName,
        ' stk.' + FStkStokKarti.StokAdi.FieldName + ' ' + FStokAdi.FieldName,
        ' brm.' + FBirim.OlcuBirimi.FieldName + ' ' + FOlcuBirimi.FieldName,
        ' stk.' + FStkStokKarti.AlisFiyat.FieldName + ' ' + FFiyat.FieldName
      ], [
        ' LEFT JOIN ' + FRecete.TableName + ' rct ON rct.id=' + IntToStr(FReceteID.Value),
        ' LEFT JOIN ' + FStkStokKarti.TableName + ' stk ON stk.' + FStkStokKarti.StokKodu.FieldName + '=' + TableName + '.' + Self.StokKodu.FieldName,
        ' LEFT JOIN ' + FBirim.TableName + ' brm ON brm.' + FBirim.Id.FieldName + '=' + FStkStokKarti.OlcuBirimiID.FieldName,
        ' WHERE 1=1 ' + AFilter
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
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
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
    Self.notify;
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

  FIscilik := TRctIscilikGideri.Create(ADatabase);
  FOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FGiderKodu := TFieldDB.Create('gider_kodu', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FGiderAdi := TFieldDB.Create(FIscilik.GiderAdi.FieldName, FIscilik.GiderAdi.DataType, '', Self, '');
  FBirim := TFieldDB.Create(FOlcuBirimi.OlcuBirimi.FieldName, FOlcuBirimi.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create(FIscilik.Fiyat.FieldName, FIscilik.Fiyat.DataType, 0, Self, '');
end;

destructor TRctReceteIscilik.Destroy;
begin
  FreeAndNil(FIscilik);
  FreeAndNil(FOlcuBirimi);
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FGiderKodu.FieldName,
        FIscilik.GiderAdi.FieldName + ' ' + FGiderAdi.FieldName,
        TableName + '.' + FMiktar.FieldName,
        FOlcuBirimi.OlcuBirimi.FieldName + ' ' + Self.FBirim.FieldName,
        FIscilik.Fiyat.FieldName + ' ' + FFiyat.FieldName
      ], [
        ' LEFT JOIN ' + FIscilik.TableName + ' ON ' + FIscilik.TableName + '.' + FIscilik.GiderKodu.FieldName + '=' + Self.TableName + '.' + Self.FGiderKodu.FieldName,
        ' LEFT JOIN ' + FOlcuBirimi.TableName + ' ON ' + FOlcuBirimi.TableName + '.' + FOlcuBirimi.Id.FieldName + '=' + FIscilik.TableName + '.' + FIscilik.OlcuBirimiID.FieldName,
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FGiderKodu.FieldName,
        FIscilik.GiderAdi.FieldName + ' ' + FGiderAdi.FieldName,
        TableName + '.' + FMiktar.FieldName,
        FOlcuBirimi.OlcuBirimi.FieldName + ' ' + Self.FBirim.FieldName,
        FIscilik.Fiyat.FieldName + ' ' + FFiyat.FieldName
      ], [
        ' LEFT JOIN ' + FIscilik.TableName + ' ON ' + FIscilik.TableName + '.' + FIscilik.GiderKodu.FieldName + '=' + Self.TableName + '.' + Self.FGiderKodu.FieldName,
        ' LEFT JOIN ' + FOlcuBirimi.TableName + ' ON ' + FOlcuBirimi.TableName + '.' + FOlcuBirimi.Id.FieldName + '=' + FIscilik.TableName + '.' + FIscilik.OlcuBirimiID.FieldName,
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
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
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
    Self.notify;
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
  FBirim := TSysOlcuBirimi.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FBirim.OlcuBirimi.FieldName, FBirim.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TRctReceteYanUrun.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FBirim);
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FFireOrani.FieldName
      ], [
        ' WHERE 1=1 ' + AFilter
      ]);
      Open;
      Active := True;
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHeaderID.FieldName,
        TableName + '.' + FStokKodu.FieldName,
        TableName + '.' + FMiktar.FieldName,
        TableName + '.' + FFireOrani.FieldName,
        ' stk.' + FStkStokKarti.StokAdi.FieldName + ' ' + FStokAdi.FieldName,
        ' brm.' + FBirim.OlcuBirimi.FieldName + ' ' + FOlcuBirimi.FieldName,
        ' stk.' + FStkStokKarti.AlisFiyat.FieldName + ' ' + FFiyat.FieldName
      ], [
        ' LEFT JOIN ' + FStkStokKarti.TableName + ' stk ON stk.' + FStkStokKarti.StokKodu.FieldName + '=' + TableName + '.' + Self.StokKodu.FieldName,
        ' LEFT JOIN ' + FBirim.TableName + ' brm ON brm.' + FBirim.Id.FieldName + '=' + FStkStokKarti.OlcuBirimiID.FieldName,
        ' WHERE 1=1 ' + AFilter
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
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
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
    Self.notify;
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

  FReceteKodu := TFieldDB.Create('recete_kodu', ftString, '', Self, 'Reçete Kodu');
  FReceteAdi := TFieldDB.Create('recete_adi', ftString, '', Self, 'Reçete Adý');
  FOrnekUretimMiktari := TFieldDB.Create('ornek_uretim_miktari', ftFloat, 0, Self, 'Örnek Üretim Miktarý');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
  FMaliyet := TFieldDB.Create('maliyet', ftBCD, 0, Self, 'Maliyet');
  FHammaddeMaliyet := TFieldDB.Create('hammadde_maliyet', ftBCD, 0, Self, 'Hammadde Maliyet');
  FIscilikMaliyet := TFieldDB.Create('iscilik_maliyet', ftBCD, 0, Self, 'Ýþçilik Maliyet');
  FYanUrunMaliyet := TFieldDB.Create('yan_urun_maliyet', ftBCD, 0, Self, 'Yan Ürün Maliyet');
end;

destructor TRctRecete.Destroy;
begin
  inherited;
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
      Active := True;
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

        List.Add(Self.Clone);

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
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
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
    Self.notify;
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
      if TRctReceteHammadde(ListDetay[n1]).FStokKodu.Value = TRctReceteHammadde(ATable).FStokKodu.Value then
      begin
        TRctReceteHammadde(ListDetay[n1]).FMiktar.Value := TRctReceteHammadde(ListDetay[n1]).FMiktar.Value + TRctReceteHammadde(ATable).Miktar.Value;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TRctReceteIscilik) and (ATable.ClassType = TRctReceteIscilik) then
    begin
      TRctReceteIscilik(ATable).Recete := Self;
      if TRctReceteIscilik(ListDetay[n1]).FGiderKodu.Value = TRctReceteIscilik(ATable).FGiderKodu.Value then
      begin
        TRctReceteIscilik(ListDetay[n1]).FMiktar.Value := TRctReceteIscilik(ListDetay[n1]).FMiktar.Value + TRctReceteIscilik(ATable).FMiktar.Value;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun) and (ATable.ClassType = TRctReceteYanUrun) then
    begin
      TRctReceteYanUrun(ATable).Recete := Self;
      if TRctReceteYanUrun(ListDetay[n1]).FStokKodu.Value = TRctReceteYanUrun(ATable).FStokKodu.Value then
      begin
        TRctReceteYanUrun(ListDetay[n1]).FMiktar.Value := TRctReceteYanUrun(ListDetay[n1]).FMiktar.Value + TRctReceteYanUrun(ATable).FMiktar.Value;
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

procedure TRctRecete.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable.Clone);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

function TRctRecete.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
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
      ReceteMaliyet.MaliyetHam := ReceteMaliyet.MaliyetHam + FormatedVariantVal(TRctReceteHammadde(ListDetay[n1]).Fiyat) * FormatedVariantVal(TRctReceteHammadde(ListDetay[n1]).Miktar)
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteIscilik then
    begin
      ReceteMaliyet.IscilikCount := ReceteMaliyet.IscilikCount + 1;
      ReceteMaliyet.MaliyetIsc := ReceteMaliyet.MaliyetIsc + FormatedVariantVal(TRctReceteIscilik(ListDetay[n1]).Fiyat) * FormatedVariantVal(TRctReceteIscilik(ListDetay[n1]).Miktar)
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun then
    begin
      ReceteMaliyet.YanUrunCount := ReceteMaliyet.YanUrunCount + 1;
      ReceteMaliyet.MaliyetYan := ReceteMaliyet.MaliyetYan - FormatedVariantVal(TRctReceteYanUrun(ListDetay[n1]).Fiyat) * FormatedVariantVal(TRctReceteYanUrun(ListDetay[n1]).Miktar)
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
      TRctReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.Value;
      TRctReceteHammadde(ListDetay[n1]).Insert(vID, True);
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteIscilik then
    begin
      TRctReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.Value;
      TRctReceteIscilik(ListDetay[n1]).Insert(vID, True);
    end
    else if TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun then
    begin
      TRctReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.Value;
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

  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TRctReceteHammadde then
      TRctReceteHammadde(ListDetay[n1]).HeaderID.Value := Self.Id.Value
    else if TObject(ListDetay[n1]).ClassType = TRctReceteIscilik then
      TRctReceteIscilik(ListDetay[n1]).HeaderID.Value := Self.Id.Value
    else if TObject(ListDetay[n1]).ClassType = TRctReceteYanUrun then
      TRctReceteYanUrun(ListDetay[n1]).HeaderID.Value := Self.Id.Value;

    if TTable(ListDetay[n1]).Id.Value > 0 then
      TTable(ListDetay[n1]).Update(False)
    else
    begin
      TTable(ListDetay[n1]).Insert(LID, False);
      TTable(ListDetay[n1]).Id.Value := LID;
    end;
  end;

  for n1 := 0 to ListSilinenDetay.Count - 1 do
    if TTable(ListSilinenDetay[n1]).Id.Value > 0 then
      TTable(ListSilinenDetay[n1]).Delete(False);
end;

function TRctRecete.Clone: TTable;
begin
  Result := TRctRecete.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
  TRctRecete(Result).RefreshHeader;
end;

end.
