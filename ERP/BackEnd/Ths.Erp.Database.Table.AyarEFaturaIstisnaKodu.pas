unit Ths.Erp.Database.Table.AyarEFaturaIstisnaKodu;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.AyarEFaturaFaturaTipi
  ;

type
  TAyarEFaturaIstisnaKodu = class(TTable)
  private
    FKod: TFieldDB;
    FAciklama: TFieldDB;
    FIsTamIstisna: TFieldDB;
    FFaturaTipID: TFieldDB;
    FFaturaTip: TFieldDB;

    FAyarFaturaTipi: TAyarEFaturaFaturaTipi;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;

    Property Kod: TFieldDB read FKod write FKod;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property IsTamIstisna: TFieldDB read FIsTamIstisna write FIsTamIstisna;
    Property FaturaTipID: TFieldDB read FFaturaTipID write FFaturaTipID;
    Property FaturaTip: TFieldDB read FFaturaTip write FFaturaTip;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TAyarEFaturaIstisnaKodu.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'ayar_efatura_istisna_kodu';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FAyarFaturaTipi := TAyarEFaturaFaturaTipi.Create(Database);

  FKod := TFieldDB.Create('kod', ftString, '', Self);
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self);
  FIsTamIstisna := TFieldDB.Create('is_tam_istisna', ftBoolean, False, Self);
  FFaturaTipID := TFieldDB.Create('fatura_tip_id', ftInteger, 0, Self);
  FFaturaTip := TFieldDB.Create(FAyarFaturaTipi.Tip.FieldName, FAyarFaturaTipi.Tip.DataType, '', Self);
end;

destructor TAyarEFaturaIstisnaKodu.Destroy;
begin
  FAyarFaturaTipi.Free;
  inherited;
end;

procedure TAyarEFaturaIstisnaKodu.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKod.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsTamIstisna.FieldName,
        TableName + '.' + FFaturaTipID.FieldName,
        addLangField(FFaturaTip.FieldName)
      ], [
        addLeftJoin(FFaturaTip.FieldName, FFaturaTipID.FieldName, FAyarFaturaTipi.TableName),
        'WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FKod, 'Kod', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
      setFieldTitle(FIsTamIstisna, 'Tam Ýstisna?', QueryOfDS);
      setFieldTitle(FFaturaTipID, 'Fatura Tip ID', QueryOfDS);
      setFieldTitle(FFaturaTip, 'Fatura Tipi', QueryOfDS);
    end;
  end;
end;

procedure TAyarEFaturaIstisnaKodu.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    if (pLock) then
		  pFilter := pFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKod.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsTamIstisna.FieldName,
        TableName + '.' + FFaturaTipID.FieldName,
        addLangField(FFaturaTip.FieldName)
      ], [
        addLeftJoin(FFaturaTip.FieldName, FFaturaTipID.FieldName, FAyarFaturaTipi.TableName),
        'WHERE 1=1 ', pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FKod, QueryOfList);
        setFieldValue(FAciklama, QueryOfList);
        setFieldValue(FIsTamIstisna, QueryOfList);
        setFieldValue(FFaturaTipID, QueryOfList);
        setFieldValue(FFaturaTip, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TAyarEFaturaIstisnaKodu.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FKod.FieldName,
        FAciklama.FieldName,
        FIsTamIstisna.FieldName,
        FFaturaTipID.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FKod);
      NewParamForQuery(QueryOfInsert, FAciklama);
      NewParamForQuery(QueryOfInsert, FIsTamIstisna);
      NewParamForQuery(QueryOfInsert, FFaturaTipID);

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

procedure TAyarEFaturaIstisnaKodu.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FKod.FieldName,
        FAciklama.FieldName,
        FIsTamIstisna.FieldName,
        FFaturaTipID.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FKod);
      NewParamForQuery(QueryOfUpdate, FAciklama);
      NewParamForQuery(QueryOfUpdate, FFaturaTipID);
      NewParamForQuery(QueryOfUpdate, FIsTamIstisna);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TAyarEFaturaIstisnaKodu.Clone():TTable;
begin
  Result := TAyarEFaturaIstisnaKodu.Create(Database);

  Self.Id.Clone(TAyarEFaturaIstisnaKodu(Result).Id);

  FKod.Clone(TAyarEFaturaIstisnaKodu(Result).FKod);
  FAciklama.Clone(TAyarEFaturaIstisnaKodu(Result).FAciklama);
  FIsTamIstisna.Clone(TAyarEFaturaIstisnaKodu(Result).FIsTamIstisna);
  FFaturaTipID.Clone(TAyarEFaturaIstisnaKodu(Result).FFaturaTipID);
  FFaturaTip.Clone(TAyarEFaturaIstisnaKodu(Result).FFaturaTip);
end;

end.
