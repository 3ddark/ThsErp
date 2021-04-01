unit Ths.Erp.Database.Table.StkStokAmbar;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TStkStokAmbar = class(TTable)
  private
    FAmbarAdi: TFieldDB;
    FIsHammaddeAmbari: TFieldDB;
    FIsUretimAmbari: TFieldDB;
    FIsSatisAmbari: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property AmbarAdi: TFieldDB read FAmbarAdi write FAmbarAdi;
    Property IsHammaddeAmbari: TFieldDB read FIsHammaddeAmbari write FIsHammaddeAmbari;
    Property IsUretimAmbari: TFieldDB read FIsUretimAmbari write FIsUretimAmbari;
    Property IsSatisAmbari: TFieldDB read FIsSatisAmbari write FIsSatisAmbari;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TStkStokAmbar.Create(ADatabase: TDatabase);
begin
  TableName := 'stk_stok_ambar';
  TableSourceCode := MODULE_STK_KAYIT;
  inherited Create(ADatabase);

  FAmbarAdi := TFieldDB.Create('ambar_adi', ftString, '', Self, 'Ambar Adý');
  FIsHammaddeAmbari := TFieldDB.Create('is_hammadde_ambari', ftBoolean, False, Self, 'Hammadde Ambarý');
  FIsUretimAmbari := TFieldDB.Create('is_uretim_ambari', ftBoolean, False, Self, 'Üretim Ambarý');
  FIsSatisAmbari := TFieldDB.Create('is_satis_ambari', ftBoolean, False, Self, 'Satýþ Ambarý');
end;

procedure TStkStokAmbar.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FAmbarAdi.FieldName,
        TableName + '.' + FIsHammaddeAmbari.FieldName,
        TableName + '.' + FIsUretimAmbari.FieldName,
        TableName + '.' + FIsSatisAmbari.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TStkStokAmbar.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
        TableName + '.' + FAmbarAdi.FieldName,
        TableName + '.' + FIsHammaddeAmbari.FieldName,
        TableName + '.' + FIsUretimAmbari.FieldName,
        TableName + '.' + FIsSatisAmbari.FieldName
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

procedure TStkStokAmbar.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FAmbarAdi.FieldName,
        FIsHammaddeAmbari.FieldName,
        FIsUretimAmbari.FieldName,
        FIsSatisAmbari.FieldName
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

procedure TStkStokAmbar.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FAmbarAdi.FieldName,
        FIsHammaddeAmbari.FieldName,
        FIsUretimAmbari.FieldName,
        FIsSatisAmbari.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

function TStkStokAmbar.Clone: TTable;
begin
  Result := TStkStokAmbar.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
