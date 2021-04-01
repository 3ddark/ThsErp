unit Ths.Erp.Database.Table.SysIlce;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysIlce = class(TTable)
  private
    FIlceAdi: TFieldDB;
    FSehirId: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IlceAdi: TFieldDB read FIlceAdi write FIlceAdi;
    Property SehirId: TFieldDB read FSehirId write FSehirId;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysIlce.Create(ADatabase: TDatabase);
begin
  inherited Create(ADatabase);
  TableName := 'sys_ilce';
  TableSourceCode := '1000';

  FIlceAdi := TFieldDB.Create('ilce_adi', ftWideString, '', Self, 'IlceAdi');
  FSehirId := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'SehirId');
end;

procedure TSysIlce.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLSelectCmd(TableName, [
        TableName + '.' + Self.Id.FieldName,
        FIlceAdi.FieldName,
        FSehirId.FieldName
      ], [
        'WHERE 1=1 ' + AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysIlce.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
      AFilter := AFilter + ' FOR UPDATE NOWAIT; ';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        FIlceAdi.FieldName,
        FSehirId.FieldName
      ], [
        'WHERE 1=1 ', AFilter
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

procedure TSysIlce.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIlceAdi.FieldName,
        FSehirId.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSysIlce.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH [
        FIlceAdi.FieldName,
        FSehirId.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysIlce.Clone: TTable;
begin
  Result := TSysIlce.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
