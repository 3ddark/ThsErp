unit Ths.Erp.Database.Table.SysErisimHakki;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SysKaynak,
  Ths.Erp.Database.Table.SysKullanici;

type
  TSysErisimHakki = class(TTable)
  private
    FKaynakID: TFieldDB;
    FKaynakAdi: TFieldDB;
    FKaynakKodu: TFieldDB;
    FIsOkuma: TFieldDB;
    FIsYeniKayit: TFieldDB;
    FIsGuncelleme: TFieldDB;
    FIsSilme: TFieldDB;
    FIsOzel: TFieldDB;
    FKullaniciID: TFieldDB;
    FKullaniciAdi: TFieldDB;
  published
    FPermSrc: TSysKaynak;
    FSysUser: TSysKullanici;

    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;
    destructor Destroy; override;

    procedure GetAccessRightBySourceCode(ASourceCode: string);

    Property KaynakID: TFieldDB read FKaynakID write FKaynakID;
    Property KaynakAdi: TFieldDB read FKaynakAdi write FKaynakAdi;
    Property KaynakKodu: TFieldDB read FKaynakKodu write FKaynakKodu;
    Property IsOkuma: TFieldDB read FIsOkuma write FIsOkuma;
    Property IsYeniKayit: TFieldDB read FIsYeniKayit write FIsYeniKayit;
    Property IsGuncelleme: TFieldDB read FIsGuncelleme write FIsGuncelleme;
    Property IsSilme: TFieldDB read FIsSilme write FIsSilme;
    Property IsOzel: TFieldDB read FIsOzel write FIsOzel;
    Property KullaniciID: TFieldDB read FKullaniciID write FKullaniciID;
    Property KullaniciAdi: TFieldDB read FKullaniciAdi write FKullaniciAdi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TSysErisimHakki.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_erisim_hakki';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FPermSrc := TSysKaynak.Create(Database);
  FSysUser := TSysKullanici.Create(Database);

  FKaynakID := TFieldDB.Create('kaynak_id', ftInteger, 0, Self, 'Kaynak Adý ID');
  FKaynakAdi := TFieldDB.Create(FPermSrc.KaynakAdi.FieldName, FPermSrc.KaynakAdi.DataType, '', Self, 'Kaynak Adý');
  FKaynakKodu := TFieldDB.Create(FPermSrc.KaynakKodu.FieldName, FPermSrc.KaynakKodu.DataType, '', Self, 'Kaynak Kodu');
  FIsOkuma := TFieldDB.Create('is_okuma', ftBoolean, False, Self, 'Okuma?');
  FIsYeniKayit := TFieldDB.Create('is_yeni_kayit', ftBoolean, False, Self, 'Yeni Kayýt?');
  FIsGuncelleme := TFieldDB.Create('is_guncelleme', ftBoolean, False, Self, 'Güncelleme?');
  FIsSilme := TFieldDB.Create('is_silme', ftBoolean, False, Self, 'Silme?');
  FIsOzel := TFieldDB.Create('is_ozel', ftBoolean, False, Self, 'Özel?');
  FKullaniciID := TFieldDB.Create('kullanici_id', ftInteger, 0, Self, 'Kullanýcý Adý ID');
  FKullaniciAdi := TFieldDB.Create(FSysUser.KullaniciAdi.FieldName, FSysUser.KullaniciAdi.DataType, '', Self, 'Kullanýcý Adý');
end;

destructor TSysErisimHakki.Destroy;
begin
  FreeAndNil(FPermSrc);
  FreeAndNil(FSysUser);
  inherited;
end;

procedure TSysErisimHakki.GetAccessRightBySourceCode(ASourceCode: string);
begin
  Self.SelectToList(
    ' AND ' + FKaynakKodu.QryName + '=' + QuotedStr(ASourceCode) +
    ' AND ' + FKullaniciID.QryName + '=' + IntToStr(GSysKullanici.Id.Value) , False, False
  );
end;

