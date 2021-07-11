unit Ths.Erp.Database.Table.SysOlcuBirimi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysOlcuBirimiTipi;

type
  TSysOlcuBirimi = class(TTable)
  private
    FOlcuBirimi: TFieldDB;
    FOlcuBirimiEInv: TFieldDB;
    FAciklama: TFieldDB;
    FIsOndalik: TFieldDB;
    FOlcuBirimiTipiID: TFieldDB;
    FOlcuBirimiTipi: TFieldDB;
    FCarpan: TFieldDB;
  published
    FBirimTipi: TSysOlcuBirimiTipi;
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property OlcuBirimi: TFieldDB read FOlcuBirimi write FOlcuBirimi;
    Property OlcuBirimiEInv: TFieldDB read FOlcuBirimiEInv write FOlcuBirimiEInv;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsOndalik: TFieldDB read FIsOndalik write FIsOndalik;
    Property OlcuBirimiTipiID: TFieldDB read FOlcuBirimiTipiID write FOlcuBirimiTipiID;
    Property OlcuBirimiTipi: TFieldDB read FOlcuBirimiTipi write FOlcuBirimiTipi;
    Property Carpan: TFieldDB read FCarpan write FCarpan;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysOlcuBirimi.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_olcu_birimi';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FBirimTipi := TSysOlcuBirimiTipi.Create(ADatabase);

  FOlcuBirimi := TFieldDB.Create('olcu_birimi', ftString, '', Self, 'Ölçü Birimi');
  FOlcuBirimiEInv := TFieldDB.Create('olcu_birimi_einv', ftString, '', Self, 'E-Fatura Birim');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
  FIsOndalik := TFieldDB.Create('is_ondalik', ftBoolean, False, Self, 'Ondalýk?');
  FOlcuBirimiTipiID := TFieldDB.Create('olcu_birimi_tipi_id', ftInteger, 0, Self, 'Ölçü Birimi Tipi ID');
  FOlcuBirimiTipi := TFieldDB.Create(FBirimTipi.OlcuBirimiTipi.FieldName, FBirimTipi.OlcuBirimiTipi.DataType, '', Self, 'Ölçü Birimi Tipi');
  FCarpan := TFieldDB.Create('carpan', ftInteger, 0, Self, 'Çarpan');
end;

destructor TSysOlcuBirimi.Destroy;
begin
  FBirimTipi.Free;
  inherited;
end;

procedure TSysOlcuBirimi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FOlcuBirimi.QryName,
        FOlcuBirimiEInv.QryName,
        FAciklama.QryName,
        FIsOndalik.QryName,
        FOlcuBirimiTipiID.QryName,
        addField(FBirimTipi.TableName, FBirimTipi.OlcuBirimiTipi.FieldName, FOlcuBirimiTipi.FieldName),
        FCarpan.QryName
      ], [
        addJoin(jtLeft, FBirimTipi.TableName, FBirimTipi.Id.FieldName, TableName, FOlcuBirimiTipiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysOlcuBirimi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Self.Id.QryName,
        FOlcuBirimi.QryName,
        FOlcuBirimiEInv.QryName,
        FAciklama.QryName,
        FIsOndalik.QryName,
        FOlcuBirimiTipiID.QryName,
        addField(FBirimTipi.TableName, FBirimTipi.OlcuBirimiTipi.FieldName, FOlcuBirimiTipi.FieldName),
        FCarpan.QryName
      ], [
        addJoin(jtLeft, FBirimTipi.TableName, FBirimTipi.Id.FieldName, TableName, FOlcuBirimiTipiID.FieldName),
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

procedure TSysOlcuBirimi.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FOlcuBirimi.FieldName,
        FOlcuBirimiEInv.FieldName,
        FAciklama.FieldName,
        FIsOndalik.FieldName,
        FOlcuBirimiTipiID.FieldName,
        FCarpan.FieldName
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

procedure TSysOlcuBirimi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FOlcuBirimi.FieldName,
        FOlcuBirimiEInv.FieldName,
        FAciklama.FieldName,
        FIsOndalik.FieldName,
        FOlcuBirimiTipiID.FieldName,
        FCarpan.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysOlcuBirimi.Clone: TTable;
begin
  Result := TSysOlcuBirimi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
