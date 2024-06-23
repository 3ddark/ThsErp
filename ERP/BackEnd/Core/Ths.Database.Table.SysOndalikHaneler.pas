unit Ths.Database.Table.SysOndalikHaneler;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  Ths.Database, Ths.Database.Table;

type
  TSysOndalikHane = class(TTable)
  private
    FMiktar: TFieldDB;
    FFiyat: TFieldDB;
    FTutar: TFieldDB;
    FStokMiktar: TFieldDB;
    FDovizKuru: TFieldDB;
  protected
    procedure BusinessInsert(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Miktar: TFieldDB read FMiktar write FMiktar;
    property Fiyat: TFieldDB read FFiyat write FFiyat;
    property Tutar: TFieldDB read FTutar write FTutar;
    property StokMiktar: TFieldDB read FStokMiktar write FStokMiktar;
    property DovizKuru: TFieldDB read FDovizKuru write FDovizKuru;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysOndalikHane.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ondalik_haneler';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FMiktar := TFieldDB.Create('miktar', ftInteger, 2, Self, 'Miktar');
  FFiyat := TFieldDB.Create('fiyat', ftInteger, 2, Self, 'Fiyat');
  FTutar := TFieldDB.Create('tutar', ftInteger, 2, Self, 'Tutar');
  FStokMiktar := TFieldDB.Create('stok_miktar', ftInteger, 2, Self, 'Stok Miktar');
  FDovizKuru := TFieldDB.Create('doviz_kuru', ftInteger, 4, Self, 'D�viz Kuru');
end;

procedure TSysOndalikHane.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FMiktar.QryName,
      FFiyat.QryName,
      FTutar.QryName,
      FStokMiktar.QryName,
      FDovizKuru.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysOndalikHane.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FMiktar.QryName,
      FFiyat.QryName,
      FTutar.QryName,
      FStokMiktar.QryName,
      FDovizKuru.QryName
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

procedure TSysOndalikHane.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FMiktar.FieldName,
      FFiyat.FieldName,
      FTutar.FieldName,
      FStokMiktar.FieldName,
      FDovizKuru.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysOndalikHane.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Self.Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FMiktar.FieldName,
      FFiyat.FieldName,
      FTutar.FieldName,
      FStokMiktar.FieldName,
      FDovizKuru.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

procedure TSysOndalikHane.BusinessDelete(APermissionControl: Boolean);
var
  LOndalik: TSysOndalikHane;
begin
  LOndalik := TSysOndalikHane.Create(Database);
  try
    LOndalik.SelectToList('', False, False);
    if LOndalik.List.Count > 1 then
      inherited
    else
      raise Exception.Create('Ondal�kl� Haneler tablosunda sadece bir kay�t olabilir!!!');
  finally
    LOndalik.Free;
  end;
end;

procedure TSysOndalikHane.BusinessInsert(APermissionControl: Boolean);
var
  LOndalik: TSysOndalikHane;
begin
  LOndalik := TSysOndalikHane.Create(Database);
  try
    LOndalik.SelectToList('', False, False);
    if LOndalik.List.Count = 0 then
      inherited
    else
      raise Exception.Create('Ondalıklı Haneler tablosunda sadece bir kayıt olabilir!!!');
  finally
    LOndalik.Free;
  end;
end;

function TSysOndalikHane.Clone: TTable;
begin
  Result := TSysOndalikHane.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
