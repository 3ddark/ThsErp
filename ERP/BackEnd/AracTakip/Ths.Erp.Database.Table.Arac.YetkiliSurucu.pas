unit Ths.Erp.Database.Table.Arac.YetkiliSurucu;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,

    Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TYetkiliSurucu = class(TTable)
  private
    FAdSoyad: TFieldDB;
    FAciklama: TFieldDB;
    FIsGorevVerebilir: TFieldDB;
    FIsAracSurebilir: TFieldDB;
    FIsActive: TFieldDB;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;

    property AdSoyad: TFieldDB read FAdSoyad write FAdSoyad;
    property Aciklama: TFieldDB read FAciklama write FAciklama;
    property IsGorevVerebilir: TFieldDB read FIsGorevVerebilir write FIsGorevVerebilir;
    property IsAracSurebilir: TFieldDB read FIsAracSurebilir write FIsAracSurebilir;
    property IsActive: TFieldDB read FIsActive write FIsActive;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TYetkiliSurucu.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'arac_yetkili';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FAdSoyad := TFieldDB.Create('ad_soyad', ftString, '', Self, '');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, '');
  FIsGorevVerebilir := TFieldDB.Create('is_gorev_verebilir', ftBoolean, False, Self, '');
  FIsAracSurebilir := TFieldDB.Create('is_arac_surebilir', ftBoolean, False, Self, '');
  FIsActive := TFieldDB.Create('is_active', ftBoolean, False, Self, '');
end;

procedure TYetkiliSurucu.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FAdSoyad.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsGorevVerebilir.FieldName,
        TableName + '.' + FIsAracSurebilir.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FAdSoyad, 'Ad Soyad', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FIsGorevVerebilir, 'Görev Verebilir?', QueryOfDS);
      setFieldTitle(FIsAracSurebilir, 'Araç Sürebilir?', QueryOfDS);
      setFieldTitle(FIsActive, 'Aktif?', QueryOfDS);
    end;
  end;
end;

procedure TYetkiliSurucu.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FAdSoyad.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsGorevVerebilir.FieldName,
        TableName + '.' + FIsAracSurebilir.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        ' WHERE 1=1 ', pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FAdSoyad, QueryOfList);
        setFieldValue(FAciklama, QueryOfList);
        setFieldValue(FIsGorevVerebilir, QueryOfList);
        setFieldValue(FIsAracSurebilir, QueryOfList);
        setFieldValue(FIsActive, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TYetkiliSurucu.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FAdSoyad.FieldName,
        FAciklama.FieldName,
        FIsGorevVerebilir.FieldName,
        FIsAracSurebilir.FieldName,
        FIsActive.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FAdSoyad);
      NewParamForQuery(QueryOfInsert, FAciklama);
      NewParamForQuery(QueryOfInsert, FIsGorevVerebilir);
      NewParamForQuery(QueryOfInsert, FIsAracSurebilir);
      NewParamForQuery(QueryOfInsert, FIsActive);

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

procedure TYetkiliSurucu.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FAdSoyad.FieldName,
        FAciklama.FieldName,
        FIsGorevVerebilir.FieldName,
        FIsAracSurebilir.FieldName,
        FIsActive.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FAdSoyad);
      NewParamForQuery(QueryOfUpdate, FAciklama);
      NewParamForQuery(QueryOfUpdate, FIsGorevVerebilir);
      NewParamForQuery(QueryOfUpdate, FIsAracSurebilir);
      NewParamForQuery(QueryOfUpdate, FIsActive);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TYetkiliSurucu.Clone():TTable;
begin
  Result := TYetkiliSurucu.Create(Database);

  Self.Id.Clone(TYetkiliSurucu(Result).Id);

  FAdSoyad.Clone(TYetkiliSurucu(Result).FAdSoyad);
  FAciklama.Clone(TYetkiliSurucu(Result).FAciklama);
  FIsGorevVerebilir.Clone(TYetkiliSurucu(Result).FIsGorevVerebilir);
  FIsAracSurebilir.Clone(TYetkiliSurucu(Result).FIsAracSurebilir);
  FIsActive.Clone(TYetkiliSurucu(Result).FIsActive);
end;

end.
