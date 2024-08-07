﻿unit Ths.Database.Table.SysAdresler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SysUlkeler,
  Ths.Database.Table.SysSehirler;

type
  TSysAdres = class(TTable)
  private
    FUlkeKodu: TFieldDB;
    FUlkeAdi: TFieldDB;
    FSehirId: TFieldDB;
    FSehir: TFieldDB;
    FIlce: TFieldDB;
    FMahalle: TFieldDB;
    FSemt: TFieldDB;
    FCadde: TFieldDB;
    FSokak: TFieldDB;
    FBinaAdi: TFieldDB;
    FKapiNo: TFieldDB;
    FPostaKodu: TFieldDB;
    FWeb: TFieldDB;
    FEmail: TFieldDB;
  published
    FSysUlke: TSysUlke;
    FSysSehir: TSysSehir;

    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property UlkeKodu: TFieldDB read FUlkeKodu write FUlkeKodu;
    Property UlkeAdi: TFieldDB read FUlkeAdi write FUlkeAdi;
    Property SehirId: TFieldDB read FSehirId write FSehirId;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property Ilce: TFieldDB read FIlce write FIlce;
    Property Mahalle: TFieldDB read FMahalle write FMahalle;
    Property Semt: TFieldDB read FSemt write FSemt;
    Property Cadde: TFieldDB read FCadde write FCadde;
    Property Sokak: TFieldDB read FSokak write FSokak;
    Property BinaAdi: TFieldDB read FBinaAdi write FBinaAdi;
    Property KapiNo: TFieldDB read FKapiNo write FKapiNo;
    Property PostaKodu: TFieldDB read FPostaKodu write FPostaKodu;
    Property Web: TFieldDB read FWeb write FWeb;
    Property Email: TFieldDB read FEmail write FEmail;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TSysAdres.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_adresler';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FSysUlke := TSysUlke.Create(ADatabase);
  FSysSehir := TSysSehir.Create(ADatabase);

  FUlkeKodu := TFieldDB.Create(FSysSehir.UlkeKodu.FieldName, FSysSehir.UlkeKodu.DataType, FSysSehir.UlkeKodu.Value, Self);
  FUlkeAdi := TFieldDB.Create(FSysSehir.UlkeAdi.FieldName, FSysSehir.UlkeAdi.DataType, FSysSehir.UlkeAdi.Value, Self);
  FSehirId := TFieldDB.Create('sehir_id', ftLargeint, 0, Self);
  FSehir := TFieldDB.Create(FSysSehir.Sehir.FieldName, FSysSehir.Sehir.DataType, FSysSehir.Sehir.Value, Self);
  FIlce := TFieldDB.Create('ilce', ftWideString, '', Self);
  FMahalle := TFieldDB.Create('mahalle', ftWideString, '', Self);
  FSemt := TFieldDB.Create('semt', ftWideString, '', Self);
  FCadde := TFieldDB.Create('cadde', ftWideString, '', Self);
  FSokak := TFieldDB.Create('sokak', ftWideString, '', Self);
  FBinaAdi := TFieldDB.Create('bina_adi', ftWideString, '', Self);
  FKapiNo := TFieldDB.Create('kapi_no', ftWideString, '', Self);
  FPostaKodu := TFieldDB.Create('posta_kodu', ftWideString, '', Self);
  FWeb := TFieldDB.Create('web', ftWideString, '', Self);
  FEmail := TFieldDB.Create('email', ftWideString, '', Self);
end;

destructor TSysAdres.Destroy;
begin
  FSysUlke.Free;
  FSysSehir.Free;
  inherited;
end;

function TSysAdres.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery();
  with LQry do
  try
    Close;
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      addField(FSysUlke.TableName, FSysUlke.UlkeKodu.FieldName, FUlkeKodu.FieldName),
      addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
      FSehirId.QryName,
      addField(FSysSehir.TableName, FSysSehir.Sehir.FieldName, FSehir.FieldName),
      FIlce.QryName,
      FMahalle.QryName,
      FSemt.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FPostaKodu.QryName,
      FWeb.QryName,
      FEmail.QryName
    ], [
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirId.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, FSysSehir.TableName, FSysSehir.UlkeID.FieldName),
      ' WHERE 1=1 ' + AFilter
    ], AAllColumn, AHelper);
    Open;
  finally
    Free;
  end;
end;

procedure TSysAdres.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      addField(FSysUlke.TableName, FSysUlke.UlkeKodu.FieldName, FUlkeKodu.FieldName),
      addField(FSysUlke.TableName, FSysUlke.UlkeAdi.FieldName, FUlkeAdi.FieldName),
      FSehirId.QryName,
      addField(FSysSehir.TableName, FSysSehir.Sehir.FieldName, FSehir.FieldName),
      FIlce.QryName,
      FMahalle.QryName,
      FSemt.QryName,
      FCadde.QryName,
      FSokak.QryName,
      FBinaAdi.QryName,
      FKapiNo.QryName,
      FPostaKodu.QryName,
      FWeb.QryName,
      FEmail.QryName
    ], [
      addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirId.FieldName),
      addJoin(jtLeft, FSysUlke.TableName, FSysUlke.Id.FieldName, FSysSehir.TableName, FSysSehir.UlkeID.FieldName),
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

procedure TSysAdres.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FSehirId.FieldName,
      FIlce.FieldName,
      FMahalle.FieldName,
      FSemt.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FPostaKodu.FieldName,
      FWeb.FieldName,
      FEmail.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSysAdres.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FSehirId.FieldName,
      FIlce.FieldName,
      FMahalle.FieldName,
      FSemt.FieldName,
      FCadde.FieldName,
      FSokak.FieldName,
      FBinaAdi.FieldName,
      FKapiNo.FieldName,
      FPostaKodu.FieldName,
      FWeb.FieldName,
      FEmail.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSysAdres.Clone: TTable;
begin
  Result := TSysAdres.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
