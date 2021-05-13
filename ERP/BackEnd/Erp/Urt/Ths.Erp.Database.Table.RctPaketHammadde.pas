unit Ths.Erp.Database.Table.RctPaketHammadde;

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
  Ths.Erp.Database.Table.RctRecete;

const
  PH_MAL_KODU = 1;
  PH_MAL_ADI = 2;
  PH_MIKTAR = 3;
  PH_BIRIM = 4;
  PH_FIYAT = 5;
  PH_FIRE_ORANI = 6;

type
  TRctPaketHammadde = class;

  TRctPaketHammaddeDetay = class(TTable)
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

    constructor Create(ADatabase: TDatabase; APaket: TRctPaketHammadde = nil); reintroduce; overload;
    destructor Destroy; override;
  public
    PaketHammadde: TRctPaketHammadde;

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

  TRctPaketHammadde = class(TTableDetailed)
  private
    FPaketAdi: TFieldDB;
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
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure AddDetay(ATable: TTable; ALastItem: Boolean = False); override;
    procedure UpdateDetay(ATable: TTable); override;
    procedure RemoveDetay(ATable: TTable); override;

    Property PaketAdi: TFieldDB read FPaketAdi write FPaketAdi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TRctPaketHammaddeDetay.Create(ADatabase: TDatabase; APaket: TRctPaketHammadde);
begin
  TableName := 'rct_paket_hammadde_detay';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  if APaket <> nil then
    PaketHammadde := APaket;

  FStkStokKarti := TStkStokKarti.Create(ADatabase);
  FBirim := TSysOlcuBirimi.Create(ADatabase);
  FRecete := TRctRecete.Create(ADatabase);

  FHeaderID := TFieldDB.Create('header_id', ftInteger, 0, Self, '');
  FReceteID := TFieldDB.Create('recete_id', ftInteger, 0, Self, '');
  FStokKodu := TFieldDB.Create('stok_kodu', ftString, '', Self, '');
  FMiktar := TFieldDB.Create('miktar', ftFloat, 0, Self, '');
  FFireOrani := TFieldDB.Create('fire_orani', ftFloat, 0, Self, '');
  FReceteKodu := TFieldDB.Create(FRecete.ReceteKodu.FieldName, FRecete.ReceteKodu.DataType, '', Self, '');
  FStokAdi := TFieldDB.Create(FStkStokKarti.StokAdi.FieldName, FStkStokKarti.StokAdi.DataType, '', Self, '');
  FOlcuBirimi := TFieldDB.Create(FBirim.OlcuBirimi.FieldName, FBirim.OlcuBirimi.DataType, '', Self, '');
  FFiyat := TFieldDB.Create('fiyat', ftBCD, 0, Self, '');
end;

destructor TRctPaketHammaddeDetay.Destroy;
begin
  FreeAndNil(FStkStokKarti);
  FreeAndNil(FBirim);
  FreeAndNil(FRecete);
  inherited;
end;

procedure TRctPaketHammaddeDetay.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
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

procedure TRctPaketHammaddeDetay.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        ' rct.' + FRecete.ReceteKodu.FieldName + ' ' + FReceteKodu.FieldName,
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

procedure TRctPaketHammaddeDetay.Insert(out AID: Integer; APermissionControl: Boolean);
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

procedure TRctPaketHammaddeDetay.Update(APermissionControl: Boolean);
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

function TRctPaketHammaddeDetay.Clone: TTable;
begin
  Result := TRctPaketHammaddeDetay.Create(Database, Self.PaketHammadde);
  CloneClassContent(Self, Result);
end;

constructor TRctPaketHammadde.Create(ADatabase: TDatabase);
begin
  TableName := 'rct_paket_hammadde';
  TableSourceCode := MODULE_RCT_RECETE_AYAR;
  inherited Create(ADatabase);

  FPaketAdi := TFieldDB.Create('paket_adi', ftString, '', Self, '');
end;

destructor TRctPaketHammadde.Destroy;
begin
  inherited;
end;

procedure TRctPaketHammadde.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      SQL.Clear;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FPaketAdi.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;
    end;
  end;
end;

procedure TRctPaketHammadde.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
      AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT; ';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FPaketAdi.FieldName
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

