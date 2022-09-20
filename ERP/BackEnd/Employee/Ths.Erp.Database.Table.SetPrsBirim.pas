unit Ths.Erp.Database.Table.SetPrsBirim;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetPrsBolum;

type
  TSetPrsBirim = class(TTable)
  private
    FBolumID: TFieldDB;
    FBolum: TFieldDB;
    FBirim: TFieldDB;

    FSetPrsBolum: TSetPrsBolum;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property BolumID: TFieldDB read FBolumID write FBolumID;
    Property Bolum: TFieldDB read FBolum write FBolum;
    Property Birim: TFieldDB read FBirim write FBirim;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

  constructor TSetPrsBirim.Create(ADatabase:TDatabase);
begin
  TableName := 'set_prs_birim';
  TableSourceCode := MODULE_PRS_AYAR;
  inherited Create(ADatabase);

  FSetPrsBolum := TSetPrsBolum.Create(Database);

  FBolumID := TFieldDB.Create('bolum_id', ftInteger, 0, Self, 'Bölüm ID');
  FBolum := TFieldDB.Create(FSetPrsBolum.Bolum.FieldName, FSetPrsBolum.Bolum.DataType, '', Self, 'Bölüm');
  FBirim := TFieldDB.Create('birim', ftWideString, '', Self, 'Birim');
end;

destructor TSetPrsBirim.Destroy;
begin
  FreeAndNil(FSetPrsBolum);
  inherited;
end;

procedure TSetPrsBirim.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FBolumID.QryName,
        addField(FSetPrsBolum.TableName, FSetPrsBolum.Bolum.FieldName, FBolum.FieldName),
        FBirim.QryName
      ], [
        addJoin(jtLeft, FSetPrsBolum.TableName, FSetPrsBolum.Id.FieldName, TableName, FBolumID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TSetPrsBirim.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FBolumID.QryName,
        addField(FSetPrsBolum.TableName, FSetPrsBolum.Bolum.FieldName, FBolum.FieldName),
        FBirim.QryName
      ], [
        addJoin(jtLeft, FSetPrsBolum.TableName, FSetPrsBolum.Id.FieldName, TableName, FBolumID.FieldName),
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

procedure TSetPrsBirim.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpInsert.ExecProc;
      AID := SpInsert.ParamByName('result').AsInteger;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfInsert do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
          FBolumID.FieldName,
          FBirim.FieldName
        ]);

        PrepareInsertQueryParams;

        Open;
        if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
        then  AID := Fields.FieldByName(Id.FieldName).AsInteger
        else  AID := 0;

        EmptyDataSet;
        Close;
      end;
    {$ENDIF}
    Notify;
  end;
end;

procedure TSetPrsBirim.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpUpdate.ExecProc;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfUpdate do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
          FBolumID.FieldName,
          FBirim.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
    {$ENDIF}
    Notify;
  end;
end;

function TSetPrsBirim.Clone: TTable;
begin
  Result := TSetPrsBirim.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
