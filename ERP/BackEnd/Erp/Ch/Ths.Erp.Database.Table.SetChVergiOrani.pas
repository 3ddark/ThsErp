unit Ths.Erp.Database.Table.SetChVergiOrani;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.ChHesapKarti;

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
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

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
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

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
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
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
end;

procedure TSetChVergiOrani.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSetChVergiOrani.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FVergiOrani.FieldName,
        FSatisKodu.FieldName,
        FSatisIadeKodu.FieldName,
        FAlisKodu.FieldName,
        FAlisIadeKodu.FieldName
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

procedure TSetChVergiOrani.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FVergiOrani.FieldName,
        FSatisKodu.FieldName,
        FSatisIadeKodu.FieldName,
        FAlisKodu.FieldName,
        FAlisIadeKodu.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
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
