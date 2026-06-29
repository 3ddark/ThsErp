unit Ths.Database.Table.PrdPktLabours;

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
  Ths.Database.Table.PrdLabour;

type
  TPrdPktLabour = class;

  TPrdPktLabourDetail = class(TTable)
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

    constructor Create(ADatabase: TDatabase; APkt: TPrdPktLabour = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    PktLabour: TPrdPktLabour;

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

  TPrdPktLabour = class(TTableDetailed)
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
  Ths.Constants;

constructor TPrdPktLabourDetail.Create(ADatabase: TDatabase; APkt: TPrdPktLabour);
begin
  TableName := 'prd_paket_iscilik_detaylari';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  if APkt <> nil then
    PktLabour := APkt;

  FPrdLabour := TPrdLabour.Create(ADatabase);
  FSysUom := TSysOlcuBirimi.Create(ADatabase);

  FHeaderId := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FLabourCode := TFieldDB.Create('iscilik_kodu', ftWideString, '', Self, '');
  FQuantity := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FExpenseName := TFieldDB.Create(FPrdLabour.ExpenseCode.FieldName, FPrdLabour.ExpenseCode.DataType, '', Self, 'Gider Kodu');
  FUoM := TFieldDB.Create(FSysUom.Birim.FieldName, FSysUom.Birim.DataType, '', Self, 'Birim');
  FPrice := TFieldDB.Create(FPrdLabour.Price.FieldName, FPrdLabour.Price.DataType, 0, Self, 'Fiyat');
end;

destructor TPrdPktLabourDetail.Destroy;
begin
  FreeAndNil(FPrdLabour);
  FreeAndNil(FSysUom);
  inherited;
end;

function TPrdPktLabourDetail.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
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
      FQuantity.QryName
    ], [
      ' WHERE 1=1 ' + AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TPrdPktLabourDetail.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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

procedure TPrdPktLabourDetail.DoInsert(APermissionControl: Boolean);
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

procedure TPrdPktLabourDetail.DoUpdate(APermissionControl: Boolean);
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

function TPrdPktLabourDetail.Clone: TTable;
begin
  Result := TPrdPktLabourDetail.Create(Database, Self.PktLabour);
  CloneClassContent(Self, Result);
end;

constructor TPrdPktLabour.Create(ADatabase: TDatabase);
begin
  TableName := 'prd_paket_iscilikler';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FPackageName := TFieldDB.Create('paket_adi', ftWideString, '', Self);
end;

function TPrdPktLabour.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
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

procedure TPrdPktLabour.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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

procedure TPrdPktLabour.DoInsert(APermissionControl: Boolean);
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

procedure TPrdPktLabour.DoUpdate(APermissionControl: Boolean);
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

procedure TPrdPktLabour.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  TPrdPktLabourDetail(ATable).PktLabour := Self;
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TPrdPktLabourDetail then
    begin
      if TPrdPktLabourDetail(ListDetay[n1]).FLabourCode.AsString = TPrdPktLabourDetail(ATable).FLabourCode.AsString then
      begin
        TPrdPktLabourDetail(ListDetay[n1]).FQuantity.Value := TPrdPktLabourDetail(ListDetay[n1]).FQuantity.AsFloat + TPrdPktLabourDetail(ATable).FQuantity.AsFloat;
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

procedure TPrdPktLabour.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

procedure TPrdPktLabour.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

function TPrdPktLabour.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TPrdPktLabour.RefreshHeader;
begin
  //
end;

procedure TPrdPktLabour.BusinessDelete(APermissionControl: Boolean);
begin
  //
end;

procedure TPrdPktLabour.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(APermissionControl);
  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TPrdPktLabourDetail then
    begin
      TPrdPktLabourDetail(Self.ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      TPrdPktLabourDetail(Self.ListDetay[n1]).Insert(APermissionControl);
    end
  end;
end;

procedure TPrdPktLabour.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  LDty: TPrdPktLabourDetail;
  n1, n2: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    LDty := TPrdPktLabourDetail.Create(Database);
    try
      LDty.SelectToList(' AND ' + LDty.HeaderId.QryName + '=' + TPrdPktLabour(Self.List[n1]).Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LDty.List.Count - 1 do
        TPrdPktLabour(Self.List[n1]).AddDetay(TPrdPktLabourDetail(TPrdPktLabourDetail(LDty.List[n2]).Clone));
    finally
      FreeAndNil(LDty);
    end;
  end;
end;

procedure TPrdPktLabour.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TPrdPktLabourDetail then
    begin
      TPrdPktLabourDetail(Self.ListDetay[n1]).FHeaderId.Value := Self.Id.AsInteger;
      if TPrdPktLabourDetail(Self.ListDetay[n1]).Id.AsInteger > 0 then
        TPrdPktLabourDetail(Self.ListDetay[n1]).Update(APermissionControl)
      else
        TPrdPktLabourDetail(Self.ListDetay[n1]).Insert(APermissionControl)
    end
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count - 1 do
    if TTable(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TTable(Self.ListSilinenDetay[n1]).Delete(APermissionControl);
end;

function TPrdPktLabour.Clone: TTable;
begin
  Result := TPrdPktLabour.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

end.
