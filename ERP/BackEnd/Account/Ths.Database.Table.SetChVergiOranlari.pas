unit Ths.Database.Table.SetChVergiOranlari;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  Ths.Database, Ths.Database.Table, Ths.Database.Table.ChHesapKarti;

type
  TSetChVergiOrani = class(TTable)
  private
    FVergiOrani: TFieldDB;
    FSatisHesapKodu: TFieldDB;
    FSatisIadeHesapKodu: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    //not a database field
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
  protected
    CH: TChHesapKarti;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    function SelectToDatasource(AFilter: string; APermissionControl: Boolean = True; AAllColumn: Boolean = True; AHelper: Boolean = False): string; override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean = True); override;
    procedure DoInsert(APermissionControl: Boolean = True); override;
    procedure DoUpdate(APermissionControl: Boolean = True); override;

    function Clone: TTable; override;
    function Validate: Boolean;

    property VergiOrani: TFieldDB read FVergiOrani write FVergiOrani;
    property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    //not a database field
    property SatisHesapAdi: TFieldDB read FSatisHesapAdi write FSatisHesapAdi;
    property SatisIadeHesapAdi: TFieldDB read FSatisIadeHesapAdi write FSatisIadeHesapAdi;
    property AlisHesapAdi: TFieldDB read FAlisHesapAdi write FAlisHesapAdi;
    property AlisIadeHesapAdi: TFieldDB read FAlisIadeHesapAdi write FAlisIadeHesapAdi;
  end;

implementation

uses
  Ths.Globals, Ths.Constants;

constructor TSetChVergiOrani.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_vergi_oranlari';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  CH := TChHesapKarti.Create(ADatabase);

  FVergiOrani := TFieldDB.Create('vergi_orani', ftBCD, 0, Self, 'KDV', '', 2);
  FSatisHesapKodu := TFieldDB.Create('satis_hesap_kodu', ftString, '', Self, 'Satış');
  FSatisIadeHesapKodu := TFieldDB.Create('satis_iade_hesap_kodu', ftString, '', Self, 'Satış İade');
  FAlisHesapKodu := TFieldDB.Create('alis_hesap_kodu', ftString, '', Self, 'Alış');
  FAlisIadeHesapKodu := TFieldDB.Create('alis_iade_hesap_kodu', ftString, '', Self, 'Alış İade');
  //not a database field
  FSatisHesapAdi := TFieldDB.Create('satis_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Satış Hesap');
  FSatisIadeHesapAdi := TFieldDB.Create('satis_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Satış İade Hesap');
  FAlisHesapAdi := TFieldDB.Create('alis_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Alış Hesap');
  FAlisIadeHesapAdi := TFieldDB.Create('alis_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Alış İade Hesap');
end;

destructor TSetChVergiOrani.Destroy;
begin
  CH.Free;
  inherited;
end;

function TSetChVergiOrani.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean): string;
var
  LQry: TFDQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  LQry := Database.NewQuery;
  try
    Database.SQLBuilder.GetSQLSelectCmd(LQry, TableName, [
      Self.Id.QryName,
      FVergiOrani.QryName,
      FSatisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSatisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FAlisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FAlisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Result := LQry.SQL.Text;
  finally
    LQry.Free;
  end;
end;

procedure TSetChVergiOrani.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Self.Id.QryName,
      FVergiOrani.QryName,
      FSatisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSatisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FAlisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FAlisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    while not EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Self.Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TSetChVergiOrani.DoInsert(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLInsertCmd(TableName, LQry, [
      FVergiOrani.FieldName,
      FSatisHesapKodu.FieldName,
      FSatisIadeHesapKodu.FieldName,
      FAlisHesapKodu.FieldName,
      FAlisIadeHesapKodu.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    LQry.Open;
    Self.Id.Value := LQry.Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    LQry.Free;
  end;
end;

procedure TSetChVergiOrani.DoUpdate(APermissionControl: Boolean);
var
  LQry: TFDQuery;
begin
  LQry := Database.NewQuery();
  try
    Database.SQLBuilder.GetSQLUpdateCmd(TableName, LQry, [
      FVergiOrani.FieldName,
      FSatisHesapKodu.FieldName,
      FSatisIadeHesapKodu.FieldName,
      FAlisHesapKodu.FieldName,
      FAlisIadeHesapKodu.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;

function TSetChVergiOrani.Clone: TTable;
begin
  Result := TSetChVergiOrani.Create(Database);
  CloneClassContent(Self, Result);
end;

function TSetChVergiOrani.Validate: Boolean;
begin
  Result := True;

  if (Self.FVergiOrani.Value < 0) or (Self.FVergiOrani.Value > 100) then
    raise Exception.Create(Trim('Vergi oranı hatalı girildi!' + AddLBs(2) + 'Lütfen veri oranını kontrol edin. Vergi Oranı 0.00 - 100.00 arasında bir değer olmalıdır. + 999999'));
end;

end.
