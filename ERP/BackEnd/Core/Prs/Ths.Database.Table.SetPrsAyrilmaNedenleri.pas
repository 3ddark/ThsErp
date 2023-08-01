unit Ths.Database.Table.SetPrsAyrilmaNedenleri;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSetEmpLeavingReason = class(TTable)
  private
    FLeavingReason: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property LeavingReason: TFieldDB read FLeavingReason write FLeavingReason;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEmpLeavingReason.Create(ADatabase: TDatabase);
begin
  TableName := 'set_prs_ayrilma_nedenleri';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FLeavingReason := TFieldDB.Create('ayrilma_nedeni', ftWideString, '', Self, 'Ayr�lma Nedeni');
end;

procedure TSetEmpLeavingReason.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FLeavingReason.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetEmpLeavingReason.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FLeavingReason.QryName
    ], [
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

procedure TSetEmpLeavingReason.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FLeavingReason.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Id.FieldName).AsInteger
    else  AID := 0;
  finally
    Free;
  end;
end;

procedure TSetEmpLeavingReason.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FLeavingReason.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetEmpLeavingReason.Clone: TTable;
begin
  Result := TSetEmpLeavingReason.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
