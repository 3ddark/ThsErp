unit Ths.Erp.Database.Table.ChTemsilciGrup;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,

  Ths.Erp.Database.Table.ChTemsilciGrupTuru
  ;

type
  TChTemsilciGrup = class(TTable)
  private
    FTemsilciGrupTuruID: TFieldDB;
    FTemsilciGrupTuru: TFieldDB;
    FTemsilciGrup: TFieldDB;

    FTemsilciGrupTurleri: TChTemsilciGrupTuru;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase);override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone():TTable;override;
    destructor Destroy; override;

    Property TemsilciGrupTuruID: TFieldDB read FTemsilciGrupTuruID write FTemsilciGrupTuruID;
    Property TemsilciGrupTuru: TFieldDB read FTemsilciGrupTuru write FTemsilciGrupTuru;
    Property TemsilciGrup: TFieldDB read FTemsilciGrup write FTemsilciGrup;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TChTemsilciGrup.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'ch_temsilci_grup';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FTemsilciGrupTurleri := TChTemsilciGrupTuru.Create(Database);

  FTemsilciGrupTuruID := TFieldDB.Create('temsilci_grup_turu_id', ftInteger, 0, Self, 'Temsilci Grup Türü ID');
  FTemsilciGrupTuru := TFieldDB.Create(FTemsilciGrupTurleri.TemsilciGrupTuru.FieldName, FTemsilciGrupTurleri.TemsilciGrupTuru.DataType, '', Self, 'Temsilci Grup Türü');
  FTemsilciGrup := TFieldDB.Create('temsilci_grup', ftString, '', Self, 'Temsilci Grup');
end;

destructor TChTemsilciGrup.Destroy;
begin
  FTemsilciGrupTurleri.Free;
  inherited;
end;

procedure TChTemsilciGrup.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTemsilciGrupTuruID.FieldName,
        addLangField(FTemsilciGrupTuru.FieldName),
        FTemsilciGrup.FieldName
      ], [
        addLeftJoin(FTemsilciGrupTuru.FieldName, FTemsilciGrupTuruID.FieldName, FTemsilciGrupTurleri.TableName),
        'WHERE 1=1 ' + pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTemsilciGrupTuruID, 'Temsilci Grup Türü ID', QueryOfDS);
      setFieldTitle(FTemsilciGrupTuru, 'Temsilci Grup Türü', QueryOfDS);
      setFieldTitle(FTemsilciGrup, 'Temsilci Grup', QueryOfDS);
    end;
  end;
end;

procedure TChTemsilciGrup.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FTemsilciGrupTuruID.FieldName,
        addLangField(FTemsilciGrupTuru.FieldName),
        FTemsilciGrup.FieldName
      ], [
        addLeftJoin(FTemsilciGrupTuru.FieldName, FTemsilciGrupTuruID.FieldName, FTemsilciGrupTurleri.TableName),
        'WHERE 1=1 ' + pFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        setFieldValue(Self.Id, QueryOfList);
        setFieldValue(FTemsilciGrupTuruID, QueryOfList);
        setFieldValue(FTemsilciGrupTuru, QueryOfList);
        setFieldValue(FTemsilciGrup, QueryOfList);

        List.Add(Self.Clone());

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TChTemsilciGrup.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTemsilciGrupTuruID.FieldName,
        FTemsilciGrup.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FTemsilciGrupTuruID);
      NewParamForQuery(QueryOfInsert, FTemsilciGrup);

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

procedure TChTemsilciGrup.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTemsilciGrupTuruID.FieldName,
        FTemsilciGrup.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FTemsilciGrupTuruID);
      NewParamForQuery(QueryOfUpdate, FTemsilciGrup);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TChTemsilciGrup.Clone():TTable;
begin
  Result := TChTemsilciGrup.Create(Database);

  Self.Id.Clone(TChTemsilciGrup(Result).Id);

  FTemsilciGrupTuruID.Clone(TChTemsilciGrup(Result).FTemsilciGrupTuruID);
  FTemsilciGrupTuru.Clone(TChTemsilciGrup(Result).FTemsilciGrupTuru);
  FTemsilciGrup.Clone(TChTemsilciGrup(Result).FTemsilciGrup);
end;

end.
