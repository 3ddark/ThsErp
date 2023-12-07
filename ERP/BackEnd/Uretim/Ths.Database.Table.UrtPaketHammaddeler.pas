unit Ths.Database.Table.UrtPaketHammaddeler;

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
  Ths.Database.Table.UrtReceteler;

type
  TUrtPaketHammadde = class;

  TUrtPaketHammaddeDetay = class(TTable)
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
    FStkStokKarti: TStkKart;
    FSysOlcuBirimi: TSysOlcuBirimi;
    FRctRecete: TUrtRecete;

    constructor Create(ADatabase: TDatabase; APaket: TUrtPaketHammadde = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    PaketHammadde: TUrtPaketHammadde;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

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

  TUrtPaketHammadde = class(TTableDetailed)
  private
    FPaketAdi: TFieldDB;
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
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property PaketAdi: TFieldDB read FPaketAdi write FPaketAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TUrtPaketHammaddeDetay.Create(ADatabase: TDatabase; APaket: TUrtPaketHammadde);
begin
  TableName := 'urt_paket_hammadde_detaylari';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  if APaket <> nil then
    PaketHammadde := APaket;

  FStkStokKarti := TStkKart.Create(ADatabase);
  FSysOlcuBirimi := TSysOlcuBirimi.Create(ADatabase);
  FRctRecete := TUrtRecete.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FReceteID := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftWideString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FReceteKodu := TFieldDB.Create(FRctRecete.ReceteKodu.FieldName, FRctRecete.ReceteKodu.DataType, '', Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FSysOlcuBirimi.Birim.FieldName, FSysOlcuBirimi.Birim.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TUrtPaketHammaddeDetay.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FSysOlcuBirimi);
  FreeAndNil(FRctRecete);
  inherited;
end;

procedure TUrtPaketHammaddeDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
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

procedure TUrtPaketHammaddeDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FHeaderID.QryName,
      FReceteID.QryName,
      FStokKodu.QryName,
      FMiktar.QryName,
      FFireOrani.QryName,
      addField(FRctRecete.TableName, FRctRecete.ReceteKodu.FieldName, FReceteKodu.FieldName),
      addField(FStkStokKarti.TableName, FStkStokKarti.StokAdi.FieldName, FStokAdi.FieldName),
      addField(FSysOlcuBirimi.TableName, FSysOlcuBirimi.Birim.FieldName, FOlcuBirimi.FieldName),
      addField(FStkStokKarti.TableName, FStkStokKarti.AlisFiyat.FieldName, FFiyat.FieldName)
    ], [
      AddJoin(jtLeft, FRctRecete.TableName, FRctRecete.Id.FieldName, TableName, FReceteID.FieldName),
      AddJoin(jtLeft, FStkStokKarti.TableName, FStkStokKarti.StokKodu.FieldName, TableName, FStokKodu.FieldName),
      AddJoin(jtLeft, FSysOlcuBirimi.TableName, FSysOlcuBirimi.Id.FieldName, FStkStokKarti.TableName, FStkStokKarti.OlcuBirimiID.FieldName),
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

procedure TUrtPaketHammaddeDetay.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FReceteID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TUrtPaketHammaddeDetay.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Clear;
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FHeaderID.FieldName,
      FReceteID.FieldName,
      FStokKodu.FieldName,
      FMiktar.FieldName,
      FFireOrani.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TUrtPaketHammaddeDetay.Clone: TTable;
begin
  Result := TUrtPaketHammaddeDetay.Create(Database, Self.PaketHammadde);
  CloneClassContent(Self, Result);
end;

constructor TUrtPaketHammadde.Create(ADatabase: TDatabase);
begin
  TableName := 'urt_paket_hammaddeler';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FPaketAdi := TFieldDB.Create('paket_adi', ftWideString, '', Self, '');
end;

procedure TUrtPaketHammadde.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    SQL.Clear;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FPaketAdi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;
  end;
end;

procedure TUrtPaketHammadde.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FPaketAdi.QryName
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

procedure TUrtPaketHammadde.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FPaketAdi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TUrtPaketHammadde.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FPaketAdi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

procedure TUrtPaketHammadde.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  TUrtPaketHammaddeDetay(ATable).PaketHammadde := Self;
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TUrtPaketHammaddeDetay then
    begin
      if TUrtPaketHammaddeDetay(ListDetay[n1]).FStokKodu.AsString = TUrtPaketHammaddeDetay(ATable).FStokKodu.AsString then
      begin
        TUrtPaketHammaddeDetay(ListDetay[n1]).FMiktar.Value := TUrtPaketHammaddeDetay(ListDetay[n1]).FMiktar.AsFloat + TUrtPaketHammaddeDetay(ATable).Miktar.AsFloat;
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

procedure TUrtPaketHammadde.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

procedure TUrtPaketHammadde.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

function TUrtPaketHammadde.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TUrtPaketHammadde.RefreshHeader;
begin
  //
end;

procedure TUrtPaketHammadde.BusinessDelete(APermissionControl: Boolean);
begin
  //
end;

procedure TUrtPaketHammadde.BusinessInsert(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Insert(APermissionControl);
  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TUrtPaketHammaddeDetay then
    begin
      TUrtPaketHammaddeDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      TUrtPaketHammaddeDetay(Self.ListDetay[n1]).Insert(APermissionControl);
    end
  end;
end;

procedure TUrtPaketHammadde.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  LDty: TUrtPaketHammaddeDetay;
  n1, n2: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);
  for n1 := 0 to List.Count-1 do
  begin
    LDty := TUrtPaketHammaddeDetay.Create(Database);
    try
      LDty.SelectToList(' AND ' + LDty.HeaderID.QryName + '=' + TUrtPaketHammadde(Self.List[n1]).Id.AsString, ALock, APermissionControl);
      for n2 := 0 to LDty.List.Count - 1 do
        TUrtPaketHammadde(Self.List[n1]).AddDetay(TUrtPaketHammaddeDetay(TUrtPaketHammaddeDetay(LDty.List[n2]).Clone));
    finally
      FreeAndNil(LDty);
    end;
  end;
end;

procedure TUrtPaketHammadde.BusinessUpdate(APermissionControl: Boolean);
var
  n1: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TUrtPaketHammaddeDetay then
    begin
      TUrtPaketHammaddeDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.AsInteger;
      if TUrtPaketHammaddeDetay(Self.ListDetay[n1]).Id.AsInteger > 0 then
        TUrtPaketHammaddeDetay(Self.ListDetay[n1]).Update(APermissionControl)
      else
        TUrtPaketHammaddeDetay(Self.ListDetay[n1]).Insert(APermissionControl)
    end
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count - 1 do
    if TTable(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TTable(Self.ListSilinenDetay[n1]).Delete(APermissionControl);
end;

function TUrtPaketHammadde.Clone: TTable;
begin
  Result := TUrtPaketHammadde.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

end.
