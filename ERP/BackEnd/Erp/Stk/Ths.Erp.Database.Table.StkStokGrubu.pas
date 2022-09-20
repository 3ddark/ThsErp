unit Ths.Erp.Database.Table.StkStokGrubu;

interface

{$I ThsERP.inc}

uses
  SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetChVergiOrani,
  Ths.Erp.Database.Table.ChHesapKarti;

type
  TStkStokGrubu = class(TTable)
  private
    FStokGrubu: TFieldDB;
    FKDVOrani: TFieldDB;
    FIhracatKodu: TFieldDB;
    FIhracatAdi: TFieldDB;
    FHammaddeKodu: TFieldDB;
    FHammaddeAdi: TFieldDB;
    FMamulKodu: TFieldDB;
    FMamulAdi: TFieldDB;
    //vergi oranlarý tablosundan geliyor
    FSatisKodu: TFieldDB;
    FSatisAdi: TFieldDB;
    FSatisIadeKodu: TFieldDB;
    FSatisIadeAdi: TFieldDB;
    FAlisKodu: TFieldDB;
    FAlisAdi: TFieldDB;
    FAlisIadeKodu: TFieldDB;
    FAlisIadeAdi: TFieldDB;
  protected
    FChHesapKarti: TChHesapKarti;
    FSetChVergiOrani: TSetChVergiOrani;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property StokGrubu: TFieldDB read FStokGrubu write FStokGrubu;
    Property KDVOrani: TFieldDB read FKDVOrani write FKDVOrani;
    Property IhracatKodu: TFieldDB read FIhracatKodu write FIhracatKodu;
    Property IhracatAdi: TFieldDB read FIhracatAdi write FIhracatAdi;
    Property HammaddeKodu: TFieldDB read FHammaddeKodu write FHammaddeKodu;
    Property HammaddeAdi: TFieldDB read FHammaddeAdi write FHammaddeAdi;
    Property MamulKodu: TFieldDB read FMamulKodu write FMamulKodu;
    Property MamulAdi: TFieldDB read FMamulAdi write FMamulAdi;
    //vergi oranlarý tablosundan geliyor
    Property SatisKodu: TFieldDB read FSatisKodu write FSatisKodu;
    Property SatisAdi: TFieldDB read FSatisAdi write FSatisAdi;
    Property SatisIadeKodu: TFieldDB read FSatisIadeKodu write FSatisIadeKodu;
    Property SatisIadeAdi: TFieldDB read FSatisIadeAdi write FSatisIadeAdi;
    Property AlisKodu: TFieldDB read FAlisKodu write FAlisKodu;
    Property AlisAdi: TFieldDB read FAlisAdi write FAlisAdi;
    Property AlisIadeKodu: TFieldDB read FAlisIadeKodu write FAlisIadeKodu;
    Property AlisIadeAdi: TFieldDB read FAlisIadeAdi write FAlisIadeAdi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TStkStokGrubu.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_stok_grubu';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FChHesapKarti := TChHesapKarti.Create(ADatabase);
  FSetChVergiOrani := TSetChVergiOrani.Create(ADatabase);

  FStokGrubu := TFieldDB.Create('stok_grubu', ftWideString, '', Self, 'Stok Grubu');
  FKDVOrani := TFieldDB.Create('kdv_orani', ftFloat, 0, Self, 'Kdv Oraný');
  FIhracatKodu := TFieldDB.Create('ihracat_kodu', ftWideString, '', Self, 'Ýhracat Kodu');
  FIhracatAdi := TFieldDB.Create('ihracat_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Ýhracat Ýsim');
  FHammaddeKodu := TFieldDB.Create('hammadde_kodu', ftWideString, '', Self, 'Hammadde Kodu');
  FHammaddeAdi := TFieldDB.Create('hammadde_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Hammadde Ýsim');
  FMamulKodu := TFieldDB.Create('mamul_kodu', ftWideString, '', Self, 'Mamül Kodu');
  FMamulAdi := TFieldDB.Create('mamul_adi', FChHesapKarti.HesapIsmi.DataType, '', Self, 'Mamül Ýsim');
  //vergi oranlarý tablosundan geliyor
  FSatisKodu := TFieldDB.Create(FSetChVergiOrani.SatisKodu.FieldName, FSetChVergiOrani.SatisKodu.DataType, FSetChVergiOrani.SatisKodu.Value, Self, FSetChVergiOrani.SatisKodu.Title);
  FSatisAdi := TFieldDB.Create(FSetChVergiOrani.SatisAdi.FieldName, FSetChVergiOrani.SatisAdi.DataType, FSetChVergiOrani.SatisAdi.Value, Self, FSetChVergiOrani.SatisAdi.Title);
  FSatisIadeKodu := TFieldDB.Create(FSetChVergiOrani.SatisIadeKodu.FieldName, FSetChVergiOrani.SatisIadeKodu.DataType, FSetChVergiOrani.SatisIadeKodu.Value, Self, FSetChVergiOrani.SatisIadeKodu.Title);
  FSatisIadeAdi := TFieldDB.Create(FSetChVergiOrani.SatisIadeAdi.FieldName, FSetChVergiOrani.SatisIadeAdi.DataType, FSetChVergiOrani.SatisIadeAdi.Value, Self, FSetChVergiOrani.SatisIadeAdi.Title);
  FAlisKodu := TFieldDB.Create(FSetChVergiOrani.AlisKodu.FieldName, FSetChVergiOrani.AlisKodu.DataType, FSetChVergiOrani.AlisKodu.Value, Self, FSetChVergiOrani.AlisKodu.Title);
  FAlisAdi := TFieldDB.Create(FSetChVergiOrani.AlisAdi.FieldName, FSetChVergiOrani.AlisAdi.DataType, FSetChVergiOrani.AlisAdi.Value, Self, FSetChVergiOrani.AlisAdi.Title);
  FAlisIadeKodu := TFieldDB.Create(FSetChVergiOrani.AlisIadeKodu.FieldName, FSetChVergiOrani.AlisIadeKodu.DataType, FSetChVergiOrani.AlisIadeKodu.Value, Self, FSetChVergiOrani.AlisIadeKodu.Title);
  FAlisIadeAdi := TFieldDB.Create(FSetChVergiOrani.AlisIadeAdi.FieldName, FSetChVergiOrani.AlisIadeAdi.DataType, FSetChVergiOrani.AlisIadeAdi.Value, Self, FSetChVergiOrani.AlisIadeAdi.Title);
