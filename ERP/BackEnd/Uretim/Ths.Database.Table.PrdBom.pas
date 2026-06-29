unit Ths.Database.Table.PrdBom;

interface

{$I Ths.inc}

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  System.Generics.Collections,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.TableDetailed,
  Ths.Database.Table.StkKartlar,
  Ths.Database.Table.SysOlcuBirimleri,
  Ths.Database.Table.PrdLabour;

type
  TUrtBom = class;

  TBomTotals = record
    CostRaw: Double;
    CostLab: Double;
    CostBy: Double;
    RawCount: SmallInt;
    LabCount: SmallInt;
    ByProductCount: SmallInt;
  end;

  TUrtBomRawMat = class(TTable)
  private
    FHeaderId: TFieldDB;
    FRecipeId: TFieldDB;
    FStockCode: TFieldDB;
    FQuantity: TFieldDB;
    FScrapRatio: TFieldDB;
    //not a database field
    FRecipeCode: TFieldDB;
    FStockName: TFieldDB;
    FUoM: TFieldDB;
    FPrice: TFieldDB;
  published
    FStkKart: TStkKart;
    FSysUom: TSysOlcuBirimi;
    FUrtBomRec: TUrtBom;

    constructor Create(ADatabase: TDatabase; ABom: TUrtBom = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Bom: TUrtBom;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderId: TFieldDB read FHeaderId write FHeaderId;
    Property RecipeId: TFieldDB read FRecipeId write FRecipeId;
    Property StockCode: TFieldDB read FStockCode write FStockCode;
    Property Quantity: TFieldDB read FQuantity write FQuantity;
    Property ScrapRatio: TFieldDB read FScrapRatio write FScrapRatio;
    //not a database field
    Property RecipeCode: TFieldDB read FRecipeCode write FRecipeCode;
    Property StockName: TFieldDB read FStockName write FStockName;
    Property UoM: TFieldDB read FUoM write FUoM;
    Property Price: TFieldDB read FPrice write FPrice;
  end;

  TUrtBomLabour = class(TTable)
  private
    FHeaderId: TFieldDB;
    FLabourCode: TFieldDB;
    FQuantity: TFieldDB;
    //not a database field
    FExpenseName: TFieldDB;
    FUoM: TFieldDB;
    FPrice: TFieldDB;
  published
    FPrdLabour: TPrdLabour;
    FSysUom: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ABom: TUrtBom = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Bom: TUrtBom;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderId: TFieldDB read FHeaderId write FHeaderId;
    Property LabourCode: TFieldDB read FLabourCode write FLabourCode;
    Property Quantity: TFieldDB read FQuantity write FQuantity;
    //not a database field
    Property ExpenseName: TFieldDB read FExpenseName write FExpenseName;
    Property UoM: TFieldDB read FUoM write FUoM;
    Property Price: TFieldDB read FPrice write FPrice;
  end;

  TUrtBomByProduct = class(TTable)
  private
    FHeaderId: TFieldDB;
    FProductCode: TFieldDB;
    FQuantity: TFieldDB;
    //not a database field
    FStockName: TFieldDB;
    FUoM: TFieldDB;
    FPrice: TFieldDB;
  published
    FStkKart: TStkKart;
    FSysUom: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ABom: TUrtBom = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Bom: TUrtBom;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderId: TFieldDB read FHeaderId write FHeaderId;
    Property ProductCode: TFieldDB read FProductCode write FProductCode;
    Property Quantity: TFieldDB read FQuantity write FQuantity;
    //not a database field
    Property StockName: TFieldDB read FStockName write FStockName;
    Property UoM: TFieldDB read FUoM write FUoM;
    Property Price: TFieldDB read FPrice write FPrice;
  end;

  TUrtBomPktRaw = class(TTable)
  private
    FHeaderId: TFieldDB;
    FPackageId: TFieldDB;
    FQuantity: TFieldDB;
  published
    FStkKart: TStkKart;
    FSysUom: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ABom: TUrtBom = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Bom: TUrtBom;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderId: TFieldDB read FHeaderId write FHeaderId;
    Property PackageId: TFieldDB read FPackageId write FPackageId;
    Property Quantity: TFieldDB read FQuantity write FQuantity;
  end;

  TUrtBomPktLabour = class(TTable)
  private
    FHeaderId: TFieldDB;
    FPackageId: TFieldDB;
    FQuantity: TFieldDB;
  published
    FStkKart: TStkKart;
    FSysUom: TSysOlcuBirimi;

    constructor Create(ADatabase: TDatabase; ABom: TUrtBom = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    Bom: TUrtBom;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property HeaderId: TFieldDB read FHeaderId write FHeaderId;
    Property PackageId: TFieldDB read FPackageId write FPackageId;
    Property Quantity: TFieldDB read FQuantity write FQuantity;
  end;

  TUrtBom = class(TTableDetailed)
  private
    FProductCode: TFieldDB;
    FProductName: TFieldDB;
    FSampleQty: TFieldDB;
    FDescription: TFieldDB;
    FCostTotal: TFieldDB;
    FCostRaw: TFieldDB;
    FCostLabour: TFieldDB;
    FCostByProduct: TFieldDB;
  protected
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;

    procedure RefreshHeader; override;
    function ValidateDetay(ATable: TTable): Boolean; override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    BomCosts: TBomTotals;

    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property ProductCode: TFieldDB read FProductCode write FProductCode;
    Property ProductName: TFieldDB read FProductName write FProductName;
    Property SampleQty: TFieldDB read FSampleQty write FSampleQty;
    Property Description: TFieldDB read FDescription write FDescription;
    property CostTotal: TFieldDB read FCostTotal write FCostTotal;
    property CostRaw: TFieldDB read FCostRaw write FCostRaw;
    property CostLabour: TFieldDB read FCostLabour write FCostLabour;
    property CostByProduct: TFieldDB read FCostByProduct write FCostByProduct;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TUrtBomRawMat.Create(ADatabase: TDatabase; ABom: TUrtBom);
begin
  TableName := 'prd_bom_raw';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ABom <> nil then
    Bom := ABom;

  FStkKart := TStkKart.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);
  FUrtBomRec := TUrtBom.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FRecipeId := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStockCode := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FScrapRatio := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FRecipeCode := TFieldDB.Create(FUrtBomRec.ProductCode.FieldName, FUrtBomRec.ProductCode.DataType, '', Self, '');
  FStockName := TFieldDB.Create(FStkKart.StokAdi.FieldName, FStkKart.StokAdi.DataType, '', Self, '');
  FUoM := TFieldDB.Create(FSysUom.Birim.FieldName, FSysUom.Birim.DataType, '', Self, '');
  FPrice := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TUrtBomRawMat.Destroy;
begin
  FreeAndNil(FStkKart);
  FreeAndNil(FSysUom);
  FreeAndNil(FUrtBomRec);
  inherited;
end;

function TUrtBomRawMat.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderId.QryName,
      FRecipeId.QryName,
      FStockCode.QryName,
      FQuantity.QryName,
      FScrapRatio.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomRawMat.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.QryName,
      FHeaderId.QryName,
      FRecipeId.QryName,
      FStockCode.QryName,
      FQuantity.QryName,
      FScrapRatio.QryName,
      addField(FUrtBomRec.TableName, FUrtBomRec.ProductCode.FieldName, FRecipeCode.FieldName),
      addField(FStkKart.TableName, FStkKart.StokAdi.FieldName, FStockName.FieldName),
      addField(FSysUom.TableName, FSysUom.Birim.FieldName, FUoM.FieldName),
      addField(FStkKart.TableName, FStkKart.AlisFiyat.FieldName, FPrice.FieldName)
    ], [
      AddJoin(jtLeft, FUrtBomRec.TableName, FUrtBomRec.Id.FieldName, TableName, RecipeId.FieldName),
      AddJoin(jtLeft, FStkKart.TableName, FStkKart.StokKodu.FieldName, TableName, FStockCode.FieldName),
      AddJoin(jtLeft, FSysUom.TableName, FSysUom.Id.FieldName, FStkKart.TableName, FStkKart.OlcuBirimiID.FieldName),
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtBomRawMat.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FRecipeId.FieldName,
      FStockCode.FieldName,
      FQuantity.FieldName,
      FScrapRatio.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomRawMat.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FRecipeId.FieldName,
      FStockCode.FieldName,
      FQuantity.FieldName,
      FScrapRatio.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtBomRawMat.Clone: TTable;
begin
  Result := TUrtBomRawMat.Create(Database, Self.Bom);
  CloneClassContent(Self, Result);
end;

constructor TUrtBomLabour.Create(ADatabase: TDatabase; ABom: TUrtBom);
begin
  TableName := 'prd_bom_labour';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ABom <> nil then
    Bom := ABom;

  FPrdLabour := TPrdLabour.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FLabourCode := TFieldDB.Create('iscilik_kodu', ftWideString, '', Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FExpenseName := TFieldDB.Create(FPrdLabour.ExpenseCode.FieldName, FPrdLabour.ExpenseCode.DataType, '', Self, 'Gider Kodu');
  FUoM := TFieldDB.Create(FSysUom.Birim.FieldName, FSysUom.Birim.DataType, '', Self, 'Birim');
  FPrice := TFieldDB.Create(FPrdLabour.Price.FieldName, FPrdLabour.Price.DataType, 0, Self, 'Fiyat');
end;

destructor TUrtBomLabour.Destroy;
begin
  FreeAndNil(FPrdLabour);
  FreeAndNil(FSysUom);
  inherited;
end;

function TUrtBomLabour.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderId.QryName,
      FLabourCode.QryName,
      addField(FPrdLabour.TableName, FPrdLabour.ExpenseCode.FieldName, FExpenseName.FieldName),
      FQuantity.QryName,
      addField(FSysUom.TableName, FSysUom.Birim.FieldName, FUoM.FieldName),
      addField(FPrdLabour.TableName, FPrdLabour.Price.FieldName, FPrice.FieldName)
    ], [
      addJoin(jtLeft, FPrdLabour.TableName, FPrdLabour.ExpenseCode.FieldName, TableName, FLabourCode.FieldName),
      addJoin(jtLeft, FSysUom.TableName, FSysUom.Id.FieldName, FPrdLabour.TableName, FPrdLabour.UnitId.FieldName),
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomLabour.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.QryName,
      FHeaderId.QryName,
      FLabourCode.QryName,
      addField(FPrdLabour.TableName, FPrdLabour.ExpenseCode.FieldName, FExpenseName.FieldName),
      FQuantity.QryName,
      addField(FSysUom.TableName, FSysUom.Birim.FieldName, FUoM.FieldName),
      addField(FPrdLabour.TableName, FPrdLabour.Price.FieldName, FPrice.FieldName)
    ], [
      addJoin(jtLeft, FPrdLabour.TableName, FPrdLabour.ExpenseCode.FieldName, TableName, FLabourCode.FieldName),
      addJoin(jtLeft, FSysUom.TableName, FSysUom.Id.FieldName, FPrdLabour.TableName, FPrdLabour.UnitId.FieldName),
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

procedure TUrtBomLabour.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FLabourCode.FieldName,
      FQuantity.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomLabour.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FLabourCode.FieldName,
      FQuantity.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtBomLabour.Clone: TTable;
begin
  Result := TUrtBomLabour.Create(Database, Self.Bom);
  CloneClassContent(Self, Result);
end;

constructor TUrtBomByProduct.Create(ADatabase: TDatabase; ABom: TUrtBom);
begin
  TableName := 'prd_bom_by_product';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ABom <> nil then
    Bom := ABom;

  FStkKart := TStkKart.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FProductCode := TFieldDB.Create('urun_kodu', ftWideString, '', Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FStockName := TFieldDB.Create(FStkKart.StokAdi.FieldName, FStkKart.StokAdi.DataType, '', Self, '');
  FUoM := TFieldDB.Create(FSysUom.Birim.FieldName, FSysUom.Birim.DataType, '', Self, '');
  FPrice := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TUrtBomByProduct.Destroy;
begin
  FreeAndNil(FStkKart);
  FreeAndNil(FSysUom);
  inherited;
end;

function TUrtBomByProduct.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderId.QryName,
      FProductCode.QryName,
      FQuantity.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomByProduct.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.QryName,
      FHeaderId.QryName,
      FProductCode.QryName,
      FQuantity.QryName,
      addField(FStkKart.TableName, FStkKart.StokAdi.FieldName, FStockName.FieldName),
      addField(FSysUom.TableName, FSysUom.Birim.FieldName, FUoM.FieldName),
      addField(FStkKart.TableName, FStkKart.AlisFiyat.FieldName, FPrice.FieldName)
    ], [
      addJoin(jtLeft, FStkKart.TableName, FStkKart.StokKodu.FieldName, TableName, FProductCode.FieldName),
      addJoin(jtLeft, FSysUom.TableName, FSysUom.Id.FieldName, FStkKart.TableName, FStkKart.OlcuBirimiID.FieldName),
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtBomByProduct.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FProductCode.FieldName,
      FQuantity.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomByProduct.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FProductCode.FieldName,
      FQuantity.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtBomByProduct.Clone: TTable;
begin
  Result := TUrtBomByProduct.Create(Database, Self.Bom);
  CloneClassContent(Self, Result);
end;

constructor TUrtBomPktRaw.Create(ADatabase: TDatabase; ABom: TUrtBom);
begin
  TableName := 'prd_bom_packet_raw';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ABom <> nil then
    Bom := ABom;

  FStkKart := TStkKart.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FPackageId := TFieldDB.Create('paket_id', ftInteger, 0, Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
end;

destructor TUrtBomPktRaw.Destroy;
begin
  FreeAndNil(FStkKart);
  FreeAndNil(FSysUom);
  inherited;
end;

function TUrtBomPktRaw.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderId.QryName,
      FPackageId.QryName,
      FQuantity.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomPktRaw.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.QryName,
      FHeaderId.QryName,
      FPackageId.QryName,
      FQuantity.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtBomPktRaw.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FPackageId.FieldName,
      FQuantity.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomPktRaw.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FPackageId.FieldName,
      FQuantity.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtBomPktRaw.Clone: TTable;
begin
  Result := TUrtBomPktRaw.Create(Database, Self.Bom);
  CloneClassContent(Self, Result);
end;

constructor TUrtBomPktLabour.Create(ADatabase: TDatabase; ABom: TUrtBom);
begin
  TableName := 'prd_bom_packet_labour';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  if ABom <> nil then
    Bom := ABom;

  FStkKart := TStkKart.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FPackageId := TFieldDB.Create('paket_id', ftInteger, 0, Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
end;

destructor TUrtBomPktLabour.Destroy;
begin
  FreeAndNil(FStkKart);
  FreeAndNil(FSysUom);
  inherited;
end;

function TUrtBomPktLabour.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderId.QryName,
      FPackageId.QryName,
      FQuantity.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomPktLabour.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Id.QryName,
      FHeaderId.QryName,
      FPackageId.QryName,
      FQuantity.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
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

procedure TUrtBomPktLabour.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FPackageId.FieldName,
      FQuantity.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBomPktLabour.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FHeaderId.FieldName,
      FPackageId.FieldName,
      FQuantity.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TUrtBomPktLabour.Clone: TTable;
begin
  Result := TUrtBomPktLabour.Create(Database, Self.Bom);
  CloneClassContent(Self, Result);
end;

constructor TUrtBom.Create(ADatabase: TDatabase);
begin
  TableName := 'prd_bom';
  TableSourceCode := MODULE_RCT_RECETE_KAYIT;
  inherited Create(ADatabase);

  BomCosts.RawCount := 0;
  BomCosts.LabCount := 0;
  BomCosts.ByProductCount := 0;

  FProductCode := TFieldDB.Create('urun_kodu', ftWideString, '', Self);
  FProductName := TFieldDB.Create('urun_adi', ftWideString, '', Self);
  FSampleQty := TFieldDB.Create('ornek_miktari', ftFloat, 0, Self);
  FDescription := TFieldDB.Create('aciklama', ftWideString, '', Self);
  FCostTotal := TFieldDB.Create('maliyet', ftBCD, 0, Self);
  FCostRaw := TFieldDB.Create('hammadde_maliyet', ftBCD, 0, Self);
  FCostLabour := TFieldDB.Create('iscilik_maliyet', ftBCD, 0, Self);
  FCostByProduct := TFieldDB.Create('yan_urun_maliyet', ftBCD, 0, Self);
end;

function TUrtBom.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FProductCode.QryName,
      FProductName.QryName,
      FSampleQty.QryName,
      FDescription.QryName,
      'spget_rct_toplam(cast('           + Id.QryName + ' as bigint)) ' + FCostTotal.FieldName,
      'spget_rct_hammadde_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FCostRaw.FieldName,
      'spget_rct_iscilik_maliyet(cast('  + Id.QryName + ' as bigint)) ' + FCostLabour.FieldName,
      'spget_rct_yan_urun_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FCostByProduct.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBom.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FProductCode.QryName,
      FProductName.QryName,
      FSampleQty.QryName,
      FDescription.QryName,
      'spget_rct_toplam(cast('           + Id.QryName + ' as bigint)) ' + FCostTotal.FieldName,
      'spget_rct_hammadde_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FCostRaw.FieldName,
      'spget_rct_iscilik_maliyet(cast('  + Id.QryName + ' as bigint)) ' + FCostLabour.FieldName,
      'spget_rct_yan_urun_maliyet(cast(' + Id.QryName + ' as bigint)) ' + FCostByProduct.FieldName
    ], [
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

procedure TUrtBom.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FProductCode.FieldName,
      FProductName.FieldName,
      FSampleQty.FieldName,
      FDescription.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBom.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FProductCode.FieldName,
      FProductName.FieldName,
      FSampleQty.FieldName,
      FDescription.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TUrtBom.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if (TObject(ListDetay[n1]).ClassType = TUrtBomRawMat) and (ATable.ClassType = TUrtBomRawMat) then
    begin
      TUrtBomRawMat(ATable).Bom := Self;
      if TUrtBomRawMat(ListDetay[n1]).FStockCode.AsString = TUrtBomRawMat(ATable).FStockCode.AsString then
      begin
        TUrtBomRawMat(ListDetay[n1]).FQuantity.Value := TUrtBomRawMat(ListDetay[n1]).FQuantity.AsFloat + TUrtBomRawMat(ATable).FQuantity.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TUrtBomLabour) and (ATable.ClassType = TUrtBomLabour) then
    begin
      TUrtBomLabour(ATable).Bom := Self;
      if TUrtBomLabour(ListDetay[n1]).FLabourCode.AsString = TUrtBomLabour(ATable).FLabourCode.AsString then
      begin
        TUrtBomLabour(ListDetay[n1]).FQuantity.Value := TUrtBomLabour(ListDetay[n1]).FQuantity.AsFloat + TUrtBomLabour(ATable).FQuantity.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end
    else if (TObject(ListDetay[n1]).ClassType = TUrtBomByProduct) and (ATable.ClassType = TUrtBomByProduct) then
    begin
      TUrtBomByProduct(ATable).Bom := Self;
      if TUrtBomByProduct(ListDetay[n1]).FProductCode.AsString = TUrtBomByProduct(ATable).FProductCode.AsString then
      begin
        TUrtBomByProduct(ListDetay[n1]).FQuantity.Value := TUrtBomByProduct(ListDetay[n1]).FQuantity.AsFloat + TUrtBomByProduct(ATable).FQuantity.AsFloat;
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

procedure TUrtBom.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

function TUrtBom.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TUrtBom.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable.Clone);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

procedure TUrtBom.RefreshHeader;
var
  n1: Integer;
begin
  BomCosts.CostRaw := 0;
  BomCosts.CostLab := 0;
  BomCosts.CostBy := 0;
  BomCosts.RawCount := 0;
  BomCosts.LabCount := 0;
  BomCosts.ByProductCount := 0;

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtBomRawMat then
    begin
      BomCosts.RawCount := BomCosts.RawCount + 1;
      BomCosts.CostRaw := BomCosts.CostRaw + TUrtBomRawMat(ListDetay[n1]).FPrice.AsFloat * TUrtBomRawMat(ListDetay[n1]).FQuantity.AsFloat
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtBomLabour then
    begin
      BomCosts.LabCount := BomCosts.LabCount + 1;
      BomCosts.CostLab := BomCosts.CostLab + TUrtBomLabour(ListDetay[n1]).FPrice.AsFloat * TUrtBomLabour(ListDetay[n1]).FQuantity.AsFloat
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtBomByProduct then
    begin
      BomCosts.ByProductCount := BomCosts.ByProductCount + 1;
      BomCosts.CostBy := BomCosts.CostBy - TUrtBomByProduct(ListDetay[n1]).FPrice.AsFloat * TUrtBomByProduct(ListDetay[n1]).FQuantity.AsFloat
    end;
  end;
end;

procedure TUrtBom.BusinessDelete(APermissionControl: Boolean);
begin
  inherited;
  //
end;

procedure TUrtBom.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(APermissionControl);
  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtBomRawMat then
    begin
      TUrtBomRawMat(ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      TUrtBomRawMat(ListDetay[n1]).Insert(True);
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtBomLabour then
    begin
      TUrtBomLabour(ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      TUrtBomLabour(ListDetay[n1]).Insert(True);
    end
    else if TObject(ListDetay[n1]).ClassType = TUrtBomByProduct then
    begin
      TUrtBomByProduct(ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      TUrtBomByProduct(ListDetay[n1]).Insert(True);
    end;
  end;
end;

procedure TUrtBom.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  ABom: TUrtBom;
  LHam: TUrtBomRawMat;
  LIsc: TUrtBomLabour;
  LYan: TUrtBomByProduct;
  n2: Integer;
  n1: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    ABom := TUrtBom(List[n1]);

    LHam := TUrtBomRawMat.Create(Database, ABom);
    LIsc := TUrtBomLabour.Create(Database, ABom);
    LYan := TUrtBomByProduct.Create(Database, ABom);
    try
      LHam.SelectToList(' AND ' + LHam.HeaderId.QryName + '=' + ABom.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LHam.List.Count - 1 do
        ABom.AddDetay(TUrtBomRawMat(TUrtBomRawMat(LHam.List[n2]).Clone));

      LIsc.SelectToList(' AND ' + LIsc.HeaderId.QryName + '=' + ABom.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LIsc.List.Count - 1 do
        ABom.AddDetay(TUrtBomLabour(TUrtBomLabour(LIsc.List[n2]).Clone));

      LYan.SelectToList(' AND ' + LYan.HeaderId.QryName + '=' + ABom.Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LYan.List.Count - 1 do
        ABom.AddDetay(TUrtBomByProduct(TUrtBomByProduct(LYan.List[n2]).Clone));

      RefreshHeader;
    finally
      FreeAndNil(LHam);
      FreeAndNil(LIsc);
      FreeAndNil(LYan);
    end;
  end;
end;

procedure TUrtBom.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Update(APermissionControl);

  for n1 := 0 to ListSilinenDetay.Count - 1 do
    if TTable(ListSilinenDetay[n1]).Id.AsInteger > 0 then
      TTable(ListSilinenDetay[n1]).Delete(False);

  for n1 := 0 to ListDetay.Count - 1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtBomRawMat then
      TUrtBomRawMat(ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger
    else if TObject(ListDetay[n1]).ClassType = TUrtBomLabour then
      TUrtBomLabour(ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger
    else if TObject(ListDetay[n1]).ClassType = TUrtBomByProduct then
      TUrtBomByProduct(ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;

    if TTable(ListDetay[n1]).Id.Value > 0 then
      TTable(ListDetay[n1]).Update(False)
    else
    begin
      TTable(ListDetay[n1]).Insert(False);
    end;
  end;
end;

function TUrtBom.Clone: TTable;
begin
  Result := TUrtBom.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
  TUrtBom(Result).RefreshHeader;
end;

end.
