unit Ths.Erp.Database.Table.SysSehir;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysUlke,
  Ths.Erp.Database.Table.SysBolge;

type
  TSysSehir = class(TTable)
  private
    FSehirAdi: TFieldDB;
    FPlakaKodu: TFieldDB;
    FUlkeID: TFieldDB;
    FUlkeAdi: TFieldDB;
    FBolgeID: TFieldDB;
    FBolgeAdi: TFieldDB;

    FSysUlke: TSysUlke;
    FSysBolge: TSysBolge;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property SehirAdi: TFieldDB read FSehirAdi write FSehirAdi;
    property PlakaKodu: TFieldDB read FPlakaKodu write FPlakaKodu;
    property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    property UlkeAdi: TFieldDB read FUlkeAdi write FUlkeAdi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysSehir.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_sehir';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysUlke := TSysUlke.Create(Database);
  FSysBolge := TSysBolge.Create(Database);

  FSehirAdi := TFieldDB.Create('sehir_adi', ftString, '', Self, 'Þehir');
  FPlakaKodu := TFieldDB.Create('plaka_kodu', ftInteger, 0, Self, 'Plaka Kodu');
  FUlkeID := TFieldDB.Create('ulke_id', ftInteger, 0, Self, 'Ülke ID');
  FUlkeAdi := TFieldDB.Create(FSysUlke.UlkeAdi.FieldName, FSysUlke.UlkeAdi.DataType, '', Self, 'Ülke');
  FBolgeID := TFieldDB.Create('bolge_id', ftInteger, 0, Self, 'Bölge ID');
  FBolgeAdi := TFieldDB.Create(FSysBolge.BolgeAdi.FieldName, FSysBolge.BolgeAdi.DataType, '', Self, 'Bölge');
end;

destructor TSysSehir.Destroy;
begin
  FreeAndNil(FSysUlke);
  FreeAndNil(FSysBolge);
  inherited;
end;

procedure TSysSehir.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FSehirAdi.FieldName,
        TableName + '.' + FPlakaKodu.FieldName,
        TableName + '.' + FUlkeID.FieldName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
        TableName + '.' + FBolgeID.FieldName,
        addField(FSysBolge.TableName, FSysBolge.BolgeAdi.FieldName, FBolgeAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
        addJoin(jtLeft, FSysBolge.TableName, FSysBolge.Id.FieldName, TableName, FBolgeID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FSehirAdi, 'Þehir Adý', QueryOfDS);
      setFieldTitle(FPlakaKodu, 'Plaka Kodu', QueryOfDS);
      setFieldTitle(FUlkeID, 'Ülke ID', QueryOfDS);
      setFieldTitle(FUlkeAdi, 'Ülke Adý', QueryOfDS);
      setFieldTitle(FBolgeID, 'Bölge ID', QueryOfDS);
      setFieldTitle(FBolgeAdi, 'Bölge Adý', QueryOfDS);
    end;
  end;
end;

procedure TSysSehir.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FSehirAdi.FieldName,
        TableName + '.' + FPlakaKodu.FieldName,
        TableName + '.' + FUlkeID.FieldName,
        addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
        TableName + '.' + FBolgeID.FieldName,
        addField(FSysBolge.TableName, FSysBolge.BolgeAdi.FieldName, FBolgeAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
        addJoin(jtLeft, FSysBolge.TableName, FSysBolge.Id.FieldName, TableName, FBolgeID.FieldName),
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
      EmptyDataSet;
      Close;
	  end;
  end;
end;

procedure TSysSehir.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FSehirAdi.FieldName,
        FPlakaKodu.FieldName,
        FUlkeID.FieldName,
        FBolgeID.FieldName
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

procedure TSysSehir.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FSehirAdi.FieldName,
        FPlakaKodu.FieldName,
        FUlkeID.FieldName,
        FBolgeID.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

function TSysSehir.Clone: TTable;
begin
  Result := TSysSehir.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
