unit Ths.Erp.Database.Table.Arac.Hareket;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,

    Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  THareket = class(TTable)
  private
    FYetkili: TFieldDB;
    FSurucu: TFieldDB;
    FPlaka: TFieldDB;
    FGorev: TFieldDB;
    FCikisYeri: TFieldDB;
    FCikisKM: TFieldDB;
    FCikisTarihi: TFieldDB;
    FVarisYeri: TFieldDB;
    FVarisKM: TFieldDB;
    FVarisTarihi: TFieldDB;
    FAciklama: TFieldDB;
    FSure: TFieldDB;
  protected
    procedure BusinessUpdate(pPermissionControl: Boolean); override;
  published
    constructor Create(pOwnerDatabase: TDatabase); override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean = True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean = True); override;
    procedure Update(pPermissionControl: Boolean = True); override;

    function Clone(): TTable; override;

    property Yetkili: TFieldDB read FYetkili write FYetkili;
    property Surucu: TFieldDB read FSurucu write FSurucu;
    property Plaka: TFieldDB read FPlaka write FPlaka;
    property Gorev: TFieldDB read FGorev write FGorev;
    property CikisYeri: TFieldDB read FCikisYeri write FCikisYeri;
    property CikisKM: TFieldDB read FCikisKM write FCikisKM;
    property CikisTarihi: TFieldDB read FCikisTarihi write FCikisTarihi;
    property VarisYeri: TFieldDB read FVarisYeri write FVarisYeri;
    property VarisKM: TFieldDB read FVarisKM write FVarisKM;
    property VarisTarihi: TFieldDB read FVarisTarihi write FVarisTarihi;
    property Aciklama: TFieldDB read FAciklama write FAciklama;
    property Sure: TFieldDB read FSure write FSure;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor THareket.Create(pOwnerDatabase:TDatabase);
begin
  TableName := 'arac_hareketi';
  TableSourceCode := '1000';
  inherited Create(pOwnerDatabase);

  FYetkili := TFieldDB.Create('yetkili', ftString, '', Self, '');
  FSurucu := TFieldDB.Create('surucu', ftString, '', Self, '');
  FPlaka := TFieldDB.Create('plaka', ftString, '', Self, '');
  FGorev := TFieldDB.Create('gorev', ftString, '', Self, '');
  FCikisYeri := TFieldDB.Create('cikis_yeri', ftString, '', Self, '');
  FCikisKM := TFieldDB.Create('cikis_km', ftInteger, 0, Self, '');
  FCikisTarihi := TFieldDB.Create('cikis_tarihi', ftDate, 0, Self, '');
  FVarisYeri := TFieldDB.Create('varis_yeri', ftString, '', Self, '');
  FVarisKM := TFieldDB.Create('varis_km', ftInteger, 0, Self, '');
  FVarisTarihi := TFieldDB.Create('varis_tarihi', ftDate, 0, Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FSure := TFieldDB.Create('sure', ftString, '', Self, '');
end;

procedure THareket.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FYetkili.FieldName,
        TableName + '.' + FSurucu.FieldName,
        TableName + '.' + FPlaka.FieldName,
        TableName + '.' + FGorev.FieldName,
        TableName + '.' + FCikisYeri.FieldName,
        TableName + '.' + FCikisKM.FieldName,
        TableName + '.' + FCikisTarihi.FieldName,
        TableName + '.' + FVarisYeri.FieldName,
        TableName + '.' + FVarisKM.FieldName,
        TableName + '.' + FVarisTarihi.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FSure.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FYetkili, 'Yetkili', QueryOfDS);
      setFieldTitle(FSurucu, 'Sürücü', QueryOfDS);
      setFieldTitle(FPlaka, 'Plaka', QueryOfDS);
      setFieldTitle(FGorev, 'Görev', QueryOfDS);
      setFieldTitle(FCikisYeri, 'Çýkýþ Yeri', QueryOfDS);
      setFieldTitle(FCikisKM, 'Çýkýþ KM', QueryOfDS);
      setFieldTitle(FCikisTarihi, 'Çýkýþ Tarihi', QueryOfDS);
      setFieldTitle(FVarisYeri, 'Varýþ Yeri', QueryOfDS);
      setFieldTitle(FVarisKM, 'Varýþ KM', QueryOfDS);
      setFieldTitle(FVarisTarihi, 'Varýþ Tarihi', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FSure, 'Süre', QueryOfDS);
    end;
  end;
end;

