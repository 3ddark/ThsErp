unit Ths.Database.Table.PrdPktRawMats;

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
  TPrdPktRawMat = class;

  TPrdPktRawMatDetail = class(TTable)
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
    FBomRec: TUrtBom;

    constructor Create(ADatabase: TDatabase; APkt: TPrdPktRawMat = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    PktRawMat: TPrdPktRawMat;

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

  TPrdPktRawMat = class(TTableDetailed)
  private
    FPackageName: TFieldDB;
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
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property PackageName: TFieldDB read FPackageName write FPackageName;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.PrdBom;

constructor TPrdPktRawMatDetail.Create(ADatabase: TDatabase; APkt: TPrdPktRawMat);
begin
  TableName := 'prd_paket_hammadde_detaylari';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  if APkt <> nil then
    PktRawMat := APkt;

  FStkKart := TStkKart.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);
  FBomRec := TUrtBom.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FRecipeId := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStockCode := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FScrapRatio := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FRecipeCode := TFieldDB.Create(FBomRec.ProductCode.FieldName, FBomRec.ProductCode.DataType, '', Self, '');
  FStockName := TFieldDB.Create(FStkKart.StokAdi.FieldName, FStkKart.StokAdi.DataType, '', Self, '');
  FUoM := TFieldDB.Create(FSysUom.Birim.FieldName, FSysUom.Birim.DataType, '', Self, '');
  FPrice := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TPrdPktRawMatDetail.Destroy;
begin
  FreeAndNil(FStkKart);
  FreeAndNil(FSysUom);
  FreeAndNil(FBomRec);
  inherited;
end;

function TPrdPktRawMatDetail.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
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

procedure TPrdPktRawMatDetail.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      addField(FBomRec.TableName, FBomRec.ProductCode.FieldName, FRecipeCode.FieldName),
      addField(FStkKart.TableName, FStkKart.StokAdi.FieldName, FStockName.FieldName),
      addField(FSysUom.TableName, FSysUom.Birim.FieldName, FUoM.FieldName),
      addField(FStkKart.TableName, FStkKart.AlisFiyat.FieldName, FPrice.FieldName)
    ], [
      AddJoin(jtLeft, FBomRec.TableName, FBomRec.Id.FieldName, TableName, FRecipeId.FieldName),
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

procedure TPrdPktRawMatDetail.DoInsert(APermissionControl: Boolean);
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

procedure TPrdPktRawMatDetail.DoUpdate(APermissionControl: Boolean);
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

function TPrdPktRawMatDetail.Clone: TTable;
begin
  Result := TPrdPktRawMatDetail.Create(Database, Self.PktRawMat);
  CloneClassContent(Self, Result);
end;

constructor TPrdPktRawMat.Create(ADatabase: TDatabase);
begin
  TableName := 'prd_paket_hammaddeler';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FPackageName := TFieldDB.Create('paket_adi', ftWideString, '', Self);
end;

function TPrdPktRawMat.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FPackageName.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TPrdPktRawMat.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FPackageName.QryName
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

procedure TPrdPktRawMat.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FPackageName.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TPrdPktRawMat.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FPackageName.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TPrdPktRawMat.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  TPrdPktRawMatDetail(ATable).PktRawMat := Self;
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TPrdPktRawMatDetail then
    begin
      if TPrdPktRawMatDetail(ListDetay[n1]).FStockCode.AsString = TPrdPktRawMatDetail(ATable).FStockCode.AsString then
      begin
        TPrdPktRawMatDetail(ListDetay[n1]).FQuantity.Value := TPrdPktRawMatDetail(ListDetay[n1]).FQuantity.AsFloat + TPrdPktRawMatDetail(ATable).FQuantity.AsFloat;
        LExistsSameCode := True;
        FreeAndNil(ATable);
        Break;
      end;
    end;
  end;

  if not LExistsSameCode then
    Self.ListDetay.Add(ATable);

  if ALastItem then RefreshHeader;
end;

procedure TPrdPktRawMat.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

procedure TPrdPktRawMat.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

function TPrdPktRawMat.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TPrdPktRawMat.RefreshHeader;
begin
  //
end;

procedure TPrdPktRawMat.BusinessDelete(APermissionControl: Boolean);
begin
  //
end;

procedure TPrdPktRawMat.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(APermissionControl);
  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TPrdPktRawMatDetail then
    begin
      TPrdPktRawMatDetail(Self.ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      TPrdPktRawMatDetail(Self.ListDetay[n1]).Insert(APermissionControl);
    end
  end;
end;

procedure TPrdPktRawMat.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  LDty: TPrdPktRawMatDetail;
  n1, n2: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    LDty := TPrdPktRawMatDetail.Create(Database);
    try
      LDty.SelectToList(' AND ' + LDty.HeaderId.QryName + '=' + TPrdPktRawMat(Self.List[n1]).Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LDty.List.Count - 1 do
        TPrdPktRawMat(Self.List[n1]).AddDetay(TPrdPktRawMatDetail(TPrdPktRawMatDetail(LDty.List[n2]).Clone));
    finally
      FreeAndNil(LDty);
    end;
  end;
end;

procedure TPrdPktRawMat.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TPrdPktRawMatDetail then
    begin
      TPrdPktRawMatDetail(Self.ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      if TPrdPktRawMatDetail(Self.ListDetay[n1]).Id.AsInteger > 0 then
        TPrdPktRawMatDetail(Self.ListDetay[n1]).Update(APermissionControl)
      else
        TPrdPktRawMatDetail(Self.ListDetay[n1]).Insert(APermissionControl)
    end
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count - 1 do
    if TTable(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TTable(Self.ListSilinenDetay[n1]).Delete(APermissionControl);
end;

function TPrdPktRawMat.Clone: TTable;
begin
  Result := TPrdPktRawMat.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

end.
