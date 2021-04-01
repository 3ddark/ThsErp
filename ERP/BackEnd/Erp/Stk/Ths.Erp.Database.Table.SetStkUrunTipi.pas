unit Ths.Erp.Database.Table.SetStkUrunTipi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSetStkUrunTipi = class(TTable)
  private
    FUrunTipi: TFieldDB;
    FIsHammadde: TFieldDB;
    FIsYariMamul: TFieldDB;
    FIsMamul: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property UrunTipi: TFieldDB read FUrunTipi write FUrunTipi;
    Property IsHammadde: TFieldDB read FIsHammadde write FIsHammadde;
    Property IsYariMamul: TFieldDB read FIsYariMamul write FIsYariMamul;
    Property IsMamul: TFieldDB read FIsMamul write FIsMamul;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetStkUrunTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_stk_urun_tipi';
  TableSourceCode := MODULE_STK_AYAR;
  inherited Create(ADatabase);

  FUrunTipi := TFieldDB.Create('urun_tipi', ftString, '', Self, 'Tip');
  FIsHammadde := TFieldDB.Create('is_hammadde', ftBoolean, False, Self, 'Hammadde?');
  FIsYariMamul := TFieldDB.Create('is_yari_mamul', ftBoolean, False, Self, 'Yarý Mamül?');
  FIsMamul := TFieldDB.Create('is_mamul', ftBoolean, False, Self, 'Mamül?');
end;

procedure TSetStkUrunTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FUrunTipi.FieldName,
        TableName + '.' + FIsHammadde.FieldName,
        TableName + '.' + FIsYariMamul.FieldName,
        TableName + '.' + FIsMamul.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSetStkUrunTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FUrunTipi.FieldName,
        TableName + '.' + FIsHammadde.FieldName,
        TableName + '.' + FIsYariMamul.FieldName,
        TableName + '.' + FIsMamul.FieldName
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

procedure TSetStkUrunTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FUrunTipi.FieldName,
        FIsHammadde.FieldName,
        FIsYariMamul.FieldName,
        FIsMamul.FieldName
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

procedure TSetStkUrunTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FUrunTipi.FieldName,
        FIsHammadde.FieldName,
        FIsYariMamul.FieldName,
        FIsMamul.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TSetStkUrunTipi.Clone: TTable;
begin
  Result := TSetStkUrunTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
