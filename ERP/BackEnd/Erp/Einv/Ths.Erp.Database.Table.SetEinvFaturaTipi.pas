unit Ths.Erp.Database.Table.SetEinvFaturaTipi;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TEinvFaturaTipi = (Satis=1, Iade, Tevkifat, Istisna, OzelMatrah, IhracKayitli);
  TSetEinvFaturaTipi = class(TTable)
  private
    FFaturaTipi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FaturaTipi: TFieldDB read FFaturaTipi write FFaturaTipi;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSetEinvFaturaTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_einv_fatura_tipi';
  TableSourceCode := '1010';
  inherited Create(ADatabase);

  FFaturaTipi := TFieldDB.Create('fatura_tipi', ftString, '', Self, 'Fatura Tipi');
end;

procedure TSetEinvFaturaTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        FFaturaTipi.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FFaturaTipi, 'Fatura Tipi', QueryOfDS);
    end;
  end;
end;

procedure TSetEinvFaturaTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FFaturaTipi.FieldName
      ], [
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

procedure TSetEinvFaturaTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FFaturaTipi.FieldName
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

procedure TSetEinvFaturaTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FFaturaTipi.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetEinvFaturaTipi.Clone: TTable;
begin
  Result := TSetEinvFaturaTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
