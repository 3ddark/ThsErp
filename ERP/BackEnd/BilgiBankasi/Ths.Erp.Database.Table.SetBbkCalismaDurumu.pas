unit Ths.Erp.Database.Table.SetBbkCalismaDurumu;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TBbkCalismaDurumu = (Calisabilir=1, Calisiyor, Calisamaz);
  TSetBbkCalismaDurumu = class(TTable)
  private
    FCalismaDurumu: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property CalismaDurumu: TFieldDB read FCalismaDurumu write FCalismaDurumu;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TSetBbkCalismaDurumu.Create(ADatabase: TDatabase);
begin
  TableName := 'set_bbk_calisma_durumu';
  TableSourceCode := MODULE_BBK_AYAR;
  inherited Create(ADatabase);

  FCalismaDurumu := TFieldDB.Create('calisma_durumu', ftWideString, '', Self, '');
end;

procedure TSetBbkCalismaDurumu.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FCalismaDurumu.QryName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TSetBbkCalismaDurumu.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FCalismaDurumu.QryName
      ], [
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

procedure TSetBbkCalismaDurumu.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpInsert.ExecProc;
      AID := SpInsert.ParamByName('result').AsInteger;
      Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfInsert do
      begin
        Close;
        SQL.Clear;

        SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
          FCalismaDurumu.FieldName
        ]);

        PrepareInsertQueryParams;

        Open;
        if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
        then  AID := Fields.FieldByName(Id.FieldName).AsInteger
        else  AID := 0;

        EmptyDataSet;
        Close;
      end;
      Notify;
    {$ENDIF}
  end;
end;

procedure TSetBbkCalismaDurumu.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpUpdate.ExecProc;
      Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfUpdate do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
          FCalismaDurumu.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
      Notify;
    {$ENDIF}
  end;
end;

function TSetBbkCalismaDurumu.Clone: TTable;
begin
  Result := TSetBbkCalismaDurumu.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
