unit Ths.Database.Table.ChDovizKurlari;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TChDovizKuru = class(TTable)
  private
    FKurTarihi: TFieldDB;
    FPara: TFieldDB;
    FKur: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property KurTarihi: TFieldDB read FKurTarihi write FKurTarihi;
    Property Para: TFieldDB read FPara write FPara;
    Property Kur: TFieldDB read FKur write FKur;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TChDovizKuru.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_doviz_kurlari';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FKurTarihi := TFieldDB.Create('kur_tarihi', ftDate, 0, Self, 'Kur Tarihi');
  FPara := TFieldDB.Create('para', ftWideString, '', Self, 'Para');
  FKur := TFieldDB.Create('kur', ftBCD, 0, Self, 'Kur');
end;

procedure TChDovizKuru.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FKurTarihi.QryName,
      FPara.QryName,
      FKur.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TChDovizKuru.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FKurTarihi.QryName,
      FPara.QryName,
      FKur.QryName
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

procedure TChDovizKuru.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FKurTarihi.FieldName,
      FPara.FieldName,
      FKur.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TChDovizKuru.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FKurTarihi.FieldName,
      FPara.FieldName,
      FKur.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TChDovizKuru.Clone: TTable;
begin
  Result := TChDovizKuru.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
