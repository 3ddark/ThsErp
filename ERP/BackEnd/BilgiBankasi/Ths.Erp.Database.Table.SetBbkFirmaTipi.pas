unit Ths.Erp.Database.Table.SetBbkFirmaTipi;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.SetBbkKayitTipi
  ;

type
  TSetBbkFirmaTipi = class(TTable)
  private
    FFirmaTipi: TFieldDB;
    FKayitTipiID: TFieldDB;
    FKayitTipi: TFieldDB;

    FSetBbkKayitTipi: TSetBbkKayitTipi;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FirmaTipi: TFieldDB read FFirmaTipi write FFirmaTipi;
    Property KayitTipiID: TFieldDB read FKayitTipiID write FKayitTipiID;
    Property KayitTipi: TFieldDB read FKayitTipi write FKayitTipi;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSetBbkFirmaTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_bbk_firma_tipi';
  TableSourceCode := '6520';
  inherited Create(ADatabase);

  FSetBbkKayitTipi := TSetBbkKayitTipi.Create(ADatabase);

  FFirmaTipi := TFieldDB.Create('firma_tipi', ftString, '', Self, '');
  FKayitTipiID := TFieldDB.Create('kayit_tipi_id', ftInteger, 0, Self, '');
  FKayitTipi := TFieldDB.Create(FSetBbkKayitTipi.KayitTipi.FieldName, FSetBbkKayitTipi.KayitTipi.DataType, '', Self, '');
end;

destructor TSetBbkFirmaTipi.Destroy;
begin
  FreeAndNil(FSetBbkKayitTipi);
  inherited;
end;

procedure TSetBbkFirmaTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FFirmaTipi.FieldName,
        TableName + '.' + FKayitTipiID.FieldName,
        addField(FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.KayitTipi.FieldName, FKayitTipi.FieldName)
      ], [
        addJoin(jtLeft, FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.Id.FieldName, Self.TableName, FKayitTipiID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FFirmaTipi, 'Firma Tipi', QueryOfDS);
      setFieldTitle(FKayitTipiID, 'Kayýt Tipi ID', QueryOfDS);
      setFieldTitle(FKayitTipi, 'Kayýt Tipi', QueryOfDS);
    end;
  end;
end;

procedure TSetBbkFirmaTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FFirmaTipi.FieldName,
        TableName + '.' + FKayitTipiID.FieldName,
        addField(FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.KayitTipi.FieldName, FKayitTipi.FieldName)
      ], [
        addJoin(jtLeft, FSetBbkKayitTipi.TableName, FSetBbkKayitTipi.Id.FieldName, Self.TableName, FKayitTipiID.FieldName),
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

procedure TSetBbkFirmaTipi.Insert(out AID: Integer; APermissionControl: Boolean);
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
          FFirmaTipi.FieldName,
          FKayitTipiID.FieldName
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

procedure TSetBbkFirmaTipi.Update(APermissionControl: Boolean);
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
          FFirmaTipi.FieldName,
          FKayitTipiID.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

function TSetBbkFirmaTipi.Clone: TTable;
begin
  Result := TSetBbkFirmaTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
