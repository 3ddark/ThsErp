unit Ths.Database.Table.SetChFirmaTuru;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table;

type
  TSetChFirmaTuru = class(TTable)
  private
    FFirmaTuru: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FirmaTuru: TFieldDB read FFirmaTuru write FFirmaTuru;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetChFirmaTuru.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_firma_turu';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FFirmaTuru := TFieldDB.Create('firma_turu', ftWideString, '', Self, 'Firma Türü');
end;

procedure TSetChFirmaTuru.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FFirmaTuru.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetChFirmaTuru.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FFirmaTuru.QryName
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

procedure TSetChFirmaTuru.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FFirmaTuru.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetChFirmaTuru.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FFirmaTuru.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetChFirmaTuru.Clone: TTable;
begin
  Result := TSetChFirmaTuru.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