procedure THareket.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FYetkili.FieldName,
        TableName + '.' + FSurucu.FieldName,
        TableName + '.' + FPlaka.FieldName,
        TableName + '.' + FGorev.FieldName,
        TableName + '.' + FCikisYeri.FieldName,
        TableName + '.' + FCikisKM.FieldName,
        TableName + '.' + FCikisTarihi.FieldName,
        TableName + '.' + FVarisYeri.FieldName,
        TableName + '.' + FVarisKM.FieldName,
        TableName + '.' + FVarisTarihi.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FSure.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FYetkili, QueryOfList);
        setFieldValue(FSurucu, QueryOfList);
        setFieldValue(FPlaka, QueryOfList);
        setFieldValue(FGorev, QueryOfList);
        setFieldValue(FCikisYeri, QueryOfList);
        setFieldValue(FCikisKM, QueryOfList);
        setFieldValue(FCikisTarihi, QueryOfList);
        setFieldValue(FVarisYeri, QueryOfList);
        setFieldValue(FVarisKM, QueryOfList);
        setFieldValue(FVarisTarihi, QueryOfList);
        setFieldValue(FAciklama, QueryOfList);
        setFieldValue(FSure, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure THareket.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FYetkili.FieldName,
        FSurucu.FieldName,
        FPlaka.FieldName,
        FGorev.FieldName,
        FCikisYeri.FieldName,
        FCikisKM.FieldName,
        FCikisTarihi.FieldName,
        FVarisYeri.FieldName,
        FVarisKM.FieldName,
        FVarisTarihi.FieldName,
        FAciklama.FieldName,
        FSure.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FYetkili);
      NewParamForQuery(QueryOfInsert, FSurucu);
      NewParamForQuery(QueryOfInsert, FPlaka);
      NewParamForQuery(QueryOfInsert, FGorev);
      NewParamForQuery(QueryOfInsert, FCikisYeri);
      NewParamForQuery(QueryOfInsert, FCikisKM);
      NewParamForQuery(QueryOfInsert, FCikisTarihi);
      NewParamForQuery(QueryOfInsert, FVarisYeri);
      NewParamForQuery(QueryOfInsert, FVarisKM);
      NewParamForQuery(QueryOfInsert, FVarisTarihi);
      NewParamForQuery(QueryOfInsert, FAciklama);
      NewParamForQuery(QueryOfInsert, FSure);

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

procedure THareket.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FYetkili.FieldName,
        FSurucu.FieldName,
        FPlaka.FieldName,
        FGorev.FieldName,
        FCikisYeri.FieldName,
        FCikisKM.FieldName,
        FCikisTarihi.FieldName,
        FVarisYeri.FieldName,
        FVarisKM.FieldName,
        FVarisTarihi.FieldName,
        FAciklama.FieldName,
        FSure.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FYetkili);
      NewParamForQuery(QueryOfUpdate, FSurucu);
      NewParamForQuery(QueryOfUpdate, FPlaka);
      NewParamForQuery(QueryOfUpdate, FGorev);
      NewParamForQuery(QueryOfUpdate, FCikisYeri);
      NewParamForQuery(QueryOfUpdate, FCikisKM);
      NewParamForQuery(QueryOfUpdate, FCikisTarihi);
      NewParamForQuery(QueryOfUpdate, FVarisYeri);
      NewParamForQuery(QueryOfUpdate, FVarisKM);
      NewParamForQuery(QueryOfUpdate, FVarisTarihi);
      NewParamForQuery(QueryOfUpdate, FAciklama);
      NewParamForQuery(QueryOfUpdate, FSure);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure THareket.BusinessUpdate(pPermissionControl: Boolean);
begin
  inherited;
  Self.Update(pPermissionControl);
end;

function THareket.Clone():TTable;
begin
  Result := THareket.Create(Database);

  Self.Id.Clone(THareket(Result).Id);

  FYetkili.Clone(THareket(Result).FYetkili);
  FSurucu.Clone(THareket(Result).FSurucu);
  FPlaka.Clone(THareket(Result).FPlaka);
  FGorev.Clone(THareket(Result).FGorev);
  FCikisYeri.Clone(THareket(Result).FCikisYeri);
  FCikisKM.Clone(THareket(Result).FCikisKM);
  FCikisTarihi.Clone(THareket(Result).FCikisTarihi);
  FVarisYeri.Clone(THareket(Result).FVarisYeri);
  FVarisKM.Clone(THareket(Result).FVarisKM);
  FVarisTarihi.Clone(THareket(Result).FVarisTarihi);
  FAciklama.Clone(THareket(Result).FAciklama);
  FSure.Clone(THareket(Result).FSure);
end;

end.

