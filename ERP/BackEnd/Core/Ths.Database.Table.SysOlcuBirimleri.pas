unit Ths.Database.Table.SysOlcuBirimleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, Ths.Database,
  Ths.Database.Table;

type
  TSysOlcuBirimi = class(TTable)
  private
    FBirim: TFieldDB;
    FBirimEInv: TFieldDB;
    FAciklama: TFieldDB;
    FIsOndalik: TFieldDB;
    FBirimiTipiID: TFieldDB;
    FBirimTipi: TFieldDB;
    FCarpan: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Birim: TFieldDB read FBirim write FBirim;
    Property BirimEInv: TFieldDB read FBirimEInv write FBirimEInv;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsOndalik: TFieldDB read FIsOndalik write FIsOndalik;
    Property BirimiTipiID: TFieldDB read FBirimiTipiID write FBirimiTipiID;
    Property BirimTipi: TFieldDB read FBirimTipi write FBirimTipi;
    Property Carpan: TFieldDB read FCarpan write FCarpan;
  end;

implementation

uses Ths.Database.Table.SysOlcuBirimiTipleri, Ths.Constants;

constructor TSysOlcuBirimi.Create(ADatabase: TDatabase);
var
  LUnitTypes: TSysOlcuBirimiTipi;
begin
  TableName := 'sys_olcu_birimleri';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  LUnitTypes := TSysOlcuBirimiTipi.Create(ADatabase);
  try
    FBirim := TFieldDB.Create('birim', ftString, '', Self, 'Birim');
    FBirimEInv := TFieldDB.Create('birim_einv', ftString, '', Self, 'E-Fature Birim');
    FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açıklama');
    FIsOndalik := TFieldDB.Create('is_ondalik', ftBoolean, False, Self, 'Ondalık?');
    FBirimiTipiID := TFieldDB.Create('birim_tipi_id', ftInteger, 0, Self, 'Ölçü Birimi Tipi ID');
    FBirimTipi := TFieldDB.Create(LUnitTypes.OlcuBirimiTipi.FieldName, LUnitTypes.OlcuBirimiTipi.DataType, LUnitTypes.OlcuBirimiTipi.Value, Self, LUnitTypes.OlcuBirimiTipi.Title);
    FCarpan := TFieldDB.Create('carpan', ftInteger, 0, Self, 'Çarpan');
  finally
    LUnitTypes.Free;
  end;
end;

procedure TSysOlcuBirimi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LUnitTypes: TSysOlcuBirimiTipi;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LUnitTypes := TSysOlcuBirimiTipi.Create(Database);
  try
    with QryOfDS do
    begin
      Close;
      Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
        Self.Id.QryName,
        FBirim.QryName,
        FBirimEInv.QryName,
        FAciklama.QryName,
        FIsOndalik.QryName,
        FBirimiTipiID.QryName,
        addField(LUnitTypes.TableName, LUnitTypes.OlcuBirimiTipi.FieldName, FBirimTipi.FieldName),
        FCarpan.QryName
      ], [
        addJoin(jtLeft, LUnitTypes.TableName, LUnitTypes.Id.FieldName, TableName, FBirimiTipiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  finally
    LUnitTypes.Free
  end;
end;

procedure TSysOlcuBirimi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
  LUnitTypes: TSysOlcuBirimiTipi;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  LUnitTypes := TSysOlcuBirimiTipi.Create(Database);
  try
    with LQry do
    begin
      Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
        Self.Id.QryName,
        FBirim.QryName,
        FBirimEInv.QryName,
        FAciklama.QryName,
        FIsOndalik.QryName,
        FBirimiTipiID.QryName,
        addField(LUnitTypes.TableName, LUnitTypes.OlcuBirimiTipi.FieldName, FBirimTipi.FieldName),
        FCarpan.QryName
      ], [
        addJoin(jtLeft, LUnitTypes.TableName, LUnitTypes.Id.FieldName, TableName, FBirimiTipiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(LQry);

        List.Add(Self.Clone);

        Next;
      end;
    end;
  finally
    LQry.Free;
    LUnitTypes.Free;
  end;
end;

procedure TSysOlcuBirimi.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FBirim.FieldName,
      FBirimEInv.FieldName,
      FAciklama.FieldName,
      FIsOndalik.FieldName,
      FBirimiTipiID.FieldName,
      FCarpan.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysOlcuBirimi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FBirim.FieldName,
      FBirimEInv.FieldName,
      FAciklama.FieldName,
      FIsOndalik.FieldName,
      FBirimiTipiID.FieldName,
      FCarpan.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSysOlcuBirimi.Clone: TTable;
begin
  Result := TSysOlcuBirimi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
