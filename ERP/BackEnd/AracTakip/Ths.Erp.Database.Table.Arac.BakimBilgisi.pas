unit Ths.Erp.Database.Table.Arac.BakimBilgisi;

interface

{$I ThsERP.inc}

uses
  SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TBakimBilgisi = class(TTable)
  private
    FPlaka: TFieldDB;
    FBakimTarihi: TFieldDB;
    FBakimNotu: TFieldDB;
    FBakimYapanServis: TFieldDB;
    FPeriyodikBakimKM: TFieldDB;
    FTrafikSigortaTarihi: TFieldDB;
    FAracMuayeneTarihi: TFieldDB;
    FAracKM: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property Plaka: TFieldDB read FPlaka write FPlaka;
    property BakimTarihi: TFieldDB read FBakimTarihi write FBakimTarihi;
    property BakimNotu: TFieldDB read FBakimNotu write FBakimNotu;
    property BakimYapanServis: TFieldDB read FBakimYapanServis write FBakimYapanServis;
    property PeriyodikBakimKM: TFieldDB read FPeriyodikBakimKM write FPeriyodikBakimKM;
    property TrafikSigortaTarihi: TFieldDB read FTrafikSigortaTarihi write FTrafikSigortaTarihi;
    property AracMuayeneTarihi: TFieldDB read FAracMuayeneTarihi write FAracMuayeneTarihi;
    property AracKM: TFieldDB read FAracKM write FAracKM;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TBakimBilgisi.Create(ADatabase: TDatabase);
begin
  TableName := 'arac_bakim_bilgisi';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FPlaka := TFieldDB.Create('plaka', ftString, '', Self, '');
  FBakimTarihi := TFieldDB.Create('bakim_tarihi', ftDate, 0, Self, '');
  FBakimNotu := TFieldDB.Create('bakim_notu', ftString, '', Self, '');
  FBakimYapanServis := TFieldDB.Create('bakim_yapan_servis', ftString, '', Self, '');
  FPeriyodikBakimKM := TFieldDB.Create('periyodik_bakim_km', ftInteger, 0, Self, '');
  FTrafikSigortaTarihi := TFieldDB.Create('trafik_sigorta_tarihi', ftDate, 0, Self, '');
  FAracMuayeneTarihi := TFieldDB.Create('arac_muayene_tarihi', ftDate, 0, Self, '');
  FAracKM := TFieldDB.Create('arac_km', ftInteger, 0, Self, '');
end;

procedure TBakimBilgisi.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FPlaka.FieldName,
        TableName + '.' + FBakimTarihi.FieldName,
        TableName + '.' + FBakimNotu.FieldName,
        TableName + '.' + FBakimYapanServis.FieldName,
        TableName + '.' + FPeriyodikBakimKM.FieldName,
        TableName + '.' + FTrafikSigortaTarihi.FieldName,
        TableName + '.' + FAracMuayeneTarihi.FieldName,
        TableName + '.' + FAracKM.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TBakimBilgisi.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    if (pLock) then
		  pFilter := pFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FPlaka.FieldName,
        TableName + '.' + FBakimTarihi.FieldName,
        TableName + '.' + FBakimNotu.FieldName,
        TableName + '.' + FBakimYapanServis.FieldName,
        TableName + '.' + FPeriyodikBakimKM.FieldName,
        TableName + '.' + FTrafikSigortaTarihi.FieldName,
        TableName + '.' + FAracMuayeneTarihi.FieldName,
        TableName + '.' + FAracKM.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
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

procedure TBakimBilgisi.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FPlaka.FieldName,
        FBakimTarihi.FieldName,
        FBakimNotu.FieldName,
        FBakimYapanServis.FieldName,
        FPeriyodikBakimKM.FieldName,
        FTrafikSigortaTarihi.FieldName,
        FAracMuayeneTarihi.FieldName,
        FAracKM.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;

      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  pID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  pID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TBakimBilgisi.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FPlaka.FieldName,
        FBakimTarihi.FieldName,
        FBakimNotu.FieldName,
        FBakimYapanServis.FieldName,
        FPeriyodikBakimKM.FieldName,
        FTrafikSigortaTarihi.FieldName,
        FAracMuayeneTarihi.FieldName,
        FAracKM.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TBakimBilgisi.Clone: TTable;
begin
  Result := TBakimBilgisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
