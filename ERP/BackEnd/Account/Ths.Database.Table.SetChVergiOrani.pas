unit Ths.Database.Table.SetChVergiOrani;

interface

{$I Ths.inc}

uses
  System.SysUtils, Data.DB, ZDataset, Ths.Database, Ths.Database.Table,
  Ths.Database.Table.ChHesapKarti;

type
  TSetChVergiOrani = class(TTable)
  private
    FVergiOrani: TFieldDB;
    FSatisHesapKodu: TFieldDB;
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapKodu: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
    FIhracHesapKodu: TFieldDB;
    FIhracHesapAdi: TFieldDB;
    FIhracIadeHesapKodu: TFieldDB;
    FIhracIadeHesapAdi: TFieldDB;
  protected
    CH: TChHesapKarti;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean = True; AAllColumn: Boolean = True; AHelper: Boolean = False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean = True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean = True); override;
    procedure DoUpdate(APermissionControl: Boolean = True); override;

    function Clone: TTable; override;
    function Validate: Boolean;

    property VergiOrani: TFieldDB read FVergiOrani write FVergiOrani;
    property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    property SatisHesapAdi: TFieldDB read FSatisHesapAdi write FSatisHesapAdi;
    property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    property SatisIadeHesapAdi: TFieldDB read FSatisIadeHesapAdi write FSatisIadeHesapAdi;
    property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    property AlisHesapAdi: TFieldDB read FAlisHesapAdi write FAlisHesapAdi;
    property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    property AlisIadeHesapAdi: TFieldDB read FAlisIadeHesapAdi write FAlisIadeHesapAdi;
    property IhracHesapKodu: TFieldDB read FIhracHesapKodu write FIhracHesapKodu;
    property IhracHesapAdi: TFieldDB read FIhracHesapAdi write FIhracHesapAdi;
    property IhracIadeHesapKodu: TFieldDB read FIhracIadeHesapKodu write FIhracIadeHesapKodu;
    property IhracIadeHesapAdi: TFieldDB read FIhracIadeHesapAdi write FIhracIadeHesapAdi;
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
  FSatisHesapKodu := TFieldDB.Create('satis_hesap_kodu', ftString, '', Self, 'Satýþ');
  FSatisHesapAdi := TFieldDB.Create('satis_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Satýþ Hesap');
  FSatisIadeHesapKodu := TFieldDB.Create('satis_iade_hesap_kodu', ftString, '', Self, 'Satýþ Ýade');
  FSatisIadeHesapAdi := TFieldDB.Create('satis_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Satýþ Ýade Hesap');
  FAlisHesapKodu := TFieldDB.Create('alis_hesap_kodu', ftString, '', Self, 'Alýþ');
  FAlisHesapAdi := TFieldDB.Create('alis_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Alýþ Hesap');
  FAlisIadeHesapKodu := TFieldDB.Create('alis_iade_hesap_kodu', ftString, '', Self, 'Alýþ Ýade');
  FAlisIadeHesapAdi := TFieldDB.Create('alis_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Alýþ Ýade Hesap');
  FIhracHesapKodu := TFieldDB.Create('ihrac_hesap_kodu', ftString, '', Self, 'Ýhracat');
  FIhracHesapAdi := TFieldDB.Create('ihrac_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Ýhracat Hesap');
  FIhracIadeHesapKodu := TFieldDB.Create('ihrac_iade_hesap_kodu', ftString, '', Self, 'Ýhracat Ýade');
  FIhracIadeHesapAdi := TFieldDB.Create('ihrac_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Ýhracat Ýade Hesap');
end;

destructor TSetChVergiOrani.Destroy;
begin
  CH.Free;
  inherited;
end;

procedure TSetChVergiOrani.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Self.Id.QryName,
      FVergiOrani.QryName,
      FSatisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSatisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FAlisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FAlisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai'),
      FIhracHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracHesapAdi.FieldName, 'ih'),
      FIhracIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracIadeHesapAdi.FieldName, 'ii')
    ], [
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIhracHesapKodu.FieldName, 'ih'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIhracIadeHesapKodu.FieldName, 'ii'),
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSetChVergiOrani.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
      Self.Id.QryName,
      FVergiOrani.QryName,
      FSatisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisHesapAdi.FieldName, 'st'),
      FSatisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeHesapAdi.FieldName, 'si'),
      FAlisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FAlisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai'),
      FIhracHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracHesapAdi.FieldName, 'ih'),
      FIhracIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracIadeHesapAdi.FieldName, 'ii')
    ], [
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIhracHesapKodu.FieldName, 'ih'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIhracIadeHesapKodu.FieldName, 'ii'),
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
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

procedure TSetChVergiOrani.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FVergiOrani.FieldName,
      FSatisHesapKodu.FieldName,
      FSatisIadeHesapKodu.FieldName,
      FAlisHesapKodu.FieldName,
      FAlisIadeHesapKodu.FieldName,
      FIhracHesapKodu.FieldName,
      FIhracIadeHesapKodu.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
    else  AID := 0;
  finally
    Free;
  end;
end;

procedure TSetChVergiOrani.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FVergiOrani.FieldName,
      FSatisHesapKodu.FieldName,
      FSatisIadeHesapKodu.FieldName,
      FAlisHesapKodu.FieldName,
      FAlisIadeHesapKodu.FieldName,
      FIhracHesapKodu.FieldName,
      FIhracIadeHesapKodu.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

function TSetChVergiOrani.Validate: Boolean;
begin
  Result := True;

  if (Self.FVergiOrani.Value < 0) or (Self.FVergiOrani.Value > 100) then
    CreateExceptionByLang('Vergi oraný hatalý girildi!' + AddLBs(2) + 'Lütfen veri oranýný kontrol edin. Vergi Oraný 0.00 - 100.00 arasýnda bir deðer olmalýdýr.', '999999');
end;

function TSetChVergiOrani.Clone: TTable;
begin
  Result := TSetChVergiOrani.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
