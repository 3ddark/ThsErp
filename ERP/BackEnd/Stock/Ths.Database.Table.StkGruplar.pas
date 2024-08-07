﻿unit Ths.Database.Table.StkGruplar;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetChVergiOranlari,
  Ths.Database.Table.ChHesapKarti;

type
  TStkGruplar = class(TTable)
  private
    FGrup: TFieldDB;
    FKDVOrani: TFieldDB;
    FHammaddeStokHesapKodu: TFieldDB;
    FHammaddeKullanimHesapKodu: TFieldDB;
    FYariMamulHesapKodu: TFieldDB;
    //veri tabanı değil
    FHammaddeStokHesapAdi: TFieldDB;
    FHammaddeKullanimHesapAdi: TFieldDB;
    FYariMamulHesapAdi: TFieldDB;
    //vergi oranları tablosundan geliyor
    FSatisHesapKodu: TFieldDB;
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapKodu: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
  protected
    FCH: TChHesapKarti;
    FSetChVergiOrani: TSetChVergiOrani;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Grup: TFieldDB read FGrup write FGrup;
    Property KDVOrani: TFieldDB read FKDVOrani write FKDVOrani;
    Property HammaddeStokHesapKodu: TFieldDB read FHammaddeStokHesapKodu write FHammaddeStokHesapKodu;
    Property HammaddeKullanimHesapKodu: TFieldDB read FHammaddeKullanimHesapKodu write FHammaddeKullanimHesapKodu;
    Property YariMamulHesapKodu: TFieldDB read FYariMamulHesapKodu write FYariMamulHesapKodu;
    //veri tabanı değil
    Property HammaddeStokHesapAdi: TFieldDB read FHammaddeStokHesapAdi write FHammaddeStokHesapAdi;
    Property HammaddeKullanimHesapAdi: TFieldDB read FHammaddeKullanimHesapAdi write FHammaddeKullanimHesapAdi;
    Property YariMamulHesapAdi: TFieldDB read FYariMamulHesapAdi write FYariMamulHesapAdi;
    //vergi oranları tablosundan geliyor
    Property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    Property SatisHesapAdi: TFieldDB read FSatisHesapAdi write FSatisHesapAdi;
    Property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    Property SatisIadeHesapAdi: TFieldDB read FSatisIadeHesapAdi write FSatisIadeHesapAdi;
    Property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    Property AlisHesapAdi: TFieldDB read FAlisHesapAdi write FAlisHesapAdi;
    Property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    Property AlisIadeHesapAdi: TFieldDB read FAlisIadeHesapAdi write FAlisIadeHesapAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkGruplar.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_gruplar';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FCH := TChHesapKarti.Create(ADatabase);
  FSetChVergiOrani := TSetChVergiOrani.Create(ADatabase);

  FGrup := TFieldDB.Create('grup', ftWideString, '', Self);
  FKDVOrani := TFieldDB.Create('kdv_orani', ftFloat, 0, Self);
  FHammaddeStokHesapKodu := TFieldDB.Create('hammadde_stok_hesap_kodu', ftWideString, '', Self);
  FHammaddeStokHesapAdi := TFieldDB.Create('hammadde_stok_hesap_adi', FCH.HesapIsmi.DataType, '', Self);
  FHammaddeKullanimHesapKodu := TFieldDB.Create('hammadde_kullanim_hesap_kodu', ftWideString, '', Self);
  FHammaddeKullanimHesapAdi := TFieldDB.Create('hammadde_kullanim_hesap_adi', FCH.HesapIsmi.DataType, '', Self);
  FYariMamulHesapKodu := TFieldDB.Create('yari_mamul_hesap_kodu', ftWideString, '', Self);
  FYariMamulHesapAdi := TFieldDB.Create('yari_mamul_hesap_adi', FCH.HesapIsmi.DataType, '', Self);
  //vergi oranları tablosundan geliyor
  FSatisHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisHesapKodu.FieldName, FSetChVergiOrani.SatisHesapKodu.DataType, FSetChVergiOrani.SatisHesapKodu.Value, Self);
  FSatisHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisHesapAdi.FieldName, FSetChVergiOrani.SatisHesapAdi.DataType, FSetChVergiOrani.SatisHesapAdi.Value, Self);
  FSatisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisIadeHesapKodu.FieldName, FSetChVergiOrani.SatisIadeHesapKodu.DataType, FSetChVergiOrani.SatisIadeHesapKodu.Value, Self);
  FSatisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisIadeHesapAdi.FieldName, FSetChVergiOrani.SatisIadeHesapAdi.DataType, FSetChVergiOrani.SatisIadeHesapAdi.Value, Self);
  FAlisHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisHesapKodu.FieldName, FSetChVergiOrani.AlisHesapKodu.DataType, FSetChVergiOrani.AlisHesapKodu.Value, Self);
  FAlisHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisHesapAdi.FieldName, FSetChVergiOrani.AlisHesapAdi.DataType, FSetChVergiOrani.AlisHesapAdi.Value, Self);
  FAlisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapKodu.FieldName, FSetChVergiOrani.AlisIadeHesapKodu.DataType, FSetChVergiOrani.AlisIadeHesapKodu.Value, Self);
  FAlisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapAdi.FieldName, FSetChVergiOrani.AlisIadeHesapAdi.DataType, FSetChVergiOrani.AlisIadeHesapAdi.Value, Self);
end;

destructor TStkGruplar.Destroy;
begin
  FCH.Free;
  FSetChVergiOrani.Free;
  inherited;
end;

function TStkGruplar.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Id.QryName,
      FGrup.QryName,
      FKDVOrani.QryName,
      FHammaddeStokHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FHammaddeStokHesapAdi.FieldName, 'hm'),
      FHammaddeKullanimHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FHammaddeKullanimHesapAdi.FieldName, 'mm'),
      FYariMamulHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FYariMamulHesapAdi.FieldName, 'ym'),
      FSetChVergiOrani.SatisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.AlisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FHammaddeStokHesapKodu.FieldName, 'hm'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FHammaddeKullanimHesapKodu.FieldName, 'mm'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FYariMamulHesapKodu.FieldName, 'ym'),
      addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TStkGruplar.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FGrup.QryName,
      FKDVOrani.QryName,
      FHammaddeStokHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FHammaddeStokHesapAdi.FieldName, 'hm'),
      FHammaddeKullanimHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FHammaddeKullanimHesapAdi.FieldName, 'mm'),
      FYariMamulHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FYariMamulHesapAdi.FieldName, 'ym'),
      FSetChVergiOrani.SatisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.AlisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FHammaddeStokHesapKodu.FieldName, 'hm'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FHammaddeKullanimHesapKodu.FieldName, 'mm'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FYariMamulHesapKodu.FieldName, 'ym'),
      addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
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

procedure TStkGruplar.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FGrup.FieldName,
      FKDVOrani.FieldName,
      FHammaddeStokHesapKodu.FieldName,
      FHammaddeKullanimHesapKodu.FieldName,
      FYariMamulHesapKodu.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TStkGruplar.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FGrup.FieldName,
      FKDVOrani.FieldName,
      FHammaddeStokHesapKodu.FieldName,
      FHammaddeKullanimHesapKodu.FieldName,
      FYariMamulHesapKodu.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TStkGruplar.Clone: TTable;
begin
  Result := TStkGruplar.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
