unit Ths.Database.Table.SetChVergiOrani;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table,
  Ths.Database.Table.ChHesapKarti;

type
  TSetChVergiOrani = class(TTable)
  private
    FVergiOrani: TFieldDB;
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
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    function Validate: Boolean;

    Property VergiOrani: TFieldDB read FVergiOrani write FVergiOrani;
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
  Ths.Globals,
  Ths.Constants;

constructor TSetChVergiOrani.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_vergi_orani';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  CH := TChHesapKarti.Create(ADatabase);

  FVergiOrani := TFieldDB.Create('vergi_orani', ftBCD, 0, Self, 'Oran', '', 2);
  FSatisKodu := TFieldDB.Create('satis_kodu', ftString, '', Self, 'Satýþ');
  FSatisAdi := TFieldDB.Create('satis_adi', CH.HesapIsmi.DataType, '', Self, 'Satýþ Ýsim');
  FSatisIadeKodu := TFieldDB.Create('satis_iade_kodu', ftString, '', Self, 'Satýþ Ýade');
  FSatisIadeAdi := TFieldDB.Create('satis_iade_adi', CH.HesapIsmi.DataType, '', Self, 'Satýþ Ýade Ýsim');
  FAlisKodu := TFieldDB.Create('alis_kodu', ftString, '', Self, 'Alýþ');
  FAlisAdi := TFieldDB.Create('alis_adi', CH.HesapIsmi.DataType, '', Self, 'Alýþ Ýsim');
  FAlisIadeKodu := TFieldDB.Create('alis_iade_kodu', ftString, '', Self, 'Alýþ Ýade');
  FAlisIadeAdi := TFieldDB.Create('alis_iade_adi', CH.HesapIsmi.DataType, '', Self, 'Alýþ Ýade Ýsim');
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
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FVergiOrani.FieldName,
      TableName + '.' + FSatisKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisAdi.FieldName, 'st'),
      TableName + '.' + FSatisIadeKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeAdi.FieldName, 'si'),
      TableName + '.' + FAlisKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisAdi.FieldName, 'al'),
      TableName + '.' + FAlisIadeKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisKodu.FieldName, 'st') +
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisIadeKodu.FieldName, 'si') +
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisKodu.FieldName, 'al') +
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisIadeKodu.FieldName, 'ai') +
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
    Active := True;
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
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FVergiOrani.FieldName,
      TableName + '.' + FSatisKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisAdi.FieldName, 'st'),
      TableName + '.' + FSatisIadeKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FSatisIadeAdi.FieldName, 'si'),
      TableName + '.' + FAlisKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisAdi.FieldName, 'al'),
      TableName + '.' + FAlisIadeKodu.FieldName,
      addfield(CH.TableName, CH.HesapIsmi.FieldName, FAlisIadeAdi.FieldName, 'ai')
    ], [
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisKodu.FieldName, 'st') +
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FSatisIadeKodu.FieldName, 'si') +
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisKodu.FieldName, 'al') +
      addJoin(jtLeft, CH.TableName, ch.HesapKodu.FieldName, TableName, FAlisIadeKodu.FieldName, 'ai') +
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
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
      FSatisKodu.FieldName,
      FSatisIadeKodu.FieldName,
      FAlisKodu.FieldName,
      FAlisIadeKodu.FieldName
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
      FSatisKodu.FieldName,
      FSatisIadeKodu.FieldName,
      FAlisKodu.FieldName,
      FAlisIadeKodu.FieldName
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