end;

destructor TStkStokGrubu.Destroy;
begin
  FChHesapKarti.Free;
  FSetChVergiOrani.Free;
  inherited;
end;

procedure TStkStokGrubu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FStokGrubu.QryName,
        FKDVOrani.QryName,
        FIhracatKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FIhracatAdi.FieldName, 'ih'),
        FMamulKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FMamulAdi.FieldName, 'mm'),
        FHammaddeKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FHammaddeAdi.FieldName, 'hm'),
        FSetChVergiOrani.SatisKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisAdi.FieldName, 'st'),
        FSetChVergiOrani.SatisIadeKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisIadeAdi.FieldName, 'si'),
        FSetChVergiOrani.AlisKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisAdi.FieldName, 'al'),
        FSetChVergiOrani.AlisIadeKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisIadeAdi.FieldName, 'ai')
      ], [
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FIhracatKodu.FieldName, 'ih') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FMamulKodu.FieldName, 'mm') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FHammaddeKodu.FieldName, 'hm') +
        addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName) +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisKodu.FieldName, 'st') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeKodu.FieldName, 'si') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisKodu.FieldName, 'al') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeKodu.FieldName, 'ai') +
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TStkStokGrubu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Id.QryName,
        FStokGrubu.QryName,
        FKDVOrani.QryName,
        FIhracatKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FIhracatAdi.FieldName, 'ih'),
        FMamulKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FMamulAdi.FieldName, 'mm'),
        FHammaddeKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FHammaddeAdi.FieldName, 'hm'),
        FSetChVergiOrani.SatisKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisAdi.FieldName, 'st'),
        FSetChVergiOrani.SatisIadeKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FSatisIadeAdi.FieldName, 'si'),
        FSetChVergiOrani.AlisKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisAdi.FieldName, 'al'),
        FSetChVergiOrani.AlisIadeKodu.QryName,
        addfield(FChHesapKarti.TableName, FChHesapKarti.HesapIsmi.FieldName, FAlisIadeAdi.FieldName, 'ai')
      ], [
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FIhracatKodu.FieldName, 'ih') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FMamulKodu.FieldName, 'mm') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, TableName, FHammaddeKodu.FieldName, 'hm') +
        addJoin(jtLeft, FSetChVergiOrani.TableName, FSetChVergiOrani.VergiOrani.FieldName, TableName, FKDVOrani.FieldName) +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisKodu.FieldName, 'st') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FSatisIadeKodu.FieldName, 'si') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisKodu.FieldName, 'al') +
        addJoin(jtLeft, FChHesapKarti.TableName, FChHesapKarti.HesapKodu.FieldName, FSetChVergiOrani.TableName, FAlisIadeKodu.FieldName, 'ai') +
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TStkStokGrubu.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FStokGrubu.FieldName,
        FKDVOrani.FieldName,
        FIhracatKodu.FieldName,
        FHammaddeKodu.FieldName,
        FMamulKodu.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;

      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
  end;
end;

procedure TStkStokGrubu.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FStokGrubu.FieldName,
        FKDVOrani.FieldName,
        FIhracatKodu.FieldName,
        FHammaddeKodu.FieldName,
        FMamulKodu.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
  end;
end;

function TStkStokGrubu.Clone: TTable;
begin
  Result := TStkStokGrubu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
