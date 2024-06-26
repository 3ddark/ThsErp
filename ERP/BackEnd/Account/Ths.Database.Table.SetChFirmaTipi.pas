unit Ths.Database.Table.SetChFirmaTipi;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetChFirmaTuru;

type
  TSetChFirmaTipi = class(TTable)
  private
    FFirmaTipi: TFieldDB;
    FFirmaTuruID: TFieldDB;
    FFirmaTuru: TFieldDB;
  protected
    FSetChFirmaTuru: TSetChFirmaTuru;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FirmaTipi: TFieldDB read FFirmaTipi write FFirmaTipi;
    Property FirmaTuruID: TFieldDB read FFirmaTuruID write FFirmaTuruID;
    Property FirmaTuru: TFieldDB read FFirmaTuru write FFirmaTuru;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetChFirmaTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_firma_tipi';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FSetChFirmaTuru := TSetChFirmaTuru.Create(Database);

  FFirmaTipi := TFieldDB.Create('firma_tipi', ftWideString, '', Self, 'Firma Tipi');
  FFirmaTuruID := TFieldDB.Create('firma_turu_id', ftInteger, 0, Self, 'Firma Türü ID');
  FFirmaTuru := TFieldDB.Create(FSetChFirmaTuru.FirmaTuru.FieldName, FSetChFirmaTuru.FirmaTuru.DataType, '', Self, 'Firma Türü');
end;

destructor TSetChFirmaTipi.Destroy;
begin
  FSetChFirmaTuru.Free;
  inherited;
end;

function TSetChFirmaTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FFirmaTuruID.QryName,
      addLangField(FirmaTuru.FieldName),
      FFirmaTipi.QryName
    ], [
      addLeftJoin(FirmaTuru.FieldName, FirmaTuruID.FieldName, FSetChFirmaTuru.TableName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSetChFirmaTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FFirmaTuruID.QryName,
      addLangField(FirmaTuru.FieldName),
      FFirmaTipi.QryName
    ], [
      addLeftJoin(FirmaTuru.FieldName, FirmaTuruID.FieldName, FSetChFirmaTuru.TableName),
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

procedure TSetChFirmaTipi.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FFirmaTipi.FieldName,
      FFirmaTuruID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetChFirmaTipi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FFirmaTipi.FieldName,
      FFirmaTuruID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetChFirmaTipi.Clone: TTable;
begin
  Result := TSetChFirmaTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



