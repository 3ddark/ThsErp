unit Ths.Database.Table.SetBbkFinansDurumu;

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
  TBbkFinansDurumu = (Olumlu=1, Olumsuz);

  TSetBbkFinansDurumu = class(TTable)
  private
    FFinansDurumu: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FinansDurumu: TFieldDB read FFinansDurumu write FFinansDurumu;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetBbkFinansDurumu.Create(ADatabase: TDatabase);
begin
  TableName := 'set_bbk_finans_durumlari';
  TableSourceCode := MODULE_BBK_AYAR;
  inherited Create(ADatabase);

  FFinansDurumu := TFieldDB.Create('finans_durumu', ftWideString, '', Self, '');
end;

procedure TSetBbkFinansDurumu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FFinansDurumu.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetBbkFinansDurumu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FFinansDurumu.QryName
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

procedure TSetBbkFinansDurumu.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FFinansDurumu.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSetBbkFinansDurumu.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FFinansDurumu.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetBbkFinansDurumu.Clone: TTable;
begin
  Result := TSetBbkFinansDurumu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
