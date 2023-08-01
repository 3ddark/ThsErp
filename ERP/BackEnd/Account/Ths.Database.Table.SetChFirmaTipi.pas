unit Ths.Database.Table.SetChFirmaTipi;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
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
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
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

procedure TSetChFirmaTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FFirmaTuruID.QryName,
      addLangField(FirmaTuru.FieldName),
      FFirmaTipi.QryName
    ], [
      addLeftJoin(FirmaTuru.FieldName, FirmaTuruID.FieldName, FSetChFirmaTuru.TableName),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetChFirmaTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
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
    List.Clear;
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

procedure TSetChFirmaTipi.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FFirmaTipi.FieldName,
      FFirmaTuruID.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Id.FieldName).AsInteger
    else  AID := 0;

    EmptyDataSet;
  finally
    Free;
  end;
end;

procedure TSetChFirmaTipi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FFirmaTipi.FieldName,
      FFirmaTuruID.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetChFirmaTipi.Clone: TTable;
begin
  Result := TSetChFirmaTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



