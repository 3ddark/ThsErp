﻿unit Ths.Database.Table.SetEinvOdemeSekli;

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
  TSetEinvOdemeSekli = class(TTable)
  private
    FOdemeSekli: TFieldDB;
    FKod: TFieldDB;
    FAciklama: TFieldDB;
    FIsEFatura: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property OdemeSekli: TFieldDB read FOdemeSekli write FOdemeSekli;
    Property Kod: TFieldDB read FKod write FKod;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsEFatura: TFieldDB read FIsEFatura write FIsEFatura;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSetEinvOdemeSekli.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_odeme_sekilleri';
  TableSourceCode := MODULE_MHS_AYAR;
  inherited Create(ADatabase);

  FOdemeSekli := TFieldDB.Create('odeme_sekli', ftWideString, '', Self);
  FKod := TFieldDB.Create('kod', ftWideString, '', Self);
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self);
  FIsEFatura := TFieldDB.Create('is_efatura', ftBoolean, False, Self);
end;

function TSetEinvOdemeSekli.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FOdemeSekli.QryName,
      FKod.QryName,
      FAciklama.QryName,
      FIsEfatura.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSetEinvOdemeSekli.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FOdemeSekli.QryName,
      FKod.QryName,
      FAciklama.QryName,
      FIsEfatura.QryName
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

procedure TSetEinvOdemeSekli.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FOdemeSekli.FieldName,
      FKod.FieldName,
      FAciklama.FieldName,
      FIsEFatura.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetEinvOdemeSekli.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FOdemeSekli.FieldName,
      FKod.FieldName,
      FAciklama.FieldName,
      FIsEFatura.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetEinvOdemeSekli.Clone: TTable;
begin
  Result := TSetEinvOdemeSekli.Create(Database);
  CloneClassContent(Self, Result);
end;

end.

