unit Ths.Erp.Database.Table.SysUlke;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysUlke = class(TTable)
  private
    FUlkeKodu: TFieldDB;
    FUlkeAdi: TFieldDB;
    FISOYil: TFieldDB;
    FISOCCTLDKod: TFieldDB;
    FIsABUyesi: TFieldDB;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property UlkeKodu: TFieldDB read FUlkeKodu write FUlkeKodu;
    Property UlkeAdi: TFieldDB read FUlkeAdi write FUlkeAdi;
    Property ISOYil: TFieldDB read FISOYil write FISOYil;
    Property ISOCCTLDKod: TFieldDB read FISOCCTLDKod write FISOCCTLDKod;
    Property IsABUyesi: TFieldDB read FIsABUyesi write FIsABUyesi;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSysUlke.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_ulke';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FUlkeKodu := TFieldDB.Create('ulke_kodu', ftString, '', Self, 'Ülke Kodu');
  FUlkeAdi := TFieldDB.Create('ulke_adi', ftString, '', Self, 'Ülke Adı');
  FISOYil := TFieldDB.Create('iso_yil', ftInteger, 0, Self, 'ISO Yıl');
  FISOCCTLDKod := TFieldDB.Create('iso_cctld_kod', ftString, '', Self, 'ISO CCTLD Kod');
  FIsABUyesi := TFieldDB.Create('is_ab_uyesi', ftBoolean, False, Self, 'AB Üyesi?');
end;

procedure TSysUlke.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FUlkeKodu.FieldName,
        TableName + '.' + FUlkeAdi.FieldName,
        TableName + '.' + FISOYil.FieldName,
        TableName + '.' + FISOCCTLDKod.FieldName,
        TableName + '.' + FIsABUyesi.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);

		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FUlkeKodu, 'Ülke Kodu', QueryOfDS);
      setFieldTitle(FUlkeAdi, 'Ülke Adı', QueryOfDS);
      setFieldTitle(FISOYil, 'Yıl', QueryOfDS);
      setFieldTitle(FISOCCTLDKod, 'Cctld Kodu', QueryOfDS);
      setFieldTitle(FIsABUyesi, 'AB Üyesi?', QueryOfDS);
	  end;
  end;
end;

procedure TSysUlke.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FUlkeKodu.FieldName,
        TableName + '.' + FUlkeAdi.FieldName,
        TableName + '.' + FISOYil.FieldName,
        TableName + '.' + FISOCCTLDKod.FieldName,
        TableName + '.' + FISOYil.FieldName
      ], [
        addLeftJoin(FUlkeAdi.FieldName, FUlkeAdi.FieldName, TableName, True),
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
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysUlke.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FUlkeKodu.FieldName,
        FUlkeAdi.FieldName,
        FISOYil.FieldName,
        FISOCCTLDKod.FieldName,
        FIsABUyesi.FieldName
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

procedure TSysUlke.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FUlkeKodu.FieldName,
        FUlkeAdi.FieldName,
        FISOYil.FieldName,
        FISOCCTLDKod.FieldName,
        FIsABUyesi.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

function TSysUlke.Clone: TTable;
begin
  Result := TSysUlke.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
