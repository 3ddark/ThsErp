unit Ths.Erp.Database.Table.SysOndalikHane;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSysOndalikHane = class(TTable)
  private
    FHesapBakiye: TFieldDB;
    FAlimMiktar: TFieldDB;
    FAlimFiyat: TFieldDB;
    FAlimTutar: TFieldDB;
    FSatisMiktar: TFieldDB;
    FSatisFiyat: TFieldDB;
    FSatisTutar: TFieldDB;
    FStokMiktar: TFieldDB;
    FStokFiyat: TFieldDB;
    FDovizKuru: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property HesapBakiye: TFieldDB read FHesapBakiye write FHesapBakiye;
    property AlimMiktar: TFieldDB read FAlimMiktar write FAlimMiktar;
    property AlimFiyat: TFieldDB read FAlimFiyat write FAlimFiyat;
    property AlimTutar: TFieldDB read FAlimTutar write FAlimTutar;
    property SatisMiktar: TFieldDB read FSatisMiktar write FSatisMiktar;
    property SatisFiyat: TFieldDB read FSatisFiyat write FSatisFiyat;
    property SatisTutar: TFieldDB read FSatisTutar write FSatisTutar;
    property StokMiktar: TFieldDB read FStokMiktar write FStokMiktar;
    property StokFiyat: TFieldDB read FStokFiyat write FStokFiyat;
    property DovizKuru: TFieldDB read FDovizKuru write FDovizKuru;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysOndalikHane.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ondalik_hane';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FHesapBakiye := TFieldDB.Create('hesap_bakiye', ftInteger, 2, Self, 'Hesap Bakiye');
  FAlimMiktar := TFieldDB.Create('alim_miktar', ftInteger, 2, Self, 'Alým Miktar');
  FAlimFiyat := TFieldDB.Create('alim_fiyat', ftInteger, 2, Self, 'Alým Fiyat');
  FAlimTutar := TFieldDB.Create('alim_tutar', ftInteger, 2, Self, 'Alým Tutar');
  FSatisMiktar := TFieldDB.Create('satis_miktar', ftInteger, 2, Self, 'Satýþ Miktar');
  FSatisFiyat := TFieldDB.Create('satis_fiyat', ftInteger, 2, Self, 'Satýþ Fiyat');
  FSatisTutar := TFieldDB.Create('satis_tutar', ftInteger, 2, Self, 'Satýþ Tutar');
  FStokMiktar := TFieldDB.Create('stok_miktar', ftInteger, 2, Self, 'Stok Miktar');
  FStokFiyat := TFieldDB.Create('stok_fiyat', ftInteger, 2, Self, 'Stok Fiyat');
  FDovizKuru := TFieldDB.Create('doviz_kuru', ftInteger, 4, Self, 'Döviz Kuru');
end;

procedure TSysOndalikHane.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHesapBakiye.FieldName,
        TableName + '.' + FAlimMiktar.FieldName,
        TableName + '.' + FAlimFiyat.FieldName,
        TableName + '.' + FAlimTutar.FieldName,
        TableName + '.' + FSatisMiktar.FieldName,
        TableName + '.' + FSatisFiyat.FieldName,
        TableName + '.' + FSatisTutar.FieldName,
        TableName + '.' + FStokMiktar.FieldName,
        TableName + '.' + FStokFiyat.FieldName,
        TableName + '.' + FDovizKuru.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FHesapBakiye, 'Hesap Bakiye', QueryOfDS);
      setFieldTitle(FAlimMiktar, 'Alýþ Miktar', QueryOfDS);
      setFieldTitle(FAlimFiyat, 'Alýþ Fiyat', QueryOfDS);
      setFieldTitle(FAlimTutar, 'Alýþ Tutar', QueryOfDS);
      setFieldTitle(FSatisMiktar, 'Satýþ Miktar', QueryOfDS);
      setFieldTitle(FSatisFiyat, 'Satýþ Fiyat', QueryOfDS);
      setFieldTitle(FSatisTutar, 'Satýþ Tutar', QueryOfDS);
      setFieldTitle(FStokMiktar, 'Stok Miktar', QueryOfDS);
      setFieldTitle(FStokFiyat, 'Stok Fiyat', QueryOfDS);
      setFieldTitle(FDovizKuru, 'Döviz Kuru', QueryOfDS);
    end;
  end;
end;

procedure TSysOndalikHane.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FHesapBakiye.FieldName,
        TableName + '.' + FAlimMiktar.FieldName,
        TableName + '.' + FAlimFiyat.FieldName,
        TableName + '.' + FAlimTutar.FieldName,
        TableName + '.' + FSatisMiktar.FieldName,
        TableName + '.' + FSatisFiyat.FieldName,
        TableName + '.' + FSatisTutar.FieldName,
        TableName + '.' + FStokMiktar.FieldName,
        TableName + '.' + FStokFiyat.FieldName,
        TableName + '.' + FDovizKuru.FieldName
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

procedure TSysOndalikHane.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHesapBakiye.FieldName,
        FAlimMiktar.FieldName,
        FAlimFiyat.FieldName,
        FAlimTutar.FieldName,
        FSatisMiktar.FieldName,
        FSatisFiyat.FieldName,
        FSatisTutar.FieldName,
        FStokMiktar.FieldName,
        FStokFiyat.FieldName,
        FDovizKuru.FieldName
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

procedure TSysOndalikHane.Update(APermissionControl: Boolean);
begin
  if Self.IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Self.Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHesapBakiye.FieldName,
        FAlimMiktar.FieldName,
        FAlimFiyat.FieldName,
        FAlimTutar.FieldName,
        FSatisMiktar.FieldName,
        FSatisFiyat.FieldName,
        FSatisTutar.FieldName,
        FStokMiktar.FieldName,
        FStokFiyat.FieldName,
        FDovizKuru.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
  Self.notify;
  end;
end;

function TSysOndalikHane.Clone: TTable;
begin
  Result := TSysOndalikHane.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
