unit Ths.Erp.Database.Table.SysKullanici;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.PrsPersonel;

type
  TKullaniciStruct = record
    KullaniciAdi: string;
    KullaniciID: Integer;
  end;

  TKullaniciList = TArray<TKullaniciStruct>;

  TSysKullanici = class(TTable)
  private
    FKullaniciAdi: TFieldDB;
    FKullaniciSifre: TFieldDB;
    FIsAktif: TFieldDB;
    FIsBagli: TFieldDB;
    FIsYonetici: TFieldDB;
    FIsSuperKullanici: TFieldDB;
    FIpAdres: TFieldDB;
    FMacAdres: TFieldDB;
    FPersonelID: TFieldDB;
    FAdSoyad: TFieldDB;

    FPersonelKarti: TPrsPersonel;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    IsSifreDegisti: Boolean;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure CopyUserRightFromUser(AFromUserID: Integer);
    procedure CopyFromRights(FromUserID, ToUserID: Integer);
    function getActiveUsers(): TKullaniciList;

    property KullaniciAdi: TFieldDB read FKullaniciAdi write FKullaniciAdi;
    property KullaniciSifre: TFieldDB read FKullaniciSifre write FKullaniciSifre;
    property IsAktif: TFieldDB read FIsAktif write FIsAktif;
    property IsBagli: TFieldDB read FIsBagli write FIsBagli;
    property IsYonetici: TFieldDB read FIsYonetici write FIsYonetici;
    property IsSuperKullanici: TFieldDB read FIsSuperKullanici write FIsSuperKullanici;
    property IpAdres: TFieldDB read FIpAdres write FIpAdres;
    property MacAdres: TFieldDB read FMacAdres write FMacAdres;
    property PersonelID: TFieldDB read FPersonelID write FPersonelID;
    property AdSoyad: TFieldDB read FAdSoyad write FAdSoyad;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysErisimHakki,
  Ths.Erp.Database.Table.SysKaynak;

constructor TSysKullanici.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_kullanici';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FPersonelKarti := TPrsPersonel.Create(Database);

  IsSifreDegisti := False;

  FKullaniciAdi := TFieldDB.Create('kullanici_adi', ftString, '', Self, 'Kullanýcý Adý');
  FKullaniciSifre := TFieldDB.Create('kullanici_sifre', ftString, '', Self, 'Kullanýcý Þifresi');
  FIsAktif := TFieldDB.Create('is_aktif', ftBoolean, False, Self, 'Aktif?');
  FIsBagli := TFieldDB.Create('is_bagli', ftBoolean, False, Self, 'Baðlý?');
  FIsYonetici := TFieldDB.Create('is_yonetici', ftBoolean, False, Self, 'Yönetici?');
  FIsSuperKullanici := TFieldDB.Create('is_super_kullanici', ftBoolean, False, Self, 'Süper Kullanýcý?');
  FIpAdres := TFieldDB.Create('ip_adres', ftString, '', Self, 'Ip Adresi');
  FMacAdres := TFieldDB.Create('mac_adres', ftString, '', Self, 'Mac Adresi');
  FPersonelID := TFieldDB.Create('personel_id', ftInteger, 0, Self, 'Personel ID');
  FAdSoyad := TFieldDB.Create(FPersonelKarti.AdSoyad.FieldName, FPersonelKarti.AdSoyad.DataType, FPersonelKarti.AdSoyad.Value, Self, 'Personel Adý');
end;

destructor TSysKullanici.Destroy;
begin
  FreeAndNil(FPersonelKarti);
  inherited;
end;

function TSysKullanici.getActiveUsers: TKullaniciList;
var
  vUser: TSysKullanici;
  n1: Integer;
begin
  vUser := TSysKullanici.Create(Database);
  try
    //tüm aktif kullanýcýlarý array liste olarak ver
    vUser.SelectToList(' AND ' + vUser.TableName + '.' + vUser.FIsAktif.FieldName + '=True', False, False);
    SetLength(Result, vUser.List.Count);
    for n1 := 0 to vUser.List.Count-1 do
    begin
      Result[n1].KullaniciAdi := TSysKullanici(vUser.List[n1]).FKullaniciAdi.Value;
      Result[n1].KullaniciID := TSysKullanici(vUser.List[n1]).Id.Value;
    end;
  finally
    vUser.Free;
  end;
end;

