unit Ths.Erp.Database.Table.SysKaynak;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKaynakGrup;

type
  TSysKaynak = class(TTable)
  private
    FKaynakKodu: TFieldDB;
    FKaynakAdi: TFieldDB;
    FKaynakGrupID: TFieldDB;
    FKaynakGrup: TFieldDB;

    FSysKaynakGrp: TSysKaynakGrup;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property KaynakKodu: TFieldDB read FKaynakKodu write FKaynakKodu;
    property KaynakAdi: TFieldDB read FKaynakAdi write FKaynakAdi;
    property KaynakGrupID: TFieldDB read FKaynakGrupID write FKaynakGrupID;
    property KaynakGrup: TFieldDB read FKaynakGrup write FKaynakGrup;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysErisimHakki,
  Ths.Erp.Database.Table.SysKullanici;

constructor TSysKaynak.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_kaynak';
  TableSourceCode := '1';
  inherited Create(ADatabase);

  FSysKaynakGrp := TSysKaynakGrup.Create(ADatabase);

  FKaynakKodu := TFieldDB.Create('kaynak_kodu', ftInteger, 0, Self, 'Kaynak Kodu');
  FKaynakAdi := TFieldDB.Create('kaynak_adi', ftString, '', Self, 'Kaynak Adý');
  FKaynakGrupID := TFieldDB.Create('kaynak_grup_id', ftInteger, 0, Self, 'Kaynak Grup ID');
  FKaynakGrup := TFieldDB.Create(FSysKaynakGrp.KaynakGrup.FieldName, FSysKaynakGrp.KaynakGrup.DataType, '', Self, 'Kaynak Grup');
end;

destructor TSysKaynak.Destroy;
begin
  FreeAndNil(FSysKaynakGrp);
  inherited;
end;

procedure TSysKaynak.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKaynakGrupID.FieldName,
        addLangField(FKaynakGrup.FieldName),
        TableName + '.' + FKaynakKodu.FieldName,
        addLangField(FKaynakAdi.FieldName, '', True)
      ], [
        addLeftJoin(FKaynakGrup.FieldName, FKaynakGrupID.FieldName, FSysKaynakGrp.TableName),
        addLeftJoin(FKaynakAdi.FieldName, FKaynakAdi.FieldName, TableName, True),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FKaynakGrupID, 'Kaynak Grup Id', QueryOfDS);
      setFieldTitle(FKaynakGrup, 'Kaynak Grup', QueryOfDS);
      setFieldTitle(FKaynakKodu, 'Kaynak Kodu', QueryOfDS);
      setFieldTitle(FKaynakAdi, 'Kaynak Adý', QueryOfDS);
	  end;
  end;
end;

procedure TSysKaynak.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
begin
  if Self.IsAuthorized(ptRead, APermissionControl) then
  begin
	  if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKaynakGrupID.FieldName,
        addLangField(FKaynakGrup.FieldName),
        TableName + '.' + FKaynakKodu.FieldName,
        addLangField(FKaynakAdi.FieldName, '', True)
      ], [
        addLeftJoin(FKaynakGrup.FieldName, FKaynakGrupID.FieldName, FSysKaynakGrp.TableName),
        addLeftJoin(FKaynakAdi.FieldName, FKaynakAdi.FieldName, TableName, True),
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

procedure TSysKaynak.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FKaynakKodu.FieldName,
        FKaynakAdi.FieldName,
        FKaynakGrupID.FieldName
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

procedure TSysKaynak.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FKaynakKodu.FieldName,
        FKaynakAdi.FieldName,
        FKaynakGrupID.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

procedure TSysKaynak.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LRights: TSysErisimHakki;
  LSource: TSysKaynak;
  qry: TFDQuery;
begin
  Self.Insert(AID, APermissionControl);

  LRights := TSysErisimHakki.Create(Database);
  LSource := TSysKaynak.Create(Database);
  qry := Ths.Erp.Globals.GDataBase.NewQuery();
  try
    qry.SQL.Text :=
      'INSERT INTO ' + LRights.TableName + ' (' +
        LRights.KaynakID.FieldName + ', ' +
        LRights.IsOkuma.FieldName + ', ' +
        LRights.IsYeniKayit.FieldName + ', ' +
        LRights.IsGuncelleme.FieldName + ', ' +
        LRights.IsSilme.FieldName + ', ' +
        LRights.IsOzel.FieldName + ', ' +
        LRights.KullaniciID.FieldName + ') ' +
      '(SELECT ' +
        IntToStr(AID) +
        ', false, false, false, false, false, ' +
        GSysKullanici.TableName + '.' + GSysKullanici.Id.FieldName +
      ' FROM ' + GSysKullanici.TableName + ')';
    qry.ExecSQL;

  finally
    LRights.Free;
    LSource.Free;
    qry.Free;
  end;
end;

function TSysKaynak.Clone: TTable;
begin
  Result := TSysKaynak.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
