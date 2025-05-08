unit Ths.Database.Table.SetSatTeklifDurum;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table;

type
  TSetSatTeklifDurum = class(TTable)
  private
    FTeklifDurum: TFieldDB;
    FAciklama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TeklifDurum: TFieldDB read FTeklifDurum write FTeklifDurum;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetSatTeklifDurum.Create(ADatabase: TDatabase);
begin
  TableName := 'set_sls_order_status';
  TableSourceCode := MODULE_TSIF_AYAR;
  inherited Create(ADatabase);

  FTeklifDurum := TFieldDB.Create('teklif_durum', ftString, '', Self);
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self);
end;

function TSetSatTeklifDurum.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FTeklifDurum.QryName,
      FAciklama.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSetSatTeklifDurum.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FTeklifDurum.QryName,
      FAciklama.QryName
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

procedure TSetSatTeklifDurum.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FTeklifDurum.FieldName,
      FAciklama.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetSatTeklifDurum.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FTeklifDurum.FieldName,
      FAciklama.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetSatTeklifDurum.Clone: TTable;
begin
  Result := TSetSatTeklifDurum.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