procedure TRctPaketHammadde.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FPaketAdi.FieldName
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

procedure TRctPaketHammadde.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FPaketAdi.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TRctPaketHammadde.AddDetay(ATable: TTable; ALastItem: Boolean = False);
var
  n1: Integer;
  LExistsSameCode: Boolean;
begin
  TRctPaketHammaddeDetay(ATable).PaketHammadde := Self;
  LExistsSameCode := False;
  for n1 := 0 to ListDetay.Count-1 do
  begin
    if TObject(ListDetay[n1]).ClassType = TRctPaketHammaddeDetay then
    begin
      if TRctPaketHammaddeDetay(ListDetay[n1]).FStokKodu.Value = TRctPaketHammaddeDetay(ATable).FStokKodu.Value then
      begin
        TRctPaketHammaddeDetay(ListDetay[n1]).FMiktar.Value := TRctPaketHammaddeDetay(ListDetay[n1]).FMiktar.Value + TRctPaketHammaddeDetay(ATable).Miktar.Value;
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

procedure TRctPaketHammadde.UpdateDetay(ATable: TTable);
begin
  inherited;
  RefreshHeader;
end;

procedure TRctPaketHammadde.RemoveDetay(ATable: TTable);
begin
  if ATable.Id.Value > 0 then
    ListSilinenDetay.Add(ATable);
  ListDetay.Remove(ATable);
  RefreshHeader;
end;

function TRctPaketHammadde.ValidateDetay(ATable: TTable): Boolean;
begin
  Result := True;
end;

procedure TRctPaketHammadde.RefreshHeader;
begin
  //
end;

procedure TRctPaketHammadde.BusinessDelete(APermissionControl: Boolean);
begin
  //
end;

procedure TRctPaketHammadde.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  n1, vID: Integer;
begin
  Self.Insert(AID, APermissionControl);
  Self.Id.Value := AID;
  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TRctPaketHammaddeDetay then
    begin
      TRctPaketHammaddeDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
      TRctPaketHammaddeDetay(Self.ListDetay[n1]).Insert(vID, APermissionControl);
    end
  end;
end;

procedure TRctPaketHammadde.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
var
  LDty: TRctPaketHammaddeDetay;
  n1: Integer;
begin
  FreeDetayListContent;

  Self.SelectToList(AFilter, ALock, APermissionControl);

  LDty := TRctPaketHammaddeDetay.Create(Database);
  try
    LDty.SelectToList(' AND ' + LDty.TableName + '.' + LDty.HeaderID.FieldName + '=' + VarToStr(Self.Id.Value), ALock, APermissionControl);
    for n1 := 0 to LDty.List.Count - 1 do
      TRctPaketHammadde(Self).AddDetay(TRctPaketHammaddeDetay(TRctPaketHammaddeDetay(LDty.List[n1]).Clone));
  finally
    FreeAndNil(LDty);
  end;
end;

procedure TRctPaketHammadde.BusinessUpdate(APermissionControl: Boolean);
var
  n1, vID: Integer;
begin
  Self.Update(APermissionControl);

  for n1 := 0 to Self.ListDetay.Count - 1 do
  begin
    if TObject(Self.ListDetay[n1]).ClassType = TRctPaketHammaddeDetay then
    begin
      TRctPaketHammaddeDetay(Self.ListDetay[n1]).HeaderID.Value := Self.Id.Value;
      if TRctPaketHammaddeDetay(Self.ListDetay[n1]).Id.Value > 0 then
        TRctPaketHammaddeDetay(Self.ListDetay[n1]).Update(APermissionControl)
      else
        TRctPaketHammaddeDetay(Self.ListDetay[n1]).Insert(vID, APermissionControl)
    end
  end;

  for n1 := 0 to Self.ListSilinenDetay.Count - 1 do
    if TTable(Self.ListSilinenDetay[n1]).Id.Value > 0 then
      TTable(Self.ListSilinenDetay[n1]).Delete(APermissionControl);
end;

function TRctPaketHammadde.Clone: TTable;
begin
  Result := TRctPaketHammadde.Create(Database);
  CloneClassContent(Self, Result);
  CloneDetayLists(TTableDetailed(Result));
end;

end.
