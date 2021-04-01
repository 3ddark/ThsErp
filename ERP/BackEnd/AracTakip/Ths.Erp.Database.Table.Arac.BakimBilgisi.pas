unit Ths.Erp.Database.Table.Arac.BakimBilgisi;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,

    Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

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
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;

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
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TBakimBilgisi.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'arac_bakim_bilgisi';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

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

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FPlaka, 'Ad Soyad', QueryOfDS);
      setFieldTitle(FBakimTarihi, 'Açýklama', QueryOfDS);
      setFieldTitle(FBakimNotu, 'Görev Verebilir?', QueryOfDS);
      setFieldTitle(FBakimYapanServis, 'Araç Sürebilir?', QueryOfDS);
      setFieldTitle(FPeriyodikBakimKM, 'Periyodik Bakým KM', QueryOfDS);
      setFieldTitle(FTrafikSigortaTarihi, 'Trafik Sigorta Tarihi', QueryOfDS);
      setFieldTitle(FAracMuayeneTarihi, 'Muayene Tarihi', QueryOfDS);
      setFieldTitle(FAracKM, 'Araç KM', QueryOfDS);
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
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FPlaka, QueryOfList);
        setFieldValue(FBakimTarihi, QueryOfList);
        setFieldValue(FBakimNotu, QueryOfList);
        setFieldValue(FBakimYapanServis, QueryOfList);
        setFieldValue(FPeriyodikBakimKM, QueryOfList);
        setFieldValue(FTrafikSigortaTarihi, QueryOfList);
        setFieldValue(FAracMuayeneTarihi, QueryOfList);
        setFieldValue(FAracKM, QueryOfList);

        List.Add(Self.Clone());

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

      NewParamForQuery(QueryOfInsert, FPlaka);
      NewParamForQuery(QueryOfInsert, FBakimTarihi);
      NewParamForQuery(QueryOfInsert, FBakimNotu);
      NewParamForQuery(QueryOfInsert, FBakimYapanServis);
      NewParamForQuery(QueryOfInsert, FPeriyodikBakimKM);
      NewParamForQuery(QueryOfInsert, FTrafikSigortaTarihi);
      NewParamForQuery(QueryOfInsert, FAracMuayeneTarihi);
      NewParamForQuery(QueryOfInsert, FAracKM);

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        pID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else
        pID := 0;

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

      NewParamForQuery(QueryOfUpdate, FPlaka);
      NewParamForQuery(QueryOfUpdate, FBakimTarihi);
      NewParamForQuery(QueryOfUpdate, FBakimNotu);
      NewParamForQuery(QueryOfUpdate, FBakimYapanServis);
      NewParamForQuery(QueryOfUpdate, FPeriyodikBakimKM);
      NewParamForQuery(QueryOfUpdate, FTrafikSigortaTarihi);
      NewParamForQuery(QueryOfUpdate, FAracMuayeneTarihi);
      NewParamForQuery(QueryOfUpdate, FAracKM);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TBakimBilgisi.Clone():TTable;
begin
  Result := TBakimBilgisi.Create(Database);

  Self.Id.Clone(TBakimBilgisi(Result).Id);

  FPlaka.Clone(TBakimBilgisi(Result).FPlaka);
  FBakimTarihi.Clone(TBakimBilgisi(Result).FBakimTarihi);
  FBakimNotu.Clone(TBakimBilgisi(Result).FBakimNotu);
  FBakimYapanServis.Clone(TBakimBilgisi(Result).FBakimYapanServis);
  FPeriyodikBakimKM.Clone(TBakimBilgisi(Result).FPeriyodikBakimKM);
  FTrafikSigortaTarihi.Clone(TBakimBilgisi(Result).FTrafikSigortaTarihi);
  FAracMuayeneTarihi.Clone(TBakimBilgisi(Result).FAracMuayeneTarihi);
  FAracKM.Clone(TBakimBilgisi(Result).FAracKM);
end;

end.
