unit Ths.Erp.Database.Table.SetChHesapTipi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TChHesapTipi = (Ana=1, Ara, Son);

  TSetChHesapTipi = class(TTable)
  private
    FHesapTipi: TFieldDB;
    FIsAnaHesap: TFieldDB;
    FIsAraHesap: TFieldDB;
    FIsSonHesap: TFieldDB;
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

    Property HesapTipi: TFieldDB read FHesapTipi write FHesapTipi;
    Property IsAnaHesap: TFieldDB read FIsAnaHesap write FIsAnaHesap;
    Property IsAraHesap: TFieldDB read FIsAraHesap write FIsAraHesap;
    Property IsSonHesap: TFieldDB read FIsSonHesap write FIsSonHesap;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSetChHesapTipi.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_hesap_tipi';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FHesapTipi := TFieldDB.Create('hesap_tipi', ftString, '', Self, 'Hesap Tipi');
  FIsAnaHesap := TFieldDB.Create('is_ana_hesap', ftBoolean, False, Self, 'Ana Hesap');
  FIsAraHesap := TFieldDB.Create('is_ara_hesap', ftBoolean, False, Self, 'Ara Hesap');
  FIsSonHesap := TFieldDB.Create('is_son_hesap', ftBoolean, False, Self, 'Son Hesap');
end;

procedure TSetChHesapTipi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHesapTipi.FieldName,
        TableName + '.' + FIsAnaHesap.FieldName,
        TableName + '.' + FIsAraHesap.FieldName,
        TableName + '.' + FIsSonHesap.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'ID', QueryOfDS);
      setFieldTitle(FHesapTipi, 'Hesap Tipi', QueryOfDS);
      setFieldTitle(FIsAnaHesap, 'Ana Hesap?', QueryOfDS);
      setFieldTitle(FIsAraHesap, 'Ara Hesap?', QueryOfDS);
      setFieldTitle(FIsAraHesap, 'Son Hesap?', QueryOfDS);
    end;
  end;
end;

procedure TSetChHesapTipi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FHesapTipi.FieldName,
        TableName + '.' + FIsAnaHesap.FieldName,
        TableName + '.' + FIsAraHesap.FieldName,
        TableName + '.' + FIsSonHesap.FieldName
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

procedure TSetChHesapTipi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHesapTipi.FieldName,
        FIsAnaHesap.FieldName,
        FIsAraHesap.FieldName,
        FIsSonHesap.FieldName
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

procedure TSetChHesapTipi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHesapTipi.FieldName,
        FIsAnaHesap.FieldName,
        FIsAraHesap.FieldName,
        FIsSonHesap.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSetChHesapTipi.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  v: TSetChHesapTipi;
  n1: Integer;
begin
  v := TSetChHesapTipi.Create(Database);
  try
    v.SelectToList('', False, False);
    for n1 := 0 to v.List.Count-1 do
    begin
      if FIsAnaHesap.Value = True then
      begin
        if TSetChHesapTipi(v.List[n1]).FIsAnaHesap.Value then
        begin
          TSetChHesapTipi(v.List[n1]).FIsAnaHesap.Value := False;
          TSetChHesapTipi(v.List[n1]).Update(False);
        end;
      end;

      if FIsAraHesap.Value = True then
      begin
        if TSetChHesapTipi(v.List[n1]).FIsAraHesap.Value then
        begin
          TSetChHesapTipi(v.List[n1]).FIsAraHesap.Value := False;
          TSetChHesapTipi(v.List[n1]).Update(False);
        end;
      end;

      if FIsSonHesap.Value = True then
      begin
        if TSetChHesapTipi(v.List[n1]).FIsSonHesap.Value then
        begin
          TSetChHesapTipi(v.List[n1]).FIsSonHesap.Value := False;
          TSetChHesapTipi(v.List[n1]).Update(False);
        end;
      end;
    end;
  finally
    v.Free;
  end;

  Self.Insert(AID, APermissionControl);
end;

procedure TSetChHesapTipi.BusinessUpdate(APermissionControl: Boolean);
var
  v: TSetChHesapTipi;
  n1: Integer;
begin
  v := TSetChHesapTipi.Create(Database);
  try
    v.SelectToList(' AND ' + v.TableName + '.' + v.Id.FieldName + '!=' + VarToStr(Id.Value), False, False);
    for n1 := 0 to v.List.Count-1 do
    begin
      if FIsAnaHesap.Value = True then
      begin
        if TSetChHesapTipi(v.List[n1]).FIsAnaHesap.Value then
        begin
          TSetChHesapTipi(v.List[n1]).FIsAnaHesap.Value := False;
          TSetChHesapTipi(v.List[n1]).Update(False);
        end;
      end;

      if FIsAraHesap.Value = True then
      begin
        if TSetChHesapTipi(v.List[n1]).FIsAraHesap.Value then
        begin
          TSetChHesapTipi(v.List[n1]).FIsAraHesap.Value := False;
          TSetChHesapTipi(v.List[n1]).Update(False);
        end;
      end;

      if FIsSonHesap.Value = True then
      begin
        if TSetChHesapTipi(v.List[n1]).FIsSonHesap.Value then
        begin
          TSetChHesapTipi(v.List[n1]).FIsSonHesap.Value := False;
          TSetChHesapTipi(v.List[n1]).Update(False);
        end;
      end;
    end;
  finally
    v.Free;
  end;

  Self.Update(APermissionControl);
end;

function TSetChHesapTipi.Clone: TTable;
begin
  Result := TSetChHesapTipi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
