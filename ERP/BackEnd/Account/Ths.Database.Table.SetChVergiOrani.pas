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
    FSatisIadeHesapKodu: TFieldDB;
    FAlisHesapKodu: TFieldDB;
    FAlisIadeHesapKodu: TFieldDB;
    FIhracatHesapKodu: TFieldDB;
    FIhracatIadeHesapKodu: TFieldDB;
    FIthalatHesapKodu: TFieldDB;
    FIthalatIadeHesapKodu: TFieldDB;
    //db alan� de�il
    FSatisHesapAdi: TFieldDB;
    FSatisIadeHesapAdi: TFieldDB;
    FAlisHesapAdi: TFieldDB;
    FAlisIadeHesapAdi: TFieldDB;
    FIhracatHesapAdi: TFieldDB;
    FIhracatIadeHesapAdi: TFieldDB;
    FIthalatHesapAdi: TFieldDB;
    FIthalatIadeHesapAdi: TFieldDB;
  protected
    CH: TChHesapKarti;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean = True; AAllColumn: Boolean = True; AHelper: Boolean = False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean = True); override;
    procedure DoInsert(APermissionControl: Boolean = True); override;
    procedure DoUpdate(APermissionControl: Boolean = True); override;

    function Clone: TTable; override;
    function Validate: Boolean;

    property VergiOrani: TFieldDB read FVergiOrani write FVergiOrani;
    property SatisHesapKodu: TFieldDB read FSatisHesapKodu write FSatisHesapKodu;
    property SatisIadeHesapKodu: TFieldDB read FSatisIadeHesapKodu write FSatisIadeHesapKodu;
    property IhracatHesapKodu: TFieldDB read FIhracatHesapKodu write FIhracatHesapKodu;
    property IhracatIadeHesapKodu: TFieldDB read FIhracatIadeHesapKodu write FIhracatIadeHesapKodu;
    property AlisHesapKodu: TFieldDB read FAlisHesapKodu write FAlisHesapKodu;
    property AlisIadeHesapKodu: TFieldDB read FAlisIadeHesapKodu write FAlisIadeHesapKodu;
    property IthalatHesapKodu: TFieldDB read FIthalatHesapKodu write FIthalatHesapKodu;
    property IthalatIadeHesapKodu: TFieldDB read FIthalatIadeHesapKodu write FIthalatIadeHesapKodu;
    //db alan� de�il
    property SatisHesapAdi: TFieldDB read FSatisHesapAdi write FSatisHesapAdi;
    property SatisIadeHesapAdi: TFieldDB read FSatisIadeHesapAdi write FSatisIadeHesapAdi;
    property IhracatHesapAdi: TFieldDB read FIhracatHesapAdi write FIhracatHesapAdi;
    property IhracatIadeHesapAdi: TFieldDB read FIhracatIadeHesapAdi write FIhracatIadeHesapAdi;
    property AlisHesapAdi: TFieldDB read FAlisHesapAdi write FAlisHesapAdi;
    property AlisIadeHesapAdi: TFieldDB read FAlisIadeHesapAdi write FAlisIadeHesapAdi;
    property IthalatHesapAdi: TFieldDB read FIthalatHesapAdi write FIthalatHesapAdi;
    property IthalatIadeHesapAdi: TFieldDB read FIthalatIadeHesapAdi write FIthalatIadeHesapAdi;
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
  FSatisHesapKodu := TFieldDB.Create('satis_hesap_kodu', ftString, '', Self, 'Sat��');
  FSatisIadeHesapKodu := TFieldDB.Create('satis_iade_hesap_kodu', ftString, '', Self, 'Sat�� �ade');
  FIhracatHesapKodu := TFieldDB.Create('ihracat_hesap_kodu', ftString, '', Self, '�hracat');
  FIhracatIadeHesapKodu := TFieldDB.Create('ihracat_iade_hesap_kodu', ftString, '', Self, '�hracat �ade');
  FAlisHesapKodu := TFieldDB.Create('alis_hesap_kodu', ftString, '', Self, 'Al��');
  FAlisIadeHesapKodu := TFieldDB.Create('alis_iade_hesap_kodu', ftString, '', Self, 'Al�� �ade');
  FIthalatHesapKodu := TFieldDB.Create('ithalat_hesap_kodu', ftString, '', Self, '�thalat');
  FIthalatIadeHesapKodu := TFieldDB.Create('ithalat_iade_hesap_kodu', ftString, '', Self, '�thalat');
  //db alan� de�il
  FSatisHesapAdi := TFieldDB.Create('satis_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Sat�� Hesap');
  FSatisIadeHesapAdi := TFieldDB.Create('satis_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Sat�� �ade Hesap');
  FIhracatHesapAdi := TFieldDB.Create('ihracat_hesap_adi', CH.HesapIsmi.DataType, '', Self, '�hracat Hesap');
  FIhracatIadeHesapAdi := TFieldDB.Create('ihracat_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, '�hracat �ade Hesap');
  FAlisHesapAdi := TFieldDB.Create('alis_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Al�� Hesap');
  FAlisIadeHesapAdi := TFieldDB.Create('alis_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, 'Al�� �ade Hesap');
  FIthalatHesapAdi := TFieldDB.Create('ithalat_hesap_adi', CH.HesapIsmi.DataType, '', Self, '�thalat Hesap');
  FIthalatIadeHesapAdi := TFieldDB.Create('ithalat_iade_hesap_adi', CH.HesapIsmi.DataType, '', Self, '�thalat �ade Hesap');
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
      FIhracatHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracatHesapAdi.FieldName, 'ih'),
      FIhracatIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracatIadeHesapAdi.FieldName, 'ii'),
      FAlisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FAlisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai'),
      FIthalatHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIthalatHesapAdi.FieldName, 'it'),
      FIthalatIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIthalatIadeHesapAdi.FieldName, 'ti')
    ], [
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FIhracatHesapKodu.FieldName, 'ih'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FIhracatIadeHesapKodu.FieldName, 'ii'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FIthalatHesapKodu.FieldName, 'it'),
      addJoin(jtLeft, CH.TableName, CH.HesapKodu.FieldName, TableName, FIthalatIadeHesapKodu.FieldName, 'ti'),
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
      FIhracatHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracatHesapAdi.FieldName, 'ih'),
      FIhracatIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIhracatIadeHesapAdi.FieldName, 'ii'),
      FAlisHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisHesapAdi.FieldName, 'al'),
      FAlisIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeHesapAdi.FieldName, 'ai'),
      FIthalatHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIthalatHesapAdi.FieldName, 'it'),
      FIthalatIadeHesapKodu.QryName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FIthalatIadeHesapAdi.FieldName, 'ti')
    ], [
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisHesapKodu.FieldName, 'st'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisIadeHesapKodu.FieldName, 'si'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIhracatHesapKodu.FieldName, 'ih'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIhracatIadeHesapKodu.FieldName, 'ii'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisHesapKodu.FieldName, 'al'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisIadeHesapKodu.FieldName, 'ai'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIthalatHesapKodu.FieldName, 'it'),
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FIthalatIadeHesapKodu.FieldName, 'ti'),
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

procedure TSetChVergiOrani.DoInsert(APermissionControl: Boolean);
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
      FIhracatHesapKodu.FieldName,
      FIhracatIadeHesapKodu.FieldName,
      FAlisHesapKodu.FieldName,
      FAlisIadeHesapKodu.FieldName,
      FIthalatHesapKodu.FieldName,
      FIthalatIadeHesapKodu.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
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
      FIhracatHesapKodu.FieldName,
      FIhracatIadeHesapKodu.FieldName,
      FAlisHesapKodu.FieldName,
      FAlisIadeHesapKodu.FieldName,
      FIthalatHesapKodu.FieldName,
      FIthalatIadeHesapKodu.FieldName
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
    CreateExceptionByLang('Vergi oran� hatal� girildi!' + AddLBs(2) + 'L�tfen veri oran�n� kontrol edin. Vergi Oran� 0.00 - 100.00 aras�nda bir de�er olmal�d�r.', '999999');
end;

function TSetChVergiOrani.Clone: TTable;
begin
  Result := TSetChVergiOrani.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
