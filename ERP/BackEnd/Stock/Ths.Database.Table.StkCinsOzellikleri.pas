﻿unit Ths.Database.Table.StkCinsOzellikleri;

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
  TStkCinsOzellik = class(TTable)
  private
    FCins: TFieldDB;
    FAciklama: TFieldDB;
    FS1: TFieldDB;
    FS2: TFieldDB;
    FS3: TFieldDB;
    FS4: TFieldDB;
    FS5: TFieldDB;
    FS6: TFieldDB;
    FS7: TFieldDB;
    FS8: TFieldDB;
    FS9: TFieldDB;
    FS10: TFieldDB;
    FI1: TFieldDB;
    FI2: TFieldDB;
    FI3: TFieldDB;
    FI4: TFieldDB;
    FI5: TFieldDB;
    FD1: TFieldDB;
    FD2: TFieldDB;
    FD3: TFieldDB;
    FD4: TFieldDB;
    FD5: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Cins: TFieldDB read FCins write FCins;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property S1: TFieldDB read FS1 write FS1;
    Property S2: TFieldDB read FS2 write FS2;
    Property S3: TFieldDB read FS3 write FS3;
    Property S4: TFieldDB read FS4 write FS4;
    Property S5: TFieldDB read FS5 write FS5;
    Property S6: TFieldDB read FS6 write FS6;
    Property S7: TFieldDB read FS7 write FS7;
    Property S8: TFieldDB read FS8 write FS8;
    Property S9: TFieldDB read FS9 write FS9;
    Property S10: TFieldDB read FS10 write FS10;
    Property I1: TFieldDB read FI1 write FI1;
    Property I2: TFieldDB read FI2 write FI2;
    Property I3: TFieldDB read FI3 write FI3;
    Property I4: TFieldDB read FI4 write FI4;
    Property I5: TFieldDB read FI5 write FI5;
    Property D1: TFieldDB read FD1 write FD1;
    Property D2: TFieldDB read FD2 write FD2;
    Property D3: TFieldDB read FD3 write FD3;
    Property D4: TFieldDB read FD4 write FD4;
    Property D5: TFieldDB read FD5 write FD5;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkCinsOzellik.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_cins_ozellikleri';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FCins := TFieldDB.Create('cins', ftWideString, '', Self);
  FAciklama := TFieldDB.Create('aciklama', ftWideString, '', Self);
  FS1 := TFieldDB.Create('s1', ftWideString, '', Self);
  FS2 := TFieldDB.Create('s2', ftWideString, '', Self);
  FS3 := TFieldDB.Create('s3', ftWideString, '', Self);
  FS4 := TFieldDB.Create('s4', ftWideString, '', Self);
  FS5 := TFieldDB.Create('s5', ftWideString, '', Self);
  FS6 := TFieldDB.Create('s6', ftWideString, '', Self);
  FS7 := TFieldDB.Create('s7', ftWideString, '', Self);
  FS8 := TFieldDB.Create('s8', ftWideString, '', Self);
  FS9 := TFieldDB.Create('s9', ftWideString, '', Self);
  FS10 := TFieldDB.Create('s10', ftWideString, '', Self);
  FI1 := TFieldDB.Create('i1', ftWideString, '', Self);
  FI2 := TFieldDB.Create('i2', ftWideString, '', Self);
  FI3 := TFieldDB.Create('i3', ftWideString, '', Self);
  FI4 := TFieldDB.Create('i4', ftWideString, '', Self);
  FI5 := TFieldDB.Create('i5', ftWideString, '', Self);
  FD1 := TFieldDB.Create('d1', ftWideString, '', Self);
  FD2 := TFieldDB.Create('d2', ftWideString, '', Self);
  FD3 := TFieldDB.Create('d3', ftWideString, '', Self);
  FD4 := TFieldDB.Create('d4', ftWideString, '', Self);
  FD5 := TFieldDB.Create('d5', ftWideString, '', Self);
end;

function TStkCinsOzellik.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FCins.QryName,
      FAciklama.QryName,
      FS1.QryName,
      FS2.QryName,
      FS3.QryName,
      FS4.QryName,
      FS5.QryName,
      FS6.QryName,
      FS7.QryName,
      FS8.QryName,
      FS9.QryName,
      FS10.QryName,
      FI1.QryName,
      FI2.QryName,
      FI3.QryName,
      FI4.QryName,
      FI5.QryName,
      FD1.QryName,
      FD2.QryName,
      FD3.QryName,
      FD4.QryName,
      FD5.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TStkCinsOzellik.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      FCins.QryName,
      FAciklama.QryName,
      FS1.QryName,
      FS2.QryName,
      FS3.QryName,
      FS4.QryName,
      FS5.QryName,
      FS6.QryName,
      FS7.QryName,
      FS8.QryName,
      FS9.QryName,
      FS10.QryName,
      FI1.QryName,
      FI2.QryName,
      FI3.QryName,
      FI4.QryName,
      FI5.QryName,
      FD1.QryName,
      FD2.QryName,
      FD3.QryName,
      FD4.QryName,
      FD5.QryName
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

procedure TStkCinsOzellik.DoInsert(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FCins.FieldName,
      FAciklama.FieldName,
      FS1.FieldName,
      FS2.FieldName,
      FS3.FieldName,
      FS4.FieldName,
      FS5.FieldName,
      FS6.FieldName,
      FS7.FieldName,
      FS8.FieldName,
      FS9.FieldName,
      FS10.FieldName,
      FI1.FieldName,
      FI2.FieldName,
      FI3.FieldName,
      FI4.FieldName,
      FI5.FieldName,
      FD1.FieldName,
      FD2.FieldName,
      FD3.FieldName,
      FD4.FieldName,
      FD5.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TStkCinsOzellik.DoUpdate(APermissionControl: Boolean=True);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FCins.FieldName,
      FAciklama.FieldName,
      FS1.FieldName,
      FS2.FieldName,
      FS3.FieldName,
      FS4.FieldName,
      FS5.FieldName,
      FS6.FieldName,
      FS7.FieldName,
      FS8.FieldName,
      FS9.FieldName,
      FS10.FieldName,
      FI1.FieldName,
      FI2.FieldName,
      FI3.FieldName,
      FI4.FieldName,
      FI5.FieldName,
      FD1.FieldName,
      FD2.FieldName,
      FD3.FieldName,
      FD4.FieldName,
      FD5.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TStkCinsOzellik.Clone: TTable;
begin
  Result := TStkCinsOzellik.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
