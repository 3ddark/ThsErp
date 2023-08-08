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
  TStkStokGrubu = class(TTable)
  private
    FGrup: TFieldDB;
    FKDVOrani: TFieldDB;
    FSatisHesapKodu: TFieldDB;
    FSatisIadeHesapKodu: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    FIhracatHesapKodu: TFieldDB;
    FIhracatIadeHesapKodu: TFieldDB;
    FHammaddeHesapKodu: TFieldDB;
    FMamulHesapKodu: TFieldDB;
    //vergi oranlarý tablosundan geliyor
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
    FIhracatHesapAdi: TFieldDB;
    FIhracatIadeHesapAdi: TFieldDB;
    FHammaddeHesapAdi: TFieldDB;
    FMamulHesapAdi: TFieldDB;
  protected
    FChHesapKarti: TChHesapKarti;
    FSetChVergiOrani: TSetChVergiOrani;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Grup: TFieldDB read FGrup write FGrup;
    Property KDVOrani: TFieldDB read FKDVOrani write FKDVOrani;
    Property HammaddeKodu: TFieldDB read FHammaddeHesapKodu write FHammaddeHesapKodu;
    Property MamulKodu: TFieldDB read FMamulHesapKodu write FMamulHesapKodu;
    Property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    Property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    Property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    Property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    Property IhracatHesapKodu: TFieldDB read FIhracatHesapKodu write FIhracatHesapKodu;
    Property IhracatIadeHesapKodu: TFieldDB read FIhracatIadeHesapKodu write FIhracatIadeHesapKodu;
    //vergi oranlarý tablosundan geliyor
    Property HammaddeAdi: TFieldDB read FHammaddeHesapAdi write FHammaddeHesapAdi;
    Property MamulAdi: TFieldDB read FMamulHesapAdi write FMamulHesapAdi;
    Property SatisHesapAdi: TFieldDB read FSatisHesapAdi write FSatisHesapAdi;
    Property SatisIadeHesapAdi: TFieldDB read FSatisIadeHesapAdi write FSatisIadeHesapAdi;
    Property AlisHesapAdi: TFieldDB read FAlisHesapAdi write FAlisHesapAdi;
    Property AlisIadeHesapAdi: TFieldDB read FAlisIadeHesapAdi write FAlisIadeHesapAdi;
    Property IhracatHesapAdi: TFieldDB read FIhracatHesapAdi write FIhracatHesapAdi;
    Property IhracatIadeHesapAdi: TFieldDB read FIhracatIadeHesapAdi write FIhracatIadeHesapAdi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants;

