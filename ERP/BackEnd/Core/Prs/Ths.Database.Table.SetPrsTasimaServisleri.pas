unit Ths.Database.Table.SetPrsTasimaServisleri;

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
  TSetPrsTasimaServisi = class(TTable)
  private
    FAracNo: TFieldDB;
    FAracAdi: TFieldDB;
    FRota: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property AracNo: TFieldDB read FAracNo write FAracNo;
    Property AracAdi: TFieldDB read FAracAdi write FAracAdi;
    property Rota: TFieldDB read FRota write FRota;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetPrsTasimaServisi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_prs_tasima_servisleri';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FAracNo := TFieldDB.Create('arac_no', ftInteger, 0, Self, 'Ara� No');
  FAracAdi := TFieldDB.Create('arac_adi', ftWideString, '', Self, 'Ara� Ad�');
  FRota := TFieldDB.Create('rota', ftArray, '', Self, 'Rota');
end;

procedure TSetPrsTasimaServisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FAracNo.QryName,
      FAracAdi.QryName,
      FRota.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetPrsTasimaServisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FAracNo.QryName,
      FAracAdi.QryName,
      FRota.QryName
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

procedure TSetPrsTasimaServisi.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FAracNo.FieldName,
      FAracAdi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetPrsTasimaServisi.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FAracNo.FieldName,
      FAracAdi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetPrsTasimaServisi.Clone: TTable;
begin
  Result := TSetPrsTasimaServisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
