unit Ths.Erp.Database.Table.SetStkBarkodTezgah;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.StkStokAmbar
  ;

type
  TAyarBarkodTezgah = class(TTable)
  private
    FTezgahAdi: TFieldDB;
    FAmbarID: TFieldDB;
    FAmbar: TFieldDB;
  protected
    FStokAmbar: TStkStokAmbar;
  published
    destructor Destroy; override;
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TezgahAdi: TFieldDB read FTezgahAdi write FTezgahAdi;
    Property AmbarID: TFieldDB read FAmbarID write FAmbarID;
    Property Ambar: TFieldDB read FAmbar write FAmbar;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TAyarBarkodTezgah.Create(ADatabase: TDatabase);
begin
  TableName := 'set_stk_barkod_tezgah';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FStokAmbar := TStkStokAmbar.Create(Database);

  FTezgahAdi := TFieldDB.Create('tezgah_adi', ftString, '', Self);
  FAmbarID := TFieldDB.Create('ambar_id', ftInteger, 0, Self);
  FAmbar := TFieldDB.Create(FStokAmbar.AmbarAdi.FieldName, FStokAmbar.AmbarAdi.DataType, '', Self);
end;

destructor TAyarBarkodTezgah.Destroy;
begin
  FStokAmbar.Free;
  inherited;
end;

procedure TAyarBarkodTezgah.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        FTezgahAdi.FieldName,
        TableName + '.' + FAmbarID.FieldName,
        addLangField(FAmbar.FieldName)
      ], [
        addLeftJoin(FAmbar.FieldName, FAmbarID.FieldName, FStokAmbar.TableName),
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTezgahAdi, 'Tezgah Adý', QueryOfDS);
      setFieldTitle(FAmbarID, 'Ambar ID', QueryOfDS);
      setFieldTitle(FAmbar, 'Ambar', QueryOfDS);
    end;
  end;
end;

procedure TAyarBarkodTezgah.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FTezgahAdi.FieldName,
        TableName + '.' + FAmbarID.FieldName,
        addLangField(FAmbar.FieldName)
      ], [
        addLeftJoin(FAmbar.FieldName, FAmbarID.FieldName, FStokAmbar.TableName),
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

procedure TAyarBarkodTezgah.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTezgahAdi.FieldName,
        FAmbarID.FieldName
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
    Self.notify;
  end;
end;

procedure TAyarBarkodTezgah.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTezgahAdi.FieldName,
        FAmbarID.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TAyarBarkodTezgah.Clone: TTable;
begin
  Result := TAyarBarkodTezgah.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