procedure TSysKullanici.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FKullaniciAdi.FieldName,
        TableName + '.' + FKullaniciSifre.FieldName + '::varchar(256)',
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FIsBagli.FieldName,
        TableName + '.' + FIsYonetici.FieldName,
        TableName + '.' + FIsSuperKullanici.FieldName,
        TableName + '.' + FIpAdres.FieldName,
        TableName + '.' + FMacAdres.FieldName,
        TableName + '.' + FPersonelID.FieldName,
        addField(FPersonelKarti.TableName, FPersonelKarti.AdSoyad.FieldName, FAdSoyad.FieldName)
      ], [
        addJoin(jtLeft, FPersonelKarti.TableName, FPersonelKarti.Id.FieldName, TableName, FPersonelID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;
 	  end;
  end;
end;

procedure TSysKullanici.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FKullaniciAdi.FieldName,
        TableName + '.' + FKullaniciSifre.FieldName + '::varchar(256)',
        TableName + '.' + FIsAktif.FieldName,
        TableName + '.' + FIsBagli.FieldName,
        TableName + '.' + FIsYonetici.FieldName,
        TableName + '.' + FIsSuperKullanici.FieldName,
        TableName + '.' + FIpAdres.FieldName,
        TableName + '.' + FMacAdres.FieldName,
        TableName + '.' + FPersonelID.FieldName,
        addField(FPersonelKarti.TableName, FPersonelKarti.AdSoyad.FieldName, FAdSoyad.FieldName)
      ], [
        addJoin(jtLeft, FPersonelKarti.TableName, FPersonelKarti.Id.FieldName, TableName, FPersonelID.FieldName),
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

procedure TSysKullanici.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FKullaniciAdi.FieldName,
        FKullaniciSifre.FieldName,
        FIsAktif.FieldName,
        FIsBagli.FieldName,
        FIsYonetici.FieldName,
        FIsSuperKullanici.FieldName,
        FIpAdres.FieldName,
        FMacAdres.FieldName,
        FPersonelID.FieldName
      ]);

      if IsSifreDegisti then
        FKullaniciSifre.Value := getCryptedData(FKullaniciSifre.Value);

      PrepareInsertQueryParams;

      if not IsSifreDegisti then
        QueryOfInsert.SQL.Text := StringReplace(QueryOfInsert.SQL.Text, FKullaniciSifre.FieldName + '=' + QRY_PAR_CH + FKullaniciSifre.FieldName + ',', '', [rfReplaceAll]);

      Open;

      AID := 0;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
        AID := Fields.FieldByName(Self.Id.FieldName).AsInteger;

		  EmptyDataSet;
		  Close;
	  end;
    Self.notify;
  end;
end;

procedure TSysKullanici.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FKullaniciAdi.FieldName,
        FKullaniciSifre.FieldName,
        FIsAktif.FieldName,
        FIsBagli.FieldName,
        FIsYonetici.FieldName,
        FIsSuperKullanici.FieldName,
        FIpAdres.FieldName,
        FMacAdres.FieldName,
        FPersonelID.FieldName
      ]);

      if IsSifreDegisti then
        FKullaniciSifre.Value := getCryptedData(FKullaniciSifre.Value);

      PrepareUpdateQueryParams;

      if not IsSifreDegisti then
        QueryOfUpdate.SQL.Text := StringReplace(QueryOfUpdate.SQL.Text, FKullaniciSifre.FieldName + '=' + QRY_PAR_CH + FKullaniciSifre.FieldName + ',', '', [rfReplaceAll]);

		  ExecSQL;
		  Close;
	  end;

    Self.Notify;
  end;
end;

procedure TSysKullanici.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LErisimHakki: TSysErisimHakki;
  LKaynak: TSysKaynak;
  qry: TFDQuery;
begin
  Self.Insert(AID, APermissionControl);
  LErisimHakki := TSysErisimHakki.Create(Database);
  LKaynak := TSysKaynak.Create(Database);
  qry := DataBase.NewQuery();
  try
    qry.SQL.Text :=
      'INSERT INTO ' + LErisimHakki.TableName + ' (' +
        LErisimHakki.KaynakID.FieldName + ', ' +
        LErisimHakki.IsOkuma.FieldName + ', ' +
        LErisimHakki.IsYeniKayit.FieldName + ', ' +
        LErisimHakki.IsGuncelleme.FieldName + ', ' +
        LErisimHakki.IsSilme.FieldName + ', ' +
        LErisimHakki.IsOzel.FieldName + ', ' +
        LErisimHakki.KullaniciID.FieldName + ') ' +
      '(SELECT ' + LKaynak.TableName + '.' + LKaynak.Id.FieldName + ', false, false, false, false, false, ' + IntToStr(AID) + ' FROM ' + LKaynak.TableName + ')';
    qry.ExecSQL;
  finally
    LErisimHakki.Free;
    LKaynak.Free;
    qry.Free;
  end;