constructor TStkStokGrubu.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_gruplar';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FChHesapKarti := TChHesapKarti.Create(ADatabase);
  FSetChVergiOrani := TSetChVergiOrani.Create(ADatabase);

  FGrup := TFieldDB.Create('stok_grubu', ftWideString, '', Self, 'Stok Grubu');
  FKDVOrani := TFieldDB.Create('kdv_orani', ftFloat, 0, Self, 'Kdv Oraný');
  FHammaddeHesapKodu := TFieldDB.Create('hammadde_kodu', ftWideString, '', Self, 'Hammadde Kodu');
  FHammaddeHesapAdi := TFieldDB.Create('hammadde_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Hammadde Ýsim');
  FMamulHesapAdi := TFieldDB.Create('mamul_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Mamül Ýsim');
  FMamulHesapKodu := TFieldDB.Create('mamul_kodu', ftWideString, '', Self, 'Mamül Kodu');
  //vergi oranlarý tablosundan geliyor
  FSatisHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisHesapKodu.FieldName, FSetChVergiOrani.SatisHesapKodu.DataType, FSetChVergiOrani.SatisHesapKodu.Value, Self, FSetChVergiOrani.SatisHesapKodu.Title);
  FSatisHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisHesapAdi.FieldName, FSetChVergiOrani.SatisHesapAdi.DataType, FSetChVergiOrani.SatisHesapAdi.Value, Self, FSetChVergiOrani.SatisHesapAdi.Title);
  FSatisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisIadeHesapKodu.FieldName, FSetChVergiOrani.SatisIadeHesapKodu.DataType, FSetChVergiOrani.SatisIadeHesapKodu.Value, Self, FSetChVergiOrani.SatisIadeHesapKodu.Title);
  FSatisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisIadeHesapAdi.FieldName, FSetChVergiOrani.SatisIadeHesapAdi.DataType, FSetChVergiOrani.SatisIadeHesapAdi.Value, Self, FSetChVergiOrani.SatisIadeHesapAdi.Title);
  FAlisHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisHesapKodu.FieldName, FSetChVergiOrani.AlisHesapKodu.DataType, FSetChVergiOrani.AlisHesapKodu.Value, Self, FSetChVergiOrani.AlisHesapKodu.Title);
  FAlisHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisHesapAdi.FieldName, FSetChVergiOrani.AlisHesapAdi.DataType, FSetChVergiOrani.AlisHesapAdi.Value, Self, FSetChVergiOrani.AlisHesapAdi.Title);
  FAlisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapKodu.FieldName, FSetChVergiOrani.AlisIadeHesapKodu.DataType, FSetChVergiOrani.AlisIadeHesapKodu.Value, Self, FSetChVergiOrani.AlisIadeHesapKodu.Title);
  FAlisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapAdi.FieldName, FSetChVergiOrani.AlisIadeHesapAdi.DataType, FSetChVergiOrani.AlisIadeHesapAdi.Value, Self, FSetChVergiOrani.AlisIadeHesapAdi.Title);
  FAlisHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisHesapKodu.FieldName, FSetChVergiOrani.AlisHesapKodu.DataType, FSetChVergiOrani.AlisHesapKodu.Value, Self, FSetChVergiOrani.AlisHesapKodu.Title);
  FAlisHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisHesapAdi.FieldName, FSetChVergiOrani.AlisHesapAdi.DataType, FSetChVergiOrani.AlisHesapAdi.Value, Self, FSetChVergiOrani.AlisHesapAdi.Title);
  FAlisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapKodu.FieldName, FSetChVergiOrani.AlisIadeHesapKodu.DataType, FSetChVergiOrani.AlisIadeHesapKodu.Value, Self, FSetChVergiOrani.AlisIadeHesapKodu.Title);
  FAlisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisIadeHesapAdi.FieldName, FSetChVergiOrani.AlisIadeHesapAdi.DataType, FSetChVergiOrani.AlisIadeHesapAdi.Value, Self, FSetChVergiOrani.AlisIadeHesapAdi.Title);
end;

destructor TStkStokGrubu.Destroy;
begin
  FChHesapKarti.Free;
  FSetChVergiOrani.Free;
  inherited;
end;

procedure TStkStokGrubu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
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
      FIhracatHesapKodu.QryName,
      FChHesapKarti.HesapKodu.FieldName,
      FMamulHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FMamulHesapAdi.FieldName, 'mm'),
      FHammaddeHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FHammaddeHesapAdi.FieldName, 'hm'),
      FSetChVergiOrani.SatisHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.AlisHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addLeftJoin(FChHesapKarti.HesapKodu.FieldName, FIhracatHesapKodu.FieldName, FChHesapKarti.TableName) +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FMamulHesapKodu.FieldName, 'mm') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FHammaddeHesapKodu.FieldName, 'hm') +
      addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName) +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisHesapKodu.FieldName, 'st') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeHesapKodu.FieldName, 'si') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisHesapKodu.FieldName, 'al') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeHesapKodu.FieldName, 'ai') +
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TStkStokGrubu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      FIhracatHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FIhracatHesapAdi.FieldName, 'ih'),
      FMamulHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FMamulHesapAdi.FieldName, 'mm'),
      FHammaddeHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FHammaddeHesapAdi.FieldName, 'hm'),
      FSetChVergiOrani.SatisHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.AlisHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeHesapKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FIhracatHesapKodu.FieldName, 'ih') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FMamulHesapKodu.FieldName, 'mm') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FHammaddeHesapKodu.FieldName, 'hm') +
      addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName) +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisHesapKodu.FieldName, 'st') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeHesapKodu.FieldName, 'si') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisHesapKodu.FieldName, 'al') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeHesapKodu.FieldName, 'ai') +
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

procedure TStkStokGrubu.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FGrup.FieldName,
      FKDVOrani.FieldName,
      FIhracatHesapKodu.FieldName,
      FHammaddeHesapKodu.FieldName,
      FMamulHesapKodu.FieldName
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

procedure TStkStokGrubu.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FGrup.FieldName,
      FKDVOrani.FieldName,
      FIhracatHesapKodu.FieldName,
      FHammaddeHesapKodu.FieldName,
      FMamulHesapKodu.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TStkStokGrubu.Clone: TTable;
begin
  Result := TStkStokGrubu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
