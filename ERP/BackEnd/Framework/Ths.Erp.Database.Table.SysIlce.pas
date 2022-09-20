unit Ths.Erp.Database.Table.SysIlce;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysSehir,
  Ths.Erp.Database.Table.SysUlke;

type
  TSysIlce = class(TTable)
  private
    FIlceAdi: TFieldDB;
    FSehirId: TFieldDB;
    FSehirAdi: TFieldDB;

    FSysSehir: TSysSehir;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IlceAdi: TFieldDB read FIlceAdi write FIlceAdi;
    Property SehirId: TFieldDB read FSehirId write FSehirId;
    Property SehirAdi: TFieldDB read FSehirAdi write FSehirAdi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TSysIlce.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ilce';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FSysSehir := TSysSehir.Create(ADatabase);

  FIlceAdi := TFieldDB.Create('ilce_adi', ftWideString, '', Self, 'Ýlçe Adý');
  FSehirId := TFieldDB.Create('sehir_id', ftInteger, 0, Self, 'Þehir Id');
  FSehirAdi := TFieldDB.Create(FSysSehir.SehirAdi.FieldName, FSysSehir.SehirAdi.DataType, '', Self, 'Þehir Adý');
end;

destructor TSysIlce.Destroy;
begin
  FreeAndNil(FSysSehir);
  inherited;
end;

procedure TSysIlce.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Id.QryName,
        FIlceAdi.QryName,
        FSehirId.QryName,
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehirAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirId.FieldName),
        ' WHERE 1=1 ' + AFilter
      ], AAllColumn, AHelper);
      Open;
    end;
  end;
end;

procedure TSysIlce.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
      AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT; ';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Id.QryName,
        FIlceAdi.QryName,
        FSehirId.QryName,
        addField(FSysSehir.TableName, FSysSehir.SehirAdi.FieldName, FSehirAdi.FieldName)
      ], [
        addJoin(jtLeft, FSysSehir.TableName, FSysSehir.Id.FieldName, TableName, FSehirId.FieldName),
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
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
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
