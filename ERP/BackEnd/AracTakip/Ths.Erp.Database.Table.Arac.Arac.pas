unit Ths.Erp.Database.Table.Arac.Arac;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,

    Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TArac = class(TTable)
  private
    FMarka: TFieldDB;
    FModel: TFieldDB;
    FPlaka: TFieldDB;
    FRenk: TFieldDB;
    FGelisTarihi: TFieldDB;
    FGelisKM: TFieldDB;
    FGelisYeri: TFieldDB;
    FAciklama: TFieldDB;
    FIsActive: TFieldDB;
    FAktifKM: TFieldDB;
    FAktifKonum: TFieldDB;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;

    Property Marka: TFieldDB read FMarka write FMarka;
    Property Model: TFieldDB read FModel write FModel;
    Property Plaka: TFieldDB read FPlaka write FPlaka;
    Property Renk: TFieldDB read FRenk write FRenk;
    Property GelisTarihi: TFieldDB read FGelisTarihi write FGelisTarihi;
    Property GelisKM: TFieldDB read FGelisKM write FGelisKM;
    Property GelisYeri: TFieldDB read FGelisYeri write FGelisYeri;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsActive: TFieldDB read FIsActive write FIsActive;
    Property AktifKM: TFieldDB read FAktifKM write FAktifKM;
    Property AktifKonum: TFieldDB read FAktifKonum write FAktifKonum;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TArac.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'arc_arac';
  TableSourceCode := '8000';
  inherited Create(OwnerDatabase);

  FMarka := TFieldDB.Create('marka', ftString, '', Self, '');
  FModel := TFieldDB.Create('model', ftString, '', Self, '');
  FPlaka := TFieldDB.Create('plaka', ftString, '', Self, '');
  FRenk := TFieldDB.Create('renk', ftString, '', Self, '');
  FGelisTarihi := TFieldDB.Create('gelis_tarihi', ftDate, 0, Self, '');
  FGelisKM := TFieldDB.Create('gelis_km', ftInteger, 0, Self, '');
  FGelisYeri := TFieldDB.Create('gelis_yeri', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsActive := TFieldDB.Create('is_active', ftBoolean, True, Self, '');
  FAktifKM := TFieldDB.Create('aktif_km', ftInteger, 0, Self, '');
  FAktifKonum := TFieldDB.Create('aktif_konum', ftString, '', Self, '');
end;

procedure TArac.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FMarka.FieldName,
        TableName + '.' + FModel.FieldName,
        TableName + '.' + FPlaka.FieldName,
        TableName + '.' + FRenk.FieldName,
        TableName + '.' + FGelisTarihi.FieldName,
        TableName + '.' + FGelisKM.FieldName,
        TableName + '.' + FGelisYeri.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsActive.FieldName,
        TableName + '.' + FAktifKM.FieldName,
        TableName + '.' + FAktifKonum.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FMarka, 'Marka', QueryOfDS);
      setFieldTitle(FModel, 'Model', QueryOfDS);
      setFieldTitle(FPlaka, 'Plaka', QueryOfDS);
      setFieldTitle(FRenk, 'Renk', QueryOfDS);
      setFieldTitle(FGelisTarihi, 'Geliþ Tarihi', QueryOfDS);
      setFieldTitle(FGelisKM, 'Geliþ KM', QueryOfDS);
      setFieldTitle(FGelisYeri, 'Geliþ Yeri', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FIsActive, 'Aktif?', QueryOfDS);
      setFieldTitle(FAktifKM, 'Aktif KM', QueryOfDS);
      setFieldTitle(FAktifKonum, 'Aktif Konum', QueryOfDS);
    end;
  end;
end;

procedure TArac.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FMarka.FieldName,
        TableName + '.' + FModel.FieldName,
        TableName + '.' + FPlaka.FieldName,
        TableName + '.' + FRenk.FieldName,
        TableName + '.' + FGelisTarihi.FieldName,
        TableName + '.' + FGelisKM.FieldName,
        TableName + '.' + FGelisYeri.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsActive.FieldName,
        TableName + '.' + FAktifKM.FieldName,
        TableName + '.' + FAktifKonum.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FMarka, QueryOfList);
        setFieldValue(FModel, QueryOfList);
        setFieldValue(FPlaka, QueryOfList);
        setFieldValue(FRenk, QueryOfList);
        setFieldValue(FGelisTarihi, QueryOfList);
        setFieldValue(FGelisKM, QueryOfList);
        setFieldValue(FGelisYeri, QueryOfList);
        setFieldValue(FAciklama, QueryOfList);
        setFieldValue(FIsActive, QueryOfList);
        setFieldValue(FAktifKM, QueryOfList);
        setFieldValue(FAktifKonum, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TArac.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FMarka.FieldName,
        FModel.FieldName,
        FPlaka.FieldName,
        FRenk.FieldName,
        FGelisTarihi.FieldName,
        FGelisKM.FieldName,
        FGelisYeri.FieldName,
        FAciklama.FieldName,
        FIsActive.FieldName,
        FAktifKM.FieldName,
        FAktifKonum.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FMarka);
      NewParamForQuery(QueryOfInsert, FModel);
      NewParamForQuery(QueryOfInsert, FPlaka);
      NewParamForQuery(QueryOfInsert, FRenk);
      NewParamForQuery(QueryOfInsert, FGelisTarihi);
      NewParamForQuery(QueryOfInsert, FGelisKM);
      NewParamForQuery(QueryOfInsert, FGelisYeri);
      NewParamForQuery(QueryOfInsert, FAciklama);
      NewParamForQuery(QueryOfInsert, FIsActive);
      NewParamForQuery(QueryOfInsert, FAktifKM);
      NewParamForQuery(QueryOfInsert, FAktifKonum);

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

procedure TArac.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FMarka.FieldName,
        FModel.FieldName,
        FPlaka.FieldName,
        FRenk.FieldName,
        FGelisTarihi.FieldName,
        FGelisKM.FieldName,
        FGelisYeri.FieldName,
        FAciklama.FieldName,
        FIsActive.FieldName,
        FAktifKM.FieldName,
        FAktifKonum.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FMarka);
      NewParamForQuery(QueryOfUpdate, FModel);
      NewParamForQuery(QueryOfUpdate, FPlaka);
      NewParamForQuery(QueryOfUpdate, FRenk);
      NewParamForQuery(QueryOfUpdate, FGelisTarihi);
      NewParamForQuery(QueryOfUpdate, FGelisKM);
      NewParamForQuery(QueryOfUpdate, FGelisYeri);
      NewParamForQuery(QueryOfUpdate, FAciklama);
      NewParamForQuery(QueryOfUpdate, FIsActive);
      NewParamForQuery(QueryOfUpdate, FAktifKM);
      NewParamForQuery(QueryOfUpdate, FAktifKonum);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TArac.Clone():TTable;
begin
  Result := TArac.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
