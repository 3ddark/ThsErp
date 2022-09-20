unit Ths.Erp.Database.Table.SetChFirmaTipi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetChFirmaTuru;

type
  TSetChFirmaTipi = class(TTable)
  private
    FFirmaTipi: TFieldDB;
    FFirmaTuruID: TFieldDB;
    FFirmaTuru: TFieldDB;
  protected
    FSetChFirmaTuru: TSetChFirmaTuru;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FirmaTipi: TFieldDB read FFirmaTipi write FFirmaTipi;
    Property FirmaTuruID: TFieldDB read FFirmaTuruID write FFirmaTuruID;
    Property FirmaTuru: TFieldDB read FFirmaTuru write FFirmaTuru;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetChFirmaTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_firma_tipi';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FSetChFirmaTuru := TSetChFirmaTuru.Create(Database);

  FFirmaTipi := TFieldDB.Create('firma_tipi', ftWideString, '', Self, 'Firma Tipi');
  FFirmaTuruID := TFieldDB.Create('firma_turu_id', ftInteger, 0, Self, 'Firma Türü ID');
  FFirmaTuru := TFieldDB.Create(FSetChFirmaTuru.FirmaTuru.FieldName, FSetChFirmaTuru.FirmaTuru.DataType, '', Self, 'Firma Türü');
end;

destructor TSetChFirmaTipi.Destroy;
begin
  FSetChFirmaTuru.Free;
  inherited;
end;

procedure TSetChFirmaTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FFirmaTuruID.QryName,
        addLangField(FirmaTuru.FieldName),
        FFirmaTipi.QryName
      ], [
        addLeftJoin(FirmaTuru.FieldName, FirmaTuruID.FieldName, FSetChFirmaTuru.TableName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TSetChFirmaTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Id.QryName,
        FFirmaTuruID.QryName,
        addLangField(FirmaTuru.FieldName),
        FFirmaTipi.QryName
      ], [
        addLeftJoin(FirmaTuru.FieldName, FirmaTuruID.FieldName, FSetChFirmaTuru.TableName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TSetChFirmaTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FFirmaTipi.FieldName,
        FFirmaTuruID.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Id.FieldName).AsInteger
      else
        AID := 0;

      EmptyDataSet;
      Close;
    end;
    Notify;
  end;
end;

procedure TSetChFirmaTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FFirmaTipi.FieldName,
        FFirmaTuruID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Notify;
  end;
end;

function TSetChFirmaTipi.Clone: TTable;
begin
  Result := TSetChFirmaTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