procedure TSysErisimHakki.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
var
  LDump: string;
  LJoinTableName: string;
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    LDump := '';
    LJoinTableName := 'data_' + FKaynakAdi.FieldName;
    if  (GDataBase.ConnSetting.Language <> GSysUygulamaAyari.UygulamaLisan.Value)
    and (GSysUygulamaAyari.UygulamaLisan.Value <> '')
    then
    begin
      LDump := 'LEFT JOIN ' + FPermSrc.TableName + ' ON ' + FPermSrc.TableName + '.id=' + FKaynakID.QryName;
      LJoinTableName := FPermSrc.TableName;
    end;

	  with QueryOfDS do
	  begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FKaynakID.QryName,
        addLangField(FKaynakAdi.FieldName),
        'data_' + FKaynakAdi.FieldName + '.' + FKaynakKodu.FieldName,
        FIsOkuma.QryName,
        FIsYeniKayit.QryName,
        FIsGuncelleme.QryName,
        FIsSilme.QryName,
        FIsOzel.QryName,
        FKullaniciID.QryName,
        addLangField(FKullaniciAdi.FieldName)
      ], [
        addLeftJoin(FKaynakAdi.FieldName, FKaynakID.QryName, FPermSrc.TableName),
        addLeftJoin(FKullaniciAdi.FieldName, FKullaniciID.QryName, FSysUser.TableName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
	  end;
  end;
end;

procedure TSysErisimHakki.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LDump: string;
  LJoinTableName: string;
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    LDump := '';
    LJoinTableName := 'data_' + FKaynakAdi.FieldName;
    if  (GDataBase.ConnSetting.Language <> GSysUygulamaAyari.UygulamaLisan.Value)
    and (GSysUygulamaAyari.UygulamaLisan.Value <> '')
    then
    begin
      LDump := 'LEFT JOIN ' + FPermSrc.TableName + ' ON ' + FPermSrc.TableName + '.id=' + FKaynakID.QryName;
      LJoinTableName := FPermSrc.TableName;
    end;

	  with QueryOfList do
	  begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKaynakID.FieldName,
        addLangField(FKaynakAdi.FieldName),
        LJoinTableName + '.' + FKaynakKodu.FieldName,
        TableName + '.' + FIsOkuma.FieldName,
        TableName + '.' + FIsYeniKayit.FieldName,
        TableName + '.' + FIsGuncelleme.FieldName,
        TableName + '.' + FIsSilme.FieldName,
        TableName + '.' + FIsOzel.FieldName,
        TableName + '.' + FKullaniciID.FieldName,
        addLangField(FKullaniciAdi.FieldName)
      ], [
        LDump,
        addLeftJoin(FKaynakAdi.FieldName, TableName + '.' + FKaynakID.FieldName, FPermSrc.TableName),
        addLeftJoin(FKullaniciAdi.FieldName, TableName + '.' + FKullaniciID.FieldName, FSysUser.TableName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Clone);

        Next;
      end;
      EmptyDataSet;
      Close;
	  end;
  end;
end;

procedure TSysErisimHakki.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FKaynakID.FieldName,            
        FIsOkuma.FieldName,
        FIsYeniKayit.FieldName,
        FIsGuncelleme.FieldName,
        FIsSilme.FieldName,
        FIsOzel.FieldName,
        FKullaniciID.FieldName
      ]);

      PrepareInsertQueryParams;

		  Open;

      if (Fields.Count > 0) and (not Fields.FieldByName(Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Id.FieldName).AsInteger
      else  AID := 0;

		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysErisimHakki.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FKaynakID.FieldName,
        FIsOkuma.FieldName,
        FIsYeniKayit.FieldName,
        FIsGuncelleme.FieldName,
        FIsSilme.FieldName,
        FIsOzel.FieldName,
        FKullaniciID.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
  end;
end;

function TSysErisimHakki.Clone():TTable;
begin
  Result := TSysErisimHakki.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
