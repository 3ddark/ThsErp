unit Ths.Erp.Database.Table.ChTemsilciGrupTuru;

interface

{$I ThsERP.inc}

uses
    Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TChTemsilciGrupTuru = class(TTable)
  private
    FTemsilciGrupTuru: TFieldDB;
  protected
  published
    constructor Create(OwnerDatabase:TDatabase); override;
  public
    procedure SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True); override;
    procedure Insert(out pID: Integer; pPermissionControl: Boolean=True); override;
    procedure Update(pPermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TemsilciGrupTuru: TFieldDB read FTemsilciGrupTuru write FTemsilciGrupTuru;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TChTemsilciGrupTuru.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'ch_temsilci_grup_turu';
  TableSourceCode := '1000';
  inherited Create(OwnerDatabase);

  FTemsilciGrupTuru := TFieldDB.Create('temsilci_grup_turu', ftString, '', Self, 'Temsilci Grup Türü');
end;

procedure TChTemsilciGrupTuru.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        FTemsilciGrupTuru.FieldName
      ], [
        'WHERE 1=1 ', pFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTemsilciGrupTuru, 'Temsilci Grup Türü', QueryOfDS);
    end;
  end;
end;

procedure TChTemsilciGrupTuru.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        FTemsilciGrupTuru.FieldName
      ], [
        'WHERE 1=1 ', pFilter
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

procedure TChTemsilciGrupTuru.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTemsilciGrupTuru.FieldName
      ]);

      NewParamForQuery(QueryOfInsert, FTemsilciGrupTuru);

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

procedure TChTemsilciGrupTuru.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTemsilciGrupTuru.FieldName
      ]);

      NewParamForQuery(QueryOfUpdate, FTemsilciGrupTuru);

      NewParamForQuery(QueryOfUpdate, Id);

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TChTemsilciGrupTuru.Clone():TTable;
begin
  Result := TChTemsilciGrupTuru.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
