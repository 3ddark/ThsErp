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
    FHammaddeKodu: TFieldDB;
    FMamulKodu: TFieldDB;
    FSatisHesapKodu: TFieldDB;
    FSatisIadeHesapKodu: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    FIhracatHesapKodu: TFieldDB;
    FIhracatIadeHesapKodu: TFieldDB;
    //vergi oranlarý tablosundan geliyor
    FHammaddeAdi: TFieldDB;
    FMamulAdi: TFieldDB;
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
    FIhracatHesapAdi: TFieldDB;
    FIhracatIadeHesapAdi: TFieldDB;
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
    Property HammaddeKodu: TFieldDB read FHammaddeKodu write FHammaddeKodu;
    Property MamulKodu: TFieldDB read FMamulKodu write FMamulKodu;
    Property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    Property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    Property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    Property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    Property IhracatHesapKodu: TFieldDB read FIhracatHesapKodu write FIhracatHesapKodu;
    Property IhracatIadeHesapKodu: TFieldDB read FIhracatIadeHesapKodu write FIhracatIadeHesapKodu;
    //vergi oranlarý tablosundan geliyor
    Property HammaddeAdi: TFieldDB read FHammaddeAdi write FHammaddeAdi;
    Property MamulAdi: TFieldDB read FMamulAdi write FMamulAdi;
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
  FHammaddeKodu := TFieldDB.Create('hammadde_kodu', ftWideString, '', Self, 'Hammadde Kodu');
  FMamulKodu := TFieldDB.Create('mamul_kodu', ftWideString, '', Self, 'Mamül Kodu');
  FIhracatHesapKodu := TFieldDB.Create('ihracat_kodu', ftWideString, '', Self, 'Ýhracat Kodu');
  FIhracatHesapAdi := TFieldDB.Create('ihracat_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Ýhracat Ýsim');
  FHammaddeAdi := TFieldDB.Create('hammadde_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Hammadde Ýsim');
  FMamulAdi := TFieldDB.Create('mamul_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Mamül Ýsim');
  //vergi oranlarý tablosundan geliyor
  FSatisHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisKodu.FieldName, FSetChVergiOrani.SatisKodu.DataType, FSetChVergiOrani.SatisKodu.Value, Self, FSetChVergiOrani.SatisKodu.Title);
  FSatisHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisAdi.FieldName, FSetChVergiOrani.SatisAdi.DataType, FSetChVergiOrani.SatisAdi.Value, Self, FSetChVergiOrani.SatisAdi.Title);
  FSatisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.SatisIadeKodu.FieldName, FSetChVergiOrani.SatisIadeKodu.DataType, FSetChVergiOrani.SatisIadeKodu.Value, Self, FSetChVergiOrani.SatisIadeKodu.Title);
  FSatisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.SatisIadeAdi.FieldName, FSetChVergiOrani.SatisIadeAdi.DataType, FSetChVergiOrani.SatisIadeAdi.Value, Self, FSetChVergiOrani.SatisIadeAdi.Title);
  FAlisHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisKodu.FieldName, FSetChVergiOrani.AlisKodu.DataType, FSetChVergiOrani.AlisKodu.Value, Self, FSetChVergiOrani.AlisKodu.Title);
  FAlisHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisAdi.FieldName, FSetChVergiOrani.AlisAdi.DataType, FSetChVergiOrani.AlisAdi.Value, Self, FSetChVergiOrani.AlisAdi.Title);
  FAlisIadeHesapKodu := TFieldDB.Create(FSetChVergiOrani.AlisIadeKodu.FieldName, FSetChVergiOrani.AlisIadeKodu.DataType, FSetChVergiOrani.AlisIadeKodu.Value, Self, FSetChVergiOrani.AlisIadeKodu.Title);
  FAlisIadeHesapAdi := TFieldDB.Create(FSetChVergiOrani.AlisIadeAdi.FieldName, FSetChVergiOrani.AlisIadeAdi.DataType, FSetChVergiOrani.AlisIadeAdi.Value, Self, FSetChVergiOrani.AlisIadeAdi.Title);
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
      FMamulKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FMamulAdi.FieldName, 'mm'),
      FHammaddeKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FHammaddeAdi.FieldName, 'hm'),
      FSetChVergiOrani.SatisKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.AlisKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addLeftJoin(FChHesapKarti.HesapKodu.FieldName, FIhracatHesapKodu.FieldName, FChHesapKarti.TableName) +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FMamulKodu.FieldName, 'mm') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FHammaddeKodu.FieldName, 'hm') +
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
      FMamulKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FMamulAdi.FieldName, 'mm'),
      FHammaddeKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FHammaddeAdi.FieldName, 'hm'),
      FSetChVergiOrani.SatisKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSetChVergiOrani.SatisIadeKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FSetChVergiOrani.AlisKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FSetChVergiOrani.AlisIadeKodu.QryName,
      addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FIhracatHesapKodu.FieldName, 'ih') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FMamulKodu.FieldName, 'mm') +
      addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FHammaddeKodu.FieldName, 'hm') +
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
      FHammaddeKodu.FieldName,
      FMamulKodu.FieldName
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
      FHammaddeKodu.FieldName,
      FMamulKodu.FieldName
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
