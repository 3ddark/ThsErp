unit Ths.Database.Table.StkGruplar;

interface

{$I Ths.inc}

uses
  SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.SetChVergiOrani,
  Ths.Database.Table.ChHesapKarti;

type
  TStkGruplar = class(TTable)
  private
    FGrup: TFieldDB;
    FKDVOrani: TFieldDB;
    FHammaddeHesapKodu: TFieldDB;
    FMamulHesapKodu: TFieldDB;
    //veri tabaný deðil
    FHammaddeHesapAdi: TFieldDB;
    FMamulHesapAdi: TFieldDB;
    //vergi oranlarý tablosundan geliyor
    FSatisHesapKodu: TFieldDB;
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapKodu: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FIhracatHesapKodu: TFieldDB;
    FIhracatHesapAdi: TFieldDB;
    FIhracatIadeHesapKodu: TFieldDB;
    FIhracatIadeHesapAdi: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
    FIthalatHesapKodu: TFieldDB;
    FIthalatHesapAdi: TFieldDB;
    FIthalatIadeHesapKodu: TFieldDB;
    FIthalatIadeHesapAdi: TFieldDB;
  protected
    FCH: TChHesapKarti;
    FSetChVergiOrani: TSetChVergiOrani;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Grup: TFieldDB read FGrup write FGrup;
    Property KDVOrani: TFieldDB read FKDVOrani write FKDVOrani;
    Property HammaddeHesapKodu: TFieldDB read FHammaddeHesapKodu write FHammaddeHesapKodu;
    Property MamulHesapKodu: TFieldDB read FMamulHesapKodu write FMamulHesapKodu;
    //veri tabaný deðil
    Property HammaddeHesapAdi: TFieldDB read FHammaddeHesapAdi write FHammaddeHesapAdi;
    Property MamulHesapAdi: TFieldDB read FMamulHesapAdi write FMamulHesapAdi;
    //vergi oranlarý tablosundan geliyor
    Property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    Property SatisHesapAdi: TFieldDB read FSatisHesapAdi write FSatisHesapAdi;
    Property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    Property SatisIadeHesapAdi: TFieldDB read FSatisIadeHesapAdi write FSatisIadeHesapAdi;
    Property IhracatHesapKodu: TFieldDB read FIhracatHesapKodu write FIhracatHesapKodu;
    Property IhracatHesapAdi: TFieldDB read FIhracatHesapAdi write FIhracatHesapAdi;
    Property IhracatIadeHesapKodu: TFieldDB read FIhracatIadeHesapKodu write FIhracatIadeHesapKodu;
    Property IhracatIadeHesapAdi: TFieldDB read FIhracatIadeHesapAdi write FIhracatIadeHesapAdi;
    Property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    Property AlisHesapAdi: TFieldDB read FAlisHesapAdi write FAlisHesapAdi;
    Property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    Property AlisIadeHesapAdi: TFieldDB read FAlisIadeHesapAdi write FAlisIadeHesapAdi;
    Property IthalatHesapKodu: TFieldDB read FIthalatHesapKodu write FIthalatHesapKodu;
    Property IthalatIhracHesapAdi: TFieldDB read FIthalatHesapAdi write FIthalatHesapAdi;
    Property IthalatIadeHesapKodu: TFieldDB read FIthalatIadeHesapKodu write FIthalatIadeHesapKodu;
    Property IthalatIadeHesapAdi: TFieldDB read FIthalatIadeHesapAdi write FIthalatIadeHesapAdi;
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

  FGrup := TFieldDB.Create('grup', ftWideString, '', Self, 'Grup');
  FKDVOrani := TFieldDB.Create('kdv_orani', ftFloat, 0, Self, 'Kdv Oraný');
  FHammaddeHesapKodu := TFieldDB.Create('hammadde_hesap_kodu', ftWideString, '', Self, 'Hammadde');
  FHammaddeHesapAdi := TFieldDB.Create('hammadde_hesap_adi', FCH.HesapIsmi.DataType, '', Self, 'Hammadde Hesap');
  FMamulHesapKodu := TFieldDB.Create('mamul_hesap_kodu', ftWideString, '', Self, 'Mamül');
  FMamulHesapAdi := TFieldDB.Create('mamul_hesap_adi', FCH.HesapIsmi.DataType, '', Self, 'Mamül Hesap');
  //vergi oranlarý tablosundan geliyor
  FSatisHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisHesapKodu.FieldName, FSetChVergiOrani.SatisHesapKodu.DataType, FSetChVergiOrani.SatisHesapKodu.Value, Self, FSetChVergiOrani.SatisHesapKodu.Title);
  FSatisHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisHesapAdi.FieldName, FSetChVergiOrani.SatisHesapAdi.DataType, FSetChVergiOrani.SatisHesapAdi.Value, Self, FSetChVergiOrani.SatisHesapAdi.Title);
  FSatisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisIadeHesapKodu.FieldName, FSetChVergiOrani.SatisIadeHesapKodu.DataType, FSetChVergiOrani.SatisIadeHesapKodu.Value, Self, FSetChVergiOrani.SatisIadeHesapKodu.Title);
  FSatisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisIadeHesapAdi.FieldName, FSetChVergiOrani.SatisIadeHesapAdi.DataType, FSetChVergiOrani.SatisIadeHesapAdi.Value, Self, FSetChVergiOrani.SatisIadeHesapAdi.Title);
  FIhracatHesapKodu := TFieldDB.Create(FSetChVergiOrani.IhracatHesapKodu.FieldName, FSetChVergiOrani.IhracatHesapKodu.DataType, FSetChVergiOrani.AlisHesapKodu.Value, Self, FSetChVergiOrani.AlisHesapKodu.Title);
  FIhracatHesapAdi := TFieldDB.Create(FSetChVergiOrani.IhracatHesapAdi.FieldName, FSetChVergiOrani.IhracatHesapAdi.DataType, FSetChVergiOrani.AlisHesapAdi.Value, Self, FSetChVergiOrani.AlisHesapAdi.Title);
  FIhracatIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.IhracatIadeHesapKodu.FieldName, FSetChVergiOrani.IhracatIadeHesapKodu.DataType, FSetChVergiOrani.AlisIadeHesapKodu.Value, Self, FSetChVergiOrani.AlisIadeHesapKodu.Title);
  FIhracatIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.IhracatIadeHesapAdi.FieldName, FSetChVergiOrani.IhracatIadeHesapAdi.DataType, FSetChVergiOrani.AlisIadeHesapAdi.Value, Self, FSetChVergiOrani.AlisIadeHesapAdi.Title);
  FAlisHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisHesapKodu.FieldName, FSetChVergiOrani.AlisHesapKodu.DataType, FSetChVergiOrani.AlisHesapKodu.Value, Self, FSetChVergiOrani.AlisHesapKodu.Title);
  FAlisHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisHesapAdi.FieldName, FSetChVergiOrani.AlisHesapAdi.DataType, FSetChVergiOrani.AlisHesapAdi.Value, Self, FSetChVergiOrani.AlisHesapAdi.Title);
  FAlisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapKodu.FieldName, FSetChVergiOrani.AlisIadeHesapKodu.DataType, FSetChVergiOrani.AlisIadeHesapKodu.Value, Self, FSetChVergiOrani.AlisIadeHesapKodu.Title);
  FAlisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapAdi.FieldName, FSetChVergiOrani.AlisIadeHesapAdi.DataType, FSetChVergiOrani.AlisIadeHesapAdi.Value, Self, FSetChVergiOrani.AlisIadeHesapAdi.Title);
  FIthalatHesapKodu := TFieldDB.Create(FSetChVergiOrani.IthalatHesapKodu.FieldName, FSetChVergiOrani.IthalatHesapKodu.DataType, FSetChVergiOrani.AlisHesapKodu.Value, Self, FSetChVergiOrani.AlisHesapKodu.Title);
  FIthalatHesapAdi := TFieldDB.Create(FSetChVergiOrani.IthalatHesapAdi.FieldName, FSetChVergiOrani.IthalatHesapAdi.DataType, FSetChVergiOrani.AlisHesapAdi.Value, Self, FSetChVergiOrani.AlisHesapAdi.Title);
  FIthalatIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.IthalatIadeHesapKodu.FieldName, FSetChVergiOrani.IthalatIadeHesapKodu.DataType, FSetChVergiOrani.AlisIadeHesapKodu.Value, Self, FSetChVergiOrani.AlisIadeHesapKodu.Title);
  FIthalatIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.IthalatIadeHesapAdi.FieldName, FSetChVergiOrani.IthalatIadeHesapAdi.DataType, FSetChVergiOrani.AlisIadeHesapAdi.Value, Self, FSetChVergiOrani.AlisIadeHesapAdi.Title);
