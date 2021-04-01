unit Ths.Erp.Database.Table.StkStokGrubu;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
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
    CH: TChHesapKarti;
    Vergi: TSetChVergiOrani;
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
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TStkStokGrubu.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_stok_grubu';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  CH := TChHesapKarti.Create(ADatabase);
  Vergi := TSetChVergiOrani.Create(ADatabase);

  FStokGrubu := TFieldDB.Create('stok_grubu', ftString, '', Self, 'Stok Grubu');
  FKDVOrani := TFieldDB.Create('kdv_orani', ftFloat, 0, Self, 'Kdv Oraný');
  FIhracatKodu := TFieldDB.Create('ihracat_kodu', ftString, '', Self, 'Ýhracat Kodu');
  FIhracatAdi := TFieldDB.Create('ihracat_adi', CH.HesapIsmi.DataType, '', Self, 'Ýhracat Ýsim');
  FHammaddeKodu := TFieldDB.Create('hammadde_kodu', ftString, '', Self, 'Hammadde Kodu');
  FHammaddeAdi := TFieldDB.Create('hammadde_adi', CH.HesapIsmi.DataType, '', Self, 'Hammadde Ýsim');
  FMamulKodu := TFieldDB.Create('mamul_kodu', ftString, '', Self, 'Mamül Kodu');
  FMamulAdi := TFieldDB.Create('mamul_adi', CH.HesapIsmi.DataType, '', Self, 'Mamül Ýsim');
  //vergi oranlarý tablosundan geliyor
  FSatisKodu := TFieldDB.Create(Vergi.SatisKodu.FieldName, Vergi.SatisKodu.DataType, Vergi.SatisKodu.Value, Self, Vergi.SatisKodu.Title);
  FSatisAdi := TFieldDB.Create(Vergi.SatisAdi.FieldName, Vergi.SatisAdi.DataType, Vergi.SatisAdi.Value, Self, Vergi.SatisAdi.Title);
  FSatisIadeKodu := TFieldDB.Create(Vergi.SatisIadeKodu.FieldName, Vergi.SatisIadeKodu.DataType, Vergi.SatisIadeKodu.Value, Self, Vergi.SatisIadeKodu.Title);
  FSatisIadeAdi := TFieldDB.Create(Vergi.SatisIadeAdi.FieldName, Vergi.SatisIadeAdi.DataType, Vergi.SatisIadeAdi.Value, Self, Vergi.SatisIadeAdi.Title);
  FAlisKodu := TFieldDB.Create(Vergi.AlisKodu.FieldName, Vergi.AlisKodu.DataType, Vergi.AlisKodu.Value, Self, Vergi.AlisKodu.Title);
  FAlisAdi := TFieldDB.Create(Vergi.AlisAdi.FieldName, Vergi.AlisAdi.DataType, Vergi.AlisAdi.Value, Self, Vergi.AlisAdi.Title);
  FAlisIadeKodu := TFieldDB.Create(Vergi.AlisIadeKodu.FieldName, Vergi.AlisIadeKodu.DataType, Vergi.AlisIadeKodu.Value, Self, Vergi.AlisIadeKodu.Title);
  FAlisIadeAdi := TFieldDB.Create(Vergi.AlisIadeAdi.FieldName, Vergi.AlisIadeAdi.DataType, Vergi.AlisIadeAdi.Value, Self, Vergi.AlisIadeAdi.Title);
end;

destructor TStkStokGrubu.Destroy;
begin
  CH.Free;
  Vergi.Free;
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FStokGrubu.FieldName,
        TableName + '.' + FKDVOrani.FieldName,
        TableName + '.' + FIhracatKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracatAdi.FieldName, 'ih'),
        TableName + '.' + FMamulKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FMamulAdi.FieldName, 'mm'),
        TableName + '.' + FHammaddeKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FHammaddeAdi.FieldName, 'hm'),
        Vergi.TableName + '.' + FSatisKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisAdi.FieldName, 'st'),
        Vergi.TableName + '.' + FSatisIadeKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeAdi.FieldName, 'si'),
        Vergi.TableName + '.' + FAlisKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisAdi.FieldName, 'al'),
        Vergi.TableName + '.' + FAlisIadeKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeAdi.FieldName, 'ai')
      ], [
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FIhracatKodu.FieldName, 'ih') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FMamulKodu.FieldName, 'mm') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FHammaddeKodu.FieldName, 'hm') +
        addJoin(jtLeft, Vergi.TableName, Vergi.VergiOrani.FieldName, TableName, FKDVOrani.FieldName) +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FSatisKodu.FieldName, 'st') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FSatisIadeKodu.FieldName, 'si') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FAlisKodu.FieldName, 'al') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FAlisIadeKodu.FieldName, 'ai') +
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
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
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FStokGrubu.FieldName,
        TableName + '.' + FKDVOrani.FieldName,
        TableName + '.' + FIhracatKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracatAdi.FieldName, 'ih'),
        TableName + '.' + FMamulKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FMamulAdi.FieldName, 'mm'),
        TableName + '.' + FHammaddeKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FHammaddeAdi.FieldName, 'hm'),
        Vergi.TableName + '.' + FSatisKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisAdi.FieldName, 'st'),
        Vergi.TableName + '.' + FSatisIadeKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeAdi.FieldName, 'si'),
        Vergi.TableName + '.' + FAlisKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisAdi.FieldName, 'al'),
        Vergi.TableName + '.' + FAlisIadeKodu.FieldName,
        addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeAdi.FieldName, 'ai')
      ], [
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FIhracatKodu.FieldName, 'ih') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FMamulKodu.FieldName, 'mm') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FHammaddeKodu.FieldName, 'hm') +
        addJoin(jtLeft, Vergi.TableName, Vergi.VergiOrani.FieldName, TableName, FKDVOrani.FieldName) +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FSatisKodu.FieldName, 'st') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FSatisIadeKodu.FieldName, 'si') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FAlisKodu.FieldName, 'al') +
        addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, Vergi.TableName, FAlisIadeKodu.FieldName, 'ai') +
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

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

      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
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
    Self.notify;
  end;
end;

function TStkStokGrubu.Clone: TTable;
begin
  Result := TStkStokGrubu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
