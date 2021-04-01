unit Ths.Erp.Database.Table.SetUtdDokumanTipi;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSetUtdDokumanTipi = class(TTable)
  private
    FDokumanTipi: TFieldDB;
    FAltKlasor: TFieldDB;
  protected
  published
    constructor Create(ADataBase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property DokumanTipi: TFieldDB read FDokumanTipi write FDokumanTipi;
    Property AltKlasor: TFieldDB read FAltKlasor write FAltKlasor;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSetUtdDokumanTipi.Create(ADataBase: TDatabase);
begin
  TableName := 'set_utd_dokuman_tipi';
  TableSourceCode := '7410';
  inherited Create(ADataBase);

  FDokumanTipi := TFieldDB.Create('dokuman_tipi', ftString, '', Self, 'Döküman Tipi');
  FAltKlasor := TFieldDB.Create('alt_klasor', ftString, '', Self, 'Alt Klasör');
end;

procedure TSetUtdDokumanTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FDokumanTipi.FieldName,
        TableName + '.' + FAltKlasor.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FDokumanTipi, 'Dokuman Tipi', QueryOfDS);
      setFieldTitle(FAltKlasor, 'Alt Klasör', QueryOfDS);
    end;
  end;
end;

procedure TSetUtdDokumanTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FDokumanTipi.FieldName,
        TableName + '.' + FAltKlasor.FieldName
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

procedure TSetUtdDokumanTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpInsert.ExecProc;
      AID := SpInsert.ParamByName('result').AsInteger;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfInsert do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
          FDokumanTipi.FieldName,
          FAltKlasor.FieldName
        ]);

        PrepareInsertQueryParams;

        Open;
        if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
          AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
        else
          AID := 0;

        EmptyDataSet;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

procedure TSetUtdDokumanTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpUpdate.ExecProc;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfUpdate do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
          FDokumanTipi.FieldName,
          FAltKlasor.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

function TSetUtdDokumanTipi.Clone: TTable;
begin
  Result := TSetUtdDokumanTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
