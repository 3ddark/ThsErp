unit Ths.Erp.Database.Table.SysGridFiltreSiralama;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysGridFiltreSiralama = class(TTable)
  private
    FTabloAdi: TFieldDB;
    FDeger: TFieldDB;
    FIsSiralama: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property Deger: TFieldDB read FDeger write FDeger;
    Property IsSiralama: TFieldDB read FIsSiralama write FIsSiralama;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysGridFiltreSiralama.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_filtre_siralama';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTabloAdi := TFieldDB.Create('tablo_adi', ftString, '', Self, 'Tablo Adý');
  FDeger := TFieldDB.Create('deger', ftString, '', Self, 'Deðer');
  FIsSiralama := TFieldDB.Create('is_siralama', ftBoolean, False, Self, 'Sýralama?');
end;

procedure TSysGridFiltreSiralama.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FDeger.FieldName,
        TableName + '.' + FIsSiralama.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSysGridFiltreSiralama.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FTabloAdi.FieldName,
        TableName + '.' + FDeger.FieldName,
        TableName + '.' + FIsSiralama.FieldName
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

procedure TSysGridFiltreSiralama.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTabloAdi.FieldName,
        FDeger.FieldName,
        FIsSiralama.FieldName
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

procedure TSysGridFiltreSiralama.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTabloAdi.FieldName,
        FDeger.FieldName,
        FIsSiralama.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSysGridFiltreSiralama.Clone: TTable;
begin
  Result := TSysGridFiltreSiralama.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
