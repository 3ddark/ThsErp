unit Ths.Erp.Database.Table.SetStkStokTipi;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSetStkStokTipi = class(TTable)
  private
    FTip: TFieldDB;
    FIsDefault: TFieldDB;
    FIsStokHareketiYap: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property Tip: TFieldDB read FTip write FTip;
    Property IsDefault: TFieldDB read FIsDefault write FIsDefault;
    Property IsStokHareketiYap: TFieldDB read FIsStokHareketiYap write FIsStokHareketiYap;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSetStkStokTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_stk_stok_tipi';
  TableSourceCode := '1000';
  inherited Create(ADatabase);

  FTip := TFieldDB.Create('tip', ftString, '', Self);
  FIsDefault := TFieldDB.Create('is_default', ftBoolean, False, Self);
  FIsStokHareketiYap := TFieldDB.Create('is_stok_hareketi_yap', ftBoolean, False, Self);
end;

procedure TSetStkStokTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        FTip.FieldName,
        TableName + '.' + FIsDefault.FieldName,
        TableName + '.' + FIsStokHareketiYap.FieldName
      ], [
        'WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FTip, 'Tip', QueryOfDS);
      setFieldTitle(FIsDefault, 'Default?', QueryOfDS);
      setFieldTitle(FIsStokHareketiYap, 'Stok Hareketi Yap?', QueryOfDS);
    end;
  end;
end;

procedure TSetStkStokTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        FTip.FieldName,
        TableName + '.' + FIsDefault.FieldName,
        TableName + '.' + FIsStokHareketiYap.FieldName
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

procedure TSetStkStokTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTip.FieldName,
        FIsDefault.FieldName,
        FIsStokHareketiYap.FieldName
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

procedure TSetStkStokTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTip.FieldName,
        FIsDefault.FieldName,
        FIsStokHareketiYap.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSetStkStokTipi.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  vStokTipi: TSetStkStokTipi;
  n1: Integer;
begin
  if FormatedVariantVal(Self.IsDefault.DataType, Self.IsDefault.Value) = True then
  begin
    vStokTipi := TSetStkStokTipi.Create(Database);
    try
      vStokTipi.SelectToList(' and ' + vStokTipi.TableName + '.' + vStokTipi.FIsDefault.FieldName + '=True', False, False);
      for n1 := 0 to vStokTipi.List.Count-1 do
      begin
        TSetStkStokTipi(vStokTipi.List[n1]).IsDefault.Value := False;
        TSetStkStokTipi(vStokTipi.List[n1]).Update();
      end;
    finally
      vStokTipi.Free;
    end;
    Self.Insert(AID, APermissionControl);
  end
  else
    Self.Insert(AID);
end;

procedure TSetStkStokTipi.BusinessUpdate(APermissionControl: Boolean);
var
  vStokTipi: TSetStkStokTipi;
  n1: Integer;
begin
  if FormatedVariantVal(Self.IsDefault.DataType, Self.IsDefault.Value) = True then
  begin
    vStokTipi := TSetStkStokTipi.Create(Database);
    try
      vStokTipi.SelectToList(' and ' + vStokTipi.TableName + '.' + vStokTipi.FIsDefault.FieldName + '=True', False, False);
      for n1 := 0 to vStokTipi.List.Count-1 do
      begin
        TSetStkStokTipi(vStokTipi.List[n1]).IsDefault.Value := False;
        TSetStkStokTipi(vStokTipi.List[n1]).Update();
      end;
    finally
      vStokTipi.Free;
    end;
    Self.Update(APermissionControl);
  end
  else
    Self.Update(APermissionControl);
end;

function TSetStkStokTipi.Clone: TTable;
begin
  Result := TSetStkStokTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
