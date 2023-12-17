unit Ths.Database.Table.SysSehirler;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, Ths.Database,
  Ths.Database.Table, Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysBolgeler;

type
  TSysSehir = class(TTable)
  private
    FSehir: TFieldDB;
    FPlakaKodu: TFieldDB;
    FUlkeID: TFieldDB;
    FUlkeKodu: TFieldDB;
    FUlkeAdi: TFieldDB;
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Sehir: TFieldDB read FSehir write FSehir;
    property PlakaKodu: TFieldDB read FPlakaKodu write FPlakaKodu;
    property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    property UlkeKodu: TFieldDB read FUlkeKodu write FUlkeKodu;
    property UlkeAdi: TFieldDB read FUlkeAdi write FUlkeAdi;
    property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    property Bolge: TFieldDB read FBolge write FBolge;
  end;

implementation

uses Ths.Constants;

constructor TSysSehir.Create(ADatabase: TDatabase);
var
  LSysUlke: TSysUlke;
  LSysBolge: TSysBolge;
begin
  TableName := 'sys_sehirler';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  LSysUlke := TSysUlke.Create(Database);
  LSysBolge := TSysBolge.Create(Database);
  try
    FSehir := TFieldDB.Create('sehir', ftString, '', Self, 'Þehir');
    FPlakaKodu := TFieldDB.Create('plaka_kodu', ftInteger, 0, Self, 'Plaka Kodu');
    FUlkeID := TFieldDB.Create('ulke_id', ftLargeInt, 0, Self, 'Ülke ID');
    FUlkeKodu := TFieldDB.Create(LSysUlke.UlkeKodu.FieldName, LSysUlke.UlkeKodu.DataType, LSysUlke.UlkeKodu.Value, Self, 'Ülke Kodu');
    FUlkeAdi := TFieldDB.Create(LSysUlke.UlkeAdi.FieldName, LSysUlke.UlkeAdi.DataType, LSysUlke.UlkeAdi.Value, Self, 'Ülke Adý');
    FBolgeID := TFieldDB.Create('bolge_id', ftLargeint, 0, Self, 'Bölge ID');
    FBolge := TFieldDB.Create(LSysBolge.Bolge.FieldName, LSysBolge.Bolge.DataType, LSysBolge.Bolge.Value, Self, 'Bölge');
  finally
    LSysUlke.Free;
    LSysBolge.Free;
  end;
end;

procedure TSysSehir.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LSysUlke: TSysUlke;
  LSysBolge: TSysBolge;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LSysUlke := TSysUlke.Create(Database);
  LSysBolge := TSysBolge.Create(Database);
  try
    with QryOfDS do
    begin
      Close;
      Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
        Id.QryName,
        FSehir.QryName,
        FPlakaKodu.QryName,
        FUlkeID.QryName,
        addField(LSysUlke.TableName, LSysUlke.UlkeKodu.FieldName, FUlkeKodu.FieldName),
        addField(LSysUlke.TableName, LSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
        FBolgeID.QryName,
        addField(LSysBolge.TableName, LSysBolge.Bolge.FieldName, FBolge.FieldName)
      ], [
        addJoin(jtLeft, LSysUlke.TableName, LSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
        addJoin(jtLeft, LSysBolge.TableName, LSysBolge.Id.FieldName, TableName, FBolgeID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  finally
    LSysUlke.Free;
    LSysBolge.Free;
  end;
end;

procedure TSysSehir.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TFDQuery;
  LSysUlke: TSysUlke;
  LSysBolge: TSysBolge;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  LSysUlke := TSysUlke.Create(Database);
  LSysBolge := TSysBolge.Create(Database);
  try
    with LQry do
    begin
      Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
        Id.QryName,
        FSehir.QryName,
        FPlakaKodu.QryName,
        FUlkeID.QryName,
        addField(LSysUlke.TableName, LSysUlke.UlkeKodu.FieldName, FUlkeKodu.FieldName),
        addField(LSysUlke.TableName, LSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
        FBolgeID.QryName,
        addField(LSysBolge.TableName, LSysBolge.Bolge.FieldName, FBolge.FieldName)
      ], [
        addJoin(jtLeft, LSysUlke.TableName, LSysUlke.Id.FieldName, TableName, FUlkeID.FieldName),
        addJoin(jtLeft, LSysBolge.TableName, LSysBolge.Id.FieldName, TableName, FBolgeID.FieldName),
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
    end;
  finally
    LQry.Free;
    LSysUlke.Free;
    LSysBolge.Free;
  end;
end;

procedure TSysSehir.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FSehir.FieldName,
      FPlakaKodu.FieldName,
      FUlkeID.FieldName,
      FBolgeID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysSehir.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FSehir.FieldName,
      FPlakaKodu.FieldName,
      FUlkeID.FieldName,
      FBolgeID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    Free;
  end;
end;

function TSysSehir.Clone: TTable;
begin
  Result := TSysSehir.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