end;

destructor TStkGruplar.Destroy;
begin
  FCH.Free;
  FSetChVergiOrani.Free;
  inherited;
end;

procedure TStkGruplar.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FGrup.QryName,
      FKDVOrani.QryName,
      FHammaddeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FHammaddeHesapAdi.FieldName, 'hm'),
      FMamulHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FMamulHesapAdi.FieldName, 'mm'),
      FSetChVergiOrani.SatisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.IhracatHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIhracatHesapAdi.FieldName, 'ih'),
      FSetChVergiOrani.IhracatIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIhracatIadeHesapAdi.FieldName, 'ii'),
      FSetChVergiOrani.AlisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai'),
      FSetChVergiOrani.IthalatHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIthalatHesapAdi.FieldName, 'it'),
      FSetChVergiOrani.IthalatIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIthalatIadeHesapAdi.FieldName, 'ti')
    ], [
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FHammaddeHesapKodu.FieldName, 'hm'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FMamulHesapKodu.FieldName, 'mm'),
      addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIhracatHesapKodu.FieldName, 'ih'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIhracatIadeHesapKodu.FieldName, 'ii'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIthalatHesapKodu.FieldName, 'it'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIthalatIadeHesapKodu.FieldName, 'ti'),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TStkGruplar.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FGrup.QryName,
      FKDVOrani.QryName,
      FHammaddeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FHammaddeHesapAdi.FieldName, 'hm'),
      FMamulHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FMamulHesapAdi.FieldName, 'mm'),
      FSetChVergiOrani.SatisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.IhracatHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIhracatHesapAdi.FieldName, 'ih'),
      FSetChVergiOrani.IhracatIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIhracatIadeHesapAdi.FieldName, 'ii'),
      FSetChVergiOrani.AlisHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai'),
      FSetChVergiOrani.IthalatHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIthalatHesapAdi.FieldName, 'it'),
      FSetChVergiOrani.IthalatIadeHesapKodu.QryName,
      addfield(FCH.TableName, FCH.HesapIsmi.FieldName, FIthalatIadeHesapAdi.FieldName, 'ti')
    ], [
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FHammaddeHesapKodu.FieldName, 'hm'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, TableName, FMamulHesapKodu.FieldName, 'mm'),
      addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIhracatHesapKodu.FieldName, 'ih'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIhracatIadeHesapKodu.FieldName, 'ii'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIthalatHesapKodu.FieldName, 'it'),
      addJoin(jtLeft, FCH.TableName, FCH.HesapKodu.FieldName, FSetChVergiOrani.TableName, FIthalatIadeHesapKodu.FieldName, 'ti'),
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

procedure TStkGruplar.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FGrup.FieldName,
      FKDVOrani.FieldName,
      FHammaddeHesapKodu.FieldName,
      FMamulHesapKodu.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TStkGruplar.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FGrup.FieldName,
      FKDVOrani.FieldName,
      FHammaddeHesapKodu.FieldName,
      FMamulHesapKodu.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TStkGruplar.Clone: TTable;
begin
  Result := TStkGruplar.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
