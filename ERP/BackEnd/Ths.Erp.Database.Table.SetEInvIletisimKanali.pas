unit Ths.Erp.Database.Table.SetEInvIletisimKanali;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TAyarEFaturaIletisimKanali = class(TTable)
  private
    FIletisimKanali: TFieldDB;
    FAciklama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property IletisimKanali: TFieldDB read FIletisimKanali write FIletisimKanali;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TAyarEFaturaIletisimKanali.Create(OwnerDatabase:TDatabase);
begin
  TableName := 'set_einv_iletisim_kanali';
  TableSourceCode := '1010';
  inherited Create(OwnerDatabase);

  FIletisimKanali := TFieldDB.Create('iletisim_kanali', ftString, '', Self);
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self);
end;

procedure TAyarEFaturaIletisimKanali.SelectToDatasource(pFilter: string; pPermissionControl: Boolean=True; AHelper: TColWidths=nil);
begin
  if IsAuthorized(ptRead, pPermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FIletisimKanali.FieldName,
        TableName + '.' + FAciklama.FieldName
      ], [
        'WHERE 1=1 ', pFilter
      ]);
      Open;
      Active := True;

      setFieldTitle(Id, 'ID', QueryOfDS);
      setFieldTitle(FIletisimKanali, 'Ýletiþim Kanalý', QueryOfDS);
      setFieldTitle(FAciklama, 'Açýklama', QueryOfDS);
    end;
  end;
end;

procedure TAyarEFaturaIletisimKanali.SelectToList(pFilter: string; pLock: Boolean; pPermissionControl: Boolean=True);
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
        TableName + '.' + FIletisimKanali.FieldName,
        TableName + '.' + FAciklama.FieldName
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

procedure TAyarEFaturaIletisimKanali.Insert(out pID: Integer; pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, pPermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FIletisimKanali.FieldName,
        FAciklama.FieldName
      ]);

      PrepareInsertQueryParams;

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

procedure TAyarEFaturaIletisimKanali.Update(pPermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, pPermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FIletisimKanali.FieldName,
        FAciklama.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TAyarEFaturaIletisimKanali.Clone():TTable;
begin
  Result := TAyarEFaturaIletisimKanali.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
