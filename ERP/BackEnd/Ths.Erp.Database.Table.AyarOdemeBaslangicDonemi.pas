unit Ths.Erp.Database.Table.AyarOdemeBaslangicDonemi;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TAyarOdemeBaslangicDonemi = class(TTable)
  private
    FDeger: TFieldDB;
    FAciklama: TFieldDB;
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

    Property Deger: TFieldDB read FDeger write FDeger;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsActive: TFieldDB read FIsActive write FIsActive;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TAyarOdemeBaslangicDonemi.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'ayar_odeme_baslangic_donemi';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FDeger := TFieldDB.Create('deger', ftString, '', Self);
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self);
  FIsActive := TFieldDB.Create('is_active', ftBoolean, True, Self);
end;

procedure TAyarOdemeBaslangicDonemi.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FDeger.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        'WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FDeger, 'Deðer', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FIsActive, 'Aktif?', QueryOfDS);
    end;
  end;
end;

procedure TAyarOdemeBaslangicDonemi.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FDeger.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsActive.FieldName
      ], [
        'WHERE 1=1 ', pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FDeger, QueryOfList);
        setFieldValue(FAciklama, QueryOfList);
        setFieldValue(FIsActive, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TAyarOdemeBaslangicDonemi.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FDeger.FieldName,
        FAciklama.FieldName,
        FIsActive.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FDeger);
      NewParamForQuery(QueryOfInsert, FAciklama);
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

procedure TAyarOdemeBaslangicDonemi.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FDeger.FieldName,
        FAciklama.FieldName,
        FIsActive.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FDeger);
      NewParamForQuery(QueryOfUpdate, FAciklama);
      NewParamForQuery(QueryOfUpdate, FIsActive);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TAyarOdemeBaslangicDonemi.Clone():TTable;
begin
  Result := TAyarOdemeBaslangicDonemi.Create(Database);

  Self.Id.Clone(TAyarOdemeBaslangicDonemi(Result).Id);

  FDeger.Clone(TAyarOdemeBaslangicDonemi(Result).FDeger);
  FAciklama.Clone(TAyarOdemeBaslangicDonemi(Result).FAciklama);
  FIsActive.Clone(TAyarOdemeBaslangicDonemi(Result).FIsActive);
end;

end.