end;

function TSysKullanici.Clone: TTable;
begin
  Result := TSysKullanici.Create(Database);
  CloneClassContent(Self, Result);
end;

procedure TSysKullanici.CopyUserRightFromUser(AFromUserID: Integer);
var
  LErisimHakki: TSysErisimHakki;
  LKaynak: TSysKaynak;
  qry: TFDQuery;
begin
  LErisimHakki := TSysErisimHakki.Create(Database);
  LKaynak := TSysKaynak.Create(Database);
  qry := DataBase.NewQuery();
  Database.Connection.StartTransaction;
  try
    try
      //geçerli kullanýcýya ait tüm eriþim haklarý siliniyor
      qry.SQL.Text := ' DELETE FROM ' + LErisimHakki.TableName +
                      ' WHERE ' + LErisimHakki.TableName + '.' + LErisimHakki.KullaniciID.FieldName + '=' + IntToStr(Self.Id.Value);
      qry.ExecSQL;

      //hakalarýn kopyalanacaðý kullanýcýdan tüm haklar mevcut kullanýcý için insert ediliyor.
      qry.SQL.Text :=
        'INSERT INTO ' + LErisimHakki.TableName + ' (' +
          LErisimHakki.KaynakID.FieldName + ', ' +
          LErisimHakki.IsOkuma.FieldName + ', ' +
          LErisimHakki.IsYeniKayit.FieldName + ', ' +
          LErisimHakki.IsGuncelleme.FieldName + ', ' +
          LErisimHakki.IsSilme.FieldName + ', ' +
          LErisimHakki.IsOzel.FieldName + ', ' +
          LErisimHakki.KullaniciID.FieldName + ') ' +
        '(SELECT ' +
            't2.' + LErisimHakki.KaynakID.FieldName + ', ' +
            't2.' + LErisimHakki.IsOkuma.FieldName + ', ' +
            't2.' + LErisimHakki.IsYeniKayit.FieldName + ', ' +
            't2.' + LErisimHakki.IsGuncelleme.FieldName + ', ' +
            't2.' + LErisimHakki.IsSilme.FieldName + ', ' +
            't2.' + LErisimHakki.IsOzel.FieldName + ', ' +
            IntToStr(Self.Id.Value) + ' FROM ' + LErisimHakki.TableName + ' as t2 )';
      qry.ExecSQL;
      Database.Connection.Commit;
    finally
      LErisimHakki.Free;
      LKaynak.Free;
      qry.Free;
    end;
  except
    Database.Connection.Rollback;
  end;
end;

procedure TSysKullanici.CopyFromRights(FromUserID, ToUserID: Integer);
var
  LQry: TFDQuery;
begin
  LQry := GDataBase.NewQuery();
  try
    LQry.SQL.Clear;
    LQry.SQL.Text :=
      'UPDATE public.sys_user_access_right ri SET ' +
		    'is_read =       (SELECT is_read       FROM sys_user_access_right r WHERE r.user_name_id = ' + IntToStr(FromUserID) + ' and r.source_name_id = ri.source_name_id), ' +
		    'is_add_record = (SELECT is_add_record FROM sys_user_access_right r WHERE r.user_name_id = ' + IntToStr(FromUserID) + ' and r.source_name_id = ri.source_name_id), ' +
		    'is_update =     (SELECT is_update     FROM sys_user_access_right r WHERE r.user_name_id = ' + IntToStr(FromUserID) + ' and r.source_name_id = ri.source_name_id), ' +
		    'is_delete =     (SELECT is_delete     FROM sys_user_access_right r WHERE r.user_name_id = ' + IntToStr(FromUserID) + ' and r.source_name_id = ri.source_name_id), ' +
		    'is_special =    (SELECT is_special    FROM sys_user_access_right r WHERE r.user_name_id = ' + IntToStr(FromUserID) + ' and r.source_name_id = ri.source_name_id) ' +
      'WHERE user_name_id=' + IntToStr(ToUserID) +
       ' and source_name_id in (SELECT source_name_id FROM sys_user_access_right rf WHERE user_name_id=' + IntToStr(FromUserID) + ')';
    LQry.ExecSQL;
  finally
    LQry.Free;
  end;
end;


end.
